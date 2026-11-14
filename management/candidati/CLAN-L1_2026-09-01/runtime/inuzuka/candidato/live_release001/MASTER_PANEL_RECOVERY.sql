BEGIN;
SET LOCAL lock_timeout='3s';
DO $pre$ BEGIN
IF md5(pg_get_functiondef('public.combat_panel_commit_v1(jsonb)'::regprocedure)) IS DISTINCT FROM '32ea930f6b5b4652730e699e14ae4272' THEN RAISE EXCEPTION 'inuzuka_panel_pre_0'; END IF;
IF md5(pg_get_functiondef('combat_panel_private.master_projection(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '30aa9f3303663b82c69f33b6ddb621fa' THEN RAISE EXCEPTION 'inuzuka_panel_pre_1'; END IF;
IF md5(pg_get_functiondef('clan_inuzuka_private.master_control_offers(uuid,bigint)'::regprocedure)) IS DISTINCT FROM '6a993eec4524f7735197693fbcf48f43' THEN RAISE EXCEPTION 'inuzuka_panel_pre_2'; END IF;
END $pre$;
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
 IF adapter IN ('ordinary_v2','master_v2') AND offer.kind='control' AND offer.operation='control'
   AND offer.source_payload->>'dispatch'='nara_possession_control' THEN
   RETURN combat_panel_private.nara_commit_control_v1(p); END IF;
 IF adapter='ordinary_v2' AND offer.kind='control' AND offer.operation='control' AND offer.source_payload->>'dispatch'='pg_movement' THEN
   RETURN combat_panel_private.commit_pg_movement(p); END IF;
 IF adapter='ordinary_v2' THEN RETURN combat_panel_private.commit_ordinary(p); END IF;
 IF adapter='master_v2' AND offer.kind='control' AND offer.operation='control' AND offer.source_payload->>'dispatch'='master_movement_control' THEN
   RETURN combat_panel_private.commit_master_movement_control(p); END IF;
 IF adapter='master_v2' THEN
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='hoki_control' THEN
     RETURN clan_hoki_private.commit_master_body(p); END IF;
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
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='akimichi_form' THEN
     RETURN clan_akimichi_private.commit_master_form(p);
   END IF;
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
  IF TRUE THEN
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
END $function$
;
CREATE OR REPLACE FUNCTION combat_panel_private.master_projection(p_location uuid, p_actor uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE multiplication jsonb; src jsonb; c combat_panel_private.contexts%ROWTYPE; sid uuid; mid uuid; rid uuid; actor uuid;
 is_master boolean; is_admin boolean; is_test boolean; simulated boolean; policy text; phase text; phase_label text;
 controlled jsonb:='[]'; roster jsonb:='[]'; item jsonb; resources jsonb; map_view jsonb:=null;
 companion_view jsonb:=null; sabaku_view jsonb:=null; narrative_view jsonb:=null; narrative_meta jsonb; meta public.combat_v2_actors%ROWTYPE;
 actor_state text; distance numeric; body_only boolean; due boolean; selected boolean;
BEGIN
 src:=public.master_v2_ui_state(p_location)->'data';
 IF src->>'publication_state'='pending' AND src->>'reason_code'='REGIA_FATO_PENDING' THEN
  RETURN jsonb_build_object('schema_version','combat-panel/1','status','blocked','reason_code','REGIA_FATO_PENDING',
   'context',NULL,'viewer',jsonb_build_object('command_actor_id',NULL,'controlled_actors','[]'::jsonb,
    'is_master',false,'is_admin',coalesce((src#>>'{viewer,is_admin}')::boolean,false),'can_command',false),
   'actors','[]'::jsonb,'map',NULL,'offers','[]'::jsonb,'movement_explanations',NULL,'companion',NULL,
   'sabaku_transport',NULL,'aburame_colony',NULL,'multiplication',NULL,'narrative',NULL,'receipt',NULL,'round_details',NULL);
 END IF;
 is_master:=coalesce((src#>>'{viewer,is_master}')::boolean,false);
 is_admin:=coalesce((src#>>'{viewer,is_admin}')::boolean,false);
 mid:=(src#>>'{master,id}')::uuid;
 IF mid IS NULL THEN is_master:=coalesce(public.master_v2_is_master(exam_regia_private.current_principal()),false); END IF; sid:=(src#>>'{encounter,id}')::uuid; rid:=(src#>>'{round,id}')::uuid;
 SELECT coalesce(l.is_test,false) INTO is_test FROM public.locations l WHERE l.id=p_location AND l.is_active;
 IF NOT FOUND THEN RAISE EXCEPTION 'panel_location_not_available' USING ERRCODE='42501'; END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(src->'actors') LOOP
   IF coalesce((item->>'mine')::boolean,false) AND EXISTS(SELECT 1 FROM public.combat_v2_actors
     WHERE id=(item->>'id')::uuid AND session_id=sid AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL) THEN
     controlled:=controlled||jsonb_build_array(jsonb_build_object('actor_id',item->'id','label',item->'name'));
   END IF;
 END LOOP;
 actor:=p_actor;
 IF actor IS NULL AND NOT(is_master OR is_admin) AND jsonb_array_length(controlled)>0 THEN
   actor:=(controlled#>>'{0,actor_id}')::uuid;
 END IF;
 IF actor IS NOT NULL AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(controlled) AS a(value)
   WHERE value->>'actor_id'=actor::text) THEN
   RAISE EXCEPTION 'panel_actor_not_controlled' USING ERRCODE='42501'; END IF;
 phase:=CASE WHEN src#>>'{master,stato}'='sospesa' OR src#>>'{encounter,state}'='sospeso' THEN 'suspended'
   WHEN sid IS NULL OR rid IS NULL THEN 'setup'
   WHEN NOT EXISTS(SELECT 1 FROM combat_spatial.arena_instances WHERE encounter_id=sid)
     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d JOIN public.combat_v2_rounds r ON r.id=d.round_id WHERE r.session_id=sid) THEN 'setup'
   ELSE CASE src#>>'{round,phase}' WHEN 'raccolta_azioni' THEN 'action' WHEN 'raccolta_difese' THEN 'defense'
     WHEN 'congelato' THEN 'review' WHEN 'valutazione' THEN 'review' WHEN 'risoluzione' THEN 'resolving'
     WHEN 'risolto' THEN 'resolved' WHEN 'narrazione' THEN 'resolved' WHEN 'narrato' THEN 'resolved' ELSE NULL END END;
 IF phase IS NULL THEN RAISE EXCEPTION 'panel_master_phase_unsupported' USING ERRCODE='22023'; END IF;
 phase_label:=CASE phase WHEN 'setup' THEN 'Preparazione dello scontro' WHEN 'action' THEN 'Raccolta delle azioni'
   WHEN 'defense' THEN 'Raccolta delle difese' WHEN 'review' THEN 'Valutazione del Master'
   WHEN 'resolving' THEN 'Risoluzione in corso' WHEN 'resolved' THEN 'Esito del round' ELSE 'Scontro sospeso' END;
 IF rid IS NOT NULL AND combat_panel_private.human_duel_round(rid) THEN
   phase_label:=CASE phase WHEN 'action' THEN 'Duello a iniziativa · turno di attacco'
     WHEN 'defense' THEN 'Duello a iniziativa · risposta difensiva' ELSE phase_label END;
 END IF;
 simulated:=CASE WHEN sid IS NULL THEN is_test ELSE NOT public.combat_v2_values_written(sid) END;
 policy:=CASE WHEN exam_human_private.execution_session_v1(mid) THEN 'exam_protected_no_persistent_resources_v1' WHEN exam_regia_private.is_bound(sid) THEN 'exam_protected_no_persistent_resources_v1' WHEN is_test THEN 'staff_test_no_persistent_resources_v1' ELSE 'master_game_resources_v1' END;
 IF sid IS NOT NULL AND (actor IS NOT NULL OR is_master OR is_admin) THEN
   map_view:=combat_panel_private.master_map(sid,actor);
 END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(src->'actors') LOOP
   SELECT * INTO STRICT meta FROM public.combat_v2_actors WHERE id=(item->>'id')::uuid AND session_id=sid;
   body_only:=meta.companion_id IS NOT NULL;
   actor_state:=CASE item->>'state' WHEN 'attivo' THEN 'active' WHEN 'fuori' THEN 'out' WHEN 'ritirato' THEN 'withdrawn' ELSE NULL END;
   IF actor_state IS NULL THEN RAISE EXCEPTION 'panel_actor_state_unsupported' USING ERRCODE='22023'; END IF;
   selected:=actor IS NOT NULL AND meta.id=actor;
   resources:=combat_panel_private.participant_resources(sid,meta.id,simulated);
   distance:=NULL;
   IF jsonb_typeof(map_view->'pov')='object' AND NOT selected THEN
     SELECT round(combat_spatial.distance_m((map_view#>>'{pov,x_m}')::numeric,(map_view#>>'{pov,y_m}')::numeric,
       (value->>'x_m')::numeric,(value->>'y_m')::numeric),2) INTO distance
       FROM jsonb_array_elements(map_view->'actors') WHERE value->>'actor_id'=meta.id::text;
   END IF;
   -- Il compagno resta passivo: risponde il controllore tramite le stesse
   -- difese ammesse dal consumer, anche con Fili recisi (Nessuna difesa).
   due:=NOT body_only AND actor_state='active' AND phase='defense'
     AND (is_master OR is_admin OR exam_regia_private.actor_principal(meta.id,meta.controller_user)=exam_regia_private.current_principal())
     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d
       WHERE d.round_id=rid AND d.actor_id=meta.id AND d.kind IN ('difesa','nessuna'))
     AND EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t
       WHERE t.round_id=rid AND t.state='attesa_difesa' AND (
         t.target_actor_id=meta.id OR (
           EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(map_view->'actors','[]')) v
             WHERE v->>'actor_id'=t.target_actor_id::text)
           AND clan_marionettisti_private.defends_body(meta.id,t.target_actor_id,'nessuna'))));
   roster:=roster||jsonb_build_array(jsonb_build_object('actor_id',meta.id,
     'kind',CASE WHEN body_only THEN 'companion' ELSE meta.actor_kind END,'body_only',body_only,
     'display_name',CASE WHEN body_only THEN to_jsonb('Marionetta'::text) ELSE item->'name' END,'team',item->'team','state',actor_state,'mine',selected,
     'action_due',NOT body_only AND actor_state='active' AND phase='action' AND combat_panel_private.human_duel_turn_allowed(rid,meta.id) AND mission_generic_owner.unified_turn_allowed(rid,meta.id) AND NOT coalesce((item->>'has_action')::boolean,false),
     'defense_due',due,'resources',resources,'distance_from_viewer_m',distance));
 END LOOP;
 IF sid IS NOT NULL AND rid IS NOT NULL THEN
   narrative_meta:=combat_panel_private.narrative_details(p_location,sid,rid);
   narrative_view:=jsonb_build_object('schema_version','combat-panel-narrative/1','activity_id',sid,'round_id',rid,
     'mode','human','state',CASE WHEN narrative_meta#>>'{last_published,round_id}'=rid::text THEN 'published'
       WHEN phase='resolved' THEN 'waiting' ELSE 'idle' END,'reason_code',null,
     'report_id',narrative_meta->'report_id','report_sha256',narrative_meta->'report_sha256',
     'last_published',narrative_meta->'last_published');
 END IF;
 multiplication:=combat_panel_private.multiplication_view(p_location,map_view->'actors');
 map_view:=combat_panel_private.multiplication_mask_map(map_view,multiplication);
 roster:=combat_panel_private.multiplication_mask_roster(roster,multiplication);
 -- Versione fissa per il fingerprint: non dipende dalla versione che genera.
 companion_view:=combat_panel_private.master_companion_projection(actor);
 sabaku_view:=clan_sabaku_private.master_panel_projection(actor,1);
 c:=combat_panel_private.refresh_context(p_location,actor,
   CASE WHEN coalesce(sid,mid) IS NULL THEN NULL ELSE 'master_v2' END,coalesce(sid,mid),rid,
   (map_view->>'map_version')::bigint,(jsonb_build_object('participant_resources',roster,'multiplication',multiplication,'is_master',is_master,'is_admin',is_admin,'source',src,'map',map_view,'narrative',narrative_view,'sabaku',sabaku_view,'companion',companion_view,
     -- Stato nativo stabile: il preset cambia le offerte senza consumare una principale.
     -- Solo fingerprint interno; nessun dato aggiunto alla risposta del viewer.
     'other_control_state',(SELECT coalesce(jsonb_agg(jsonb_build_object('technique_id',z.technique_id,'controller_version',z.controller_version,'receipt_sha256',z.receipt_sha256) ORDER BY z.technique_id,z.controller_version),'[]'::jsonb) FROM combat_v2_elemental_internal.other_staff_receipts z WHERE z.actor_id=actor AND z.session_id=sid),
     'suiton_control_state',(SELECT coalesce(jsonb_agg(jsonb_build_object(
       'technique_id',s.technique_id,'controller_version',s.controller_version,'receipt_sha256',s.receipt_sha256)
       ORDER BY s.technique_id,s.controller_version),'[]'::jsonb)
       FROM combat_v2_elemental_internal.suiton_staff_receipts s WHERE s.actor_id=actor AND s.session_id=sid),
     'scudo_control_state',(SELECT coalesce(jsonb_agg(jsonb_build_object(
       'technique_id',s.technique_id,'controller_version',s.controller_version,'receipt_sha256',s.receipt_sha256) ORDER BY s.technique_id,s.controller_version),'[]'::jsonb) FROM combat_v2_elemental_internal.scudo_staff_receipts s WHERE s.actor_id=actor AND s.session_id=sid),
     'hyuga_control_state',jsonb_build_object(
       'profiles',(SELECT coalesce(jsonb_agg(jsonb_build_object('profile_version',h.profile_version,'active',h.is_active)
           ORDER BY h.profile_version,h.is_active,h.created_request),'[]'::jsonb)
         FROM clan_hyuga_private.staff_profiles h WHERE h.actor_id=actor AND h.session_id=sid),
       'offensive_receipts',(SELECT count(*) FROM clan_hyuga_private.offensive_staff_receipts h
         WHERE h.actor_id=actor AND h.session_id=sid),
       'byakugan',(SELECT coalesce(jsonb_agg(jsonb_build_object('technique_id',h.technique_id,'active',h.active,'state_version',h.state_version)ORDER BY h.technique_id),'[]'::jsonb)
         FROM clan_innata_combat_private.combat_state h WHERE h.actor_id=actor AND h.session_id=sid AND h.technique_id IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid)))) ||
     -- Il preset Katon cambia le offerte disponibili nella simulazione Staff.
     CASE WHEN p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND simulated THEN
       jsonb_strip_nulls(jsonb_build_object('staff_katon_receipt',(
         SELECT f.receipt_sha256
         FROM clan_uchiha_private.fireball_staff_receipts f
         JOIN public.combat_v2_actors a ON a.id=f.actor_id AND a.session_id=f.session_id
           AND a.controller_user=f.controller_user AND a.controller_version=f.controller_version
         JOIN clan_hyuga_private.staff_profiles h ON h.actor_id=f.actor_id AND h.session_id=f.session_id
           AND h.profile_version='sharingan-l1/1' AND h.is_active AND h.created_request=f.common_profile_request
         WHERE f.actor_id=actor AND f.session_id=sid
       )))
     ELSE '{}'::jsonb END));
 RETURN clan_hoki_private.panel_projection(clan_inuzuka_private.master_projection(
   clan_sabaku_private.clone_attach_map(jsonb_build_object('schema_version','combat-panel/1','status','ready','reason_code',null,
   'context',jsonb_build_object('activity_id',coalesce(sid,mid),'activity_kind',c.activity_kind,
     'location_id',p_location,'round_id',rid,'round_no',to_jsonb(exam_regia_private.logical_round_no(rid)),'phase',phase,'phase_label',phase_label,
     'version',c.context_version,'scene_version',c.scene_version,'policy_id',policy,'simulated',simulated),
   'viewer',jsonb_build_object('command_actor_id',actor,'controlled_actors',controlled,'is_master',is_master,
     'is_admin',is_admin,'can_command',is_master OR is_admin OR (actor IS NOT NULL AND (phase='defense' OR (phase='action' AND combat_panel_private.human_duel_turn_allowed(rid,actor) AND mission_generic_owner.unified_turn_allowed(rid,actor))))),
   'actors',roster,'map',map_view,'offers','[]'::jsonb,'movement_explanations',null,
   'multiplication',multiplication,'companion',companion_view,'sabaku_transport',CASE WHEN sabaku_view IS NULL THEN NULL
     ELSE jsonb_set(sabaku_view,'{context_version}',to_jsonb(c.context_version)) END,'narrative',narrative_view,
   'round_details',combat_panel_private.round_details_from_source(src,roster),'receipt',null))));
END $function$
;
CREATE OR REPLACE FUNCTION clan_inuzuka_private.master_control_offers(p_context uuid, p_expected bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE;cc public.character_companions%ROWTYPE;placement jsonb;
 ninken uuid;caps jsonb;item jsonb;move jsonb;moves jsonb:='[]';cap combat_spatial.movement_capabilities%ROWTYPE;
 state clan_innata_combat_private.combat_state%ROWTYPE;scope jsonb;
 oid uuid;direction_group uuid;direction_id uuid;distance_group uuid;direction text;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.command_actor_id IS NULL OR c.round_id IS NULL
  OR NOT clan_inuzuka_private.owner_allowed(c.command_actor_id) THEN RETURN;END IF;
 IF clan_inuzuka_private.staff_profile_needed(c.command_actor_id) THEN
  PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Prepara profilo Inuzuka',false,
   jsonb_build_object('adapter','master_v2','dispatch','inuzuka_control','inuzuka_operation','staff_profile'));
  RETURN;
 END IF;
 BEGIN scope:=clan_inuzuka_private.quattro_scope(c.command_actor_id);
 EXCEPTION WHEN insufficient_privilege THEN RETURN;END;
 state:=clan_innata_private.combat_state_read(c.command_actor_id,'c11ecd52-43cd-479b-8d5d-08187beba56e');
 IF state.active THEN
  PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Disattiva Quattro Zampe · gratuito',false,
   jsonb_build_object('adapter','master_v2','dispatch','inuzuka_control','inuzuka_operation','deactivate','expected_state',state.state_version));
 ELSIF coalesce((SELECT (a.mechanics_snapshot->>'chakra')::integer FROM public.combat_v2_actors a WHERE a.id=c.command_actor_id),0)>=5
  AND clan_innata_private.combat_activation_window(c.command_actor_id,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid) THEN
  PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Attiva Quattro Zampe · 5 chakra',false,
   jsonb_build_object('adapter','master_v2','dispatch','inuzuka_control','inuzuka_operation','activate','expected_state',state.state_version));
 END IF;
 SELECT companion.* INTO cc FROM public.character_companions companion JOIN public.combat_v2_actors owner
  ON owner.character_id=companion.character_id WHERE owner.id=c.command_actor_id
  AND companion.kind='cane_ninja' AND companion.is_active ORDER BY companion.created_at,companion.id LIMIT 1;
 IF cc.id IS NULL THEN RETURN;END IF;
 ninken:=clan_inuzuka_private.ninken_actor(c.command_actor_id);
 IF ninken IS NULL THEN
  placement:=clan_inuzuka_private.placement(c.command_actor_id);IF placement IS NULL THEN RETURN;END IF;
  PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Schiera il ninken',true,
   jsonb_build_object('adapter','master_v2','dispatch','inuzuka_control','inuzuka_operation','bind',
    'companion_id',cc.id,'placement',placement,'companion_context_required',true));
  RETURN;
 END IF;
 caps:=clan_inuzuka_private.movement_options(c.command_actor_id);
 FOR item IN SELECT value FROM jsonb_array_elements(caps) LOOP
  SELECT * INTO STRICT cap FROM combat_spatial.movement_capabilities WHERE capability_id=(item->>'option_id')::uuid;
  direction:=CASE WHEN cap.end_x_m=cap.start_x_m AND cap.end_y_m<cap.start_y_m THEN 'up'
   WHEN cap.end_x_m=cap.start_x_m AND cap.end_y_m>cap.start_y_m THEN 'down'
   WHEN cap.end_y_m=cap.start_y_m AND cap.end_x_m<cap.start_x_m THEN 'left'
   WHEN cap.end_y_m=cap.start_y_m AND cap.end_x_m>cap.start_x_m THEN 'right' END;
  IF direction IS NULL THEN RAISE EXCEPTION 'inuzuka_direction_invalid' USING ERRCODE='22023';END IF;
  moves:=moves||jsonb_build_array(jsonb_build_object('capability_id',cap.capability_id,
   'direction',direction,'distance_m',item->'distance_m'));
 END LOOP;
 IF jsonb_array_length(moves)=0 THEN RETURN;END IF;
 oid:=combat_panel_private.create_offer(c.id,c.context_version,'control','control','Muovi il ninken',true,
  jsonb_build_object('adapter','master_v2','dispatch','inuzuka_control','inuzuka_operation','move',
   'companion_id',cc.id,'ninken_actor_id',ninken,'companion_context_required',true));
 direction_group:=combat_panel_private.add_group(oid,'Direzione','movement_direction','single',1,1);
 FOREACH direction IN ARRAY ARRAY['up','right','down','left'] LOOP
  IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(moves) WHERE value->>'direction'=direction) THEN CONTINUE;END IF;
  direction_id:=combat_panel_private.add_choice(direction_group,CASE direction WHEN 'up' THEN 'Su'
   WHEN 'right' THEN 'Destra' WHEN 'down' THEN 'Giù' ELSE 'Sinistra' END,
   jsonb_build_object('direction',direction),NULL,direction);
  distance_group:=combat_panel_private.add_group(oid,'Distanza','movement_distance','single',1,1,direction_id);
  FOR move IN SELECT DISTINCT ON ((value->>'distance_m')::numeric) value FROM jsonb_array_elements(moves)
   WHERE value->>'direction'=direction ORDER BY (value->>'distance_m')::numeric,value->>'capability_id' LOOP
   PERFORM combat_panel_private.add_choice(distance_group,(move->>'distance_m')::numeric::integer::text||' m',
    jsonb_build_object('movement_capability_id',move->'capability_id'),(move->>'distance_m')::numeric,direction);
  END LOOP;
 END LOOP;
END $function$
;
DO $post$ BEGIN
IF md5(pg_get_functiondef('public.combat_panel_commit_v1(jsonb)'::regprocedure)) IS DISTINCT FROM '7f64f000fd247e63ac77217514543d44' THEN RAISE EXCEPTION 'inuzuka_panel_post_0'; END IF;
IF md5(pg_get_functiondef('combat_panel_private.master_projection(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '02f5e95a537eab2754fed7abdd1c657a' THEN RAISE EXCEPTION 'inuzuka_panel_post_1'; END IF;
IF md5(pg_get_functiondef('clan_inuzuka_private.master_control_offers(uuid,bigint)'::regprocedure)) IS DISTINCT FROM '04f5cdd09028933f289793212a591294' THEN RAISE EXCEPTION 'inuzuka_panel_post_2'; END IF;
END $post$;
COMMIT;
