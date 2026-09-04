-- BUG-3/S2: training_eligibility ora richiede proprietario-o-staff (niente snooping altrui).
-- S3: unequip_row valida p_qty >= 1 (una quantità negativa gonfiava l'equipaggiato).

CREATE OR REPLACE FUNCTION public.training_eligibility(p_technique uuid, p_character uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare c public.characters; t public.clan_techniques; reasons text[] := '{}'; v_stat int; v_state text; v_done int; v_req int; v_prev boolean; v_us int; v_tot int;
begin
  if p_character is null then select * into c from public.characters where user_id = auth.uid() limit 1;
  else select * into c from public.characters where id = p_character; end if;
  if not found then return jsonb_build_object('eligible',false,'reasons',jsonb_build_array('Personaggio non trovato')); end if;
  if not (c.user_id = auth.uid() or public.is_staff()) then raise exception 'non autorizzato'; end if;
  select * into t from public.clan_techniques where id = p_technique;
  if not found then return jsonb_build_object('eligible',false,'reasons',jsonb_build_array('Tecnica non trovata')); end if;
  if not t.is_active then reasons := array_append(reasons,'Tecnica non attiva'); end if;
  select ca.state, coalesce(ca.sessions_done,0) into v_state, v_done
    from public.character_abilities ca where ca.character_id = c.id and ca.technique_id = t.id;
  v_req := coalesce(t.trainings_required, 1);
  if t.clan is not null and (c.clan is distinct from t.clan) then
    reasons := array_append(reasons, 'Devi appartenere al clan '||t.clan);
  end if;
  if t.req_grade is not null and public._grade_rank(c.rank) < public._grade_rank(t.req_grade) then
    reasons := array_append(reasons, 'Grado minimo: '||t.req_grade);
  end if;
  if t.req_stat is not null and t.req_stat_value is not null then
    v_stat := case lower(t.req_stat)
      when 'mente' then c.mente when 'forza' then c.forza
      when 'velocità' then c.velocita when 'velocita' then c.velocita
      when 'resistenza' then c.resistenza when 'ninjutsu' then c.ninjutsu
      when 'genjutsu' then c.genjutsu when 'taijutsu' then c.taijutsu
      when 'fuuinjutsu' then c.fuuinjutsu when 'kekkei genkai' then c.kekkei_genkai
      else null end;
    if v_stat is null or v_stat < t.req_stat_value then
      reasons := array_append(reasons, t.req_stat||' minimo: '||t.req_stat_value);
    end if;
  end if;
  if coalesce(t.level,1) > 1 then
    select exists(
      select 1 from public.character_abilities ca
        join public.clan_techniques pt on pt.id = ca.technique_id
      where ca.character_id = c.id and ca.state='attiva'
        and pt.name = t.name and (pt.clan is not distinct from t.clan) and pt.level = t.level - 1
    ) into v_prev;
    if not v_prev then reasons := array_append(reasons, 'Serve prima il livello '||(t.level-1)||' attivo'); end if;
  end if;
  if t.xp_cost is not null and coalesce(c.exp,0) < t.xp_cost then
    reasons := array_append(reasons, 'XP insufficiente: servono '||t.xp_cost||', hai '||coalesce(c.exp,0));
  end if;
  if not coalesce(t.is_innata,false) and v_state is null then
    select s.usati, s.totale into v_us, v_tot from public.slot_tecniche(c.id) s;
    if v_us >= v_tot then
      reasons := array_append(reasons, 'Slot tecniche pieni ('||v_us||'/'||v_tot||'): compra uno slot extra o sali di grado');
    end if;
  end if;
  if v_state = 'attiva' then reasons := array_append(reasons,'Già appresa'); end if;
  if v_state = 'in_addestramento' then reasons := array_append(reasons,'Già in addestramento'); end if;
  return jsonb_build_object(
    'eligible', (array_length(reasons,1) is null),
    'reasons', to_jsonb(reasons),
    'state', v_state,
    'sessions_done', coalesce(v_done,0),
    'sessions_required', v_req,
    'xp_cost', t.xp_cost,
    'character_id', c.id,
    'technique', jsonb_build_object('id',t.id,'name',t.name,'level',t.level,'clan',t.clan)
  );
end; $function$;

CREATE OR REPLACE FUNCTION public.unequip_row(p_equip uuid, p_qty integer DEFAULT NULL::integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare row public.character_equipment; ch public.characters;
begin
  if p_qty is not null and p_qty < 1 then raise exception 'Quantità non valida'; end if;
  select * into row from public.character_equipment where id=p_equip;
  if not found then raise exception 'Riga non trovata'; end if;
  select * into ch from public.characters where id=row.character_id;
  if not (ch.user_id=auth.uid() or public.is_staff()) then raise exception 'Non autorizzato'; end if;
  if row.anchor is not null and exists(select 1 from public.character_equipment where parent_id=p_equip) then
    delete from public.character_equipment where parent_id=p_equip;
    delete from public.character_equipment where id=p_equip;
    return json_build_object('ok',true,'removed','container');
  end if;
  if p_qty is null or p_qty >= row.quantity then
    delete from public.character_equipment where id=p_equip;
  else
    update public.character_equipment set quantity=quantity-p_qty where id=p_equip;
  end if;
  return json_build_object('ok',true);
end; $function$;