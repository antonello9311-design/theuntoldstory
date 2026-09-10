-- Frozen four-group component matrix. Synthetic local data, no gameplay.
-- SECTION G2

DO $qa$ DECLARE p jsonb;s jsonb;f jsonb;e jsonb;b jsonb; n integer; BEGIN
SELECT projection INTO b FROM qa_before;
p:=combat_consumer_private.narrative_tech_sources_v1('00000000-0000-0000-0000-000000000040');
s:=combat_consumer_private.scene_snapshot_v2('00000000-0000-0000-0000-000000000040');
PERFORM public.qa_assert(jsonb_typeof(s->'resolved_facts')='string' AND pg_input_is_valid(s->>'resolved_facts','jsonb'),'snapshot JSON string native');
f:=(s->>'resolved_facts')::jsonb;
PERFORM public.qa_assert(p=combat_consumer_private.narrative_tech_sources_v1('00000000-0000-0000-0000-000000000040'),'determinismo');
PERFORM public.qa_assert(p->'fonti_tecniche'=b->'fonti_tecniche','fonti legacy immutate');
PERFORM public.qa_assert((SELECT jsonb_agg(x) FROM jsonb_array_elements(p->'conclusioni_effetti_server') x WHERE x->>'tecnica'='Clone di Sabbia')=b->'conclusioni_effetti_server','Clone immutato');
SELECT count(*),jsonb_agg(x)->0 INTO n,e FROM jsonb_array_elements(p->'conclusioni_effetti_server') x WHERE x->>'tecnica'='Moltiplicazione del corpo';
PERFORM public.qa_assert(n=1 AND e='{"tecnica":"Moltiplicazione del corpo","actor_id":"00000000-0000-0000-0000-000000000012","stato":"terminato","causa":"primo_attacco_risolto"}'::jsonb,'evento006 esatto quattro campi');
PERFORM public.qa_assert(f->'conclusioni_effetti_server'=p->'conclusioni_effetti_server' AND f->'fonti_tecniche'=p->'fonti_tecniche','hook trasmette fonti e fine');
PERFORM public.qa_assert(s->'sources'=(SELECT snapshot->'sources' FROM qa_before) AND s->'actors'=(SELECT snapshot->'actors' FROM qa_before),'fonti role/roster invariati');
PERFORM public.qa_assert(s::text !~ 'qa_private_sentinel|original_index|rng_seed|selected_index|receipt_sha256|source_body_version|target_velocity|x_m|y_m','privacy proiezione');
INSERT INTO qa_results VALUES('G2','PASS','{"scope":"synthetic projection branch006 + legacy Clone; not native resolution/provider"}');
EXCEPTION WHEN OTHERS THEN INSERT INTO qa_results VALUES('G2','FAIL',jsonb_build_object('sqlstate',SQLSTATE,'error',SQLERRM)); END $qa$;
-- SECTION G3

