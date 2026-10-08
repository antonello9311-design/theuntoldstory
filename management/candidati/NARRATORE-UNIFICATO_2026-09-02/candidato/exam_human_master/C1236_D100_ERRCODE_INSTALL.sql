-- C1236 agg12/review13 SOURCE_ONLY; preparation never applies DB.
-- Seven custom error codes only; no ACL, auth, mechanics, data or history change.
BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '30s';
DO $errcode_install$
DECLARE
 f pg_catalog.pg_proc%ROWTYPE;
 after_f pg_catalog.pg_proc%ROWTYPE;
 old_definition text;
 new_definition text;
 expected_metadata jsonb := '{"oid":"300715","proacl":["postgres=X/postgres","authenticated=X/postgres"],"proallargtypes":null,"proargdefaults":null,"proargmodes":null,"proargnames":["p_session","p_view","p_character"],"proargtypes":["2950","25","2950"],"probin":null,"proconfig":["search_path=\"\""],"procost":100,"proisstrict":false,"prokind":"f","prolang":"13619","proleakproof":false,"proname":"mission_factory_mission_d100_state_v1","pronamespace":"2200","pronargdefaults":0,"pronargs":3,"proowner":"16388","proparallel":"u","proretset":false,"prorettype":"3802","prorows":0,"prosecdef":true,"prosqlbody":null,"prosupport":"-","protrftypes":null,"provariadic":"0","provolatile":"v"}'::jsonb;
BEGIN
 SELECT p.* INTO STRICT f FROM pg_catalog.pg_proc p WHERE p.oid=pg_catalog.to_regprocedure('public.mission_factory_mission_d100_state_v1(uuid,text,uuid)');
 IF f.oid::bigint <> 300715 OR md5(f.prosrc) <> '68a236a17b6a01101c953f79e1800969'
  OR md5(pg_catalog.pg_get_functiondef(f.oid)) <> '0b76dce38134e6c2d15c54aa04ee1054'
  OR pg_catalog.pg_get_function_identity_arguments(f.oid) <> 'p_session uuid, p_view text, p_character uuid'
  OR pg_catalog.pg_get_function_result(f.oid) <> 'jsonb'
  OR to_jsonb(f)-'prosrc' IS DISTINCT FROM expected_metadata
 THEN RAISE EXCEPTION 'C1236_D100_ERRCODE_BASELINE_DRIFT' USING ERRCODE='PT409'; END IF;
 IF (length(f.prosrc)-length(replace(f.prosrc, 'ERRCODE=''40001''', '')))/length('ERRCODE=''40001''') <> 7
  OR (length(f.prosrc)-length(replace(f.prosrc, '''40001''', '')))/length('''40001''') <> 7
  OR position('''PT409''' IN f.prosrc) <> 0
 THEN RAISE EXCEPTION 'C1236_D100_ERRCODE_MATCH_DRIFT' USING ERRCODE='PT409'; END IF;
 old_definition := pg_catalog.pg_get_functiondef(f.oid);
 new_definition := replace(old_definition, '''40001''', '''PT409''');
 IF md5(new_definition) <> '928674505f3a76b6667dcbb13aaa2839' THEN RAISE EXCEPTION 'C1236_D100_ERRCODE_DELTA_DRIFT' USING ERRCODE='PT409'; END IF;
 EXECUTE new_definition;
 SELECT p.* INTO STRICT after_f FROM pg_catalog.pg_proc p WHERE p.oid=pg_catalog.to_regprocedure('public.mission_factory_mission_d100_state_v1(uuid,text,uuid)');
 IF after_f.oid <> f.oid OR to_jsonb(after_f)-'prosrc' IS DISTINCT FROM expected_metadata
  OR md5(after_f.prosrc) <> '62bd694f0d07fe1e97866bb8752448de'
  OR md5(pg_catalog.pg_get_functiondef(after_f.oid)) <> '928674505f3a76b6667dcbb13aaa2839'
  OR after_f.prosrc IS DISTINCT FROM replace(f.prosrc, '''40001''', '''PT409''')
 THEN RAISE EXCEPTION 'C1236_D100_ERRCODE_POSTFLIGHT_DRIFT' USING ERRCODE='PT409'; END IF;
END;
$errcode_install$;
COMMIT;
