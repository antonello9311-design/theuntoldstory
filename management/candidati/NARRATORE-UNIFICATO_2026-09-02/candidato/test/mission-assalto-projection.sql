\set ON_ERROR_STOP on
\timing on
BEGIN;
DO $test$
DECLARE r jsonb; o jsonb;
BEGIN
  r:='{"tecnica":"Moltiplicazione del corpo · Assalto","esito":"copia_colpita","attaccante":"Attaccante","difensore":"Difensore","bersaglio_su":"una copia di Difensore","colpito":true,"danno":"grave","bersaglio":"il viso"}';
  o:=public._esame_referto_modello(r);
  IF o->>'bersaglio_su'<>'Difensore' OR o->>'copie_di'<>'Attaccante'
    OR o->>'difesa_diretta_a'<>'una copia dell''attaccante'
    OR (o-'bersaglio_su'-'copie_di'-'difesa_diretta_a') IS DISTINCT FROM (r-'bersaglio_su')
  THEN RAISE EXCEPTION 'P01 copia Assalto'; END IF;
  r:=jsonb_set(r,'{esito}','"originale_individuato"');
  o:=public._esame_referto_modello(r);
  IF o->>'bersaglio_su'<>'Difensore' OR o->>'difesa_diretta_a'<>'l''attaccante originale'
    OR o->>'copie_di'<>'Attaccante' THEN RAISE EXCEPTION 'P01 originale Assalto'; END IF;
END $test$;
SELECT 'P01 Assalto: identità e conseguenze PASS';
DO $test$
DECLARE r jsonb;
BEGIN
  r:='{"tecnica":"Colpo a mani nude","esito":"copia_colpita","attaccante":"Attaccante","difensore":"Difensore","bersaglio_su":"una copia di Difensore","colpito":false,"danno":"nessuno"}';
  IF public._esame_referto_modello(r) IS DISTINCT FROM r THEN RAISE EXCEPTION 'P02 difesa copie modificata'; END IF;
END $test$;
SELECT 'P02 difesa ordinaria tramite copie invariata PASS';
DO $test$
DECLARE r jsonb; o jsonb;
BEGIN
  r:='{"lista":[{"tecnica":"Moltiplicazione del corpo · Assalto","esito":"copia_colpita","attaccante":"Attaccante","difensore":"Difensore","bersaglio_su":"una copia di Difensore","colpito":true,"danno":"grave","appendice":"interno","numero":24,"cifra_nel_testo":"24 punti"}],"altro":"intatto"}';
  o:=public._esame_referto_modello(r);
  IF o#>>'{lista,0,bersaglio_su}'<>'Difensore' OR o#>>'{lista,0,copie_di}'<>'Attaccante'
    OR (o#>'{lista,0}') ?| array['appendice','numero','cifra_nel_testo']
    OR o#>'{lista,0,colpito}' IS DISTINCT FROM 'true'::jsonb
    OR o#>>'{lista,0,danno}'<>'grave' OR o->>'altro'<>'intatto'
    OR public._esame_referto_modello(o) IS DISTINCT FROM o
  THEN RAISE EXCEPTION 'P03 ricorsione/idempotenza'; END IF;
END $test$;
SELECT 'P03 ricorsione, filtri esistenti e idempotenza PASS';
DO $test$
DECLARE r jsonb;
BEGIN
  r:='{"tecnica":"Moltiplicazione del corpo · Assalto","esito":"copia_colpita","difensore":"Difensore","bersaglio_su":"valore storico"}';
  IF public._esame_referto_modello(r) IS DISTINCT FROM r
    OR public._esame_referto_modello(NULL) IS NOT NULL
    OR has_function_privilege('anon','public._esame_referto_modello(jsonb)','EXECUTE')
    OR has_function_privilege('authenticated','public._esame_referto_modello(jsonb)','EXECUTE')
    OR NOT has_function_privilege('service_role','public._esame_referto_modello(jsonb)','EXECUTE')
    OR (SELECT provolatile FROM pg_proc WHERE oid='public._esame_referto_modello(jsonb)'::regprocedure)<>'i'
  THEN RAISE EXCEPTION 'P04 fonte insufficiente/ACL/volatilità'; END IF;
END $test$;
SELECT 'P04 fonte insufficiente, null, ACL e volatilità PASS';
ROLLBACK;
