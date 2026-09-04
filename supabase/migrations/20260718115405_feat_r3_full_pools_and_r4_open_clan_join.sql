-- R3: alla prima allocazione (Deshi senza carriera) il PG parte con PV/Chakra pieni.
-- R4: il cambio clan e' permesso solo sotto il flag app.allow_clan_join (impostato solo da clan_join_open),
--     che consente a un personaggio senza clan di entrare da solo in un clan APERTO (is_gated=false) del proprio villaggio.

CREATE OR REPLACE FUNCTION public.characters_guard()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare inc int; academy boolean; v_cap int;
begin
  if public.is_staff() then
    new.vita_max := public.calc_vita_max(new.resistenza, new.rank);
    new.chakra_max := public.calc_chakra_max(new.ninjutsu, new.mente, new.rank);
    new.vita := least(coalesce(new.vita, new.vita_max), new.vita_max);
    new.chakra := least(coalesce(new.chakra, new.chakra_max), new.chakra_max);
    new.updated_at := now(); return new;
  end if;
  academy := coalesce(current_setting('app.allow_academy', true),'') = '1';
  new.name := old.name; new.epithet := old.epithet;
  new.village := old.village; new.age := old.age; new.sex := old.sex;
  if old.element is not null then new.element := old.element; end if;
  if current_setting('app.allow_vita_delta', true) is distinct from '1' then new.vita := old.vita; end if;
  if current_setting('app.allow_chakra_delta', true) is distinct from '1' then new.chakra := old.chakra; end if;
  new.user_id := old.user_id; new.created_at := old.created_at;
  new.corporation := old.corporation;
  if current_setting('app.allow_clan_join', true) is distinct from '1' then
    new.clan := old.clan; new.clan_role := old.clan_role;
  end if;
  if current_setting('app.allow_money_delta', true) is distinct from '1' then new.money := old.money; end if;
  if current_setting('app.allow_exp_delta', true) is distinct from '1' then
    new.xp_lifetime := old.xp_lifetime; new.last_daily_xp := old.last_daily_xp; new.slot_extra := old.slot_extra;
  end if;
  if current_setting('app.allow_align_delta', true) is distinct from '1' then
    new.lealta := old.lealta; new.via := old.via; new.fama := old.fama;
  end if;
  if not academy then
    new.rank := old.rank;
    if current_setting('app.allow_exp_delta', true) is distinct from '1' then new.exp := old.exp; end if;
    if new.unspent_points is null then new.unspent_points := old.unspent_points; end if;
    if new.unspent_points > old.unspent_points then raise exception 'Non puoi aumentare i punti da assegnare'; end if;
  else
    if new.unspent_points is null then new.unspent_points := old.unspent_points; end if;
  end if;
  if new.taijutsu<old.taijutsu or new.ninjutsu<old.ninjutsu or new.genjutsu<old.genjutsu
     or new.forza<old.forza or new.velocita<old.velocita or new.mente<old.mente
     or new.resistenza<old.resistenza or new.fuuinjutsu<old.fuuinjutsu or new.kekkei_genkai<old.kekkei_genkai then
    raise exception 'Le statistiche non possono diminuire'; end if;
  if (new.taijutsu-old.taijutsu)%5<>0 or (new.ninjutsu-old.ninjutsu)%5<>0 or (new.genjutsu-old.genjutsu)%5<>0
     or (new.forza-old.forza)%5<>0 or (new.velocita-old.velocita)%5<>0 or (new.mente-old.mente)%5<>0
     or (new.resistenza-old.resistenza)%5<>0 or (new.fuuinjutsu-old.fuuinjutsu)%5<>0 or (new.kekkei_genkai-old.kekkei_genkai)%5<>0 then
    raise exception 'Le statistiche si assegnano a gruppi di 5'; end if;
  v_cap := case coalesce(new.rank,'Deshi')
    when 'Deshi' then 30 when 'Genin' then 45 when 'Chunin' then 60
    when 'Jonin' then 75 when 'Jonin Speciale' then 85 else 100 end;
  if (new.taijutsu>old.taijutsu and new.taijutsu>v_cap) or (new.ninjutsu>old.ninjutsu and new.ninjutsu>v_cap)
     or (new.genjutsu>old.genjutsu and new.genjutsu>v_cap) or (new.forza>old.forza and new.forza>v_cap)
     or (new.velocita>old.velocita and new.velocita>v_cap) or (new.mente>old.mente and new.mente>v_cap)
     or (new.resistenza>old.resistenza and new.resistenza>v_cap) or (new.fuuinjutsu>old.fuuinjutsu and new.fuuinjutsu>v_cap)
     or (new.kekkei_genkai>old.kekkei_genkai and new.kekkei_genkai>v_cap) then
    raise exception 'Tetto del grado superato: nessuna statistica può andare oltre % a questo rango', v_cap; end if;
  if new.kekkei_genkai>old.kekkei_genkai and (coalesce(old.clan,'Nessuno') in ('','Nessuno') or coalesce(old.rank,'Deshi')='Deshi') then
    raise exception 'L''abilita'' innata si sblocca da Genin e richiede un clan'; end if;
  inc := (new.taijutsu-old.taijutsu)+(new.ninjutsu-old.ninjutsu)+(new.genjutsu-old.genjutsu)
        +(new.forza-old.forza)+(new.velocita-old.velocita)+(new.mente-old.mente)
        +(new.resistenza-old.resistenza)+(new.fuuinjutsu-old.fuuinjutsu)+(new.kekkei_genkai-old.kekkei_genkai);
  if new.unspent_points < 0 then raise exception 'Punti non validi'; end if;
  if not academy then
    if inc <> (old.unspent_points - new.unspent_points) then raise exception 'Incoerenza tra punti e statistiche'; end if;
  else
    if inc <> 0 then raise exception 'In accademia le statistiche non cambiano'; end if;
  end if;
  new.vita_max := public.calc_vita_max(new.resistenza, new.rank);
  new.chakra_max := public.calc_chakra_max(new.ninjutsu, new.mente, new.rank);
  new.vita := least(coalesce(new.vita, new.vita_max), new.vita_max);
  new.chakra := least(coalesce(new.chakra, new.chakra_max), new.chakra_max);
  if not academy and coalesce(old.rank,'Deshi')='Deshi' and coalesce(old.xp_lifetime,0)=0 and inc>0 then
    new.vita := new.vita_max; new.chakra := new.chakra_max;
  end if;
  new.updated_at := now(); return new;
