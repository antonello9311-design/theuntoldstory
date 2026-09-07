-- GO PM nominativo 07/09/2026, dopo postflight DB + Edge + LAND verdi.
-- Unico executor DB-CORE. Nessuna apertura, chiamata provider o flag stanza.
-- Policy già immutabilmente vincolata a Tamako/Konoha dal release verificato.
BEGIN;
DO $enable_sample$
DECLARE gate_row mission_exam_private.release_gate%ROWTYPE;
BEGIN
  SELECT * INTO STRICT gate_row FROM mission_exam_private.release_gate
    WHERE singleton FOR UPDATE;
  IF gate_row.enabled OR gate_row.provider_call_cap IS NOT NULL THEN
    RAISE EXCEPTION 'mission_session_enable_requires_inert_gate'; END IF;
  IF EXISTS(SELECT 1 FROM mission_exam_private.protected_sessions WHERE state<>'closed') THEN
    RAISE EXCEPTION 'mission_session_enable_existing_trial'; END IF;
  UPDATE mission_exam_private.release_gate SET enabled=true,provider_call_cap=20
    WHERE singleton;
END $enable_sample$;
COMMIT;
