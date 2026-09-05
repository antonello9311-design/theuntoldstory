CREATE OR REPLACE FUNCTION public._esame_ciclo_payload(p_prova uuid)
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
  v_int jsonb; v_e jsonb; v_out jsonb := '[]'::jsonb;
  v_pg text;
  v_assalto boolean := false;
  v_chi_att text; v_kind text := 'fisico';
  v_fatti jsonb;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found or v.stato <> 'aperta' then return null; end if;

  select * into c from public.esame_narrazione_cicli
   where prova_id = p_prova and stato = 'aperta';
  if not found then return null; end if;

  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select * into v_c from public.characters where id = v.candidate_character;

  select left(btrim(m.body), 2500) into v_pg
    from public.messages m where m.id = c.pg_message_id;

  v_assalto := c.ruolo = 'png_difende'
    and v.pend_azione->'principale'->>'fonte' = 'moltiplicazione'
    and v.pend_azione->'principale'->>'modalita' = 'assalto';

  v_int := coalesce(v.opzioni_png->'intenzioni','[]'::jsonb);
  for v_e in select * from jsonb_array_elements(v_int) loop
    v_out := v_out || jsonb_build_array(jsonb_build_object(
      'id',        v_e->>'intenzione_id',
      'etichetta', v_e->>'etichetta',
      'genere',    v_e->>'genere',
      'movimento', case v_e->>'movimento' when 'avanti' then 'guadagna terreno'
                                          when 'indietro' then 'cede terreno' else null end,
      'esiti_possibili', case when v_assalto
        then '["copia_colpita","originale_individuato"]'::jsonb
        else to_jsonb(coalesce(
          (select array_agg(x) from jsonb_array_elements_text(v_e->'esiti_possibili') x),
          array[]::text[]))
      end));
  end loop;

  -- I fatti già decisi per questo ciclo, prima della risoluzione: chi attacca
  -- nella metà in corso e dove il colpo è destinato (il dado della prova).
  if c.ruolo in ('png_difende','png_attacca') then
    v_chi_att := case when v.meta = 'png' then 'png' else 'candidato' end;
    if c.ruolo = 'png_difende' then
      v_kind := case when v.pend_azione->'principale'->>'fonte' = 'jutsu'
                     then coalesce((select lower(j.category) from public.jutsu j
                                     where j.id = (v.pend_azione->'principale'->>'id')::uuid), 'fisico')
                     else 'fisico' end;
    end if;
    v_fatti := jsonb_build_object(
      'attacca', case when v_chi_att = 'png' then v_prof.nome else coalesce(v_c.name,'il candidato') end,
      'difende', case when v_chi_att = 'png' then coalesce(v_c.name,'il candidato') else v_prof.nome end,
      'bersaglio_previsto', case when c.ruolo = 'png_difende'
          then coalesce(public._esame_zona_dichiarata(v_pg, v.seme, public._esame_indice(v.scambio, v.meta, v_chi_att, 'att')), public._esame_zona(v.seme, v.scambio, v.meta, v_chi_att, v_kind))
          else public._esame_zona(v.seme, v.scambio, 'png', 'png', 'fisico') end,
      'nota_bersaglio', case when c.ruolo = 'png_difende'
          then 'se il colpo del candidato arriva, arriva qui: le branche «colpito» e «sfiorato» lo raccontano su questa zona; la gravità non è ancora nota e non va quantificata'
          else 'se l''attacco dello sfidante arriva, arriva qui: la frase che apre l''attacco dice che mira a questa zona; l''esito lo decide il campo e lo racconta il ciclo successivo' end,
      'ancora_sostituzione', case when c.ruolo = 'png_difende'
          and public._esame_spatial_snapshot_v1(p_prova) is null
          then public._esame_ancora_scegli(p_prova, v.pos_png) else null end);
  else
    v_fatti := '{}'::jsonb;
  end if;

  return public._esame_payload_v5_complete_v1(p_prova,jsonb_build_object(
    'versione',        5,
    'ricevuta_id',     c.opzioni_id,
    'ruolo',           c.ruolo,
    'contesto_pg',     coalesce(v_pg,''),
    'esito_precedente', case when c.ruolo in ('png_esito','png_finale')
      then public._esame_referto_modello(c.referto-'_spatial_audit')
      else (select public._esame_referto_modello(p.referto-'_spatial_audit')
              from public.esame_narrazione_cicli p
             where p.prova_id = p_prova
               and p.ruolo = 'png_difende'
               and p.stato = 'risolta'
               and p.result_message_id is null
               and coalesce((p.referto->>'legacy')::boolean, false) = false
             order by p.resolved_at desc nulls last, p.created_at desc, p.id desc
             limit 1)
      end,
    'fatti_del_ciclo', v_fatti,
    'stile_precedente', public._esame_storia_narrativa(p_prova),
    'scena',           public._esame_png_scena(p_prova),
    'dossier',         public._esame_dossier_sfidante(p_prova),
    'sensei',          case when c.ruolo = 'png_finale' then public._esame_sensei_finale(p_prova) else null end,
    'intenzioni',      v_out));
end
$function$;
