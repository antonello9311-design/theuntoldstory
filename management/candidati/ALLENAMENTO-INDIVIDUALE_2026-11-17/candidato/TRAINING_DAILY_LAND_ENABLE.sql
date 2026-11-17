BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '30s';

ALTER TABLE training_sheet_private.release_v1
  ADD COLUMN public_enabled_at timestamptz,
  ADD CONSTRAINT training_sheet_release_date_v1 CHECK (NOT public_enabled OR public_enabled_at IS NOT NULL);

DO $compose$
DECLARE
  body text;
  start_rpc regprocedure := 'public.training_start(uuid,uuid)'::regprocedure;
  declare_rpc regprocedure := 'public.training_role_dichiara(uuid,uuid,text,uuid,uuid)'::regprocedure;
  state_rpc regprocedure := 'public.training_sheet_state_v1(uuid)'::regprocedure;
  old_start text := $old$  if training_sheet_private.scope_v1(c) is not null and not training_sheet_private.is_special_v1(t) then
    return jsonb_build_object('ok',false,'reasons',jsonb_build_array('Avvia l’allenamento giornaliero in Scheda.'));
  end if;
$old$;
  declaration_anchor text := E'  insert into public.training_sessions(character_id,technique_id,role_session_id,combat_session_id,\n';
  state_anchor text := '    ''staff_case'',w.case_id,''staff_xp'',w.balance,''staff_clock'',';
BEGIN
  IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=start_rpc) IS DISTINCT FROM '111aee1398e2c55b476fb653304358b8'
    OR (SELECT md5(prosrc) FROM pg_proc WHERE oid=declare_rpc) IS DISTINCT FROM '32c4bd9f7c7164fb95781856ded9e8ec'
    OR (SELECT md5(prosrc) FROM pg_proc WHERE oid=state_rpc) IS DISTINCT FROM '40b7dd14be0b56b4af990a7710a63f96'
    OR NOT EXISTS (SELECT 1 FROM training_sheet_private.release_v1 WHERE staff_enabled AND NOT public_enabled)
  THEN RAISE EXCEPTION 'Baseline rilascio Allenamento cambiata'; END IF;

  body:=pg_get_functiondef(start_rpc);
  IF (length(body)-length(replace(body,old_start,'')))/length(old_start)<>1 THEN
    RAISE EXCEPTION 'Ancora avvio legacy Allenamento cambiata';
  END IF;
  body:=replace(body,old_start,'');
  body:=replace(body,'0,now(),null,null,null)','0,clock_timestamp(),null,null,null)');
  body:=replace(body,'started_at=now(),activated_at=null','started_at=clock_timestamp(),activated_at=null');
  EXECUTE body;

  body:=pg_get_functiondef(declare_rpc);
  IF (length(body)-length(replace(body,declaration_anchor,'')))/length(declaration_anchor)<>1 THEN
    RAISE EXCEPTION 'Ancora dichiarazione Allenamento cambiata';
  END IF;
  EXECUTE replace(body,declaration_anchor,$new$  if p_modalita='individuale' and p_combat_session is null
     and exists(select 1 from training_sheet_private.release_v1 g
       where g.singleton and g.public_enabled and ca.started_at>=g.public_enabled_at)
     and exists(select 1 from public.clan_techniques t
       where t.id=p_technique and not training_sheet_private.is_special_v1(t))
  then
    raise exception 'Per l’allenamento individuale apri Scheda → Jutsu e abilità';
  end if;
$new$||declaration_anchor);

  body:=pg_get_functiondef(state_rpc);
  IF (length(body)-length(replace(body,state_anchor,'')))/length(state_anchor)<>1 THEN
    RAISE EXCEPTION 'Ancora stato Allenamento cambiata';
  END IF;
  EXECUTE replace(body,state_anchor,$new$    'role_active',NOT v_simulated AND EXISTS (
      SELECT 1 FROM public.character_abilities a WHERE a.character_id=c.id AND a.state='in_addestramento'
        AND NOT EXISTS (SELECT 1 FROM training_sheet_private.day_sessions_v1 d
          WHERE d.ability_id=a.id AND d.completed_at IS NULL)
    ),
$new$||state_anchor);
END;
$compose$;

DO $qualify$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM training_sheet_private.staff_xp_v1 w
    JOIN training_sheet_private.day_sessions_v1 d ON d.staff_case=w.case_id
    JOIN public.combat_v2_sessions c ON c.id=w.combat_session_id AND c.state='chiuso'
    JOIN public.combat_v2_actors a ON a.session_id=c.id AND a.character_id=w.character_id
    JOIN combat_v2_taijutsu_internal.taijutsu_staff_receipts r ON r.actor_id=a.id AND r.technique_id=d.technique_id
    WHERE w.closed_at IS NOT NULL AND w.balance=20 AND d.xp_spent=50 AND d.completed_at>=d.ends_at
      AND r.receipt->>'training_receipt'=d.id::text AND r.receipt->>'training_staff_case'=w.case_id::text
      AND NOT public.combat_v2_values_written(c.id)
  ) THEN RAISE EXCEPTION 'Collaudo Staff Allenamento non attestato'; END IF;
END;
$qualify$;

UPDATE training_sheet_private.release_v1
  SET public_enabled=true, public_enabled_at=coalesce(public_enabled_at,clock_timestamp())
  WHERE singleton AND staff_enabled AND NOT public_enabled;

COMMIT;
