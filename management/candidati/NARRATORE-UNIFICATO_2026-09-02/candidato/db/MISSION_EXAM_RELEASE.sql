-- SESSION Tamako/Konoha: unica transazione, gate iniziale disabilitato.
BEGIN;
-- SESSION-TAMAKO-001 · CANDIDATO OFFLINE, NON VERIFICATO, NON APPLY-READY.
-- Autorità, porte owner/SERVICE e isolamento dei writer. Applicazione solo
-- atomica con MISSION_EXAM_SESSION.sql dopo freeze, QA e review nominativa.
-- Nessun enable, nuova prova, cambio ruolo o dati PG in questo sorgente.

CREATE SCHEMA mission_exam_private;
REVOKE ALL ON SCHEMA mission_exam_private FROM PUBLIC, anon, authenticated, service_role;

CREATE TABLE mission_exam_private.protected_sessions (
  class_session_id uuid PRIMARY KEY
    REFERENCES public.academy_class_sessions(id) DEFERRABLE INITIALLY DEFERRED,
  prova_id uuid UNIQUE REFERENCES public.esame_prove(id) DEFERRABLE INITIALLY DEFERRED,
  owner_user uuid NOT NULL,
  character_id uuid NOT NULL REFERENCES public.characters(id),
  location_id uuid NOT NULL REFERENCES public.locations(id),
  request_id uuid NOT NULL,
  policy_version text NOT NULL DEFAULT 'tamako-konoha-no-progression/1',
  state text NOT NULL DEFAULT 'opening',
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  closed_at timestamptz,
  provider_calls integer NOT NULL DEFAULT 0,
  provider_call_cap integer NOT NULL,
  UNIQUE(owner_user, request_id),
  CHECK(character_id = 'f335b077-34a1-41c3-94aa-58ec674b649b'::uuid),
  CHECK(location_id = 'df83cd65-b13d-49d6-ad77-a44f35d5ea00'::uuid),
  CHECK(policy_version = 'tamako-konoha-no-progression/1'),
  CHECK(state IN ('opening','active','paused','closed')),
  CHECK(provider_call_cap > 0 AND provider_calls BETWEEN 0 AND provider_call_cap),
  CHECK((state='closed') = (closed_at IS NOT NULL))
);
ALTER TABLE mission_exam_private.protected_sessions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON mission_exam_private.protected_sessions FROM PUBLIC,anon,authenticated,service_role;

-- L'identità protetta non può essere spostata su un'altra prova o altro owner.
CREATE FUNCTION mission_exam_private.guard_identity()
RETURNS trigger LANGUAGE plpgsql SET search_path='' AS $fn$
BEGIN
  IF TG_OP='UPDATE' AND (
    NEW.class_session_id IS DISTINCT FROM OLD.class_session_id OR
    NEW.owner_user IS DISTINCT FROM OLD.owner_user OR
    NEW.character_id IS DISTINCT FROM OLD.character_id OR
    NEW.location_id IS DISTINCT FROM OLD.location_id OR
    NEW.request_id IS DISTINCT FROM OLD.request_id OR
    NEW.policy_version IS DISTINCT FROM OLD.policy_version OR
    NEW.provider_call_cap IS DISTINCT FROM OLD.provider_call_cap OR
    (OLD.prova_id IS NOT NULL AND NEW.prova_id IS DISTINCT FROM OLD.prova_id)
  ) THEN RAISE EXCEPTION 'mission_session_identity_immutable' USING ERRCODE='22023'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.characters c WHERE c.id=NEW.character_id AND c.user_id=NEW.owner_user)
  THEN RAISE EXCEPTION 'mission_session_owner_invalid' USING ERRCODE='42501'; END IF;
  RETURN NEW;
END $fn$;
REVOKE ALL ON FUNCTION mission_exam_private.guard_identity() FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER protected_sessions_identity BEFORE INSERT OR UPDATE ON mission_exam_private.protected_sessions
FOR EACH ROW EXECUTE FUNCTION mission_exam_private.guard_identity();

