BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '30s';

DO $preflight$
BEGIN
  IF md5((SELECT prosrc FROM pg_proc WHERE oid = 'public.training_start(uuid,uuid)'::regprocedure)) <> 'd84d1a5cc5f7bd44d32bf30d720f5f26'
    OR md5((SELECT prosrc FROM pg_proc WHERE oid = 'public.enter_land()'::regprocedure)) <> 'a1d8b16854c7d5274a03b77c1ff1ec76'
    OR md5((SELECT prosrc FROM pg_proc WHERE oid = 'public.combat_panel_state_v1(uuid,uuid)'::regprocedure)) <> '00ed8863b22f7965e38e91043a0ed665'
    OR md5((SELECT prosrc FROM pg_proc WHERE oid = 'public.training_start_guided_v2(uuid,uuid,uuid,integer,text)'::regprocedure)) <> '170be5b1e1c1bcd511ad0c35cfb979e4'
    OR md5((SELECT prosrc FROM pg_proc WHERE oid = 'public._training_giornata(timestamptz)'::regprocedure)) <> 'd055225729d86a2914a9e6fcd19c2b9e'
  THEN RAISE EXCEPTION 'Baseline Training cambiata'; END IF;
END;
$preflight$;

CREATE SCHEMA training_sheet_private;
REVOKE ALL ON SCHEMA training_sheet_private FROM PUBLIC, anon, authenticated, service_role;

CREATE TABLE training_sheet_private.release_v1 (
  singleton boolean PRIMARY KEY DEFAULT true CHECK (singleton),
  staff_enabled boolean NOT NULL,
  public_enabled boolean NOT NULL
);
INSERT INTO training_sheet_private.release_v1 VALUES (true, true, false);

CREATE TABLE training_sheet_private.day_sessions_v1 (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  character_id uuid NOT NULL REFERENCES public.characters(id),
  technique_id uuid NOT NULL REFERENCES public.clan_techniques(id),
  ability_id uuid REFERENCES public.character_abilities(id),
  receipt_id uuid UNIQUE REFERENCES public.training_sessions(id),
  request_key uuid NOT NULL,
  simulated boolean NOT NULL,
  day date NOT NULL,
  started_at timestamptz NOT NULL,
  ends_at timestamptz NOT NULL CHECK (ends_at > started_at),
  xp_spent integer NOT NULL CHECK (xp_spent >= 0),
  completed_at timestamptz CHECK (completed_at >= ends_at),
  UNIQUE (character_id, simulated, day),
  UNIQUE (character_id, simulated, request_key),
  CHECK (simulated = (ability_id IS NULL) AND simulated = (receipt_id IS NULL))
);
CREATE UNIQUE INDEX day_sessions_one_pending_v1
  ON training_sheet_private.day_sessions_v1(character_id, simulated)
  WHERE completed_at IS NULL;

ALTER TABLE training_sheet_private.release_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_sheet_private.day_sessions_v1 ENABLE ROW LEVEL SECURITY;
CREATE TABLE training_sheet_private.staff_xp_v1 (
  character_id uuid PRIMARY KEY REFERENCES public.characters(id),
  balance integer NOT NULL CHECK (balance >= 0)
);
ALTER TABLE training_sheet_private.staff_xp_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON ALL TABLES IN SCHEMA training_sheet_private FROM PUBLIC, anon, authenticated, service_role;

