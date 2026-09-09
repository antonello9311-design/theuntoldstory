from pathlib import Path
import subprocess, json, time, hashlib, sys, ast, re
from datetime import datetime, timezone
P = Path(__file__).resolve().parent
OUT = P / 'CLAN_CONTINUATION_QA_FINAL.json'
DB = 'tus_clan_continuation_qa'
INSTALL_SHA = '9dc6fa7fd2f0520e9e3779a600d90587d2151d389ae00a839f85bec0b6619089'
CMD = ['/Applications/Docker.app/Contents/Resources/bin/docker', '--host',
       'unix:///Users/antonello/.docker/run/docker.sock', 'exec', '-i', '-u', 'postgres',
       'tus_ordinary_compose_qa_db', 'psql', '-X', '-Atq', '-v', 'ON_ERROR_STOP=1', '-v', 'VERBOSITY=verbose', '-d', DB]
install = (P / 'CLAN_CONTINUATION_INSTALL.sql').read_text()
helpers = (P / 'CLAN_CONTINUATION_QA_HELPERS.sql').read_text()
base = json.loads((P/'CLAN_CONTINUATION_BASELINE.json').read_text())['functions'] + json.loads((P/'CLAN_CONTINUATION_CONTEXT_BASELINE.json').read_text()) + json.loads((P/'CLAN_CONTINUATION_SCOPE_BASELINE.json').read_text())
pins = "DO $p$ BEGIN " + ''.join("IF md5(pg_get_functiondef('"+f['signature']+"'::regprocedure)) IS DISTINCT FROM '"+f['md5']+"' THEN RAISE EXCEPTION 'baseline_drift: "+f['signature']+"'; END IF;" for f in base) + " END $p$;"
# Lo stesso INSTALL resta invariato su disco; il solo COMMIT esterno viene
# sostituito nel trasporto QA da ROLLBACK dopo il sottocaso.
transaction_install = install.rsplit('COMMIT;', 1)[0]
SNAPSHOT = """SELECT json_build_object(
 'database',current_database(),'postgres_version',current_setting('server_version'),
 'sessions_total',(SELECT count(*) FROM public.combat_v2_sessions),
 'sessions_open',(SELECT count(*) FROM public.combat_v2_sessions WHERE closed_at IS NULL),
 'history_md5',(SELECT md5(coalesce(string_agg(to_jsonb(s)::text, E'\\n' ORDER BY id),'')) FROM public.combat_v2_sessions s),
 'characters_md5',(SELECT md5(coalesce(string_agg(to_jsonb(c)::text, E'\\n' ORDER BY id),'')) FROM public.characters c),
 'functions_md5',(SELECT md5(coalesce(string_agg(p.oid::text||':'||pg_get_functiondef(p.oid)||':'||coalesce(p.proacl::text,''),E'\\n' ORDER BY p.oid),'')) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE p.prokind IN ('f','p') AND n.nspname NOT LIKE 'pg_%' AND n.nspname<>'information_schema'),
 'helper_absent',to_regnamespace('qa_clan_cont') IS NULL,
 'candidate_absent',to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)') IS NULL
)::text;"""
cases=[
('G02_clone_context_publish',"d:=qa_clan_cont.clone_case();PERFORM qa_clan_cont.check_and_publish(d);"),
('G03_escape_context_publish',"d:=qa_clan_cont.escape_case();PERFORM qa_clan_cont.check_and_publish(d);"),
('G04_copies_context_publish',"r:=qa_integrated.resolve('azione_risolta');SELECT id INTO STRICT d FROM public.combat_v2_declarations WHERE round_id=(r->>'round_id')::uuid AND kind='utilita';PERFORM qa_clan_cont.check_and_publish(d);"),
('G05_unknown_and_scope',"r:=qa_integrated.resolve('rinuncia');SELECT id INTO STRICT d FROM public.combat_v2_declarations WHERE round_id=(r->>'round_id')::uuid AND kind='passa';PERFORM qa_integrated.check(combat_consumer_private.narrative_declaration_supported(d),'positive_pass_before_synthetic_fault');UPDATE public.combat_v2_declarations SET kind='utilita',sanitized_intent=jsonb_build_object('kind','utilita'),outcome='{}'::jsonb WHERE id=d;PERFORM qa_integrated.check((SELECT state='risolta' AND kind='utilita' FROM public.combat_v2_declarations WHERE id=d),'represented_resolved_unknown');PERFORM qa_integrated.check(NOT combat_consumer_private.narrative_declaration_supported(d),'unknown_utility_excluded');"),
('G05_protected_scope',"r:=qa_integrated.resolve('azione_risolta');SELECT id INTO STRICT d FROM public.combat_v2_declarations WHERE round_id=(r->>'round_id')::uuid AND kind='utilita';PERFORM qa_integrated.check(combat_consumer_private.narrative_declaration_supported(d),'positive_protected_utility');UPDATE public.locations SET is_test=false WHERE id=marionetta_qa.loc(true);PERFORM qa_integrated.check(NOT combat_consumer_private.narrative_declaration_supported(d),'outside_protected_excluded');"),
('G06_regression_hand',"d:=qa_clan_cont.hand_case();"),
('G06_regression_attack',"r:=qa_integrated.resolve('confronto');SELECT id INTO STRICT d FROM public.combat_v2_declarations WHERE round_id=(r->>'round_id')::uuid AND kind='attacco';PERFORM qa_integrated.check(combat_consumer_private.narrative_declaration_supported(d),'puppet_attack_preserved');PERFORM qa_clan_cont.publish_current();"),
('G06_regression_pass',"r:=qa_integrated.resolve('rinuncia');SELECT id INTO STRICT d FROM public.combat_v2_declarations WHERE round_id=(r->>'round_id')::uuid AND kind='passa';PERFORM qa_integrated.check(combat_consumer_private.narrative_declaration_supported(d),'pass_preserved');UPDATE clan_marionettisti_private.release_gate SET rinuncia_enabled=false;PERFORM qa_integrated.check(NOT combat_consumer_private.narrative_declaration_supported(d),'pass_gate_preserved');"),
('G07_dispatch_once_and_gate',"r:=qa_integrated.resolve('azione_risolta');UPDATE combat_consumer_private.runtime_config SET narrative_edge_url='https://aaaaaaaaaaaaaaaaaaaa.supabase.co/functions/v1/combat_narratore_ai',provider_enabled=false,staff_test_provider_enabled=false;SELECT count(*) INTO n FROM qa_scene.net_calls;PERFORM combat_consumer_private.dispatch_narrative('qa-local-marker');PERFORM qa_integrated.check((SELECT count(*)=n FROM qa_scene.net_calls),'gate_no_transport');UPDATE combat_consumer_private.runtime_config SET staff_test_provider_enabled=true;PERFORM combat_consumer_private.dispatch_narrative('qa-local-marker');PERFORM combat_consumer_private.dispatch_narrative('qa-local-marker');PERFORM qa_integrated.check((SELECT count(*)=n+1 FROM qa_scene.net_calls),'one_transport');PERFORM qa_integrated.check((SELECT count(*)=1 AND bool_and(state='queued') FROM combat_consumer_private.narrative_dispatches WHERE round_id=(r->>'round_id')::uuid),'one_queued_dispatch');PERFORM qa_integrated.check((SELECT mechanics_sha256=r->>'report_sha256' AND NOT values_written FROM public.combat_v2_round_reports WHERE round_id=(r->>'round_id')::uuid),'report_unchanged');")]

