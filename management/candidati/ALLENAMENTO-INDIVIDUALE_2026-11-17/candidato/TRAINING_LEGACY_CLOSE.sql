BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '20s';

DO $cutover$
DECLARE
  target record;
  ability public.character_abilities%ROWTYPE;
  closed_at timestamptz := transaction_timestamp();
  reason constant text := 'Assegnazione amministrativa autorizzata per la chiusura dei due addestramenti già pagati, prima del passaggio alla Scheda giornaliera.';
BEGIN
  FOR target IN
    SELECT * FROM (VALUES
      ('aa98cc7f-4503-4f61-aa09-a6f891ca0186'::uuid, '6bceee99-974f-426b-8d92-38b43b4a4267'::uuid, 'b10f8ee7-43ed-4de1-8662-bfcc08ea3a07'::uuid, 'Lama di vento'),
      ('66f7b362-9b48-48a1-a363-d216211628b6'::uuid, '7478669c-6a30-45a7-be30-7535b1351443'::uuid, '85f5a22d-e333-5d1f-aa0d-bf5b27c1598f'::uuid, 'Risonanza Katon')
    ) named(ability_id, character_id, technique_id, technique_name)
    ORDER BY character_id
  LOOP
    PERFORM 1 FROM public.characters c WHERE c.id = target.character_id AND c.is_test IS FALSE FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Scheda nominata non verificata'; END IF;

    SELECT a.* INTO STRICT ability FROM public.character_abilities a
      WHERE a.id = target.ability_id AND a.character_id = target.character_id
        AND a.technique_id = target.technique_id AND a.state = 'in_addestramento' AND a.sessions_done = 0
      FOR UPDATE;

    IF NOT EXISTS (
      SELECT 1 FROM public.clan_techniques t WHERE t.id = target.technique_id
        AND t.name = target.technique_name AND t.is_active AND t.trainings_required = 1
    ) OR 1 <> (
      SELECT count(*) FROM public.xp_log x WHERE x.character_id = target.character_id
        AND x.created_at = ability.started_at AND x.delta = -50 AND x.motivo = 'tecnica: ' || target.technique_name
    ) OR EXISTS (
      SELECT 1 FROM public.training_sessions s WHERE s.character_id = target.character_id AND s.technique_id = target.technique_id
        AND s.stato IN ('dichiarata', 'sospetta', 'valida', 'legacy_review', 'legacy_approvata')
    ) THEN
      RAISE EXCEPTION 'Il percorso % è cambiato dopo la verifica', target.technique_name;
    END IF;

    -- Una ricevuta amministrativa, separata dalle giornate giocate e senza attribuire una role.
    INSERT INTO public.training_sessions (
      character_id, technique_id, modalita, stato, registrata_at, decisione_at, decisione_motivo,
      sessions_done_dopo, sessions_required_dopo
    ) VALUES (
      target.character_id, target.technique_id, 'legacy', 'legacy_approvata', closed_at, closed_at, reason, 1, 1
    );
    UPDATE public.character_abilities SET state = 'attiva', sessions_done = 1, activated_at = closed_at
      WHERE id = ability.id;
  END LOOP;
END;
$cutover$;

COMMIT;
