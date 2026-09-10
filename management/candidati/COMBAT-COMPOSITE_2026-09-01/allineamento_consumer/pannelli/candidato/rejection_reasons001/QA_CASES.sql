
-- PHASE G2
DO $case$ DECLARE r jsonb;k uuid:='a2000000-0000-4000-8000-000000000002';BEGIN
 PERFORM set_config('request.jwt.claim.sub','a1000000-0000-4000-8000-000000000001',false);
 r:=public.combat_panel_commit_v1('null'::jsonb);
 PERFORM qa_rejection.record_case('G2_native_validator','G2',qa_rejection.error_shape(r,null) AND r->>'code'='selection_rejected' AND r->>'message'='La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.' AND NOT EXISTS(SELECT 1 FROM qa_rejection.sentinel),jsonb_build_object('response',r,'sentinel_rows',(SELECT count(*) FROM qa_rejection.sentinel)));
 PERFORM set_config('qa.rejection_case','formation',false);r:=public.combat_panel_commit_v1(qa_rejection.command(k));
 PERFORM qa_rejection.record_case('G2_dispatch_rollback','G2',qa_rejection.error_shape(r,k) AND r->>'code'='selection_rejected' AND r->>'message'='Il numero di copie o la disposizione non rispettano i limiti disponibili della Moltiplicazione.' AND NOT EXISTS(SELECT 1 FROM qa_rejection.sentinel) AND NOT EXISTS(SELECT 1 FROM combat_panel_private.request_receipts),jsonb_build_object('response',r,'sentinel_rows',(SELECT count(*) FROM qa_rejection.sentinel),'receipts',(SELECT count(*) FROM combat_panel_private.request_receipts)));
END $case$;
SELECT jsonb_agg(to_jsonb(r) ORDER BY case_id) FROM qa_rejection.results r WHERE group_id='G2';
-- PHASE G3
DO $case$ DECLARE r jsonb;k uuid;mode text;expected_code text;expected_message text;expected_recovery text; i integer:=0;BEGIN
 PERFORM set_config('request.jwt.claim.sub','a1000000-0000-4000-8000-000000000001',false);
 FOREACH mode IN ARRAY ARRAY['unknown','context','pgrst','conflict'] LOOP
 i:=i+1;k:=('a3000000-0000-4000-8000-'||lpad(i::text,12,'0'))::uuid;PERFORM set_config('qa.rejection_case',mode,false);
 r:=public.combat_panel_commit_v1(qa_rejection.command(k));
 expected_code:=CASE mode WHEN 'unknown' THEN 'selection_rejected' WHEN 'context' THEN 'context_changed' WHEN 'pgrst' THEN 'operation_rejected' ELSE 'request_key_conflict' END;
 expected_message:=CASE mode WHEN 'unknown' THEN 'Le scelte non sono più valide. Rileggi le opzioni.' WHEN 'context' THEN 'Lo scontro è cambiato. Rileggi lo stato e scegli di nuovo.' WHEN 'pgrst' THEN 'Il server ha rifiutato l’operazione. Rileggi lo stato; se il problema resta, informa lo staff.' ELSE 'Questa richiesta è già associata a un altro invio. Verifica lo stato prima di continuare.' END;
 expected_recovery:=CASE WHEN mode='conflict' THEN 'contact_staff' ELSE 'refresh' END;
 PERFORM qa_rejection.record_case('G3_'||mode,'G3',qa_rejection.error_shape(r,k) AND r->>'code'=expected_code AND r->>'message'=expected_message AND r->>'recovery'=expected_recovery AND position('QA_SYNTHETIC_PRIVATE_MARKER' in r::text)=0 AND position('details_sanitized' in r::text)=0 AND NOT EXISTS(SELECT 1 FROM qa_rejection.sentinel) AND NOT EXISTS(SELECT 1 FROM combat_panel_private.request_receipts),jsonb_build_object('response',r,'sentinel_rows',(SELECT count(*) FROM qa_rejection.sentinel),'receipts',(SELECT count(*) FROM combat_panel_private.request_receipts),'provider_calls',0));
 END LOOP;
END $case$;
SELECT jsonb_agg(to_jsonb(r) ORDER BY case_id) FROM qa_rejection.results r WHERE group_id='G3';
-- PHASE G4_SUCCESS
DO $case$ DECLARE a jsonb;b jsonb;k uuid:='a4000000-0000-4000-8000-000000000001';BEGIN
 PERFORM set_config('request.jwt.claim.sub','a1000000-0000-4000-8000-000000000001',false);PERFORM set_config('qa.rejection_case','success',false);
 a:=public.combat_panel_commit_v1(qa_rejection.command(k));b:=public.combat_panel_commit_v1(qa_rejection.command(k));
 PERFORM qa_rejection.record_case('G4_success_replay','G4',a->>'status'='accepted' AND a->'receipt'->>'replayed'='false' AND b->'receipt'->>'replayed'='true' AND jsonb_set(a,'{receipt,replayed}','true',false)=b AND (SELECT count(*)=1 FROM qa_rejection.sentinel) AND (SELECT count(*)=1 FROM combat_panel_private.request_receipts),jsonb_build_object('first',a,'replay',b,'effects',(SELECT count(*) FROM qa_rejection.sentinel),'receipts',(SELECT count(*) FROM combat_panel_private.request_receipts),'boundary_synthetic',true));
END $case$;
SELECT to_jsonb(r) FROM qa_rejection.results r WHERE case_id='G4_success_replay';
-- PHASE POST
DO $case$ DECLARE r jsonb;k uuid:='a4000000-0000-4000-8000-000000000002';same_data boolean;BEGIN
 PERFORM set_config('request.jwt.claim.sub','a1000000-0000-4000-8000-000000000001',false);PERFORM set_config('qa.rejection_case','formation',false);
 r:=public.combat_panel_commit_v1(qa_rejection.command(k));
 SELECT data=qa_rejection.data_snapshot() INTO same_data FROM qa_rejection.snapshots WHERE label='before_recovery';
 PERFORM qa_rejection.record_case('G4_recovery_preserves','G4',qa_rejection.error_shape(r,k) AND r->>'code'='selection_rejected' AND r->>'message'='Le scelte non sono più valide. Rileggi le opzioni.' AND same_data AND (SELECT count(*)=0 FROM public.characters),jsonb_build_object('response',r,'data_preserved',same_data,'characters',(SELECT count(*) FROM public.characters)));
END $case$;
SELECT jsonb_build_object('cases',count(*),'passed',count(*) FILTER(WHERE passed),'groups',count(DISTINCT group_id),'all_pass',count(*)=9 AND bool_and(passed),'results',jsonb_agg(to_jsonb(r) ORDER BY case_id),'retained_data',qa_rejection.data_snapshot()) FROM qa_rejection.results r;