end; $function$;

CREATE OR REPLACE FUNCTION public.clan_join_open(p_clan text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare c public.characters%rowtype; cl public.clans%rowtype;
begin
  if auth.uid() is null then raise exception 'Non autenticato'; end if;
  select * into c from public.characters where user_id = auth.uid() limit 1;
  if c.id is null then raise exception 'Nessun personaggio'; end if;
  if coalesce(c.clan,'Nessuno') not in ('','Nessuno') then raise exception 'Hai già un clan'; end if;
  select * into cl from public.clans where name = p_clan and is_active limit 1;
  if cl.name is null then raise exception 'Clan inesistente'; end if;
  if cl.is_gated then raise exception 'Questo clan è ad accesso riservato: lo assegna lo staff'; end if;
  if cl.village is not null and (c.village is distinct from cl.village) then
    raise exception 'Puoi entrare solo in un clan del tuo villaggio (%)', coalesce(c.village,'—');
  end if;
  perform set_config('app.allow_clan_join','1', true);
  update public.characters set clan = cl.name, clan_role = coalesce(nullif(clan_role,''),'Membro') where id = c.id;
  return json_build_object('ok', true, 'clan', cl.name);
end; $function$;

revoke all on function public.clan_join_open(text) from public, anon;
grant execute on function public.clan_join_open(text) to authenticated;