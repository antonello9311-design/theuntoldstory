"""Build reviewed E68 delta installer. No database or provider execution."""
from pathlib import Path
import argparse,json,hashlib,copy,re,ast,sys
j=lambda x:json.dumps(x,ensure_ascii=False,separators=(',',':'))
sha=lambda x:hashlib.sha256(x.encode()).hexdigest()
dq=lambda x,t:'$'+t+'$'+x+'$'+t+'$'
a=argparse.ArgumentParser();a.add_argument('--packet',default=str(Path(__file__).with_name('DB_PACKET.json')));a.add_argument('--baseline-json',required=True);a.add_argument('--edge-package',required=True);a.add_argument('--ui-manifest',required=True);a.add_argument('--preservation-json',required=True);a.add_argument('--preservation-query',required=True);a.add_argument('--constraints-json',required=True);a.add_argument('--tables-json',required=True);a.add_argument('--material');a.add_argument('--out',required=True);o=a.parse_args();P=Path(o.out);P.mkdir(parents=True,exist_ok=True)
p=json.loads(Path(o.packet).read_text());r=json.loads(Path(o.baseline_json).read_text());r=r[0] if isinstance(r,list) else r;base=r['canonical_preimage'];root=json.loads(base);assert sha(base)==r['revision_sha256']==r['observed_revision_sha256']==p['baseline_root'];assert len(root['db_core']['all_function_headers'])==246
cfg=p['config'];fs=p['functions'];edge=json.loads(Path(o.edge_package).read_text());ui=json.loads(Path(o.ui_manifest).read_text());assert edge['name']=='mission_generic_ai' and edge['verify_jwt'] is False
files=[{'name':f['name'],'bytes':len(f['content'].encode()),'sha256':sha(f['content'])} for f in edge['files']];uifiles={}
for f in ui['files']:
 b=Path(f['candidate_path']).read_bytes();assert len(b)==f['candidate_bytes'] and hashlib.sha256(b).hexdigest()==f['candidate_sha256'];uifiles[Path(f['path']).name]={'bytes':len(b),'sha256':f['candidate_sha256']}