ALTER TABLE public.training_sessions
  DROP CONSTRAINT training_sessions_modalita_chk,
  DROP CONSTRAINT training_sessions_stato_chk,
  DROP CONSTRAINT training_sessions_scena_coerente_chk,
  ADD CONSTRAINT training_sessions_modalita_chk
    CHECK (modalita IN ('legacy','individuale','cooperativa','gruppo','scheda')),
  ADD CONSTRAINT training_sessions_stato_chk
    CHECK (stato IN ('legacy_review','legacy_approvata','dichiarata','sospetta','valida','respinta','abbandonata','annullata','prenotata_scheda')),
  ADD CONSTRAINT training_sessions_scena_coerente_chk
    CHECK ((modalita IN ('legacy','scheda') AND role_session_id IS NULL)
      OR (modalita NOT IN ('legacy','scheda') AND role_session_id IS NOT NULL AND dichiarata_at IS NOT NULL)),
  ADD CONSTRAINT training_sessions_scheda_chk
    CHECK ((stato <> 'prenotata_scheda' OR modalita = 'scheda')
      AND (modalita <> 'scheda' OR (giornata IS NOT NULL AND combat_session_id IS NULL
        AND stato IN ('prenotata_scheda','valida','annullata'))));

-- Lo stesso indice arbitra la quota legacy e quella della Scheda, senza lock in ordine inverso.
CREATE UNIQUE INDEX ts_quota_scheda_e_role_v1 ON public.training_sessions(character_id,giornata)
  WHERE giornata IS NOT NULL AND stato IN ('sospetta','valida','prenotata_scheda');

CREATE FUNCTION training_sheet_private.scope_v1(p_character public.characters)
RETURNS text LANGUAGE plpgsql STABLE SET search_path = '' AS $scope$
DECLARE
  current_location uuid;
  gate training_sheet_private.release_v1%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL OR p_character.user_id IS DISTINCT FROM auth.uid() THEN RETURN NULL; END IF;
  SELECT * INTO STRICT gate FROM training_sheet_private.release_v1 WHERE singleton;
  SELECT p.location_id INTO current_location FROM public.presence p
    WHERE p.user_id = auth.uid() AND NOT p.left_logged;
  IF p_character.is_test IS TRUE OR EXISTS (
    SELECT 1 FROM public.locations l WHERE l.id = current_location AND l.is_test
  ) THEN
    IF gate.staff_enabled AND p_character.is_test IS TRUE
      AND p_character.id = '2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid AND public.is_staff()
      AND current_location = '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND EXISTS (SELECT 1 FROM public.locations l WHERE l.id = current_location AND l.is_active AND l.is_test)
      AND EXISTS (SELECT 1 FROM public.presence p WHERE p.user_id = auth.uid() AND p.last_seen >= now() - interval '8 minutes')
    THEN RETURN 'staff'; END IF;
    RETURN NULL;
  END IF;
  IF gate.public_enabled THEN RETURN 'land'; END IF;
  RETURN NULL;
END;
$scope$;

CREATE FUNCTION training_sheet_private.is_special_v1(t public.clan_techniques)
RETURNS boolean LANGUAGE sql STABLE SET search_path = '' AS $special$
  SELECT coalesce(t.is_innata,false) OR coalesce(t.is_leggendaria,false)
    OR coalesce(t.macro IN ('evocazione','cercoterio'),false)
    OR EXISTS (SELECT 1 FROM public.training_guidance_policies p WHERE p.technique_id=t.id AND p.enforcement<>'disabled');
$special$;

CREATE FUNCTION training_sheet_private.end_for_day_v1(p_day date)
RETURNS timestamptz LANGUAGE sql STABLE SET search_path = '' AS $boundary$
  SELECT ((p_day + 1)::timestamp + interval '6 hours') AT TIME ZONE 'Europe/Rome';
$boundary$;

CREATE FUNCTION training_sheet_private.payload_v1(s training_sheet_private.day_sessions_v1)
RETURNS jsonb LANGUAGE sql STABLE SET search_path = '' AS $payload$
  SELECT jsonb_build_object('technique_id',s.technique_id,'status',
    CASE WHEN s.completed_at IS NULL THEN 'in_corso' ELSE 'appresa' END,
    'day',s.day,'ends_at',s.ends_at,'xp_spent',s.xp_spent);
$payload$;

