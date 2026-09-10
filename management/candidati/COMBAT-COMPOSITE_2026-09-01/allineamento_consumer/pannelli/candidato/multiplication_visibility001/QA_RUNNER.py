#!/usr/bin/env python3
"""Preparazione sola lettura all'import. Una futura campagna nativa, solo con gate PM espliciti."""
from pathlib import Path
import argparse,hashlib,json,subprocess,time
ROOT=Path('/Users/antonello/Desktop/theuntoldstory')
BASE=Path(__file__).resolve().parent
DB='combat_multiplication_visibility_002'
CONTAINER='8681f0364c9f27bd5c856d2cc0f20690c8bc2f8d4aaf36de3394241b1596c019'
DOCKER=['/Applications/Docker.app/Contents/Resources/bin/docker','--host','unix:///Users/antonello/.docker/run/docker.sock']
ENV_REL='management/candidati/COMBAT-COMPOSITE_2026-09-01/allineamento_consumer/pannelli/candidato/rejection_reasons001/QA_ENVIRONMENT.json'
PREFLIGHT="""DO $guard$ BEGIN
IF EXISTS(SELECT 1 FROM pg_database WHERE datname='combat_multiplication_visibility_002') THEN RAISE EXCEPTION 'qa_database_already_exists_no_reuse';END IF;
IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname=current_user AND rolsuper) OR current_setting('server_version_num')::integer NOT BETWEEN 170006 AND 170006 THEN RAISE EXCEPTION 'qa_version_or_owner';END IF;
IF EXISTS(SELECT role_name FROM unnest(ARRAY['anon','authenticated','dashboard_user','pg_database_owner','postgres','service_role','supabase_admin','supabase_auth_admin']) role_name WHERE NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname=role_name)) THEN RAISE EXCEPTION 'qa_native_role_missing';END IF;
END $guard$;
SELECT 'CREATE DATABASE combat_multiplication_visibility_002 OWNER postgres TEMPLATE template0'\n\\gexec
"""
SESSION="""BEGIN;
SELECT set_config('request.jwt.claim.sub',(SELECT principal::text FROM qa_visibility.context),true);
SELECT set_config('request.jwt.claim.role','authenticated',true);
"""
DECL="""DECLARE c qa_visibility.context%ROWTYPE; figs jsonb; prof jsonb; visible boolean; ready text; code text; msg text; ok boolean:=false; before_count integer; detail jsonb; fp text;
BEGIN
SELECT * INTO STRICT c FROM qa_visibility.context;
figs:=combat_panel_private.multiplication_line_figures(10,9,1,0,1,1);
"""
CALL="""PERFORM combat_panel_private.multiplication_prepare_declaration(c.round_id,c.actor_id,'assalto',1,figs,2,c.target_id,NULL,'70000000-0000-4000-8000-000000000001');"""
G1=SESSION+"DO $case$\n"+DECL+"""
BEGIN
prof:=combat_panel_private.multiplication_actor_profile(c.actor_id);
visible:=combat_panel_private.body_visible_to_viewer(c.instance_id,c.target_id);
ready:=combat_consumer_private.state_projection('30000000-0000-4000-8000-000000000001')->>'status';
IF prof->>'available' IS DISTINCT FROM 'true' OR visible IS DISTINCT FROM true OR ready IS DISTINCT FROM 'ready'
 OR EXISTS(SELECT 1 FROM combat_spatial.viewer_grants WHERE instance_id=c.instance_id AND viewer_principal_id=c.principal AND subject_actor_id=c.target_id AND can_view_map)
 THEN RAISE EXCEPTION 'qa_G1_prerequisite_not_ready';END IF;
"""+CALL+"""
fp:=public.combat_v2_sha256(jsonb_build_object('round',c.round_id,'actor',c.actor_id,'mode','assalto','copies',1,'figures',figs,'original',2,'target',c.target_id,'movement',NULL));
ok:=EXISTS(SELECT 1 FROM combat_panel_private.multiplication_declaration_plans WHERE request_key='70000000-0000-4000-8000-000000000001' AND actor_id=c.actor_id AND round_id=c.round_id AND principal_user=c.principal AND fingerprint=fp AND prepared_transaction=txid_current() AND declaration_id IS NULL AND movement_event_id IS NULL AND movement_m=0 AND chakra_cost=15 AND figures=figs AND original_index=2)
 AND (SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM public.characters x)=c.character_before
 AND (SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM public.combat_v2_actors x)=c.actor_before;
EXCEPTION WHEN OTHERS THEN GET STACKED DIAGNOSTICS code=RETURNED_SQLSTATE,msg=MESSAGE_TEXT;ok:=false;
END;
INSERT INTO qa_visibility.results VALUES('G1',coalesce(ok,false),jsonb_build_object('profile_available',prof->'available','visible',visible,'projection_status',ready,'sqlstate',code,'diagnostic',msg,'subject','native complete prepare; persisted plan is not resolved attack'));
END $case$;
COMMIT;
SELECT to_jsonb(r) FROM qa_visibility.results r WHERE case_id='G1';
"""
# Both negative cases roll back only their synthetic fixture changes through an exception
# block. The native caught error must be exactly the contact rejection, not a prerequisite.
def negative(case_id,fixture,expected_visible):
 call=CALL.replace('000000000001','000000000002' if case_id=='G2b' else '000000000003')
 return SESSION+'DO $case$\n'+DECL+"""
SELECT count(*) INTO before_count FROM combat_panel_private.multiplication_declaration_plans;
BEGIN
"""+fixture+"""
prof:=combat_panel_private.multiplication_actor_profile(c.actor_id);
visible:=combat_panel_private.body_visible_to_viewer(c.instance_id,c.target_id);
ready:=combat_consumer_private.state_projection('30000000-0000-4000-8000-000000000001')->>'status';
IF prof->>'available' IS DISTINCT FROM 'true' THEN RAISE EXCEPTION 'qa_negative_failed_before_contact';END IF;
"""+("IF visible IS TRUE OR ready IS DISTINCT FROM 'blocked' THEN RAISE EXCEPTION 'qa_G2b_invalid_fixture';END IF;" if case_id=='G2b' else "IF visible IS DISTINCT FROM true OR ready IS DISTINCT FROM 'ready' OR combat_spatial.distance_m(10,9,15,10)<=2 THEN RAISE EXCEPTION 'qa_G3_invalid_fixture';END IF;")+call+"""
RAISE EXCEPTION 'qa_negative_unexpected_accept';
EXCEPTION WHEN OTHERS THEN
 GET STACKED DIAGNOSTICS code=RETURNED_SQLSTATE,msg=MESSAGE_TEXT;
 ok:=code='22023' AND msg='panel_multiplication_assault_contact_invalid' AND prof->>'available'='true';
END;
ok:=coalesce(ok,false) AND (SELECT count(*) FROM combat_panel_private.multiplication_declaration_plans)=before_count
 AND (SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM public.characters x)=c.character_before
 AND (SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM public.combat_v2_actors x)=c.actor_before;
INSERT INTO qa_visibility.results VALUES('"""+case_id+"""',ok,jsonb_build_object('profile_available',prof->'available','visible',visible,'projection_status',ready,'sqlstate',code,'diagnostic',msg,'fixture_rolled_back',true));
END $case$;
COMMIT;
SELECT to_jsonb(r) FROM qa_visibility.results r WHERE case_id='"""+case_id+"';\n"
G2=negative('G2b',"""INSERT INTO combat_spatial.viewer_grants(instance_id,viewer_principal_id,subject_actor_id,can_view_map,can_view_objects,grant_version) VALUES(c.instance_id,c.principal,c.target_id,true,false,1);
UPDATE combat_consumer_private.runtime_config SET enabled=false WHERE singleton;
""",False)
G3=negative('G3',"UPDATE combat_spatial.actor_states SET x_m=15,y_m=10,body_version=body_version+1 WHERE instance_id=c.instance_id AND actor_id=c.target_id;\n",True)
TABLES=['public.characters','public.combat_v2_actors','public.combat_v2_sessions','public.combat_v2_rounds','combat_consumer_private.activities','combat_consumer_private.members','combat_consumer_private.invitations','combat_consumer_private.open_authorizations','combat_consumer_private.scene_claims','combat_spatial.arena_instances','combat_spatial.actor_states','combat_spatial.viewer_grants','combat_panel_private.multiplication_declaration_plans','combat_panel_private.multiplication_attack_aims']
def table_digest(rel):return "(SELECT coalesce(jsonb_agg(to_jsonb(r) ORDER BY to_jsonb(r)::text),'[]'::jsonb) FROM "+rel+' r)'
SNAPSHOT='BEGIN;\n'+''.join("INSERT INTO qa_visibility.recovery_snapshot VALUES('"+rel+"',"+table_digest(rel)+');\n' for rel in TABLES)+"COMMIT;\n"
def postflight(baseline):
 checks=[]
 for f in baseline['functions']:
  ident=f['identity']; acl=f['acl']; cfg=f['config'];
  checks.append("EXISTS(SELECT 1 FROM pg_proc p WHERE p.oid='"+ident+"'::regprocedure AND md5(pg_get_functiondef(p.oid))='"+f['definition_md5']+"' AND pg_get_userbyid(p.proowner)='"+f['owner_name']+"' AND p.proacl::text IS NOT DISTINCT FROM "+("NULL" if acl is None else "'"+acl.replace("'","''")+"'")+" AND p.prosecdef="+str(f['security_definer']).lower()+" AND to_jsonb(p.proconfig) IS NOT DISTINCT FROM "+("NULL" if cfg is None else "'"+json.dumps(cfg).replace("'","''")+"'::jsonb")+")")
 checks.extend("(SELECT rows_before FROM qa_visibility.recovery_snapshot WHERE relation_name='"+r+"')="+table_digest(r) for r in TABLES)
 checks.append("(SELECT enabled AND NOT provider_enabled FROM combat_consumer_private.runtime_config WHERE singleton)")
 return "INSERT INTO qa_visibility.results VALUES('G4',coalesce("+' AND '.join(checks)+",false),jsonb_build_object('recovery_full_COMMIT',true,'tables_compared',14));\nSELECT jsonb_build_object('all_pass',count(*)=4 AND bool_and(passed),'results',jsonb_agg(to_jsonb(r) ORDER BY case_id)) FROM qa_visibility.results r;"
