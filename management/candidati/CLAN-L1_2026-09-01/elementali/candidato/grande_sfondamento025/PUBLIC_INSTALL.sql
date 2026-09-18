BEGIN;

SELECT clan_innata_private.eligibility_release_assert();

DO $pin$
BEGIN
 IF encode(extensions.digest(convert_to(pg_get_functiondef('clan_innata_private.eligibility_release_assert()'::regprocedure),'UTF8'),'sha256'),'hex') IS DISTINCT FROM '80f9e047114aa7d818cf125349a8e8d5af87ebc82c8056560a7e73b6c3db17ec' THEN RAISE EXCEPTION 'grande_sfondamento_public025_guard_drift'; END IF;
 IF md5(pg_get_functiondef('combat_effects_private.session_allowed(uuid)'::regprocedure)) IS DISTINCT FROM 'e83e4399164eb53164f0d8148182bea0' THEN RAISE EXCEPTION 'grande_sfondamento_public025_session_allowed_drift'; END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('combat_v2_elemental_internal.other_profile(uuid,uuid)'::regprocedure),'UTF8'),'sha256'),'hex') IS DISTINCT FROM 'e2f9fcb1449f2a4aecf65fa2c219c36d9ef8a9dcb42cb06595d6ca859f26a36c' THEN RAISE EXCEPTION 'grande_sfondamento_public025_profile_drift'; END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid)'::regprocedure),'UTF8'),'sha256'),'hex') IS DISTINCT FROM '1ca1400e5e9d62408ca6c4c72a8d33c6f9d8dd8808415424ded594efb127e2a2' THEN RAISE EXCEPTION 'grande_sfondamento_public025_force_drift'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='combat_v2_elemental_internal' AND table_name='other_gates' AND column_name='public_enabled') THEN RAISE EXCEPTION 'grande_sfondamento_public025_gate_column_exists'; END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_gates WHERE technique_id='d5605069-b381-41ad-8e6a-9c24a314c58f'::uuid AND enabled) THEN RAISE EXCEPTION 'grande_sfondamento_public025_gate_drift'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.clan_techniques WHERE id='d5605069-b381-41ad-8e6a-9c24a314c58f'::uuid
  AND description='Una folata che parte dal palmo e spinge via tutto quello che trova. Si apre col sigillo dell''Uccello.'
  AND danno_effetto='Disperde fumo, nebbia e polvere, e chi ci si nascondeva dentro.'
  AND durata='Istantanea' AND requirements IS NULL AND req_stat IS NULL AND req_stat_value IS NULL
  AND chakra_cost=10 AND danno_base=20 AND grado='C' AND req_grade='Genin' AND req_elements=ARRAY['Vento']::text[] AND gittata='media' AND is_active) THEN
  RAISE EXCEPTION 'grande_sfondamento_public025_catalog_drift';
 END IF;
END $pin$;

ALTER TABLE combat_v2_elemental_internal.other_gates
 ADD COLUMN public_enabled boolean NOT NULL DEFAULT false;
ALTER TABLE combat_v2_elemental_internal.other_gates
 ADD CONSTRAINT other_gates_public_requires_enabled CHECK (NOT public_enabled OR enabled);