-- Il chiamante ha già bloccato la scheda e ha derivato lo scope dal server.
CREATE FUNCTION training_sheet_private.settle_v1(p_character uuid, p_simulated boolean, p_now timestamptz)
RETURNS void LANGUAGE plpgsql SET search_path = '' AS $settle$
DECLARE s training_sheet_private.day_sessions_v1%ROWTYPE;
BEGIN
  UPDATE training_sheet_private.day_sessions_v1
    SET completed_at = p_now
    WHERE character_id = p_character AND simulated = p_simulated AND completed_at IS NULL AND ends_at <= p_now
    RETURNING * INTO s;
  IF NOT FOUND OR s.simulated THEN RETURN; END IF;

  UPDATE public.character_abilities SET state='attiva', sessions_done=1, activated_at=s.ends_at
    WHERE id=s.ability_id AND character_id=s.character_id AND technique_id=s.technique_id AND state='in_addestramento';
  IF NOT FOUND THEN RAISE EXCEPTION 'Ricevuta Scheda senza addestramento corrispondente'; END IF;

  UPDATE public.training_sessions SET stato='valida', registrata_at=s.ends_at, decisione_at=p_now,
    sessions_done_dopo=1, sessions_required_dopo=1
    WHERE id=s.receipt_id AND modalita='scheda' AND stato='prenotata_scheda';
  IF NOT FOUND THEN RAISE EXCEPTION 'Prenotazione giornaliera non riconciliabile'; END IF;
END;
$settle$;

CREATE FUNCTION training_sheet_private.guard_role_v1()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $guard$
BEGIN
  IF NEW.modalita<>'scheda' AND NEW.stato IN ('dichiarata','sospetta','valida') AND EXISTS (
    SELECT 1 FROM training_sheet_private.day_sessions_v1 s
      WHERE s.character_id=NEW.character_id AND s.technique_id=NEW.technique_id
        AND NOT s.simulated AND s.completed_at IS NULL
  ) THEN
    RAISE EXCEPTION USING ERRCODE='55000', MESSAGE='L’allenamento individuale è già in corso in Scheda';
  END IF;
  RETURN NEW;
END;
$guard$;
CREATE TRIGGER training_sheet_guard_role_v1 BEFORE INSERT OR UPDATE OF stato, giornata ON public.training_sessions
  FOR EACH ROW EXECUTE FUNCTION training_sheet_private.guard_role_v1();

CREATE FUNCTION training_sheet_private.guard_ability_v1()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $guard$
BEGIN
  IF OLD.state='in_addestramento' AND EXISTS (
    SELECT 1 FROM training_sheet_private.day_sessions_v1 s WHERE s.ability_id=OLD.id AND NOT s.simulated AND s.completed_at IS NULL
  ) AND (NEW.state,NEW.sessions_done,NEW.started_at,NEW.activated_at)
      IS DISTINCT FROM (OLD.state,OLD.sessions_done,OLD.started_at,OLD.activated_at) THEN
    RAISE EXCEPTION USING ERRCODE='55000', MESSAGE='La conclusione è regolata dalla giornata dell’allenamento in Scheda';
  END IF;
  RETURN NEW;
END;
$guard$;
CREATE TRIGGER training_sheet_guard_ability_v1 BEFORE UPDATE OF state,sessions_done,started_at,activated_at ON public.character_abilities
  FOR EACH ROW EXECUTE FUNCTION training_sheet_private.guard_ability_v1();

