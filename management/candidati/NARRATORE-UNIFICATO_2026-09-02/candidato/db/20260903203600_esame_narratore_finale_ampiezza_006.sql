-- ESAME-GENIN-NARRATORE-FINALE-001 · ampiezza autoritativa in parole.
-- Baseline LIVE obbligatoria: head 20260903111028, zero prove aperte.
-- Cambia soltanto quattro corpi interni già esistenti; firme, owner, ACL,
-- volatilità, SECURITY DEFINER e search_path restano invariati.
-- Vincoli aggiunti/allentati: nessuno. Nuove funzioni: nessuna.

begin;

do $m$
declare
  v_def text;
  v_n integer;
  v_head text;
begin
  select version::text into v_head
    from supabase_migrations.schema_migrations
   order by version desc limit 1;
  if v_head is distinct from '20260903111028' then
    raise exception '006 drift: head attesa 20260903111028, trovata %', v_head;
  end if;
  if exists (select 1 from public.esame_prove where stato = 'aperta') then
    raise exception '006 gate: esiste una prova aperta';
  end if;

  -- Il PNG conserva la fotografia prima del movimento nella pend_azione,
  -- come fa già il candidato. Senza questa coppia il referto non può sapere
  -- quanto si è mosso il PNG dopo che lo stato è stato aggiornato.
  select pg_get_functiondef(p.oid) into v_def
    from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public' and p.prokind='f'
     and p.proname='_esame_png_gioca'
     and pg_get_function_identity_arguments(p.oid)='p_prova uuid, p_opzione text, p_da text';
  if md5(v_def) <> 'b5d25e2eda7f62b46971e362a5a16dae' then
    raise exception '006 drift: _esame_png_gioca';
  end if;
  v_n := (length(v_def)-length(replace(v_def, $$'chiave',        v_sc->>'chiave',
           'scelta_da',     p_da)$$, ''))) / length($$'chiave',        v_sc->>'chiave',
           'scelta_da',     p_da)$$);
  if v_n <> 1 then raise exception '006 png_gioca: ancora trovata % volte', v_n; end if;
  v_def := replace(v_def, $$'chiave',        v_sc->>'chiave',
           'scelta_da',     p_da)$$,
    $$'chiave',        v_sc->>'chiave',
           'pos_cand_prima', v.pos_candidato,
      'pos_png_prima', v.pos_png,
           'scelta_da',     p_da)$$);
  execute v_def;

  -- Il referto autoritativo porta al massimo una voce per attore mosso.
  select pg_get_functiondef(p.oid) into v_def
    from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public' and p.prokind='f'
     and p.proname='_esame_risolvi'
     and pg_get_function_identity_arguments(p.oid)='p_prova uuid, p_azione jsonb, p_chi text';
  if md5(v_def) <> '474aca170416aa0eebfcc3cd3a9771ca' then
    raise exception '006 drift: _esame_risolvi';
  end if;
  v_n := (length(v_def)-length(replace(v_def, 'v_pp_prima int;', ''))) / length('v_pp_prima int;');
  if v_n <> 1 then raise exception '006 risolvi dichiarazioni: %', v_n; end if;
  v_def := replace(v_def, 'v_pp_prima int;', $$v_pp_prima int;
  v_movimenti jsonb := '[]'::jsonb;
  v_amp text;
  v_dir text;$$);

  v_n := (length(v_def)-length(replace(v_def, '  v_dist_lab := case', ''))) / length('  v_dist_lab := case');
  if v_n <> 1 then raise exception '006 risolvi punto movimento: %', v_n; end if;
  v_def := replace(v_def, '  v_dist_lab := case', $$  v_movimenti := '[]'::jsonb;
  if v_pc_prima is distinct from v.pos_candidato then
    v_dir := case when abs(v.pos_png-v.pos_candidato) < abs(v_pp_prima-v_pc_prima)
                  then 'guadagna terreno' else 'cede terreno' end;
    v_amp := case abs(v.pos_candidato-v_pc_prima)
               when 1 then 'un passo' when 2 then 'due passi' else 'tre o più passi' end;
    if v.pos_candidato in (0,10) then v_amp := v_amp || ', fino al bordo del tatami'; end if;
    v_movimenti := v_movimenti || jsonb_build_array(jsonb_build_object(
      'attore_ref','actor.candidate','direzione',v_dir,'ampiezza',v_amp));
  end if;
  if v_pp_prima is distinct from v.pos_png then
    v_dir := case when abs(v.pos_png-v.pos_candidato) < abs(v_pp_prima-v_pc_prima)
                  then 'guadagna terreno' else 'cede terreno' end;
    v_amp := case abs(v.pos_png-v_pp_prima)
               when 1 then 'un passo' when 2 then 'due passi' else 'tre o più passi' end;
    if v.pos_png in (0,10) then v_amp := v_amp || ', fino al bordo del tatami'; end if;
    v_movimenti := v_movimenti || jsonb_build_array(jsonb_build_object(
      'attore_ref','actor.opponent','direzione',v_dir,'ampiezza',v_amp));
  end if;
  v_dist_lab := case$$);

  v_n := (length(v_def)-length(replace(v_def, $$    'iniziativa',     case when v_png_att$$, ''))) / length($$    'iniziativa',     case when v_png_att$$);
  if v_n <> 1 then raise exception '006 risolvi referto: %', v_n; end if;
  v_def := replace(v_def, $$    'iniziativa',     case when v_png_att$$,
    $$    'movimenti_autoritativi', v_movimenti,
    'iniziativa',     case when v_png_att$$);
  execute v_def;

  -- Il payload LIVE traduce i metri interni in un vocabolario narrativo
  -- chiuso e non espone il numero al modello.
  select pg_get_functiondef(p.oid) into v_def
    from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public' and p.prokind='f'
     and p.proname='_esame_ciclo_payload'
     and pg_get_function_identity_arguments(p.oid)='p_prova uuid';
  if md5(v_def) <> '2460ceea8fa78f0483fcfa4c2ed68bf7' then
    raise exception '006 drift: _esame_ciclo_payload';
  end if;
  v_n := (length(v_def)-length(replace(v_def, $$      'esiti_possibili', case when v_assalto$$, ''))) / length($$      'esiti_possibili', case when v_assalto$$);
  if v_n <> 1 then raise exception '006 ciclo payload: %', v_n; end if;
  v_def := replace(v_def, $$      'esiti_possibili', case when v_assalto$$,
    $$      'ampiezza', case when v_e->>'movimento' is null then null else
          (case abs(coalesce((v_e->>'metri')::int,0))
             when 1 then 'un passo' when 2 then 'due passi' else 'tre o più passi' end) ||
          (case when public._esame_bordo(public._esame_muove(
             v.pos_png,v.pos_candidato,coalesce((v_e->>'metri')::int,0),v_e->>'movimento'='avanti')) in (0,10)
             then ', fino al bordo del tatami' else '' end) end,
      'esiti_possibili', case when v_assalto$$);
  execute v_def;

  -- Il replay ricostruisce gli stessi fatti dalle posizioni dello scambio e
  -- applica la stessa forma all'intenzione realmente scelta.
  select pg_get_functiondef(p.oid) into v_def
    from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public' and p.prokind='f'
     and p.proname='_esame_replay_payload'
     and pg_get_function_identity_arguments(p.oid)='p_prova uuid, p_ciclo uuid';
  if md5(v_def) <> '727499ac75b8dfd122dad21af68e6120' then
    raise exception '006 drift: _esame_replay_payload';
  end if;
  v_n := (length(v_def)-length(replace(v_def, 'v_ordine int;', ''))) / length('v_ordine int;');
  if v_n <> 1 then raise exception '006 replay dichiarazioni: %', v_n; end if;
  v_def := replace(v_def, 'v_ordine int;', $$v_ordine int;
  v_movimenti jsonb := '[]'::jsonb;
  v_amp text;
  v_dir text;$$);

  v_n := (length(v_def)-length(replace(v_def, '    v_ref := coalesce(c.referto', ''))) / length('    v_ref := coalesce(c.referto');
  if v_n <> 1 then raise exception '006 replay referto: %', v_n; end if;
  v_def := replace(v_def, '    v_ref := coalesce(c.referto', $$    v_movimenti := '[]'::jsonb;
    if v_pc_prima is distinct from s.pos_cand then
      v_dir := case when abs(s.pos_png-s.pos_cand) < abs(v_pp_prima-v_pc_prima)
                    then 'guadagna terreno' else 'cede terreno' end;
      v_amp := case abs(s.pos_cand-v_pc_prima)
                 when 1 then 'un passo' when 2 then 'due passi' else 'tre o più passi' end;
      if s.pos_cand in (0,10) then v_amp := v_amp || ', fino al bordo del tatami'; end if;
      v_movimenti := v_movimenti || jsonb_build_array(jsonb_build_object(
        'attore_ref','actor.candidate','direzione',v_dir,'ampiezza',v_amp));
    end if;
    if v_pp_prima is distinct from s.pos_png then
      v_dir := case when abs(s.pos_png-s.pos_cand) < abs(v_pp_prima-v_pc_prima)
                    then 'guadagna terreno' else 'cede terreno' end;
      v_amp := case abs(s.pos_png-v_pp_prima)
                 when 1 then 'un passo' when 2 then 'due passi' else 'tre o più passi' end;
      if s.pos_png in (0,10) then v_amp := v_amp || ', fino al bordo del tatami'; end if;
      v_movimenti := v_movimenti || jsonb_build_array(jsonb_build_object(
        'attore_ref','actor.opponent','direzione',v_dir,'ampiezza',v_amp));
    end if;
    v_ref := coalesce(c.referto$$);

  v_n := (length(v_def)-length(replace(v_def, $$      'iniziativa', case when c.ruolo = 'png_finale'$$, ''))) / length($$      'iniziativa', case when c.ruolo = 'png_finale'$$);
  if v_n <> 1 then raise exception '006 replay movimenti: %', v_n; end if;
  v_def := replace(v_def, $$      'iniziativa', case when c.ruolo = 'png_finale'$$,
    $$      'movimenti_autoritativi', v_movimenti,
      'iniziativa', case when c.ruolo = 'png_finale'$$);

  v_n := (length(v_def)-length(replace(v_def, $$      'movimento', null, 'esiti_possibili', v_esiti$$, ''))) / length($$      'movimento', null, 'esiti_possibili', v_esiti$$);
  if v_n <> 1 then raise exception '006 replay intenzione: %', v_n; end if;
  v_def := replace(v_def, $$      'movimento', null, 'esiti_possibili', v_esiti$$,
    $$      'movimento', case when c.ruolo='png_attacca' and s.id is not null
                                  and coalesce(s.pos_png_prima,s.pos_png) <> s.pos_png
                             then case when abs(s.pos_png-s.pos_cand) < abs(coalesce(s.pos_png_prima,s.pos_png)-coalesce(s.pos_cand_prima,s.pos_cand))
                                       then 'guadagna terreno' else 'cede terreno' end else null end,
      'ampiezza', case when c.ruolo='png_attacca' and s.id is not null
                                and coalesce(s.pos_png_prima,s.pos_png) <> s.pos_png then
                      (case abs(s.pos_png-coalesce(s.pos_png_prima,s.pos_png))
                         when 1 then 'un passo' when 2 then 'due passi' else 'tre o più passi' end) ||
                      (case when s.pos_png in (0,10) then ', fino al bordo del tatami' else '' end)
                    else null end,
      'esiti_possibili', v_esiti$$);
  execute v_def;

  -- Postcondizioni: forma, ACL e attributi devono restare quelli fotografati.
  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace
     where n.nspname='public' and p.prokind='f'
       and p.proname in ('_esame_png_gioca','_esame_risolvi','_esame_ciclo_payload','_esame_replay_payload')
       and (pg_get_userbyid(p.proowner) <> 'postgres'
            or p.proconfig is distinct from array['search_path=public']::text[]
            or coalesce(array_to_string(p.proacl,','),'') not like '%service_role=X/postgres%')
  ) then raise exception '006 postflight: owner/search_path/ACL variati'; end if;
  if (select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
       where n.nspname='public' and p.prokind='f'
         and p.proname in ('_esame_png_gioca','_esame_risolvi','_esame_ciclo_payload','_esame_replay_payload')) <> 4 then
    raise exception '006 postflight: firme inattese';
  end if;
end $m$;

commit;