cons=json.loads(Path(o.constraints_json).read_text());tables=json.loads(Path(o.tables_json).read_text());aftercons=copy.deepcopy(cons)
sem=sha(j({'schema':'editorial68-integrated/1','baseline':sha(base),'packet':sha(Path(o.packet).read_text()),'Edge':files,'UI':uifiles}))
params={'schema':'editorial68-material/1','semantic':sem,'review_ref':'C1266_EDITORIAL68_REVIEW.json','review_sha':'__E68_REVIEW_SHA__','p0':0,'p1':0,'p2':0,'ui_git_head':'__E68_UI_HEAD__','assets_verified':False,'edge_verified':False,'edge_version':'__E68_EDGE_VERSION__','edge_ezbr_sha256':'__E68_EDGE_SHA__'}
if o.material:params=json.loads(Path(o.material).read_text())
expected=[];updates={}
for i,f in enumerate(fs):
 old=f['before']['header'] if f['before'] else None;h=copy.deepcopy(old or f['expected_header']);h.update(signature=f['signature'],source_md5=f['source_md5'],ddl_md5='__E68_DDL_'+str(i)+'__')
 if old is None:h['oid']='__E68_OID_'+str(i)+'__'
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
c['contract']['code_identity_sha256']=sem;c['recovery']['semantic_identity_sha256']=sem;c['recovery']['editorial68']={'semantic':sem,'review_ref':params['review_ref'],'review_sha256':params['review_sha'],'previous_root_sha256':sha(base)}
c['config']['c1266_editorial68']={'campaign_id':cfg['campaign_id'],'policy_sha256':cfg['policy_sha256'],'active_variants':['director','writer']}
c['edge_bundles'][0].update(version=params['edge_version'],ezbr_sha256=params['edge_ezbr_sha256'],files=files)
c['ui']['git_head']=params['ui_git_head'];c['ui']['narrative_scene_version']=re.search(r"export const VERSION=['\"]([^'\"]+)",Path(next(f['candidate_path']for f in ui['files']if f['path'].endswith('mission-generic-ui.mjs'))).read_text()).group(1);c['ui']['module_pin']='editorial68-'+uifiles['mission-generic-ui.mjs']['sha256'][:16]
for name,f in uifiles.items():c['ui']['files'][name]=f
ct=j(c);assert len(ct.encode())<=262144,len(ct.encode())
# Frozen capture expressions from the previously reviewed compiler; no DB execution.
oldtree=ast.parse(Path('/private/tmp/tus-c1266-combat64-20261030/release30/build_release30.py').read_text());abi=next(ast.literal_eval(n.value) for n in oldtree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='abi_sql' for t in n.targets))
header=Path('/private/tmp/tus-c1266-combat64-20261030/release30/HEADER_CAPTURE_FRAGMENT.sql').read_text()
header=header.replace('INTO actual','INTO e68_actual').replace('to_regprocedure(sig)','to_regprocedure(e68_sig)').replace("'signature',sig","'signature',e68_sig");abi=abi.replace('INTO abi','INTO e68_abi').replace('to_regprocedure(sig)','to_regprocedure(e68_sig)')
preserve=Path(o.preservation_query).read_text();assert preserve.count(' evidence;')==1;capture=preserve.replace(' evidence;',' INTO e68_data;');preserved=json.loads(Path(o.preservation_json).read_text())
if isinstance(preserved,list):preserved=preserved[0]
if 'evidence'in preserved:preserved=preserved['evidence']
assert len(preserved['fati'])==43
e66ledger=Path('/private/tmp/tus-c1266-editorial66-20261030/postflight/LEDGER_QUERY.sql').read_text();e66expected=json.loads((Path(o.packet).parent/'E66_LEDGER_BASELINE.json').read_text())[0]['metadata']
common="""E66_CAPTURE
 IF e68_data IS DISTINCT FROM E66_EXPECTED THEN RAISE EXCEPTION 'E68_E66_HISTORY_DRIFT';END IF;
 FOR e68_item IN SELECT value FROM jsonb_array_elements(e68_preserved_abis) LOOP e68_sig:=e68_item->>'signature';ABI
 IF e68_abi IS DISTINCT FROM e68_item->'abi' THEN RAISE EXCEPTION 'E68_PRESERVED_ABI_DRIFT %',e68_sig;END IF;END LOOP;
 FOR e68_item IN SELECT value FROM jsonb_array_elements(e68_constraints) LOOP
 SELECT jsonb_build_object('relation',conrelid::regclass::text,'name',conname,'definition',pg_get_constraintdef(oid),'validated',convalidated,'type',contype::text) INTO e68_actual FROM pg_constraint WHERE conrelid=(e68_item->>'relation')::regclass AND conname=e68_item->>'name';
 IF e68_actual IS DISTINCT FROM e68_item THEN RAISE EXCEPTION 'E68_CONSTRAINT_DRIFT';END IF;END LOOP;
 IF (SELECT count(*) FROM pg_constraint WHERE conrelid IN(SELECT DISTINCT(value->>'relation')::regclass FROM jsonb_array_elements(e68_constraints)))<>jsonb_array_length(e68_constraints) THEN RAISE EXCEPTION 'E68_CONSTRAINT_SET_DRIFT';END IF;
 FOR e68_item IN SELECT value FROM jsonb_array_elements(e68_tables) LOOP
 SELECT jsonb_build_object('relation',ec.oid::regclass::text,'owner',pg_get_userbyid(ec.relowner),'rls',ec.relrowsecurity,'acl',ec.relacl::text,'columns',(SELECT jsonb_agg(jsonb_build_object('name',ea.attname,'type',format_type(ea.atttypid,ea.atttypmod),'notnull',ea.attnotnull,'default',pg_get_expr(ed.adbin,ed.adrelid)) ORDER BY ea.attnum) FROM pg_attribute ea LEFT JOIN pg_attrdef ed ON ed.adrelid=ea.attrelid AND ed.adnum=ea.attnum WHERE ea.attrelid=ec.oid AND ea.attnum>0 AND NOT ea.attisdropped)) INTO e68_actual FROM pg_class ec WHERE ec.oid=to_regclass(e68_item->>'relation');
 IF e68_actual IS DISTINCT FROM e68_item THEN RAISE EXCEPTION 'E68_TABLE_DRIFT';END IF;END LOOP;
 CAPTURE
 IF e68_data IS DISTINCT FROM PRESERVATION THEN RAISE EXCEPTION 'E68_HISTORY_DRIFT';END IF;"""
