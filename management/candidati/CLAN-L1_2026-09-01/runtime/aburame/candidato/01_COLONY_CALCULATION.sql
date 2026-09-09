-- Candidato privato: sola matematica ratificata, nessuna risorsa o permission creata.
-- Non applicabile isolatamente: ledger, acquisizione, recupero atomico e consumer ancora necessari.
BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='30s';
CREATE SCHEMA clan_aburame_private AUTHORIZATION postgres;
REVOKE ALL ON SCHEMA clan_aburame_private FROM PUBLIC,anon,authenticated,service_role;
GRANT USAGE ON SCHEMA clan_aburame_private TO postgres;

CREATE FUNCTION clan_aburame_private.capacity_for_kg(p_permanent_kg integer)
RETURNS integer LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER SET search_path='' AS $function$
BEGIN
 IF p_permanent_kg IS NULL OR p_permanent_kg<0 THEN
  RAISE EXCEPTION 'aburame_permanent_kg_invalid' USING ERRCODE='22023'; END IF;
 RETURN 20+5*(p_permanent_kg/10);
END $function$;
REVOKE ALL ON FUNCTION clan_aburame_private.capacity_for_kg(integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_aburame_private.capacity_for_kg(integer) TO postgres;

CREATE FUNCTION clan_aburame_private.regeneration_split(p_capacity integer,p_living integer,p_theoretical_chakra integer)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $function$
DECLARE missing integer; diverted integer;
BEGIN
 -- Il caller futuro deve derivare questi valori dal ledger e dal solo recupero automatico pre-cap.
 -- Questa funzione pura non certifica origine dell'evento, fuori-combat, possesso o idempotenza.
 IF p_capacity IS NULL OR p_living IS NULL OR p_theoretical_chakra IS NULL
  OR p_capacity<0 OR p_living<0 OR p_living>p_capacity OR p_theoretical_chakra<0 THEN
  RAISE EXCEPTION 'aburame_regeneration_input_invalid' USING ERRCODE='22023'; END IF;
 missing:=p_capacity-p_living;
 diverted:=least(missing,p_theoretical_chakra/2);
 RETURN jsonb_build_object('formula_version','aburame-symbiotic-regeneration/1',
  'colony_recovered',diverted,'chakra_remaining_before_cap',p_theoretical_chakra-diverted,
  'living_after',p_living+diverted);
END $function$;
REVOKE ALL ON FUNCTION clan_aburame_private.regeneration_split(integer,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_aburame_private.regeneration_split(integer,integer,integer) TO postgres;
COMMIT;