CREATE OR REPLACE FUNCTION combat_effects_private.session_allowed(p_session uuid)
 RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO '' AS $function$
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_sessions s WHERE s.id=p_session AND s.state='in_corso' AND s.closed_at IS NULL
  AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings b WHERE b.combat_session_id=s.id)
  AND (EXISTS(SELECT 1 FROM combat_consumer_private.activities c WHERE c.session_id=s.id AND c.phase<>'closed') OR EXISTS(SELECT 1 FROM combat_panel_private.master_panel_sessions m WHERE m.master_session_id=s.master_session_id))
  AND EXISTS(SELECT 1 FROM public.combat_v2_actors a WHERE a.session_id=s.id AND a.actor_kind='pg')
  AND (combat_effects_private.staff_session_allowed(s.id) OR combat_effects_private.scudo_public_runtime_allowed(s.id)
   OR EXISTS(SELECT 1 FROM combat_v2_elemental_internal.suiton_gates g WHERE g.enabled AND g.public_enabled)
   OR EXISTS(SELECT 1 FROM combat_v2_elemental_internal.suiton_sources z JOIN public.combat_v2_declarations d ON d.id=z.declaration_id JOIN public.combat_v2_rounds r ON r.id=d.round_id WHERE r.session_id=s.id AND z.preparation#>'{profile,runtime_public_admitted}'='true'::jsonb AND combat_v2_elemental_internal.suiton_source_valid(z.declaration_id))
   OR EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_gates g WHERE g.enabled AND g.public_enabled)
   OR EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_sources z JOIN public.combat_v2_declarations d ON d.id=z.declaration_id JOIN public.combat_v2_rounds r ON r.id=d.round_id WHERE r.session_id=s.id AND z.preparation#>'{profile,runtime_public_admitted}'='true'::jsonb AND combat_v2_elemental_internal.other_source_valid(z.declaration_id))))
$function$;

CREATE OR REPLACE FUNCTION combat_v2_elemental_internal.other_profile(p_actor uuid, p_technique uuid)
 RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO '' AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE;p jsonb;public_admitted boolean:=false;
BEGIN
 IF NOT EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_gates WHERE technique_id=p_technique AND enabled) THEN RETURN NULL;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind IN ('pg','png') AND companion_id IS NULL AND state='attivo';
 IF a.id IS NULL OR NOT combat_effects_private.session_allowed(a.session_id) THEN RETURN NULL;END IF;
 public_admitted:=NOT combat_effects_private.staff_session_allowed(a.session_id) AND EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_gates WHERE technique_id=p_technique AND enabled AND public_enabled);
 IF NOT combat_effects_private.staff_session_allowed(a.session_id) AND NOT public_admitted THEN RETURN NULL;END IF;
 p:=combat_v2_elemental_internal.technique_profile_v1(p_technique);
 IF jsonb_typeof(a.mechanics_snapshot->'ninjutsu') IS DISTINCT FROM 'number'
  OR (a.mechanics_snapshot->>'ninjutsu')::numeric < (p#>>'{eligibility,ninjutsu_min}')::numeric THEN RETURN NULL;END IF;
 IF a.actor_kind='png' THEN
  IF NOT combat_v2_elemental_internal.other_png_owned(a.id,p_technique) THEN RETURN NULL;END IF;
 ELSIF combat_v2_elemental_internal.other_staff_binding(a.id,p_technique) IS NULL AND
  NOT combat_v2_elemental_internal.eligible_v1(a.character_id,p_technique,false) THEN RETURN NULL;END IF;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]')) x
  WHERE x->>'source'='clan' AND x->>'id'=p_technique::text) THEN RETURN NULL;END IF;
 RETURN CASE WHEN public_admitted THEN p||jsonb_build_object('runtime_public_admitted',true) ELSE p END;
END $function$;

ALTER FUNCTION combat_effects_private.session_allowed(uuid) OWNER TO postgres;
REVOKE ALL ON FUNCTION combat_effects_private.session_allowed(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_effects_private.session_allowed(uuid) TO postgres;
ALTER FUNCTION combat_v2_elemental_internal.other_profile(uuid,uuid) OWNER TO postgres;
REVOKE ALL ON FUNCTION combat_v2_elemental_internal.other_profile(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_elemental_internal.other_profile(uuid,uuid) TO postgres;

DO $force_patch$
DECLARE v text; anchor constant text:='s.profile IS DISTINCT FROM combat_v2_elemental_internal.technique_profile_v1(s.catalog_technique_id)'; occurrences integer;
BEGIN
 v:=pg_get_functiondef('combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid)'::regprocedure);
 occurrences:=(length(v)-length(replace(v,anchor,'')))/length(anchor);
 IF occurrences<>1 THEN RAISE EXCEPTION 'grande_sfondamento_public025_force_anchor_count_%',occurrences; END IF;
 EXECUTE replace(v,anchor,'(s.profile - ''runtime_public_admitted'') IS DISTINCT FROM combat_v2_elemental_internal.technique_profile_v1(s.catalog_technique_id)');
END $force_patch$;
ALTER FUNCTION combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid) OWNER TO postgres;
REVOKE ALL ON FUNCTION combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid) TO postgres;

