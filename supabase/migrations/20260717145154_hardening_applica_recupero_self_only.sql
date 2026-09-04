-- Recupero PV/chakra passivo: un utente NON-staff può far avanzare solo il PROPRIO
-- personaggio; il parametro p_user viene ignorato per i non-staff (niente target altrui).
-- Lo staff mantiene la possibilità di indicare un utente (strumenti admin).
-- Comportamento senza argomenti (come lo chiama il sito) invariato per tutti.
create or replace function public.applica_recupero(p_user uuid default null)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare v_user uuid; c public.characters%rowtype; giorni numeric; add_v int; add_c int;
begin
  if public.is_staff() then
    v_user := coalesce(p_user, auth.uid());
  else
    v_user := auth.uid();
  end if;
  if v_user is null then return; end if;
  select * into c from public.characters where user_id = v_user;
  if c.id is null then return; end if;
  giorni := extract(epoch from (now() - coalesce(c.last_regen_at, now()))) / 86400.0;
  if giorni <= 0 then return; end if;
  add_v := floor( coalesce(c.vita_max,0) * giorni / 3.0 );
  add_c := floor( coalesce(c.chakra_max,0) * giorni / 2.0 );
  if add_v <= 0 and add_c <= 0 then return; end if;
  perform set_config('app.allow_vita_delta','1', true);
  perform set_config('app.allow_chakra_delta','1', true);
  update public.characters
     set vita = least(coalesce(vita_max,0), coalesce(vita,0) + greatest(add_v,0)),
         chakra = least(coalesce(chakra_max,0), coalesce(chakra,0) + greatest(add_c,0)),
         last_regen_at = now()
   where user_id = v_user;
end; $function$;