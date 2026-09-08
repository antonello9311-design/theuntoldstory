CREATE OR REPLACE FUNCTION public._esame_referto_modello(p_referto jsonb)
 RETURNS jsonb
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'public'
AS $function$
  select case
    when p_referto is null then null
    when jsonb_typeof(p_referto) = 'object' then
      coalesce((
        select jsonb_object_agg(k, public._esame_referto_modello(v))
          from jsonb_each((case
          -- Nell'Assalto le figure appartengono all'attaccante. Il risultato
          -- del colpo reale riguarda il difensore; l'esito dell'inganno non
          -- trasforma quest'ultimo in una copia.
          when p_referto->>'tecnica' = 'Moltiplicazione del corpo · Assalto'
            and p_referto->>'esito' in ('copia_colpita','originale_individuato')
            and nullif(p_referto->>'attaccante','') is not null
            and nullif(p_referto->>'difensore','') is not null
          then p_referto || jsonb_build_object(
            'bersaglio_su',p_referto->>'difensore',
            'copie_di',p_referto->>'attaccante',
            'difesa_diretta_a',case p_referto->>'esito'
              when 'copia_colpita' then 'una copia dell''attaccante'
              else 'l''attaccante originale' end)
          else p_referto end) - 'appendice') as e(k, v)
         where public._esame_referto_modello(v) is not null
      ), '{}'::jsonb)
    when jsonb_typeof(p_referto) = 'array' then
      coalesce((
        select jsonb_agg(public._esame_referto_modello(x))
          from jsonb_array_elements(p_referto) x
         where public._esame_referto_modello(x) is not null
      ), '[]'::jsonb)
    when jsonb_typeof(p_referto) = 'number' then null
    when jsonb_typeof(p_referto) = 'string'
     and (p_referto #>> '{}') ~ '[0-9]' then null
    else p_referto
  end
$function$;

REVOKE ALL ON FUNCTION public._esame_referto_modello(jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public._esame_referto_modello(jsonb) TO postgres, service_role;
