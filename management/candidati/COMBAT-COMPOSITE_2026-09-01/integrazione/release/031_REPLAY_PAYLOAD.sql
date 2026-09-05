CREATE OR REPLACE FUNCTION public._esame_replay_payload(p_prova uuid, p_ciclo uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  c public.esame_narrazione_cicli%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype;
  s public.esame_scambi%rowtype;     -- lo scambio risolto da/dopo questo ciclo
  v_pg text; v_ref jsonb; v_fatti jsonb; v_int jsonb; v_asof timestamptz;
  v_chi_att text; v_esiti jsonb; v_et text; v_f jsonb; v_mov text;
  v_pc_prima int; v_pp_prima int; v_ordine int;
  v_spatial jsonb; v_audit jsonb; v_bound boolean; v_scene_version integer;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found then return null; end if;
  select * into c from public.esame_narrazione_cicli where id = p_ciclo and prova_id = p_prova;
  if not found then return null; end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select * into v_c from public.characters where id = v.candidate_character;
  v_asof := c.created_at;
  v_bound:=public._esame_spatial_snapshot_v1(p_prova) is not null;
  v_audit:=c.referto->'_spatial_audit';
  if v_bound then
    if v_audit is null then raise exception 'EXAM_SPATIAL_REPLAY_REFERENCE_MISSING'; end if;
    v_scene_version:=(v_audit->>case when c.ruolo in ('png_esito','png_finale') then 'after_version' else 'before_version' end)::int;
    v_spatial:=public._esame_spatial_snapshot_version_v1(p_prova,v_scene_version);
  end if;
  select left(btrim(m.body), 2500) into v_pg from public.messages m where m.id = c.pg_message_id;

  -- lo scambio collegato: per png_esito/png_finale è l'ultimo scritto PRIMA
  -- del ciclo; per png_difende/png_attacca è il primo scritto DOPO.
  if v_bound then
    select x.* into strict s from public.esame_scambi x
      where x.id=(v_audit->>'scambio_id')::uuid and x.prova_id=p_prova;
  elsif c.ruolo in ('png_esito','png_finale') then
    select * into s from public.esame_scambi x where x.prova_id = p_prova and x.created_at <= c.created_at
     order by x.ordine desc limit 1;
  else
    select * into s from public.esame_scambi x where x.prova_id = p_prova and x.created_at > c.created_at
     order by x.ordine asc limit 1;
  end if;

  -- il referto, arricchito con i fatti ricalcolati
  if c.ruolo in ('png_esito','png_finale') and s.id is not null then
    v_f := public._esame_scambio_fatti(s);
    if v_bound then
      v_mov:=c.referto->>'movimento';
    else
    v_pc_prima := coalesce(s.pos_cand_prima, s.pos_cand); v_pp_prima := coalesce(s.pos_png_prima, s.pos_png);
    v_mov := coalesce(nullif(concat_ws('; ',
      case when v_pc_prima <> s.pos_cand then v_c.name || case when abs(s.pos_png - s.pos_cand) < abs(s.pos_png - v_pc_prima) then ' ha guadagnato terreno' else ' ha ceduto terreno' end end,
      case when v_pp_prima <> s.pos_png then v_prof.nome || case when abs(s.pos_png - s.pos_cand) < abs(v_pp_prima - s.pos_cand) then ' ha guadagnato terreno' else ' ha ceduto terreno' end end), ''), 'nessuno');
    end if;
    v_ref := coalesce(c.referto, '{}'::jsonb) || jsonb_build_object(
      'bersaglio', v_f->>'bersaglio', 'bersaglio_su', s.defender_name,
      'conseguenza', v_f->>'conseguenza', 'gravita', v_f->>'gravita',
      'postura_difensore', case when s.colpito or s.ko then public._esame_postura(v_f->>'gravita', s.ko) else 'in guardia' end,
      'movimento', v_mov,
      'iniziativa', case when c.ruolo = 'png_finale' then 'la prova si chiude'
                         when s.chi_attacca = 'png' then 'passa a ' || s.defender_name else 'passa a ' || s.attacker_name end,
      'scambio', case s.scambio when 1 then 'primo' when 2 then 'secondo' when 3 then 'terzo' else 'ultimo' end,
      'ancora', case when v_bound then c.referto->'ancora'
                    when s.reazione = 'sostituzione' and not s.colpito
                     then (select jsonb_build_object('id',a->>'id','oggetto',a->>'oggetto','dove',a->>'dove','taglia',a->>'taglia','nota',a->>'nota')
                             from jsonb_array_elements(public._esame_aula_ancore(public._esame_aula_villaggio(p_prova))) a
                            order by sqrt(power((a->>'x')::numeric - (case when s.chi_attacca='png' then s.pos_cand else s.pos_png end),2) + power((a->>'y')::numeric - 5,2)), a->>'id' limit 1)
                     else null end,
      'segni', public._esame_segni(p_prova, s.ordine));
    v_ref := public._esame_referto_modello(v_ref-'_spatial_audit');
  elsif c.ruolo = 'png_attacca' then
    v_ref := (select public._esame_referto_modello(p.referto-'_spatial_audit') from public.esame_narrazione_cicli p
               where p.prova_id = p_prova and p.ruolo = 'png_difende' and p.stato = 'risolta'
                 and p.created_at < c.created_at
               order by p.resolved_at desc nulls last, p.created_at desc limit 1);
  else
    v_ref := null;
  end if;

  -- l'intenzione reale come unica intenzione
  v_esiti := to_jsonb(coalesce(c.esiti_attesi, array[]::text[]));
  if c.ruolo in ('png_difende','png_attacca') then
    v_chi_att := case when c.ruolo = 'png_attacca' then 'png' else 'candidato' end;
    v_et := case when c.ruolo = 'png_difende' then 'Reazione: ' || coalesce(s.reazione, 'reazione')
                 else coalesce(s.tech_name, 'attacco') end;
    v_int := jsonb_build_array(jsonb_build_object(
      'id', coalesce(c.intenzione_id, 'replay'), 'etichetta', v_et,
      'genere', case when c.ruolo = 'png_difende' then 'reazione' else 'turno' end,
      'movimento', null, 'esiti_possibili', v_esiti));
    v_fatti := jsonb_build_object(
      'attacca', case when v_chi_att = 'png' then v_prof.nome else coalesce(v_c.name,'il candidato') end,
      'difende', case when v_chi_att = 'png' then coalesce(v_c.name,'il candidato') else v_prof.nome end,
      'bersaglio_previsto', case when s.id is not null
          then coalesce(case when s.chi_attacca <> 'png' then public._esame_zona_dichiarata(v_pg, v.seme, public._esame_indice(s.scambio, s.meta, s.chi_attacca, 'att')) end, public._esame_zona(v.seme, s.scambio, s.meta, s.chi_attacca, s.kind)) else null end,
      'nota_bersaglio', case when c.ruolo = 'png_difende'
          then 'se il colpo del candidato arriva, arriva qui: le branche «colpito» e «sfiorato» lo raccontano su questa zona; la gravità non è ancora nota e non va quantificata'
          else 'se l''attacco dello sfidante arriva, arriva qui: la frase che apre l''attacco dice che mira a questa zona; l''esito lo decide il campo e lo racconta il ciclo successivo' end,
      'ancora_sostituzione', null);
  else
    v_int := jsonb_build_array(jsonb_build_object(
      'id', case when c.ruolo = 'png_finale' then 'narra_finale' else 'narra_esito' end,
      'etichetta', case when c.ruolo = 'png_finale' then 'Concludi l''Esame' else 'Racconta l''esito della difesa' end,
      'genere', case when c.ruolo = 'png_finale' then 'finale' else 'esito' end,
      'movimento', null, 'esiti_possibili', '[]'::jsonb));
    v_fatti := '{}'::jsonb;
  end if;

  return public._esame_payload_v5_complete_v1(p_prova,jsonb_build_object(
    'versione', 5, 'replay', true,
    'ricevuta_id', c.opzioni_id, 'ruolo', c.ruolo,
    'contesto_pg', coalesce(v_pg,''),
    'esito_precedente', v_ref,
    'fatti_del_ciclo', v_fatti,
    'stile_precedente', public._esame_storia_narrativa(p_prova, v_asof),
    'scena', case when v_bound then public._esame_png_scena_snapshot_v1(p_prova,v_asof,v_scene_version)
                  else public._esame_png_scena(p_prova, v_asof) end,
    'dossier', public._esame_dossier_sfidante(p_prova),
    'sensei', case when c.ruolo = 'png_finale' then public._esame_sensei_finale(p_prova) else null end,
    'intenzioni', v_int,
    'originale', jsonb_build_object('azione_png', c.azione_png, 'testo_esito', c.testo_esito, 'model', c.model, 'stato', c.stato)));
end
$function$;