DO $guard_patch$
DECLARE v text; old_hash text[]:=ARRAY['b8faaa991c581771256b4736160ae081','b4ad443bffb9972a1c684d910c1fa837']; new_hash text[]; occurrences integer;i integer;
BEGIN
 new_hash:=ARRAY[
  (SELECT md5(p.prosrc) FROM pg_proc p WHERE p.oid='combat_v2_elemental_internal.other_profile(uuid,uuid)'::regprocedure),
  (SELECT md5(p.prosrc) FROM pg_proc p WHERE p.oid='combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid)'::regprocedure)];
 v:=pg_get_functiondef('clan_innata_private.eligibility_release_assert()'::regprocedure);
 FOR i IN 1..2 LOOP
  occurrences:=(length(v)-length(replace(v,old_hash[i],'')))/length(old_hash[i]);
  IF occurrences<>1 THEN RAISE EXCEPTION 'grande_sfondamento_public025_guard_anchor_%_count_%',i,occurrences; END IF;
  v:=replace(v,old_hash[i],new_hash[i]);
 END LOOP;
 EXECUTE v;
END $guard_patch$;
ALTER FUNCTION clan_innata_private.eligibility_release_assert() OWNER TO postgres;
REVOKE ALL ON FUNCTION clan_innata_private.eligibility_release_assert() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_innata_private.eligibility_release_assert() TO postgres;

UPDATE public.clan_techniques SET
 description='Dopo aver composto i sigilli, iniziando dall''Uccello, il ninja libera una forte folata di vento dal palmo, dirigendola verso un solo avversario.',
 danno_effetto='Su un colpo pieno, la folata può respingere il bersaglio lungo la direzione dell''attacco; ostacoli, dislivelli e terreno possono arrestare lo spostamento.',
 durata='Istantanea',
 requirements='Grado Genin o superiore, elemento Vento, Ninjutsu 40 e possesso della tecnica.',
 req_stat='Ninjutsu',req_stat_value=40
WHERE id='d5605069-b381-41ad-8e6a-9c24a314c58f'::uuid;

UPDATE combat_v2_elemental_internal.other_gates
 SET public_enabled=true
WHERE technique_id='d5605069-b381-41ad-8e6a-9c24a314c58f'::uuid AND enabled;

SELECT clan_innata_private.eligibility_release_assert();

DO $post$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_gates WHERE technique_id='d5605069-b381-41ad-8e6a-9c24a314c58f'::uuid AND enabled AND public_enabled) THEN RAISE EXCEPTION 'grande_sfondamento_public025_enable_failed'; END IF;
 IF EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_gates WHERE technique_id<>'d5605069-b381-41ad-8e6a-9c24a314c58f'::uuid AND public_enabled) THEN RAISE EXCEPTION 'grande_sfondamento_public025_scope_failed'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.clan_techniques WHERE id='d5605069-b381-41ad-8e6a-9c24a314c58f'::uuid
  AND description='Dopo aver composto i sigilli, iniziando dall''Uccello, il ninja libera una forte folata di vento dal palmo, dirigendola verso un solo avversario.'
  AND danno_effetto='Su un colpo pieno, la folata può respingere il bersaglio lungo la direzione dell''attacco; ostacoli, dislivelli e terreno possono arrestare lo spostamento.'
  AND durata='Istantanea' AND requirements='Grado Genin o superiore, elemento Vento, Ninjutsu 40 e possesso della tecnica.'
  AND req_stat='Ninjutsu' AND req_stat_value=40) THEN RAISE EXCEPTION 'grande_sfondamento_public025_catalog_failed'; END IF;
END $post$;
COMMIT;
