BEGIN;
DO $guard$ BEGIN
 IF EXISTS(SELECT 1 FROM exam_regia_private.ordinary_sessions o JOIN exam_regia_private.bindings b ON b.prova_id=o.prova_id WHERE b.state<>'closed') THEN
 RAISE EXCEPTION 'ordinary_reward_recovery_active_session'; END IF;
END $guard$;
UPDATE exam_regia_private.ordinary_gate SET ordinary_enabled=false;
CREATE OR REPLACE FUNCTION mission_exam_private.bind_class_session()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE req mission_exam_private.open_requests%ROWTYPE; cap integer;
BEGIN
  SELECT * INTO req FROM mission_exam_private.open_requests
    WHERE transaction_id=txid_current() AND owner_user=NEW.started_by AND class_session_id IS NULL FOR UPDATE;
  IF NOT FOUND THEN RETURN NEW; END IF;
  IF req.exam_regia_admission_id IS NOT NULL THEN
    IF NOT EXISTS(SELECT 1 FROM exam_regia_private.admissions a WHERE a.id=req.exam_regia_admission_id
      AND exam_regia_private.native_open_allowed(req.owner_user,a.character_id,NEW.location_id)) THEN
      RAISE EXCEPTION 'exam_regia_native_open_scope' USING ERRCODE='42501'; END IF;
    UPDATE mission_exam_private.open_requests SET class_session_id=NEW.id WHERE request_id=req.request_id;
    SELECT rt.provider_call_cap INTO STRICT cap FROM exam_regia_private.runtime rt JOIN mission_exam_private.release_gate gate ON gate.singleton AND gate.enabled WHERE rt.singleton AND rt.enabled;
    INSERT INTO mission_exam_private.protected_sessions(class_session_id,owner_user,character_id,location_id,request_id,provider_call_cap,policy_version)
    SELECT NEW.id,req.owner_user,a.character_id,NEW.location_id,req.request_id,cap,'exam_protected_no_persistent_resources_v1'
    FROM exam_regia_private.admissions a WHERE a.id=req.exam_regia_admission_id;
    RETURN NEW;
  END IF;
  IF auth.uid() IS DISTINCT FROM req.owner_user
    OR NEW.location_id<>'df83cd65-b13d-49d6-ad77-a44f35d5ea00'::uuid THEN
    RAISE EXCEPTION 'mission_session_open_scope' USING ERRCODE='42501'; END IF;
  SELECT coalesce((SELECT rt.provider_call_cap FROM exam_regia_private.runtime rt
    WHERE rt.singleton AND rt.enabled AND EXISTS(SELECT 1 FROM exam_regia_private.admissions ad
     WHERE ad.owner_user=req.owner_user AND ad.character_id='f335b077-34a1-41c3-94aa-58ec674b649b'::uuid
     AND ad.location_id=NEW.location_id AND ad.surface='konoha' AND ad.enabled AND ad.expires_at>clock_timestamp())),g.provider_call_cap)
    INTO STRICT cap FROM mission_exam_private.release_gate g WHERE g.singleton AND g.enabled;
  INSERT INTO mission_exam_private.protected_sessions
    (class_session_id,owner_user,character_id,location_id,request_id,provider_call_cap)
    VALUES(NEW.id,req.owner_user,'f335b077-34a1-41c3-94aa-58ec674b649b',NEW.location_id,req.request_id,cap);
  UPDATE mission_exam_private.open_requests SET class_session_id=NEW.id WHERE request_id=req.request_id;
  RETURN NEW;
END $function$;
CREATE OR REPLACE FUNCTION exam_regia_private.protected_binding_valid(p_class uuid,p_owner uuid,p_character uuid,p_location uuid)
RETURNS boolean LANGUAGE sql VOLATILE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT EXISTS(SELECT 1 FROM exam_regia_private.bindings b JOIN exam_regia_private.admissions a ON a.id=b.admission_id
 WHERE b.class_session_id=p_class AND b.owner_user=p_owner AND b.character_id=p_character AND b.location_id=p_location
 AND (a.owner_user,a.character_id,a.location_id)=(b.owner_user,b.character_id,b.location_id))
 OR EXISTS(SELECT 1 FROM mission_exam_private.open_requests req JOIN exam_regia_private.admissions a ON a.id=req.exam_regia_admission_id
 WHERE req.class_session_id=p_class AND req.owner_user=p_owner AND req.transaction_id=txid_current()
 AND (a.owner_user,a.character_id,a.location_id)=(p_owner,p_character,p_location)
 AND exam_regia_private.native_open_allowed(p_owner,p_character,p_location));
