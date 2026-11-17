BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '15s';

DO $catalog$
DECLARE
  target_ids uuid[];
  changed integer;
BEGIN
  SELECT array_agg(t.id ORDER BY t.id)
    INTO target_ids
    FROM (
      SELECT ct.id
      FROM public.clan_techniques ct
      WHERE ct.is_active AND (
        (ct.name='Scudo di Sabbia' AND ct.clan='Sabaku'
          AND md5(to_jsonb(ct)::text)='1e4598f0cce68b075ba9c454da015921')
        OR
        (ct.name='Rilascio della Marionetta' AND ct.clan='Marionettisti'
          AND md5(to_jsonb(ct)::text)='79e849e631c1a2e95705f7afa4eed28a')
      )
      ORDER BY ct.id
      FOR UPDATE OF ct
    ) t;

  IF cardinality(coalesce(target_ids,'{}'::uuid[])) <> 2 OR
     NOT EXISTS (SELECT 1 FROM clan_sabaku_private.armor_release_gate WHERE singleton AND public_enabled) OR
     NOT EXISTS (SELECT 1 FROM public.clan_techniques WHERE name='Armatura di Sabbia' AND clan='Sabaku' AND is_active)
  THEN
    RAISE EXCEPTION 'Baseline delle due tecniche o dell’Armatura cambiata';
  END IF;

  IF EXISTS (SELECT 1 FROM public.character_abilities WHERE technique_id=ANY(target_ids)) OR
     EXISTS (SELECT 1 FROM public.training_sessions WHERE technique_id=ANY(target_ids)) OR
     EXISTS (SELECT 1 FROM training_sheet_private.day_sessions_v1 WHERE technique_id=ANY(target_ids)) OR
     EXISTS (SELECT 1 FROM public.training_guidance_policies
       WHERE technique_id=ANY(target_ids) AND enforcement<>'disabled') OR
     EXISTS (
       SELECT 1 FROM public.clan_techniques consumer
       JOIN public.clan_techniques legacy ON legacy.id=ANY(target_ids)
       WHERE consumer.is_active AND
         (lower(consumer.req_tecnica::text)=lower(legacy.name) OR consumer.req_tecnica::text=legacy.id::text)
     )
  THEN
    RAISE EXCEPTION 'Trovata una dipendenza attiva o una progressione da conservare';
  END IF;

  UPDATE public.clan_techniques SET is_active=false
    WHERE id=ANY(target_ids) AND is_active;
  GET DIAGNOSTICS changed=ROW_COUNT;
  IF changed<>2 THEN RAISE EXCEPTION 'Attese esattamente due schede disattivate'; END IF;
END;
$catalog$;

COMMIT;