mat="""IF e68_params->>'schema'<>'editorial68-material/1' OR e68_params->>'semantic'<>'SEMANTIC' OR e68_params->>'review_ref'<>'C1266_EDITORIAL68_REVIEW.json' OR e68_params->'p0'<>'0'::jsonb OR e68_params->'p1'<>'0'::jsonb OR e68_params->'p2'<>'0'::jsonb OR coalesce(e68_params->>'review_sha','')!~'^[a-f0-9]{64}$' OR coalesce(e68_params->>'ui_git_head','')!~'^[a-f0-9]{40}$' OR e68_params->'assets_verified' IS DISTINCT FROM 'true'::jsonb OR e68_params->'edge_verified' IS DISTINCT FROM 'true'::jsonb OR coalesce(e68_params->>'edge_ezbr_sha256','')!~'^[a-f0-9]{64}$' OR jsonb_typeof(e68_params->'edge_version')<>'number' OR(e68_params->>'edge_version')::integer<=132 THEN RAISE EXCEPTION 'E68_MATERIAL_UNQUALIFIED';END IF;""".replace('SEMANTIC',sem)
decl="DECLARE e68_params jsonb:=PARAMS;e68_base text:=BASELINE;e68_new text:=CANDIDATE;e68_expected jsonb:=EXPECTED;e68_constraints jsonb:=CONSTRAINTS;e68_tables jsonb:=TABLES;e68_preserved_abis jsonb:=PRESERVED_ABIS;e68_item jsonb;e68_actual jsonb;e68_abi jsonb;e68_sig text;e68_token text;e68_data jsonb;e68_rr mission_factory_owner.editor_release_readiness;e68_sha text;"
pre="""BEGIN;DO $e68pre$
DECL
BEGIN
 MAT
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'E68_OPERATOR_REQUIRED';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN RAISE EXCEPTION 'E68_RELEASE_BUSY';END IF;
 SELECT * INTO STRICT e68_rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF e68_rr.canonical_preimage IS DISTINCT FROM e68_base OR e68_rr.revision_sha256<>'BEFORE_SHA' OR e68_rr.observed_revision_sha256<>e68_rr.revision_sha256 OR e68_rr.state<>'enabled' OR e68_rr.scope<>'staff' OR NOT e68_rr.staff_guards_verified OR NOT e68_rr.published_assets_verified THEN RAISE EXCEPTION 'E68_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_campaigns_v1 WHERE id='CAMPAIGN') THEN RAISE EXCEPTION 'E68_CAMPAIGN_EXISTS';END IF;
 FOR e68_item IN SELECT value FROM jsonb_array_elements(PACKET::jsonb#>'{config,source_refs}')LOOP
 IF NOT EXISTS(SELECT 1 FROM mission_creation_owner.revisions r JOIN mission_generic_owner.definitions d ON d.plan_version_id=r.plan_version_id JOIN public.mission_plan_versions v ON v.id=d.plan_version_id WHERE r.plan_version_id=(e68_item#>>'{source,plan_version_id}')::uuid AND v.stato='approvata'AND v.plan_sha256=e68_item#>>'{source,plan_sha256}'AND r.document_sha256=e68_item#>>'{source,snapshot,document_sha256}'AND r.document_sha256=mission_internal.fingerprint(r.document)AND d.id=(e68_item#>>'{source,snapshot,definition_id}')::uuid AND d.definition_sha256=e68_item#>>'{source,snapshot,definition_sha256}'AND d.definition_sha256=mission_internal.fingerprint(d.definition)AND r.document#>'{editorial,setting}'=e68_item#>'{source,snapshot,scene,setting}') THEN RAISE EXCEPTION 'E68_VERSIONED_SOURCE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(e68_item#>'{source,npc_refs}')nr WHERE NOT EXISTS(SELECT 1 FROM public.nb_template_versions nv JOIN public.nb_mechanical_bindings nb ON nb.narrative_version_id=nv.id WHERE nv.id=(nr->>'version_id')::uuid AND nv.template_id=(nr->>'template_id')::uuid AND nv.review_state='approved'AND nv.content_sha256=nr->>'content_sha256'AND nb.id=(nr->>'binding_id')::uuid AND nb.lifecycle_state='approved'AND NOT nb.active AND EXISTS(SELECT 1 FROM jsonb_array_elements(e68_item#>'{source,snapshot,scene,npcs}')np WHERE np->>'actor_key'=nr->>'actor_key'AND np->>'narrative_version_id'=nv.id::text AND np->'profile'=nv.skeleton AND np->'knowledge'=nv.knowledge_boundary))) THEN RAISE EXCEPTION 'E68_PROFILE_SOURCE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(e68_item#>'{source,last_fati}')hf WHERE NOT EXISTS(SELECT 1 FROM public.messages m WHERE m.id=(hf->>'message_id')::uuid AND m.kind='fato'AND m.recipient_user IS NULL AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'AND m.body=hf->>'body'AND encode(extensions.digest(convert_to(m.body,'UTF8'),'sha256'),'hex')=hf->>'body_sha256')) OR EXISTS(SELECT 1 FROM jsonb_array_elements(e68_item#>'{source,questions}')q WHERE encode(extensions.digest(convert_to(q->>'body','UTF8'),'sha256'),'hex')IS DISTINCT FROM q->>'body_sha256') THEN RAISE EXCEPTION 'E68_REAL_HISTORY_QUESTION_DRIFT';END IF;END LOOP;
 FOR e68_item IN SELECT value FROM jsonb_array_elements(e68_base::jsonb#>'{db_core,all_function_headers}') LOOP e68_sig:=e68_item->>'signature';HEADER
 IF e68_actual IS DISTINCT FROM e68_item THEN RAISE EXCEPTION 'E68_BASELINE_HEADER_DRIFT %',e68_sig;END IF;END LOOP;
 FOR e68_item IN SELECT value FROM jsonb_array_elements(e68_expected) LOOP e68_sig:=e68_item->>'signature';HEADER
 IF e68_actual IS DISTINCT FROM nullif(e68_item->'before','null'::jsonb) THEN RAISE EXCEPTION 'E68_TARGET_HEADER_DRIFT %',e68_sig;END IF;
 IF e68_actual IS NOT NULL THEN ABI
 IF e68_abi IS DISTINCT FROM e68_item->'abi' THEN RAISE EXCEPTION 'E68_ABI_DRIFT %',e68_sig;END IF;END IF;END LOOP;
 COMMON
END $e68pre$;
"""
post="""DO $e68post$
DECL
BEGIN
 MAT
 FOR e68_item IN SELECT value FROM jsonb_array_elements(e68_expected) LOOP e68_sig:=e68_item->>'signature';HEADER
 IF e68_actual IS NULL OR(e68_actual-'oid'-'ddl_md5') IS DISTINCT FROM ((e68_item->'header')-'oid'-'ddl_md5') OR(e68_item->'before'<>'null'::jsonb AND e68_actual->'oid' IS DISTINCT FROM e68_item#>'{before,oid}') THEN RAISE EXCEPTION 'E68_POST_FUNCTION_DRIFT %',e68_sig;END IF;
 ABI
 IF e68_abi IS DISTINCT FROM e68_item->'abi' THEN RAISE EXCEPTION 'E68_POST_ABI_DRIFT %',e68_sig;END IF;
 e68_token:=e68_item#>>'{header,ddl_md5}';e68_new:=replace(e68_new,to_jsonb(e68_token)::text,to_jsonb(e68_actual->>'ddl_md5')::text);
 IF e68_item->'before'='null'::jsonb THEN e68_token:=e68_item#>>'{header,oid}';e68_new:=replace(e68_new,to_jsonb(e68_token)::text,e68_actual->>'oid');END IF;END LOOP;
 FOR e68_item IN SELECT value FROM jsonb_array_elements(e68_new::jsonb#>'{db_core,all_function_headers}') LOOP e68_sig:=e68_item->>'signature';HEADER
 IF e68_actual IS DISTINCT FROM e68_item THEN RAISE EXCEPTION 'E68_FINAL_HEADER_DRIFT %',e68_sig;END IF;END LOOP;
 COMMON
 IF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_campaigns_v1 WHERE id='CAMPAIGN' AND NOT enabled AND policy_sha256='POLICY_SHA' AND policy_sha256=public.combat_v2_sha256(jsonb_build_object('policy',policy,'source_refs',source_refs))) OR EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_runs_v1 WHERE campaign_id='CAMPAIGN') OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls WHERE scope_id='CAMPAIGN') THEN RAISE EXCEPTION 'E68_SEED_PROVIDER_EFFECT';END IF;
 IF octet_length(e68_new)>262144 OR strpos(e68_new,'__E68_')>0 THEN RAISE EXCEPTION 'E68_UNMATERIAL';END IF;
 e68_sha:=encode(extensions.digest(convert_to(e68_new,'UTF8'),'sha256'),'hex');
 UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=e68_new,revision_sha256=e68_sha,observed_revision_sha256=e68_sha,client_build='mission-factory-admin/2:'||e68_sha,independent_review_ref='C1266_EDITORIAL68_REVIEW.json',updated_at=clock_timestamp() WHERE singleton AND revision_sha256='BEFORE_SHA';
 IF NOT FOUND THEN RAISE EXCEPTION 'E68_CAS_LOST';END IF;
END $e68post$;COMMIT;NOTIFY pgrst,'reload schema';
"""
def expand(s,after=False):
 vals={'DECL':decl,'MAT':mat,'COMMON':common,'HEADER':header,'ABI':abi,'CAPTURE':capture,'BASELINE':dq(base,'e68base'),'CANDIDATE':dq(ct,'e68root'),'PARAMS':dq(j(params),'e68params')+'::jsonb','PACKET':dq(j(p),'e68packet')+'::jsonb','EXPECTED':dq(j(expected),'e68expected')+'::jsonb','CONSTRAINTS':dq(j(aftercons if after else cons),'e68constraints')+'::jsonb','TABLES':dq(j(tables),'e68tables')+'::jsonb','PRESERVED_ABIS':dq(j(p['preserved_abis']),'e68preservedabis')+'::jsonb','PRESERVATION':dq(j(preserved),'e68preserve')+'::jsonb','E66_CAPTURE':e66ledger.replace('metadata;','INTO e68_data;'),'E66_EXPECTED':dq(j(e66expected),'e68e66preserve')+'::jsonb','BEFORE_SHA':sha(base),'CAMPAIGN':cfg['campaign_id'],'POLICY_SHA':cfg['policy_sha256']}
 for _ in range(3):s=re.sub(r'\b('+'|'.join(vals)+r')\b',lambda m:vals[m.group(0)],s)
 return s
