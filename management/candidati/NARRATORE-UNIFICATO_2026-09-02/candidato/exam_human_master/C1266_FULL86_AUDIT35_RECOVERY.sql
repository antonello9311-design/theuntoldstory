-- FONTE RECOVERY35: estratto non autonomo; usare solo pacchetto integrato revisionato.
-- Disabilita la nuova diagnostica; non cambia le meccaniche.
CREATE OR REPLACE FUNCTION public.combat_panel_commit_v1(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p jsonb; uid uuid:=auth.uid(); key uuid; fp text; adapter text; reason text;
 prior combat_panel_private.request_receipts%ROWTYPE; offer combat_panel_private.offers%ROWTYPE;
 code text; message text; recovery text;
 diag_context text; diag_state text; diag_frames jsonb;
 diag35_binding jsonb; diag35_scope uuid; diag35_frames jsonb; diag35_data jsonb;
 diag35_key uuid; diag35_fingerprint text; diag35_adapter text; diag35_offer combat_panel_private.offers%ROWTYPE;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 p:=combat_panel_private.validate_command(p_command);
 PERFORM exam_human_private.assert_panel_command_v1(p); key:=(p->>'request_key')::uuid; fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF prior.request_key IS NOT NULL THEN
   IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);
 END IF;
 SELECT * INTO offer FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
 IF offer.id IS NULL THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
 IF EXISTS(SELECT 1 FROM combat_panel_private.contexts ctx
   JOIN mission_generic_owner.unified_batches ub ON ub.encounter_id=ctx.activity_id
   WHERE ctx.id=offer.context_id AND ctx.principal_user=uid
     AND ub.source_window_id IS NOT NULL AND ub.composition_kind='entry_png'
     AND ub.state IN('preparing','ready') AND ub.message_id IS NULL)
 THEN RAISE EXCEPTION 'MUF_PUBLICATION_PENDING' USING ERRCODE='42501'; END IF;
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
 IF adapter='master_v2' AND offer.kind='control' AND offer.operation='control' AND offer.source_payload->>'dispatch'='master_movement_control' THEN
   RETURN combat_panel_private.commit_master_movement_control(p); END IF;
 IF adapter='master_v2' THEN
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='aburame_control' THEN
     RETURN clan_aburame_private.commit_master_stop(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='scudo_control' THEN
     RETURN combat_v2_elemental_internal.scudo_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='suiton_control' THEN
     RETURN combat_v2_elemental_internal.suiton_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='other_control' THEN
     RETURN combat_v2_elemental_internal.other_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='hyuga_control' THEN
     RETURN clan_hyuga_private.commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='sharingan_control' THEN
     RETURN clan_innata_private.sharingan_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='sabaku_control' THEN
     RETURN clan_sabaku_private.commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='inuzuka_control' THEN RETURN clan_inuzuka_private.commit_master_control(p); END IF; IF offer.kind='control' AND offer.source_payload->>'dispatch'='companion_control' THEN
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
     WHEN 'panel_choice_cardinality_or_dependency_invalid' THEN 'Manca una scelta richiesta, sono selezionate troppe opzioni oppure alcune scelte sono incompatibili. Rileggi le opzioni e correggi la selezione.'
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
 -- Diagnostica privata della sola sessione Staff autorizzata. Nessun testo della richiesta.
 GET STACKED DIAGNOSTICS diag_context = PG_EXCEPTION_CONTEXT, diag_state = RETURNED_SQLSTATE;
 BEGIN
  IF uid IS NOT NULL AND key IS NOT NULL AND offer.id IS NOT NULL
   AND offer.principal_user=uid AND public.is_staff()
   AND ((offer.kind='action' AND offer.operation='declare')
    OR (offer.kind='control' AND offer.operation='control' AND adapter='ordinary_v2'
     AND EXISTS (SELECT 1 FROM combat_consumer_private.offers diagnostic_source
       WHERE diagnostic_source.id=(offer.source_payload->>'source_offer_id')::uuid
        AND diagnostic_source.session_id=(offer.source_payload->>'source_activity_id')::uuid
        AND diagnostic_source.operation='control'
        AND diagnostic_source.source_payload->>'aburame_operation'='release_stop'))
    OR (offer.kind='defense' AND offer.operation='defend' AND adapter='ordinary_v2'
     AND EXISTS (
      SELECT 1 FROM combat_consumer_private.offers src
      JOIN public.combat_v2_actors defender ON defender.id=offer.actor_id
      WHERE src.id=(offer.source_payload->>'source_offer_id')::uuid
       AND src.offer_kind='defense' AND src.operation='defend'
       AND (src.source_payload#>>'{intent,reaction}' IN ('parata','schivata','nessuna')
        OR (src.source_payload->>'aburame_clone'='aburame-clone/1'
         AND src.source_payload#>>'{intent,reaction}'='tecnica'
         AND src.source_payload#>>'{intent,ability_source}'='clan'
         AND src.source_payload#>>'{intent,ability_id}'='b9195ceb-74de-4251-95af-fe5c1bdaf485'))
       AND src.session_id=defender.session_id
       AND src.principal_character_id=defender.character_id
       AND src.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid)))
   AND adapter IN ('ordinary_v2','master_v2')
   AND EXISTS (
    SELECT 1 FROM combat_panel_private.contexts c
    JOIN public.combat_v2_actors a ON a.id=offer.actor_id AND a.controller_user=uid
    JOIN public.combat_v2_sessions s ON s.id=a.session_id
    WHERE c.id=offer.context_id AND c.principal_user=uid AND c.command_actor_id=a.id
     AND s.id='bff182d1-7027-4519-a546-65e28d991716'::uuid
     AND c.activity_id=s.id
     AND c.id='8b72e8cf-c522-4b88-bc64-a51c83bddcb4'::uuid
     AND c.round_id='c880d549-179d-414d-ad25-a987c999af87'::uuid
     AND c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
     AND s.location_id=c.location_id
     AND c.activity_kind=adapter
     AND a.id IN ('ff130a12-d6df-4e11-8add-b3087b42aab8'::uuid,'da8eebcd-2d79-49c2-b5ec-c7ea4fbc02d8'::uuid)
     AND NOT public.combat_v2_values_written(s.id))
   AND combat_panel_private.access_reason('0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid,adapter) IS NULL
  THEN
   SELECT coalesce(jsonb_agg(jsonb_build_object('function',x.parts[1],'line',x.parts[2]::integer) ORDER BY x.ord),'[]'::jsonb)
    INTO diag_frames
    FROM (SELECT m.parts,m.ord FROM regexp_matches(diag_context,
     'PL/pgSQL function ([a-z_][a-z0-9_]*(?:[.][a-z_][a-z0-9_]*)?)[(][^\n]*[)] line ([0-9]+)',
     'g') WITH ORDINALITY AS m(parts,ord) LIMIT 16) x;
   INSERT INTO public.combat_v2_events(scope_id,request_key,operation_kind,request_fingerprint,
    caller,status,error_sanitized,completed_at)
   VALUES('36651303-0795-4b3e-832d-e2ae6d070b0c'::uuid,key,'staff_panel_rejection_diagnostic',
    public.combat_v2_sha256(jsonb_build_object('request_key',key,'sqlstate',diag_state,'frames',diag_frames)),
    NULL,'fallita',jsonb_build_object('schema','staff-panel-diagnostic/1','sqlstate',diag_state,'frames',diag_frames),clock_timestamp())
   ON CONFLICT (scope_id,request_key) DO NOTHING;
  END IF;
 EXCEPTION WHEN OTHERS THEN
  -- Un errore del solo audit non sostituisce il rifiuto pubblico originale.
  NULL;
 END;
 BEGIN
  -- Audit35: letture e scrittura diagnostiche isolate, dopo il rollback della richiesta.
  -- Il guard costante racchiude TUTTO il nuovo audit; la recovery lo disattiva integralmente.
  IF FALSE THEN
   IF uid IS NOT NULL AND p IS NOT NULL AND jsonb_typeof(p)='object' AND public.is_staff() THEN
    diag35_key:=(p->>'request_key')::uuid;
    diag35_fingerprint:=public.combat_v2_sha256(p);
    SELECT * INTO diag35_offer FROM combat_panel_private.offers
     WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
    diag35_adapter:=diag35_offer.source_payload->>'adapter';
    IF diag35_key IS NOT NULL AND diag35_offer.id IS NOT NULL
     AND diag35_offer.principal_user=uid AND diag35_fingerprint~'^[0-9a-f]{64}$'
     AND diag35_adapter IN ('ordinary_v2','master_v2')
     AND combat_panel_private.access_reason('0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid,diag35_adapter) IS NULL
     AND combat_consumer_private.staff_test_allowed('0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid,ARRAY[uid]::uuid[],false)
    THEN
     SELECT jsonb_build_object('master_session_id',ds.master_session_id,'encounter_id',ds.id,
       'context_id',dc.id,'round_id',dc.round_id,'actor_id',da.id,'context_version',dc.context_version)
     INTO diag35_binding
     FROM combat_panel_private.contexts dc
     JOIN public.combat_v2_actors da ON da.id=diag35_offer.actor_id AND da.controller_user=uid
     JOIN public.combat_v2_sessions ds ON ds.id=da.session_id
     JOIN public.combat_v2_rounds dr ON dr.id=dc.round_id AND dr.session_id=ds.id
     JOIN public.locations dl ON dl.id=ds.location_id AND dl.is_active AND dl.is_test
     WHERE dc.id=diag35_offer.context_id AND dc.principal_user=uid AND dc.command_actor_id=da.id
      AND dc.activity_id=ds.id AND dc.activity_kind=diag35_adapter
      AND dc.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND dl.id=dc.location_id
      AND combat_panel_private.uses_simulated_pools(ds.id) IS TRUE
      AND public.combat_v2_values_written(ds.id) IS FALSE;
     IF diag35_binding IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(jsonb_build_object('function',df.parts[1],'line',df.parts[2]::integer) ORDER BY df.ord),'[]'::jsonb)
      INTO diag35_frames
      FROM (SELECT dm.parts,dm.ord FROM regexp_matches(diag_context,
       'PL/pgSQL function ([a-z_][a-z0-9_]*(?:[.][a-z_][a-z0-9_]*)?)[(][^\n]*[)] line ([0-9]+)',
       'g') WITH ORDINALITY AS dm(parts,ord) LIMIT 16) df;
      diag35_scope:=mission_ai_service_owner.uuid5((diag35_binding->>'encounter_id')::uuid,'staff-panel-rejection-diagnostic/2');
      diag35_data:=jsonb_build_object('schema','staff-panel-diagnostic/2','sqlstate',diag_state,
        'frames',diag35_frames,'binding',diag35_binding,'command_sha256',diag35_fingerprint);
      INSERT INTO public.combat_v2_events(scope_id,request_key,operation_kind,request_fingerprint,
       caller,control_version,status,error_sanitized,completed_at)
      VALUES(diag35_scope,diag35_key,'staff_panel_rejection_diagnostic',public.combat_v2_sha256(diag35_data),
       uid,(diag35_binding->>'context_version')::bigint,'fallita',diag35_data,clock_timestamp())
      ON CONFLICT (scope_id,request_key) DO NOTHING;
     END IF;
    END IF;
   END IF;
  END IF;
 EXCEPTION WHEN OTHERS THEN
  -- Un errore dell'audit corrente non altera né il rifiuto originale né l'audit storico.
  NULL;
 END;
 RETURN jsonb_build_object('schema_version','combat-panel-error/1','status','rejected','request_key',key,
   'code',code,'message',message,'recovery',recovery);
END $function$;
