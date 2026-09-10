-- COMBAT-PANEL-REJECTION-REASONS-CANDIDATE-001 INSTALL; candidate only, no game data operations.
BEGIN;
SET LOCAL search_path=pg_catalog,public;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='120s';
SELECT pg_advisory_xact_lock(hashtextextended('public.combat_panel_commit_v1:message-release',731));
DO $guard$ DECLARE o oid; BEGIN
o:=to_regprocedure('public.combat_panel_commit_v1(jsonb)'); IF o IS NULL THEN RAISE EXCEPTION 'panel_message_function_missing:%','public.combat_panel_commit_v1(jsonb)'; END IF;
IF md5(pg_get_functiondef(o)) IS DISTINCT FROM '84860632d828931cea773b83c583548e' OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p WHERE p.oid=o AND pg_get_userbyid(p.proowner)='postgres' AND p.proacl::text IS NOT DISTINCT FROM '{postgres=X/postgres,authenticated=X/postgres}' AND p.prosecdef=true AND p.provolatile='v' AND p.proconfig IS NOT DISTINCT FROM ARRAY['search_path=""']::text[]) THEN RAISE EXCEPTION 'panel_message_function_drift:%','public.combat_panel_commit_v1(jsonb)'; END IF;
o:=to_regprocedure('public.combat_v2_fail(text,text,integer,uuid,jsonb)'); IF o IS NULL THEN RAISE EXCEPTION 'panel_message_function_missing:%','public.combat_v2_fail(text,text,integer,uuid,jsonb)'; END IF;
IF md5(pg_get_functiondef(o)) IS DISTINCT FROM '607dec1f81b9b0c310c91585315803f6' OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p WHERE p.oid=o AND pg_get_userbyid(p.proowner)='postgres' AND p.proacl::text IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}' AND p.prosecdef=false AND p.provolatile='v' AND p.proconfig IS NOT DISTINCT FROM ARRAY['search_path=""']::text[]) THEN RAISE EXCEPTION 'panel_message_function_drift:%','public.combat_v2_fail(text,text,integer,uuid,jsonb)'; END IF;
END $guard$;
-- CREATE OR REPLACE retains the existing owner and ACL; no GRANT/REVOKE/ALTER.
CREATE OR REPLACE FUNCTION public.combat_panel_commit_v1(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p jsonb; uid uuid:=auth.uid(); key uuid; fp text; adapter text; reason text;
 prior combat_panel_private.request_receipts%ROWTYPE; offer combat_panel_private.offers%ROWTYPE;
 code text; message text; recovery text;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 p:=combat_panel_private.validate_command(p_command); key:=(p->>'request_key')::uuid; fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF prior.request_key IS NOT NULL THEN
   IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);
 END IF;
 SELECT * INTO offer FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
 IF offer.id IS NULL THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
 adapter:=offer.source_payload->>'adapter';
 reason:=combat_panel_private.access_reason((p->>'location_id')::uuid,adapter);
 IF reason IS NOT NULL THEN RAISE EXCEPTION 'panel_access_rejected' USING ERRCODE='42501'; END IF;
 IF adapter IS DISTINCT FROM combat_panel_private.location_adapter((p->>'location_id')::uuid) THEN
   RAISE EXCEPTION 'panel_context_stale' USING ERRCODE='40001'; END IF;
 IF offer.kind='administration' AND offer.operation='open'
   AND offer.source_payload->>'dispatch'='master_session_open' THEN
   RETURN combat_panel_private.commit_master_open(p); END IF;
 IF offer.kind='action' AND offer.operation='declare' AND offer.source_payload->>'dispatch'='sabaku_clone' THEN
   RETURN clan_sabaku_private.commit_clone(p); END IF;
 IF offer.kind='action' AND offer.operation='declare' AND offer.source_payload->>'dispatch'='immobilization_escape' THEN
   RETURN combat_panel_private.commit_immobilization_escape(p); END IF;
 IF offer.kind='action' AND offer.operation='declare' AND offer.source_payload->>'dispatch'='multiplication' THEN
   RETURN combat_panel_private.commit_multiplication(p); END IF;
 IF adapter='ordinary_v2' AND offer.kind='control' AND offer.operation='control' AND offer.source_payload->>'dispatch'='pg_movement' THEN
   RETURN combat_panel_private.commit_pg_movement(p); END IF;
 IF adapter='ordinary_v2' THEN RETURN combat_panel_private.commit_ordinary(p); END IF;
 IF adapter='master_v2' THEN
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='sabaku_control' THEN
     RETURN clan_sabaku_private.commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='companion_control' THEN
     RETURN combat_panel_private.commit_master_companion(p); END IF;
   IF offer.kind='administration' THEN RETURN combat_panel_private.commit_master_admin(p); END IF;
   RETURN combat_panel_private.commit_master_actor(p);
 END IF;
 RAISE EXCEPTION 'panel_dispatch_not_available' USING ERRCODE='22023';
