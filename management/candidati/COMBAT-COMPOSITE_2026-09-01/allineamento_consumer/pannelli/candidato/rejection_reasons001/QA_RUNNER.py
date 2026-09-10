#!/usr/bin/env python3
"""Single component campaign. No SQL on import; exact environment, new DB, frozen source."""
from pathlib import Path
import argparse,hashlib,json,subprocess,time,re
ROOT=Path('/Users/antonello/Desktop/theuntoldstory')
BASE=Path(__file__).resolve().parent
DOCKER=['/Applications/Docker.app/Contents/Resources/bin/docker','--host','unix:///Users/antonello/.docker/run/docker.sock']
ID='8681f0364c9f27bd5c856d2cc0f20690c8bc2f8d4aaf36de3394241b1596c019'
DB='combat_panel_rejection_reasons_001'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 a=argparse.ArgumentParser();a.add_argument('--authorized-once',action='store_true');a.add_argument('--output',type=Path,required=True);args=a.parse_args()
 if not args.authorized_once or args.output.exists():raise SystemExit('Explicit one-run gate and fresh result required')
 start=time.monotonic();deadline=start+600;result={'task_id':'COMBAT-PANEL-REJECTION-REASONS-QA-001','status':'NOT_RUN','database':DB,'sql_submissions':0,'max_sql_submissions':9,'runs':1,'groups_max':4,'subcases_max':9,'provider_calls':0,'tokens':0,'phases':[],'limits':['Complete real PostgreSQL gateway/validator/fail and native supporting access/routing bodies, but nominal local auth identity; no Supabase Auth/RLS/API verification','commit_ordinary is explicitly synthetic, no game logic/geometric validity/Assalto011 cause certified','Full native bootstrap retained with no historical migration rows or RNG/characters; no existing DB mutated']}
 def command(args,stdin=None,timeout=30):
  remaining=deadline-time.monotonic()
  if remaining<20:raise RuntimeError('Deadline exhausted')
  return subprocess.run(DOCKER+args,input=stdin,text=True,capture_output=True,timeout=min(timeout,remaining-5))
 def sql(name,db,body,user='postgres'):
  remain=deadline-time.monotonic()
  if result['sql_submissions']>=9 or remain<25:raise RuntimeError('SQL/time budget exhausted')
  ms=int(min(120000,(remain-20)*1000));t=time.monotonic();rec={'phase':name,'database':db,'user':user,'SQL_sha256':hashlib.sha256(body.encode()).hexdigest()};result['sql_submissions']+=1
  try:
   r=command(['exec','-i','-e',f'PGOPTIONS=-c statement_timeout={ms} -c transaction_timeout={ms+2000} -c lock_timeout=3000',ID,'psql','-X','-qAt','-v','ON_ERROR_STOP=1','-U',user,'-d',db],body,(ms+7000)/1000)
   rec.update(status='PASS' if r.returncode==0 else 'FAIL',exit_code=r.returncode,stdout=r.stdout[-30000:],stderr=r.stderr[-4000:])
  except subprocess.TimeoutExpired:rec.update(status='TIMEOUT',note='Server timeouts remain active; shared container never stopped or reset, no retry')
  rec['seconds']=round(time.monotonic()-t,3);result['phases'].append(rec);return rec['status']=='PASS'
 def predicate_record(label,pin):
  return "SELECT qa_rejection.record_case('G1_full_install','G1',md5(pg_get_functiondef('public.combat_panel_commit_v1(jsonb)'::regprocedure))='"+pin+"',jsonb_build_object('full_INSTALL_COMMIT',true,'after_md5',md5(pg_get_functiondef('public.combat_panel_commit_v1(jsonb)'::regprocedure)))); SELECT to_jsonb(r) FROM qa_rejection.results r WHERE case_id='G1_full_install';"
 try:
  freeze=json.loads((BASE/'QA_MANIFEST.json').read_text())
  for n,pin in freeze['frozen_inputs'].items():
   path=ROOT/n
   if digest(path)!=pin['sha256'] or path.stat().st_size!=pin['bytes']:raise RuntimeError('Frozen source drift: '+n)
  for n,pin in freeze['frozen_QA'].items():
   path=BASE/n
   if digest(path)!=pin['sha256'] or path.stat().st_size!=pin['bytes']:raise RuntimeError('Frozen QA drift: '+n)
  expected=json.loads((BASE/'QA_ENVIRONMENT.json').read_text())['expected']
  r=command(['inspect','--format','{{json .Id}}|{{json .Name}}|{{json .Config.Image}}|{{json .Image}}|{{json .HostConfig.NetworkMode}}|{{json .HostConfig.PortBindings}}|{{json .Mounts}}|{{json .State.Running}}',ID])
  if r.returncode:raise RuntimeError('Selected metadata inspection unavailable')
  vals=[json.loads(x) for x in r.stdout.strip().split('|')]
  if len(vals)!=8:raise RuntimeError('Environment metadata shape mismatch')
  actual=dict(zip(['full_id','name','image_reference','image_id','network','port_bindings','mounts','running'],vals));actual['mounts']=sorted(actual['mounts'],key=lambda x:x['Destination'])
  if actual!=expected:raise RuntimeError('Exact QA container configuration mismatch')
  result['environment']='EXACT_MATCH';result['environment_sha256']=digest(BASE/'QA_ENVIRONMENT.json')
  phases=json.loads((BASE/'QA_SOURCE_MANIFEST.json').read_text())['phase_SQL']
  # Every psql invocation counts once; phase1 includes both absence checks and CREATE via psql gexec.
  if not sql('01_preflight_and_CREATE', 'postgres',phases['01'], 'supabase_admin'):raise RuntimeError('Preflight/create failed; no reuse/reset/retry')
  if not sql('02_native_setup',DB,(BASE/'QA_SETUP.sql').read_text(),'supabase_admin'):raise RuntimeError('Native setup failed; remaining component NOT_RUN; preserved DB, no repair')
  installed=sql('03_INSTALL_COMMIT',DB,(BASE/'INSTALL.sql').read_text()+phases['03'])
  if not installed:raise RuntimeError('INSTALL failed; no runtime cases or recovery of unqualified state')
  sections=re.split(r'^-- PHASE ([A-Z0-9_]+)\n',(BASE/'QA_CASES.sql').read_text(),flags=re.M);cases=dict(zip(sections[1::2],sections[2::2]))
  sql('04_G2',DB,cases['G2']);sql('05_G3',DB,cases['G3']);sql('06_G4_success_replay',DB,cases['G4_SUCCESS'])
  saved=sql('07_before_recovery',DB,phases['07'])
  if saved:sql('08_RECOVERY_COMMIT',DB,(BASE/'RECOVERY.sql').read_text())
  post=sql('09_postflight',DB,phases['09']+cases['POST'])
  if post:
   try:result['matrix']=json.loads(result['phases'][-1]['stdout'].strip().splitlines()[-1])
   except (ValueError,IndexError):result['matrix']={'all_pass':False,'parse_limit':True}
  result['status']='COMPONENT_PASS' if result.get('matrix',{}).get('all_pass') and result['sql_submissions']==9 and all(p['status']=='PASS' for p in result['phases']) else 'NOT_QUALIFIED'
 except Exception as e:result['status']='NOT_QUALIFIED';result['limit']=str(e)
 finally:
  result['elapsed_seconds']=round(time.monotonic()-start,3);result['container_and_database_preserved']=True;result['retries']=0;args.output.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'status':result['status'],'sql_submissions':result['sql_submissions'],'provider_calls':0,'output':str(args.output)}))
if __name__=='__main__':main()
