\set ON_ERROR_STOP on
\timing on
BEGIN;
DO $test$
BEGIN
 IF public._esame_zona_dichiarata('Cerca di colpire la gamba dell''altro, poi cerca di colpire il volto.',1,1)<>'il viso'
  OR public._esame_zona_dichiarata('Tocca la spalla dell''altro, poi mira al ventre.',1,1)<>'il ventre'
 THEN RAISE EXCEPTION 'T01 ultima mira'; END IF;
END $test$;
SELECT 'T01 ultima mira oltre menzione possessiva PASS';
DO $test$
BEGIN
 IF public._esame_zona_dichiarata('Mira alla spalla destra.',1,1)<>'la spalla destra'
  OR public._esame_zona_dichiarata('Cerca di colpire il fianco sinistro.',1,1)<>'il fianco sinistro'
 THEN RAISE EXCEPTION 'T02 lateralità'; END IF;
END $test$;
SELECT 'T02 bersaglio unico e lateralità PASS';
DO $test$
BEGIN
 IF public._esame_zona_dichiarata(NULL,1,1) IS NOT NULL
  OR public._esame_zona_dichiarata('',1,1) IS NOT NULL
  OR public._esame_zona_dichiarata('Osserva.',1,1) IS NOT NULL
  OR public._esame_zona_dichiarata('Il torace.',1,1)<>'il torace'
 THEN RAISE EXCEPTION 'T03 fallback'; END IF;
END $test$;
SELECT 'T03 null, assenza di zona e fallback PASS';
DO $test$
BEGIN
 IF has_function_privilege('anon','public._esame_zona_dichiarata(text,bigint,integer)','EXECUTE')
  OR has_function_privilege('authenticated','public._esame_zona_dichiarata(text,bigint,integer)','EXECUTE')
  OR NOT has_function_privilege('service_role','public._esame_zona_dichiarata(text,bigint,integer)','EXECUTE')
  OR (SELECT provolatile FROM pg_proc WHERE oid='public._esame_zona_dichiarata(text,bigint,integer)'::regprocedure)<>'i'
  OR (SELECT md5(replace(prosrc,'(?:mir','(mir')) FROM pg_proc WHERE oid='public._esame_zona_dichiarata(text,bigint,integer)'::regprocedure)<>'95b3a01f7efecc82516550200dedfa63'
 THEN RAISE EXCEPTION 'T04 ACL/volatilità/delta'; END IF;
END $test$;
SELECT 'T04 ACL, volatilità e delta di soli due caratteri PASS';
ROLLBACK;