$fn$;
CREATE OR REPLACE FUNCTION public.esame_avvia(p_location uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_loc record; v_char record; v_lesson record; v_agent record;
  v_village text; v_steps int; v_sess uuid; v_aperta uuid;
  v_tot_reg int; v_done_reg int;
  -- [038-R2] la deroga di collaudo: si calcola UNA volta, subito dopo
  -- aver letto il luogo, e da lì in poi si legge soltanto. Ricalcolarla
  -- nei due punti in cui serve vorrebbe dire due letture della stessa
  -- cosa, che è il modo in cui questa famiglia di difetti si riproduce.
  v_deroga boolean := false;
  -- [002] deroga di collaudo completa: Test Room + staff.
  v_test_staff boolean := false;
begin
  if v_uid is null then raise exception 'non autenticato'; end if;

  select id, name, rank, village into v_char
    from public.characters where user_id = v_uid limit 1;
  if v_char.id is null then raise exception 'Ti serve un personaggio'; end if;

  select * into v_loc from public.locations
   where id = p_location
     and (is_active
          or (id = '1ed40f52-7bff-4aa1-85a1-28b24f5804b2'::uuid
              and v_uid = 'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid));

  -- ═══ [038-R2 · decisione PM 1] LA DEROGA DI COLLAUDO ═════════════════════
  -- Tre condizioni in `and`, e nessuna è ridondante:
  --   · il luogo esiste ed è ATTIVO — è già nella `select` qui sopra, e la
  --     deroga non la tocca: un luogo spento resta spento;
  --   · `is_test = true` — una riga sola in tutto il database, la Test Room;
  --   · `is_staff()` — che a sua volta pretende `auth.uid()` non nullo, quindi
  --     un utente autenticato con `profiles.role in ('master','admin')`.
  --
  -- ⚠️ `is_staff()` è `SECURITY DEFINER` e legge `auth.uid()`: dentro questa
  --    funzione, anch'essa `SECURITY DEFINER`, `auth.uid()` continua a leggere
  --    il JWT del chiamante e non l'identità del proprietario. È il motivo per
  --    cui la deroga NON si apre a una chiamata di servizio senza `sub` — e il
  --    banco lo prova, perché «un GRANT non è una capacità».
  v_deroga := (coalesce(v_loc.is_test, false) and (public.is_staff() or public._ai_narrative_exam_qa_grant_allows_131m(v_uid,v_char.id,v_loc.id)))
              or (v_loc.id = '1ed40f52-7bff-4aa1-85a1-28b24f5804b2'::uuid
                  and v_uid = 'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid);

  -- [002] Nella Test Room lo staff prova l'esame con qualunque PG: le barriere
  --       del candidato (villaggio, grado, lezioni) non si applicano. Solo qui.
  v_deroga := v_deroga OR exam_regia_private.native_open_allowed(v_uid,v_char.id,v_loc.id);
  v_test_staff := coalesce(v_loc.is_test, false) and public.is_staff();

  if v_loc.id is null or not (coalesce(v_loc.is_exam_room,false) or v_deroga) then
    raise exception 'Qui non si tengono esami';
  end if;

  -- [108] Serializza soltanto gli avvii nella stessa sala. La transazione non
  -- contiene chiamate esterne e il lock vive per pochi millisecondi.
  perform pg_advisory_xact_lock(hashtextextended('esame_avvia:'||p_location::text,0));

  v_village := coalesce(nullif(lower(btrim(v_loc.region)),''), 'konoha');

  -- [PREREQ-001 · lower() 1 di 3] locations.region è minuscolo,
  -- characters.village è maiuscolo: senza lower() da entrambe le parti il
  -- confronto è sempre falso. Vedi PREFLIGHT di DB-003 §5.1.
  -- ⚠️ Errore NON previsto dai nove del §6a: aggiunto di iniziativa, dichiarato
  --    nell'handoff perché il PM lo ratifichi (Discovery §10, punto 10).
  if not v_test_staff and lower(btrim(coalesce(v_char.village,''))) is distinct from v_village then
    raise exception 'Questo esame non è del tuo villaggio';
  end if;

  if not v_test_staff and coalesce(v_char.rank,'Deshi') <> 'Deshi' then
    raise exception 'Hai già il grado di Genin';
  end if;

  -- Idempotenza (Discovery §7): un doppio invio o un rientro ritrovano la
  -- propria sessione aperta invece di aprirne una seconda nella sala di riserva.
  select s.id into v_aperta
    from public.academy_class_sessions s
    join public.academy_lessons l on l.id = s.lesson_id
    join public.academy_class_participants p on p.session_id = s.id and p.user_id = v_uid
   where s.state <> 'closed' and coalesce(l.is_exam,false)
   order by s.created_at desc limit 1;
  if v_aperta is not null then
    -- Recupero idempotente: la stessa porta riallinea e apre l'eventuale
    -- sessione rimasta enrolling, senza creare un secondo owner o una prova.
    perform public.esame_prova_apri(v_aperta);
    return v_aperta;
  end if;

  -- Prerequisito, verificato QUI e non solo a valle (§6a). Sta prima della
  -- disponibilità della riga EXAM perché riguarda il candidato e non il
  -- sistema: resta vero anche a esame contenuto.
  select count(*) filter (where not al.is_exam),
         count(*) filter (where not al.is_exam and pp.lesson_id is not null)
    into v_tot_reg, v_done_reg
    from public.academy_lessons al
    left join public.lesson_progress pp on pp.lesson_id = al.id and pp.user_id = v_uid
   where al.is_active;
  if not v_test_staff and not (coalesce(v_tot_reg,0) > 0 and v_done_reg = v_tot_reg) then
    raise exception 'Non hai ancora finito le lezioni';
  end if;

  -- La lezione la sceglie il server, non il client.
  -- [038-R2] la seconda barriera. `is_exam` resta CONGIUNTO: la deroga allarga
  -- soltanto `is_active`, quindi nessuna lezione ordinaria spenta entra qui.
  -- ⚠️ `order by is_active desc` PRIMA di `ordinal`: se un giorno esistessero
  --    due lezioni d'esame, una accesa e una spenta, senza questa riga la
  --    deroga potrebbe far scegliere la spenta a chi aveva diritto alla accesa.
  --    Così la deroga può solo AGGIUNGERE un ripiego, mai cambiare la scelta
  --    che il percorso normale avrebbe fatto.
  select * into v_lesson from public.academy_lessons
   where is_exam and (is_active or v_deroga)
   order by is_active desc, ordinal limit 1;
  if v_lesson.id is null then raise exception 'L''esame non è disponibile'; end if;

  if exists (select 1 from public.academy_class_sessions
              where location_id = p_location and state <> 'closed') then
    raise exception 'C''è già un esame in corso in questa sala';
  end if;

  select coalesce(max(step),0) into v_steps
    from public.academy_lesson_script
   where lesson_id = v_lesson.id and lower(btrim(village)) = v_village;
  if v_steps = 0 then raise exception 'Esame senza contenuti'; end if;

  if coalesce(v_loc.is_exam_room,false) or v_deroga then
    -- Sessione contenitore compatibile con il client, gia' sul passo della prova.
    -- `ai_blocked_at` esclude academy_sensei_ai; `step_at` futuro impedisce
    -- l'avanzamento automatico Accademia durante il banco reale.
    insert into public.academy_class_sessions
      (location_id, village, lesson_id, lesson_code, lesson_title,
       sensei_name, total_steps, started_by, starter_name, sensei_agent_id,
       state, step, step_at, ai_blocked_at, ai_block_reason)
    values
      (p_location, v_village, v_lesson.id, v_lesson.code, v_lesson.title,
       null, v_steps, v_uid, v_char.name, null,
       'teaching',
       (select max(sc.step) from public.academy_lesson_script sc
         where sc.lesson_id = v_lesson.id
           and lower(btrim(sc.village)) = v_village
           and coalesce(sc.valuta,false)),
       now() + interval '24 hours', now(), 'staff')
    returning id into v_sess;
  else
    select a.id, a.name into v_agent from public.ai_agents a
     where a.kind = 'sensei' and a.is_active
       and lower(btrim(a.village)) = v_village
       and not exists (select 1 from public.academy_class_sessions s
                        where s.state <> 'closed' and s.sensei_agent_id = a.id)
     order by (-ln(random()) / greatest(a.weight,1)) asc limit 1;
    if v_agent.id is null then
      select a.id, a.name into v_agent from public.ai_agents a
       where a.kind = 'sensei' and a.is_active
         and lower(btrim(a.village)) = v_village
       order by (-ln(random()) / greatest(a.weight,1)) asc limit 1;
    end if;
    if v_agent.id is null then
      raise exception 'In questo villaggio non c''è nessun maestro attivo';
    end if;

    insert into public.academy_class_sessions
      (location_id, village, lesson_id, lesson_code, lesson_title,
       sensei_name, total_steps, started_by, starter_name, sensei_agent_id)
    values
      (p_location, v_village, v_lesson.id, v_lesson.code, v_lesson.title,
       v_agent.name, v_steps, v_uid, v_char.name, v_agent.id)
    returning id into v_sess;
  end if;

  insert into public.academy_class_participants
    (session_id, user_id, character_id, character_name, kind)
  values (v_sess, v_uid, v_char.id, v_char.name, 'student');

  -- [108] Sessione, partecipante e prova nascono nella stessa transazione.
  -- Se la prova non può aprirsi, anche il contenitore viene annullato: nessun
  -- player resta più quindici minuti davanti a una sessione dimezzata.
  perform public.esame_prova_apri(v_sess);

  return v_sess;
end $function$;
CREATE OR REPLACE FUNCTION public.esame_regia_readiness(p_location uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE adm exam_regia_private.admissions%ROWTYPE; runtime exam_regia_private.runtime%ROWTYPE;
 b exam_regia_private.bindings%ROWTYPE; ready boolean:=false; reason text; eligible boolean:=false;
BEGIN
 SELECT * INTO STRICT runtime FROM exam_regia_private.runtime WHERE singleton;
 IF auth.uid() IS NOT NULL AND p_location IS NOT NULL THEN
  SELECT a.* INTO adm FROM exam_regia_private.admissions a JOIN public.characters c ON c.id=a.character_id AND c.user_id=a.owner_user
   JOIN public.locations l ON l.id=a.location_id AND l.is_active WHERE a.owner_user=auth.uid()
   AND a.location_id=p_location AND a.enabled AND a.expires_at>clock_timestamp();
  eligible:=FOUND;
 END IF;
 IF eligible THEN
  SELECT * INTO b FROM exam_regia_private.bindings WHERE owner_user=auth.uid() AND state<>'closed';
  ready:=runtime.enabled AND EXISTS(SELECT 1 FROM public.esame_png_profili e
   JOIN public.ai_agents agent ON agent.id=e.agent_id AND agent.is_active WHERE e.is_active)
   AND EXISTS(SELECT 1 FROM combat_spatial.arena_templates t WHERE t.template_key=adm.template_key
    AND t.template_version=adm.template_version AND t.status='ready');
  IF NOT runtime.enabled THEN reason:='release_not_enabled';
  ELSIF EXISTS(SELECT 1 FROM public.master_v2_sessions m WHERE m.location_id=p_location AND m.stato NOT IN ('chiusa','annullata')
    AND m.id IS DISTINCT FROM b.master_session_id)
   OR EXISTS(SELECT 1 FROM public.combat_v2_sessions s WHERE s.location_id=p_location AND s.closed_at IS NULL
    AND s.state NOT IN ('chiuso','annullato') AND s.id IS DISTINCT FROM b.combat_session_id)
   OR EXISTS(SELECT 1 FROM public.combat_sessions s WHERE s.location_id=p_location AND s.state='aperto')
   OR EXISTS(SELECT 1 FROM public.academy_class_sessions s WHERE s.location_id=p_location AND s.state<>'closed'
    AND s.id IS DISTINCT FROM b.class_session_id) THEN ready:=false;reason:='location_busy';
  ELSIF NOT ready THEN reason:='sources_not_ready'; END IF;
 ELSE reason:='not_eligible'; END IF;
 RETURN jsonb_build_object('ok',true,'version','EXAM-REGIA17/1','eligible',eligible,'ready',ready,'protected',eligible,
  'location_id',p_location,'candidate_character',adm.character_id,'existing_prova',b.prova_id,'reason',reason,
  'budget',CASE WHEN eligible THEN jsonb_build_object('used',0,'limit',runtime.provider_call_cap) ELSE NULL END,
  'capabilities',jsonb_build_object('common_combat',ready,'movement',ready,'substitution',ready,'multiplication',ready,'ai_controller',ready));
END $fn$;
CREATE OR REPLACE FUNCTION public.esame_regia_open(p_location uuid,p_request uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE ready jsonb; native jsonb; adm exam_regia_private.admissions%ROWTYPE; b exam_regia_private.bindings%ROWTYPE; sess uuid; proof uuid;
BEGIN
 IF auth.uid() IS NULL OR p_location IS NULL OR p_request IS NULL THEN RAISE EXCEPTION 'exam_regia_auth_required' USING ERRCODE='42501'; END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('exam-regia-owner:'||auth.uid()::text,731));
 PERFORM 1 FROM public.locations WHERE id=p_location AND is_active FOR UPDATE;
 SELECT * INTO b FROM exam_regia_private.bindings WHERE owner_user=auth.uid() AND request_key=p_request;
 IF FOUND THEN
 IF b.state='closed' OR b.location_id<>p_location THEN RAISE EXCEPTION 'exam_regia_request_closed_or_conflict' USING ERRCODE='55000'; END IF;
 RETURN jsonb_build_object('ok',true,'version','EXAM-REGIA17/1','prova',b.prova_id,'class_session_id',b.class_session_id,
 'protected',true,'binding',exam_regia_private.binding_wire(b.prova_id),'budget',public.esame_regia_state(b.prova_id)->'budget'); END IF;
 ready:=public.esame_regia_readiness(p_location);
 IF ready->>'eligible'<>'true' OR ready->>'ready'<>'true' OR NOT coalesce(public._combat_presente(auth.uid(),p_location),false)
 THEN RAISE EXCEPTION 'exam_regia_not_ready' USING ERRCODE='55000'; END IF;
 IF EXISTS(SELECT 1 FROM public.esame_prove WHERE candidate_user=auth.uid() AND stato='aperta')
 OR EXISTS(SELECT 1 FROM exam_regia_private.bindings WHERE owner_user=auth.uid() AND state<>'closed')
 THEN RAISE EXCEPTION 'exam_regia_existing_activity' USING ERRCODE='55000'; END IF;
 SELECT * INTO STRICT adm FROM exam_regia_private.admissions WHERE owner_user=auth.uid() AND location_id=p_location
 AND enabled AND expires_at>clock_timestamp() FOR SHARE;
 IF adm.surface='konoha' THEN
 native:=public.esame_session_open(p_request); proof:=(native->>'prova')::uuid;
 ELSE
 INSERT INTO mission_exam_private.open_requests(request_id,owner_user,transaction_id,exam_regia_admission_id)
 VALUES(p_request,auth.uid(),txid_current(),adm.id);
 INSERT INTO public.esame_supervisione_prenotazioni(personaggio,luogo,autore) VALUES(adm.character_id,p_location,auth.uid());
 sess:=public.esame_avvia(p_location);
 SELECT q.prova_id INTO STRICT proof FROM mission_exam_private.protected_sessions q
 WHERE q.class_session_id=sess AND q.owner_user=auth.uid() AND q.state='active';
 END IF;
 RETURN exam_regia_private.attach_native(proof,p_request);
END $fn$;
CREATE OR REPLACE FUNCTION public.esame_regia_state(p_prova uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; h public.esame_supervisione%ROWTYPE;
 q mission_exam_private.protected_sessions%ROWTYPE; d public.esame_supervisione_bozze%ROWTYPE; r public.combat_v2_rounds%ROWTYPE;
 next_step text; player boolean; native_state jsonb;
BEGIN
 b:=exam_regia_private.assert_owner(p_prova,true);
 SELECT * INTO STRICT h FROM public.esame_supervisione WHERE prova=p_prova;
 SELECT * INTO STRICT q FROM mission_exam_private.protected_sessions WHERE prova_id=p_prova;
 SELECT * INTO r FROM public.combat_v2_rounds WHERE session_id=b.combat_session_id ORDER BY round_no DESC LIMIT 1;
 IF b.receipt_kind='narration' THEN SELECT rr.* INTO STRICT r FROM public.combat_v2_rounds rr JOIN exam_regia_private.receipts qr ON qr.round_id=rr.id WHERE qr.id=b.receipt_id; END IF;
 SELECT * INTO d FROM public.esame_supervisione_bozze WHERE prova=p_prova AND ricevuta=b.receipt_id;
 player:=b.state IN ('active','congedo') AND b.receipt_kind='player' AND h.apertura_pubblicata AND h.player_ready AND NOT h.publishing;
 next_step:=CASE WHEN b.state='closed' THEN 'complete' WHEN b.state='paused' OR d.stato='errore' THEN 'paused'
 WHEN h.publishing OR d.stato='generazione' THEN 'waiting' WHEN d.stato='pronta' THEN 'publish'
 WHEN player THEN 'player' WHEN d.stato='autorizzata' THEN 'generate'
 WHEN b.receipt_kind IN ('opening','choice','narration') AND d.id IS NULL THEN 'authorize' ELSE 'waiting' END;
 IF b.state='opening' THEN
 native_state:=public.esame_session_state(p_prova);
 RETURN native_state||jsonb_build_object('version','EXAM-REGIA17/1','status','opening','phase','opening','next',next_step,
 'round_no',exam_regia_private.logical_round_no(r.id),'max_rounds',4,'exchange',exam_regia_private.exchange_wire(r.id),'binding',exam_regia_private.binding_wire(b.prova_id));
 END IF;
 RETURN jsonb_build_object('ok',true,'version','EXAM-REGIA17/1','prova',p_prova,'protected',true,'status',b.state,
 'phase',CASE WHEN b.state='congedo' THEN 'uscita' ELSE b.receipt_kind END,'next',next_step,'receipt_id',b.receipt_id,
 'player_ready',player,'publishing',h.publishing,'opening_published',h.apertura_pubblicata,'closed',b.state='closed',
 'round_no',exam_regia_private.logical_round_no(r.id),'max_rounds',4,'exchange',exam_regia_private.exchange_wire(r.id),'binding',exam_regia_private.binding_wire(b.prova_id),
 'budget',jsonb_build_object('used',q.provider_calls,'limit',q.provider_call_cap),
 'draft',CASE WHEN d.id IS NULL THEN NULL ELSE jsonb_build_object('id',d.id,'status',d.stato,'sha',d.sha,
 'result_ok',coalesce(d.risultato->>'ok'='true',false),'publishable',coalesce(d.risultato->>'publishable'='true',false),
 'version',d.risultato->>'validator_version') END,'error',CASE WHEN d.stato='errore' THEN 'generation_error' ELSE NULL END);
END $fn$;
CREATE OR REPLACE FUNCTION public.esame_regia_close(p_prova uuid,p_request uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; res jsonb;
BEGIN
 b:=exam_regia_private.assert_owner(p_prova,true);
 res:=public.esame_session_close(p_prova,p_request);
 IF NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings WHERE prova_id=p_prova AND state='closed')
 THEN RAISE EXCEPTION 'exam_regia_close_not_confirmed'; END IF;
 RETURN res||jsonb_build_object('version','EXAM-REGIA17/1');
END $fn$;
CREATE OR REPLACE FUNCTION public.esame_chiudi(p_session uuid)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_sess record; v_lesson record; v_char record;
  v_user uuid; v_charid uuid;
  v_tot int; v_done int;
  v_esito text; v_xp int; v_rank text;
begin
  if exists(select 1 from mission_exam_private.protected_sessions where class_session_id=p_session) then
    raise exception 'mission_session_progression_forbidden' using errcode='42501';
  end if;
  select * into v_sess from public.academy_class_sessions where id = p_session for update;
  if not found then raise exception 'sessione inesistente'; end if;

  select * into v_lesson from public.academy_lessons where id = v_sess.lesson_id;
  if not coalesce(v_lesson.is_exam,false) then raise exception 'non è un esame'; end if;

  if coalesce(v_sess.step,0) < coalesce(v_sess.total_steps,0) then
    raise exception 'esame non concluso';
  end if;

  select p.user_id, p.character_id into v_user, v_charid
    from public.academy_class_participants p
   where p.session_id = p_session and p.kind = 'student'
   order by p.enrolled_at limit 1;
  if v_user is null then raise exception 'sessione inesistente'; end if;

  select * into v_char from public.characters where id = v_charid;
  if not found then raise exception 'sessione inesistente'; end if;

  -- Prima di qualunque scrittura: chi è già Genin non si ripromuove e non
  -- riceve una seconda volta i 30 XP. Copre anche il caso in cui la promozione
  -- sia passata dal ramo legacy _academy_grant, che il §6c deve ancora ritirare.
  if coalesce(v_char.rank,'Deshi') <> 'Deshi' then raise exception 'già promosso'; end if;

  -- Il prerequisito si rilegge QUI (§6b), non ci si fida di esame_avvia.
  select count(*) filter (where not al.is_exam),
         count(*) filter (where not al.is_exam and pp.lesson_id is not null)
    into v_tot, v_done
    from public.academy_lessons al
    left join public.lesson_progress pp on pp.lesson_id = al.id and pp.user_id = v_user
   where al.is_active;
  if not (coalesce(v_tot,0) > 0 and v_done = v_tot) then
    raise exception 'prerequisito non soddisfatto';
  end if;

  v_esito := public._esame_classifica(p_session);

  insert into public.lesson_progress(user_id, lesson_id)
    values (v_user, v_lesson.id)
    on conflict (user_id, lesson_id) do nothing;

  v_xp := coalesce(v_lesson.xp_reward, 0);
  perform public._assegna_xp(v_charid, v_xp, 'accademia: esame Genin');

  update public.academy_class_participants
     set esito = v_esito
   where session_id = p_session and user_id = v_user;

  -- ⚠️ app.allow_academy si accende IMMEDIATAMENTE prima dell'unico update del
  --    grado e si azzera SUBITO dopo. Acceso, quel flag non apre solo rank:
  --    apre anche unspent_points, ed è la porta da cui passa il «+15» di
  --    academy_complete (PREFLIGHT DB-003 §2.1). Qui i punti NON si toccano:
  --    li concede trg_characters_grant_pool da sé, 60 → 90, cioè +30.
  perform set_config('app.allow_academy','1',true);
  update public.characters set rank = 'Genin' where id = v_charid;
  perform set_config('app.allow_academy','',true);

  update public.academy_class_sessions
     set state = 'closed', closed_at = now(), close_reason = 'done', force_next = false
   where id = p_session;

  select rank into v_rank from public.characters where id = v_charid;
  return json_build_object('ok', true, 'esito', v_esito, 'xp', v_xp, 'rank', v_rank);
end $function$;
CREATE OR REPLACE FUNCTION public.esame_regia_exit(p_prova uuid,p_request uuid,p_text text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; prior exam_regia_private.exit_receipts%ROWTYPE;
 fp text; mid uuid; guided text; res jsonb;
BEGIN
 IF p_request IS NULL OR nullif(btrim(p_text),'') IS NULL OR length(p_text)>5000 THEN
 RAISE EXCEPTION 'exam_regia_exit_text_invalid' USING ERRCODE='22023'; END IF;
 b:=exam_regia_private.assert_owner(p_prova,true); fp:=public.combat_v2_sha256(to_jsonb(btrim(p_text)));
 SELECT * INTO prior FROM exam_regia_private.exit_receipts WHERE prova_id=p_prova OR request_key=p_request FOR UPDATE;
 IF FOUND THEN
  IF prior.prova_id<>p_prova OR prior.owner_user IS DISTINCT FROM auth.uid() OR prior.request_key<>p_request
  OR prior.text_sha256<>fp OR prior.result IS NULL THEN RAISE EXCEPTION 'exam_regia_exit_replay_conflict' USING ERRCODE='22023'; END IF;
  RETURN prior.result||jsonb_build_object('replayed',true);
 END IF;
 IF b.state<>'congedo' OR NOT coalesce(public._combat_presente(auth.uid(),b.location_id),false)
 OR NOT EXISTS(SELECT 1 FROM exam_regia_private.receipts r JOIN public.esame_supervisione_bozze d ON d.id=r.draft_id
 WHERE r.prova_id=b.prova_id AND r.kind='narration' AND r.published_at IS NOT NULL AND d.stato='pubblicata'
 AND d.payload#>>'{regia,final}'='true') THEN RAISE EXCEPTION 'exam_regia_exit_not_ready' USING ERRCODE='55000'; END IF;
 INSERT INTO exam_regia_private.exit_receipts(prova_id,request_key,owner_user,text_sha256)
 VALUES(p_prova,p_request,auth.uid(),fp) RETURNING * INTO prior;
 mid:=public._esame_testo_candidato(b.prova_id,btrim(p_text));
 IF NOT EXISTS(SELECT 1 FROM public.messages WHERE id=mid AND character_id=b.character_id AND sender_user=b.owner_user
 AND location_id=b.location_id AND body=btrim(p_text)) THEN RAISE EXCEPTION 'exam_regia_exit_message_invalid'; END IF;
 UPDATE public.esame_prove SET stato='conclusa',closed_at=clock_timestamp(),close_reason='done',opzioni_png=NULL,opzioni_id=NULL
 WHERE id=b.prova_id AND stato='aperta';
 res:=public.esame_regia_close(b.prova_id,p_request);
 res:=res||jsonb_build_object('message_id',mid,'receipt_id',prior.receipt_id,'replayed',false);
 UPDATE exam_regia_private.exit_receipts SET message_id=mid,result=res WHERE prova_id=p_prova;
 RETURN res;
END $fn$;
CREATE OR REPLACE FUNCTION exam_regia_private.scene(p_prova uuid,p_round uuid)
RETURNS jsonb LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path='' AS $scene$
DECLARE
 b exam_regia_private.bindings%ROWTYPE; s public.combat_v2_sessions%ROWTYPE;
 r public.combat_v2_rounds%ROWTYPE; rep public.combat_v2_round_reports%ROWTYPE;
 pg public.combat_v2_actors%ROWTYPE; npc public.combat_v2_actors%ROWTYPE;
 inst public.combat_v2_png_instances%ROWTYPE; profile exam_regia_private.profile_templates%ROWTYPE;
 place public.locations%ROWTYPE; d public.combat_v2_declarations%ROWTYPE; row record;
 pg_name text; body text; source_id text; source_hash text; technique text; ability uuid;
 actors jsonb; actions jsonb:='[]'; sources jsonb:='[]'; facts jsonb:='[]'; spatial jsonb:='[]';
 projected jsonb; recorded jsonb; narrator jsonb; snapshot jsonb; candidate jsonb; output jsonb;
 final_round boolean; previous_count integer:=0; included integer:=0; declaration_count integer:=0;
BEGIN
 IF NOT public.combat_v2_is_service() OR auth.uid() IS NOT NULL OR p_prova IS NULL OR p_round IS NULL THEN
  RAISE EXCEPTION 'exam_regia_scene_service_required' USING ERRCODE='42501';
 END IF;
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=p_prova;
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=b.combat_session_id;
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=p_round AND session_id=s.id;
 SELECT * INTO STRICT rep FROM public.combat_v2_round_reports WHERE round_id=r.id AND id=r.report_id;
 IF b.state<>'active' OR b.policy_id<>'exam_protected_no_persistent_resources_v1' OR b.control_version<1
  OR s.source_kind<>'master' OR s.master_session_id IS DISTINCT FROM b.master_session_id
  OR s.location_id IS DISTINCT FROM b.location_id OR s.lesiva IS DISTINCT FROM false
  OR public.combat_v2_values_written(s.id) IS DISTINCT FROM false
  OR r.state NOT IN ('risolto','narrazione','narrato') OR r.resolved_at IS NULL OR r.round_no NOT BETWEEN 1 AND 8
  OR rep.values_written IS DISTINCT FROM false OR rep.mechanics->'values_written' IS DISTINCT FROM 'false'::jsonb
  OR rep.mechanics_sha256 IS DISTINCT FROM public.combat_v2_sha256(rep.mechanics)
  OR NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m WHERE m.id=b.master_session_id
    AND m.owner_kind='ai_service' AND m.master_user IS NULL AND m.location_id=b.location_id)
 THEN RAISE EXCEPTION 'exam_regia_scene_binding_invalid' USING ERRCODE='55000'; END IF;
 SELECT * INTO STRICT pg FROM public.combat_v2_actors WHERE id=b.player_actor_id AND session_id=s.id
  AND actor_kind='pg' AND character_id=b.character_id AND controller_user=b.owner_user;
 SELECT * INTO STRICT npc FROM public.combat_v2_actors WHERE id=b.png_actor_id AND session_id=s.id
  AND actor_kind='png' AND character_id IS NULL AND controller_user IS NULL;
 IF pg.id=npc.id OR (SELECT count(*) FROM public.combat_v2_actors WHERE session_id=s.id)<>2 THEN
  RAISE EXCEPTION 'exam_regia_scene_roster_invalid' USING ERRCODE='55000'; END IF;
 SELECT name INTO STRICT pg_name FROM public.characters WHERE id=b.character_id AND user_id=b.owner_user;
 SELECT * INTO STRICT inst FROM public.combat_v2_png_instances WHERE id=npc.png_instance_id AND session_id=s.id;
 SELECT * INTO STRICT profile FROM exam_regia_private.profile_templates WHERE template_id=inst.template_id;
 SELECT * INTO STRICT place FROM public.locations WHERE id=b.location_id;
 IF nullif(btrim(pg_name),'') IS NULL OR nullif(btrim(inst.nome),'') IS NULL
  OR nullif(btrim(profile.persona),'') IS NULL OR nullif(btrim(place.name),'') IS NULL
  OR profile.source_sha256 !~ '^[0-9a-f]{64}$' THEN
  RAISE EXCEPTION 'exam_regia_scene_identity_invalid' USING ERRCODE='55000'; END IF;
 actors:=jsonb_build_array(
  jsonb_build_object('id',pg.id,'name',pg_name,'kind','PG','persona',NULL,'may_speak',false),
  jsonb_build_object('id',npc.id,'name',inst.nome,'kind','PNG','persona',profile.persona,'may_speak',true));

 -- Le fonti setting precedono le role: ordine richiesto da buildScene invariato.
 IF nullif(btrim(place.description),'') IS NOT NULL THEN
  body:=place.description;
  sources:=sources||jsonb_build_array(jsonb_build_object('id','location:'||place.id,'session_id',s.id,
   'round_id',r.id,'kind','setting','actor_id',NULL,'sequence',r.round_no,'body',body,
   'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 END IF;
 -- L'incipit è già pubblico: ricevuta e sigillo SESSION, nessuna scansione chat.
 FOR row IN SELECT z.id,z.risultato,z.sha,z.ricevuta,z.payload_sha FROM public.esame_supervisione_bozze z
 JOIN public.esame_supervisione h ON h.prova=z.prova AND h.apertura_ricevuta=z.ricevuta
 WHERE z.prova=b.prova_id AND z.tipo='apertura' AND z.stato='pubblicata' AND h.apertura_pubblicata
 ORDER BY z.autorizzata_at,z.id
 LOOP
  IF row.sha IS DISTINCT FROM public._esame_supervisione_hash(jsonb_build_object(
   'ricevuta',row.ricevuta,'payload_sha',row.payload_sha,'risultato',row.risultato))
   OR row.risultato->'ok' IS DISTINCT FROM 'true'::jsonb OR row.risultato->'publishable' IS DISTINCT FROM 'true'::jsonb
   THEN RAISE EXCEPTION 'exam_regia_scene_opening_changed' USING ERRCODE='55000'; END IF;
  body:=btrim(row.risultato->>'testo');
  IF nullif(body,'') IS NULL THEN RAISE EXCEPTION 'exam_regia_scene_opening_empty' USING ERRCODE='55000'; END IF;
  sources:=sources||jsonb_build_array(jsonb_build_object('id','opening:'||row.id,'session_id',s.id,
   'round_id',r.id,'kind','setting','actor_id',NULL,'sequence',0,'body',body,
   'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 END LOOP;
 IF (SELECT count(*) FROM public.esame_supervisione_bozze z JOIN public.esame_supervisione h
 ON h.prova=z.prova AND h.apertura_ricevuta=z.ricevuta WHERE z.prova=b.prova_id
 AND z.tipo='apertura' AND z.stato='pubblicata' AND h.apertura_pubblicata)<>1 THEN
  RAISE EXCEPTION 'exam_regia_scene_opening_missing' USING ERRCODE='55000'; END IF;
 final_round:=exam_regia_private.round_is_final(r.id);
 IF final_round THEN
  body:='Lo scontro della prova Genin è concluso. Il Sensei invita il candidato al congedo. La prova è protetta: nessuna promozione, premio o modifica alla scheda reale.';
  sources:=sources||jsonb_build_array(jsonb_build_object('id','exam-final:'||r.id,'session_id',s.id,
   'round_id',r.id,'kind','setting','actor_id',NULL,'sequence',r.round_no,'body',body,
   'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 END IF;

 IF jsonb_typeof(rep.mechanics->'declarations') IS DISTINCT FROM 'array' OR EXISTS(
  SELECT 1 FROM public.combat_v2_declarations x WHERE x.round_id=r.id AND
   (x.actor_id NOT IN(pg.id,npc.id) OR x.kind NOT IN('attacco','utilita','movimento','difesa') OR x.state NOT IN('risolta','superflua')))
 THEN RAISE EXCEPTION 'exam_regia_scene_declarations_invalid' USING ERRCODE='55000'; END IF;
 FOR d IN SELECT * FROM public.combat_v2_declarations WHERE round_id=r.id
  ORDER BY CASE WHEN kind='difesa' THEN 1 ELSE 0 END,order_no NULLS LAST,id
 LOOP
  SELECT value INTO STRICT recorded FROM jsonb_array_elements(rep.mechanics->'declarations') WHERE value->>'id'=d.id::text;
  IF recorded->>'actor' IS DISTINCT FROM d.actor_id::text OR recorded->>'kind' IS DISTINCT FROM d.kind
   OR recorded->>'state' IS DISTINCT FROM d.state OR recorded->'outcome' IS DISTINCT FROM d.outcome THEN
   RAISE EXCEPTION 'exam_regia_scene_report_declaration_changed' USING ERRCODE='55000'; END IF;
  IF d.actor_id=pg.id THEN
   SELECT m.id::text,m.body INTO STRICT source_id,body FROM combat_consumer_private.declaration_messages link
    JOIN public.messages m ON m.id=link.message_id WHERE link.declaration_id=d.id
    AND m.location_id=b.location_id AND m.character_id=b.character_id AND m.sender_user=b.owner_user
    AND m.recipient_user IS NULL AND m.kind NOT IN ('whisper','motore')
    AND public._combat_narrative_sha(m.id)=link.message_sha256;
  ELSE
   -- Fonte PNG pubblicabile autorizzata dalla capacità consumata. La difesa
   -- non ha un messaggio anticipato; non si fabbrica il collegamento a messages.
   IF NOT EXISTS(SELECT 1 FROM exam_regia_private.ai_capabilities cap
    JOIN exam_regia_private.receipts q ON q.id=cap.receipt_id AND q.prova_id=cap.prova_id
    JOIN combat_panel_private.request_receipts rr ON rr.principal_user=b.service_principal_id
     AND rr.request_key=cap.request_key
    WHERE cap.prova_id=b.prova_id AND cap.actor_id=npc.id AND cap.consumed_at IS NOT NULL
     AND cap.request_key=d.request_key AND q.round_id=r.id AND q.kind='choice' AND q.command_receipt_id IS NOT NULL
     AND q.published_at IS NOT NULL AND q.committed_command->>'request_key'=d.request_key::text
     AND q.committed_command->>'narrative_text'=d.declaration_text
     AND cap.command_sha256=public.combat_v2_sha256(q.committed_command)
     AND rr.command_fingerprint=cap.command_sha256
     AND rr.viewer_envelope#>>'{receipt,receipt_id}'=q.command_receipt_id::text
     AND rr.viewer_envelope#>>'{receipt,declaration_id}'=d.id::text)
   THEN RAISE EXCEPTION 'exam_regia_scene_png_source_invalid' USING ERRCODE='55000'; END IF;
   source_id:='declaration:'||d.id;body:=d.declaration_text;
  END IF;
  IF nullif(btrim(body),'') IS NULL THEN RAISE EXCEPTION 'exam_regia_scene_role_empty' USING ERRCODE='55000'; END IF;
  source_hash:=encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex');
  actions:=actions||jsonb_build_array(jsonb_build_object('actor_id',d.actor_id,'role',CASE WHEN d.kind='difesa' THEN 'difesa' ELSE 'azione' END,'source_id',source_id));
  sources:=sources||jsonb_build_array(jsonb_build_object('id',source_id,'session_id',s.id,'round_id',r.id,
   'kind','role','actor_id',d.actor_id,'sequence',r.round_no,'body',body,'sha256',source_hash,'visibility','public','complete',true));
  declaration_count:=declaration_count+1;
  IF d.state='risolta' THEN projected:=combat_panel_private.narrative_declaration_facts(d.id);
  ELSE projected:=jsonb_build_object('schema_version','combat-narrative-facts/1','kind',d.kind,
   'execution','not_executed','result',combat_panel_private.narrative_outcome_facts(d.outcome)); END IF;
  technique:=NULL;ability:=NULL;
  IF d.sanitized_intent->>'ability_id' ~* '^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$' THEN
   ability:=(d.sanitized_intent->>'ability_id')::uuid;
   IF d.sanitized_intent->>'ability_source'='jutsu' THEN SELECT name_it INTO technique FROM public.jutsu WHERE id=ability;
   ELSIF d.sanitized_intent->>'ability_source'='clan' THEN SELECT name INTO technique FROM public.clan_techniques WHERE id=ability; END IF;
  END IF;
  IF projected ? 'multiplication_created' THEN technique:='Moltiplicazione'; END IF;
  facts:=facts||jsonb_build_array(jsonb_build_object('actor_id',d.actor_id,'target_actor_id',d.target_actor_id,
   'role',CASE WHEN d.kind='difesa' THEN 'difesa' ELSE 'azione' END,'source_id',source_id,
   'technique',technique,'reaction',CASE WHEN d.kind='difesa' THEN d.sanitized_intent->>'reaction' ELSE NULL END,
   'facts',projected));
  IF d.kind='movimento' AND d.state='risolta' THEN
   -- Distanza assestata del movimento, già esito nativo; nessuna posizione o
   -- figura originale. Gli stati before/after del kernel restano privati.
   IF d.outcome ? 'movement_m' AND (jsonb_typeof(d.outcome->'movement_m')<>'number' OR (d.outcome->>'movement_m')::numeric<0) THEN
    RAISE EXCEPTION 'exam_regia_scene_movement_invalid' USING ERRCODE='55000'; END IF;
   spatial:=spatial||jsonb_build_array(jsonb_build_object('actor_id',d.actor_id,'kind','movement',
    'distance_m',d.outcome->'movement_m','reason',d.outcome->'reason_code'));
  END IF;
 END LOOP;
 IF declaration_count<>jsonb_array_length(rep.mechanics->'declarations') OR
  (SELECT count(*) FROM public.combat_v2_declarations WHERE round_id=r.id AND kind<>'difesa')<>1 OR
  NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=r.id AND kind<>'difesa'
   AND actor_id=CASE WHEN r.round_no%2=1 THEN pg.id ELSE npc.id END) OR
  NOT EXISTS(SELECT 1 FROM mission_exchange_v3.receipts e WHERE e.combat_round_id=r.id AND e.combat_owner->>'report_sha256'=rep.mechanics_sha256) THEN
  RAISE EXCEPTION 'exam_regia_scene_actions_incomplete' USING ERRCODE='55000'; END IF;

 -- Substitution receipt è già proiezione narratore del resolver. Selezioniamo
 -- solo identità del difensore, esito e descrizioni semantiche; niente indici,
 -- coordinate, before/after_state o interi mechanics_snapshot.
 IF jsonb_typeof(rep.mechanics->'substitution_receipts') IS DISTINCT FROM 'array' THEN
  RAISE EXCEPTION 'exam_regia_scene_substitution_missing' USING ERRCODE='55000'; END IF;
 FOR recorded IN SELECT value FROM jsonb_array_elements(rep.mechanics->'substitution_receipts') LOOP
  narrator:=recorded->'narrator_payload';
  IF recorded->>'round_id' IS DISTINCT FROM r.id::text OR recorded->>'actor_id' IS NULL OR recorded->>'actor_id' NOT IN(pg.id::text,npc.id::text)
   OR recorded->>'event_kind' IS DISTINCT FROM 'substitution_committed'
   OR narrator->>'schema_version' IS DISTINCT FROM 'common-substitution-narrator/1.0'
   OR narrator#>>'{impact,outcome}' IS NULL OR narrator#>>'{impact,outcome}' NOT IN('negato_sostituzione','reazione_spesa_su_copia')
   OR narrator#>>'{impact,proxy}' IS DISTINCT FROM 'semantic_non_actor'
   OR narrator#>>'{after,state}' IS DISTINCT FROM 'defender_relocated'
   OR nullif(btrim(narrator#>>'{anchor,semantic_label}'),'') IS NULL
   OR nullif(btrim(narrator#>>'{after,semantic_region}'),'') IS NULL THEN
   RAISE EXCEPTION 'exam_regia_scene_substitution_invalid' USING ERRCODE='55000'; END IF;
  spatial:=spatial||jsonb_build_array(jsonb_build_object('actor_id',recorded->'actor_id','kind','substitution',
   'outcome',narrator#>'{impact,outcome}','anchor',narrator#>'{anchor,semantic_label}',
   'after',narrator#>'{after,semantic_region}'));
 END LOOP;

 SELECT count(*) INTO previous_count FROM public.combat_v2_narratives n
  JOIN public.combat_v2_rounds old ON old.id=n.round_id AND old.session_id=s.id
  JOIN public.combat_v2_round_reports q ON q.id=n.report_id AND q.round_id=old.id
  WHERE old.round_no<r.round_no AND old.state='narrato' AND q.narration_state='pubblicata';
 snapshot:=jsonb_build_object('schema_version','combat-scene/1','session_id',s.id,'round_id',r.id,
  'report_sha256',rep.mechanics_sha256,'control_version',b.control_version,'location',place.name,
  'actors',actors,'actions',actions,'resolved_facts',(jsonb_build_object('schema_version','exam-regia-resolved-facts/1',
    'round_no',exam_regia_private.logical_round_no(r.id),'final',final_round,'declarations',facts,'spatial',spatial)||combat_consumer_private.narrative_tech_sources_v1(b.receipt_id))::text,'sources',sources,
  'selection',jsonb_build_object('max_input_bytes',49152,'previous_available',previous_count,'previous_included',0));
 IF octet_length(snapshot::text)>49152 THEN RAISE EXCEPTION 'scene_required_context_overflow' USING ERRCODE='54000'; END IF;
 FOR row IN SELECT n.id,n.round_id,n.body,old.round_no,q.message_id FROM public.combat_v2_narratives n
  JOIN public.combat_v2_rounds old ON old.id=n.round_id AND old.session_id=s.id
  JOIN public.combat_v2_round_reports q ON q.id=n.report_id AND q.round_id=old.id
  WHERE old.round_no<r.round_no AND old.state='narrato' AND q.narration_state='pubblicata'
  ORDER BY old.round_no DESC,n.id
 LOOP
  IF nullif(btrim(row.body),'') IS NULL OR NOT EXISTS(SELECT 1 FROM public.messages m
   WHERE m.id=row.message_id AND m.location_id=b.location_id AND m.character_id IS NULL AND m.sender_user IS NULL
   AND m.recipient_user IS NULL AND m.kind='fato' AND m.body=row.body) THEN
   RAISE EXCEPTION 'exam_regia_scene_previous_changed' USING ERRCODE='55000'; END IF;
  candidate:=jsonb_set(snapshot,'{sources}',(snapshot->'sources')||jsonb_build_array(jsonb_build_object(
   'id',row.id,'session_id',s.id,'round_id',row.round_id,'kind','fato','actor_id',NULL,'sequence',row.round_no,
   'body',row.body,'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true)));
  candidate:=jsonb_set(candidate,'{selection,previous_included}',to_jsonb(included+1));
  IF octet_length(candidate::text)<=49152 THEN included:=included+1;snapshot:=candidate; END IF;
 END LOOP;
 source_hash:=public.combat_v2_sha256(snapshot);
 output:=jsonb_build_object('scene',jsonb_build_object('snapshot',snapshot,'snapshot_sha256',source_hash),
  'scene_binding',jsonb_build_object('session_id',s.id,'round_id',r.id,'report_sha256',rep.mechanics_sha256,
   'control_version',b.control_version,'hash_authority','combat_v2_sha256/jsonb','scene_sha256',source_hash));
 RETURN output;
END $scene$;
CREATE OR REPLACE FUNCTION public._esame_preview_source(p_prova uuid, p_user uuid)
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT b.id FROM public.esame_prove e
 JOIN mission_exam_private.protected_sessions q ON q.prova_id=e.id
 JOIN public.esame_supervisione_bozze b ON b.prova=e.id AND b.tipo='ciclo' AND b.stato='pubblicata'
 JOIN public.esame_narrazione_cicli c ON c.prova_id=e.id AND c.opzioni_id=b.ricevuta
 JOIN public.messages m ON m.id=c.action_message_id AND m.location_id=q.location_id
 WHERE e.id=p_prova AND p_user IS NOT NULL AND b.autore=p_user AND public._esame_session_scope(e.id,p_user)
  AND q.state='active' AND e.stato='aperta' AND e.meta='png' AND e.fase='difesa'
  AND c.ruolo='png_attacca' AND c.stato='accettata' AND e.pg_message_id IS NOT DISTINCT FROM c.pg_message_id
  AND b.risultato->>'validator_version'='MISSION-EXAM-SESSION-001'
  AND b.risultato->'ok'='true'::jsonb AND b.risultato->'publishable'='true'::jsonb
  AND c.intenzione_id=b.risultato#>>'{uscita,intenzione_id}'
  AND c.azione_png=btrim(b.risultato#>>'{uscita,azione_png}')
  AND m.kind='sistema' AND m.author_name='Il narratore' AND m.character_id IS NULL AND m.sender_user IS NULL
  AND NOT EXISTS(SELECT 1 FROM public.esame_narrazione_cicli x WHERE x.prova_id=e.id AND x.created_at>c.created_at)
  AND (m.body=c.azione_png OR EXISTS(
    SELECT 1 FROM mission_exam_private.editorial_requests er
    JOIN mission_exam_private.editorial_events ev ON ev.request_id=er.id AND ev.event='published'
    WHERE er.draft_id=b.id AND er.state='published' AND er.message_id=m.id AND ev.data->>'testo'=m.body))
 ORDER BY b.pubblicata_at DESC,b.id DESC LIMIT 1
$function$;
CREATE OR REPLACE FUNCTION public.esame_session_editorial_target(p_prova uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE b public.esame_supervisione_bozze%rowtype; r mission_exam_private.editorial_requests%rowtype;
BEGIN
 IF auth.uid() IS NULL OR NOT public._esame_session_scope(p_prova,auth.uid()) THEN
  RAISE EXCEPTION 'editorial_owner_required' USING ERRCODE='42501'; END IF;
 SELECT * INTO b FROM public.esame_supervisione_bozze WHERE prova=p_prova AND tipo='ciclo' AND stato='pubblicata'
  ORDER BY pubblicata_at DESC,id DESC LIMIT 1;
 IF b.id IS NULL THEN RETURN jsonb_build_object('ok',true,'draft_id',null,'status','unavailable'); END IF;
 SELECT * INTO r FROM mission_exam_private.editorial_requests WHERE draft_id=b.id;
 IF r.id IS NULL AND NOT EXISTS(
  SELECT 1 FROM public.esame_prove e
  JOIN mission_exam_private.protected_sessions q ON q.prova_id=e.id
  JOIN public.esame_narrazione_cicli c ON c.prova_id=e.id AND c.opzioni_id=b.ricevuta
  JOIN public.messages m ON m.id=c.action_message_id AND m.location_id=q.location_id
  WHERE e.id=p_prova AND b.autore=auth.uid() AND q.state='active' AND q.provider_calls<q.provider_call_cap
   AND b.risultato->>'validator_version'='MISSION-EXAM-SESSION-001'
   AND b.risultato->'ok'='true'::jsonb AND b.risultato->'publishable'='true'::jsonb
   AND c.intenzione_id=b.risultato#>>'{uscita,intenzione_id}' AND c.stato='accettata' AND c.ruolo='png_attacca'
   AND e.meta='png' AND e.fase='difesa' AND e.pg_message_id IS NOT DISTINCT FROM c.pg_message_id
   AND m.body=btrim(b.risultato#>>'{uscita,azione_png}') AND c.azione_png=m.body
   AND m.kind='sistema' AND m.author_name='Il narratore' AND m.character_id IS NULL AND m.sender_user IS NULL
   AND NOT EXISTS(SELECT 1 FROM public.esame_narrazione_cicli x WHERE x.prova_id=e.id AND x.created_at>c.created_at)
 ) THEN RETURN jsonb_build_object('ok',true,'draft_id',null,'status','unavailable'); END IF;
 RETURN jsonb_build_object('ok',true,'draft_id',b.id,'status',coalesce(r.state,'available'));
END $function$;
COMMIT;
