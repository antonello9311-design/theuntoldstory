CREATE OR REPLACE FUNCTION public._esame_zona_dichiarata(p_testo text, p_seme bigint, p_indice integer)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'public'
AS $function$
declare
  t text := lower(coalesce(p_testo, ''));
  v_zone text[] := array['viso','torace','fianco','ventre','spalla','braccio','gamba','mente'];
  v_parole text[][] := array[
    array['viso',    'viso|volto|faccia|zigomo|mascella|mento|naso|tempia|guancia|labbr|testa|nuca|fronte|occhi'],
    array['torace',  'torace|petto|sterno|costol|costato|clavicol'],
    array['fianco',  'fianc'],
    array['ventre',  'ventre|stomaco|addome|pancia|diaframma|plesso'],
    array['spalla',  'spall'],
    array['braccio', 'bracci|avambracci|gomit|pols|mano|nocch'],
    array['gamba',   'gamb|tibi|stinc|ginocch|cosci|polpacc|cavigli|pied|tallone dell'],
    array['mente',   'mente|genjutsu|illusion']];
  v_best text := null; v_best_pos int := -1; v_pos int; v_z text; v_re text; m text[];
  v_lato text := null; v_dopo text;
  v_mir text := '(?:mir\w*|vers[oa]|contro|diretto a|dirett[oa] al|punt\w*|cerc\w* (?:di )?colpire|colpir\w* (?:la |il |lo |l'')?|centr\w*|raggiung\w*|sull[ao] |all[ao] |al |nel|nell[ao]) ?(?:\w+ ){0,4}?';
  i int;
begin
  if t = '' then return null; end if;
  -- si preferisce una zona preceduta (entro poche parole) da un verbo di mira,
  -- oppure seguita da «dell'altr…/dell'avversari…»; altrimenti l'ultima zona
  -- nominata nel testo. Le parti del corpo dell'attaccante stesso («sulla gamba
  -- destra» come appoggio) restano ambigue: il verbo di mira decide.
  for i in 1..array_length(v_zone,1) loop
    v_z := v_parole[i][1]; v_re := v_parole[i][2];
    for m in select regexp_matches(t, '(' || v_mir || ')(?:la |il |lo |l''|le |i |gli |della |del |dello |dell'')?(' || v_re || ')\w*', 'g') loop
      v_pos := position((m[1] || coalesce(m[2],'')) in t);
      if v_pos > v_best_pos then v_best := v_z; v_best_pos := v_pos; end if;
    end loop;
    for m in select regexp_matches(t, '(' || v_re || ')\w*( dell''altr\w*| dell''avversari\w*| di lei| di lui)', 'g') loop
      v_pos := position(m[1] in t);
      if v_pos > v_best_pos then v_best := v_z; v_best_pos := v_pos; end if;
    end loop;
  end loop;
  if v_best is null then
    for i in 1..array_length(v_zone,1) loop
      v_z := v_zone[i]; v_re := v_parole[i][2];
      for m in select regexp_matches(t, '(' || v_re || ')', 'g') loop
        v_pos := position(m[1] in t);
        if v_pos > v_best_pos then v_best := v_z; v_best_pos := v_pos; end if;
      end loop;
    end loop;
  end if;
  if v_best is null then return null; end if;
  -- il lato: se scritto entro poche parole dopo la zona, altrimenti dal seme
  v_dopo := substr(t, greatest(1, v_best_pos), 60);
  if v_dopo ~ 'destr' then v_lato := 'destra';
  elsif v_dopo ~ 'sinistr' then v_lato := 'sinistra';
  else v_lato := case when abs(public._esame_rng(p_seme, p_indice + 60000)) % 2 = 0 then 'destra' else 'sinistra' end; end if;
  return case
    when v_best in ('mente','torace','ventre','viso') then case v_best when 'mente' then 'la mente' when 'torace' then 'il torace' when 'ventre' then 'il ventre' else 'il viso' end
    when v_best in ('spalla','gamba') then 'la ' || v_best || ' ' || v_lato
    else 'il ' || v_best || ' ' || case v_lato when 'destra' then 'destro' else 'sinistro' end
  end;
end
$function$;
REVOKE ALL ON FUNCTION public._esame_zona_dichiarata(text,bigint,integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public._esame_zona_dichiarata(text,bigint,integer) TO postgres, service_role;

