-- KO: un personaggio a vita<=0 e' "fuori combattimento": non puo' attaccare finche' non recupera,
-- e non puo' essere ulteriormente colpito. (Staff/Regia non soggetti.)

CREATE OR REPLACE FUNCTION public.pg_attacca_png(p_location uuid, p_instance uuid, p_kind text DEFAULT 'fisico'::text, p_name text DEFAULT ''::text, p_base integer DEFAULT 0, p_mod integer DEFAULT 0, p_defense text DEFAULT 'schivata'::text, p_quality integer DEFAULT 0, p_technique uuid DEFAULT NULL::uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare a public.characters%rowtype; g public.png_instances%rowtype; v_staff boolean;
  q int; mod int; base int; atk_sum int; def_sum int; off int; red_div int;
  atk_roll int; def_roll int; atk_tot int; def_tot int;
  margin int; mb int; dmg int; hit boolean; desc_txt text; outcome text; body text; tname text;
  v_cost int; v_state text; v_dmgbase int; v_ck int := 0; v_kind text; v_def text;
begin
  if auth.uid() is null then raise exception 'non autenticato'; end if;
  select * into a from public.characters where user_id=auth.uid() limit 1;
  if a.id is null then raise exception 'nessun personaggio associato'; end if;
  if coalesce(a.vita,0) <= 0 then raise exception 'Sei fuori combattimento: recupera prima di poter attaccare'; end if;
  select * into g from public.png_instances where id=p_instance and location_id=p_location for update;
  if g.id is null then raise exception 'PNG non presente in questa scena'; end if;
  if g.is_down then raise exception '% è già fuori combattimento', g.nome; end if;
  v_staff := public.is_staff();
  q := case when v_staff then greatest(0, least(6, coalesce(p_quality,0))) else 0 end;
  mod := case when v_staff then greatest(-30, least(30, coalesce(p_mod,0))) else 0 end;
  base := case when v_staff then greatest(0, least(120, coalesce(p_base,0))) else 10 end;
  tname := coalesce(nullif(btrim(p_name),''),'attacco');
  v_kind := case when p_kind='ninjutsu' then 'ninjutsu' else 'fisico' end;
  v_def := case when p_defense='contrasto' then 'contrasto' else 'schivata' end;
  if p_technique is not null then
    select t.danno_base, t.chakra_cost, t.name, ca.state into v_dmgbase, v_cost, tname, v_state
    from public.character_abilities ca join public.clan_techniques t on t.id = ca.technique_id
    where ca.character_id = a.id and ca.technique_id = p_technique;
    if tname is null or v_state is distinct from 'attiva' then raise exception 'tecnica non disponibile o non ancora attiva'; end if;
    base := coalesce(v_dmgbase,0); v_cost := coalesce(v_cost,0);
    if v_cost>0 and coalesce(a.chakra_max,0)>0 then
      if coalesce(a.chakra,0) < v_cost then raise exception 'Chakra insufficiente: servono % (ne hai %)', v_cost, coalesce(a.chakra,0); end if;
      perform set_config('app.allow_chakra_delta','1', true);
      update public.characters set chakra = chakra - v_cost where id = a.id; v_ck := v_cost;
    end if;
  end if;
  if v_kind='ninjutsu' then atk_sum:=a.mente+a.ninjutsu; off:=a.mente; red_div:=40;
  else atk_sum:=a.forza+a.taijutsu; off:=greatest(a.forza,a.taijutsu); red_div:=20; end if;
  if v_def='contrasto' then def_sum:=g.velocita+g.mente; else def_sum:=g.velocita+g.taijutsu; end if;
  atk_roll:=floor(random()*20)+1; def_roll:=floor(random()*20)+1;
  atk_tot:=(atk_sum/10)+atk_roll+mod+q; def_tot:=(def_sum/10)+def_roll;
  margin:=atk_tot-def_tot; hit:=margin>=0;
  if not hit then
    dmg:=0;
    outcome:=a.name||' usa «'||tname||'» contro '||g.nome||': '||(case when v_def='contrasto' then 'il PNG contrasta e annulla il colpo' else 'il PNG schiva' end)||' — nessun danno.';
  else
    mb:=case when margin<5 then 0 when margin<10 then 3 when margin<15 then 6 else 10 end;
    dmg:=greatest(1, base+(off/4)+mb-(g.resistenza/red_div));
    update public.png_instances set vita=greatest(0, vita-dmg), is_down=(vita-dmg)<=0 where id=g.id
      returning vita, is_down into g.vita, g.is_down;
    desc_txt:=case when margin<5 then 'lo coglie di striscio' when margin<15 then 'lo colpisce in pieno' else 'lo travolge' end;
    outcome:=a.name||' usa «'||tname||'» contro '||g.nome||': '||desc_txt||' — '||g.nome||' subisce '||dmg||' danni. (PV di '||g.nome||': '||g.vita||'/'||g.vita_max||')';
    if g.is_down then outcome:=outcome||'  〈'||g.nome||' è fuori combattimento!〉'; end if;
  end if;
  if v_ck>0 then outcome:=outcome||'  〈−'||v_ck||' chakra〉'; end if;
  body:=json_build_object('a',json_build_object('n',a.name,'u',coalesce(a.avatar_url,''),'c',a.id),
    'd',json_build_object('n',g.nome,'u',coalesce(g.avatar_url,''),'c',null),
    'o',outcome,'hit',hit,'dmg',dmg,'margin',margin,'kind',v_kind,'def',v_def,'q',q,'ck',v_ck,'png',true,
    'apv',json_build_array(a.vita, a.vita_max),'dpv',json_build_array(g.vita, g.vita_max),'ko',g.is_down)::text;
  insert into public.messages(location_id,character_id,author_name,kind,sender_user,recipient_user,recipient_name,body)
    values(p_location,a.id,a.name,'combat',auth.uid(),null,g.nome,body);
  insert into public.presence(user_id,last_seen,location_id) values(auth.uid(),now(),p_location)
    on conflict (user_id) do update set last_seen=now(),location_id=excluded.location_id;
  return outcome;
end; $function$;

CREATE OR REPLACE FUNCTION public.post_combat(p_location uuid, p_defender_user uuid, p_kind text DEFAULT 'fisico'::text, p_name text DEFAULT ''::text, p_base integer DEFAULT 0, p_mod integer DEFAULT 0, p_defense text DEFAULT 'schivata'::text, p_quality integer DEFAULT 0, p_technique uuid DEFAULT NULL::uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare a public.characters%rowtype; d public.characters%rowtype; v_staff boolean;
  q int; mod int; base int; atk_sum int; def_sum int; off int; red_div int;
  atk_roll int; def_roll int; atk_tot int; def_tot int;
  margin int; mb int; dmg int; hit boolean; desc_txt text; outcome text; body text; tname text;
  v_cost int; v_state text; v_dmgbase int; v_ck int := 0;
begin
  if auth.uid() is null then raise exception 'non autenticato'; end if;
  if not exists (select 1 from public.locations l where l.id=p_location and l.is_active) then raise exception 'luogo non valido'; end if;
  select * into a from public.characters where user_id=auth.uid() limit 1;
  if a.id is null then raise exception 'nessun personaggio associato'; end if;
  if coalesce(a.vita,0) <= 0 then raise exception 'Sei fuori combattimento: recupera prima di poter attaccare'; end if;
  select * into d from public.characters where user_id=p_defender_user limit 1;
  if d.id is null then raise exception 'bersaglio non valido'; end if;
  if d.id = a.id then raise exception 'non puoi bersagliare te stesso'; end if;
  v_staff := public.is_staff();
  if not v_staff and not exists (select 1 from public.presence pr where pr.user_id = d.user_id and pr.location_id = p_location) then
    raise exception 'Il bersaglio non è presente in questa scena';
  end if;
  if coalesce(d.vita,0) <= 0 then raise exception '% è già fuori combattimento', d.name; end if;
  q := case when v_staff then greatest(0, least(6, coalesce(p_quality,0))) else 0 end;
  mod := case when v_staff then greatest(-30, least(30, coalesce(p_mod,0))) else 0 end;
  base := case when v_staff then greatest(0, least(120, coalesce(p_base,0))) else 10 end;
  tname := coalesce(nullif(btrim(p_name),''),'attacco');
  if p_technique is not null then
    select t.danno_base, t.chakra_cost, t.name, ca.state into v_dmgbase, v_cost, tname, v_state
    from public.character_abilities ca join public.clan_techniques t on t.id = ca.technique_id
    where ca.character_id = a.id and ca.technique_id = p_technique;
    if tname is null or v_state is distinct from 'attiva' then raise exception 'tecnica non disponibile o non ancora attiva'; end if;
    base := coalesce(v_dmgbase,0); v_cost := coalesce(v_cost,0);
    if v_cost>0 and coalesce(a.chakra_max,0)>0 then
      if coalesce(a.chakra,0) < v_cost then raise exception 'Chakra insufficiente: servono % (ne hai %)', v_cost, coalesce(a.chakra,0); end if;
      perform set_config('app.allow_chakra_delta','1', true);
      update public.characters set chakra = chakra - v_cost where id = a.id; v_ck := v_cost;
    end if;
  end if;
  if p_kind='ninjutsu' then atk_sum:=a.mente+a.ninjutsu; off:=a.mente; red_div:=40;
  else p_kind:='fisico'; atk_sum:=a.forza+a.taijutsu; off:=greatest(a.forza,a.taijutsu); red_div:=20; end if;
  if p_defense='contrasto' then def_sum:=d.velocita+d.mente; else p_defense:='schivata'; def_sum:=d.velocita+d.taijutsu; end if;
  atk_roll:=floor(random()*20)+1; def_roll:=floor(random()*20)+1;
  atk_tot:=(atk_sum/10)+atk_roll+mod+q; def_tot:=(def_sum/10)+def_roll;
  margin:=atk_tot-def_tot; hit:=margin>=0;
  if not hit then
    dmg:=0;
    outcome:=a.name||' usa «'||tname||'»: '||d.name||' '||(case when p_defense='contrasto' then 'contrasta e annulla il colpo' else 'schiva' end)||' — nessun danno.';
  else
    mb:=case when margin<5 then 0 when margin<10 then 3 when margin<15 then 6 else 10 end;
    dmg:=greatest(1, base+(off/4)+mb-(d.resistenza/red_div));
    perform set_config('app.allow_vita_delta','1', true);
    update public.characters set vita=greatest(0, coalesce(vita,vita_max,0)-dmg) where id=d.id returning vita into d.vita;
    desc_txt:=case when margin<5 then 'è colpito di striscio' when margin<15 then 'è colpito in pieno' else 'subisce un colpo devastante' end;
    outcome:=a.name||' usa «'||tname||'»: '||d.name||' '||(case when p_defense='contrasto' then 'prova a contrastare ma ' else 'prova a schivare ma ' end)||desc_txt||' — subisce '||dmg||' danni.'||' (PV di '||d.name||': '||d.vita||coalesce('/'||d.vita_max,'')||')'||(case when coalesce(d.vita,0)<=0 then '  〈'||d.name||' è fuori combattimento!〉' else '' end);
  end if;
  if v_ck>0 then outcome:=outcome||'  〈−'||v_ck||' chakra〉'; end if;
  body:=json_build_object('a',json_build_object('n',a.name,'u',coalesce(a.avatar_url,''),'c',a.id),
    'd',json_build_object('n',d.name,'u',coalesce(d.avatar_url,''),'c',d.id),
    'o',outcome,'hit',hit,'dmg',dmg,'margin',margin,'kind',p_kind,'def',p_defense,'q',q,'dv',d.vita,'dvmax',d.vita_max,'ck',v_ck,'ko',(coalesce(d.vita,0)<=0))::text;
  insert into public.messages(location_id,character_id,author_name,kind,sender_user,recipient_user,recipient_name,body)
    values(p_location,a.id,a.name,'combat',auth.uid(),d.user_id,d.name,body);
  insert into public.presence(user_id,last_seen,location_id) values(auth.uid(),now(),p_location)
    on conflict (user_id) do update set last_seen=now(),location_id=excluded.location_id;
  return outcome;
end; $function$;