sql=expand(pre)+p['constraint_sql']+'\n'+'\n\n'.join(f['source'].rstrip(';')+';' for f in fs)+'\n'+p['acl_sql']+p['seed_sql']+'\n'+expand(post,True)
sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312');from pglast import parse_sql,parse_plpgsql
nodes=parse_sql(sql)
for n in nodes:
 if type(n.stmt).__name__=='DoStmt':parse_plpgsql('DO '+dq(n.stmt.args[0].arg.sval,'e68parse'))
(P/'INSTALL.sql').write_text(sql);(P/'ROOT_TEMPLATE.json').write_text(ct);(P/'MATERIAL_TEMPLATE.json').write_text(json.dumps(params,indent=2));(P/'MANIFEST.json').write_text(json.dumps({'schema':'editorial68-release/1','semantic':sem,'baseline_root':sha(base),'baseline_canonical_preimage':base,'Root_bytes':len(ct.encode()),'headers_before':246,'headers_after':246,'functions':len(fs),'sql_sha256':sha(sql),'sql_bytes':len(sql.encode()),'SQL_nodes':len(nodes),'SQL_parse':True,'PL_DO_parse':True,'function_static':p['static'],'Edge_files':files,'UI_files':uifiles,'campaign':cfg,'preservation':preserved},indent=2));print(json.dumps({'semantic':sem,'root_bytes':len(ct.encode()),'SQL_sha256':sha(sql),'SQL_nodes':len(nodes)}))
# A separate, reviewed, one-shot ENABLE sets the real assistant clock only after install/UI readiness.
enable="""BEGIN;DO $e68enable$
DECL
 e68_campaign mission_narrative_internal.editorial_campaigns_v1;e68_now timestamptz;e68_policy jsonb;e68_policy_sha text;
BEGIN
 MAT
 IF current_user<>'postgres'THEN RAISE EXCEPTION 'E68_ENABLE_OPERATOR_REQUIRED';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'E68_ENABLE_BUSY';END IF;
 SELECT * INTO STRICT e68_rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 FOR e68_item IN SELECT value FROM jsonb_array_elements(e68_expected)LOOP e68_sig:=e68_item->>'signature';HEADER
 IF e68_actual IS NULL OR(e68_actual-'oid'-'ddl_md5')IS DISTINCT FROM((e68_item->'header')-'oid'-'ddl_md5')OR e68_actual->'oid'IS DISTINCT FROM e68_item#>'{before,oid}'THEN RAISE EXCEPTION 'E68_ENABLE_FUNCTION_DRIFT';END IF;
 ABI
 IF e68_abi IS DISTINCT FROM e68_item->'abi'THEN RAISE EXCEPTION 'E68_ENABLE_ABI_DRIFT';END IF;
 e68_token:=e68_item#>>'{header,ddl_md5}';e68_new:=replace(e68_new,to_jsonb(e68_token)::text,to_jsonb(e68_actual->>'ddl_md5')::text);END LOOP;
 IF e68_rr.canonical_preimage IS DISTINCT FROM e68_new OR e68_rr.revision_sha256 IS DISTINCT FROM encode(extensions.digest(convert_to(e68_new,'UTF8'),'sha256'),'hex')OR e68_rr.observed_revision_sha256<>e68_rr.revision_sha256 OR e68_rr.scope<>'staff'OR e68_rr.state<>'enabled'THEN RAISE EXCEPTION 'E68_ENABLE_ROOT_DRIFT';END IF;
 FOR e68_item IN SELECT value FROM jsonb_array_elements(e68_new::jsonb#>'{db_core,all_function_headers}')LOOP e68_sig:=e68_item->>'signature';HEADER
 IF e68_actual IS DISTINCT FROM e68_item THEN RAISE EXCEPTION 'E68_ENABLE_ALL_HEADER_DRIFT';END IF;END LOOP;
 COMMON
 SELECT * INTO STRICT e68_campaign FROM mission_narrative_internal.editorial_campaigns_v1 WHERE id='CAMPAIGN'FOR UPDATE;
 IF e68_campaign.enabled OR e68_campaign.policy_sha256<>'POLICY_SHA'OR e68_campaign.policy_sha256<>public.combat_v2_sha256(jsonb_build_object('policy',e68_campaign.policy,'source_refs',e68_campaign.source_refs))OR e68_campaign.policy->'provider_deadline'IS DISTINCT FROM'null'::jsonb OR e68_campaign.policy->'close_deadline'IS DISTINCT FROM'null'::jsonb OR EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_runs_v1 WHERE campaign_id=e68_campaign.id)OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls WHERE scope_id=e68_campaign.id)THEN RAISE EXCEPTION 'E68_ENABLE_NOT_PRISTINE';END IF;
 IF NOT EXISTS(SELECT 1 FROM public.profiles pr JOIN public.presence pp ON pp.user_id=pr.id WHERE pr.id=(e68_campaign.source_refs#>>'{0,source,author_user_id}')::uuid AND pr.role IN('admin','master')AND pp.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b')THEN RAISE EXCEPTION 'E68_ENABLE_STAFF_NOT_PRESENT';END IF;
 e68_now:=clock_timestamp();e68_policy:=jsonb_set(jsonb_set(e68_campaign.policy,'{provider_deadline}',to_jsonb(e68_now+interval '75 minutes')),'{close_deadline}',to_jsonb(e68_now+interval '90 minutes'));
 e68_policy_sha:=public.combat_v2_sha256(jsonb_build_object('policy',e68_policy,'source_refs',e68_campaign.source_refs));
 IF length(e68_new)-length(replace(e68_new,'POLICY_SHA',''))<>64 THEN RAISE EXCEPTION 'E68_ENABLE_ROOT_PIN_AMBIGUOUS';END IF;
 e68_new:=replace(e68_new,to_jsonb('POLICY_SHA'::text)::text,to_jsonb(e68_policy_sha)::text);
 IF(e68_new::jsonb#-'{config,c1266_editorial68,policy_sha256}')IS DISTINCT FROM(e68_rr.canonical_preimage::jsonb#-'{config,c1266_editorial68,policy_sha256}')OR octet_length(e68_new)>262144 THEN RAISE EXCEPTION 'E68_ENABLE_ROOT_EXTRA_MUTATION';END IF;
 UPDATE mission_narrative_internal.editorial_campaigns_v1 SET policy=e68_policy,policy_sha256=e68_policy_sha,enabled=true WHERE id=e68_campaign.id AND NOT enabled AND policy_sha256='POLICY_SHA';
 IF NOT FOUND THEN RAISE EXCEPTION 'E68_ENABLE_CAMPAIGN_CAS';END IF;
 e68_sha:=encode(extensions.digest(convert_to(e68_new,'UTF8'),'sha256'),'hex');
 UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=e68_new,revision_sha256=e68_sha,observed_revision_sha256=e68_sha,client_build='mission-factory-admin/2:'||e68_sha,updated_at=e68_now WHERE singleton AND revision_sha256=e68_rr.revision_sha256;
 IF NOT FOUND THEN RAISE EXCEPTION 'E68_ENABLE_ROOT_CAS';END IF;
 COMMON
END $e68enable$;COMMIT;
"""
enablesql=expand(enable,True);enodes=parse_sql(enablesql)
for n in enodes:
 if type(n.stmt).__name__=='DoStmt':parse_plpgsql('DO '+dq(n.stmt.args[0].arg.sval,'e68enableparse'))
(P/'ENABLE.sql').write_text(enablesql)
(P/'POSTFLIGHT_PRESERVATION_QUERY.sql').write_text(preserve);(P/'POSTFLIGHT_E66_QUERY.sql').write_text(e66ledger)
m=json.loads((P/'MANIFEST.json').read_text());m.update(ENABLE_sha256=sha(enablesql),ENABLE_SQL_parse=True,ENABLE_PL_parse=True,campaign_initially_disabled=True,clock_start='Separate one-shot ENABLE; provider75/close90; no automatic calls',UI_unchanged=False,new_schema_or_constraints=0,all246_headers_before=True,all246_headers_after=True,ABI_count=10);(P/'MANIFEST.json').write_text(json.dumps(m,indent=2))