DO $qa$ DECLARE denied boolean; p jsonb; BEGIN
BEGIN
UPDATE public.combat_v2_attack_targets SET round_id='00000000-0000-0000-0000-000000000009';
p:=combat_consumer_private.narrative_tech_sources_v1('00000000-0000-0000-0000-000000000040');
PERFORM public.qa_assert(NOT EXISTS(SELECT 1 FROM jsonb_array_elements(p->'conclusioni_effetti_server') e WHERE e->>'tecnica'='Moltiplicazione del corpo'),'round estraneo escluso');
RAISE EXCEPTION 'rollback fixture' USING ERRCODE='ZQ001';
EXCEPTION WHEN SQLSTATE 'ZQ001' THEN NULL; END;
denied:=false;
BEGIN UPDATE combat_panel_private.multiplication_resolutions SET receipt_sha256=repeat('0',64);
PERFORM combat_consumer_private.narrative_tech_sources_v1('00000000-0000-0000-0000-000000000040');
RAISE EXCEPTION 'hash non respinto';
EXCEPTION WHEN SQLSTATE '22023' THEN denied:=SQLERRM='narrative_multiplication_receipt_invalid'; END;
PERFORM public.qa_assert(denied,'hash alterato respinto');
denied:=false;
BEGIN UPDATE combat_panel_private.multiplication_formations SET terminal_reason='expired';
PERFORM combat_consumer_private.narrative_tech_sources_v1('00000000-0000-0000-0000-000000000040');
RAISE EXCEPTION 'terminale non respinto';
EXCEPTION WHEN SQLSTATE '22023' THEN denied:=SQLERRM='narrative_multiplication_terminal_event_invalid'; END;
PERFORM public.qa_assert(denied,'terminale incoerente respinto');
PERFORM public.qa_assert(public.qa_data_digest()=(SELECT data_sha FROM qa_before),'rollback dati invariati');
INSERT INTO qa_results VALUES('G3','PASS','{"round":"excluded","hash":"denied","terminal":"denied","rollback":"verified"}');
EXCEPTION WHEN OTHERS THEN INSERT INTO qa_results VALUES('G3','FAIL',jsonb_build_object('sqlstate',SQLSTATE,'error',SQLERRM)); END $qa$;
-- SECTION G4
CREATE FUNCTION public.qa_exact_recovery_use_guard() RETURNS void LANGUAGE plpgsql AS $qa$ BEGIN

 IF current_setting('tus.multiplication_lifecycle_recovery',true)
   IS DISTINCT FROM 'Antonello:NARRATIVE-MULTIPLICATION-LIFECYCLE-CANDIDATE-001:before-use' THEN
  RAISE EXCEPTION 'multiplication_lifecycle_named_recovery_required'; END IF;
 IF EXISTS (
  SELECT 1 FROM combat_consumer_private.scene_attempts_v2 a
  CROSS JOIN LATERAL (SELECT CASE
    WHEN jsonb_typeof(a.scene_payload->'resolved_facts')='object' THEN a.scene_payload->'resolved_facts'
    WHEN jsonb_typeof(a.scene_payload->'resolved_facts')='string'
      AND pg_catalog.pg_input_is_valid(a.scene_payload->>'resolved_facts','jsonb')
      THEN (a.scene_payload->>'resolved_facts')::jsonb ELSE '{}'::jsonb END AS facts) decoded
  CROSS JOIN LATERAL jsonb_array_elements(CASE
    WHEN jsonb_typeof(decoded.facts->'conclusioni_effetti_server')='array'
    THEN decoded.facts->'conclusioni_effetti_server' ELSE '[]'::jsonb END) e
  WHERE e->>'tecnica'='Moltiplicazione del corpo' AND e->>'stato'='terminato'
    AND e->>'causa' IN ('primo_attacco_risolto','assalto_risolto')
 ) THEN RAISE EXCEPTION 'multiplication_lifecycle_already_used_recovery_forbidden'; END IF;
END $qa$;

DO $qa$ DECLARE denied boolean; shape jsonb; payload jsonb; BEGIN
-- Named gate is local only and is not set by product or in production.
denied:=false;
BEGIN PERFORM public.qa_exact_recovery_use_guard(); RAISE EXCEPTION 'named gate absent not denied';
EXCEPTION WHEN OTHERS THEN denied:=SQLERRM='multiplication_lifecycle_named_recovery_required'; END;
PERFORM public.qa_assert(denied,'nominative gate');
PERFORM set_config('tus.multiplication_lifecycle_recovery','Antonello:NARRATIVE-MULTIPLICATION-LIFECYCLE-CANDIDATE-001:before-use',true);
PERFORM public.qa_exact_recovery_use_guard();
payload:=combat_consumer_private.narrative_tech_sources_v1('00000000-0000-0000-0000-000000000040');
FOREACH shape IN ARRAY ARRAY[payload,to_jsonb(payload::text)] LOOP
 denied:=false;
 BEGIN
 INSERT INTO combat_consumer_private.scene_attempts_v2 VALUES(jsonb_build_object('resolved_facts',shape));
 PERFORM public.qa_exact_recovery_use_guard();
 RAISE EXCEPTION 'history not denied';
 EXCEPTION WHEN OTHERS THEN denied:=SQLERRM='multiplication_lifecycle_already_used_recovery_forbidden'; END;
 PERFORM public.qa_assert(denied,'object/string persisted conclusion denied');
END LOOP;
BEGIN
INSERT INTO combat_consumer_private.scene_attempts_v2 VALUES('{"resolved_facts":null}'),('{"resolved_facts":7}');
PERFORM public.qa_exact_recovery_use_guard();
RAISE EXCEPTION 'rollback synthetic shapes' USING ERRCODE='ZQ001';
EXCEPTION WHEN SQLSTATE 'ZQ001' THEN NULL; END;
PERFORM public.qa_assert(public.qa_data_digest()=(SELECT data_sha FROM qa_before),'history fixture rolled back, no delete');
INSERT INTO qa_results VALUES('G4_guard','PASS','{"guard":"exact UNUSED block","object_and_string":"deny","null_scalar":"safe","complete_wrapper":"NOT_RUN"}');
EXCEPTION WHEN OTHERS THEN INSERT INTO qa_results VALUES('G4_guard','FAIL',jsonb_build_object('sqlstate',SQLSTATE,'error',SQLERRM)); END $qa$;
