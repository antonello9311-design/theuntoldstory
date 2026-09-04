-- Rollback della 006. Eseguire con zero prove aperte e dopo aver
-- ridistribuito la fotografia Edge v120 conservata nel cantiere.
do $r$
declare v_def text; v_n integer; v_a integer; v_b integer;
begin
  if exists (select 1 from public.esame_prove where stato='aperta') then
    raise exception 'rollback 006: esiste una prova aperta';
  end if;

  select pg_get_functiondef(p.oid) into v_def from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public' and p.prokind='f' and p.proname='_esame_png_gioca'
     and pg_get_function_identity_arguments(p.oid)='p_prova uuid, p_opzione text, p_da text';
  v_n := (length(v_def)-length(replace(v_def, $$'chiave',        v_sc->>'chiave',
           'pos_cand_prima', v.pos_candidato,
      'pos_png_prima', v.pos_png,
           'scelta_da',     p_da)$$, ''))) / length($$'chiave',        v_sc->>'chiave',
           'pos_cand_prima', v.pos_candidato,
      'pos_png_prima', v.pos_png,
           'scelta_da',     p_da)$$);
  if v_n<>1 then raise exception 'rollback 006 png_gioca: %',v_n; end if;
  v_def:=replace(v_def,$$'chiave',        v_sc->>'chiave',
           'pos_cand_prima', v.pos_candidato,
      'pos_png_prima', v.pos_png,
           'scelta_da',     p_da)$$,$$'chiave',        v_sc->>'chiave',
           'scelta_da',     p_da)$$); execute v_def;

  select pg_get_functiondef(p.oid) into v_def from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public' and p.prokind='f' and p.proname='_esame_risolvi'
     and pg_get_function_identity_arguments(p.oid)='p_prova uuid, p_azione jsonb, p_chi text';
  if position('v_movimenti jsonb' in v_def)=0 or position($$'movimenti_autoritativi', v_movimenti$$ in v_def)=0 then
    raise exception 'rollback 006 risolvi: marcatori assenti'; end if;
  v_a:=position($$  v_movimenti := '[]'::jsonb;$$ in v_def);
  v_b:=position('  v_dist_lab := case' in v_def);
  if v_a=0 or v_b<=v_a then raise exception 'rollback 006 risolvi: blocco non univoco'; end if;
  v_def:=substring(v_def from 1 for v_a-1)||substring(v_def from v_b);
  v_def:=replace(v_def,$$
  v_movimenti jsonb := '[]'::jsonb;
  v_amp text;
  v_dir text;$$,'');
  v_def:=replace(v_def,$$    'movimenti_autoritativi', v_movimenti,
$$,'');
  execute v_def;

  select pg_get_functiondef(p.oid) into v_def from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public' and p.prokind='f' and p.proname='_esame_ciclo_payload'
     and pg_get_function_identity_arguments(p.oid)='p_prova uuid';
  v_a:=position($$      'ampiezza', case when v_e->>'movimento' is null$$ in v_def);
  v_b:=position($$      'esiti_possibili', case when v_assalto$$ in v_def);
  if v_a=0 or v_b<=v_a then raise exception 'rollback 006 ciclo: blocco non univoco'; end if;
  v_def:=substring(v_def from 1 for v_a-1)||substring(v_def from v_b);
  execute v_def;

  select pg_get_functiondef(p.oid) into v_def from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public' and p.prokind='f' and p.proname='_esame_replay_payload'
     and pg_get_function_identity_arguments(p.oid)='p_prova uuid, p_ciclo uuid';
  if position('v_movimenti jsonb' in v_def)=0 or position($$'movimenti_autoritativi', v_movimenti$$ in v_def)=0 then
    raise exception 'rollback 006 replay: marcatori assenti'; end if;
  v_a:=position($$    v_movimenti := '[]'::jsonb;$$ in v_def);
  v_b:=position($$    v_ref := coalesce(c.referto$$ in v_def);
  if v_a=0 or v_b<=v_a then raise exception 'rollback 006 replay: blocco referto non univoco'; end if;
  v_def:=substring(v_def from 1 for v_a-1)||substring(v_def from v_b);
  v_def:=replace(v_def,$$
  v_movimenti jsonb := '[]'::jsonb;
  v_amp text;
  v_dir text;$$,'');
  v_def:=replace(v_def,$$      'movimenti_autoritativi', v_movimenti,
$$,'');
  v_a:=position($$      'movimento', case when c.ruolo='png_attacca'$$ in v_def);
  v_b:=position($$      'esiti_possibili', v_esiti$$ in v_def);
  if v_a=0 or v_b<=v_a then raise exception 'rollback 006 replay: blocco intenzione non univoco'; end if;
  v_def:=substring(v_def from 1 for v_a-1)||$$      'movimento', null, $$||substring(v_def from v_b+6);
  execute v_def;

  if md5(pg_get_functiondef('public._esame_png_gioca(uuid,text,text)'::regprocedure)) <> 'b5d25e2eda7f62b46971e362a5a16dae'
     or md5(pg_get_functiondef('public._esame_risolvi(uuid,jsonb,text)'::regprocedure)) <> '474aca170416aa0eebfcc3cd3a9771ca'
     or md5(pg_get_functiondef('public._esame_ciclo_payload(uuid)'::regprocedure)) <> '2460ceea8fa78f0483fcfa4c2ed68bf7'
     or md5(pg_get_functiondef('public._esame_replay_payload(uuid,uuid)'::regprocedure)) <> '727499ac75b8dfd122dad21af68e6120'
  then raise exception 'rollback 006: le impronte preimage non coincidono'; end if;
end $r$;
