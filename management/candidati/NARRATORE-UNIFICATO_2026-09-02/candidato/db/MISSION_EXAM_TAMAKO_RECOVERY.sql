-- SESSION-TAMAKO-001 · frammento recovery, NON eseguire separatamente.
-- Usare soltanto MISSION_EXAM_RELEASE_RECOVERY.sql: un unico BEGIN/COMMIT
-- e tutti i preflight Tamako+publisher prima di qualunque mutazione.
-- Il frammento ripete le proprie guardie, senza commit interni.
-- Esige zero prove protette attive; non chiude né cancella una prova per
-- ottenere il gate. Conserva policy, audit e definizioni archiviate.
-- PREFLIGHT BEGIN
DO $tamako_preflight$
DECLARE backup_row record;
BEGIN
  PERFORM 1 FROM mission_exam_private.release_gate WHERE singleton FOR UPDATE;
  IF EXISTS(SELECT 1 FROM mission_exam_private.protected_sessions WHERE state<>'closed') THEN
    RAISE EXCEPTION 'mission_session_recovery_active_trial'; END IF;
  IF EXISTS(SELECT 1 FROM public.esame_supervisione_bozze draft_row
    JOIN mission_exam_private.protected_sessions q ON q.prova_id=draft_row.prova
    WHERE draft_row.stato='generazione') THEN RAISE EXCEPTION 'mission_session_recovery_active_claim'; END IF;
  IF (SELECT count(*) FROM mission_exam_private.function_backups)<>8 THEN
    RAISE EXCEPTION 'mission_session_recovery_backup_incomplete'; END IF;
  FOR backup_row IN SELECT * FROM mission_exam_private.function_backups ORDER BY signature LOOP
    IF pg_get_functiondef(backup_row.signature::regprocedure) IS DISTINCT FROM backup_row.candidate_definition THEN
      RAISE EXCEPTION 'mission_session_recovery_drift: %',backup_row.signature; END IF;
  END LOOP;
END $tamako_preflight$;
-- PREFLIGHT END

-- APPLY BEGIN
DO $recovery$
DECLARE backup_row record;
BEGIN
  UPDATE mission_exam_private.release_gate SET enabled=false WHERE singleton;
  FOR backup_row IN SELECT * FROM mission_exam_private.function_backups ORDER BY signature LOOP
    EXECUTE backup_row.original_definition;
  END LOOP;
END $recovery$;

REVOKE ALL ON FUNCTION public.esame_session_readiness(),public.esame_session_open(uuid),
 public.esame_session_state(uuid),public.esame_session_authorize(uuid,uuid),
 public.esame_session_publish(uuid,text),public.esame_session_close(uuid,uuid),
 public._esame_session_scope(uuid,uuid),public._esame_session_claim(uuid,uuid)
 FROM PUBLIC,anon,authenticated,service_role;
ALTER TABLE public.academy_class_sessions DISABLE TRIGGER mission_session_bind;
ALTER TABLE public.academy_class_sessions DISABLE TRIGGER zz_mission_session_lifecycle;
ALTER TABLE public.esame_prove DISABLE TRIGGER mission_session_bind;
-- Namespace, policy e audit restano presenti ma inerti; nessun DROP/DELETE,
-- nessun restore PG, nessuna modifica a cron o flag della stanza.
-- APPLY END
