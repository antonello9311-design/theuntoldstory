-- Candidato sola lettura: non cambia il recupero pubblico e non accredita risorse.
-- Richiede 01_COLONY_CALCULATION.sql per lo schema privato.
CREATE FUNCTION clan_aburame_private.recovery_window(
 p_character uuid,p_from timestamptz,p_until timestamptz
) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE v_user uuid;v_busy boolean;v_unknown boolean;v_union tstzmultirange;v_seconds numeric:=0;
BEGIN
 IF p_character IS NULL OR p_from IS NULL OR p_until IS NULL
  OR NOT isfinite(p_from) OR NOT isfinite(p_until) OR p_until<p_from THEN
  RAISE EXCEPTION 'clan_recovery_window_invalid' USING ERRCODE='22023'; END IF;
 SELECT user_id INTO v_user FROM public.characters WHERE id=p_character;
 IF NOT FOUND OR v_user IS NULL THEN RAISE EXCEPTION 'clan_recovery_character_missing'; END IF;
 -- Conta il personaggio fisico, non un PNG controllato dallo stesso utente.
 SELECT EXISTS(
  SELECT 1 FROM public.combat_participants p
   JOIN public.combat_sessions s ON s.id=p.session_id
   JOIN public.locations l ON l.id=s.location_id
   WHERE p.character_id=p_character AND p.user_id=v_user AND p.ruolo='combattente'
    AND s.state='aperto' AND NOT p.fuori AND NOT coalesce(l.is_test,false)
  UNION ALL
  SELECT 1 FROM public.combat_v2_actors a
   JOIN public.combat_v2_sessions s ON s.id=a.session_id
   JOIN public.locations l ON l.id=s.location_id
   WHERE a.character_id=p_character AND a.actor_kind='pg' AND a.state='attivo'
    AND s.state IN ('in_corso','sospeso','risolto') AND s.closed_at IS NULL
    AND NOT coalesce(l.is_test,false)
    AND NOT EXISTS(SELECT 1 FROM public.master_v2_participants m
      WHERE m.session_id=s.master_session_id AND m.character_id=p_character AND m.left_at<=p_until)
 ) INTO v_busy;
 -- I vecchi attori ordinari non hanno un left_at: la loro uscita individuale non si ricostruisce dalla prosa.
 SELECT EXISTS(
  SELECT 1 FROM public.combat_v2_actors a
   JOIN public.combat_v2_sessions s ON s.id=a.session_id
   JOIN public.locations l ON l.id=s.location_id
   WHERE a.character_id=p_character AND a.actor_kind='pg' AND NOT coalesce(l.is_test,false)
    AND a.created_at<p_until AND coalesce(s.closed_at,p_until)>p_from
    AND (s.state='preparazione' OR
      (a.state<>'attivo' AND NOT EXISTS(
        SELECT 1 FROM public.master_v2_participants m
         WHERE m.session_id=s.master_session_id AND m.character_id=p_character AND m.left_at IS NOT NULL)))
  UNION ALL
  SELECT 1 FROM public.combat_participants p
   JOIN public.combat_sessions s ON s.id=p.session_id
   JOIN public.locations l ON l.id=s.location_id
   WHERE p.character_id=p_character AND p.user_id=v_user AND p.ruolo='combattente'
    AND p.fuori AND NOT coalesce(l.is_test,false)
    AND p.joined_at<p_until AND coalesce(s.closed_at,p_until)>p_from
 ) INTO v_unknown;
 WITH intervals AS (
  SELECT greatest(p_from,p.joined_at) start_at,least(p_until,s.closed_at) end_at
   FROM public.combat_participants p JOIN public.combat_sessions s ON s.id=p.session_id
   JOIN public.locations l ON l.id=s.location_id
   WHERE p.character_id=p_character AND p.user_id=v_user AND p.ruolo='combattente'
    AND s.state='chiuso' AND s.closed_at IS NOT NULL AND NOT p.fuori AND NOT coalesce(l.is_test,false)
  UNION ALL
  SELECT greatest(p_from,a.created_at,s.created_at,coalesce(m.joined_at,a.created_at)),
    least(p_until,coalesce(m.left_at,s.closed_at),s.closed_at)
   FROM public.combat_v2_actors a JOIN public.combat_v2_sessions s ON s.id=a.session_id
   JOIN public.locations l ON l.id=s.location_id
   LEFT JOIN public.master_v2_participants m ON m.session_id=s.master_session_id AND m.character_id=p_character
   WHERE a.character_id=p_character AND a.actor_kind='pg' AND NOT coalesce(l.is_test,false)
    AND s.state<>'preparazione' AND (s.closed_at IS NOT NULL OR m.left_at IS NOT NULL)
    AND (a.state='attivo' OR m.left_at IS NOT NULL)
 ), clipped AS (
  SELECT tstzrange(start_at,end_at,'[)') period FROM intervals WHERE end_at>start_at
 ) SELECT range_agg(period) INTO v_union FROM clipped;
 IF v_union IS NOT NULL THEN
  SELECT coalesce(sum(extract(epoch FROM upper(r)-lower(r))),0) INTO v_seconds FROM unnest(v_union) r;
 END IF;
 RETURN jsonb_build_object('contract','clan-recovery-window/1','character_id',p_character,
  'from',p_from AT TIME ZONE 'UTC','until',p_until AT TIME ZONE 'UTC',
  'currently_busy',v_busy,'history_complete',NOT v_unknown,
  'eligible',NOT v_busy AND NOT v_unknown,'combat_seconds',v_seconds,
  'rest_seconds',CASE WHEN v_busy OR v_unknown THEN NULL
    ELSE greatest(0,extract(epoch FROM p_until-p_from)-v_seconds) END);
END $f$;
REVOKE ALL ON FUNCTION clan_aburame_private.recovery_window(uuid,timestamptz,timestamptz)
 FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_aburame_private.recovery_window(uuid,timestamptz,timestamptz) TO postgres;
