BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='30s';
DO $preflight$
BEGIN
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'administrative_owner_required'; END IF;
 IF md5(pg_get_functiondef('public.esame_supervisione_chiudi(uuid)'::regprocedure))<>'81ca0d67dbe5b3845164ffddb0a51bb8'
 OR md5(pg_get_functiondef('public.esame_prova_tick()'::regprocedure))<>'67ce890acefa429e7df420132d2ad137'
 OR (SELECT md5(coalesce(jsonb_agg(jsonb_build_object('def',pg_get_triggerdef(oid),'enabled',tgenabled) order by tgname),'[]')::text) FROM pg_trigger WHERE tgrelid='public.esame_prove'::regclass AND NOT tgisinternal)<>'252f798c726ba761ea2aa70f23a99f24'
 OR to_regprocedure('public._esame_prenotazione_chiudi_su_terminale()') IS NOT NULL
 THEN RAISE EXCEPTION 'exam_reservation_lifecycle_baseline_drift'; END IF;
END $preflight$;
CREATE OR REPLACE FUNCTION public._esame_prenotazione_chiudi_su_terminale()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $body$
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
$body$;
ALTER FUNCTION public._esame_prenotazione_chiudi_su_terminale() OWNER TO postgres;
REVOKE ALL ON FUNCTION public._esame_prenotazione_chiudi_su_terminale() FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public._esame_prenotazione_chiudi_su_terminale() TO postgres;
CREATE TRIGGER esame_prenotazione_chiudi_su_terminale
AFTER UPDATE OF stato ON public.esame_prove
FOR EACH ROW
EXECUTE FUNCTION public._esame_prenotazione_chiudi_su_terminale();
COMMENT ON FUNCTION public._esame_prenotazione_chiudi_su_terminale() IS
'EXAM-RESERVATION-LIFECYCLE-001 STAFF: disattiva solo prenotazione della prova terminale; storico conservato';
COMMIT;