def phases():
 return {'01':PREFLIGHT,'02':(BASE/'QA_SETUP.sql').read_text(),'03':(BASE/'INSTALL.sql').read_text(),'04':G1,'05':G2,'06':G3,'07':SNAPSHOT+(BASE/'RECOVERY.sql').read_text(),'08':postflight(json.loads((BASE/'BASELINE.json').read_text()))}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 a=argparse.ArgumentParser();a.add_argument('--authorized-once',action='store_true');a.add_argument('--approved-four-case-matrix',action='store_true');a.add_argument('--output',required=True,type=Path);args=a.parse_args()
 if not args.authorized_once or not args.approved_four_case_matrix or args.output.exists():raise SystemExit('Richiesti incarico esecuzione PM, riduzione motivata accettata e output nuovo; nessun riuso.')
 start=time.monotonic();deadline=start+600;r={'status':'NOT_RUN','database':DB,'sql_submissions':0,'max_sql_submissions':8,'provider_calls':0,'tokens':0,'runs':1,'retries':0,'phases':[],'G2a':'NOT_APPLICABLE_CURRENT_PRODUCT_NOT_PASS','limitations':['Nominal local identity is not Supabase Auth/RLS/API','Synthetic PGs and initial positions; native acceptance/snapshot/projection/prepare, no stubs','No attack resolution, Master, future invisibility or TestRoom-user qualification']}
 def command(args,body=None,timeout=30):return subprocess.run(DOCKER+args,input=body,text=True,capture_output=True,timeout=min(timeout,max(1,deadline-time.monotonic()-5)))
 def sql(k,body):
  remaining=deadline-time.monotonic()
  if r['sql_submissions']>=8 or remaining<25:raise RuntimeError('Budget esaurito')
  ms=int(min(120000,(remaining-20)*1000));r['sql_submissions']+=1;t=time.monotonic();rec={'phase':k,'sha256':hashlib.sha256(body.encode()).hexdigest()}
  try:
   p=command(['exec','-i','-e',f'PGOPTIONS=-c statement_timeout={ms} -c transaction_timeout={ms+2000} -c lock_timeout=3000',CONTAINER,'psql','-X','-qAt','-v','ON_ERROR_STOP=1','-U','supabase_admin' if k in ('01','02') else 'postgres','-d','postgres' if k=='01' else DB],body,(ms+7000)/1000)
   rec.update(status='PASS' if p.returncode==0 else 'FAIL',exit_code=p.returncode,stdout=p.stdout[-16000:],stderr=p.stderr[-3000:])
  except subprocess.TimeoutExpired:rec.update(status='TIMEOUT',note='Timeout server attivo; banco condiviso non fermato, nessun retry')
  rec['seconds']=round(time.monotonic()-t,3);r['phases'].append(rec);return rec['status']=='PASS'
 try:
  manifest=json.loads((BASE/'QA_SOURCE_MANIFEST.json').read_text())
  for path,pin in manifest['frozen_inputs'].items():
   if sha(ROOT/path)!=pin['sha256']:raise RuntimeError('Fonte congelata cambiata: '+path)
  for path,pin in manifest['QA_files'].items():
   if sha(BASE/path)!=pin['sha256']:raise RuntimeError('Banco congelato cambiato: '+path)
  ps=phases()
  if {k:hashlib.sha256(v.encode()).hexdigest() for k,v in ps.items()}!=manifest['phase_sha256']:raise RuntimeError('Stringhe SQL diverse dal freeze')
  p=command(['inspect','--format','{{json .Id}}|{{json .Name}}|{{json .Config.Image}}|{{json .Image}}|{{json .HostConfig.NetworkMode}}|{{json .HostConfig.PortBindings}}|{{json .Mounts}}|{{json .State.Running}}',CONTAINER])
  if p.returncode:raise RuntimeError('Ispezione metadata selezionati non disponibile')
  vals=[json.loads(x) for x in p.stdout.strip().split('|')];actual=dict(zip(['full_id','name','image_reference','image_id','network','port_bindings','mounts','running'],vals));actual['mounts']=sorted(actual['mounts'],key=lambda x:x['Destination'])
  if actual!=json.loads((ROOT/ENV_REL).read_text())['expected']:raise RuntimeError('Identità/configurazione banco differente dal pin')
  r['environment']='EXACT_MATCH'
  for k in ('01','02','03'):
   if not sql(k,ps[k]):raise RuntimeError('Prerequisito '+k+' fallito, dipendenti NOT_RUN; nessun reset o repair')
  for k in ('04','05','06'):sql(k,ps[k])
  if not sql('07',ps['07']):raise RuntimeError('Snapshot/recovery non attestati; banco conservato')
  if sql('08',ps['08']):
   try:r['matrix']=json.loads(r['phases'][-1]['stdout'].strip().splitlines()[-1])
   except (ValueError,IndexError):r['matrix']={'all_pass':False,'parse_limit':True}
  r['status']='NATIVE_COMPONENT_PASS' if r.get('matrix',{}).get('all_pass') and r['sql_submissions']==8 and all(x['status']=='PASS' for x in r['phases']) else 'NOT_QUALIFIED'
 except Exception as e:r['status']='NOT_QUALIFIED';r['limit']=str(e)
 finally:
  r['elapsed_seconds']=round(time.monotonic()-start,3);r['database_preserved']=True;args.output.write_text(json.dumps(r,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'status':r['status'],'sql_submissions':r['sql_submissions'],'provider_calls':0,'output':str(args.output)}))
if __name__=='__main__':main()
