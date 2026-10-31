"""Build the single-function E68 alias correction, without DB execution."""
from pathlib import Path
import json,hashlib,re,copy,sys,ast,argparse
j=lambda x:json.dumps(x,ensure_ascii=False,separators=(',',':'))
sha=lambda x:hashlib.sha256(x.encode()).hexdigest()
dq=lambda x,t:'$'+t+'$'+x+'$'+t+'$'
a=argparse.ArgumentParser();a.add_argument('--inputs',required=True);a.add_argument('--material');a.add_argument('--out',required=True);o=a.parse_args();B=Path(o.inputs);P=Path(o.out);P.mkdir(parents=True,exist_ok=True)
p=json.loads((B/'PACKET.json').read_text());r=json.loads((B/'ROOT_BASELINE.json').read_text());base=r['canonical_preimage'];root=json.loads(base);assert sha(base)==r['revision_sha256']==r['observed_revision_sha256']==p['baseline_root'];assert len(root['db_core']['all_function_headers'])==246
f=p['function'];semantic=sha(j({'schema':'editorial68-recovery13/1','baseline':sha(base),'function':f['signature'],'source':sha(f['source'])}))
params={'schema':'editorial68-recovery13-material/1','semantic':semantic,'review_ref':'C1266_EDITORIAL68_RECOVERY13_REVIEW.json','review_sha':'__E68_REVIEW_SHA__','p0':0,'p1':0,'p2':0}
if o.material:params=json.loads(Path(o.material).read_text())
c=copy.deepcopy(root)
def rewrite(v):
 if isinstance(v,dict):
  if v.get('signature')==f['signature']:
   if 'source_md5'in v:v['source_md5']=f['source_md5']
   if 'ddl_md5'in v:v['ddl_md5']='__E68_DDL_13__'
  for x in v.values():rewrite(x)
 elif isinstance(v,list):
  for x in v:rewrite(x)
