#!/usr/bin/env python3
"""Offline generator: one finite message CASE, no SQL execution or connection."""
from pathlib import Path
import argparse,hashlib,json,re

def sha(v):return hashlib.sha256(v if isinstance(v,bytes) else v.encode()).hexdigest()
def lit(s):return "'"+s.replace("'","''")+"'"
def definitions(v):
 if isinstance(v,dict):
  if isinstance(v.get('definition'),str):yield v['definition']
  for x in v.values():yield from definitions(x)
 elif isinstance(v,list):
  for x in v:yield from definitions(x)
def guard(rows,expected):
 checks=[]
 for f in rows:
  identity='public.'+f['proname']+('('+('jsonb' if f['proname']=='combat_panel_commit_v1' else 'text,text,integer,uuid,jsonb')+')')
  pin=expected if f['proname']=='combat_panel_commit_v1' else f['definition_md5']
  checks.append(f"o:=to_regprocedure({lit(identity)}); IF o IS NULL THEN RAISE EXCEPTION 'panel_message_function_missing:%',{lit(identity)}; END IF;\nIF md5(pg_get_functiondef(o)) IS DISTINCT FROM {lit(pin)} OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p WHERE p.oid=o AND pg_get_userbyid(p.proowner)={lit(f['owner_name'])} AND p.proacl::text IS NOT DISTINCT FROM {lit(f['acl'])} AND p.prosecdef={str(f['security_definer']).lower()} AND p.provolatile={lit(f['volatility'])} AND p.proconfig IS NOT DISTINCT FROM ARRAY['search_path=\"\"']::text[]) THEN RAISE EXCEPTION 'panel_message_function_drift:%',{lit(identity)}; END IF;")
 return 'DO $guard$ DECLARE o oid; BEGIN\n'+'\n'.join(checks)+'\nEND $guard$;\n'
def main():
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True);p.add_argument('--package',type=Path,default=Path(__file__).resolve().parent);p.add_argument('--output',type=Path,required=True);a=p.parse_args();raw=(a.package/'BASELINE.json').read_bytes();b=json.loads(raw)
 source_bodies=[]
 for name,pin in b['source_inputs'].items():
  v=(a.root/name).read_bytes()
  if sha(v)!=pin['sha256'] or len(v)!=pin['bytes']:raise RuntimeError('Source drift:'+name)
  source_bodies.extend(definitions(json.loads(v)))
 for name,pin in b['package_sources'].items():
  v=(a.package/name).read_bytes()
  if sha(v)!=pin['sha256'] or len(v)!=pin['bytes']:raise RuntimeError('Package drift:'+name)
 for f in b['functions']:
  if hashlib.md5(f['definition'].encode()).hexdigest()!=f['definition_md5']:raise RuntimeError('Metadata body drift')
 target=next(f for f in b['functions'] if f['proname']=='combat_panel_commit_v1');before=target['definition'];anchor="   WHEN 'selection_rejected' THEN 'Le scelte non sono più valide. Rileggi le opzioni.'";causes=[r['cause'] for r in b['mapping']]
 if len(set(causes))!=len(causes) or before.count(anchor)!=1:raise RuntimeError('Mapping/source anchor drift')
 lines=[]
 for row in b['mapping']:
  if not any("RAISE EXCEPTION '"+row['cause']+"'" in s or "raise exception '"+row['cause']+"'" in s for s in source_bodies):raise RuntimeError('Cause without authentic source:'+row['cause'])
  if not re.fullmatch(r'[a-z_]+',row['cause']) or re.search(r'SQLSTATE|SQLERRM|[0-9a-f]{8}-[0-9a-f-]{27,}|https?://',row['message'],re.I):raise RuntimeError('Public message not safe literal')
  lines.append('     WHEN '+lit(row['cause'])+' THEN '+lit(row['message']))
 replacement="   WHEN 'selection_rejected' THEN CASE SQLERRM\n"+'\n'.join(lines)+"\n     ELSE 'Le scelte non sono più valide. Rileggi le opzioni.' END"
 after=before.replace(anchor,replacement)
 if after.replace(replacement,anchor)!=before:raise RuntimeError('Delta outside message assignment')
 aftermd5=hashlib.md5(after.encode()).hexdigest()
 def migration(beforepin,body,afterpin,kind):
  return ('-- '+b['task_id']+' '+kind+'; candidate only, no game data operations.\nBEGIN;\nSET LOCAL search_path=pg_catalog,public;\nSET LOCAL lock_timeout=\'5s\';\nSET LOCAL statement_timeout=\'120s\';\nSELECT pg_advisory_xact_lock(hashtextextended(\'public.combat_panel_commit_v1:message-release\',731));\n'+guard(b['functions'],beforepin)+'-- CREATE OR REPLACE retains the existing owner and ACL; no GRANT/REVOKE/ALTER.\n'+body.rstrip().rstrip(';')+';\n'+guard(b['functions'],afterpin)+'COMMIT;\n')
 install=migration(target['definition_md5'],after,aftermd5,'INSTALL');recovery=migration(aftermd5,before,target['definition_md5'],'RECOVERY')
 for sql in [install,recovery]:
  if len(re.findall(r'^BEGIN;\s*$',sql,re.M))!=1 or len(re.findall(r'^COMMIT;\s*$',sql,re.M))!=1 or len(re.findall(r'^CREATE OR REPLACE FUNCTION ',sql,re.M))!=1:raise RuntimeError('Migration boundary drift')
 outputs={'BASELINE.json':raw,'INSTALL.sql':install.encode(),'RECOVERY.sql':recovery.encode()}
 for name in b['package_sources']:outputs[name]=(a.package/name).read_bytes()
 manifest={'task_id':b['task_id'],'state':'FROZEN_CANDIDATE_PENDING_REVIEW_AND_QA','files':{n:{'bytes':len(v),'sha256':sha(v)} for n,v in sorted(outputs.items())},'source_inputs':b['source_inputs'],'metadata':{'queries':1,'functions':2,'gateway_before_md5':target['definition_md5'],'gateway_after_md5':aftermd5,'gateway_before_sha256':sha(before),'gateway_after_sha256':sha(after),'fail_md5':next(f['definition_md5'] for f in b['functions'] if f['proname']=='combat_v2_fail')},'delta':{'changed_functions':1,'new_functions':0,'new_tables':0,'new_API_fields':0,'ACL_changes':0,'only_assignment':'message for code=selection_rejected','finite_causes':len(causes),'outside_replacement':'byteidentical','unknown_fallback':'unchanged','PGRST':'unchanged, no JSON parse','rollback_dispatch_code_status_request_key_recovery':'unchanged'},'construction_checks':{'authentic_cause_sources':'PASS','one_transaction_one_function_each':'PASS','inverse_delta':'PASS','deterministic_build':'verify two outputs outside generator'},'QA':{'budget':b['QA_budget'],'runs':0,'status':'NOT_RUN'},'limitations':['Not an explanation of the actual011 cause','No fullRPC/Auth/gameplay/browser/provider qualification','Advisory release lock is cooperative; independent concurrent DDL must be excluded by owner/gate','Recovery changes only the same function and refuses AFTER/dependency drift'],'self_hash_excluded':True}
 outputs['MANIFEST.json']=(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n').encode();a.output.mkdir(parents=True,exist_ok=False)
 for n,v in outputs.items():(a.output/n).write_bytes(v)
 print(json.dumps({'files':len(outputs),'after_md5':aftermd5,'manifest_sha256':sha(outputs['MANIFEST.json']),'SQL':0}))
if __name__=='__main__':main()
