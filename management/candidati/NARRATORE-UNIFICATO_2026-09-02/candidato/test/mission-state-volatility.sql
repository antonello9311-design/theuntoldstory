\set ON_ERROR_STOP on
-- Solo DB locale esclusivo. Auth fixture sintetica, nessun provider.
SET request.jwt.claim.sub='10000000-0000-4000-8000-000000000001';
CREATE TEMP TABLE state_fixture(prova uuid,character_sha text);
CREATE TEMP TABLE state_results(id integer,ok boolean,detail text);
BEGIN;
UPDATE mission_exam_private.release_gate SET enabled=true;
INSERT INTO state_fixture SELECT (public.esame_session_open(gen_random_uuid())->>'prova')::uuid,
 (SELECT md5(to_jsonb(c)::text) FROM public.characters c WHERE c.id='f335b077-34a1-41c3-94aa-58ec674b649b');
UPDATE public.esame_prove SET meta='png',fase='difesa',pend_azione='{"principale":{"fonte":"colpo"}}'
 WHERE id=(SELECT prova FROM state_fixture);
COMMIT;
BEGIN READ ONLY;
DO $test$
BEGIN
 BEGIN
  PERFORM public.esame_prova_stato((SELECT prova FROM state_fixture));
  INSERT INTO state_results VALUES(1,false,'baseline non riproduce25006');
 EXCEPTION WHEN read_only_sql_transaction THEN
  INSERT INTO state_results VALUES(1,true,'baseline riproduce25006');
 WHEN OTHERS THEN INSERT INTO state_results VALUES(1,false,SQLSTATE||':'||SQLERRM);
 END;
END $test$;
COMMIT;
ALTER FUNCTION public.esame_prova_stato(uuid) VOLATILE;
BEGIN;
DO $test$
DECLARE r jsonb;
BEGIN
 BEGIN
  r:=public.esame_prova_stato((SELECT prova FROM state_fixture));
  INSERT INTO state_results VALUES(2,
   r#>>'{prova,id}'=(SELECT prova::text FROM state_fixture)
   AND (SELECT md5(to_jsonb(c)::text) FROM public.characters c WHERE c.id='f335b077-34a1-41c3-94aa-58ec674b649b')=(SELECT character_sha FROM state_fixture),
   'transazione scrivibile: stato restituito e scheda invariata');
 EXCEPTION WHEN OTHERS THEN INSERT INTO state_results VALUES(2,false,SQLSTATE||':'||SQLERRM);
 END;
END $test$;
DO $test$
DECLARE denied boolean:=false;
BEGIN
 PERFORM set_config('request.jwt.claim.sub','',true);
 BEGIN PERFORM public.esame_prova_stato((SELECT prova FROM state_fixture));
 EXCEPTION WHEN raise_exception THEN denied:=SQLERRM='non autenticato';END;
 INSERT INTO state_results VALUES(3,denied
  AND (SELECT provolatile='v' AND md5(prosrc)='a2f88dc113ee44b9078e09a580153bce'
   AND proacl::text='{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}'
   FROM pg_proc WHERE oid='public.esame_prova_stato(uuid)'::regprocedure),
  'Auth assente rifiutata; corpo e ACL invariati');
END $test$;
COMMIT;
TABLE state_results;
SELECT bool_and(ok) AND count(*)=3 all_passed FROM state_results;
SELECT public.esame_session_close((SELECT prova FROM state_fixture),gen_random_uuid());