EXCEPTION WHEN OTHERS THEN
 -- Questo ramo viene raggiunto dopo il rollback dell'intera sottotransazione
 -- della richiesta. Non comprende timeout/disconnessioni senza risposta DB.
 code:=CASE WHEN SQLSTATE='28000' THEN 'authentication_required'
   WHEN SQLERRM='panel_request_key_conflict' THEN 'request_key_conflict'
   WHEN SQLSTATE='42501' THEN 'not_authorized'
   WHEN SQLSTATE='40001' THEN 'context_changed'
   WHEN SQLSTATE LIKE '22%' THEN 'selection_rejected' ELSE 'operation_rejected' END;
 message:=CASE code WHEN 'authentication_required' THEN 'Accedi nuovamente per continuare.'
   WHEN 'request_key_conflict' THEN 'Questa richiesta è già associata a un altro invio. Verifica lo stato prima di continuare.'
   WHEN 'not_authorized' THEN 'Questa operazione non è disponibile per il tuo accesso.'
   WHEN 'context_changed' THEN 'Lo scontro è cambiato. Rileggi lo stato e scegli di nuovo.'
   WHEN 'selection_rejected' THEN CASE SQLERRM
     WHEN 'panel_command_shape_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_command_keys_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_contract_version_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_command_values_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_identifier_invalid' THEN 'La richiesta non identifica correttamente il contesto o le scelte. Rileggi il pannello.'
     WHEN 'panel_option_identifier_invalid' THEN 'La richiesta non identifica correttamente il contesto o le scelte. Rileggi il pannello.'
     WHEN 'panel_context_version_invalid' THEN 'La richiesta non identifica correttamente il contesto o le scelte. Rileggi il pannello.'
     WHEN 'panel_duplicate_selection' THEN 'La selezione contiene elementi ripetuti o non validi. Rileggi le opzioni e scegli nuovamente.'
     WHEN 'panel_selection_invalid' THEN 'La selezione contiene elementi ripetuti o non validi. Rileggi le opzioni e scegli nuovamente.'
     WHEN 'panel_selection_not_offered' THEN 'Una delle scelte inviate non appartiene alle opzioni disponibili. Rileggi le opzioni.'
     WHEN 'panel_choice_cardinality_or_dependency_invalid' THEN 'Manca una scelta richiesta oppure sono selezionate opzioni che dipendono da una scelta diversa.'
     WHEN 'panel_input_shape_invalid' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_duplicate_input' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_input_cardinality_invalid' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_input_value_invalid' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_input_not_offered' THEN 'La richiesta contiene un campo non previsto per questa azione. Rileggi le opzioni.'
     WHEN 'panel_activity_scope_invalid' THEN 'La richiesta non appartiene allo scontro o al luogo selezionato. Riapri il pannello.'
     WHEN 'panel_role_required' THEN 'Questa dichiarazione richiede un testo di azione valido prima della conferma.'
     WHEN 'panel_multiplication_selection_incomplete' THEN 'Completa le scelte di copie, modalità, disposizione e originale prima di confermare.'
     WHEN 'panel_multiplication_selection_conflict' THEN 'Le scelte di modalità, copie, disposizione o bersaglio della Moltiplicazione sono incompatibili.'
     WHEN 'panel_multiplication_mode_invalid' THEN 'La modalità scelta e la presenza del bersaglio non sono compatibili.'
     WHEN 'panel_multiplication_formation_invalid' THEN 'Il numero di copie o la disposizione non rispettano i limiti disponibili della Moltiplicazione.'
     WHEN 'panel_multiplication_figure_outside_arena' THEN 'La disposizione porta almeno una figura fuori dai confini dell’arena.'
     WHEN 'panel_multiplication_single_movement_required' THEN 'Lo spostamento dell’originale non è disponibile. Controlla il movimento residuo e gli impedimenti.'
     WHEN 'panel_multiplication_zero_movement_capability' THEN 'È stato richiesto uno spostamento, ma l’originale è nella posizione di partenza. Rileggi le opzioni.'
     WHEN 'panel_multiplication_target_invalid' THEN 'Il bersaglio dell’assalto non è un avversario attivo in questo scontro.'
     WHEN 'panel_multiplication_target_choice_required' THEN 'Per questo bersaglio occorre selezionare una figura tra quelle offerte.'
     WHEN 'panel_multiplication_target_selection_conflict' THEN 'La selezione della figura per il bersaglio non è completa o contiene scelte incompatibili.'
     WHEN 'panel_multiplication_target_selection_invalid' THEN 'La selezione della figura per il bersaglio non è completa o contiene scelte incompatibili.'
     WHEN 'panel_attack_origin_invalid' THEN 'L’origine scelta per l’attacco non è consentita.'
     WHEN 'panel_multiplication_assault_contact_invalid' THEN 'L’assalto non può raggiungere il bersaglio dalla posizione scelta: verifica visibilità, contatto, direzione e percorso.'
     WHEN 'panel_multiplication_catalog_changed' THEN 'La tecnica non è utilizzabile con la configurazione attuale. Segnala il rifiuto allo staff.'
     WHEN 'panel_multiplication_rank_unavailable' THEN 'Non è possibile determinare le copie disponibili per il rango del personaggio. Contatta lo staff.'
     WHEN 'panel_multiplication_resources_invalid' THEN 'Non è possibile verificare le risorse disponibili per la Moltiplicazione. Contatta lo staff.'
     WHEN 'panel_multiplication_cost_snapshot_invalid' THEN 'Non è possibile verificare le risorse disponibili per la Moltiplicazione. Contatta lo staff.'
     WHEN 'panel_multiplication_npc_source_unavailable' THEN 'Questo attore non dispone di una fonte valida per usare la Moltiplicazione.'
     WHEN 'panel_multiplication_actor_kind_invalid' THEN 'Questo attore non dispone di una fonte valida per usare la Moltiplicazione.'
     WHEN 'immobilization_escape_action_conflict' THEN 'La stessa dichiarazione contiene azioni speciali incompatibili. Rileggi le opzioni e scegli una sola azione.'
     WHEN 'sabaku_clone_action_conflict' THEN 'La stessa dichiarazione contiene azioni speciali incompatibili. Rileggi le opzioni e scegli una sola azione.'
     WHEN 'panel_dispatch_not_available' THEN 'Questa azione non ha un percorso disponibile nel pannello. Segnala il rifiuto allo staff.'
     ELSE 'Le scelte non sono più valide. Rileggi le opzioni.' END
   ELSE 'Il server ha rifiutato l’operazione. Rileggi lo stato; se il problema resta, informa lo staff.' END;
 recovery:=CASE WHEN code='authentication_required' THEN 'authenticate'
   WHEN code='request_key_conflict' THEN 'contact_staff' ELSE 'refresh' END;
 RETURN jsonb_build_object('schema_version','combat-panel-error/1','status','rejected','request_key',key,
   'code',code,'message',message,'recovery',recovery);