CREATE FUNCTION public.training_sheet_state_v1(p_character uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $state$
DECLARE
  c public.characters%ROWTYPE;
  s training_sheet_private.day_sessions_v1%ROWTYPE;
  scope text;
  v_simulated boolean;
  checked_at timestamptz;
  game_day date;
BEGIN
  SELECT x.* INTO c FROM public.characters x WHERE x.id=p_character AND x.user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION USING ERRCODE='42501', MESSAGE='Scheda non autorizzata'; END IF;
  scope:=training_sheet_private.scope_v1(c);
  IF scope IS NULL THEN RETURN jsonb_build_object('enabled',false); END IF;
  v_simulated:=scope='staff';
  SELECT x.* INTO STRICT c FROM public.characters x WHERE x.id=p_character AND x.user_id=auth.uid() FOR UPDATE;
  checked_at:=clock_timestamp();
  game_day:=public._training_giornata(checked_at);
  PERFORM training_sheet_private.settle_v1(c.id,v_simulated,checked_at);
  SELECT d.* INTO s FROM training_sheet_private.day_sessions_v1 d
    WHERE d.character_id=c.id AND d.simulated=v_simulated ORDER BY d.day DESC LIMIT 1;
  RETURN jsonb_build_object('enabled',true,'simulated',v_simulated,'day',game_day,
    'next_reset_at',training_sheet_private.end_for_day_v1(game_day),
    'day_reserved',coalesce(s.day=game_day,false) OR (NOT v_simulated AND EXISTS (
      SELECT 1 FROM public.training_sessions v WHERE v.character_id=c.id AND v.giornata=game_day AND v.stato IN ('sospetta','valida','prenotata_scheda')
    )), 'session',CASE WHEN s.id IS NULL THEN NULL ELSE training_sheet_private.payload_v1(s) END,
    'special_techniques',(SELECT coalesce(jsonb_agg(t.id ORDER BY t.id),'[]'::jsonb)
      FROM public.clan_techniques t WHERE t.is_active AND training_sheet_private.is_special_v1(t)));
END;
$state$;

CREATE FUNCTION public.training_sheet_start_v1(p_character uuid, p_technique uuid, p_request uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $start$
DECLARE
  c public.characters%ROWTYPE;
  t public.clan_techniques%ROWTYPE;
  s training_sheet_private.day_sessions_v1%ROWTYPE;
  scope text;
  v_simulated boolean;
  checked_at timestamptz;
  game_day date;
  cost integer;
  elig jsonb;
  selected_ability uuid;
  selected_receipt uuid;
BEGIN
  IF p_technique IS NULL OR p_request IS NULL THEN RAISE EXCEPTION USING ERRCODE='22023',MESSAGE='Richiesta Allenamento incompleta'; END IF;
  SELECT x.* INTO c FROM public.characters x WHERE x.id=p_character AND x.user_id=auth.uid() FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION USING ERRCODE='42501', MESSAGE='Scheda non autorizzata'; END IF;
  scope:=training_sheet_private.scope_v1(c);
  IF scope IS NULL THEN RETURN jsonb_build_object('ok',false,'code','DISABLED'); END IF;
  v_simulated:=scope='staff';
  checked_at:=clock_timestamp();
  game_day:=public._training_giornata(checked_at);
  PERFORM training_sheet_private.settle_v1(c.id,v_simulated,checked_at);

  SELECT d.* INTO s FROM training_sheet_private.day_sessions_v1 d
    WHERE d.character_id=c.id AND d.simulated=v_simulated AND d.request_key=p_request;
  IF FOUND THEN
    IF s.technique_id<>p_technique THEN RETURN jsonb_build_object('ok',false,'code','REQUEST_CONFLICT'); END IF;
    RETURN jsonb_build_object('ok',true,'session',training_sheet_private.payload_v1(s));
  END IF;
  SELECT * INTO t FROM public.clan_techniques WHERE id=p_technique AND is_active FOR SHARE;
  IF NOT FOUND OR training_sheet_private.is_special_v1(t) THEN
    RETURN jsonb_build_object('ok',false,'code','TECHNIQUE_UNAVAILABLE');
  END IF;
  IF EXISTS (SELECT 1 FROM training_sheet_private.day_sessions_v1 d
      WHERE d.character_id=c.id AND d.simulated=v_simulated AND d.day=game_day)
    OR (NOT v_simulated AND EXISTS (SELECT 1 FROM public.training_sessions v
      WHERE v.character_id=c.id AND v.giornata=game_day AND v.stato IN ('sospetta','valida','prenotata_scheda')))
  THEN RETURN jsonb_build_object('ok',false,'code','DAY_RESERVED'); END IF;
  IF EXISTS(SELECT 1 FROM public.character_abilities a WHERE a.character_id=c.id AND a.state='in_addestramento') THEN
    RETURN jsonb_build_object('ok',false,'code','TRAINING_ACTIVE');
  END IF;
  IF v_simulated AND EXISTS(SELECT 1 FROM training_sheet_private.day_sessions_v1 d
    WHERE d.character_id=c.id AND d.simulated AND d.technique_id=t.id AND d.completed_at IS NOT NULL) THEN
    RETURN jsonb_build_object('ok',false,'code','ALREADY_LEARNED');
  END IF;
  elig:=public.training_eligibility(t.id,c.id);
  IF NOT coalesce((elig->>'eligible')::boolean,false) THEN
    RETURN jsonb_build_object('ok',false,'code','INELIGIBLE','reasons',coalesce(elig->'reasons','[]'::jsonb));
  END IF;
  cost:=greatest(coalesce(t.xp_cost,0),0);

  IF v_simulated THEN
    INSERT INTO training_sheet_private.staff_xp_v1(character_id,balance) VALUES(c.id,greatest(coalesce(c.exp,0),0))
      ON CONFLICT (character_id) DO NOTHING;
    UPDATE training_sheet_private.staff_xp_v1 SET balance=balance-cost WHERE character_id=c.id AND balance>=cost;
    IF NOT FOUND THEN RETURN jsonb_build_object('ok',false,'code','XP_INSUFFICIENT'); END IF;
  ELSE
    BEGIN
      INSERT INTO public.training_sessions(character_id,technique_id,modalita,stato,giornata,decisione_motivo)
        VALUES(c.id,t.id,'scheda','prenotata_scheda',game_day,'Allenamento individuale in Scheda')
        RETURNING id INTO selected_receipt;
    EXCEPTION WHEN unique_violation THEN
      RETURN jsonb_build_object('ok',false,'code','DAY_RESERVED');
    END;
    IF cost>0 AND NOT public._spendi_xp(c.id,cost,'tecnica in Scheda: '||t.name||coalesce(' L'||t.level,'')) THEN
      RAISE EXCEPTION USING ERRCODE='55000', MESSAGE='XP_INSUFFICIENT';
    END IF;
    INSERT INTO public.character_abilities(character_id,technique_id,state,sessions_done,started_at)
      VALUES(c.id,t.id,'in_addestramento',0,checked_at)
      ON CONFLICT(character_id,technique_id) DO UPDATE SET state='in_addestramento',sessions_done=0,
        started_at=EXCLUDED.started_at,activated_at=NULL,trained_by=NULL,approved_by=NULL
        WHERE character_abilities.state='annullata'
      RETURNING id INTO selected_ability;
    IF NOT FOUND THEN RAISE EXCEPTION 'TRAINING_START_STATE_CONFLICT'; END IF;
  END IF;

  INSERT INTO training_sheet_private.day_sessions_v1 (character_id,technique_id,ability_id,receipt_id,request_key,simulated,day,started_at,ends_at,xp_spent)
    VALUES(c.id,t.id,selected_ability,selected_receipt,p_request,v_simulated,game_day,checked_at,
      training_sheet_private.end_for_day_v1(game_day),cost) RETURNING * INTO s;
  RETURN jsonb_build_object('ok',true,'session',training_sheet_private.payload_v1(s));
END;
$start$;

CREATE FUNCTION training_sheet_private.on_player_request_v1()
RETURNS void LANGUAGE plpgsql SET search_path = '' AS $entry$
DECLARE c public.characters%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL OR EXISTS (
    SELECT 1 FROM public.presence p JOIN public.locations l ON l.id=p.location_id
      WHERE p.user_id=auth.uid() AND NOT p.left_logged AND l.is_test
  ) THEN RETURN; END IF;
  FOR c IN SELECT x.* FROM public.characters x
    JOIN training_sheet_private.day_sessions_v1 s ON s.character_id=x.id
    WHERE x.user_id=auth.uid() AND x.is_test IS NOT TRUE
      AND NOT s.simulated AND s.completed_at IS NULL AND s.ends_at<=clock_timestamp()
    ORDER BY x.id FOR UPDATE OF x
  LOOP
    PERFORM training_sheet_private.settle_v1(c.id,false,clock_timestamp());
  END LOOP;
END;
$entry$;

-- Innesta sui corpi vivi, conservando firme, permessi e comportamento delle tecniche speciali.
DO $compose$
DECLARE body text;
BEGIN
  body:=pg_get_functiondef('public.training_start(uuid,uuid)'::regprocedure);
  body:=replace(body,'select * into c from public.characters where id=v_char;',
                    'select * into c from public.characters where id=v_char for update;');
  body:=replace(body,$old$  select t2.name||coalesce(' · livello '||t2.level,'') into v_in_corso$old$,
$new$  if c.is_test is true or (c.user_id=auth.uid() and exists (
    select 1 from public.presence p join public.locations l on l.id=p.location_id
      where p.user_id=auth.uid() and not p.left_logged and l.is_test
  )) then
    return jsonb_build_object('ok',false,'reasons',jsonb_build_array('In Staff usa l’allenamento protetto in Scheda.'));
  end if;
  if training_sheet_private.scope_v1(c) is not null and not training_sheet_private.is_special_v1(t) then
    return jsonb_build_object('ok',false,'reasons',jsonb_build_array('Avvia l’allenamento giornaliero in Scheda.'));
  end if;
  select t2.name||coalesce(' · livello '||t2.level,'') into v_in_corso$new$);
  IF strpos(body,'training_sheet_private.scope_v1(c)')=0 OR strpos(body,'where id=v_char for update;')=0 THEN
    RAISE EXCEPTION 'Composizione training_start incompleta';
  END IF;
  EXECUTE body;

  body:=pg_get_functiondef('public.enter_land()'::regprocedure);
  body:=replace(body,'  if not v_staff_resume then perform public.applica_recupero(); end if;',
      E'  if not v_staff_resume then perform public.applica_recupero(); end if;\n  perform training_sheet_private.on_player_request_v1();');
  IF strpos(body,'perform training_sheet_private.on_player_request_v1()')=0 THEN RAISE EXCEPTION 'Composizione enter_land incompleta'; END IF;
  EXECUTE body;

  body:=pg_get_functiondef('public.combat_panel_state_v1(uuid,uuid)'::regprocedure);
  body:=replace(body,' IF reason IS NOT NULL THEN RETURN combat_panel_private.blocked(reason); END IF;',
$entry$ IF reason IS NOT NULL THEN RETURN combat_panel_private.blocked(reason); END IF;
 IF EXISTS (SELECT 1 FROM public.locations l WHERE l.id=p_location AND l.is_active AND NOT l.is_test) THEN
   PERFORM training_sheet_private.on_player_request_v1();
 END IF;$entry$);
  IF strpos(body,'PERFORM training_sheet_private.on_player_request_v1()')=0 THEN
    RAISE EXCEPTION 'Composizione del pannello Combat incompleta';
  END IF;
  EXECUTE body;
END;
$compose$;

REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA training_sheet_private FROM PUBLIC, anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.training_sheet_state_v1(uuid),public.training_sheet_start_v1(uuid,uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.training_sheet_state_v1(uuid),public.training_sheet_start_v1(uuid,uuid,uuid) TO authenticated;

COMMIT;
