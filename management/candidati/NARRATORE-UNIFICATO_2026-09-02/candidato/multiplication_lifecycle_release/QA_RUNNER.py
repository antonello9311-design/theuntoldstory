#!/usr/bin/env python3
"""Frozen component QA. ROOT only, after review and exclusive guard resource claim.
No SQL executes on import. Whole product INSTALL/RECOVERY wrappers are NOT_RUN.
"""
import argparse,hashlib,json,re,subprocess,time
from pathlib import Path
BASE=Path(__file__).resolve().parent
DOCKER=['/Applications/Docker.app/Contents/Resources/bin/docker','--host','unix:///Users/antonello/.docker/run/docker.sock']
CONTAINER='tus_ordinary_compose_qa_db'
EXPECTED_ID='8681f0364c9f27bd5c856d2cc0f20690c8bc2f8d4aaf36de3394241b1596c019'
DATABASE='narrative_multiplication_lifecycle_001'
TARGET='combat_consumer_private.narrative_tech_sources_v1(uuid)'
HOOK='combat_consumer_private.scene_snapshot_v2(uuid)'
PINS={'PLAN.md': 'c88756025d73ada21272ba3631c0a2e23fc98eec6e30e8e0746daec255e71a10', 'CONTRACT.md': '5536a80fd48392cdbe69e212aeb9acb00850fb18fa7d92654b8521da80193ee9', 'BASELINE.json': 'bf04df3fb27536a4cded47d875485b3812d6518ce60e9ee48fc95899b699736d', 'BUILD.py': '71f4ddc39a2805b38136b6f559e8e5ad67728cffd6142e4ed514be6e7bce4eaf', 'INSTALL.sql': '17be81bcd3bef9c85a24abc17f10010fa1ae12e06564fdcbc46f56f66810a3be', 'RECOVERY.sql': '0ba547687368e0dae01f782653a0d1d855217ecd8bd5b5002ea0aa527eefdbe1', 'QA_PLAN.md': '902920cce6b871ff7db2af97953e3045ca7533039676e417aa7ca8692b98f0ed', 'MANIFEST.json': 'fb173196bec2a9cbfa090bc709987b356a160dbd10d13c7b3b5b92436101bc9e', 'QA_SETUP.sql': '4321f741b78d0e6d8b2f101e60147d7a58350e95a1b3bac874c470f8a6b88643', 'QA_CASES.sql': '72a7cfbb167e14334b7c526d32c4167e89ab6f0f6850b10b0d286605ffceb393', 'QA_ENVIRONMENT.json': '883a7d319a08a975034b5159896e45be8486baf36ff8b83e0ffa1262c64ed16c'}

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def lit(s):return "'"+s.replace("'","''")+"'"
def function_sql(s):return s.rstrip()+';\n'
def check_pin(identity,md5):
 return "SELECT public.qa_assert(EXISTS(SELECT 1 FROM pg_proc p WHERE p.oid="+lit(identity)+"::regprocedure AND md5(pg_get_functiondef(p.oid))="+lit(md5)+" AND pg_get_userbyid(p.proowner)='postgres' AND p.proacl='{postgres=X/postgres}'::aclitem[]),'body/owner/ACL pin');\n"
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--authorized-once',action='store_true');ap.add_argument('--expected-container-id',required=True);ap.add_argument('--output',type=Path,required=True);args=ap.parse_args()
 if not args.authorized_once or args.expected_container_id!=EXPECTED_ID:raise SystemExit('Explicit ROOT gate/full container ID required')
 if args.output.exists():raise SystemExit('Output already exists: no overwrite/retry')
 started=time.monotonic();deadline=started+600
 result={'schema_version':'multiplication-lifecycle-component-qa/1','status':'NOT_RUN','sql_submissions':0,'max_sql_submissions':8,'provider_calls':0,'http_attempts':0,'tokens':0,'fixture':'synthetic projection; no native resolution, Auth, RLS or Edge qualification','complete_INSTALL_wrapper':'NOT_RUN','complete_RECOVERY_wrapper':'NOT_RUN','release_gate':'BLOCKED_PENDING_FULL_WRAPPER_QA','phases':[],'files':{},'database':DATABASE,'container':CONTAINER}
 def cmd(arguments,stdin=None,timeout=30):
  remaining=deadline-time.monotonic()
  if remaining<20:raise RuntimeError('global time budget exhausted')
  return subprocess.run(DOCKER+arguments,input=stdin,text=True,capture_output=True,timeout=min(timeout,remaining-5))
 def sql(phase,database,text):
  if result['sql_submissions']>=8:raise RuntimeError('SQL budget exhausted')
  remaining=deadline-time.monotonic()
  if remaining<25:raise RuntimeError('insufficient bounded server execution time')
  stmt_ms=int(min(80000,(remaining-20)*1000));tx_ms=stmt_ms+2000
  result['sql_submissions']+=1
  rec={'phase':phase,'sql_sha256':hashlib.sha256(text.encode()).hexdigest(),'database':database}
  start=time.monotonic()
  try:
   response=cmd(['exec','-i','-e',f'PGOPTIONS=-c statement_timeout={stmt_ms} -c transaction_timeout={tx_ms} -c lock_timeout=3000',EXPECTED_ID,'psql','-X','-qAt','-v','ON_ERROR_STOP=1','-U','postgres','-d',database],text,tx_ms/1000+5)
   rec.update({'exit_code':response.returncode,'status':'PASS' if response.returncode==0 else 'FAIL','stdout':response.stdout[-16000:],'stderr':response.stderr[-4000:]})
  except subprocess.TimeoutExpired:
   rec.update({'status':'TIMEOUT','note':'Server statement/transaction timeout was bounded; shared container never stopped. No retry.'})
  rec['elapsed_seconds']=round(time.monotonic()-start,3);result['phases'].append(rec)
  return rec
 try:
  for name,expected in PINS.items():
   actual=sha(BASE/name);result['files'][name]=actual
   if actual!=expected:raise RuntimeError('frozen input drift: '+name)
  # Selected non-secret fields only. No Env, no broad inspect, no container mutation.
  response=cmd(['inspect','--format','{{json .Id}}|{{json .Name}}|{{json .Config.Image}}|{{json .Image}}|{{json .HostConfig.NetworkMode}}|{{json .HostConfig.PortBindings}}|{{json .Mounts}}|{{json .State.Running}}',EXPECTED_ID])
  if response.returncode:raise RuntimeError('container inspection unavailable')
  fields=[json.loads(x) for x in response.stdout.strip().split('|')]
  if len(fields)!=8:raise RuntimeError('container metadata shape mismatch')
  observed=dict(zip(['full_id','name','image_reference','image_id','network','port_bindings','mounts','running'],fields))
  if not isinstance(observed['mounts'],list):raise RuntimeError('mount metadata shape mismatch')
  observed['mounts']=sorted(observed['mounts'],key=lambda m:m['Destination'])
  expected=json.loads((BASE/'QA_ENVIRONMENT.json').read_text())['expected']
  if observed!=expected:raise RuntimeError('exact assigned QA configuration drift; preserve container, no changes permitted')
  if observed['port_bindings']!={'5432/tcp':[{'HostIp':'127.0.0.1','HostPort':'54322'}]}:raise RuntimeError('only pinned loopback binding allowed')
  result['isolation']={'configuration':'EXACT_MATCH_ASSIGNED_LOCAL_QA','environment_sha256':sha(BASE/'QA_ENVIRONMENT.json'),'full_id':observed['full_id'],'name':observed['name'],'image':observed['image_reference'],'image_id':observed['image_id'],'network':observed['network'],'port_bindings':observed['port_bindings'],'mount_count':len(observed['mounts']),'running':observed['running']}
  b=json.loads((BASE/'BASELINE.json').read_text());before=b['functions'][0]['definition'];after=b['candidate']['after_definition'];hook_md5=b['functions'][1]['md5']
  sections=re.split(r'^-- SECTION (G[234])\n',(BASE/'QA_CASES.sql').read_text(),flags=re.M);cases=dict(zip(sections[1::2],sections[2::2]));setup=(BASE/'QA_SETUP.sql').read_text()
  preflight="""DO $$ BEGIN
IF current_user<>'postgres' OR current_setting('server_version_num')::int NOT BETWEEN 170006 AND 170006 THEN RAISE EXCEPTION 'expected postgres / PostgreSQL17.6'; END IF;
IF EXISTS(SELECT 1 FROM pg_database WHERE datname='narrative_multiplication_lifecycle_001') THEN RAISE EXCEPTION 'database already exists; no reuse/reset'; END IF;
IF (SELECT count(*) FROM pg_roles WHERE rolname IN ('postgres','anon','authenticated','service_role'))<>4 THEN RAISE EXCEPTION 'required nominal roles absent; no role mutations allowed'; END IF;
END $$; SELECT jsonb_build_object('server_version',current_setting('server_version'),'new_database_absent',true,'nominal_roles_present',true);"""
  if sql('01_preflight','postgres',preflight)['status']!='PASS':raise RuntimeError('preflight failed')
  if sql('02_create_new_database','postgres','CREATE DATABASE '+DATABASE+' TEMPLATE template0;')['status']!='PASS':raise RuntimeError('new database creation failed')
  if sql('03_setup_BEFORE_commit',DATABASE,setup)['status']!='PASS':raise RuntimeError('setup failed; all dependent groups NOT_RUN, no retry')
  install='BEGIN; SET LOCAL check_function_bodies=on;\n'+check_pin(TARGET,b['candidate']['before_md5'])+check_pin(HOOK,hook_md5)+function_sql(after)+check_pin(TARGET,b['candidate']['after_md5'])+check_pin(HOOK,hook_md5)+"INSERT INTO qa_results VALUES('G1','PASS','{\"scope\":\"exact body, hook, owner and ACL; whole wrapper NOT_RUN\"}'); COMMIT;"
  installed=sql('04_component_AFTER_commit_G1',DATABASE,install)['status']=='PASS'
  if installed:
   sql('05_projection_G2',DATABASE,cases['G2'])
   sql('06_known_invariants_G3',DATABASE,cases['G3'])
   # Independent history use guard test subtransactions roll back synthetic rows.
   # Actual component BEFORE restore COMMIT is its own explicit transaction.
   unused=next(n.value.value for n in __import__('ast').parse((BASE/'BUILD.py').read_text()).body if isinstance(n,__import__('ast').Assign) and any(isinstance(t,__import__('ast').Name) and t.id=='UNUSED' for t in n.targets))
   recovery=cases['G4']+"\nBEGIN; SELECT public.qa_assert(EXISTS(SELECT 1 FROM qa_results WHERE group_id='G4_guard' AND result='PASS'),'history guard component qualified');\n"+check_pin(TARGET,b['candidate']['after_md5'])+"SELECT set_config('tus.multiplication_lifecycle_recovery','Antonello:NARRATIVE-MULTIPLICATION-LIFECYCLE-CANDIDATE-001:before-use',true); DO $recovery$ BEGIN\n"+unused+"END $recovery$;\n"+function_sql(before)+check_pin(TARGET,b['candidate']['before_md5'])+check_pin(HOOK,hook_md5)+"COMMIT;"
   sql('07_history_guard_and_component_recovery_commit',DATABASE,recovery)
  post=check_pin(TARGET,b['candidate']['before_md5'])+check_pin(HOOK,hook_md5)+"""
SELECT public.qa_assert(public.qa_data_digest()=(SELECT data_sha FROM qa_before),'all fixture rows unchanged');
SELECT public.qa_assert(combat_consumer_private.scene_snapshot_v2('00000000-0000-0000-0000-000000000040')=(SELECT snapshot FROM qa_before),'BEFORE snapshot restored');
INSERT INTO qa_results VALUES('G4','PASS','{"scope":"component BEFORE recovery COMMIT and data/history/hash comparison; whole wrapper NOT_RUN"}');
SELECT jsonb_build_object('groups',(SELECT jsonb_agg(to_jsonb(q) ORDER BY group_id) FROM qa_results q),'data_sha',public.qa_data_digest(),'restored_before',true,'all_four_pass',(SELECT count(*)=4 AND bool_and(result='PASS') FROM qa_results WHERE group_id IN ('G1','G2','G3','G4')));
"""
  p=sql('08_postflight_separate_connection',DATABASE,post)
  if p['status']=='PASS':
   final=json.loads(p['stdout'].strip().splitlines()[-1]);result['summary']=final
   result['status']='COMPONENT_PASS' if final['all_four_pass'] and all(x['status']=='PASS' for x in result['phases']) else 'COMPONENT_FAIL'
  else:result['status']='COMPONENT_FAIL'
 except Exception as e:
  result['status']='NOT_QUALIFIED';result['limit']=str(e)
 finally:
  result['elapsed_seconds']=round(time.monotonic()-started,3);result['container_preserved']=True;result['no_retries']=True
  args.output.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'status':result['status'],'sql_submissions':result['sql_submissions'],'provider_calls':0,'output':str(args.output)},ensure_ascii=False))
if __name__=='__main__':main()
