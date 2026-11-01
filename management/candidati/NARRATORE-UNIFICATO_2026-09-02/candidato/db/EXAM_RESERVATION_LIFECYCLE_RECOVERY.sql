-- Solo recovery necessaria; nessuna riapertura o ripristino dei dati.
BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='30s';
SET LOCAL search_path=pg_catalog;
DO $preflight$
BEGIN
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'administrative_owner_required'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_proc p WHERE p.oid='public._esame_prenotazione_chiudi_su_terminale()'::regprocedure
 AND (p.prosrc=$expected0$
BEGIN
  -- EXAM-RESERVATION-LIFECYCLE-001: stato terminale autoritativo, nessuna cancellazione.
  IF NEW.stato NOT IN ('conclusa','annullata') OR OLD.stato IS NOT DISTINCT FROM NEW.stato THEN
    RETURN NEW;
  END IF;
  -- Disponibilita iniziale riservata alla Staff Test Room.
  IF NOT EXISTS (SELECT 1 FROM public.academy_class_sessions s
                 WHERE s.id=NEW.class_session_id
                   AND s.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid) THEN
    RETURN NEW;
  END IF;
  UPDATE public.esame_supervisione_prenotazioni
     SET is_active=false
   WHERE prova=NEW.id AND is_active;
  RETURN NEW;
END
$expected0$ OR p.prosrc=$expected1$
BEGIN
  -- EXAM-RESERVATION-LIFECYCLE-001: stato terminale autoritativo, nessuna cancellazione.
  IF NEW.stato NOT IN ('conclusa','annullata') OR OLD.stato IS NOT DISTINCT FROM NEW.stato THEN
    RETURN NEW;
  END IF;
  UPDATE public.esame_supervisione_prenotazioni
     SET is_active=false
   WHERE prova=NEW.id AND is_active;
  RETURN NEW;
END
$expected1$) AND p.prosecdef AND p.prorettype='trigger'::regtype AND p.pronargs=0
 AND p.proowner='postgres'::regrole AND p.prolang=(SELECT oid FROM pg_language WHERE lanname='plpgsql')
 AND p.proconfig=ARRAY['search_path=""']::text[] AND p.provolatile='v' AND NOT p.proleakproof AND p.proparallel='u'
 AND (SELECT count(*) FROM aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))))=1
 AND NOT EXISTS(SELECT 1 FROM aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) a
 WHERE a.grantee<>p.proowner OR a.grantor<>p.proowner OR a.privilege_type<>'EXECUTE' OR a.is_grantable)
 )
 OR NOT EXISTS(SELECT 1 FROM pg_trigger t WHERE t.tgrelid='public.esame_prove'::regclass
 AND t.tgname='esame_prenotazione_chiudi_su_terminale'
 AND t.tgfoid='public._esame_prenotazione_chiudi_su_terminale()'::regprocedure
 AND t.tgenabled IN ('O','D') AND pg_get_triggerdef(t.oid)='CREATE TRIGGER esame_prenotazione_chiudi_su_terminale AFTER UPDATE OF stato ON public.esame_prove FOR EACH ROW EXECUTE FUNCTION public._esame_prenotazione_chiudi_su_terminale()')
 THEN RAISE EXCEPTION 'exam_reservation_lifecycle_identity_drift'; END IF;
END $preflight$;
ALTER TABLE public.esame_prove DISABLE TRIGGER esame_prenotazione_chiudi_su_terminale;
COMMIT;