rewrite(c['db_core']);c['contract']['code_identity_sha256']=semantic;c['recovery']['semantic_identity_sha256']=semantic;c['recovery']['editorial68']={'semantic':semantic,'review_ref':params['review_ref'],'review_sha256':params['review_sha'],'previous_root_sha256':sha(base)}
assert c['config']==root['config'] and c['ui']==root['ui'] and c['edge_bundles']==root['edge_bundles'];ct=j(c);assert len(ct.encode())<=262144
tree=ast.parse(Path('/private/tmp/tus-c1266-editorial68-20261031/release11/DB_BUILD.py').read_text());common=next(ast.literal_eval(n.value)for n in tree.body if isinstance(n,ast.Assign)and any(isinstance(t,ast.Name)and t.id=='common'for t in n.targets))
old=ast.parse(Path('/private/tmp/tus-c1266-combat64-20261030/release30/build_release30.py').read_text());abi=next(ast.literal_eval(n.value)for n in old.body if isinstance(n,ast.Assign)and any(isinstance(t,ast.Name)and t.id=='abi_sql'for t in n.targets));abi=abi.replace('INTO abi','INTO e68_abi').replace('to_regprocedure(sig)','to_regprocedure(e68_sig)')
header=Path('/private/tmp/tus-c1266-combat64-20261030/release30/HEADER_CAPTURE_FRAGMENT.sql').read_text().replace('INTO actual','INTO e68_actual').replace('to_regprocedure(sig)','to_regprocedure(e68_sig)').replace("'signature',sig","'signature',e68_sig")
preserve=Path('/private/tmp/tus-c1266-editorial66-20261030/postflight/PRESERVATION_QUERY.sql').read_text();preserved=json.loads((B/'PRESERVATION_BASELINE.json').read_text())[0]['evidence'];assert len(preserved['fati'])==43
e66query=Path('/private/tmp/tus-c1266-editorial66-20261030/postflight/LEDGER_QUERY.sql').read_text();e66=json.loads((B/'E66_LEDGER_BASELINE.json').read_text())[0]['metadata']
cons=json.loads(Path('/private/tmp/tus-c1266-editorial68-20261031/db/CONSTRAINTS_BEFORE.json').read_text());tables=json.loads(Path('/private/tmp/tus-c1266-editorial68-20261031/db/TABLES_BEFORE.json').read_text());campaign=json.loads((B/'CAMPAIGN_BASELINE.json').read_text())[0];assert campaign['enabled']and campaign['runs']==campaign['calls']==0
vals={'E66_CAPTURE':e66query.replace('metadata;','INTO e68_data;'),'E66_EXPECTED':'e68_e66expected','ABI':abi,'HEADER':header,'CAPTURE':preserve.replace(' evidence;',' INTO e68_data;'),'PRESERVATION':'e68_preserved'}
common=re.sub(r'\b('+'|'.join(vals)+r')\b',lambda m:vals[m.group(0)],common)
cg="""IF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_campaigns_v1 ec WHERE ec.id='a8c3c6f9-949d-5b64-8a02-80667c7b4da8'AND public.combat_v2_sha256(to_jsonb(ec))=CAMSHA)OR EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_runs_v1 er WHERE er.campaign_id='a8c3c6f9-949d-5b64-8a02-80667c7b4da8')OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls eq WHERE eq.scope_id='a8c3c6f9-949d-5b64-8a02-80667c7b4da8')THEN RAISE EXCEPTION 'E68_RECOVERY13_CAMPAIGN_DRIFT';END IF;""".replace('CAMSHA',"'"+campaign['campaign_row_sha256']+"'")
constants={'e68_base':base,'e68_new':ct};jsonconst={'e68_params':params,'e68_constraints':cons,'e68_tables':tables,'e68_preserved_abis':p['all_abis'],'e68_preserved':preserved,'e68_e66expected':e66,'e68_beforeheader':f['before_header']}
decl='\n'.join(k+' text:='+dq(v,k)+';'for k,v in constants.items())+'\n'+'\n'.join(k+' jsonb:='+dq(j(v),k)+'::jsonb;'for k,v in jsonconst.items())
sql="""BEGIN;DO $e68_recovery13$
DECLARE DECL
e68_item jsonb;e68_actual jsonb;e68_abi jsonb;e68_sig text;e68_data jsonb;e68_rr mission_factory_owner.editor_release_readiness;e68_sha text;
BEGIN
IF e68_params->>'schema'<>'editorial68-recovery13-material/1'OR e68_params->>'semantic'<>'SEMANTIC'OR e68_params->>'review_ref'<>'C1266_EDITORIAL68_RECOVERY13_REVIEW.json'OR coalesce(e68_params->>'review_sha','')!~'^[a-f0-9]{64}$'OR e68_params->'p0'IS DISTINCT FROM'0'::jsonb OR e68_params->'p1'IS DISTINCT FROM'0'::jsonb OR e68_params->'p2'IS DISTINCT FROM'0'::jsonb THEN RAISE EXCEPTION 'E68_RECOVERY13_UNQUALIFIED';END IF;
IF current_user<>'postgres'THEN RAISE EXCEPTION 'E68_OPERATOR_REQUIRED';END IF;
IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'E68_RELEASE_BUSY';END IF;
SELECT * INTO STRICT e68_rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
IF e68_rr.canonical_preimage IS DISTINCT FROM e68_base OR e68_rr.revision_sha256<>'BASESHA'OR e68_rr.observed_revision_sha256<>e68_rr.revision_sha256 OR e68_rr.state<>'enabled'OR e68_rr.scope<>'staff'OR NOT e68_rr.staff_guards_verified OR NOT e68_rr.published_assets_verified THEN RAISE EXCEPTION 'E68_RECOVERY13_BASELINE_DRIFT';END IF;
FOR e68_item IN SELECT value FROM jsonb_array_elements(e68_base::jsonb#>'{db_core,all_function_headers}')LOOP e68_sig:=e68_item->>'signature';HEADER
IF e68_actual IS DISTINCT FROM e68_item THEN RAISE EXCEPTION 'E68_RECOVERY13_HEADER_DRIFT %',e68_sig;END IF;END LOOP;
COMMON
CAMPAIGN
EXECUTE DDL;
e68_sig:='SIGNATURE';HEADER
IF (e68_actual-'ddl_md5')IS DISTINCT FROM(e68_beforeheader-'ddl_md5')||jsonb_build_object('source_md5','NEWMD5')THEN RAISE EXCEPTION 'E68_RECOVERY13_TARGET_DRIFT';END IF;
e68_new:=replace(e68_new,to_jsonb('__E68_DDL_13__'::text)::text,to_jsonb(e68_actual->>'ddl_md5')::text);
FOR e68_item IN SELECT value FROM jsonb_array_elements(e68_new::jsonb#>'{db_core,all_function_headers}')LOOP e68_sig:=e68_item->>'signature';HEADER
IF e68_actual IS DISTINCT FROM e68_item THEN RAISE EXCEPTION 'E68_RECOVERY13_FINAL_HEADER_DRIFT %',e68_sig;END IF;END LOOP;
COMMON
CAMPAIGN
IF octet_length(e68_new)>262144 OR strpos(e68_new,'__E68_')>0 THEN RAISE EXCEPTION 'E68_RECOVERY13_UNMATERIAL';END IF;
e68_sha:=encode(extensions.digest(convert_to(e68_new,'UTF8'),'sha256'),'hex');
UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=e68_new,revision_sha256=e68_sha,observed_revision_sha256=e68_sha,client_build='mission-factory-admin/2:'||e68_sha,independent_review_ref='C1266_EDITORIAL68_RECOVERY13_REVIEW.json',updated_at=clock_timestamp()WHERE singleton AND revision_sha256='BASESHA';
IF NOT FOUND THEN RAISE EXCEPTION 'E68_RECOVERY13_CAS_LOST';END IF;
END;$e68_recovery13$;COMMIT;NOTIFY pgrst,'reload schema';
"""
v={'DECL':decl,'SEMANTIC':semantic,'BASESHA':sha(base),'HEADER':header,'COMMON':common,'CAMPAIGN':cg,'DDL':dq(f['source'],'e68ddl13'),'SIGNATURE':f['signature'],'NEWMD5':f['source_md5']};sql=re.sub(r'\b('+'|'.join(v)+r')\b',lambda m:v[m.group(0)],sql)
sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312');from pglast import parse_sql,parse_plpgsql
parse_sql(sql);parse_plpgsql(sql.replace('e68_rr mission_factory_owner.editor_release_readiness','e68_rr record'));parse_sql(f['source']);parse_plpgsql(f['source'].replace('c mission_narrative_internal.editorial_campaigns_v1','c record').replace('r mission_narrative_internal.editorial_runs_v1','r record').replace('w mission_generic_owner.work_items','w record').replace('wc mission_public_owner.work_contracts_v1','wc record').replace('parent_run mission_narrative_internal.editorial_runs_v1','parent_run record').replace('e68_anchor mission_generic_owner.work_items','e68_anchor record'))
wire=max(len(json.dumps({'query':sql},ensure_ascii=x).encode())for x in [False,True]);assert wire<900000
(P/'INSTALL.sql').write_text(sql);(P/'ROOT_TEMPLATE.json').write_text(ct);(P/'MATERIAL_TEMPLATE.json').write_text(json.dumps(params,indent=2));(P/'MANIFEST.json').write_text(json.dumps({'schema':'editorial68-recovery13-build/1','semantic':semantic,'baseline_root':sha(base),'baseline_canonical_preimage':base,'Root_bytes':len(ct.encode()),'SQL_sha256':sha(sql),'SQL_bytes':len(sql.encode()),'wire_bytes_max':wire,'SQL_PL_parse':'PASS','headers':246,'ABI_count':10,'changed_function':f['signature'],'constraints_changed':[],'campaign_row_sha256':campaign['campaign_row_sha256'],'provider_deadline':campaign['provider_deadline'],'close_deadline':campaign['close_deadline'],'no_campaign_mutation':True},indent=2));print(json.dumps({'semantic':semantic,'SQL_sha256':sha(sql),'wire_bytes_max':wire,'Root_bytes':len(ct.encode())}))