acl_body = "PERFORM qa_integrated.check(NOT has_function_privilege('authenticated','combat_consumer_private.narrative_declaration_supported(uuid)','EXECUTE') AND NOT has_function_privilege('anon','combat_consumer_private.narrative_declaration_supported(uuid)','EXECUTE') AND NOT has_function_privilege('service_role','combat_consumer_private.narrative_declaration_supported(uuid)','EXECUTE'),'private_acl');PERFORM qa_integrated.check(NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL),'no_residual_scene');"

def validate_static():
 ast.parse(Path(__file__).read_text())
 assert hashlib.sha256((P/'CLAN_CONTINUATION_INSTALL.sql').read_bytes()).hexdigest() == INSTALL_SHA
 assert install.count('\nCOMMIT;') == 1 and install.rstrip().endswith('COMMIT;')
 assert '\nBEGIN;' in transaction_install and 'COMMIT;' not in transaction_install
 assert not any(x in helpers.upper() for x in ('COMMIT;', 'ROLLBACK;', 'TRUNCATE ', 'DELETE FROM ', 'UPDATE PUBLIC.CHARACTERS'))
 assert len(cases)==9 and len({name for name,_ in cases})==9
 assert {name[:3] for name,_ in cases}|{'G01','G08'}=={f'G{i:02}' for i in range(1,9)}
 assert len({f['signature'] for f in base})==9
 fixture=json.loads((P/'CLAN_CONTINUATION_FIXTURE.json').read_text())
 assert len(fixture['entropy_vectors'])==14 and len(fixture['component_vectors'])==2
 assert all(v in helpers for v in fixture['entropy_vectors'])
 assert len(cases)+5==14<=16 and 14+2==16<=20
 return {'pass':True,'groups':8,'functional_subcases':9,'component_vectors':2,'entropy_candidates_max':14,'preparation_sql':2,'planned_campaign_sql':14,'planned_total_sql':16,'provider_calls':0,'install_sha256':INSTALL_SHA,'fixture_sha256':hashlib.sha256((P/'CLAN_CONTINUATION_FIXTURE.json').read_bytes()).hexdigest()}

