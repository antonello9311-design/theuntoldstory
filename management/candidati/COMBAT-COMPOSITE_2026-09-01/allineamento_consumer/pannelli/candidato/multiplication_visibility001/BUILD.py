#!/usr/bin/env python3
"""Offline reproducible one-predicate candidate; no SQL execution or connection."""
from pathlib import Path
import argparse,hashlib,json,re

def sha(v):return hashlib.sha256(v).hexdigest()
def md5(v):return hashlib.md5(v.encode()).hexdigest()
def literal(v):return "'"+v.replace("'","''")+"'"
def guard(functions,pins):
 out=[]
 for f in functions:
  out.append("o:=to_regprocedure("+literal(f['identity'])+"); IF o IS NULL THEN RAISE EXCEPTION 'multiplication_visibility_missing:%',"+literal(f['identity'])+"; END IF;\nIF md5(pg_get_functiondef(o)) IS DISTINCT FROM "+literal(pins[f['proname']])+" OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p WHERE p.oid=o AND pg_get_userbyid(p.proowner)="+literal(f['owner_name'])+" AND p.proacl::text IS NOT DISTINCT FROM "+literal(f['acl'])+" AND p.prosecdef="+str(f['security_definer']).lower()+" AND p.provolatile="+literal(f['volatility'])+" AND p.proconfig IS NOT DISTINCT FROM ARRAY['search_path=\"\"']::text[]) THEN RAISE EXCEPTION 'multiplication_visibility_drift:%',"+literal(f['identity'])+"; END IF;")
 return 'DO $pin$ DECLARE o oid; BEGIN\n'+'\n'.join(out)+'\nEND $pin$;\n'
def main():
 a=argparse.ArgumentParser();a.add_argument('--root',type=Path,required=True);a.add_argument('--package',type=Path,default=Path(__file__).resolve().parent);a.add_argument('--output',type=Path,required=True);args=a.parse_args();b=json.loads((args.package/'BASELINE.json').read_text())
 for rel,pin in b['source_inputs'].items():
  v=(args.root/rel).read_bytes()
  if len(v)!=pin['bytes'] or sha(v)!=pin['sha256']:raise RuntimeError('source drift:'+rel)
 for name,pin in b['package_sources'].items():
  v=(args.package/name).read_bytes()
  if len(v)!=pin['bytes'] or sha(v)!=pin['sha256']:raise RuntimeError('package drift:'+name)
 for f in b['functions']:
  if md5(f['definition'])!=f['definition_md5'] or sha(f['definition'].encode())!=f['definition_sha256']:raise RuntimeError('native function pin mismatch')
 target=next(f for f in b['functions'] if f['proname']=='multiplication_prepare_declaration');before=target['definition'];anchor=b['replacement']['before'];replacement=b['replacement']['after']
 if before.count(anchor)!=1:raise RuntimeError('unique native predicate missing')
 after=before.replace(anchor,replacement)
 if after.replace(replacement,anchor)!=before:raise RuntimeError('noninverse predicate delta')
 if after.count('combat_panel_private.body_visible_to_viewer(i.instance_id,p_target) IS DISTINCT FROM true')!=1:raise RuntimeError('native signature/failclosed drift')
 beforepins={f['proname']:f['definition_md5'] for f in b['functions']};afterpins={**beforepins,target['proname']:md5(after)}
 def migration(kind,pre,body,post):
  return '-- '+b['task_id']+' '+kind+'; candidate only. No game-data operations.\nBEGIN;\nSET LOCAL search_path=pg_catalog,public;\nSET LOCAL lock_timeout=\'5s\';\nSET LOCAL statement_timeout=\'120s\';\nSELECT pg_advisory_xact_lock(hashtextextended(\'combat_panel_private.multiplication_prepare_declaration:visibility-release\',731));\n'+guard(b['functions'],pre)+'-- Existing signature/owner/ACL retained by CREATE OR REPLACE and verified after.\n'+body.rstrip().rstrip(';')+';\n'+guard(b['functions'],post)+'COMMIT;\n'
 install=migration('INSTALL',beforepins,after,afterpins);recovery=migration('RECOVERY',afterpins,before,beforepins)
 for sql in [install,recovery]:
  if len(re.findall(r'^CREATE OR REPLACE FUNCTION ',sql,re.M))!=1 or len(re.findall(r'^BEGIN;$',sql,re.M))!=1 or len(re.findall(r'^COMMIT;$',sql,re.M))!=1:raise RuntimeError('transaction/function count drift')
 outputs={'BASELINE.json':(args.package/'BASELINE.json').read_bytes(),'INSTALL.sql':install.encode(),'RECOVERY.sql':recovery.encode(),**{n:(args.package/n).read_bytes() for n in b['package_sources']}}
 manifest={'task_id':b['task_id'],'state':'CANDIDATE_FROZEN_PENDING_REVIEW_AND_NATIVE_QA','files':{n:{'bytes':len(v),'sha256':sha(v)} for n,v in sorted(outputs.items())},'source_inputs':b['source_inputs'],'pins':{'before':beforepins,'after':afterpins},'changed_body_sha256':sha(after.encode()),'delta':{'changed_functions':1,'new_functions':0,'new_tables':0,'new_grants':0,'changed_API_fields':0,'changed_game_numbers':0,'only_change':'native visibility authority replaces direct enemy grant, failclosed','outside_predicate':'byteidentical','helper_visibility_body':'unchanged dependency'},'construction_checks':{'source_pins':True,'one_predicate_inverse':True,'transaction_counts':True},'QA':{'status':'NOT_RUN','budget':b['QA_budget'],'native_fixture_preparation_required':True,'gaps':b['QA_prerequisites']},'live_changes':0,'query_calls':0,'provider_calls':0,'review_budget':{'initial_independent':1,'aggregate_max_authorized':5,'countercheck_max_authorized':5,'stop_at_green':True,'no_new_examples_after_review':True},'self_hash_excluded':True}
 outputs['MANIFEST.json']=(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n').encode();args.output.mkdir(exist_ok=False,parents=True)
 for n,v in outputs.items():(args.output/n).write_bytes(v)
 print(json.dumps({'files':len(outputs),'after_md5':md5(after),'manifest_sha256':sha(outputs['MANIFEST.json']),'SQL':0}))
if __name__=='__main__':main()
