-- Campo "prestavolto" (riferimento di volto) per i PNG: definito sul modello, copiato nell'istanza all'evocazione.
alter table public.png_templates add column if not exists prestavolto text;
alter table public.png_instances add column if not exists prestavolto text;

create or replace function public.png_evoca(p_template uuid, p_location uuid, p_nome text default null)
 returns uuid language plpgsql security definer set search_path to 'public' as $function$
declare t public.png_templates%rowtype; v_id uuid; v_vmax int; v_cmax int;
begin
  if not public.is_staff() then raise exception 'solo lo staff evoca i PNG'; end if;
  select * into t from public.png_templates where id = p_template and is_active;
  if t.id is null then raise exception 'modello inesistente'; end if;
  if not exists (select 1 from public.locations where id=p_location and is_active) then raise exception 'luogo non valido'; end if;
  v_vmax := coalesce(t.vita_max,  public.calc_vita_max(t.resistenza, public._png_rank_equiv(t.grado)));
  v_cmax := coalesce(t.chakra_max, public.calc_chakra_max(t.ninjutsu, t.mente, public._png_rank_equiv(t.grado)));
  insert into public.png_instances(template_id, location_id, nome, avatar_url, prestavolto, grado,
    taijutsu, ninjutsu, genjutsu, forza, velocita, mente, resistenza, fuuinjutsu, kekkei_genkai,
    vita, vita_max, chakra, chakra_max, abilita, note)
  values (t.id, p_location, coalesce(nullif(btrim(coalesce(p_nome,'')),''), t.nome), t.avatar_url, t.prestavolto, t.grado,
    t.taijutsu, t.ninjutsu, t.genjutsu, t.forza, t.velocita, t.mente, t.resistenza, t.fuuinjutsu, t.kekkei_genkai,
    v_vmax, v_vmax, v_cmax, v_cmax, t.abilita, t.note)
  returning id into v_id;
  return v_id;
end; $function$;