-- Scope di pubblicazione/generazione soltanto; la lettura owner di una prova
-- conclusa avrà una porta distinta. Non è da solo un permesso di claim/publish.
CREATE FUNCTION public._esame_session_scope(p_prova uuid,p_user uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
  SELECT p_user IS NOT NULL AND EXISTS (
    SELECT 1 FROM public.esame_prove v
    JOIN public.academy_class_sessions s ON s.id=v.class_session_id
    JOIN public.characters c ON c.id=v.candidate_character AND c.user_id=v.candidate_user
    JOIN public.locations l ON l.id=s.location_id
    JOIN public.esame_supervisione h ON h.prova=v.id AND h.chiusa_at IS NULL
    WHERE v.id=p_prova AND v.candidate_user=p_user AND v.stato='aperta'
      AND s.state<>'closed' AND l.is_active
      AND (
        EXISTS (SELECT 1 FROM mission_exam_private.protected_sessions q
          WHERE q.class_session_id=s.id AND q.prova_id=v.id
            AND q.owner_user=p_user AND q.character_id=c.id AND q.location_id=l.id
            AND q.policy_version='tamako-konoha-no-progression/1' AND q.state='active'
            AND c.id='f335b077-34a1-41c3-94aa-58ec674b649b'::uuid
            AND l.id='df83cd65-b13d-49d6-ad77-a44f35d5ea00'::uuid
            AND NOT l.is_test AND l.is_exam_room AND l.is_academy)
        OR (
          l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
          AND l.is_test AND l.is_exam_room AND l.is_academy
          AND lower(c.name) IN ('riuji','testperfunzioni')
          AND EXISTS(SELECT 1 FROM public.profiles p WHERE p.id=p_user AND p.role IN ('admin','master'))
        )
      )
  );
$fn$;
REVOKE ALL ON FUNCTION public._esame_session_scope(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public._esame_session_scope(uuid,uuid) TO service_role;

-- Lease fissa 150s: timeout provider120s +30s margine. Non è un timer di
-- chiusura della prova. Close è sempre volontario e autenticato.
CREATE FUNCTION public.esame_session_close(p_prova uuid,p_request uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE
  q mission_exam_private.protected_sessions%ROWTYPE;
  v public.esame_prove%ROWTYPE;
  h public.esame_supervisione%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL OR p_request IS NULL THEN
    RAISE EXCEPTION 'mission_session_auth_required' USING ERRCODE='42501'; END IF;
  SELECT * INTO q FROM mission_exam_private.protected_sessions
    WHERE prova_id=p_prova AND owner_user=auth.uid();
  IF NOT FOUND OR NOT EXISTS(SELECT 1 FROM public.characters c
    WHERE c.id=q.character_id AND c.user_id=auth.uid()) THEN
    RAISE EXCEPTION 'mission_session_not_owned' USING ERRCODE='42501'; END IF;
  -- Ordine lock: prova, HOLD, policy, bozze. Identico al futuro claim.
  SELECT * INTO STRICT v FROM public.esame_prove WHERE id=p_prova FOR UPDATE;
  SELECT * INTO STRICT h FROM public.esame_supervisione WHERE prova=p_prova FOR UPDATE;
  SELECT * INTO STRICT q FROM mission_exam_private.protected_sessions
    WHERE prova_id=p_prova AND owner_user=auth.uid() FOR UPDATE;
  IF v.candidate_user IS DISTINCT FROM auth.uid()
    OR v.candidate_character IS DISTINCT FROM q.character_id
    OR v.class_session_id IS DISTINCT FROM q.class_session_id THEN
    RAISE EXCEPTION 'mission_session_scope_drift' USING ERRCODE='42501'; END IF;
  IF q.state='closed' THEN
    RETURN jsonb_build_object('ok',true,'prova',p_prova,'closed',true,'protected',true);
  END IF;
  IF h.publishing THEN RAISE EXCEPTION 'mission_session_publishing' USING ERRCODE='55000'; END IF;
  PERFORM 1 FROM public.esame_supervisione_bozze WHERE prova=p_prova ORDER BY id FOR UPDATE;
  IF EXISTS(SELECT 1 FROM public.esame_supervisione_bozze b WHERE b.prova=p_prova
    AND b.stato='generazione' AND (b.claimed_at IS NULL OR b.claimed_at > clock_timestamp()-interval '150 seconds')) THEN
    RAISE EXCEPTION 'mission_session_generation_in_flight' USING ERRCODE='55000'; END IF;
  -- Se il processo provider è caduto, la bozza non resta depositabile. Il
  -- vecchio deposit richiede generazione: una risposta tardiva verrà respinta.
  UPDATE public.esame_supervisione_bozze SET stato='errore'
    WHERE prova=p_prova AND stato='generazione';
  UPDATE public.esame_prove SET stato='annullata',closed_at=clock_timestamp(),
    close_reason='cancelled',opzioni_png=NULL,opzioni_id=NULL,opzioni_at=NULL
    WHERE id=p_prova AND stato='aperta';
  UPDATE public.esame_narrazione_cicli SET stato='scartata'
    WHERE prova_id=p_prova AND stato IN ('aperta','accettata');
  UPDATE public.esame_supervisione SET chiusa_at=clock_timestamp(),
    motivo_chiusura='session_owner_close',player_ready=false,publishing=false,idle_deadline=NULL
    WHERE prova=p_prova;
  UPDATE public.esame_supervisione_prenotazioni reservation SET is_active=false
    FROM public.esame_supervisione hold_row
    WHERE hold_row.prova=p_prova AND reservation.id=hold_row.prenotazione
      AND reservation.prova=p_prova AND reservation.is_active;
  UPDATE public.academy_class_sessions SET state='closed',closed_at=clock_timestamp(),
    close_reason='cancelled',force_next=false
    WHERE id=q.class_session_id AND state<>'closed'
      AND NOT EXISTS(SELECT 1 FROM public.esame_prove x WHERE x.class_session_id=q.class_session_id AND x.stato='aperta');
  UPDATE mission_exam_private.protected_sessions SET state='closed',closed_at=clock_timestamp()
    WHERE class_session_id=q.class_session_id;
  RETURN jsonb_build_object('ok',true,'prova',p_prova,'closed',true,'protected',true);
END $fn$;
REVOKE ALL ON FUNCTION public.esame_session_close(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.esame_session_close(uuid,uuid) TO authenticated;

CREATE FUNCTION public.esame_session_state(p_prova uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE q mission_exam_private.protected_sessions%ROWTYPE;
  v public.esame_prove%ROWTYPE; h public.esame_supervisione%ROWTYPE;
  b public.esame_supervisione_bozze%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'mission_session_auth_required' USING ERRCODE='42501'; END IF;
  SELECT * INTO q FROM mission_exam_private.protected_sessions
    WHERE prova_id=p_prova AND owner_user=auth.uid();
  IF NOT FOUND OR NOT EXISTS(SELECT 1 FROM public.characters c WHERE c.id=q.character_id AND c.user_id=auth.uid())
    THEN RAISE EXCEPTION 'mission_session_not_owned' USING ERRCODE='42501'; END IF;
  SELECT * INTO STRICT v FROM public.esame_prove WHERE id=p_prova AND candidate_user=auth.uid()
    AND candidate_character=q.character_id AND class_session_id=q.class_session_id;
  SELECT * INTO STRICT h FROM public.esame_supervisione WHERE prova=p_prova;
  SELECT * INTO b FROM public.esame_supervisione_bozze WHERE prova=p_prova AND autore=auth.uid()
    AND ricevuta=(CASE WHEN h.apertura_pubblicata THEN v.opzioni_id ELSE h.apertura_ricevuta END)
    ORDER BY autorizzata_at DESC,id DESC LIMIT 1;
  RETURN jsonb_build_object('ok',true,'prova',p_prova,'protected',true,
    'version','MISSION-EXAM-SESSION-001','status',v.stato,'phase',v.fase,
    'receipt_id',CASE WHEN h.apertura_pubblicata THEN v.opzioni_id ELSE h.apertura_ricevuta END,
    'player_ready',h.player_ready,'publishing',h.publishing,'opening_published',h.apertura_pubblicata,
    'closed',q.state='closed' OR v.stato<>'aperta',
    'budget',jsonb_build_object('used',q.provider_calls,'limit',q.provider_call_cap),
    'draft',CASE WHEN b.id IS NULL THEN NULL ELSE jsonb_build_object(
      'id',b.id,'status',b.stato,'sha',b.sha,
      'result_ok',coalesce(b.risultato->>'ok'='true',false),
      'publishable',coalesce(b.risultato->>'publishable'='true',false),
      'version',b.risultato->>'validator_version') END,
    'error',CASE WHEN b.stato='errore' THEN 'generation_error' ELSE NULL END);
END $fn$;
REVOKE ALL ON FUNCTION public.esame_session_state(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.esame_session_state(uuid) TO authenticated;

CREATE TABLE mission_exam_private.dispatches (
  prova_id uuid NOT NULL REFERENCES public.esame_prove(id),
  receipt_id uuid NOT NULL,
  draft_id uuid NOT NULL UNIQUE REFERENCES public.esame_supervisione_bozze(id),
  claimed_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  PRIMARY KEY(prova_id,receipt_id)
);
ALTER TABLE mission_exam_private.dispatches ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON mission_exam_private.dispatches FROM PUBLIC,anon,authenticated,service_role;

CREATE FUNCTION public.esame_session_authorize(p_prova uuid,p_ricevuta uuid)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE v public.esame_prove%ROWTYPE; h public.esame_supervisione%ROWTYPE;
  q mission_exam_private.protected_sessions%ROWTYPE; bid uuid; rid uuid; typ text;
BEGIN
  IF auth.uid() IS NULL OR p_ricevuta IS NULL OR NOT public._esame_session_scope(p_prova,auth.uid())
    THEN RAISE EXCEPTION 'mission_session_scope_denied' USING ERRCODE='42501'; END IF;
  SELECT * INTO STRICT v FROM public.esame_prove WHERE id=p_prova FOR UPDATE;
  SELECT * INTO STRICT h FROM public.esame_supervisione WHERE prova=p_prova FOR UPDATE;
  SELECT * INTO STRICT q FROM mission_exam_private.protected_sessions
    WHERE prova_id=p_prova AND owner_user=auth.uid() FOR UPDATE;
  IF NOT public._esame_session_scope(p_prova,auth.uid()) OR h.player_ready OR h.publishing
    THEN RAISE EXCEPTION 'mission_session_not_waiting' USING ERRCODE='55000'; END IF;
  rid:=CASE WHEN h.apertura_pubblicata THEN v.opzioni_id ELSE h.apertura_ricevuta END;
  typ:=CASE WHEN h.apertura_pubblicata THEN 'ciclo' ELSE 'apertura' END;
  IF rid IS NULL OR rid IS DISTINCT FROM p_ricevuta
    THEN RAISE EXCEPTION 'mission_session_receipt_stale' USING ERRCODE='40001'; END IF;
  SELECT id INTO bid FROM public.esame_supervisione_bozze
    WHERE prova=p_prova AND ricevuta=rid AND autore=auth.uid()
    ORDER BY autorizzata_at,id LIMIT 1;
  IF bid IS NOT NULL THEN RETURN bid; END IF;
  IF q.provider_calls>=q.provider_call_cap
    THEN RAISE EXCEPTION 'mission_session_call_limit' USING ERRCODE='55000'; END IF;
  INSERT INTO public.esame_supervisione_bozze(prova,ricevuta,tipo,autore)
    VALUES(p_prova,rid,typ,auth.uid()) RETURNING id INTO bid;
  RETURN bid;
END $fn$;
REVOKE ALL ON FUNCTION public.esame_session_authorize(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.esame_session_authorize(uuid,uuid) TO authenticated;

CREATE FUNCTION public._esame_session_claim(p_bozza uuid,p_user uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b public.esame_supervisione_bozze%ROWTYPE;
  q mission_exam_private.protected_sessions%ROWTYPE; payload jsonb;
BEGIN
  SELECT * INTO STRICT b FROM public.esame_supervisione_bozze WHERE id=p_bozza;
  PERFORM 1 FROM public.esame_prove WHERE id=b.prova FOR UPDATE;
  PERFORM 1 FROM public.esame_supervisione WHERE prova=b.prova FOR UPDATE;
  SELECT * INTO STRICT q FROM mission_exam_private.protected_sessions
    WHERE prova_id=b.prova AND owner_user=p_user FOR UPDATE;
  SELECT * INTO STRICT b FROM public.esame_supervisione_bozze WHERE id=p_bozza FOR UPDATE;
  IF b.autore IS DISTINCT FROM p_user OR NOT public._esame_session_scope(b.prova,p_user)
    THEN RAISE EXCEPTION 'mission_session_scope_denied' USING ERRCODE='42501'; END IF;
  IF EXISTS(SELECT 1 FROM mission_exam_private.dispatches WHERE prova_id=b.prova AND receipt_id=b.ricevuta)
    THEN RAISE EXCEPTION 'mission_session_already_dispatched' USING ERRCODE='55000'; END IF;
  IF q.provider_calls>=q.provider_call_cap
    THEN RAISE EXCEPTION 'mission_session_call_limit' USING ERRCODE='55000'; END IF;
  -- L'authority già esistente congela il payload e verifica stato/ricevuta.
  -- La transazione intera torna indietro se qualunque check fallisce.
  payload:=public._esame_supervisione_claim(p_bozza,p_user);
  INSERT INTO mission_exam_private.dispatches(prova_id,receipt_id,draft_id)
    VALUES(b.prova,b.ricevuta,b.id);
  UPDATE mission_exam_private.protected_sessions SET provider_calls=provider_calls+1
    WHERE class_session_id=q.class_session_id;
  RETURN payload;
END $fn$;
REVOKE ALL ON FUNCTION public._esame_session_claim(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public._esame_session_claim(uuid,uuid) TO service_role;

CREATE FUNCTION public.esame_session_publish(p_bozza uuid,p_sha text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b public.esame_supervisione_bozze%ROWTYPE; published_result jsonb;
BEGIN
  SELECT * INTO b FROM public.esame_supervisione_bozze WHERE id=p_bozza;
  IF auth.uid() IS NULL OR b.autore IS DISTINCT FROM auth.uid()
    OR NOT public._esame_session_scope(b.prova,auth.uid())
    OR NOT EXISTS(SELECT 1 FROM mission_exam_private.protected_sessions q
      WHERE q.prova_id=b.prova AND q.owner_user=auth.uid()) THEN
    RAISE EXCEPTION 'mission_session_scope_denied' USING ERRCODE='42501'; END IF;
  -- Il publisher SESSION del cantiere verifica lock, hash, receipt corrente,
  -- risultato/validator e atomicità. Nessuna duplicazione del suo corpo.
  published_result:=public.esame_supervisione_pubblica(p_bozza,p_sha);
  IF jsonb_typeof(published_result) IS DISTINCT FROM 'object'
    OR NOT EXISTS(SELECT 1 FROM public.esame_supervisione_bozze published_draft
      WHERE published_draft.id=p_bozza AND published_draft.autore=auth.uid()
        AND published_draft.sha=p_sha AND published_draft.stato='pubblicata') THEN
    RAISE EXCEPTION 'mission_session_publication_not_confirmed'; END IF;
  RETURN (published_result-'ok'-'pubblicato')||jsonb_build_object(
    'ok',true,'pubblicato',true,'publication_label',published_result->>'pubblicato');
END $fn$;
REVOKE ALL ON FUNCTION public.esame_session_publish(uuid,text) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.esame_session_publish(uuid,text) TO authenticated;

CREATE TABLE mission_exam_private.release_gate (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
  enabled boolean NOT NULL DEFAULT false,
  provider_call_cap integer CHECK(provider_call_cap>0),
  CHECK(NOT enabled OR provider_call_cap IS NOT NULL)
);
INSERT INTO mission_exam_private.release_gate(singleton) VALUES(true);
ALTER TABLE mission_exam_private.release_gate ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON mission_exam_private.release_gate FROM PUBLIC,anon,authenticated,service_role;

CREATE TABLE mission_exam_private.open_requests (
  request_id uuid PRIMARY KEY,
  owner_user uuid NOT NULL,
  transaction_id bigint NOT NULL,
  class_session_id uuid UNIQUE,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE(transaction_id,owner_user)
);
ALTER TABLE mission_exam_private.open_requests ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON mission_exam_private.open_requests FROM PUBLIC,anon,authenticated,service_role;

-- BEFORE INSERT cattura l'ID generato dal percorso normale esame_avvia:
-- la policy esiste prima dei trigger AFTER e senza riscrivere l'ingresso.
CREATE FUNCTION mission_exam_private.bind_class_session()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE req mission_exam_private.open_requests%ROWTYPE; cap integer;
BEGIN
  SELECT * INTO req FROM mission_exam_private.open_requests
    WHERE transaction_id=txid_current() AND owner_user=NEW.started_by AND class_session_id IS NULL FOR UPDATE;
  IF NOT FOUND THEN RETURN NEW; END IF;
  IF auth.uid() IS DISTINCT FROM req.owner_user
    OR NEW.location_id<>'df83cd65-b13d-49d6-ad77-a44f35d5ea00'::uuid THEN
    RAISE EXCEPTION 'mission_session_open_scope' USING ERRCODE='42501'; END IF;
  SELECT provider_call_cap INTO STRICT cap FROM mission_exam_private.release_gate WHERE singleton AND enabled;
  INSERT INTO mission_exam_private.protected_sessions
    (class_session_id,owner_user,character_id,location_id,request_id,provider_call_cap)
    VALUES(NEW.id,req.owner_user,'f335b077-34a1-41c3-94aa-58ec674b649b',NEW.location_id,req.request_id,cap);
  UPDATE mission_exam_private.open_requests SET class_session_id=NEW.id WHERE request_id=req.request_id;
  RETURN NEW;
END $fn$;
REVOKE ALL ON FUNCTION mission_exam_private.bind_class_session() FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER mission_session_bind BEFORE INSERT ON public.academy_class_sessions
  FOR EACH ROW EXECUTE FUNCTION mission_exam_private.bind_class_session();

CREATE FUNCTION mission_exam_private.bind_prova()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE q mission_exam_private.protected_sessions%ROWTYPE;
BEGIN
  SELECT * INTO q FROM mission_exam_private.protected_sessions
    WHERE class_session_id=NEW.class_session_id FOR UPDATE;
  IF NOT FOUND THEN RETURN NEW; END IF;
  IF q.state<>'opening' OR q.prova_id IS NOT NULL OR NEW.candidate_user<>q.owner_user
    OR NEW.candidate_character<>q.character_id THEN
    RAISE EXCEPTION 'mission_session_prova_binding' USING ERRCODE='42501'; END IF;
  UPDATE mission_exam_private.protected_sessions SET prova_id=NEW.id,state='active'
    WHERE class_session_id=NEW.class_session_id;
  RETURN NEW;
END $fn$;
REVOKE ALL ON FUNCTION mission_exam_private.bind_prova() FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER mission_session_bind BEFORE INSERT ON public.esame_prove
  FOR EACH ROW EXECUTE FUNCTION mission_exam_private.bind_prova();

CREATE FUNCTION public.esame_session_readiness()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE c public.characters%ROWTYPE; existing uuid; cap integer; enabled boolean; room_ok boolean;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'mission_session_auth_required' USING ERRCODE='42501'; END IF;
  SELECT * INTO c FROM public.characters WHERE id='f335b077-34a1-41c3-94aa-58ec674b649b' AND user_id=auth.uid();
  IF NOT FOUND THEN RETURN jsonb_build_object('ok',true,'eligible',false,'ready',false,'protected',false,
    'version','MISSION-EXAM-SESSION-001','existing_prova',NULL,'reason','not_eligible',
    'candidate_character',NULL,'location_id',NULL,'budget',NULL); END IF;
  SELECT g.enabled,g.provider_call_cap INTO STRICT enabled,cap FROM mission_exam_private.release_gate g WHERE singleton;
  SELECT q.prova_id INTO existing FROM mission_exam_private.protected_sessions q
    WHERE q.owner_user=auth.uid() AND q.state<>'closed' ORDER BY q.created_at DESC LIMIT 1;
  SELECT EXISTS(SELECT 1 FROM public.locations l JOIN combat_spatial.exam_arena_routes_v1 r ON r.class_location_id=l.id
    WHERE l.id='df83cd65-b13d-49d6-ad77-a44f35d5ea00' AND l.is_active AND NOT l.is_test
      AND l.is_exam_room AND l.is_academy AND r.enabled) INTO room_ok;
  RETURN jsonb_build_object('ok',true,'eligible',true,'ready',enabled AND cap IS NOT NULL AND room_ok,
    'protected',true,'version','MISSION-EXAM-SESSION-001','existing_prova',existing,
    'candidate_character',c.id,'location_id','df83cd65-b13d-49d6-ad77-a44f35d5ea00',
    'reason',CASE WHEN NOT enabled OR cap IS NULL THEN 'release_not_ready' WHEN NOT room_ok THEN 'arena_not_ready' ELSE NULL END,
    'budget',CASE WHEN cap IS NULL THEN NULL ELSE jsonb_build_object('used',0,'limit',cap) END);
END $fn$;
REVOKE ALL ON FUNCTION public.esame_session_readiness() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.esame_session_readiness() TO authenticated;

CREATE FUNCTION public.esame_session_open(p_request uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE ready jsonb; q mission_exam_private.protected_sessions%ROWTYPE; sess uuid; prova uuid;
BEGIN
  IF auth.uid() IS NULL OR p_request IS NULL THEN
    RAISE EXCEPTION 'mission_session_auth_required' USING ERRCODE='42501'; END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended('esame_supervisione:f335b077-34a1-41c3-94aa-58ec674b649b',0));
  ready:=public.esame_session_readiness();
  IF ready->>'eligible'<>'true' THEN RAISE EXCEPTION 'mission_session_not_owned' USING ERRCODE='42501'; END IF;
  SELECT * INTO q FROM mission_exam_private.protected_sessions
    WHERE owner_user=auth.uid() AND (request_id=p_request OR state<>'closed') ORDER BY created_at DESC LIMIT 1;
  IF FOUND THEN
    IF q.state='closed' THEN RAISE EXCEPTION 'mission_session_request_closed' USING ERRCODE='55000'; END IF;
    RETURN jsonb_build_object('ok',true,'prova',q.prova_id,'class_session_id',q.class_session_id,
      'protected',true,'version','MISSION-EXAM-SESSION-001');
  END IF;
  IF ready->>'ready'<>'true' THEN RAISE EXCEPTION 'mission_session_not_ready' USING ERRCODE='55000'; END IF;
  IF EXISTS(SELECT 1 FROM public.esame_prove WHERE candidate_user=auth.uid() AND stato='aperta')
    OR EXISTS(SELECT 1 FROM public.esame_supervisione_prenotazioni WHERE personaggio='f335b077-34a1-41c3-94aa-58ec674b649b' AND is_active)
    THEN RAISE EXCEPTION 'mission_session_existing_activity' USING ERRCODE='55000'; END IF;
  INSERT INTO mission_exam_private.open_requests(request_id,owner_user,transaction_id)
    VALUES(p_request,auth.uid(),txid_current());
  INSERT INTO public.esame_supervisione_prenotazioni(personaggio,luogo,autore)
    VALUES('f335b077-34a1-41c3-94aa-58ec674b649b','df83cd65-b13d-49d6-ad77-a44f35d5ea00',auth.uid());
  -- Prerequisiti, profilo avversario, risorse temporanee e mappa: percorso vivo.
  sess:=public.esame_avvia('df83cd65-b13d-49d6-ad77-a44f35d5ea00');
  SELECT q1.prova_id INTO STRICT prova FROM mission_exam_private.protected_sessions q1
    JOIN public.esame_supervisione h ON h.prova=q1.prova_id
    WHERE q1.class_session_id=sess AND q1.owner_user=auth.uid() AND q1.state='active';
  IF NOT public._esame_session_scope(prova,auth.uid()) THEN
    RAISE EXCEPTION 'mission_session_open_attestation_failed' USING ERRCODE='42501'; END IF;
  RETURN jsonb_build_object('ok',true,'prova',prova,'class_session_id',sess,
    'protected',true,'version','MISSION-EXAM-SESSION-001');
END $fn$;
REVOKE ALL ON FUNCTION public.esame_session_open(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.esame_session_open(uuid) TO authenticated;

CREATE FUNCTION mission_exam_private.is_protected(p_prova uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT EXISTS(SELECT 1 FROM mission_exam_private.protected_sessions WHERE prova_id=p_prova);
$fn$;
REVOKE ALL ON FUNCTION mission_exam_private.is_protected(uuid) FROM PUBLIC,anon,authenticated,service_role;

CREATE TABLE mission_exam_private.protected_messages (
  -- Nessuna FK verso messages: archiviazione ordinaria dei messaggi invariata.
  message_id uuid PRIMARY KEY,
  prova_id uuid NOT NULL REFERENCES public.esame_prove(id)
);
ALTER TABLE mission_exam_private.protected_messages ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON mission_exam_private.protected_messages FROM PUBLIC,anon,authenticated,service_role;

CREATE TABLE mission_exam_private.lifecycle_transactions (
  transaction_id bigint PRIMARY KEY,
  class_session_id uuid NOT NULL REFERENCES public.academy_class_sessions(id) DEFERRABLE INITIALLY DEFERRED
);
ALTER TABLE mission_exam_private.lifecycle_transactions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON mission_exam_private.lifecycle_transactions FROM PUBLIC,anon,authenticated,service_role;
CREATE FUNCTION mission_exam_private.mark_lifecycle()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
BEGIN
 IF EXISTS(SELECT 1 FROM mission_exam_private.protected_sessions WHERE class_session_id=NEW.id) THEN
   INSERT INTO mission_exam_private.lifecycle_transactions(transaction_id,class_session_id)
     VALUES(txid_current(),NEW.id) ON CONFLICT(transaction_id) DO NOTHING;
 END IF;
 RETURN NEW;
END $fn$;
REVOKE ALL ON FUNCTION mission_exam_private.mark_lifecycle() FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER zz_mission_session_lifecycle BEFORE INSERT OR UPDATE ON public.academy_class_sessions
 FOR EACH ROW EXECUTE FUNCTION mission_exam_private.mark_lifecycle();

-- Baseline e fingerprint dei soli corpi modificati. Conservati per recovery;
-- nessun DROP o cancellazione di storia/righe della prova.
CREATE TABLE mission_exam_private.function_backups (
  signature text PRIMARY KEY,
  original_definition text NOT NULL,
  candidate_definition text NOT NULL
);
ALTER TABLE mission_exam_private.function_backups ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON mission_exam_private.function_backups FROM PUBLIC,anon,authenticated,service_role;


-- Patch esatte di corpi LIVE congelati: confronto integrale prima modifica.
DO $patch$
DECLARE original text:=$original$CREATE OR REPLACE FUNCTION public._trg_academy_overflow()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  perform public._academy_overflow_sync();
  return null;
end $function$
$original$;
 candidate text:=$candidate$CREATE OR REPLACE FUNCTION public._trg_academy_overflow()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if exists(select 1 from mission_exam_private.lifecycle_transactions where transaction_id=txid_current()) then return null; end if;
  perform public._academy_overflow_sync();
  return null;
end $function$
$candidate$;
BEGIN
 IF pg_get_functiondef('public._trg_academy_overflow()'::regprocedure) IS DISTINCT FROM original THEN RAISE EXCEPTION 'mission_session_baseline_drift: _trg_academy_overflow'; END IF;
 INSERT INTO mission_exam_private.function_backups VALUES('public._trg_academy_overflow()',original,candidate);
 EXECUTE candidate;
END $patch$;

DO $patch$
DECLARE original text:=$original$CREATE OR REPLACE FUNCTION public.trg_role_autojoin()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_sess uuid; v_uid uuid; v_cname text;
  v_gettone text; v_len int := -1;
  v_lname text; v_ltest boolean;
  v_quando timestamptz := coalesce(NEW.created_at, now());
begin
  -- [ROLE-REC-AUTOSTART-006] Il gettone si legge e si consuma SEMPRE, per primo,
  -- anche quando questa riga non ne ha diritto: e' monouso per costruzione, cosi'
  -- nessun messaggio inserito dopo, nella stessa transazione, puo' ereditarlo.
  -- Lo deposita soltanto post_message, subito prima del proprio insert, e porta
  -- il conteggio che ha calcolato il server: il luogo davanti ai due punti, la
  -- lunghezza dopo. Nessun'altra funzione che scrive in messages lo deposita,
  -- quindi un tiro di dado, un referto o una riga d'Accademia non aprono REC.
  v_gettone := nullif(current_setting('app.role_turno', true), '');
  if v_gettone is not null then
    perform set_config('app.role_turno', '', true);
    if split_part(v_gettone, ':', 1) = NEW.location_id::text then
      v_len := coalesce(nullif(split_part(v_gettone, ':', 2), '')::int, -1);
    end if;
  end if;

  if not public._role_msg_valido(NEW.kind, NEW.character_id, NEW.recipient_user) then
    return NEW;
  end if;

  select id into v_sess from public.role_sessions
   where location_id = NEW.location_id and closed_at is null
   order by started_at desc limit 1;

  select user_id, name into v_uid, v_cname from public.characters where id = NEW.character_id;
  if v_uid is null then return NEW; end if;

  if v_sess is null then
    -- [ROLE-REC-AUTOSTART-006] Apertura automatica della REC generale. Tre porte,
    -- tutte chiuse per difetto: serve il gettone di post_message, quel conteggio
    -- deve arrivare alla soglia, e il luogo non puo' essere una stanza di prova.
    -- Se anche una sola manca si esce come prima, senza registrare niente: e'
    -- esattamente il comportamento precedente a questa migrazione.
    if v_len < public._role_soglia_apertura() then return NEW; end if;

    select l.name, coalesce(l.is_test,false) into v_lname, v_ltest
      from public.locations l where l.id = NEW.location_id;
    if not found or v_ltest then return NEW; end if;

    -- record_from prende il created_at del messaggio che apre, non now(): il turno
    -- che ha aperto la REC deve cadere DENTRO la finestra, mai un istante prima.
    insert into public.role_sessions
        (location_id, location_name, started_by, starter_name, title, started_at, record_from)
    values (NEW.location_id, v_lname, v_uid, v_cname,
            'Role · ' || coalesce(v_lname,'Luogo'), v_quando, v_quando)
    on conflict (location_id) where closed_at is null do nothing
    returning id into v_sess;

    -- Corsa fra due primi turni nello stesso luogo: chi arriva secondo aspetta
    -- l'indice unico parziale, non inserisce niente, e qui rilegge la REC che ha
    -- aperto l'altro. Da li' in poi prende la strada normale del conteggio, e
    -- ciascuno dei due messaggi vale un turno, una volta sola.
    if v_sess is null then
      select id into v_sess from public.role_sessions
       where location_id = NEW.location_id and closed_at is null
       order by started_at desc limit 1;
    end if;
    if v_sess is null then return NEW; end if;
  end if;

  -- strada veloce
  update public.role_session_participants
     set message_count    = message_count + 1,
         last_message_at  = greatest(coalesce(last_message_at, NEW.created_at), NEW.created_at),
         first_message_at = least(coalesce(first_message_at, NEW.created_at), NEW.created_at)
   where session_id = v_sess and user_id = v_uid and ha_contribuito;
  if found then return NEW; end if;

  -- strada lenta: la sessione deve essere ancora aperta, e resta bloccata
  -- fino alla fine di questa transazione.
  perform 1 from public.role_sessions
   where id = v_sess and closed_at is null for no key update;
  if not found then return NEW; end if;

  insert into public.role_session_participants
      (session_id, user_id, character_id, character_name,
       message_count, first_message_at, last_message_at)
  values (v_sess, v_uid, NEW.character_id, v_cname,
       1, NEW.created_at, NEW.created_at)
  on conflict (session_id, user_id) do update
     set message_count    = role_session_participants.message_count + 1,
         first_message_at = least(coalesce(role_session_participants.first_message_at, NEW.created_at), NEW.created_at),
         last_message_at  = greatest(coalesce(role_session_participants.last_message_at, NEW.created_at), NEW.created_at),
         character_id     = coalesce(role_session_participants.character_id, NEW.character_id),
         character_name   = coalesce(role_session_participants.character_name, v_cname);
  return NEW;
end; $function$
$original$;
 candidate text:=$candidate$CREATE OR REPLACE FUNCTION public.trg_role_autojoin()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_sess uuid; v_uid uuid; v_cname text;
  v_gettone text; v_len int := -1;
  v_lname text; v_ltest boolean;
  v_quando timestamptz := coalesce(NEW.created_at, now());
begin
  if exists(select 1 from mission_exam_private.protected_messages pm where pm.message_id=NEW.id) then
    perform set_config('app.role_turno','',true); return NEW;
  end if;
  -- [ROLE-REC-AUTOSTART-006] Il gettone si legge e si consuma SEMPRE, per primo,
  -- anche quando questa riga non ne ha diritto: e' monouso per costruzione, cosi'
  -- nessun messaggio inserito dopo, nella stessa transazione, puo' ereditarlo.
  -- Lo deposita soltanto post_message, subito prima del proprio insert, e porta
  -- il conteggio che ha calcolato il server: il luogo davanti ai due punti, la
  -- lunghezza dopo. Nessun'altra funzione che scrive in messages lo deposita,
  -- quindi un tiro di dado, un referto o una riga d'Accademia non aprono REC.
  v_gettone := nullif(current_setting('app.role_turno', true), '');
  if v_gettone is not null then
    perform set_config('app.role_turno', '', true);
    if split_part(v_gettone, ':', 1) = NEW.location_id::text then
      v_len := coalesce(nullif(split_part(v_gettone, ':', 2), '')::int, -1);
    end if;
  end if;

  if not public._role_msg_valido(NEW.kind, NEW.character_id, NEW.recipient_user) then
    return NEW;
  end if;

  select id into v_sess from public.role_sessions
   where location_id = NEW.location_id and closed_at is null
   order by started_at desc limit 1;

  select user_id, name into v_uid, v_cname from public.characters where id = NEW.character_id;
  if v_uid is null then return NEW; end if;

  if v_sess is null then
    -- [ROLE-REC-AUTOSTART-006] Apertura automatica della REC generale. Tre porte,
    -- tutte chiuse per difetto: serve il gettone di post_message, quel conteggio
    -- deve arrivare alla soglia, e il luogo non puo' essere una stanza di prova.
    -- Se anche una sola manca si esce come prima, senza registrare niente: e'
    -- esattamente il comportamento precedente a questa migrazione.
    if v_len < public._role_soglia_apertura() then return NEW; end if;

    select l.name, coalesce(l.is_test,false) into v_lname, v_ltest
      from public.locations l where l.id = NEW.location_id;
    if not found or v_ltest then return NEW; end if;

    -- record_from prende il created_at del messaggio che apre, non now(): il turno
    -- che ha aperto la REC deve cadere DENTRO la finestra, mai un istante prima.
    insert into public.role_sessions
        (location_id, location_name, started_by, starter_name, title, started_at, record_from)
    values (NEW.location_id, v_lname, v_uid, v_cname,
            'Role · ' || coalesce(v_lname,'Luogo'), v_quando, v_quando)
    on conflict (location_id) where closed_at is null do nothing
    returning id into v_sess;

    -- Corsa fra due primi turni nello stesso luogo: chi arriva secondo aspetta
    -- l'indice unico parziale, non inserisce niente, e qui rilegge la REC che ha
    -- aperto l'altro. Da li' in poi prende la strada normale del conteggio, e
    -- ciascuno dei due messaggi vale un turno, una volta sola.
    if v_sess is null then
      select id into v_sess from public.role_sessions
       where location_id = NEW.location_id and closed_at is null
       order by started_at desc limit 1;
    end if;
    if v_sess is null then return NEW; end if;
  end if;

  -- strada veloce
  update public.role_session_participants
     set message_count    = message_count + 1,
         last_message_at  = greatest(coalesce(last_message_at, NEW.created_at), NEW.created_at),
         first_message_at = least(coalesce(first_message_at, NEW.created_at), NEW.created_at)
   where session_id = v_sess and user_id = v_uid and ha_contribuito;
  if found then return NEW; end if;

  -- strada lenta: la sessione deve essere ancora aperta, e resta bloccata
  -- fino alla fine di questa transazione.
  perform 1 from public.role_sessions
   where id = v_sess and closed_at is null for no key update;
  if not found then return NEW; end if;

  insert into public.role_session_participants
      (session_id, user_id, character_id, character_name,
       message_count, first_message_at, last_message_at)
  values (v_sess, v_uid, NEW.character_id, v_cname,
       1, NEW.created_at, NEW.created_at)
  on conflict (session_id, user_id) do update
     set message_count    = role_session_participants.message_count + 1,
         first_message_at = least(coalesce(role_session_participants.first_message_at, NEW.created_at), NEW.created_at),
         last_message_at  = greatest(coalesce(role_session_participants.last_message_at, NEW.created_at), NEW.created_at),
         character_id     = coalesce(role_session_participants.character_id, NEW.character_id),
         character_name   = coalesce(role_session_participants.character_name, v_cname);
  return NEW;
end; $function$
$candidate$;
BEGIN
 IF pg_get_functiondef('public.trg_role_autojoin()'::regprocedure) IS DISTINCT FROM original THEN RAISE EXCEPTION 'mission_session_baseline_drift: trg_role_autojoin'; END IF;
 INSERT INTO mission_exam_private.function_backups VALUES('public.trg_role_autojoin()',original,candidate);
 EXECUTE candidate;
END $patch$;

DO $patch$
DECLARE original text:=$original$CREATE OR REPLACE FUNCTION public._esame_testo_candidato(p_prova uuid, p_testo text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_nome text;
  v_msg uuid;
  v_location uuid;
  v_len int;
begin
  if p_testo is null then return null; end if;
  select * into v from public.esame_prove where id = p_prova;
  if not found then raise exception 'A10/§D: prova inesistente in pubblicazione'; end if;
  select c.name into v_nome from public.characters c where c.id = v.candidate_character;
  select s.location_id into v_location from public.academy_class_sessions s where s.id = v.class_session_id;
  if v_location is null then raise exception 'A10/§D: luogo della prova assente'; end if;

  v_len := length(btrim(public._combat_normalizza(p_testo)));
  perform set_config('app.role_turno', v_location::text || ':' || v_len::text, true);
  insert into public.messages (location_id, character_id, sender_user, author_name, body, kind)
  values (v_location, v.candidate_character, v.candidate_user, v_nome, p_testo, 'say')
  returning id into v_msg;

  update public.esame_prove set pg_message_id = v_msg where id = p_prova;
  return v_msg;
end
$function$
$original$;
 candidate text:=$candidate$CREATE OR REPLACE FUNCTION public._esame_testo_candidato(p_prova uuid, p_testo text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_nome text;
  v_msg uuid;
  v_location uuid;
  v_len int;
begin
  if p_testo is null then return null; end if;
  select * into v from public.esame_prove where id = p_prova;
  if not found then raise exception 'A10/§D: prova inesistente in pubblicazione'; end if;
  select c.name into v_nome from public.characters c where c.id = v.candidate_character;
  select s.location_id into v_location from public.academy_class_sessions s where s.id = v.class_session_id;
  if v_location is null then raise exception 'A10/§D: luogo della prova assente'; end if;

  if mission_exam_private.is_protected(p_prova) then
    v_msg:=gen_random_uuid();
    insert into mission_exam_private.protected_messages(message_id,prova_id) values(v_msg,p_prova);
    insert into public.messages(id,location_id,character_id,sender_user,author_name,body,kind)
      values(v_msg,v_location,v.candidate_character,v.candidate_user,v_nome,p_testo,'say');
    update public.esame_prove set pg_message_id=v_msg where id=p_prova;
    return v_msg;
  end if;
  v_len := length(btrim(public._combat_normalizza(p_testo)));
  perform set_config('app.role_turno', v_location::text || ':' || v_len::text, true);
  insert into public.messages (location_id, character_id, sender_user, author_name, body, kind)
  values (v_location, v.candidate_character, v.candidate_user, v_nome, p_testo, 'say')
  returning id into v_msg;

  update public.esame_prove set pg_message_id = v_msg where id = p_prova;
  return v_msg;
end
$function$
$candidate$;
BEGIN
 IF pg_get_functiondef('public._esame_testo_candidato(uuid,text)'::regprocedure) IS DISTINCT FROM original THEN RAISE EXCEPTION 'mission_session_baseline_drift: _esame_testo_candidato'; END IF;
 INSERT INTO mission_exam_private.function_backups VALUES('public._esame_testo_candidato(uuid,text)',original,candidate);
 EXECUTE candidate;
END $patch$;

DO $patch$
DECLARE original text:=$original$CREATE OR REPLACE FUNCTION public.esame_chiudi(p_session uuid)
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
end $function$
$original$;
 candidate text:=$candidate$CREATE OR REPLACE FUNCTION public.esame_chiudi(p_session uuid)
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
end $function$
$candidate$;
BEGIN
 IF pg_get_functiondef('public.esame_chiudi(uuid)'::regprocedure) IS DISTINCT FROM original THEN RAISE EXCEPTION 'mission_session_baseline_drift: esame_chiudi'; END IF;
 INSERT INTO mission_exam_private.function_backups VALUES('public.esame_chiudi(uuid)',original,candidate);
 EXECUTE candidate;
END $patch$;

DO $patch$
DECLARE original text:=$original$CREATE OR REPLACE FUNCTION public._exam_surface_qa_capture()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  r public.exam_surface_qa_runtime%rowtype;
  c public.esame_narrazione_cicli%rowtype;
  s jsonb;
  v_context_sha text;
  v_source_sha text;
  v_message_kind text;
  v_recipient uuid;
  v_message_body text;
  v_queue_id bigint;
begin
  begin
    select * into r from public.exam_surface_qa_runtime where singleton=true;
    if not found or not r.monitor_enabled or r.kill_switch then return new; end if;

    -- La fotografia diventa materializzabile soltanto DOPO che
    -- `_esame_png_turno` / `_esame_risolvi` hanno pubblicato sulla prova la
    -- stessa opzioni_id del ciclo. Un trigger sulla INSERT del ciclo scatta
    -- troppo presto: opzioni_png non e' ancora stata congelata sulla prova.
    if new.stato<>'aperta' or new.opzioni_id is null
       or jsonb_typeof(new.opzioni_png) is distinct from 'object' then
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,reason_code)
        values('excluded',null,'INCOMPLETE_SOURCE');
      return new;
    end if;

    select * into c
      from public.esame_narrazione_cicli x
     where x.prova_id=new.id and x.stato='aperta'
       and x.opzioni_id=new.opzioni_id
     order by x.created_at desc,x.id desc
     limit 1;
    if not found or c.pg_message_id is null
       or c.ruolo not in ('png_attacca','png_difende','png_esito','png_finale')
       -- Attacco e difesa descrivono una scelta ancora aperta e possono non
       -- avere referto; esito e finale narrano invece un fatto gia' risolto.
       or (c.ruolo in ('png_esito','png_finale')
           and jsonb_typeof(c.referto) is distinct from 'object') then
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,reason_code)
        values('excluded',c.id,'INCOMPLETE_SOURCE');
      return new;
    end if;

    select coalesce(m.kind,a.kind), coalesce(m.recipient_user,a.recipient_user),
           coalesce(m.body,a.body)
      into v_message_kind,v_recipient,v_message_body
      from (select 1) x
      left join public.messages m on m.id=c.pg_message_id
      left join public.messages_archive a on a.id=c.pg_message_id;
    if v_message_kind is distinct from 'say' or v_recipient is not null
       or v_message_body is null
       or v_message_body ~* '\[(ooc|off)\]' then
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,reason_code)
        values('excluded',c.id,case
          when v_message_body ~* '\[(ooc|off)\]' then 'OOC_SOURCE'
          else 'NON_PUBLIC_SAY' end);
      return new;
    end if;

    s := public.narrative_surface_seed_exam(new.id,1);
    if coalesce(s->>'state_version','') !~ '^[0-9a-f]{64}$'
       or jsonb_array_length(coalesce(s->'intents','[]'))=0
       or jsonb_array_length(coalesce(s->'facts','[]'))=0
       or jsonb_typeof(s->'persona') is distinct from 'object'
       or jsonb_array_length(coalesce(s->'environment','[]'))=0
       or jsonb_typeof(s->'deterministic_components') is distinct from 'array' then
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,reason_code)
        values('excluded',c.id,'SEED_INCOMPLETE');
      return new;
    end if;
    v_context_sha := encode(extensions.digest(s::text,'sha256'),'hex');
    v_source_sha := encode(extensions.digest(concat_ws('|',c.id,c.opzioni_id,
      s->>'state_version',v_context_sha),'sha256'),'hex');
    insert into public.exam_surface_qa_queue(
      source_prova_id,source_cycle_id,source_message_id,source_receipt_id,role,
      state_version,context_sha256,source_sha256,structural_metrics,expires_at)
    values(new.id,c.id,c.pg_message_id,c.opzioni_id,c.ruolo,
      s->>'state_version',v_context_sha,v_source_sha,
      jsonb_build_object('intents',jsonb_array_length(s->'intents'),
        'facts',jsonb_array_length(s->'facts'),
        'dialogue_frames',jsonb_array_length(coalesce(s->'dialogue_frames','[]')),
        'components',jsonb_array_length(s->'deterministic_components')),
      least(coalesce(r.trial_expires_at,now()+interval '24 hours'),now()+interval '24 hours'))
    on conflict do nothing returning id into v_queue_id;
    if v_queue_id is not null then
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,queue_id,reason_code,details)
      values('eligible',c.id,v_queue_id,'STRUCTURE_COMPLETE',
        jsonb_build_object('role',c.ruolo,'state_version',s->>'state_version'));
    end if;
  exception when others then
    -- Il monitor non può interrompere la transazione di gioco.
    begin
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,reason_code,details)
      values('excluded',c.id,'CAPTURE_ERROR',jsonb_build_object('sqlstate',sqlstate));
    exception when others then null;
    end;
    return new;
  end;
  return new;
end
$function$
$original$;
 candidate text:=$candidate$CREATE OR REPLACE FUNCTION public._exam_surface_qa_capture()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  r public.exam_surface_qa_runtime%rowtype;
  c public.esame_narrazione_cicli%rowtype;
  s jsonb;
  v_context_sha text;
  v_source_sha text;
  v_message_kind text;
  v_recipient uuid;
  v_message_body text;
  v_queue_id bigint;
begin
  if mission_exam_private.is_protected(NEW.id) then return NEW; end if;
  begin
    select * into r from public.exam_surface_qa_runtime where singleton=true;
    if not found or not r.monitor_enabled or r.kill_switch then return new; end if;

    -- La fotografia diventa materializzabile soltanto DOPO che
    -- `_esame_png_turno` / `_esame_risolvi` hanno pubblicato sulla prova la
    -- stessa opzioni_id del ciclo. Un trigger sulla INSERT del ciclo scatta
    -- troppo presto: opzioni_png non e' ancora stata congelata sulla prova.
    if new.stato<>'aperta' or new.opzioni_id is null
       or jsonb_typeof(new.opzioni_png) is distinct from 'object' then
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,reason_code)
        values('excluded',null,'INCOMPLETE_SOURCE');
      return new;
    end if;

    select * into c
      from public.esame_narrazione_cicli x
     where x.prova_id=new.id and x.stato='aperta'
       and x.opzioni_id=new.opzioni_id
     order by x.created_at desc,x.id desc
     limit 1;
    if not found or c.pg_message_id is null
       or c.ruolo not in ('png_attacca','png_difende','png_esito','png_finale')
       -- Attacco e difesa descrivono una scelta ancora aperta e possono non
       -- avere referto; esito e finale narrano invece un fatto gia' risolto.
       or (c.ruolo in ('png_esito','png_finale')
           and jsonb_typeof(c.referto) is distinct from 'object') then
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,reason_code)
        values('excluded',c.id,'INCOMPLETE_SOURCE');
      return new;
    end if;

    select coalesce(m.kind,a.kind), coalesce(m.recipient_user,a.recipient_user),
           coalesce(m.body,a.body)
      into v_message_kind,v_recipient,v_message_body
      from (select 1) x
      left join public.messages m on m.id=c.pg_message_id
      left join public.messages_archive a on a.id=c.pg_message_id;
    if v_message_kind is distinct from 'say' or v_recipient is not null
       or v_message_body is null
       or v_message_body ~* '\[(ooc|off)\]' then
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,reason_code)
        values('excluded',c.id,case
          when v_message_body ~* '\[(ooc|off)\]' then 'OOC_SOURCE'
          else 'NON_PUBLIC_SAY' end);
      return new;
    end if;

    s := public.narrative_surface_seed_exam(new.id,1);
    if coalesce(s->>'state_version','') !~ '^[0-9a-f]{64}$'
       or jsonb_array_length(coalesce(s->'intents','[]'))=0
       or jsonb_array_length(coalesce(s->'facts','[]'))=0
       or jsonb_typeof(s->'persona') is distinct from 'object'
       or jsonb_array_length(coalesce(s->'environment','[]'))=0
       or jsonb_typeof(s->'deterministic_components') is distinct from 'array' then
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,reason_code)
        values('excluded',c.id,'SEED_INCOMPLETE');
      return new;
    end if;
    v_context_sha := encode(extensions.digest(s::text,'sha256'),'hex');
    v_source_sha := encode(extensions.digest(concat_ws('|',c.id,c.opzioni_id,
      s->>'state_version',v_context_sha),'sha256'),'hex');
    insert into public.exam_surface_qa_queue(
      source_prova_id,source_cycle_id,source_message_id,source_receipt_id,role,
      state_version,context_sha256,source_sha256,structural_metrics,expires_at)
    values(new.id,c.id,c.pg_message_id,c.opzioni_id,c.ruolo,
      s->>'state_version',v_context_sha,v_source_sha,
      jsonb_build_object('intents',jsonb_array_length(s->'intents'),
        'facts',jsonb_array_length(s->'facts'),
        'dialogue_frames',jsonb_array_length(coalesce(s->'dialogue_frames','[]')),
        'components',jsonb_array_length(s->'deterministic_components')),
      least(coalesce(r.trial_expires_at,now()+interval '24 hours'),now()+interval '24 hours'))
    on conflict do nothing returning id into v_queue_id;
    if v_queue_id is not null then
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,queue_id,reason_code,details)
      values('eligible',c.id,v_queue_id,'STRUCTURE_COMPLETE',
        jsonb_build_object('role',c.ruolo,'state_version',s->>'state_version'));
    end if;
  exception when others then
    -- Il monitor non può interrompere la transazione di gioco.
    begin
      insert into public.exam_surface_qa_audit(event_type,source_cycle_id,reason_code,details)
      values('excluded',c.id,'CAPTURE_ERROR',jsonb_build_object('sqlstate',sqlstate));
    exception when others then null;
    end;
    return new;
  end;
  return new;
end
$function$
$candidate$;
BEGIN
 IF pg_get_functiondef('public._exam_surface_qa_capture()'::regprocedure) IS DISTINCT FROM original THEN RAISE EXCEPTION 'mission_session_baseline_drift: _exam_surface_qa_capture'; END IF;
 INSERT INTO mission_exam_private.function_backups VALUES('public._exam_surface_qa_capture()',original,candidate);
 EXECUTE candidate;
END $patch$;

DO $patch$
DECLARE original text:=$original$CREATE OR REPLACE FUNCTION public.esame_prova_tick()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare r record; n int := 0; v_scelta text; v_loc uuid;
begin
  -- 1 · il PNG muto da cinque minuti [004: era tre]: gioca il ripiego.
  for r in select e.* from public.esame_prove e
            where e.stato = 'aperta' and e.opzioni_id is not null
              and not public._esame_supervisione_attiva(e.id)
              and e.opzioni_at < now() - interval '5 minutes'
  loop
    -- [038] il ripiego passa dal ciclo, non più da `_esame_png_gioca` nudo:
    -- deve chiudere la ricevuta e far uscire la voce dal Narratore. La scelta
    -- deterministica la fa comunque `_esame_png_scelta`, dentro.
    perform public._esame_ciclo_ripiego(r.id, r.opzioni_id, 'silenzio del modello oltre i 5 minuti');
    n := n + 1;
  end loop;

  -- 2 · [038] il secondo tentativo NON esiste più: il contratto del ciclo
  --     ammette una chiamata sola. `ia_tentativi` resta in tabella come
  --     colonna storica e non viene più incrementata da nessuno.
  --     ⚠️ Non è stata tolta la colonna: `esame_ia_tentativi` e i referti
  --     vecchi la leggono, e una colonna tolta è un dato perso.

  -- 3 · il candidato muto da tre ore.
  for r in select e.*, s.location_id from public.esame_prove e
             join public.academy_class_sessions s on s.id = e.class_session_id
            where e.stato = 'aperta'
              and (not public._esame_supervisione_attiva(e.id) or exists (select 1 from public.esame_supervisione h where h.prova=e.id and h.player_ready and h.idle_deadline < now()))
              and ((e.updated_at < now() - interval '3 hours'
                    and not exists (select 1 from public.messages m
                                     where m.location_id = s.location_id
                                       and m.character_id = e.candidate_character
                                       and m.created_at > e.updated_at))
                   or public._ai_narrative_exam_qa_cleanup_requested_131m(e.id))
  loop
    -- Rilettura sotto lock: una SELECT precedente non autorizza il timeout.
    perform 1 from public.esame_prove e where e.id=r.id and e.stato='aperta' for update;
    if not found then continue; end if;
    perform 1 from public.esame_supervisione h where h.prova=r.id for update;
    if public._esame_supervisione_attiva(r.id) and not exists (
      select 1 from public.esame_supervisione h where h.prova=r.id and h.player_ready and h.idle_deadline<now()
    ) then continue; end if;
    if not exists(select 1 from public.esame_prove e where e.id=r.id and (
      (e.updated_at<now()-interval '3 hours' and not exists(select 1 from public.messages m where m.location_id=r.location_id and m.character_id=e.candidate_character and m.created_at>e.updated_at))
      or public._ai_narrative_exam_qa_cleanup_requested_131m(e.id)
    )) then continue; end if;
    update public.esame_prove
       set stato = 'annullata', closed_at = now(), close_reason = 'timeout'
     where id = r.id;

    -- [121] chiude anche il contenitore della prova scaduta. Il controllo
    -- sulle altre prove aperte impedisce di interrompere una sessione viva.
    update public.academy_class_sessions s
       set state='closed', closed_at=coalesce(s.closed_at,now()),
           close_reason=coalesce(s.close_reason,'exam_timeout')
     where s.id=r.class_session_id and s.state='teaching'
       and not exists (
         select 1 from public.esame_prove x
          where x.class_session_id=s.id and x.stato='aperta');

    insert into public.messages (location_id, character_id, sender_user, author_name, body, kind)
    values (r.location_id, null, null, 'Sistema',
      '((La prova si è chiusa per il tempo trascorso. Nessun punto è stato tolto e nessun tentativo è stato consumato.))',
      'sistema');
    n := n + 1;
  end loop;

  return n;
end
$function$
$original$;
 candidate text:=$candidate$CREATE OR REPLACE FUNCTION public.esame_prova_tick()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare r record; n int := 0; v_scelta text; v_loc uuid;
begin
  -- 1 · il PNG muto da cinque minuti [004: era tre]: gioca il ripiego.
  for r in select e.* from public.esame_prove e
            where not mission_exam_private.is_protected(e.id) and e.stato = 'aperta' and e.opzioni_id is not null
              and not public._esame_supervisione_attiva(e.id)
              and e.opzioni_at < now() - interval '5 minutes'
  loop
    -- [038] il ripiego passa dal ciclo, non più da `_esame_png_gioca` nudo:
    -- deve chiudere la ricevuta e far uscire la voce dal Narratore. La scelta
    -- deterministica la fa comunque `_esame_png_scelta`, dentro.
    perform public._esame_ciclo_ripiego(r.id, r.opzioni_id, 'silenzio del modello oltre i 5 minuti');
    n := n + 1;
  end loop;

  -- 2 · [038] il secondo tentativo NON esiste più: il contratto del ciclo
  --     ammette una chiamata sola. `ia_tentativi` resta in tabella come
  --     colonna storica e non viene più incrementata da nessuno.
  --     ⚠️ Non è stata tolta la colonna: `esame_ia_tentativi` e i referti
  --     vecchi la leggono, e una colonna tolta è un dato perso.

  -- 3 · il candidato muto da tre ore.
  for r in select e.*, s.location_id from public.esame_prove e
             join public.academy_class_sessions s on s.id = e.class_session_id
            where not mission_exam_private.is_protected(e.id) and e.stato = 'aperta'
              and (not public._esame_supervisione_attiva(e.id) or exists (select 1 from public.esame_supervisione h where h.prova=e.id and h.player_ready and h.idle_deadline < now()))
              and ((e.updated_at < now() - interval '3 hours'
                    and not exists (select 1 from public.messages m
                                     where m.location_id = s.location_id
                                       and m.character_id = e.candidate_character
                                       and m.created_at > e.updated_at))
                   or public._ai_narrative_exam_qa_cleanup_requested_131m(e.id))
  loop
    -- Rilettura sotto lock: una SELECT precedente non autorizza il timeout.
    perform 1 from public.esame_prove e where e.id=r.id and e.stato='aperta' for update;
    if not found then continue; end if;
    perform 1 from public.esame_supervisione h where h.prova=r.id for update;
    if public._esame_supervisione_attiva(r.id) and not exists (
      select 1 from public.esame_supervisione h where h.prova=r.id and h.player_ready and h.idle_deadline<now()
    ) then continue; end if;
    if not exists(select 1 from public.esame_prove e where e.id=r.id and (
      (e.updated_at<now()-interval '3 hours' and not exists(select 1 from public.messages m where m.location_id=r.location_id and m.character_id=e.candidate_character and m.created_at>e.updated_at))
      or public._ai_narrative_exam_qa_cleanup_requested_131m(e.id)
    )) then continue; end if;
    update public.esame_prove
       set stato = 'annullata', closed_at = now(), close_reason = 'timeout'
     where id = r.id;

    -- [121] chiude anche il contenitore della prova scaduta. Il controllo
    -- sulle altre prove aperte impedisce di interrompere una sessione viva.
    update public.academy_class_sessions s
       set state='closed', closed_at=coalesce(s.closed_at,now()),
           close_reason=coalesce(s.close_reason,'exam_timeout')
     where s.id=r.class_session_id and s.state='teaching'
       and not exists (
         select 1 from public.esame_prove x
          where x.class_session_id=s.id and x.stato='aperta');

    insert into public.messages (location_id, character_id, sender_user, author_name, body, kind)
    values (r.location_id, null, null, 'Sistema',
      '((La prova si è chiusa per il tempo trascorso. Nessun punto è stato tolto e nessun tentativo è stato consumato.))',
      'sistema');
    n := n + 1;
  end loop;

  return n;
end
$function$
$candidate$;
BEGIN
 IF pg_get_functiondef('public.esame_prova_tick()'::regprocedure) IS DISTINCT FROM original THEN RAISE EXCEPTION 'mission_session_baseline_drift: esame_prova_tick'; END IF;
 INSERT INTO mission_exam_private.function_backups VALUES('public.esame_prova_tick()',original,candidate);
 EXECUTE candidate;
END $patch$;

DO $patch$
DECLARE original text:=$original$CREATE OR REPLACE FUNCTION public.esame_prova_uscita(p_prova uuid, p_testo text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid:=auth.uid(); v public.esame_prove%rowtype;
  v_testo text; v_chiusura jsonb; v_is_test boolean:=false; v_esito text;
begin
  perform 1 from public.esame_prove where id=p_prova for update;
  if exists(select 1 from public.esame_supervisione where prova=p_prova and not player_ready and not publishing) then
    raise exception 'Esito in revisione: attendi la pubblicazione dello staff';
  end if;
  if v_uid is null then raise exception 'non autenticato'; end if;
  select * into v from public.esame_prove where id=p_prova for update;
  if not found then raise exception 'La prova non esiste più'; end if;
  if v.candidate_user<>v_uid then raise exception 'Questa non è la tua prova'; end if;
  if v.stato='conclusa' then return public._esame_stato_json(p_prova); end if;
  if v.stato<>'aperta' or v.meta<>'candidato' or v.fase<>'uscita' then
    raise exception 'L''uscita non è ancora il passo di questo esame';
  end if;
  if exists (select 1 from public.esame_narrazione_cicli c
              where c.prova_id=p_prova and c.stato in ('aperta','accettata')) then
    raise exception 'Il narratore sta ancora concludendo l''esame';
  end if;

  v_testo:=nullif(btrim(coalesce(p_testo,'')),'');
  if v_testo is null then raise exception 'Scrivi la role con cui lasci l''aula'; end if;
  if length(v_testo)>5000 then
    raise exception 'Il testo supera i 5.000 caratteri (ne hai scritti %).',length(v_testo);
  end if;
  perform public._esame_testo_candidato(p_prova,v_testo);

  select coalesce(l.is_test,false) into v_is_test
    from public.academy_class_sessions s
    join public.locations l on l.id=s.location_id
   where s.id=v.class_session_id;

  perform public._esame_valuta(p_prova);
  if v_is_test then
    v_esito:=public._esame_classifica(v.class_session_id);
    update public.academy_class_participants
       set esito=v_esito
     where session_id=v.class_session_id and user_id=v.candidate_user;
    update public.academy_class_sessions
       set step=greatest(coalesce(step,0),coalesce(total_steps,0)), step_at=now(),
           state='closed',closed_at=now(),close_reason='done',force_next=false
     where id=v.class_session_id;
    v_chiusura:=jsonb_build_object('ok',true,'isolata',true,'esito',v_esito,
                                   'xp',0,'grado_modificato',false);
  else
    update public.academy_class_sessions
       set step=greatest(coalesce(step,0),coalesce(total_steps,0)), step_at=now()
     where id=v.class_session_id and state<>'closed';
    v_chiusura:=public.esame_chiudi(v.class_session_id)::jsonb;
  end if;

  return public._esame_stato_json(p_prova)
    || jsonb_build_object('uscita_registrata',true,'chiusura',v_chiusura);
end
$function$
$original$;
 candidate text:=$candidate$CREATE OR REPLACE FUNCTION public.esame_prova_uscita(p_prova uuid, p_testo text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid:=auth.uid(); v public.esame_prove%rowtype;
  v_testo text; v_chiusura jsonb; v_is_test boolean:=false; v_esito text;
begin
  perform 1 from public.esame_prove where id=p_prova for update;
  if exists(select 1 from public.esame_supervisione where prova=p_prova and not player_ready and not publishing) then
    raise exception 'Esito in revisione: attendi la pubblicazione dello staff';
  end if;
  if v_uid is null then raise exception 'non autenticato'; end if;
  select * into v from public.esame_prove where id=p_prova for update;
  if not found then raise exception 'La prova non esiste più'; end if;
  if v.candidate_user<>v_uid then raise exception 'Questa non è la tua prova'; end if;
  if v.stato='conclusa' then return public._esame_stato_json(p_prova); end if;
  if v.stato<>'aperta' or v.meta<>'candidato' or v.fase<>'uscita' then
    raise exception 'L''uscita non è ancora il passo di questo esame';
  end if;
  if exists (select 1 from public.esame_narrazione_cicli c
              where c.prova_id=p_prova and c.stato in ('aperta','accettata')) then
    raise exception 'Il narratore sta ancora concludendo l''esame';
  end if;

  v_testo:=nullif(btrim(coalesce(p_testo,'')),'');
  if v_testo is null then raise exception 'Scrivi la role con cui lasci l''aula'; end if;
  if length(v_testo)>5000 then
    raise exception 'Il testo supera i 5.000 caratteri (ne hai scritti %).',length(v_testo);
  end if;
  perform public._esame_testo_candidato(p_prova,v_testo);

  select coalesce(l.is_test,false) into v_is_test
    from public.academy_class_sessions s
    join public.locations l on l.id=s.location_id
   where s.id=v.class_session_id;

  perform public._esame_valuta(p_prova);
  if v_is_test or mission_exam_private.is_protected(p_prova) then
    v_esito:=public._esame_classifica(v.class_session_id);
    update public.academy_class_participants
       set esito=v_esito
     where session_id=v.class_session_id and user_id=v.candidate_user;
    update public.academy_class_sessions
       set step=greatest(coalesce(step,0),coalesce(total_steps,0)), step_at=now(),
           state='closed',closed_at=now(),close_reason='done',force_next=false
     where id=v.class_session_id;
    v_chiusura:=jsonb_build_object('ok',true,'isolata',true,'esito',v_esito,
                                   'xp',0,'grado_modificato',false);
  else
    update public.academy_class_sessions
       set step=greatest(coalesce(step,0),coalesce(total_steps,0)), step_at=now()
     where id=v.class_session_id and state<>'closed';
    v_chiusura:=public.esame_chiudi(v.class_session_id)::jsonb;
  end if;

  if mission_exam_private.is_protected(p_prova) then
    update mission_exam_private.protected_sessions set state='closed',closed_at=clock_timestamp() where prova_id=p_prova;
    update public.esame_supervisione set chiusa_at=clock_timestamp(),motivo_chiusura='session_completed',
      player_ready=false,publishing=false,idle_deadline=null where prova=p_prova;
    update public.esame_supervisione_prenotazioni reservation set is_active=false
      from public.esame_supervisione hold_row
      where hold_row.prova=p_prova and reservation.id=hold_row.prenotazione
        and reservation.prova=p_prova and reservation.is_active;
  end if;
  return public._esame_stato_json(p_prova)
    || jsonb_build_object('uscita_registrata',true,'chiusura',v_chiusura);
end
$function$
$candidate$;
BEGIN
 IF pg_get_functiondef('public.esame_prova_uscita(uuid,text)'::regprocedure) IS DISTINCT FROM original THEN RAISE EXCEPTION 'mission_session_baseline_drift: esame_prova_uscita'; END IF;
 INSERT INTO mission_exam_private.function_backups VALUES('public.esame_prova_uscita(uuid,text)',original,candidate);
 EXECUTE candidate;
END $patch$;

DO $patch$
DECLARE original text:=$original$CREATE OR REPLACE FUNCTION public._esame_prova_opzioni(p_prova uuid, p_chi text DEFAULT 'candidato'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype;
  v_dist numeric; v_maxm int; v_ck int; v_vel int; v_nin int;
  v_spatial jsonb; v_avv jsonb; v_rit jsonb;
  v_speso boolean; v_rapida_spesa boolean; v_sposta_spesa boolean;
  v_beat int;
  v_disp_id uuid; v_disp_ck int := 0; v_disp_nome text; v_disp_ok boolean := false;
  v_princ jsonb; v_scen jsonb := '[]'::jsonb; v_inn jsonb := '[]'::jsonb; v_rap jsonb; v_reaz jsonb;
  v_common_sost jsonb := '[]'::jsonb;
  v_png boolean; v_motivo_beat text; v_copie boolean;
  -- [017-R1] il diversivo e le sue direzioni
  v_div jsonb := '[]'::jsonb; v_div_id uuid; v_div_nome text; v_div_ck int := 0;
  v_div_scorso int; v_div_ok boolean; v_direzioni jsonb := '[]'::jsonb;
  v_copie_cap int := 0; v_copie_offerte jsonb := '[]'::jsonb;
  v_assalto_avanzamenti jsonb := '[]'::jsonb;
  -- [ADDENDUM] le due posizioni risultanti, calcolate una volta e lette due:
  -- dal ramo `disponibile` e dal ramo `metri`. Calcolarle due volte è il modo
  -- in cui un elenco comincia a promettere una cosa e l'esecutore a farne
  -- un'altra.
  v_pos_io int; v_pos_lui int; v_pos_avv int; v_pos_rit int;
  v_avv_ok boolean; v_rit_ok boolean;
  -- [031] La manovra del candidato non è un attacco e non accetta metri.
  v_man jsonb := '[]'::jsonb; v_dist_dopo_avv numeric;
  v_principale_dopo boolean := false;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found then raise exception 'La prova non esiste più'; end if;
  v_spatial := public._esame_spatial_snapshot_v1(p_prova);
  if v_spatial is null then
    return public._esame_prova_opzioni_legacy_v1(p_prova,p_chi);
  end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;

  v_png  := (lower(coalesce(p_chi,'candidato')) = 'png');
  v_beat := v.beat;
  v_dist := (v_spatial->>'distance_m')::numeric;

  if v_png then
    v_vel := v_prof.velocita; v_nin := v_prof.ninjutsu; v_ck := v.ck_png;
    v_copie := coalesce(v.copie_attive_png,false);
  else
    select * into v_c from public.characters where id = v.candidate_character;
    v_vel := coalesce(v_c.velocita,0); v_nin := coalesce(v_c.ninjutsu,0); v_ck := v.ck_cand;
    v_copie := coalesce(v.copie_attive_cand,false);
  end if;
  v_maxm := (v_vel / 10) * 5;

  -- [ADDENDUM] `_esame_muove` è la sede unica: si ferma sul bersaglio, non
  -- scavalca, e rispetta il campo. Se questo elenco calcolasse i metri con
  -- un'aritmetica sua, tornerebbe il difetto in forma più piccola.
  v_avv := public._esame_spatial_move_preview_v1(p_prova,p_chi,v_maxm,true);
  v_rit := public._esame_spatial_move_preview_v1(p_prova,p_chi,v_maxm,false);
  v_avv_ok := (v_avv->>'available')::boolean;
  v_rit_ok := (v_rit->>'available')::boolean;

  -- L'economia dell'azione vale per chi ha il turno d'attacco in questa metà.
  v_speso        := v.usato_principale and ((v.meta = 'png') = v_png);
  v_rapida_spesa := v.usato_rapida     and ((v.meta = 'png') = v_png);
  v_sposta_spesa := v.usato_spostamento and ((v.meta = 'png') = v_png);

  v_motivo_beat := case v_beat
    when 1 then 'In questa prova non ancora: prima il passo e il colpo, il maestro vuole vedere quelli.'
    when 2 then 'In questa prova non ancora: prima mostra come ti muovi.'
    else null end;

  -- ── principali: i jutsu. Beat 1 non li offre ancora; beat 2 sì. ──────────
  -- Nessuna tecnica di clan per il PNG: un avversario d'esame non ha clan.
  select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_princ from (
    select jsonb_build_object(
      'id', j.id, 'fonte', 'jutsu', 'nome', j.name_it, 'clan', null, 'livello', null,
      'grado', j.rank, 'disciplina', j.category, 'gittata', coalesce(j.gittata,'media'),
      'portata_m', public._fascia_metri(coalesce(j.gittata,'media')),
      'chakra', coalesce(j.chakra_cost,0),
      'posseduta', true,
      'disponibile', v_dist <= public._fascia_metri(coalesce(j.gittata,'media'))
                     and (coalesce(j.chakra_cost,0) = 0 or v_ck >= coalesce(j.chakra_cost,0))
                     and not v_speso,
      'motivo_no', case
        when v_speso then 'hai già speso l''azione principale'
        when v_dist > public._fascia_metri(coalesce(j.gittata,'media'))
          then 'a ' || v_dist || ' metri non arriva: copre ' || public._fascia_metri(coalesce(j.gittata,'media'))
        when coalesce(j.chakra_cost,0) > v_ck
          then 'servono ' || j.chakra_cost || ' chakra, ne hai ' || v_ck
        end) as x
      from public.jutsu j
     where j.is_active and j.uso = 'principale' and not coalesce(j.difensiva,false)
       -- [017-R1] un diversivo NON è un attacco: esce dall'elenco delle
       -- principali e rientra sotto `diversivi`, che ha regole sue. È in UN
       -- PUNTO SOLO, ed è il perimetro di cui parla `04_COLONNE.md`.
       and not coalesce(j.diversivo,false)
       -- [042-B0] né una tecnica di scena. Vale per il candidato E per il
       -- PNG: `_esame_png_intenzioni` cicla su questo stesso elenco.
       and not coalesce(j.di_scena,false)
       and ( (v_png and j.id = any(v_prof.repertorio))
             or (not v_png and exists (select 1 from public.character_jutsu cj
                                        where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)) )
  ) s;

  if not v_png then
    select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_scen from (
      select jsonb_build_object(
        'id', j.id, 'fonte', 'scena', 'nome', j.name_it,
        'grado', j.rank, 'disciplina', j.category, 'gittata', 'sé stesso',
        'portata_m', 0, 'chakra', coalesce(j.chakra_cost,0),
        'posseduta', true,
        'disponibile', not v_speso
                       and (coalesce(j.chakra_cost,0) = 0 or v_ck >= coalesce(j.chakra_cost,0)),
        'motivo_no', case
          when v_speso then 'hai già speso l''azione principale'
          when coalesce(j.chakra_cost,0) > v_ck
            then 'servono ' || j.chakra_cost || ' chakra, ne hai ' || v_ck
          end) as x
        from public.jutsu j
       where j.is_active and coalesce(j.di_scena,false)
         and j.uso <> 'fuori_scontro'
         and exists (select 1 from public.character_jutsu cj
                      where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)
    ) s;
    v_princ := v_princ || v_scen;
  end if;

  -- ── innate: solo il candidato può averne, e solo al beat 3 ──────────────
  if not v_png then
    select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_inn from (
      select jsonb_build_object(
        'id', t.id, 'fonte', 'innata', 'nome', t.name, 'clan', t.clan, 'livello', t.level,
        'chakra', coalesce(t.chakra_cost,0), 'per_round', true, 'posseduta', true,
        'disponibile', v_beat >= 3 and not v_speso
                       and (coalesce(t.chakra_cost,0) = 0 or v_ck >= coalesce(t.chakra_cost,0)),
        'motivo_no', case
          when v_beat < 3 then 'In questa prova non ancora: si aggiunge all''ultimo scambio.'
          when v_speso then 'hai già speso l''azione principale'
          when coalesce(t.chakra_cost,0) > v_ck
            then 'servono ' || t.chakra_cost || ' chakra, ne hai ' || v_ck
          end) as x
        from public.clan_techniques t
        join public.character_abilities ca
          on ca.technique_id = t.id and ca.character_id = v.candidate_character and ca.state = 'attiva'
       where t.is_active and t.is_innata and t.consumption_type = 'per_turno'
         and public._grade_rank(coalesce(v_c.rank,'Deshi')) >=
             public._grade_rank(coalesce(t.req_grade,'Deshi'))
    ) s;
  end if;

  -- [R3] Guardia è ritirata: non esistono rapide nel contratto dell'Esame.
  v_rap := '[]'::jsonb;

  -- La Sostituzione arriva esclusivamente dal resolver spaziale comune.
  -- Le opzioni contengono capability opache e un'etichetta semantica: mai
  -- coordinate, distanze o la vecchia lista di posizioni.
  v_common_sost := public._esame_sostituzione_opzioni_comune_v1(p_prova, p_chi);

  if v.fase='difesa'
     and (v.pend_azione->'principale'->>'fonte')='jutsu'
     and exists (select 1 from public.jutsu a
                  where a.id=(v.pend_azione->'principale'->>'id')::uuid
                    and lower(a.category)='genjutsu') then
    select j.id,j.name_it,coalesce(j.chakra_cost,0)
      into v_disp_id,v_disp_nome,v_disp_ck
      from public.jutsu j
     where j.is_active and j.name_it='Dispersione'
       and ((v_png and j.id=any(v_prof.repertorio))
         or (not v_png and exists(select 1 from public.character_jutsu cj
                                  where cj.jutsu_id=j.id and cj.user_id=v.candidate_user)))
     limit 1;
    v_disp_ok := v_disp_id is not null and (v_disp_ck=0 or v_ck>=v_disp_ck);
  end if;

  v_reaz := jsonb_build_array(
    jsonb_build_object('chiave','schivata','nome','Schivata','chakra',0,'disponibile',true),
    jsonb_build_object('chiave','parata','nome','Parata','chakra',0,'disponibile',true)
  ) || v_common_sost;

  -- [A10 §B] Le copie compaiono SOLO se ci sono. Niente voce grigia con
  -- un motivo_no: una difesa che non si può giocare non è un'opzione.
  if v_copie then
    v_reaz := v_reaz || jsonb_build_array(jsonb_build_object(
      'chiave','copie','nome','Confondere con le copie','chakra',0,
      'disponibile', v.fase = 'difesa'));
  end if;

  -- [A10 §B] Stesso principio per la Dispersione: c'è quando è giocabile
  -- (contro Genjutsu e con il chakra che basta), altrimenti non c'è.
  if v_disp_ok then
    v_reaz := v_reaz || jsonb_build_array(jsonb_build_object(
      'chiave','tecnica','id',v_disp_id,'nome',v_disp_nome,'fonte','jutsu',
      'disciplina','Abilità','chakra',v_disp_ck,'disponibile',true));
  end if;

  -- ── [017-R1] il diversivo: DUE direzioni, e solo se muovono davvero ────
  -- Le condizioni sono quattro e stanno tutte qui, perché l'elenco è la sola
  -- fonte di legalità (decisione PM 9). `_esame_diversivo` le ricontrolla
  -- comunque: chi esegue non si fida di chi offre.
  --
  -- ⚠️ `manovre_png < 2` vale anche per il diversivo, e non è pignoleria: il
  -- diversivo incrementa `manovre_png`, quindi eredita la prova di
  -- terminazione della R2. Se lo si offrisse oltre il due, si allungherebbe
  -- una catena che la R2 ha dimostrato finita, e la dimostrazione andrebbe
  -- rifatta da capo.
  select j.id, j.name_it, coalesce(j.chakra_cost,0)
    into v_div_id, v_div_nome, v_div_ck
    from public.jutsu j
   where j.is_active and coalesce(j.diversivo,false)
     and ( (v_png and j.id = any(v_prof.repertorio))
           or (not v_png and exists (select 1 from public.character_jutsu cj
                                      where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)) )
   order by j.name_it limit 1;

  v_div_scorso := case when v_png then v.diversivo_scambio_png else v.diversivo_scambio_cand end;
  v_div_ok := v_div_id is not null
              and v.fase = 'attacco'
              and not v_speso
              and v_div_ck <= v_ck
              and (v_div_scorso is null or v_div_scorso < v.scambio)
              and (not v_png or v.manovre_png < 2);

  if v_div_ok then
    select coalesce(jsonb_agg(x order by x->>'chiave'), '[]'::jsonb) into v_div from (
      select jsonb_build_object(
        'chiave',    d.dir,
        'nome',      case d.dir when 'avvicinamento' then 'Coprire un avvicinamento'
                                else 'Coprire una ritirata' end,
        'tecnica',   v_div_nome,
        'id',        v_div_id,
        'chakra',    v_div_ck,
        'distanza_dopo', (m.preview->>'distance_after_m')::numeric,
        'disponibile', true) as x
        from (values ('avvicinamento'),('ritirata')) as d(dir)
        cross join lateral (select public._esame_spatial_move_preview_v1(p_prova,p_chi,
          case when d.dir='avvicinamento' then 5 else greatest(0,least(5,2+v_maxm-v_dist)) end,
          d.dir='avvicinamento') as preview) m
       -- zero offerte morte: una direzione che non cambia la posizione non
       -- viene presentata. Non è un vezzo di interfaccia, è il mandato.
       where (m.preview->>'available')::boolean
    ) s;
  end if;

  -- [107] Assalto usa soltanto l'avanzamento interno che chiude davvero la
  -- misura. Il payload offre zero se il candidato è già a contatto, altrimenti
  -- l'unica distanza positiva necessaria. Se la Velocità non basta, Assalto
  -- non compare fra le modalità: il client non deve proporre mosse morte.
  if not v_png then
    if v_dist <= 2 then
      v_assalto_avanzamenti := jsonb_build_array(0);
    elsif v_avv_ok and (v_avv->>'distance_after_m')::numeric <= 2 then
      -- Il comando resta in passi da cinque metri; il percorso effettivo
      -- può arrestarsi prima. Il writer ricontrolla lo stesso preview.
      select coalesce(jsonb_agg(n order by n),'[]'::jsonb) into v_assalto_avanzamenti
      from (select n from generate_series(5,v_maxm,5) n
        where (public._esame_spatial_move_preview_v1(p_prova,p_chi,n,true)->>'distance_after_m')::numeric<=2
        order by n limit 1) only_contact;
    else
      v_assalto_avanzamenti := '[]'::jsonb;
    end if;
  end if;

  -- [077] Per il candidato Moltiplicazione è UNA tecnica. Direzione e modalità
  -- sono decisioni di secondo livello; copie e costi arrivano dal server.
  if not v_png and v_div_id is not null then
    v_direzioni:=v_div;
    v_copie_cap:=least(public._copie_cap(coalesce(v_c.ninjutsu,0),coalesce(v_c.rank,'Deshi')),4,
                       greatest(0,(v_ck-v_div_ck)/5));
    select coalesce(jsonb_agg(n order by n),'[]'::jsonb) into v_copie_offerte
      from generate_series(1,v_copie_cap) n;
    if v.fase='attacco' and not v_speso and v_copie_cap>0
       and (v_div_scorso is null or v_div_scorso<v.scambio) then
      v_div:=jsonb_build_array(jsonb_build_object(
        'id',v_div_id,'tecnica',v_div_nome,'nome',v_div_nome,'disponibile',true,
        'modalita_offerte',jsonb_build_array('diversivo','copertura') ||
          case when jsonb_array_length(v_assalto_avanzamenti)>0
               then jsonb_build_array('assalto') else '[]'::jsonb end,
        'assalto_avanzamenti',v_assalto_avanzamenti,
        'direzioni_offerte',v_direzioni,'copie_offerte',v_copie_offerte,
        'copie_max',v_copie_cap,'costo_base',v_div_ck,'costo_per_copia',5));
    else
      v_div:='[]'::jsonb;
    end if;
  end if;

  -- ── [031] manovra di chiusura del candidato ──────────────────────────────
  -- Il confronto è sullo stato RISULTANTE dopo il massimo avvicinamento.
  -- Le innate disponibili contano: se il candidato può agire, la manovra
  -- non compare. Il server calcola distanza e posizione, mai il client.
  v_dist_dopo_avv := (v_avv->>'distance_after_m')::numeric;
  select (v_dist_dopo_avv <= 2)
      or exists (
           select 1 from jsonb_array_elements(v_princ) e
            where coalesce((e->>'chakra')::int,0) <= v_ck
              and coalesce((e->>'portata_m')::int,0) >= v_dist_dopo_avv)
      or exists (
           select 1 from jsonb_array_elements(v_inn) e
            where coalesce((e->>'disponibile')::boolean,false))
    into v_principale_dopo;

  if not v_png
     and v.fase = 'attacco' and v.meta = 'candidato'
     and not v_speso and not v_sposta_spesa
     and v_avv_ok
     and jsonb_array_length(v_div) = 0
     and not v_principale_dopo then
    v_man := jsonb_build_array(jsonb_build_object(
      'chiave', 'avvicinamento',
      'nome', 'Chiudere la misura',
      'disponibile', true,
      'distanza_dopo', v_dist_dopo_avv));
  end if;

  return jsonb_build_object(
    'versione', 1,
    'prova_id', v.id, 'chi', case when v_png then 'png' else 'candidato' end,
    'scambio', v.scambio, 'beat', v_beat, 'fase', v.fase, 'meta', v.meta,
    'distanza', v_dist,
    'fascia', case when v_dist <= 2 then 'a contatto' when v_dist <= 10 then 'corta'
                   when v_dist <= 30 then 'media' else 'lunga' end,
    'slancio', case when v_png then v.slancio_png else v.slancio_cand end,
    'chakra', jsonb_build_object('ora', v_ck, 'max', case when v_png then v.ck_png_max else v.ck_cand_max end),
    'spostamento', jsonb_build_object(
      'disponibile', v.fase = 'attacco' and not v_sposta_spesa
                     and (v_avv_ok or v_rit_ok),
      'max_metri', v_maxm,
      'avvicinamento', jsonb_build_object(
        'disponibile', v.fase = 'attacco' and not v_sposta_spesa and v_avv_ok,
        'metri',         (v_avv->>'travelled_m')::numeric,
        'distanza_dopo', (v_avv->>'distance_after_m')::numeric,
        'motivo_no', case when not v_avv_ok then 'sei già addosso: non c''è terreno da guadagnare' end),
      'ritirata', jsonb_build_object(
        'disponibile', v.fase = 'attacco' and not v_sposta_spesa and v_rit_ok,
        'metri',         (v_rit->>'travelled_m')::numeric,
        'distanza_dopo', (v_rit->>'distance_after_m')::numeric,
        'motivo_no', case when not v_rit_ok then 'da qui non puoi cedere altro terreno' end),
      'motivo_no', case when v.fase = 'difesa' then 'in difesa si risponde e basta'
                        when v_sposta_spesa then 'già speso in questo round'
                        when not (v_avv_ok or v_rit_ok) then 'nessuno spostamento cambierebbe la posizione' end),
    'colpo', jsonb_build_object('nome','Colpo a mani nude','fonte','colpo','gittata','contatto',
      'portata_m', 2, 'chakra', 0,
      'disponibile', v_dist <= 2 and not v_speso,
      'disponibile_dopo_avvicinamento',
        v_dist > 2 and not v_speso and v_avv_ok and v_dist_dopo_avv <= 2,
      'motivo_no', case when v_speso then 'hai già speso l''azione principale'
                        when v_dist > 2 then 'a ' || v_dist || ' metri non lo raggiungi: serve il contatto' end),
    'principali', v_princ,
    'diversivi', v_div,
    'manovre', v_man,
    'innate', v_inn,
    'rapide', v_rap,
    'reazioni', v_reaz);
end
$function$
$original$;
 candidate text:=$candidate$CREATE OR REPLACE FUNCTION public._esame_prova_opzioni(p_prova uuid, p_chi text DEFAULT 'candidato'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype;
  v_dist numeric; v_maxm int; v_ck int; v_vel int; v_nin int;
  v_spatial jsonb; v_avv jsonb; v_rit jsonb;
  v_speso boolean; v_rapida_spesa boolean; v_sposta_spesa boolean;
  v_beat int;
  v_disp_id uuid; v_disp_ck int := 0; v_disp_nome text; v_disp_ok boolean := false;
  v_princ jsonb; v_scen jsonb := '[]'::jsonb; v_inn jsonb := '[]'::jsonb; v_rap jsonb; v_reaz jsonb;
  v_common_sost jsonb := '[]'::jsonb;
  v_png boolean; v_motivo_beat text; v_copie boolean;
  -- [017-R1] il diversivo e le sue direzioni
  v_div jsonb := '[]'::jsonb; v_div_id uuid; v_div_nome text; v_div_ck int := 0;
  v_div_scorso int; v_div_ok boolean; v_direzioni jsonb := '[]'::jsonb;
  v_copie_cap int := 0; v_copie_offerte jsonb := '[]'::jsonb;
  v_assalto_avanzamenti jsonb := '[]'::jsonb;
  -- [ADDENDUM] le due posizioni risultanti, calcolate una volta e lette due:
  -- dal ramo `disponibile` e dal ramo `metri`. Calcolarle due volte è il modo
  -- in cui un elenco comincia a promettere una cosa e l'esecutore a farne
  -- un'altra.
  v_pos_io int; v_pos_lui int; v_pos_avv int; v_pos_rit int;
  v_avv_ok boolean; v_rit_ok boolean;
  -- [031] La manovra del candidato non è un attacco e non accetta metri.
  v_man jsonb := '[]'::jsonb; v_dist_dopo_avv numeric;
  v_principale_dopo boolean := false;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found then raise exception 'La prova non esiste più'; end if;
  v_spatial := public._esame_spatial_snapshot_v1(p_prova);
  if v_spatial is null then
    if mission_exam_private.is_protected(p_prova) then raise exception 'mission_session_spatial_required'; end if;
    return public._esame_prova_opzioni_legacy_v1(p_prova,p_chi);
  end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;

  v_png  := (lower(coalesce(p_chi,'candidato')) = 'png');
  v_beat := v.beat;
  v_dist := (v_spatial->>'distance_m')::numeric;

  if v_png then
    v_vel := v_prof.velocita; v_nin := v_prof.ninjutsu; v_ck := v.ck_png;
    v_copie := coalesce(v.copie_attive_png,false);
  else
    select * into v_c from public.characters where id = v.candidate_character;
    v_vel := coalesce(v_c.velocita,0); v_nin := coalesce(v_c.ninjutsu,0); v_ck := v.ck_cand;
    v_copie := coalesce(v.copie_attive_cand,false);
  end if;
  v_maxm := (v_vel / 10) * 5;

  -- [ADDENDUM] `_esame_muove` è la sede unica: si ferma sul bersaglio, non
  -- scavalca, e rispetta il campo. Se questo elenco calcolasse i metri con
  -- un'aritmetica sua, tornerebbe il difetto in forma più piccola.
  v_avv := public._esame_spatial_move_preview_v1(p_prova,p_chi,v_maxm,true);
  v_rit := public._esame_spatial_move_preview_v1(p_prova,p_chi,v_maxm,false);
  v_avv_ok := (v_avv->>'available')::boolean;
  v_rit_ok := (v_rit->>'available')::boolean;

  -- L'economia dell'azione vale per chi ha il turno d'attacco in questa metà.
  v_speso        := v.usato_principale and ((v.meta = 'png') = v_png);
  v_rapida_spesa := v.usato_rapida     and ((v.meta = 'png') = v_png);
  v_sposta_spesa := v.usato_spostamento and ((v.meta = 'png') = v_png);

  v_motivo_beat := case v_beat
    when 1 then 'In questa prova non ancora: prima il passo e il colpo, il maestro vuole vedere quelli.'
    when 2 then 'In questa prova non ancora: prima mostra come ti muovi.'
    else null end;

  -- ── principali: i jutsu. Beat 1 non li offre ancora; beat 2 sì. ──────────
  -- Nessuna tecnica di clan per il PNG: un avversario d'esame non ha clan.
  select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_princ from (
    select jsonb_build_object(
      'id', j.id, 'fonte', 'jutsu', 'nome', j.name_it, 'clan', null, 'livello', null,
      'grado', j.rank, 'disciplina', j.category, 'gittata', coalesce(j.gittata,'media'),
      'portata_m', public._fascia_metri(coalesce(j.gittata,'media')),
      'chakra', coalesce(j.chakra_cost,0),
      'posseduta', true,
      'disponibile', v_dist <= public._fascia_metri(coalesce(j.gittata,'media'))
                     and (coalesce(j.chakra_cost,0) = 0 or v_ck >= coalesce(j.chakra_cost,0))
                     and not v_speso,
      'motivo_no', case
        when v_speso then 'hai già speso l''azione principale'
        when v_dist > public._fascia_metri(coalesce(j.gittata,'media'))
          then 'a ' || v_dist || ' metri non arriva: copre ' || public._fascia_metri(coalesce(j.gittata,'media'))
        when coalesce(j.chakra_cost,0) > v_ck
          then 'servono ' || j.chakra_cost || ' chakra, ne hai ' || v_ck
        end) as x
      from public.jutsu j
      join lateral (select 1 where not mission_exam_private.is_protected(p_prova)
        or j.id in ('31b15861-fb78-4f8a-ac1c-ebf2d957c32e'::uuid,'c6e31b7b-38fe-4b4f-b3c7-05f3e922d193'::uuid)) mission_allowed on true
     where j.is_active and j.uso = 'principale' and not coalesce(j.difensiva,false)
       -- [017-R1] un diversivo NON è un attacco: esce dall'elenco delle
       -- principali e rientra sotto `diversivi`, che ha regole sue. È in UN
       -- PUNTO SOLO, ed è il perimetro di cui parla `04_COLONNE.md`.
       and not coalesce(j.diversivo,false)
       -- [042-B0] né una tecnica di scena. Vale per il candidato E per il
       -- PNG: `_esame_png_intenzioni` cicla su questo stesso elenco.
       and not coalesce(j.di_scena,false)
       and ( (v_png and j.id = any(v_prof.repertorio))
             or (not v_png and exists (select 1 from public.character_jutsu cj
                                        where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)) )
  ) s;

  if not v_png then
    select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_scen from (
      select jsonb_build_object(
        'id', j.id, 'fonte', 'scena', 'nome', j.name_it,
        'grado', j.rank, 'disciplina', j.category, 'gittata', 'sé stesso',
        'portata_m', 0, 'chakra', coalesce(j.chakra_cost,0),
        'posseduta', true,
        'disponibile', not v_speso
                       and (coalesce(j.chakra_cost,0) = 0 or v_ck >= coalesce(j.chakra_cost,0)),
        'motivo_no', case
          when v_speso then 'hai già speso l''azione principale'
          when coalesce(j.chakra_cost,0) > v_ck
            then 'servono ' || j.chakra_cost || ' chakra, ne hai ' || v_ck
          end) as x
        from public.jutsu j
      join lateral (select 1 where not mission_exam_private.is_protected(p_prova)
        or j.id in ('31b15861-fb78-4f8a-ac1c-ebf2d957c32e'::uuid,'c6e31b7b-38fe-4b4f-b3c7-05f3e922d193'::uuid)) mission_allowed on true
       where j.is_active and coalesce(j.di_scena,false)
         and j.uso <> 'fuori_scontro'
         and exists (select 1 from public.character_jutsu cj
                      where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)
    ) s;
    v_princ := v_princ || v_scen;
  end if;

  -- ── innate: solo il candidato può averne, e solo al beat 3 ──────────────
  if not v_png then
    select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_inn from (
      select jsonb_build_object(
        'id', t.id, 'fonte', 'innata', 'nome', t.name, 'clan', t.clan, 'livello', t.level,
        'chakra', coalesce(t.chakra_cost,0), 'per_round', true, 'posseduta', true,
        'disponibile', v_beat >= 3 and not v_speso
                       and (coalesce(t.chakra_cost,0) = 0 or v_ck >= coalesce(t.chakra_cost,0)),
        'motivo_no', case
          when v_beat < 3 then 'In questa prova non ancora: si aggiunge all''ultimo scambio.'
          when v_speso then 'hai già speso l''azione principale'
          when coalesce(t.chakra_cost,0) > v_ck
            then 'servono ' || t.chakra_cost || ' chakra, ne hai ' || v_ck
          end) as x
        from public.clan_techniques t
        join public.character_abilities ca
          on ca.technique_id = t.id and ca.character_id = v.candidate_character and ca.state = 'attiva'
       where t.is_active and t.is_innata and t.consumption_type = 'per_turno'
         and public._grade_rank(coalesce(v_c.rank,'Deshi')) >=
             public._grade_rank(coalesce(t.req_grade,'Deshi'))
    ) s;
  end if;

  -- [R3] Guardia è ritirata: non esistono rapide nel contratto dell'Esame.
  v_rap := '[]'::jsonb;

  -- La Sostituzione arriva esclusivamente dal resolver spaziale comune.
  -- Le opzioni contengono capability opache e un'etichetta semantica: mai
  -- coordinate, distanze o la vecchia lista di posizioni.
  v_common_sost := public._esame_sostituzione_opzioni_comune_v1(p_prova, p_chi);

  if v.fase='difesa'
     and (v.pend_azione->'principale'->>'fonte')='jutsu'
     and exists (select 1 from public.jutsu a
                  where a.id=(v.pend_azione->'principale'->>'id')::uuid
                    and lower(a.category)='genjutsu') then
    select j.id,j.name_it,coalesce(j.chakra_cost,0)
      into v_disp_id,v_disp_nome,v_disp_ck
      from public.jutsu j
      join lateral (select 1 where not mission_exam_private.is_protected(p_prova)
        or j.id in ('31b15861-fb78-4f8a-ac1c-ebf2d957c32e'::uuid,'c6e31b7b-38fe-4b4f-b3c7-05f3e922d193'::uuid)) mission_allowed on true
     where j.is_active and j.name_it='Dispersione'
       and ((v_png and j.id=any(v_prof.repertorio))
         or (not v_png and exists(select 1 from public.character_jutsu cj
                                  where cj.jutsu_id=j.id and cj.user_id=v.candidate_user)))
     limit 1;
    v_disp_ok := v_disp_id is not null and (v_disp_ck=0 or v_ck>=v_disp_ck);
  end if;

  v_reaz := jsonb_build_array(
    jsonb_build_object('chiave','schivata','nome','Schivata','chakra',0,'disponibile',true),
    jsonb_build_object('chiave','parata','nome','Parata','chakra',0,'disponibile',true)
  ) || v_common_sost;

  -- [A10 §B] Le copie compaiono SOLO se ci sono. Niente voce grigia con
  -- un motivo_no: una difesa che non si può giocare non è un'opzione.
  if v_copie then
    v_reaz := v_reaz || jsonb_build_array(jsonb_build_object(
      'chiave','copie','nome','Confondere con le copie','chakra',0,
      'disponibile', v.fase = 'difesa'));
  end if;

  -- [A10 §B] Stesso principio per la Dispersione: c'è quando è giocabile
  -- (contro Genjutsu e con il chakra che basta), altrimenti non c'è.
  if v_disp_ok then
    v_reaz := v_reaz || jsonb_build_array(jsonb_build_object(
      'chiave','tecnica','id',v_disp_id,'nome',v_disp_nome,'fonte','jutsu',
      'disciplina','Abilità','chakra',v_disp_ck,'disponibile',true));
  end if;

  -- ── [017-R1] il diversivo: DUE direzioni, e solo se muovono davvero ────
  -- Le condizioni sono quattro e stanno tutte qui, perché l'elenco è la sola
  -- fonte di legalità (decisione PM 9). `_esame_diversivo` le ricontrolla
  -- comunque: chi esegue non si fida di chi offre.
  --
  -- ⚠️ `manovre_png < 2` vale anche per il diversivo, e non è pignoleria: il
  -- diversivo incrementa `manovre_png`, quindi eredita la prova di
  -- terminazione della R2. Se lo si offrisse oltre il due, si allungherebbe
  -- una catena che la R2 ha dimostrato finita, e la dimostrazione andrebbe
  -- rifatta da capo.
  select j.id, j.name_it, coalesce(j.chakra_cost,0)
    into v_div_id, v_div_nome, v_div_ck
    from public.jutsu j
      join lateral (select 1 where not mission_exam_private.is_protected(p_prova)
        or j.id in ('31b15861-fb78-4f8a-ac1c-ebf2d957c32e'::uuid,'c6e31b7b-38fe-4b4f-b3c7-05f3e922d193'::uuid)) mission_allowed on true
   where j.is_active and coalesce(j.diversivo,false)
     and ( (v_png and j.id = any(v_prof.repertorio))
           or (not v_png and exists (select 1 from public.character_jutsu cj
                                      where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)) )
   order by j.name_it limit 1;

  v_div_scorso := case when v_png then v.diversivo_scambio_png else v.diversivo_scambio_cand end;
  v_div_ok := v_div_id is not null
              and v.fase = 'attacco'
              and not v_speso
              and v_div_ck <= v_ck
              and (v_div_scorso is null or v_div_scorso < v.scambio)
              and (not v_png or v.manovre_png < 2);

  if v_div_ok then
    select coalesce(jsonb_agg(x order by x->>'chiave'), '[]'::jsonb) into v_div from (
      select jsonb_build_object(
        'chiave',    d.dir,
        'nome',      case d.dir when 'avvicinamento' then 'Coprire un avvicinamento'
                                else 'Coprire una ritirata' end,
        'tecnica',   v_div_nome,
        'id',        v_div_id,
        'chakra',    v_div_ck,
        'distanza_dopo', (m.preview->>'distance_after_m')::numeric,
        'disponibile', true) as x
        from (values ('avvicinamento'),('ritirata')) as d(dir)
        cross join lateral (select public._esame_spatial_move_preview_v1(p_prova,p_chi,
          case when d.dir='avvicinamento' then 5 else greatest(0,least(5,2+v_maxm-v_dist)) end,
          d.dir='avvicinamento') as preview) m
       -- zero offerte morte: una direzione che non cambia la posizione non
       -- viene presentata. Non è un vezzo di interfaccia, è il mandato.
       where (m.preview->>'available')::boolean
    ) s;
  end if;

  -- [107] Assalto usa soltanto l'avanzamento interno che chiude davvero la
  -- misura. Il payload offre zero se il candidato è già a contatto, altrimenti
  -- l'unica distanza positiva necessaria. Se la Velocità non basta, Assalto
  -- non compare fra le modalità: il client non deve proporre mosse morte.
  if not v_png then
    if v_dist <= 2 then
      v_assalto_avanzamenti := jsonb_build_array(0);
    elsif v_avv_ok and (v_avv->>'distance_after_m')::numeric <= 2 then
      -- Il comando resta in passi da cinque metri; il percorso effettivo
      -- può arrestarsi prima. Il writer ricontrolla lo stesso preview.
      select coalesce(jsonb_agg(n order by n),'[]'::jsonb) into v_assalto_avanzamenti
      from (select n from generate_series(5,v_maxm,5) n
        where (public._esame_spatial_move_preview_v1(p_prova,p_chi,n,true)->>'distance_after_m')::numeric<=2
        order by n limit 1) only_contact;
    else
      v_assalto_avanzamenti := '[]'::jsonb;
    end if;
  end if;

  -- [077] Per il candidato Moltiplicazione è UNA tecnica. Direzione e modalità
  -- sono decisioni di secondo livello; copie e costi arrivano dal server.
  if not v_png and v_div_id is not null then
    v_direzioni:=v_div;
    v_copie_cap:=least(public._copie_cap(coalesce(v_c.ninjutsu,0),coalesce(v_c.rank,'Deshi')),4,
                       greatest(0,(v_ck-v_div_ck)/5));
    select coalesce(jsonb_agg(n order by n),'[]'::jsonb) into v_copie_offerte
      from generate_series(1,v_copie_cap) n;
    if v.fase='attacco' and not v_speso and v_copie_cap>0
       and (v_div_scorso is null or v_div_scorso<v.scambio) then
      v_div:=jsonb_build_array(jsonb_build_object(
        'id',v_div_id,'tecnica',v_div_nome,'nome',v_div_nome,'disponibile',true,
        'modalita_offerte',jsonb_build_array('diversivo','copertura') ||
          case when jsonb_array_length(v_assalto_avanzamenti)>0
               then jsonb_build_array('assalto') else '[]'::jsonb end,
        'assalto_avanzamenti',v_assalto_avanzamenti,
        'direzioni_offerte',v_direzioni,'copie_offerte',v_copie_offerte,
        'copie_max',v_copie_cap,'costo_base',v_div_ck,'costo_per_copia',5));
    else
      v_div:='[]'::jsonb;
    end if;
  end if;

  -- ── [031] manovra di chiusura del candidato ──────────────────────────────
  -- Il confronto è sullo stato RISULTANTE dopo il massimo avvicinamento.
  -- Le innate disponibili contano: se il candidato può agire, la manovra
  -- non compare. Il server calcola distanza e posizione, mai il client.
  v_dist_dopo_avv := (v_avv->>'distance_after_m')::numeric;
  select (v_dist_dopo_avv <= 2)
      or exists (
           select 1 from jsonb_array_elements(v_princ) e
            where coalesce((e->>'chakra')::int,0) <= v_ck
              and coalesce((e->>'portata_m')::int,0) >= v_dist_dopo_avv)
      or exists (
           select 1 from jsonb_array_elements(v_inn) e
            where coalesce((e->>'disponibile')::boolean,false))
    into v_principale_dopo;

  if not v_png
     and v.fase = 'attacco' and v.meta = 'candidato'
     and not v_speso and not v_sposta_spesa
     and v_avv_ok
     and jsonb_array_length(v_div) = 0
     and not v_principale_dopo then
    v_man := jsonb_build_array(jsonb_build_object(
      'chiave', 'avvicinamento',
      'nome', 'Chiudere la misura',
      'disponibile', true,
      'distanza_dopo', v_dist_dopo_avv));
  end if;

  return jsonb_build_object(
    'versione', 1,
    'prova_id', v.id, 'chi', case when v_png then 'png' else 'candidato' end,
    'scambio', v.scambio, 'beat', v_beat, 'fase', v.fase, 'meta', v.meta,
    'distanza', v_dist,
    'fascia', case when v_dist <= 2 then 'a contatto' when v_dist <= 10 then 'corta'
                   when v_dist <= 30 then 'media' else 'lunga' end,
    'slancio', case when v_png then v.slancio_png else v.slancio_cand end,
    'chakra', jsonb_build_object('ora', v_ck, 'max', case when v_png then v.ck_png_max else v.ck_cand_max end),
    'spostamento', jsonb_build_object(
      'disponibile', v.fase = 'attacco' and not v_sposta_spesa
                     and (v_avv_ok or v_rit_ok),
      'max_metri', v_maxm,
      'avvicinamento', jsonb_build_object(
        'disponibile', v.fase = 'attacco' and not v_sposta_spesa and v_avv_ok,
        'metri',         (v_avv->>'travelled_m')::numeric,
        'distanza_dopo', (v_avv->>'distance_after_m')::numeric,
        'motivo_no', case when not v_avv_ok then 'sei già addosso: non c''è terreno da guadagnare' end),
      'ritirata', jsonb_build_object(
        'disponibile', v.fase = 'attacco' and not v_sposta_spesa and v_rit_ok,
        'metri',         (v_rit->>'travelled_m')::numeric,
        'distanza_dopo', (v_rit->>'distance_after_m')::numeric,
        'motivo_no', case when not v_rit_ok then 'da qui non puoi cedere altro terreno' end),
      'motivo_no', case when v.fase = 'difesa' then 'in difesa si risponde e basta'
                        when v_sposta_spesa then 'già speso in questo round'
                        when not (v_avv_ok or v_rit_ok) then 'nessuno spostamento cambierebbe la posizione' end),
    'colpo', jsonb_build_object('nome','Colpo a mani nude','fonte','colpo','gittata','contatto',
      'portata_m', 2, 'chakra', 0,
      'disponibile', v_dist <= 2 and not v_speso,
      'disponibile_dopo_avvicinamento',
        v_dist > 2 and not v_speso and v_avv_ok and v_dist_dopo_avv <= 2,
      'motivo_no', case when v_speso then 'hai già speso l''azione principale'
                        when v_dist > 2 then 'a ' || v_dist || ' metri non lo raggiungi: serve il contatto' end),
    'principali', v_princ,
    'diversivi', v_div,
    'manovre', v_man,
    'innate', v_inn,
    'rapide', v_rap,
    'reazioni', v_reaz);
end
$function$
$candidate$;
BEGIN
 IF pg_get_functiondef('public._esame_prova_opzioni(uuid,text)'::regprocedure) IS DISTINCT FROM original THEN RAISE EXCEPTION 'mission_session_baseline_drift: _esame_prova_opzioni'; END IF;
 INSERT INTO mission_exam_private.function_backups VALUES('public._esame_prova_opzioni(uuid,text)',original,candidate);
 EXECUTE candidate;
END $patch$;

-- Consegna candidata: tutti i blocchi previsti sono presenti, nessun gate QA
-- attestato. Review e campagna integrata devono verificare in particolare:
-- ordine BEFORE/AFTER e FK deferred, zero effetti REC/overflow/QAqueue,
-- filtro opzioni su entrambi i lati e assenza bypass diretto delle tecniche,
-- dipendenze2D reali e recovery nella transazione con il publisher SESSION.
-- Config iniziale OFF/capNULL; apertura live necessita enable/cap nominati.

-- CANDIDATO SESSION001, nessun apply implicito. Richiede prima MISSION_EXAM_TAMAKO.sql.
-- Tre corpi esistenti e un helper puro; scope protetto comune attestato dal DB.

DO $pre$ BEGIN
  IF EXISTS(SELECT 1 FROM public.esame_prove WHERE stato='aperta') THEN RAISE EXCEPTION 'Esami aperti: rilascio sospeso'; END IF;
  IF md5(pg_get_functiondef('public.esame_supervisione_pubblica(uuid,text)'::regprocedure))<>'f278ac6a0d8567ae4f1170ddf3adc90a' THEN RAISE EXCEPTION 'Baseline diversa: esame_supervisione_pubblica'; END IF;
  IF md5(pg_get_functiondef('public.esame_narrazione_apply(uuid,uuid,text,text,jsonb,text,integer,text,numeric,integer,integer,text,text,jsonb)'::regprocedure))<>'e2648a72fc198acbb7df0341ec9a5e1b' THEN RAISE EXCEPTION 'Baseline diversa: esame_narrazione_apply'; END IF;
  IF md5(pg_get_functiondef('public._esame_supervisione_post(uuid,uuid,text)'::regprocedure))<>'3b91a996e1cdc3963d5fb3d1bd04b345' THEN RAISE EXCEPTION 'Baseline diversa: _esame_supervisione_post'; END IF;
  IF to_regprocedure('public._esame_mission_formato(text,jsonb,text[])') IS NOT NULL THEN RAISE EXCEPTION 'Helper già presente'; END IF;
END $pre$;
CREATE FUNCTION public._esame_mission_formato(p_azione text,p_esiti jsonb,p_attesi text[])
RETURNS text LANGUAGE plpgsql IMMUTABLE SET search_path=public AS $fn$
declare actual text[]; expected text[]; entry record;
begin
  if nullif(btrim(p_azione),'') is null then return 'azione assente'; end if;
  if jsonb_typeof(p_esiti) is distinct from 'object' then return 'branche non oggetto'; end if;
  select coalesce(array_agg(k order by k),array[]::text[]) into actual from jsonb_object_keys(p_esiti) k;
  select coalesce(array_agg(distinct k order by k),array[]::text[]) into expected from unnest(coalesce(p_attesi,array[]::text[])) k;
  if actual is distinct from expected then return 'branche diverse dalle offerte server'; end if;
  for entry in select key,value from jsonb_each(p_esiti) loop
    if jsonb_typeof(entry.value) is distinct from 'string' or nullif(btrim(entry.value#>>'{}'),'') is null then
      return 'branca assente o non testuale';
    end if;
  end loop;
  return null;
end; $fn$;
REVOKE ALL ON FUNCTION public._esame_mission_formato(text,jsonb,text[]) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public._esame_mission_formato(text,jsonb,text[]) TO postgres,service_role;
CREATE OR REPLACE FUNCTION public.esame_supervisione_pubblica(p_bozza uuid, p_sha text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare b public.esame_supervisione_bozze%rowtype; h public.esame_supervisione%rowtype; v public.esame_prove%rowtype;
  v_mission boolean; j jsonb; u jsonb; t jsonb; v_loc uuid; res jsonb; mid uuid; v_ready boolean;
begin
  select * into b from public.esame_supervisione_bozze where id=p_bozza;
  if not found then raise exception 'Bozza assente'; end if;
  select * into v from public.esame_prove where id=b.prova for update;
  select * into h from public.esame_supervisione where prova=b.prova for update;
  select * into b from public.esame_supervisione_bozze where id=p_bozza for update;
  v_mission := coalesce(b.risultato->>'validator_version'='MISSION-EXAM-SESSION-001',false);
  if v_mission then
    if b.autore is distinct from auth.uid()
      or public._esame_session_scope(v.id,auth.uid()) is distinct from true then
      raise exception 'Sessione Narratore non autorizzata';
    end if;
  else
    perform public._esame_supervisione_staff();
  end if;
  if b.stato<>'pronta' or b.sha is distinct from p_sha or v.stato<>'aperta' then raise exception 'Bozza non approvabile'; end if;
  if b.ricevuta is distinct from (case when h.apertura_pubblicata then v.opzioni_id else h.apertura_ricevuta end) then
    raise exception 'Ricevuta scaduta';
  end if;
  j:=case when b.tipo='apertura' then h.apertura_fatti else public._esame_ciclo_payload(b.prova) end;
  if public._esame_supervisione_hash(j) is distinct from b.payload_sha then raise exception 'Fonti cambiate: approvazione invalidata'; end if;
  if v_mission then
    if b.autore is distinct from auth.uid() or b.risultato->'ok' is distinct from 'true'::jsonb
      or b.risultato->'publishable' is distinct from 'true'::jsonb or not public._esame_session_scope(v.id,auth.uid()) then
      raise exception 'Sessione Narratore non autorizzata nel contesto protetto';
    end if;
  elsif b.risultato->>'ok' is distinct from 'true' or b.risultato->>'validator_version' is distinct from 'SHION-HOLD-001' then
    raise exception 'Controlli non verdi o versione non riconosciuta';
  end if;
  if not v_mission and exists(select 1 from public.esame_supervisione_bozze mb
    where mb.prova=b.prova and mb.tipo='apertura' and mb.stato='pubblicata'
      and mb.risultato->>'validator_version'='MISSION-EXAM-SESSION-001') then
    raise exception 'La sessione richiede il proprio Narratore';
  end if;
  update public.esame_supervisione set publishing=true where prova=b.prova;
  if b.tipo='apertura' then
    if jsonb_typeof(b.risultato->'testo') is distinct from 'string'
      or nullif(btrim(b.risultato->>'testo'),'') is null
      or (not v_mission and length(b.risultato->>'testo') > 4000)
      or b.risultato->>'testo' is distinct from btrim(b.risultato->>'testo') then
      raise exception 'Apertura non pubblicabile integralmente';
    end if;
    select location_id into v_loc from public.academy_class_sessions where id=v.class_session_id;
    mid:=public._esame_supervisione_post(b.prova,v_loc,b.risultato->>'testo');
    if mid is null then raise exception 'Apertura non pubblicata'; end if;
    update public.esame_supervisione set apertura_pubblicata=true where prova=b.prova;
    res:=jsonb_build_object('ok',true,'pubblicato','apertura','message_id',mid);
  else
    u:=b.risultato->'uscita'; t:=b.risultato->'telemetria';
    res:=public.esame_narrazione_apply(b.prova,b.ricevuta,u->>'intenzione_id',u->>'azione_png',u->'esiti',
      t->>'model',(b.risultato->>'prompt_version')::integer,b.risultato->>'impronta_prompt',null,
      (t->>'input_tokens')::integer,(t->>'output_tokens')::integer,t->>'stop_reason',null,
      jsonb_build_object('supervisione_bozza',b.id,'approvata_da',auth.uid(),'chiamate',1));
    if res->>'ripiego'='true' or res->>'scartato'='true' or res->>'pubblicato' is null then
      raise exception 'Pubblicazione rifiutata: stato e bozza conservati';
    end if;
  end if;
  v_ready:=not exists(select 1 from public.esame_narrazione_cicli where prova_id=b.prova and stato='aperta');
  update public.esame_supervisione set publishing=false,player_ready=v_ready,
    pausa_totale=pausa_totale+(now()-pausa_da),pausa_da=now(),
    idle_deadline=case when v_ready then now()+interval '3 hours' else null end where prova=b.prova;
  update public.esame_supervisione_bozze set stato='pubblicata',approvata_da=auth.uid(),pubblicata_at=now() where id=b.id;
  return res;
end; $function$;
CREATE OR REPLACE FUNCTION public.esame_narrazione_apply(p_prova uuid, p_ricevuta uuid, p_intenzione_id text, p_azione text, p_esiti jsonb, p_model text DEFAULT NULL::text, p_prompt_version integer DEFAULT NULL::integer, p_impronta_prompt text DEFAULT NULL::text, p_temperatura numeric DEFAULT NULL::numeric, p_input_tokens integer DEFAULT NULL::integer, p_output_tokens integer DEFAULT NULL::integer, p_stop_reason text DEFAULT NULL::text, p_errori text DEFAULT NULL::text, p_ctx jsonb DEFAULT NULL::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  c public.esame_narrazione_cicli%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_loc uuid; v_int jsonb; v_e jsonb; v_attesi text[];
  v_motivo text; v_res jsonb; v_mid uuid; v_ctx jsonb; v_ok boolean;
  v_prec public.esame_narrazione_cicli%rowtype; v_unificato text;
begin
  -- ── il lock, e l'ordine: prova poi ricevuta, sempre in questo verso ──────
  -- Il ripiego (`esame_prova_tick`) prende gli stessi due lock nello stesso
  -- ordine. Invertirli qui sarebbe un deadlock che si vede solo sotto corsa —
  -- e una corsa è esattamente ciò che questa funzione deve reggere.
  select * into v from public.esame_prove where id = p_prova for update;
  if not found then
    return jsonb_build_object('versione',4,'ok',false,'motivo','prova inesistente');
  end if;
  if v.stato <> 'aperta' then
    return jsonb_build_object('versione',4,'ok',false,'motivo','prova non aperta');
  end if;

  if public._esame_supervisione_blocca(p_prova) then
    return jsonb_build_object('ok',false,'supervisione',true,'pubblicato',false);
  end if;

  select * into c from public.esame_narrazione_cicli
   where opzioni_id = p_ricevuta for update;

  -- ── LO SCONTRINO ─────────────────────────────────────────────────────────
  -- Tre modi di essere in ritardo, e sono tutti la stessa risposta: «scaduta»,
  -- non «errore». HTTP 200, `scartato:true`, ZERO messaggi, ZERO righe
  -- d'audit, ZERO effetti (gate E-27). Sopra questa riga non si scrive niente.
  if not found
     or c.prova_id <> p_prova
     or c.stato <> 'aperta'
     or v.opzioni_id is null
     or v.opzioni_id is distinct from p_ricevuta then
    return jsonb_build_object('versione',4,'ok',false,'scartato',true,
             'motivo','ricevuta scaduta: la prova è già andata avanti');
  end if;

  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select location_id into v_loc from public.academy_class_sessions
   where id = v.class_session_id;

  -- ── l'intenzione dev'essere una di quelle OFFERTE ────────────────────────
  -- ═══ [R2b · TROVATO DALLA PARITÀ DELLA EDGE] `max_tokens` PRIMA DI TUTTO ══
  -- 🔴 In R2 questo blocco stava sotto la ricerca dell'intenzione, ed era un
  --    difetto vero: `max_tokens` si manifesta NORMALMENTE come JSON troncato a
  --    metà, cioè **senza `intenzione_id`**. La ricerca falliva per prima e
  --    l'audit registrava `motivo_ripiego = 'intenzione inventata'` invece di
  --    `tetto_token_raggiunto` — e il corpus dei tetti sarebbe nato misurando
  --    una causa inventata, che è esattamente ciò che il commento qui sotto
  --    dice di voler evitare. Il difetto era il commento giusto messo un passo
  --    troppo in basso.
  --    Lo ha trovato la prova di parità della Edge chiamando questa porta per
  --    nome, non rileggendo il SQL: `R2-K3` non lo copriva perché provava con
  --    un `intenzione_id` valido, cioè con un troncamento che non troncava.
  --
  -- ⚠️ Il blocco NON usa `v_e`: può stare qui, e qui deve stare. Sotto restano
  --    soltanto le cause che presuppongono una risposta ARRIVATA INTERA.
  -- 🔴 In R1 questa regola viveva SOLO nella Edge, ed era l'unico punto del
  --    contratto in cui «se le due dicessero cose diverse ha ragione il
  --    database» non si poteva applicare: il database non aveva niente da dire.
  --    `p_stop_reason` arrivava, veniva archiviato, e non giudicava nulla.
  --
  -- Una risposta tagliata al tetto si scarta **anche se il JSON risulta
  -- intero**: una chiusura fortunata non è una chiusura voluta. Il modello
  -- stava ancora scrivendo, e ciò che manca è precisamente ciò che non sappiamo
  -- — l'ultima branca può essere finita a metà frase e restare sintatticamente
  -- valida.
  --
  -- ⚠️ STA PRIMA del validatore, e l'ordine è una scelta: se venisse dopo, un
  --    JSON tagliato che è ANCHE invalido finirebbe nell'audit col motivo
  --    sbagliato («branca mancante» invece di «tetto raggiunto»), e il corpus
  --    dei tetti si misurerebbe su una causa inventata. Il motivo giusto è
  --    quello che poi decide se alzare il tetto.
  if lower(btrim(coalesce(p_stop_reason,''))) = 'max_tokens' then
    return public._esame_ciclo_ripiego(p_prova, p_ricevuta,
             'tetto_token_raggiunto: stop_reason=max_tokens, risposta scartata prima di qualunque pubblicazione',
             p_model, p_prompt_version, p_impronta_prompt, p_input_tokens,
             p_output_tokens, p_stop_reason, p_errori, p_ctx, p_azione);
  end if;


  select e into v_e
    from jsonb_array_elements(coalesce(v.opzioni_png->'intenzioni','[]'::jsonb)) e
   where e->>'intenzione_id' = p_intenzione_id;

  if v_e is null then
    -- Un'opzione inventata non solleva e non pubblica: registra e degrada.
    -- Una prova non deve mai restare senza continuazione.
    return public._esame_ciclo_ripiego(p_prova, p_ricevuta, 'intenzione inventata',
             p_model, p_prompt_version, p_impronta_prompt, p_input_tokens,
             p_output_tokens, p_stop_reason, p_errori, p_ctx, p_azione);
  end if;

  select coalesce(array_agg(x order by x), array[]::text[]) into v_attesi
    from jsonb_array_elements_text(coalesce(v_e->'esiti_possibili','[]'::jsonb)) x;

  -- [095] L'Assalto ha due esiti autoritativi propri. Il payload IA li ha già
  -- ricevuti da _esame_ciclo_payload: la porta di rientro deve convalidare lo
  -- stesso insieme, non le branche generiche della reazione PNG.
  if c.ruolo = 'png_difende'
     and v.pend_azione->'principale'->>'fonte' = 'moltiplicazione'
     and v.pend_azione->'principale'->>'modalita' = 'assalto' then
    v_attesi := array['copia_colpita','originale_individuato']::text[];
  end if;

  -- [084-A15] La freschezza è già garantita dall'opzioni_id monouso.
  -- Le branche valide sono quelle della singola intenzione scelta,
  -- rilette dalla stessa opzioni_png congelata e validate qui sotto.

  -- ── il validatore, DENTRO la transazione ─────────────────────────────────
  -- La variante redazionale è ammessa solo per la bozza server in pubblicazione.
  if public._esame_session_scope(v.id,auth.uid()) and exists(select 1 from public.esame_supervisione_bozze mb
    join public.esame_supervisione mh on mh.prova=mb.prova
    where mb.prova=p_prova and mb.ricevuta=p_ricevuta and mb.tipo='ciclo'
      and mb.stato='pronta' and mb.autore=auth.uid() and mh.publishing and mh.chiusa_at is null
      and mb.risultato->>'validator_version'='MISSION-EXAM-SESSION-001'
      and mb.risultato->'ok'='true'::jsonb and mb.risultato->'publishable'='true'::jsonb
      and mb.payload_sha=public._esame_supervisione_hash(public._esame_ciclo_payload(p_prova))
      and mb.sha=public._esame_supervisione_hash(jsonb_build_object(
        'ricevuta',mb.ricevuta,'payload_sha',mb.payload_sha,'risultato',mb.risultato))
      and mb.risultato#>>'{uscita,intenzione_id}'=p_intenzione_id
      and mb.risultato#>>'{uscita,azione_png}'=p_azione
      and mb.risultato#>'{uscita,esiti}'=p_esiti) then
    v_motivo := public._esame_mission_formato(p_azione,p_esiti,v_attesi);
  else
    v_motivo := public._esame_narrazione_valida(p_azione,p_esiti,v_attesi,c.ruolo);
  end if;

  -- Un'intenzione senza esiti (manovra, diversivo) non porta branche: la mappa
  -- dev'essere l'oggetto vuoto, e il validatore lo pretende già per identità.
  if v_motivo is not null then
    -- 🔴 NESSUNA SECONDA CHIAMATA. «Una chiamata modello per ciclo significa
    --    una, non una più la correzione» (contratto §2). Il JSON rotto, il
    --    troncamento e la branca mancante finiscono tutti qui.
    return public._esame_ciclo_ripiego(p_prova, p_ricevuta, v_motivo,
             p_model, p_prompt_version, p_impronta_prompt, p_input_tokens,
             p_output_tokens, p_stop_reason, p_errori, p_ctx, p_azione);
  end if;

  -- ── SI CONSUMA LO SCONTRINO, e da qui il ciclo è di questa chiamata ──────
  update public.esame_prove
     set opzioni_png = null, opzioni_id = null, opzioni_at = null
   where id = p_prova;

  update public.esame_narrazione_cicli set
    stato           = 'accettata',
    intenzione_id   = p_intenzione_id,
    azione_png      = btrim(p_azione),
    esiti           = p_esiti,
    esiti_attesi   = v_attesi,
    receipt_sha256  = public._esame_ricevuta_sigillo(
                        c.opzioni_id, p_intenzione_id, btrim(p_azione), p_esiti, v_attesi),
    model           = nullif(btrim(coalesce(p_model,'')),''),
    prompt_version  = p_prompt_version,
    impronta_prompt = nullif(btrim(coalesce(p_impronta_prompt,'')),''),
    temperatura     = p_temperatura,
    input_tokens    = p_input_tokens,
    output_tokens   = p_output_tokens,
    stop_reason     = p_stop_reason,
    accepted_at     = now()
  where id = c.id;

  v_ctx := coalesce(p_ctx,'{}'::jsonb) || jsonb_build_object(
             'contratto_ciclo', 4,
             'ricevuta',        c.opzioni_id,
             'branche',         jsonb_array_length(coalesce(jsonb_path_query_array(p_esiti,'$.keyvalue()'),'[]'::jsonb)),
             'stop_reason',     p_stop_reason,
             'input_tokens',    p_input_tokens,
             'output_tokens',   p_output_tokens);

  insert into public.esame_ia_tentativi
    (prova_id, scambio, meta, attempt, model, prompt_version, esito,
     opzione_scelta, errori, ctx, chars)
  values (p_prova, v.scambio, v.meta, 1,
          nullif(btrim(coalesce(p_model,'')),''), p_prompt_version,
          'pubblicato', p_intenzione_id,
          nullif(btrim(coalesce(p_errori,'')),''), v_ctx,
          length(btrim(coalesce(p_azione,''))));

  -- [098] Il finale salda l'ultimo esito e il congedo del Sensei.
  if c.ruolo = 'png_finale' then
    v_mid := public._esame_supervisione_post(p_prova,v_loc,
      regexp_replace(btrim(p_azione),'[[:space:]]+',' ','g'));
    update public.esame_narrazione_cicli
       set stato='risolta', result_message_id=v_mid, resolved_at=now()
     where id=c.id;
    update public.esame_prove set
      meta='candidato', fase='uscita', pend_azione=null,
      opzioni_png=null, opzioni_id=null, opzioni_at=null
    where id=p_prova and stato='aperta';
    return jsonb_build_object('versione',4,'ok',true,'ricevuta',c.opzioni_id,
      'pubblicato','finale completo','attende','role di uscita');
  end if;

  -- [095/27] Il terzo ruolo narra un fatto già chiuso dal motore.
  if c.ruolo = 'png_esito' then
    v_mid := public._esame_supervisione_post(p_prova,v_loc,
      regexp_replace(btrim(p_azione),'[[:space:]]+',' ','g'));
    update public.esame_narrazione_cicli
       set stato='risolta', result_message_id=v_mid, resolved_at=now()
     where id=c.id;
    update public.esame_narrazione_cicli
       set result_message_id=v_mid
     where id=(select x.id from public.esame_narrazione_cicli x
                where x.prova_id=p_prova and x.ruolo='png_attacca'
                  and x.stato='risolta' and x.result_message_id is null
                order by x.resolved_at desc nulls last,x.created_at desc,x.id desc
                limit 1);
    return jsonb_build_object('versione',4,'ok',true,'ricevuta',c.opzioni_id,
      'pubblicato','esito dopo difesa reale');
  end if;

  -- ── si GIOCA la mossa PRIMA di pubblicare l'AZIONE ───────────────────────
  -- 🔴 L'ordine è il difetto che questo candidato chiude. `esame_png_apply`
  --    pubblicava `p_testo` e POI chiamava `_esame_png_gioca`: se la mossa
  --    veniva rifiutata (uno spostamento a effetto zero, un'intenzione non più
  --    legale), in chat restava un'azione che non è mai accaduta.
  --    Qui si gioca prima. Se il motore rifiuta, la ricevuta torna al ripiego e
  --    NIENTE è stato pubblicato.
  v_res := public._esame_png_gioca(p_prova, coalesce(v_e->>'chiave', p_intenzione_id), 'ia');

  -- 🔴 [BANCO 038 · difetto 1] `_esame_png_gioca` NON restituisce sempre `ok`.
  --    Quando l'intenzione è una REAZIONE — cioè in tutto il ramo `png_difende`,
  --    che è il cuore del contratto §3 — delega a `_esame_risolvi`, e quella
  --    restituisce `{versione, ordine, esito, esito_copie, colpito, striscio,
  --    danno}`: nessun `ok`. Leggerlo con `coalesce(…,false)` faceva quindi
  --    scattare il ramo «mossa rifiutata dal motore» su OGNI difesa RIUSCITA:
  --    la ricevuta appena risolta veniva marcata `scartata`, la prova degradata
  --    a `ia_degradata=true`, nasceva una seconda riga `esame_ia_tentativi` e
  --    `_esame_ciclo_ripiego` pubblicava un SECONDO messaggio del Narratore.
  --    Misurato dal banco su §B6/§B8: due messaggi invece di uno.
  --    Un rifiuto è tale solo se il motore lo DICE: `ok` assente più `esito`
  --    presente vuol dire «lo scambio è stato risolto», non «è fallito».
  v_ok := case when v_res ? 'ok' then coalesce((v_res->>'ok')::boolean, false)
               else (v_res ? 'esito') end;

  if not v_ok then
    update public.esame_narrazione_cicli
       set stato = 'scartata', resolved_at = now()
     where id = c.id;
    return public._esame_ciclo_ripiego(p_prova, null,
             'mossa rifiutata dal motore: ' || coalesce(v_res->>'motivo','?'),
             p_model, p_prompt_version, p_impronta_prompt, p_input_tokens,
             p_output_tokens, p_stop_reason, p_errori, p_ctx, p_azione);
  end if;

  -- ── (a) il PNG si DIFENDEVA: `_esame_risolvi` ha già pubblicato AZIONE+ESITO
  -- in UN messaggio solo, leggendo la ricevuta. Qui non resta niente da fare.
  if c.ruolo = 'png_difende' then
    return v_res || jsonb_build_object('versione',4,'ricevuta',c.opzioni_id,
                      'pubblicato','azione+esito');
  end if;

  -- ── (b) il PNG ha ATTACCATO: si pubblica la SOLA AZIONE ──────────────────
  select * into v_prec
    from public.esame_narrazione_cicli
   where prova_id = p_prova
     and ruolo = 'png_difende'
     and stato = 'risolta'
     and result_message_id is null
     and coalesce((referto->>'legacy')::boolean, false) = false
     and (referto is not null or nullif(btrim(testo_esito),'') is not null)
   order by resolved_at desc nulls last, created_at desc, id desc
   limit 1 for update;

  if found then
    -- 🔴 QUI STAVA LA SALDATURA. `testo_esito` era prosa di catalogo e veniva
    --    incollata davanti al testo del modello: due voci, la difesa raccontata
    --    due volte, e la contraddizione fra «a segno» del server e «assorbe
    --    l'urto» del modello. Adesso il modello ha ricevuto `esito_precedente`
    --    e ha scritto il racconto INTERO: si pubblica il suo testo e basta.
    -- 🔴 [A5] E NON si accoda l'appendice. Il messaggio pubblicato è la sola
    --    prosa del modello: `v_prec.referto->>'appendice'` resta dov'è —
    --    nel referto, per l'audit — e non attraversa più la chat.
    v_unificato := btrim(p_azione);
    v_mid := public._esame_supervisione_post(p_prova,v_loc, v_unificato);
    update public.esame_narrazione_cicli
       set result_message_id = v_mid
     where id = v_prec.id;
  else
    -- Fail-safe per prove storiche senza il nuovo deposito: una sola azione,
    -- comunque compatta e senza intestazione tecnica.
    v_mid := public._esame_supervisione_post(p_prova,v_loc, btrim(p_azione));
  end if;

  -- Una manovra e un diversivo non lasciano nessuna mossa in attesa: non ci
  -- sarà nessun ESITO, e la ricevuta si chiude qui. Non è una mancanza: è
  -- un'azione che chiude la metà, e dirlo è più onesto che inventare un esito.
  if v_res->>'genere' in ('manovra','diversivo') or coalesce(array_length(v_attesi,1),0) = 0 then
    update public.esame_narrazione_cicli
       set stato = 'risolta', action_message_id = v_mid, resolved_at = now()
     where id = c.id;
    return v_res || jsonb_build_object('versione',4,'ricevuta',c.opzioni_id,
                      'pubblicato','azione');
  end if;

  update public.esame_narrazione_cicli
     set action_message_id = v_mid
   where id = c.id;

  return v_res || jsonb_build_object('versione',4,'ricevuta',c.opzioni_id,
                    'pubblicato','azione','attende','difesa del candidato');
end
$function$;
CREATE OR REPLACE FUNCTION public._esame_supervisione_post(p_prova uuid, p_location uuid, p_corpo text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_mid uuid;
begin
  if not exists(select 1 from public.esame_prove e join public.academy_class_sessions s on s.id=e.class_session_id
    where e.id=p_prova and s.location_id=p_location) then raise exception 'Prova e stanza non corrispondono'; end if;
  if public._esame_supervisione_blocca(p_prova) then raise exception 'Supervisione: manca approvazione della bozza'; end if;
  -- Il vecchio post tronca a 4000: il nuovo percorso conserva l'intero testo.
  if exists(select 1 from public.esame_prove v
    join public.esame_supervisione mh on mh.prova=v.id
    join public.esame_supervisione_bozze mb on mb.prova=v.id
    where v.id=p_prova and v.stato='aperta' and mh.publishing and mh.chiusa_at is null
      and mb.stato='pronta' and mb.autore=auth.uid()
      and mb.risultato->>'validator_version'='MISSION-EXAM-SESSION-001'
      and mb.risultato->'ok'='true'::jsonb and mb.risultato->'publishable'='true'::jsonb
      and public._esame_session_scope(v.id,auth.uid())) then
    if nullif(btrim(p_corpo),'') is null then raise exception 'Testo Narratore assente'; end if;
    insert into public.messages(location_id,character_id,sender_user,author_name,body,kind)
      values(p_location,null,null,'Il narratore',btrim(p_corpo),'sistema') returning id into v_mid;
    return v_mid;
  end if;
  return public._esame_narratore_post(p_location,p_corpo);
end; $function$;DO $acl$ BEGIN
  IF has_function_privilege('anon','public._esame_mission_formato(text,jsonb,text[])','EXECUTE')
    OR has_function_privilege('authenticated','public._esame_mission_formato(text,jsonb,text[])','EXECUTE')
    OR NOT has_function_privilege('service_role','public._esame_mission_formato(text,jsonb,text[])','EXECUTE')
  THEN RAISE EXCEPTION 'ACL helper non conformi'; END IF;
END $acl$;

COMMIT;
