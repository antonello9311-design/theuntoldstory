-- SP08 SOURCE ONLY; integrated Root composition and review required.
DO $sp08_not_installable$BEGIN RAISE EXCEPTION 'SP08_ROOT_COMPOSITION_REQUIRED';END $sp08_not_installable$;
CREATE OR REPLACE FUNCTION clan_hyuga_private.rotation_profile(p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$

DECLARE a public.combat_v2_actors%ROWTYPE; gate clan_hyuga_private.rotation_gate%ROWTYPE;
 st clan_innata_combat_private.combat_state%ROWTYPE; scope jsonb;staff_profile jsonb;kg bigint;tai bigint;ct public.clan_techniques%ROWTYPE;
BEGIN
 SELECT * INTO gate FROM clan_hyuga_private.rotation_gate WHERE singleton AND enabled;
 IF NOT FOUND OR p_actor IS NULL THEN RETURN NULL; END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND state='attivo' AND companion_id IS NULL;
 IF NOT FOUND THEN RETURN NULL;END IF;
 BEGIN scope:=clan_hyuga_private.combat_scope(a.id);
 EXCEPTION WHEN insufficient_privilege THEN RETURN NULL;END;
 IF (scope->>'is_test')::boolean THEN
  IF NOT gate.staff_enabled THEN RETURN NULL;END IF;
  -- SP08: optional legacy L1 Rotation probe, not an explicit Innata request.
  IF EXISTS(SELECT 1 FROM public.combat_v2_sessions sp08_session
    WHERE sp08_session.id=a.session_id
     AND sp08_session.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
     AND sp08_session.closed_at IS NULL
     AND NOT public.combat_v2_values_written(sp08_session.id)) THEN
   staff_profile:=clan_innata_narrative_private.staff_profile_actor_v1(a.id);
   IF staff_profile IS NOT NULL AND (staff_profile->>'technique_id')::uuid
    IS DISTINCT FROM '4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid THEN RETURN NULL;END IF;
  END IF;

 ELSE
  IF NOT gate.public_enabled OR NOT EXISTS(SELECT 1 FROM public.character_abilities
   WHERE character_id=a.character_id AND technique_id=gate.technique_id AND state='attiva')
   OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(a.mechanics_snapshot->'abilities') b
    WHERE b->>'source'='clan' AND b->>'id'=gate.technique_id::text) THEN RETURN NULL; END IF;
 END IF;
 SELECT * INTO STRICT ct FROM public.clan_techniques WHERE id=gate.technique_id;
 IF NOT (scope->>'is_test')::boolean AND NOT ct.is_active THEN RETURN NULL;END IF;
 IF ct.uso IS DISTINCT FROM 'difesa' OR NOT ct.difensiva OR ct.chakra_cost IS DISTINCT FROM 10
  OR ct.potenza IS DISTINCT FROM 25 OR ct.danno_base IS DISTINCT FROM 0 THEN RAISE EXCEPTION 'rotation_catalog_drift';END IF;
 st:=clan_innata_private.combat_state_read(a.id,'4a527ff2-0420-4da9-bc1f-5489c753b285');
 IF NOT coalesce(st.active,false) OR combat_panel_private.immobilization_active(a.id)
  OR EXISTS(SELECT 1 FROM clan_marionettisti_private.links WHERE owner_actor_id=a.id AND state='connected')
 THEN RETURN NULL;END IF;
 IF a.mechanics_snapshot->>'kekkei_genkai' !~ '^[0-9]+$' OR a.mechanics_snapshot->>'taijutsu' !~ '^[0-9]+$'
  OR a.mechanics_snapshot->>'kekkei_genkai' IS NULL OR a.mechanics_snapshot->>'taijutsu' IS NULL THEN
  RAISE EXCEPTION 'rotation_statistics_invalid';END IF;
 kg:=(a.mechanics_snapshot->>'kekkei_genkai')::bigint;tai:=(a.mechanics_snapshot->>'taijutsu')::bigint;
 IF kg<45 THEN RETURN NULL;END IF;
 IF kg+tai>2147483647 THEN RAISE EXCEPTION 'rotation_pool_overflow';END IF;
 RETURN jsonb_build_object('profile_version','hyuga-rotation/1','technique_id',gate.technique_id,
  'kg',kg,'taijutsu',tai,'pool',kg+tai,'power_base',25,'power_contribution',(kg+tai)/10,
  'power',25+(kg+tai)/10,'modifiers','[]'::jsonb,'intrinsic_roll_bonus',0,'chakra_base',10,
  'main_actions',0,'reactions',1,'byakugan_state_version',st.state_version,'is_test',scope->'is_test',
  'catalog',jsonb_build_object('name',ct.name,'description',ct.description,'danno_effetto',ct.danno_effetto,
   'potenza',ct.potenza,'difesa',ct.difesa,'danno_base',ct.danno_base,'tipo_azione',ct.tipo_azione,
   'consumption_type',ct.consumption_type,'chakra_cost',ct.chakra_cost,'portata',ct.portata,'bersaglio',ct.bersaglio));
END

$function$
