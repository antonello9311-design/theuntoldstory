from pathlib import Path
import subprocess,json,time,hashlib
P=Path(__file__).resolve().parent; OUT=P/'CLAN_CONTINUATION_QA_FINAL.json';DB='tus_clan_continuation_qa'
if OUT.exists():raise SystemExit('Campagna già registrata: nessun retry')
CMD=['/Applications/Docker.app/Contents/Resources/bin/docker','--host','unix:///Users/antonello/.docker/run/docker.sock','exec','-i','-u','postgres','tus_ordinary_compose_qa_db','psql','-X','-Atq','-v','ON_ERROR_STOP=1','-d']
start=time.monotonic();results=[]
def run(name,sql,db=DB):
 if len(results)>=16 or time.monotonic()-start>2100:raise RuntimeError('Budget esaurito')
 t=time.monotonic()
 try:
  r=subprocess.run(CMD+[db],input=sql,text=True,capture_output=True,timeout=90)
  row={'case':name,'pass':r.returncode==0,'stdout':r.stdout,'stderr':r.stderr,'seconds':round(time.monotonic()-t,3)}
 except subprocess.TimeoutExpired:row={'case':name,'pass':False,'stderr':'timeout90s','seconds':90}
 results.append(row)
 OUT.write_text(json.dumps({'scope':'CLAN-CONTINUATION','database':DB,'install_sha256':hashlib.sha256((P/'CLAN_CONTINUATION_INSTALL.sql').read_bytes()).hexdigest(),'budget':{'groups':8,'submissions':16,'seconds':2100,'provider_calls':0,'tokens':0},'submissions':len(results),'seconds':round(time.monotonic()-start,3),'results':results,'limitations':['Auth locale simulata su fixture sintetiche; nessuna identità reale','Trasporto HTTP sostituito da coda QA senza rete, non certifica servizio Edge','Publish da output sintetico; contesto, ricevute, risoluzione e avanzamento nativi']},ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({k:v for k,v in row.items() if k not in ('stdout','stderr')}),flush=True);return row['pass']
def case(body):return "BEGIN;SET LOCAL statement_timeout='70s';DO $c$ DECLARE d uuid;r jsonb;o jsonb;aid uuid;n bigint;BEGIN "+body+" END $c$;ROLLBACK;"
if not run('clone_preflight',"DO $p$ BEGIN IF current_database()<>'tus_clan_continuation_qa' OR EXISTS(SELECT 1 FROM public.combat_v2_sessions) OR to_regnamespace('qa_clan_cont') IS NOT NULL THEN RAISE EXCEPTION 'qa_baseline_not_clean'; END IF; END $p$;"):raise SystemExit(1)
base=json.loads((P/'CLAN_CONTINUATION_BASELINE.json').read_text())['functions']+json.loads((P/'CLAN_CONTINUATION_CONTEXT_BASELINE.json').read_text())+json.loads((P/'CLAN_CONTINUATION_SCOPE_BASELINE.json').read_text())
pins="DO $p$ BEGIN "+''.join("IF md5(pg_get_functiondef('"+f['signature']+"'::regprocedure))<>'"+f['md5']+"' THEN RAISE EXCEPTION 'baseline_drift: "+f['signature']+"';END IF;" for f in base)+" END $p$;"
if not run('baseline_produzione_locale',pins):raise SystemExit(1)
install=(P/'CLAN_CONTINUATION_INSTALL.sql').read_text()
if not run('G01_install_rollback',install.rsplit('COMMIT;',1)[0]+'ROLLBACK;'+pins):raise SystemExit(1)
if not run('install_e_helpers',install+(P/'CLAN_CONTINUATION_QA_HELPERS.sql').read_text()):raise SystemExit(1)
cases=[
('G02_clone_context_publish',"d:=qa_clan_cont.clone_case();PERFORM qa_clan_cont.check_and_publish(d);"),
('G03_escape_context_publish',"d:=qa_clan_cont.escape_case();PERFORM qa_clan_cont.check_and_publish(d);"),
('G04_copies_context_publish',"r:=qa_integrated.resolve('azione_risolta');SELECT id INTO STRICT d FROM public.combat_v2_declarations WHERE round_id=(r->>'round_id')::uuid AND kind='utilita';PERFORM qa_clan_cont.check_and_publish(d);"),
('G05_unknown_and_scope',"r:=qa_integrated.resolve('rinuncia');SELECT id INTO STRICT d FROM public.combat_v2_declarations WHERE round_id=(r->>'round_id')::uuid AND kind='passa';PERFORM qa_integrated.check(combat_consumer_private.narrative_declaration_supported(d),'positive_pass_before_synthetic_fault');UPDATE public.combat_v2_declarations SET kind='utilita',sanitized_intent=jsonb_build_object('kind','utilita'),outcome='{}'::jsonb WHERE id=d;PERFORM qa_integrated.check((SELECT state='risolta' AND kind='utilita' FROM public.combat_v2_declarations WHERE id=d),'represented_resolved_unknown');PERFORM qa_integrated.check(NOT combat_consumer_private.narrative_declaration_supported(d),'unknown_utility_excluded');"),
('G05_protected_scope',"r:=qa_integrated.resolve('azione_risolta');SELECT id INTO STRICT d FROM public.combat_v2_declarations WHERE round_id=(r->>'round_id')::uuid AND kind='utilita';PERFORM qa_integrated.check(combat_consumer_private.narrative_declaration_supported(d),'positive_protected_utility');UPDATE public.locations SET is_test=false WHERE id=marionetta_qa.loc(true);PERFORM qa_integrated.check(NOT combat_consumer_private.narrative_declaration_supported(d),'outside_protected_excluded');"),
('G06_regression_hand',"d:=qa_clan_cont.hand_case();"),
('G06_regression_attack',"r:=qa_integrated.resolve('confronto');SELECT id INTO STRICT d FROM public.combat_v2_declarations WHERE round_id=(r->>'round_id')::uuid AND kind='attacco';PERFORM qa_integrated.check(combat_consumer_private.narrative_declaration_supported(d),'puppet_attack_preserved');PERFORM qa_clan_cont.publish_current();"),
('G06_regression_pass',"r:=qa_integrated.resolve('rinuncia');SELECT id INTO STRICT d FROM public.combat_v2_declarations WHERE round_id=(r->>'round_id')::uuid AND kind='passa';PERFORM qa_integrated.check(combat_consumer_private.narrative_declaration_supported(d),'pass_preserved');UPDATE clan_marionettisti_private.release_gate SET rinuncia_enabled=false;PERFORM qa_integrated.check(NOT combat_consumer_private.narrative_declaration_supported(d),'pass_gate_preserved');"),
('G07_dispatch_once_and_gate',"r:=qa_integrated.resolve('azione_risolta');UPDATE combat_consumer_private.runtime_config SET narrative_edge_url='https://qa.invalid/no-network',provider_enabled=false,staff_test_provider_enabled=false;SELECT count(*) INTO n FROM qa_scene.net_calls;PERFORM combat_consumer_private.dispatch_narrative('qa-local-marker');PERFORM qa_integrated.check((SELECT count(*)=n FROM qa_scene.net_calls),'gate_no_transport');UPDATE combat_consumer_private.runtime_config SET staff_test_provider_enabled=true;PERFORM combat_consumer_private.dispatch_narrative('qa-local-marker');PERFORM combat_consumer_private.dispatch_narrative('qa-local-marker');PERFORM qa_integrated.check((SELECT count(*)=n+1 FROM qa_scene.net_calls),'one_transport');PERFORM qa_integrated.check((SELECT count(*)=1 AND bool_and(state='queued') FROM combat_consumer_private.narrative_dispatches WHERE round_id=(r->>'round_id')::uuid),'one_queued_dispatch');PERFORM qa_integrated.check((SELECT mechanics_sha256=r->>'report_sha256' AND NOT values_written FROM public.combat_v2_round_reports WHERE round_id=(r->>'round_id')::uuid),'report_unchanged');")]
for name,body in cases:run(name,case(body))
run('G08_acl_and_no_residue',case("PERFORM qa_integrated.check(NOT has_function_privilege('authenticated','combat_consumer_private.narrative_declaration_supported(uuid)','EXECUTE') AND NOT has_function_privilege('anon','combat_consumer_private.narrative_declaration_supported(uuid)','EXECUTE') AND NOT has_function_privilege('service_role','combat_consumer_private.narrative_declaration_supported(uuid)','EXECUTE'),'private_acl');PERFORM qa_integrated.check(NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions),'no_residual_scene');"))