static = validate_static()
if '--static-only' in sys.argv:
 print(json.dumps(static)); raise SystemExit(0)
if OUT.exists(): raise SystemExit('Campagna già registrata: nessun retry')
PREPARATION = {'case': 'preparazione_readonly_contratti_QA', 'pass': True, 'seconds': 0.416, 'evidence': {'at': '2026-09-09T15:08:18.445066+00:00', 'database': 'tus_clan_continuation_qa', 'function_md5': {'clan_sabaku_private.consumer_options(jsonb)': '2133d8387e8f9264ca11522c3b2ebc61', 'combat_panel_private.import_ordinary_offer(uuid,bigint,jsonb,bigint)': 'ffcbd498cae1a0653029960f9781c178', 'clan_sabaku_private.clone_capture_guard()': '0ce56b7c0caa222e0e259ec2200bb563', 'qa_integrated.commit_offer(integer,jsonb,jsonb,text)': '8d250caa44cec49070903c7901176e8b'}}}
start = time.monotonic()
started_at = datetime.now(timezone.utc).isoformat()
PREPARATION_COMPILE = {'case': 'preparazione_compilazione_transazionale', 'pass': True, 'seconds': 0.147, 'sql_count': 1, 'gameplay_executed': False}
results = [PREPARATION, PREPARATION_COMPILE]
before = None

def save():
 OUT.write_text(json.dumps({'task_id':'CLAN-RACCORDO-QUALIFICA-CONTRATTO-001', 'scope':'raccordo-ingressi-autorevoli-e-fixture-sintetica-validata', 'review':'pending-first-independent-review', 'cycle':'Nuovo contratto PM sul raccordo; precedente finale ROSSA preservata', 'database':DB,
  'started_at_utc':started_at, 'updated_at_utc':datetime.now(timezone.utc).isoformat(), 'install_sha256':INSTALL_SHA,
  'static_checks':static, 'baseline_source':'File datati del 09/09; confronto locale delle 9 definizioni distinte. Nessuna nuova lettura produzione.',
  'budget':{'groups':8,'submissions':20,'preparation_max':4,'campaign_max':16,'seconds':2100,'provider_calls':0,'tokens':0},
  'submissions':len(results),'seconds':round(time.monotonic()-start+PREPARATION['seconds']+PREPARATION_COMPILE['seconds'],3),'results':results,
  'qualification':'owner-pass-first-review-pending' if len(results)==16 and all(r['pass'] for r in results) else 'owner-incomplete-or-red-review-pending',
  'changes_to_harness':['Nuovo contratto di prova: Clone nativo con qualunque esito','G03 da fixture positiva SINTETICA validata, entropie finite congelate','Selezione offerte per identità/operazione/sorgente/bersaglio, non label','Nessuna UPDATE statistiche; componenti positivo/negativo e postflight invariati'],
  'limitations':['Auth locale simulata su fixture sintetiche; nessuna identità reale','HTTP sostituito da coda QA senza rete: Edge, provider e Auth reali non certificati','Pubblicazione da output sintetico; contesto, ricevute, risoluzione e avanzamento nativi','Le sequenze PostgreSQL possono avanzare anche con rollback; nessun reset dei contatori','Nessuna prova UI o disponibilità live attestata','G03 non certifica innesco naturale della presa: contatto e ingresso positivo sintetici esplicitamente dichiarati','Entropie sintetiche: insieme congelato di14 vettori, selezione deterministica massimo14 senza retry gameplay; due vettori puri aggiuntivi' ]}, ensure_ascii=False, indent=2)+'\n')

