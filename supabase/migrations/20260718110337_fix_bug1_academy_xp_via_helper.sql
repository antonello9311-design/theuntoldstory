-- BUG-1: l'Accademia accredita l'XP con _assegna_xp (saldo + carriera + xp_log),
-- invece dell'update diretto che toccava solo exp. Rank/punti dell'esame invariati.

CREATE OR REPLACE FUNCTION public.academy_complete(p_lesson uuid)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare me uuid := auth.uid(); v_char uuid; v_rank text; v_has boolean; l record;
        last_at timestamptz; total_reg int; done_reg int; granted text[];
begin
  if me is null then raise exception 'Non autenticato'; end if;
  select id, rank, true into v_char, v_rank, v_has from public.characters where user_id=me;
  if not coalesce(v_has,false) then raise exception 'Devi prima creare il personaggio'; end if;
  select * into l from public.academy_lessons where id=p_lesson and is_active;
  if l.id is null then raise exception 'Lezione non trovata'; end if;
  if exists(select 1 from public.lesson_progress where user_id=me and lesson_id=l.id) then
    raise exception 'Hai gia completato questa lezione';
  end if;

  if l.is_exam then
    select count(*) filter (where not al.is_exam),
           count(*) filter (where not al.is_exam and pp.lesson_id is not null)
      into total_reg, done_reg
      from public.academy_lessons al
      left join public.lesson_progress pp on pp.lesson_id=al.id and pp.user_id=me
      where al.is_active;
    if not (total_reg>0 and done_reg=total_reg) then raise exception 'Devi completare tutte le lezioni prima dell esame'; end if;
    if coalesce(v_rank,'Deshi') <> 'Deshi' then raise exception 'Hai gia superato l esame'; end if;
  else
    select max(p.completed_at) into last_at
      from public.lesson_progress p join public.academy_lessons al on al.id=p.lesson_id
      where p.user_id=me and not al.is_exam;
    if last_at is not null and last_at > now() - interval '20 hours' then
      raise exception 'Puoi seguire una sola lezione al giorno. Torna piu tardi.';
    end if;
  end if;

  insert into public.lesson_progress(user_id, lesson_id) values (me, l.id);

  -- sblocca abilità/tecniche della lezione
  insert into public.character_jutsu(user_id, jutsu_id, source)
    select me, g.jutsu_id, 'academy' from public.lesson_grants g where g.lesson_id=l.id
    on conflict (user_id, jutsu_id) do nothing;
  select array_agg(j.name_it order by j.sort) into granted
    from public.lesson_grants g join public.jutsu j on j.id=g.jutsu_id where g.lesson_id=l.id;

  -- XP tramite helper: aggiorna saldo E carriera e scrive xp_log
  perform public._assegna_xp(v_char, l.xp_reward,
    case when l.is_exam then 'accademia: esame Genin' else 'accademia: '||coalesce(l.title,'lezione') end);
  if l.is_exam then
    perform set_config('app.allow_academy','1',true);
    update public.characters set rank='Genin', unspent_points = unspent_points + 15 where id=v_char;
  end if;

  return json_build_object('ok',true,'lesson',l.title,'xp',l.xp_reward,
    'granted', coalesce(granted, array[]::text[]), 'exam', l.is_exam, 'promoted', l.is_exam);
end $function$;

CREATE OR REPLACE FUNCTION public._academy_grant(p_user uuid, p_lesson uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare l record; v_char uuid; v_rank text; v_has boolean; last_at timestamptz; total_reg int; done_reg int; prereq_missing int;
begin
  select id, rank, true into v_char, v_rank, v_has from public.characters where user_id=p_user;
  if not coalesce(v_has,false) then return 'nochar'; end if;
  select * into l from public.academy_lessons where id=p_lesson and is_active;
  if l.id is null then return 'nolesson'; end if;
  if exists(select 1 from public.lesson_progress where user_id=p_user and lesson_id=l.id) then return 'done'; end if;
  if l.is_exam then
    select count(*) filter (where not al.is_exam),
           count(*) filter (where not al.is_exam and pp.lesson_id is not null)
      into total_reg, done_reg
      from public.academy_lessons al
      left join public.lesson_progress pp on pp.lesson_id=al.id and pp.user_id=p_user
      where al.is_active;
    if not (total_reg>0 and done_reg=total_reg) then return 'prereq'; end if;
    if coalesce(v_rank,'Deshi') <> 'Deshi' then return 'done'; end if;
  else
    select count(*) into prereq_missing
      from public.academy_lessons al
      where al.is_active and not al.is_exam and al.ordinal < l.ordinal
        and not exists(select 1 from public.lesson_progress pp where pp.user_id=p_user and pp.lesson_id=al.id);
    if prereq_missing > 0 then return 'prereq'; end if;
    select max(p.completed_at) into last_at
      from public.lesson_progress p join public.academy_lessons al on al.id=p.lesson_id
      where p.user_id=p_user and not al.is_exam;
    if last_at is not null and last_at > now() - interval '20 hours' then return 'cooldown'; end if;
  end if;
  insert into public.lesson_progress(user_id, lesson_id) values (p_user, l.id);
  insert into public.character_jutsu(user_id, jutsu_id, source)
    select p_user, g.jutsu_id, 'academy' from public.lesson_grants g where g.lesson_id=l.id
    on conflict (user_id, jutsu_id) do nothing;
  -- XP tramite helper: saldo + carriera + registro
  perform public._assegna_xp(v_char, l.xp_reward,
    case when l.is_exam then 'accademia: esame Genin' else 'accademia: '||coalesce(l.title,'lezione') end);
  if l.is_exam then
    perform set_config('app.allow_academy','1',true);
    update public.characters set rank='Genin', unspent_points = unspent_points + 15 where user_id=p_user;
  end if;
  return 'ok';
end $function$;