END $function$;
DO $guard$ DECLARE o oid; BEGIN
o:=to_regprocedure('public.combat_panel_commit_v1(jsonb)'); IF o IS NULL THEN RAISE EXCEPTION 'panel_message_function_missing:%','public.combat_panel_commit_v1(jsonb)'; END IF;
IF md5(pg_get_functiondef(o)) IS DISTINCT FROM 'bd5fc563e3cd83a8912c79e9bcdce3c2' OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p WHERE p.oid=o AND pg_get_userbyid(p.proowner)='postgres' AND p.proacl::text IS NOT DISTINCT FROM '{postgres=X/postgres,authenticated=X/postgres}' AND p.prosecdef=true AND p.provolatile='v' AND p.proconfig IS NOT DISTINCT FROM ARRAY['search_path=""']::text[]) THEN RAISE EXCEPTION 'panel_message_function_drift:%','public.combat_panel_commit_v1(jsonb)'; END IF;
o:=to_regprocedure('public.combat_v2_fail(text,text,integer,uuid,jsonb)'); IF o IS NULL THEN RAISE EXCEPTION 'panel_message_function_missing:%','public.combat_v2_fail(text,text,integer,uuid,jsonb)'; END IF;
IF md5(pg_get_functiondef(o)) IS DISTINCT FROM '607dec1f81b9b0c310c91585315803f6' OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p WHERE p.oid=o AND pg_get_userbyid(p.proowner)='postgres' AND p.proacl::text IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}' AND p.prosecdef=false AND p.provolatile='v' AND p.proconfig IS NOT DISTINCT FROM ARRAY['search_path=""']::text[]) THEN RAISE EXCEPTION 'panel_message_function_drift:%','public.combat_v2_fail(text,text,integer,uuid,jsonb)'; END IF;
END $guard$;
COMMIT;