def run(name, sql, compare=False):
 if len(results)>=20 or time.monotonic()-start>2100: raise RuntimeError('Budget esaurito')
 t=time.monotonic()
 row={'case':name, 'pass':False}
 try:
  r=subprocess.run(CMD,input=sql,text=True,capture_output=True,timeout=90)
  row.update({'pass':r.returncode==0, 'exit_code':r.returncode})
  row['witnesses']=[]
  for line in r.stderr.splitlines():
   for marker in ('QA_FIXTURE:', 'QA_COMPONENT:'):
    if marker in line:
     try: row['witnesses'].append(json.loads(line.split(marker,1)[1]))
     except ValueError: row['pass']=False;row['diagnostic_parse_error']=True
  # VERBOSITY=verbose consente codice e posizione. Nessuna stringa SQL,
  # parametro, ruolo, valore o messaggio arbitrario finisce nel referto.
  if r.returncode:
   state=re.search(r'ERROR:\s+([0-9A-Z]{5}):',r.stderr)
   frames=[]
   for line in r.stderr.splitlines():
    frame=re.search(r'PL/pgSQL function ([A-Za-z_][A-Za-z_0-9.]*)(?:\([^\n]*?\))? line (\d+) at ([A-Za-z ]+)',line)
    if frame: frames.append({'function':frame.group(1),'line':int(frame.group(2)),'operation':frame.group(3).strip()})
   row['error']={'sqlstate':state.group(1) if state else 'unavailable','frames':frames}
   marker=re.search(r'qa_(?:semantic_offer_cardinality:[a-z_]+:[0-9]+|frozen_vector_set_has_no_positive|component_vectors_mismatch)',r.stderr)
   if marker: row['error']['qa_marker']=marker.group(0)
  else:
   snapshots=[json.loads(x) for x in r.stdout.splitlines() if x.startswith('{')]
   if snapshots: row['snapshot']=snapshots[-1]
   if compare:
    row['baseline_equal']=row.get('snapshot')==before
    row['pass']=row['pass'] and row['baseline_equal']
 except subprocess.TimeoutExpired:
  row['error']='timeout90s'
 row['seconds']=round(time.monotonic()-t,3)
 results.append(row);save()
 print(json.dumps({k:v for k,v in row.items() if k!='snapshot'}),flush=True)
 return row

preflight = "DO $p$ BEGIN IF current_database()<>'tus_clan_continuation_qa' OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL) OR to_regnamespace('qa_clan_cont') IS NOT NULL OR to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)') IS NOT NULL THEN RAISE EXCEPTION 'qa_baseline_not_clean'; END IF; END $p$;"
r=run('clone_preflight',preflight+SNAPSHOT)
if not r['pass']: raise SystemExit(1)
before=r['snapshot']
if not run('baseline_datata_confronto_locale', pins)['pass']: raise SystemExit(1)
component_sql = """DO $vectors$ DECLARE neg jsonb;pos jsonb; BEGIN
 neg:=clan_sabaku_private.clone_capture_result(30,30,20,20,ARRAY[1,1,10,10]);
 pos:=clan_sabaku_private.clone_capture_result(30,30,20,20,ARRAY[10,10,1,1]);
 IF (neg->>'success')::boolean OR NOT (pos->>'success')::boolean THEN RAISE EXCEPTION 'qa_component_vectors_mismatch'; END IF;
 RAISE NOTICE 'QA_COMPONENT:%',jsonb_build_object('provenance','COMPONENTE_PURO_SINTETICO','negative',neg,'positive',pos);
END $vectors$;"""
if not run('G01_install_rollback',transaction_install+component_sql+'ROLLBACK;'+pins+SNAPSHOT,compare=True)['pass']: raise SystemExit(1)

def case(body):
 return transaction_install + helpers + "SET LOCAL statement_timeout='70s';DO $c$ DECLARE d uuid;r jsonb;o jsonb;aid uuid;n bigint;BEGIN " + body + " END $c$;ROLLBACK;" + SNAPSHOT

for name, body in cases:
 r=run(name,case(body),compare=True)
 # Una variazione persistente è rischio dati: interrompere. Un rosso funzionale
 # annulla la connessione e non impedisce la raccolta degli altri casi.
 if r.get('baseline_equal') is False: raise SystemExit(1)
 if any(frame['function'].endswith('_guard') for frame in r.get('error',{}).get('frames',[])):
  run('postflight_after_validator_stop',preflight+pins+SNAPSHOT,compare=True)
  raise SystemExit(1)
run('G08_acl_and_no_residue',case(acl_body),compare=True)
run('postflight_baseline_e_storico',preflight+pins+SNAPSHOT,compare=True)
raise SystemExit(0 if len(results)==16 and all(x['pass'] for x in results) else 1)
