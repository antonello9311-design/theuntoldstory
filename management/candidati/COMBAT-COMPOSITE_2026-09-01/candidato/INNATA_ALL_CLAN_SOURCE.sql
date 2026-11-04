-- SOURCE ONLY: reviewed Root composition is mandatory. No database execution authorized by this file.
DO $not_installable$BEGIN RAISE EXCEPTION 'INNATA_ALL_CLAN_ROOT_COMPOSITION_REQUIRED';END $not_installable$;
BEGIN;

ALTER TABLE clan_innata_narrative_private.contexts_v1 DROP CONSTRAINT contexts_v1_staff_ability_profile_check;
ALTER TABLE clan_innata_narrative_private.contexts_v1 ADD CONSTRAINT contexts_v1_staff_ability_profile_check CHECK(jsonb_typeof(staff_ability_profile)='object' AND staff_ability_profile->>'schema_version'='innata-staff-profile/1' AND (staff_ability_profile->>'version')~'^[0-9]+$' AND jsonb_typeof(staff_ability_profile->'journal')='array' AND (staff_ability_profile->>'profile_key' IS NULL OR staff_ability_profile->>'profile_key' IN('aburame-l1','aburame-l2','aburame-l3','aburame-l4','akimichi-l1','akimichi-l2','akimichi-l3','akimichi-l4','hoki-l1','hoki-l2','hoki-l3','hoki-l4','byakugan-l1','byakugan-l2','byakugan-l3','byakugan-l4','inuzuka-l1','inuzuka-l2','inuzuka-l3','inuzuka-l4','marionettisti-l1','marionettisti-l2','marionettisti-l3','marionettisti-l4','nara-l1','nara-l2','nara-l3','nara-l4','sabaku-l1','sabaku-l2','sabaku-l3','sabaku-l4','sharingan-l1','sharingan-l2','sharingan-l3','sharingan-l4')));
ALTER TABLE clan_hyuga_private.staff_profiles DROP CONSTRAINT staff_profiles_profile_version_check;
ALTER TABLE clan_hyuga_private.staff_profiles ADD CONSTRAINT staff_profiles_profile_version_check CHECK(profile_version IN('byakugan-l1/1','byakugan-l2/1','byakugan-l3/1','byakugan-l4/1','sharingan-l1/1','sharingan-l2/1','sharingan-l3/1','sharingan-l4/1'));

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.catalog_v2() RETURNS jsonb
LANGUAGE sql IMMUTABLE SECURITY DEFINER SET search_path='' AS $f$
SELECT '[{"profile_key":"aburame-l1","technique_id":"94c45ec9-78c7-423e-9045-4b4cf2104b15","family":"aburame","tier":1,"clan_catalog":"Aburame","clan_product":"Aburame","catalog_name":"Insetti Parassiti Distruttivi","required_grade":"Genin","required_kg":30,"activation_cost":null,"upkeep_cost":null,"order":1,"lifecycle_kind":"passive_permission"},{"profile_key":"aburame-l2","technique_id":"d2d98dad-fb9f-4ff1-b6b2-3d3f2d222fae","family":"aburame","tier":2,"clan_catalog":"Aburame","clan_product":"Aburame","catalog_name":"Insetti Parassiti Distruttivi","required_grade":"Chunin","required_kg":50,"activation_cost":null,"upkeep_cost":null,"order":2,"lifecycle_kind":"passive_permission"},{"profile_key":"aburame-l3","technique_id":"6d264e00-1db3-4daa-b7cc-e5f011e1dab1","family":"aburame","tier":3,"clan_catalog":"Aburame","clan_product":"Aburame","catalog_name":"Insetti Parassiti Distruttivi","required_grade":"Jonin","required_kg":70,"activation_cost":null,"upkeep_cost":null,"order":3,"lifecycle_kind":"passive_permission"},{"profile_key":"aburame-l4","technique_id":"2fb3e027-a4ff-4058-9d5d-0212facb3f68","family":"aburame","tier":4,"clan_catalog":"Aburame","clan_product":"Aburame","catalog_name":"Insetti Parassiti Distruttivi","required_grade":"Jonin Speciale","required_kg":80,"activation_cost":null,"upkeep_cost":null,"order":4,"lifecycle_kind":"passive_permission"},{"profile_key":"akimichi-l1","technique_id":"bc2569b5-eab4-44b4-9843-c199724caff4","family":"akimichi","tier":1,"clan_catalog":"Akimichi","clan_product":"Akimichi","catalog_name":"Arte dell''Espansione","required_grade":"Genin","required_kg":30,"activation_cost":null,"upkeep_cost":null,"order":5,"lifecycle_kind":"passive_permission"},{"profile_key":"akimichi-l2","technique_id":"09097efd-e162-4cae-a644-5e643fe94f8c","family":"akimichi","tier":2,"clan_catalog":"Akimichi","clan_product":"Akimichi","catalog_name":"Arte dell''Espansione","required_grade":"Chunin","required_kg":50,"activation_cost":null,"upkeep_cost":null,"order":6,"lifecycle_kind":"passive_permission"},{"profile_key":"akimichi-l3","technique_id":"dd2026b4-bffc-490e-8646-be411d4746b3","family":"akimichi","tier":3,"clan_catalog":"Akimichi","clan_product":"Akimichi","catalog_name":"Arte dell''Espansione","required_grade":"Jonin","required_kg":70,"activation_cost":null,"upkeep_cost":null,"order":7,"lifecycle_kind":"passive_permission"},{"profile_key":"akimichi-l4","technique_id":"fdf79ce1-1c5b-44c4-aaa1-789be08e01de","family":"akimichi","tier":4,"clan_catalog":"Akimichi","clan_product":"Akimichi","catalog_name":"Arte dell''Espansione","required_grade":"Jonin Speciale","required_kg":80,"activation_cost":null,"upkeep_cost":null,"order":8,"lifecycle_kind":"passive_permission"},{"profile_key":"hoki-l1","technique_id":"ed808bc6-57f6-4853-80bf-9e6985ca0cc3","family":"hoki_dokugan","tier":1,"clan_catalog":"Dokugan","clan_product":"Hoki","catalog_name":"Corpo di Veleno e Occhio del Veleno","required_grade":"Genin","required_kg":30,"activation_cost":null,"upkeep_cost":null,"order":9,"lifecycle_kind":"passive_permission"},{"profile_key":"hoki-l2","technique_id":"41254b82-5b5e-46e9-9820-b3d604bbe38f","family":"hoki_dokugan","tier":2,"clan_catalog":"Dokugan","clan_product":"Hoki","catalog_name":"Corpo di Veleno e Occhio del Veleno","required_grade":"Chunin","required_kg":50,"activation_cost":null,"upkeep_cost":null,"order":10,"lifecycle_kind":"passive_permission"},{"profile_key":"hoki-l3","technique_id":"2fb9e210-225d-460a-a9f9-39ee64f8fce1","family":"hoki_dokugan","tier":3,"clan_catalog":"Dokugan","clan_product":"Hoki","catalog_name":"Corpo di Veleno e Occhio del Veleno","required_grade":"Jonin","required_kg":70,"activation_cost":null,"upkeep_cost":null,"order":11,"lifecycle_kind":"passive_permission"},{"profile_key":"hoki-l4","technique_id":"ab64415a-cca3-472f-9203-84ad60c09405","family":"hoki_dokugan","tier":4,"clan_catalog":"Dokugan","clan_product":"Hoki","catalog_name":"Corpo di Veleno e Occhio del Veleno","required_grade":"Jonin Speciale","required_kg":80,"activation_cost":null,"upkeep_cost":null,"order":12,"lifecycle_kind":"passive_permission"},{"profile_key":"byakugan-l1","technique_id":"4a527ff2-0420-4da9-bc1f-5489c753b285","family":"byakugan","tier":1,"clan_catalog":"Hyuga","clan_product":"Hyuga","catalog_name":"Byakugan","required_grade":"Genin","required_kg":30,"activation_cost":5,"upkeep_cost":5,"order":13,"lifecycle_kind":"maintained"},{"profile_key":"byakugan-l2","technique_id":"8e20bafe-cb3c-4967-b9c7-2a4bca694996","family":"byakugan","tier":2,"clan_catalog":"Hyuga","clan_product":"Hyuga","catalog_name":"Byakugan","required_grade":"Chunin","required_kg":50,"activation_cost":10,"upkeep_cost":10,"order":14,"lifecycle_kind":"maintained"},{"profile_key":"byakugan-l3","technique_id":"9b384de3-35f0-43c0-b145-94f985fa758a","family":"byakugan","tier":3,"clan_catalog":"Hyuga","clan_product":"Hyuga","catalog_name":"Byakugan","required_grade":"Jonin","required_kg":70,"activation_cost":15,"upkeep_cost":15,"order":15,"lifecycle_kind":"maintained"},{"profile_key":"byakugan-l4","technique_id":"a50808fa-e7cd-45ee-b4d4-33ad8c65d472","family":"byakugan","tier":4,"clan_catalog":"Hyuga","clan_product":"Hyuga","catalog_name":"Byakugan","required_grade":"Jonin Speciale","required_kg":80,"activation_cost":20,"upkeep_cost":20,"order":16,"lifecycle_kind":"maintained"},{"profile_key":"inuzuka-l1","technique_id":"b0748ef4-bea8-4d85-95a1-7d9db1b4381c","family":"inuzuka","tier":1,"clan_catalog":"Inuzuka","clan_product":"Inuzuka","catalog_name":"Simbiosi coi Ninken","required_grade":"Genin","required_kg":30,"activation_cost":null,"upkeep_cost":null,"order":17,"lifecycle_kind":"passive_permission"},{"profile_key":"inuzuka-l2","technique_id":"843031ac-521a-4c5b-832e-37a0398a9862","family":"inuzuka","tier":2,"clan_catalog":"Inuzuka","clan_product":"Inuzuka","catalog_name":"Simbiosi coi Ninken","required_grade":"Chunin","required_kg":50,"activation_cost":null,"upkeep_cost":null,"order":18,"lifecycle_kind":"passive_permission"},{"profile_key":"inuzuka-l3","technique_id":"537945fc-b7a3-4661-8144-e3fbcd6b24d0","family":"inuzuka","tier":3,"clan_catalog":"Inuzuka","clan_product":"Inuzuka","catalog_name":"Simbiosi coi Ninken","required_grade":"Jonin","required_kg":70,"activation_cost":null,"upkeep_cost":null,"order":19,"lifecycle_kind":"passive_permission"},{"profile_key":"inuzuka-l4","technique_id":"d48b7246-44bf-4ecc-a4dc-a9bb705c331a","family":"inuzuka","tier":4,"clan_catalog":"Inuzuka","clan_product":"Inuzuka","catalog_name":"Simbiosi coi Ninken","required_grade":"Jonin Speciale","required_kg":80,"activation_cost":null,"upkeep_cost":null,"order":20,"lifecycle_kind":"passive_permission"},{"profile_key":"marionettisti-l1","technique_id":"4d742b75-2592-4379-81c0-07ddf436f32b","family":"marionettisti","tier":1,"clan_catalog":"Marionettisti","clan_product":"Marionettisti","catalog_name":"Padronanza dei Fili e delle Marionette","required_grade":"Genin","required_kg":30,"activation_cost":null,"upkeep_cost":null,"order":21,"lifecycle_kind":"passive_permission"},{"profile_key":"marionettisti-l2","technique_id":"6e4b8efc-e324-404a-a8c7-b4c39b8070b8","family":"marionettisti","tier":2,"clan_catalog":"Marionettisti","clan_product":"Marionettisti","catalog_name":"Padronanza dei Fili e delle Marionette","required_grade":"Chunin","required_kg":50,"activation_cost":null,"upkeep_cost":null,"order":22,"lifecycle_kind":"passive_permission"},{"profile_key":"marionettisti-l3","technique_id":"559606f3-f3a0-401d-9e8c-7685624bb880","family":"marionettisti","tier":3,"clan_catalog":"Marionettisti","clan_product":"Marionettisti","catalog_name":"Padronanza dei Fili e delle Marionette","required_grade":"Jonin","required_kg":70,"activation_cost":null,"upkeep_cost":null,"order":23,"lifecycle_kind":"passive_permission"},{"profile_key":"marionettisti-l4","technique_id":"7fef3cc6-ec43-49a2-a740-cd9f4ee1c31a","family":"marionettisti","tier":4,"clan_catalog":"Marionettisti","clan_product":"Marionettisti","catalog_name":"Padronanza dei Fili e delle Marionette","required_grade":"Jonin Speciale","required_kg":80,"activation_cost":null,"upkeep_cost":null,"order":24,"lifecycle_kind":"passive_permission"},{"profile_key":"nara-l1","technique_id":"20341270-6241-45cd-9633-437d3ce80447","family":"nara","tier":1,"clan_catalog":"Nara","clan_product":"Nara","catalog_name":"Manipolazione dell''Ombra","required_grade":"Genin","required_kg":30,"activation_cost":null,"upkeep_cost":null,"order":25,"lifecycle_kind":"passive_permission"},{"profile_key":"nara-l2","technique_id":"32d0749c-6167-45da-8880-bb3f60dd401f","family":"nara","tier":2,"clan_catalog":"Nara","clan_product":"Nara","catalog_name":"Manipolazione dell''Ombra","required_grade":"Chunin","required_kg":50,"activation_cost":null,"upkeep_cost":null,"order":26,"lifecycle_kind":"passive_permission"},{"profile_key":"nara-l3","technique_id":"a4704025-1ef8-43c9-9e5b-113582a7e621","family":"nara","tier":3,"clan_catalog":"Nara","clan_product":"Nara","catalog_name":"Manipolazione dell''Ombra","required_grade":"Jonin","required_kg":70,"activation_cost":null,"upkeep_cost":null,"order":27,"lifecycle_kind":"passive_permission"},{"profile_key":"nara-l4","technique_id":"6c56bb2f-4936-4c43-873e-dde65fe42d2b","family":"nara","tier":4,"clan_catalog":"Nara","clan_product":"Nara","catalog_name":"Manipolazione dell''Ombra","required_grade":"Jonin Speciale","required_kg":80,"activation_cost":null,"upkeep_cost":null,"order":28,"lifecycle_kind":"passive_permission"},{"profile_key":"sabaku-l1","technique_id":"001f907c-8f32-4758-8a16-ad1730e72c59","family":"sabaku","tier":1,"clan_catalog":"Sabaku","clan_product":"Sabaku","catalog_name":"Controllo della Sabbia","required_grade":"Genin","required_kg":30,"activation_cost":5,"upkeep_cost":5,"order":29,"lifecycle_kind":"maintained"},{"profile_key":"sabaku-l2","technique_id":"e6cc70fa-7ef3-4eaf-afb7-4ca6f588c2b4","family":"sabaku","tier":2,"clan_catalog":"Sabaku","clan_product":"Sabaku","catalog_name":"Controllo della Sabbia","required_grade":"Chunin","required_kg":50,"activation_cost":null,"upkeep_cost":null,"order":30,"lifecycle_kind":"passive_permission"},{"profile_key":"sabaku-l3","technique_id":"efd15ad1-c1ae-4495-aaa5-0f9415f4be0a","family":"sabaku","tier":3,"clan_catalog":"Sabaku","clan_product":"Sabaku","catalog_name":"Controllo della Sabbia","required_grade":"Jonin","required_kg":70,"activation_cost":null,"upkeep_cost":null,"order":31,"lifecycle_kind":"passive_permission"},{"profile_key":"sabaku-l4","technique_id":"e0456437-21d5-4a04-9d8a-9bffbf87c26d","family":"sabaku","tier":4,"clan_catalog":"Sabaku","clan_product":"Sabaku","catalog_name":"Controllo della Sabbia","required_grade":"Jonin Speciale","required_kg":80,"activation_cost":null,"upkeep_cost":null,"order":32,"lifecycle_kind":"passive_permission"},{"profile_key":"sharingan-l1","technique_id":"4056f62d-77f3-47f9-8ecb-9a7799682a9d","family":"sharingan","tier":1,"clan_catalog":"Uchiha","clan_product":"Uchiha","catalog_name":"Sharingan","required_grade":"Genin","required_kg":30,"activation_cost":5,"upkeep_cost":5,"order":33,"lifecycle_kind":"maintained"},{"profile_key":"sharingan-l2","technique_id":"65b30dec-6f9f-459e-b78c-49173d74f251","family":"sharingan","tier":2,"clan_catalog":"Uchiha","clan_product":"Uchiha","catalog_name":"Sharingan","required_grade":"Chunin","required_kg":50,"activation_cost":10,"upkeep_cost":10,"order":34,"lifecycle_kind":"maintained"},{"profile_key":"sharingan-l3","technique_id":"f3673da7-42c9-497e-abe1-1c0982429f35","family":"sharingan","tier":3,"clan_catalog":"Uchiha","clan_product":"Uchiha","catalog_name":"Sharingan","required_grade":"Jonin","required_kg":70,"activation_cost":15,"upkeep_cost":15,"order":35,"lifecycle_kind":"maintained"},{"profile_key":"sharingan-l4","technique_id":"1ab6d359-f337-45ed-839c-4e626d2e2819","family":"sharingan","tier":4,"clan_catalog":"Uchiha","clan_product":"Uchiha","catalog_name":"Sharingan","required_grade":"Jonin Speciale","required_kg":80,"activation_cost":20,"upkeep_cost":20,"order":36,"lifecycle_kind":"maintained"}]'::jsonb
$f$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.profile_definition_v2(p_profile text) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE d jsonb;q clan_innata_narrative_private.config_quotes_v1;reason text;
BEGIN
 SELECT x INTO d FROM jsonb_array_elements(clan_innata_narrative_private.catalog_v2())x WHERE x->>'profile_key'=p_profile;
 IF d IS NULL THEN RAISE EXCEPTION 'INNATA_PROFILE_INVALID' USING ERRCODE='22023';END IF;
 IF NOT EXISTS(SELECT 1 FROM public.clan_techniques t WHERE t.id=(d->>'technique_id')::uuid AND t.is_active AND t.macro='clan'
   AND t.level=(d->>'tier')::integer AND t.clan=d->>'clan_catalog') THEN reason:='INNATA_PROFILE_CATALOG_UNAVAILABLE';END IF;
 IF NOT EXISTS(SELECT 1 FROM clan_innata_narrative_private.gate_v1 WHERE singleton AND staff_enabled)THEN reason:='INNATA_PROFILE_RUNTIME_UNAVAILABLE';END IF;
 IF d->>'lifecycle_kind'='maintained' AND reason IS NULL THEN
  BEGIN q:=clan_innata_narrative_private.quote_v1((d->>'technique_id')::uuid,false);
   IF q.activation_cost IS DISTINCT FROM (d->>'activation_cost')::integer OR q.upkeep_cost IS DISTINCT FROM (d->>'upkeep_cost')::integer
    THEN reason:='INNATA_PROFILE_QUOTE_UNAVAILABLE';END IF;
  EXCEPTION WHEN no_data_found OR insufficient_privilege OR data_exception THEN reason:='INNATA_PROFILE_QUOTE_UNAVAILABLE';END;
  IF(d->>'family'='sabaku'AND NOT EXISTS(SELECT 1 FROM clan_sabaku_private.release_gate WHERE singleton AND staff_enabled))
    OR(d->>'family'IN('byakugan','sharingan')AND NOT EXISTS(SELECT 1 FROM clan_hyuga_private.release_gate WHERE singleton AND staff_enabled))
  THEN reason:='INNATA_PROFILE_RUNTIME_UNAVAILABLE';END IF;
 END IF;
 RETURN d||jsonb_build_object('level',d->'tier','label',CASE WHEN d->>'family'='hoki_dokugan' THEN 'Dokugan' ELSE d->>'catalog_name' END,
   'name',CASE WHEN d->>'family'='hoki_dokugan' THEN 'Dokugan' ELSE d->>'catalog_name' END,'clan',d->'clan_product',
   'availability',CASE WHEN reason IS NULL THEN 'ready' ELSE 'unavailable' END,'reason_code',reason);
END;
$f$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.profile_definition_by_id_v2(p_technique uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE k text;
BEGIN SELECT x->>'profile_key'INTO k FROM jsonb_array_elements(clan_innata_narrative_private.catalog_v2())x WHERE x->>'technique_id'=p_technique::text;
 IF k IS NULL THEN RETURN NULL;END IF;RETURN clan_innata_narrative_private.profile_definition_v2(k);END;
$f$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.permission_fact_v2(p_context uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE c clan_innata_narrative_private.contexts_v1;d jsonb;f jsonb;
BEGIN
 SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE context_id=p_context;
 IF c.context_id IS NULL OR c.staff_ability_profile->>'profile_key'IS NULL THEN RETURN NULL;END IF;
 d:=clan_innata_narrative_private.profile_definition_v2(c.staff_ability_profile->>'profile_key');
 IF d->>'lifecycle_kind'<>'passive_permission' THEN RETURN NULL;END IF;
 f:=c.staff_ability_profile->'permission_fact';
 IF f IS NULL OR jsonb_typeof(f)IS DISTINCT FROM 'object'OR(SELECT count(*)FROM jsonb_object_keys(f))<>16
  OR NOT(f?&ARRAY['schema_version','receipt_id','owner_character_id','profile_key','family','tier','technique_id','profile_version','source_request','ruleset','eligible','capabilities_granted','resource_usage_authorized','values_written','preimage','sha256'])
  OR f->>'schema_version'<>'innata-permission-fact/1'OR f->>'owner_character_id'IS DISTINCT FROM c.character_id::text
  OR f->>'profile_key'IS DISTINCT FROM d->>'profile_key'OR f->>'family'IS DISTINCT FROM d->>'family'OR f->'tier'IS DISTINCT FROM d->'tier'
  OR f->'eligible'IS DISTINCT FROM 'true'::jsonb OR f->'capabilities_granted'IS DISTINCT FROM 'false'::jsonb
  OR f->'resource_usage_authorized'IS DISTINCT FROM 'false'::jsonb OR f->'values_written'IS DISTINCT FROM 'false'::jsonb
  OR f->>'technique_id'IS DISTINCT FROM d->>'technique_id' OR f->>'profile_version'IS DISTINCT FROM c.staff_ability_profile->>'version'
  OR f->>'ruleset'IS DISTINCT FROM 'innata-all-clan/2:5ab71c326bb0b150ed466bb2e6b76b8e9a83e6bdfe68198777d22ce7b47413b5' OR f->'preimage' IS NULL
  OR f->>'sha256'IS DISTINCT FROM public.combat_v2_sha256(f->'preimage') THEN
  RAISE EXCEPTION 'INNATA_PERMISSION_RECEIPT_INVALID' USING ERRCODE='42501';END IF;
 IF f->'preimage'IS DISTINCT FROM(f-ARRAY['preimage','sha256'])THEN RAISE EXCEPTION 'INNATA_PERMISSION_RECEIPT_INVALID' USING ERRCODE='42501';END IF;
 RETURN f;
END;
$f$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.profile_busy_reason_v2(p_context uuid) RETURNS text
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE c clan_innata_narrative_private.contexts_v1;ids uuid[];
BEGIN
 SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE context_id=p_context;
 IF c.context_id IS NULL THEN RETURN NULL;END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions s JOIN public.combat_v2_actors a ON a.session_id=s.id WHERE a.character_id=c.character_id AND s.closed_at IS NULL)
 THEN RETURN 'INNATA_PROFILE_COMBAT_ACTIVE';END IF;
 IF EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources x WHERE x.owner_character_id=c.character_id AND x.state<>'ended')
 OR EXISTS(SELECT 1 FROM clan_marionettisti_private.links x JOIN public.combat_v2_actors a ON a.id=x.owner_actor_id WHERE a.character_id=c.character_id AND x.state='connected')
 THEN RETURN 'INNATA_PROFILE_SOURCE_BUSY';END IF;
 ids:=coalesce(clan_innata_narrative_private.staff_profile_active_ids_v1(c.context_id),'{}'::uuid[]);
 IF cardinality(ids)>0 THEN RETURN 'INNATA_PROFILE_ACTIVE';END IF;RETURN NULL;
END;
$f$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.profile_state_core_v2(p_location uuid,p_master_session uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.characters;c clan_innata_narrative_private.contexts_v1;d jsonb;pr jsonb:='[]'::jsonb;
 rowdoc jsonb;chosen jsonb;lifecycle jsonb;ids uuid[];suppressed jsonb;reason text;phase text;
BEGIN
 SELECT * INTO STRICT a FROM public.characters WHERE user_id=auth.uid();
 PERFORM clan_innata_narrative_private.staff_profile_authorize_v1(p_location,p_master_session,a.id);
 SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE character_id=a.id AND location_id=p_location ORDER BY created_at DESC,context_id DESC LIMIT 1;
 FOR rowdoc IN SELECT value FROM jsonb_array_elements(clan_innata_narrative_private.catalog_v2())ORDER BY(value->>'order')::integer LOOP
  rowdoc:=clan_innata_narrative_private.profile_definition_v2(rowdoc->>'profile_key');
  IF p_master_session IS NOT NULL AND rowdoc->>'lifecycle_kind'='maintained' AND rowdoc->>'family'IN('byakugan','sharingan')
   AND NOT EXISTS(SELECT 1 FROM clan_hyuga_private.release_gate WHERE singleton AND staff_enabled AND master_enabled)
  THEN rowdoc:=rowdoc||jsonb_build_object('availability','unavailable','reason_code','INNATA_PROFILE_MASTER_UNAVAILABLE');END IF;
  pr:=pr||jsonb_build_array(jsonb_build_object('profile_key',rowdoc->'profile_key','label',rowdoc->'label',
   'technique_id',rowdoc->'technique_id','level',rowdoc->'level','activation_cost',rowdoc->'activation_cost','upkeep_cost',rowdoc->'upkeep_cost',
   'required_grade',rowdoc->'required_grade','required_kg',rowdoc->'required_kg','lifecycle_kind',rowdoc->'lifecycle_kind','availability',rowdoc->'availability','reason_code',rowdoc->'reason_code'));
 END LOOP;
 ids:=coalesce(clan_innata_narrative_private.staff_profile_active_ids_v1(c.context_id),'{}'::uuid[]);
 IF c.staff_ability_profile->>'profile_key'IS NOT NULL THEN
  d:=clan_innata_narrative_private.profile_definition_v2(c.staff_ability_profile->>'profile_key');
  SELECT q->>'reason_code'INTO reason FROM jsonb_array_elements(pr)q WHERE q->>'profile_key'=d->>'profile_key';
  SELECT coalesce(jsonb_agg(id ORDER BY id),'[]'::jsonb)INTO suppressed FROM(
   SELECT(x->>'technique_id')::uuid id FROM jsonb_array_elements(clan_innata_narrative_private.catalog_v2())x
   UNION SELECT t.id FROM public.clan_techniques t JOIN public.character_abilities ca ON ca.technique_id=t.id AND ca.character_id=a.id AND ca.state='attiva'WHERE t.is_active AND t.is_innata)u
  WHERE id<>(d->>'technique_id')::uuid;
  chosen:=jsonb_build_object('technique_id',d->'technique_id','name',d->'name','level',d->'level','clan',d->'clan','chakra_cost',d->'activation_cost',
   'consumption_type',CASE WHEN d->>'lifecycle_kind'='passive_permission' THEN 'passiva' ELSE 'per_turno' END,'state','attiva','is_simulated',true,'suppressed_innata_ids',suppressed);
  IF reason IS NOT NULL THEN phase:='unavailable';
  ELSIF d->>'lifecycle_kind'='passive_permission' THEN
   IF clan_innata_narrative_private.permission_fact_v2(c.context_id)IS NULL THEN phase:='unavailable';reason:='INNATA_PERMISSION_RECEIPT_REQUIRED';ELSE phase:='eligible';END IF;
  ELSE phase:=CASE WHEN (d->>'technique_id')::uuid=ANY(ids)THEN 'on'ELSE 'off'END;END IF;
  lifecycle:=jsonb_build_object('kind',d->'lifecycle_kind','phase',phase,'reason_code',reason);
 END IF;
 reason:=clan_innata_narrative_private.profile_busy_reason_v2(c.context_id);
 RETURN jsonb_build_object('schema_version','innata-staff-profile-state/2','location_id',p_location,'master_session_id',p_master_session,'character_id',a.id,
  'context_id',CASE WHEN c.active AND c.scope_key=coalesce(p_master_session,p_location)THEN c.context_id ELSE NULL END,
  'profile_version',coalesce((c.staff_ability_profile->>'version')::bigint,0),'selected_profile',c.staff_ability_profile->'profile_key','selected_ability',chosen,
  'innata_active',coalesce(lifecycle->>'kind'='maintained'AND lifecycle->>'phase'='on',false),
  'can_change',reason IS NULL OR(reason='INNATA_PROFILE_ACTIVE'AND c.staff_ability_profile->>'profile_key'IS NULL),'reason',reason,'profiles',pr,'selected_lifecycle',lifecycle);
END;
$f$;

CREATE OR REPLACE FUNCTION public.clan_innata_staff_profile_state_v2(p_location uuid,p_master_session uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
SELECT clan_innata_narrative_private.profile_state_core_v2(p_location,p_master_session)
$f$;

CREATE OR REPLACE FUNCTION public.clan_innata_staff_profile_set_v2(p_location uuid,p_master_session uuid,p_profile_key text,p_request_key uuid,p_expected_version bigint) RETURNS jsonb
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.characters;c clan_innata_narrative_private.contexts_v1;d jsonb;fp text;prior jsonb;doc jsonb;outcome jsonb;sc jsonb;ids uuid[];reason text;fact jsonb;
BEGIN
 SELECT * INTO STRICT a FROM public.characters WHERE user_id=auth.uid();
 PERFORM clan_innata_narrative_private.staff_profile_authorize_v1(p_location,p_master_session,a.id);
 IF p_request_key IS NULL OR p_expected_version IS NULL OR p_expected_version<0 THEN RAISE EXCEPTION 'INNATA_PROFILE_INVALID' USING ERRCODE='22023';END IF;
 fp:=public.combat_v2_sha256(jsonb_build_object('api','innata-staff-profile/2','ruleset','innata-all-clan/2:5ab71c326bb0b150ed466bb2e6b76b8e9a83e6bdfe68198777d22ce7b47413b5','character',a.id,'location',p_location,
   'master',p_master_session,'profile',p_profile_key,'expected_version',p_expected_version));
 PERFORM 1 FROM public.locations WHERE id=p_location FOR UPDATE;
 PERFORM pg_advisory_xact_lock(hashtextextended('innata-narrative:'||a.id::text,0));
 SELECT e INTO prior FROM clan_innata_narrative_private.contexts_v1 x CROSS JOIN LATERAL jsonb_array_elements(x.staff_ability_profile->'journal')e
  WHERE x.character_id=a.id AND x.location_id=p_location AND e->>'request_key'=p_request_key::text ORDER BY x.created_at DESC LIMIT 1;
 IF prior IS NOT NULL THEN IF prior->>'fingerprint'IS DISTINCT FROM fp THEN RAISE EXCEPTION 'INNATA_PROFILE_REQUEST_CONFLICT' USING ERRCODE='22023';END IF;
  RETURN(prior->'result')||jsonb_build_object('replayed',true);END IF;
 IF p_profile_key IS NOT NULL THEN
  d:=clan_innata_narrative_private.profile_definition_v2(p_profile_key);
  IF d->>'availability'<>'ready'THEN RAISE EXCEPTION '%',d->>'reason_code' USING ERRCODE='42501';END IF;
 END IF;
 sc:=clan_innata_narrative_private.scope_v1(p_location,p_master_session,a.id);
 IF sc->>'allowed'IS DISTINCT FROM 'true'THEN RAISE EXCEPTION '%',sc->>'reason' USING ERRCODE='55000';END IF;
 c:=clan_innata_narrative_private.ensure_context_v1(a.id,p_location,p_master_session,NULL);
 IF(c.staff_ability_profile->>'version')::bigint<>p_expected_version THEN RAISE EXCEPTION 'INNATA_PROFILE_STATE_CHANGED' USING ERRCODE='40001';END IF;
 reason:=clan_innata_narrative_private.profile_busy_reason_v2(c.context_id);
 ids:=coalesce(clan_innata_narrative_private.staff_profile_active_ids_v1(c.context_id),'{}'::uuid[]);
 IF reason IS NOT NULL AND NOT(reason='INNATA_PROFILE_ACTIVE'AND p_profile_key IS NOT NULL AND d->>'lifecycle_kind'='maintained'
    AND NOT EXISTS(SELECT 1 FROM unnest(ids)i WHERE i IS DISTINCT FROM(d->>'technique_id')::uuid))
 THEN RAISE EXCEPTION '%',reason USING ERRCODE='55000';END IF;
 doc:=(c.staff_ability_profile-'permission_fact')||jsonb_build_object('version',p_expected_version+1,'profile_key',p_profile_key,'created_by',auth.uid(),'ruleset','innata-all-clan/2:5ab71c326bb0b150ed466bb2e6b76b8e9a83e6bdfe68198777d22ce7b47413b5');
 IF d->>'lifecycle_kind'='passive_permission' THEN
  fact:=jsonb_build_object('schema_version','innata-permission-fact/1','receipt_id',extensions.uuid_generate_v5(p_request_key,'innata-permission-fact/1'),
   'owner_character_id',a.id,'profile_key',p_profile_key,'family',d->'family','tier',d->'level','technique_id',d->'technique_id',
   'profile_version',p_expected_version+1,'source_request',p_request_key,'ruleset','innata-all-clan/2:5ab71c326bb0b150ed466bb2e6b76b8e9a83e6bdfe68198777d22ce7b47413b5','eligible',true,'capabilities_granted',false,'resource_usage_authorized',false,'values_written',false);
  fact:=fact||jsonb_build_object('preimage',fact,'sha256',public.combat_v2_sha256(fact));doc:=doc||jsonb_build_object('permission_fact',fact);
 END IF;
 UPDATE clan_innata_narrative_private.contexts_v1 SET staff_ability_profile=doc WHERE context_id=c.context_id;
 outcome:=clan_innata_narrative_private.profile_state_core_v2(p_location,p_master_session)||jsonb_build_object('schema_version','innata-staff-profile-receipt/2','request_key',p_request_key,'replayed',false);
 doc:=jsonb_set(doc,'{journal}',(doc->'journal')||jsonb_build_array(jsonb_build_object('request_key',p_request_key,'fingerprint',fp,'api_version',2,'ruleset','innata-all-clan/2:5ab71c326bb0b150ed466bb2e6b76b8e9a83e6bdfe68198777d22ce7b47413b5','result',outcome)),false);
 UPDATE clan_innata_narrative_private.contexts_v1 SET staff_ability_profile=doc WHERE context_id=c.context_id;RETURN outcome;
END;
$f$;

CREATE OR REPLACE FUNCTION public.clan_innata_staff_profile_state_v1(p_location uuid, p_master_session uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.characters;c clan_innata_narrative_private.contexts_v1;d jsonb;pr jsonb;chosen jsonb;blocked boolean;ids uuid[];suppressed jsonb;
BEGIN
 SELECT * INTO STRICT a FROM public.characters WHERE user_id=auth.uid();
 PERFORM clan_innata_narrative_private.staff_profile_authorize_v1(p_location,p_master_session,a.id);
 -- The latest protected chain is authoritative across ordinary and Master scopes.
 SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE character_id=a.id AND location_id=p_location
 ORDER BY created_at DESC,context_id DESC LIMIT 1;
 IF c.staff_ability_profile->>'profile_key'IS NOT NULL AND c.staff_ability_profile->>'profile_key' NOT IN('sabaku-l1','sharingan-l1','byakugan-l1','byakugan-l2','byakugan-l3','byakugan-l4') THEN RAISE EXCEPTION 'INNATA_PROFILE_CONSUMER_UPGRADE_REQUIRED' USING ERRCODE='42501';END IF;
 SELECT jsonb_agg(x.d-ARRAY['name','clan']ORDER BY x.ord)INTO pr FROM unnest(ARRAY['sabaku-l1','sharingan-l1','byakugan-l1','byakugan-l2','byakugan-l3','byakugan-l4'])WITH ORDINALITY k(key,ord)
 CROSS JOIN LATERAL(SELECT clan_innata_narrative_private.staff_profile_definition_v1(k.key)d,k.ord)x;
 IF c.staff_ability_profile->>'profile_key'IS NOT NULL THEN
  d:=clan_innata_narrative_private.staff_profile_definition_v1(c.staff_ability_profile->>'profile_key');
  SELECT coalesce(jsonb_agg(id ORDER BY id),'[]'::jsonb)INTO suppressed FROM(
  SELECT t.id FROM public.clan_techniques t JOIN public.character_abilities ca ON ca.technique_id=t.id AND ca.character_id=a.id AND ca.state='attiva'WHERE t.is_active AND t.is_innata
  UNION SELECT(q->>'technique_id')::uuid FROM jsonb_array_elements(pr)q)u WHERE id<>(d->>'technique_id')::uuid;
  chosen:=jsonb_build_object('technique_id',d->'technique_id','name',d->'name','level',d->'level','clan',d->'clan','chakra_cost',d->'activation_cost',
  'consumption_type','per_turno','state','attiva','is_simulated',true,'suppressed_innata_ids',suppressed);
 END IF;
 ids:=coalesce(clan_innata_narrative_private.staff_profile_active_ids_v1(c.context_id),'{}'::uuid[]);
 blocked:=EXISTS(SELECT 1 FROM public.combat_v2_sessions s JOIN public.combat_v2_actors x ON x.session_id=s.id WHERE x.character_id=a.id AND s.closed_at IS NULL);
 RETURN jsonb_build_object('schema_version','innata-staff-profile-state/1','location_id',p_location,'master_session_id',p_master_session,'character_id',a.id,
 'context_id',CASE WHEN c.active AND c.scope_key=coalesce(p_master_session,p_location)THEN c.context_id ELSE NULL END,'profile_version',coalesce((c.staff_ability_profile->>'version')::bigint,0),'selected_profile',c.staff_ability_profile->'profile_key','selected_ability',chosen,
 'innata_active',cardinality(ids)>0,'can_change',NOT blocked AND(cardinality(ids)=0 OR c.staff_ability_profile->>'profile_key'IS NULL),
 'reason',CASE WHEN blocked THEN 'INNATA_PROFILE_COMBAT_ACTIVE'WHEN cardinality(ids)>0 THEN 'INNATA_PROFILE_ACTIVE'END,'profiles',pr);
END $function$;

CREATE OR REPLACE FUNCTION public.clan_innata_staff_profile_set_v1(p_location uuid, p_master_session uuid, p_profile_key text, p_request_key uuid, p_expected_version bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.characters;c clan_innata_narrative_private.contexts_v1;d jsonb;fp text;prior jsonb;doc jsonb;outcome jsonb;sc jsonb;ids uuid[];
BEGIN
 SELECT * INTO STRICT a FROM public.characters WHERE user_id=auth.uid();
 PERFORM clan_innata_narrative_private.staff_profile_authorize_v1(p_location,p_master_session,a.id);
 IF p_request_key IS NULL OR p_expected_version IS NULL OR p_expected_version<0 THEN RAISE EXCEPTION 'INNATA_PROFILE_INVALID' USING ERRCODE='22023';END IF;
 IF p_profile_key IS NOT NULL THEN d:=clan_innata_narrative_private.staff_profile_definition_v1(p_profile_key);END IF;
 fp:=public.combat_v2_sha256(jsonb_build_object('character',a.id,'location',p_location,'master',p_master_session,'profile',p_profile_key,'expected_version',p_expected_version));
 PERFORM 1 FROM public.locations WHERE id=p_location FOR UPDATE;
 PERFORM pg_advisory_xact_lock(hashtextextended('innata-narrative:'||a.id::text,0));
 SELECT e INTO prior FROM clan_innata_narrative_private.contexts_v1 x CROSS JOIN LATERAL jsonb_array_elements(x.staff_ability_profile->'journal')e
 WHERE x.character_id=a.id AND x.location_id=p_location AND e->>'request_key'=p_request_key::text ORDER BY x.created_at DESC LIMIT 1;
 IF prior IS NOT NULL THEN IF prior->>'fingerprint'IS DISTINCT FROM fp THEN RAISE EXCEPTION 'INNATA_PROFILE_REQUEST_CONFLICT' USING ERRCODE='22023';END IF;RETURN(prior->'result')||jsonb_build_object('replayed',true);END IF;
 SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE character_id=a.id AND location_id=p_location ORDER BY created_at DESC,context_id DESC LIMIT 1;
 IF c.staff_ability_profile->>'profile_key'IS NOT NULL AND c.staff_ability_profile->>'profile_key' NOT IN('sabaku-l1','sharingan-l1','byakugan-l1','byakugan-l2','byakugan-l3','byakugan-l4') THEN RAISE EXCEPTION 'INNATA_PROFILE_CONSUMER_UPGRADE_REQUIRED' USING ERRCODE='42501';END IF;
 IF clan_innata_narrative_private.profile_busy_reason_v2(c.context_id)='INNATA_PROFILE_SOURCE_BUSY'THEN RAISE EXCEPTION 'INNATA_PROFILE_SOURCE_BUSY' USING ERRCODE='55000';END IF;
 sc:=clan_innata_narrative_private.scope_v1(p_location,p_master_session,a.id);
 IF sc->>'allowed'IS DISTINCT FROM 'true'THEN RAISE EXCEPTION '%',sc->>'reason' USING ERRCODE='55000';END IF;
 c:=clan_innata_narrative_private.ensure_context_v1(a.id,p_location,p_master_session,NULL);
 IF(c.staff_ability_profile->>'version')::bigint<>p_expected_version THEN RAISE EXCEPTION 'INNATA_PROFILE_STATE_CHANGED' USING ERRCODE='40001';END IF;
 ids:=coalesce(clan_innata_narrative_private.staff_profile_active_ids_v1(c.context_id),'{}'::uuid[]);
 IF cardinality(ids)>0 AND(p_profile_key IS NULL OR EXISTS(SELECT 1 FROM unnest(ids)i WHERE i IS DISTINCT FROM(d->>'technique_id')::uuid))
 THEN RAISE EXCEPTION 'INNATA_PROFILE_ACTIVE' USING ERRCODE='55000';END IF;
 doc:=c.staff_ability_profile||jsonb_build_object('version',p_expected_version+1,'profile_key',p_profile_key,'created_by',auth.uid());
 UPDATE clan_innata_narrative_private.contexts_v1 SET staff_ability_profile=doc WHERE context_id=c.context_id;
 outcome:=public.clan_innata_staff_profile_state_v1(p_location,p_master_session)||jsonb_build_object('schema_version','innata-staff-profile-receipt/1','request_key',p_request_key,'replayed',false);
 doc:=jsonb_set(doc,'{journal}',(doc->'journal')||jsonb_build_array(jsonb_build_object('request_key',p_request_key,'fingerprint',fp,'result',outcome)),false);
 UPDATE clan_innata_narrative_private.contexts_v1 SET staff_ability_profile=doc WHERE context_id=c.context_id;
 RETURN outcome;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.staff_profile_for_character_v1(p_location uuid, p_master uuid, p_character uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c clan_innata_narrative_private.contexts_v1;
BEGIN
 IF p_location IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid OR auth.uid()IS NULL OR NOT public.is_staff()
 OR NOT EXISTS(SELECT 1 FROM public.characters WHERE id=p_character AND user_id=auth.uid())
 OR NOT EXISTS(SELECT 1 FROM clan_innata_narrative_private.gate_v1 WHERE singleton AND staff_enabled)THEN RETURN NULL;END IF;
 IF p_master IS NULL THEN SELECT ms.id INTO p_master FROM public.master_v2_sessions ms JOIN public.master_v2_participants mp ON mp.session_id=ms.id AND mp.character_id=p_character AND mp.user_id_snapshot=auth.uid()AND mp.left_at IS NULL AND mp.engagement_state='attivo' WHERE ms.location_id=p_location AND ms.closed_at IS NULL ORDER BY ms.created_at DESC LIMIT 1;END IF;
 SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE character_id=p_character AND location_id=p_location
 ORDER BY created_at DESC,context_id DESC LIMIT 1;
 IF c.context_id IS NULL OR c.staff_ability_profile->>'profile_key'IS NULL OR c.staff_ability_profile->>'created_by'IS DISTINCT FROM auth.uid()::text THEN RETURN NULL;END IF;
 IF p_master IS NOT NULL AND (clan_innata_narrative_private.profile_definition_v2(c.staff_ability_profile->>'profile_key')->>'family')IN('byakugan','sharingan')
 AND NOT EXISTS(SELECT 1 FROM clan_hyuga_private.release_gate WHERE singleton AND staff_enabled AND master_enabled)
 THEN RAISE EXCEPTION 'INNATA_PROFILE_RUNTIME_UNAVAILABLE' USING ERRCODE='42501';END IF;
 RETURN clan_innata_narrative_private.profile_definition_v2(c.staff_ability_profile->>'profile_key');
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.command_admitted_v1(p_location uuid, p_character uuid, p_technique uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT CASE WHEN clan_innata_narrative_private.staff_profile_for_character_v1(p_location,NULL::uuid,p_character)IS NOT NULL THEN
 (clan_innata_narrative_private.staff_profile_for_character_v1(p_location,NULL::uuid,p_character)->>'lifecycle_kind')='maintained' AND p_technique=(clan_innata_narrative_private.staff_profile_for_character_v1(p_location,NULL::uuid,p_character)->>'technique_id')::uuid
 ELSE(EXISTS(SELECT 1 FROM clan_innata_narrative_private.config_quotes_v1 q
  JOIN public.character_abilities ca ON ca.technique_id=q.technique_id AND ca.character_id=p_character AND ca.state='attiva'
  JOIN public.characters a ON a.id=ca.character_id AND a.user_id=auth.uid()
  JOIN public.clan_techniques t ON t.id=q.technique_id AND t.is_active AND t.is_innata
  JOIN public.locations l ON l.id=p_location AND l.is_active
  CROSS JOIN clan_innata_narrative_private.gate_v1 g
  WHERE q.technique_id=p_technique AND g.singleton
   AND public._grade_rank(a.rank)>=public._grade_rank(t.req_grade)
   AND((l.is_test AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND public._puo_test_room()AND g.staff_enabled)
     OR(NOT l.is_test AND g.public_enabled))))END
$function$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.activate_v1(p_location uuid, p_master_session uuid, p_character uuid, p_technique_id uuid, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.characters;scope jsonb;q clan_innata_narrative_private.config_quotes_v1;c clan_innata_narrative_private.contexts_v1;
 old clan_innata_narrative_private.receipts_v1;fp text;st clan_innata_narrative_private.states_v1;sv bigint;act boolean;cost integer:=0;
 authority uuid;receipt uuid;preimage jsonb;h text;native_result jsonb;result jsonb;flag text;
 p_desired_state boolean:=true;p_expected_version bigint;sim_profile jsonb;
BEGIN
 IF auth.uid()IS NULL THEN RAISE EXCEPTION 'INNATA_AUTH_REQUIRED' USING ERRCODE='42501';END IF;
 IF p_location IS NULL OR p_character IS NULL OR p_technique_id IS NULL OR p_request_key IS NULL
 THEN RAISE EXCEPTION 'INNATA_REQUEST_INVALID' USING ERRCODE='22023';END IF;
 SELECT * INTO STRICT a FROM public.characters WHERE id=p_character AND user_id=auth.uid();
 fp:=public.combat_v2_sha256(jsonb_build_object('actor',a.id,'location',p_location,'master',p_master_session,
  'technique',p_technique_id,'desired',p_desired_state));
 IF p_master_session IS NOT NULL AND EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE id=p_master_session AND owner_kind='human')
  THEN PERFORM 1 FROM public.master_v2_sessions WHERE id=p_master_session FOR UPDATE;END IF;
 PERFORM 1 FROM public.locations WHERE id=p_location FOR UPDATE;
 PERFORM pg_advisory_xact_lock(hashtextextended('innata-narrative:'||a.id::text,0));
 SELECT * INTO old FROM clan_innata_narrative_private.receipts_v1 WHERE character_id=a.id AND request_key=p_request_key;
 IF FOUND THEN
  IF old.fingerprint<>fp THEN RAISE EXCEPTION 'INNATA_REQUEST_CONFLICT' USING ERRCODE='22023';END IF;
  RETURN old.result||jsonb_build_object('replayed',true);
 END IF;
 scope:=clan_innata_narrative_private.scope_v1(p_location,p_master_session,a.id);
 IF(scope->>'allowed')::boolean IS DISTINCT FROM true THEN RAISE EXCEPTION '%',scope->>'reason' USING ERRCODE='55000';END IF;
 q:=clan_innata_narrative_private.quote_v1(p_technique_id,NOT(scope->>'is_test')::boolean);
 sim_profile:=clan_innata_narrative_private.staff_profile_for_character_v1(p_location,p_master_session,a.id);
 IF(scope->>'is_test')::boolean AND sim_profile IS NOT NULL THEN
  IF sim_profile->>'lifecycle_kind'<>'maintained'THEN RAISE EXCEPTION 'INNATA_PASSIVE_NOT_ACTIVATABLE' USING ERRCODE='42501';END IF;
  IF p_technique_id IS DISTINCT FROM(sim_profile->>'technique_id')::uuid THEN RAISE EXCEPTION 'INNATA_PROFILE_INVALID' USING ERRCODE='42501';END IF;
 ELSE
 IF NOT EXISTS(SELECT 1 FROM public.character_abilities ca JOIN public.clan_techniques t ON t.id=ca.technique_id
  WHERE ca.character_id=a.id AND ca.technique_id=q.technique_id AND ca.state='attiva'AND t.is_active AND t.is_innata AND(t.level=1 OR t.id IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid))
   AND public._grade_rank(a.rank)>=public._grade_rank(t.req_grade))
 THEN RAISE EXCEPTION 'INNATA_NOT_OWNED' USING ERRCODE='42501';END IF;
 IF p_technique_id IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid)AND NOT clan_innata_narrative_private.byakugan_owned_v1(a.id,p_technique_id)
 THEN RAISE EXCEPTION 'BYAKUGAN_NOT_OWNED' USING ERRCODE='42501';END IF;
 END IF;
 PERFORM clan_innata_private.assert_no_combat_authority(a.id,p_technique_id);
 IF(scope->>'is_test')::boolean THEN
  c:=clan_innata_narrative_private.ensure_context_v1(a.id,p_location,p_master_session,NULL);
  IF EXISTS(SELECT 1 FROM clan_innata_narrative_private.byakugan_catalog_v1 WHERE technique_id=p_technique_id)
  AND EXISTS(SELECT 1 FROM clan_innata_narrative_private.states_v1 protected74
   JOIN clan_innata_narrative_private.byakugan_catalog_v1 tier74 ON tier74.technique_id=protected74.technique_id
   WHERE protected74.context_id=c.context_id AND protected74.active AND protected74.technique_id<>p_technique_id)
  THEN RAISE EXCEPTION 'BYAKUGAN_FAMILY_ALREADY_ACTIVE' USING ERRCODE='55000';END IF;
  INSERT INTO clan_innata_narrative_private.states_v1(context_id,technique_id)VALUES(c.context_id,p_technique_id)
   ON CONFLICT(context_id,technique_id)DO NOTHING;
  SELECT * INTO STRICT st FROM clan_innata_narrative_private.states_v1 WHERE context_id=c.context_id AND technique_id=p_technique_id FOR UPDATE;
  p_expected_version:=st.state_version;
  IF st.active IS DISTINCT FROM p_desired_state THEN
   IF p_desired_state THEN cost:=q.activation_cost;END IF;
   IF c.chakra<cost THEN RAISE EXCEPTION 'INNATA_INSUFFICIENT_CHAKRA' USING ERRCODE='22023';END IF;
   UPDATE clan_innata_narrative_private.contexts_v1 SET chakra=chakra-cost WHERE context_id=c.context_id RETURNING * INTO c;
   UPDATE clan_innata_narrative_private.states_v1 SET active=p_desired_state,state_version=state_version+1
    WHERE context_id=c.context_id AND technique_id=p_technique_id RETURNING * INTO st;
  END IF;
  act:=st.active;sv:=st.state_version;receipt:=gen_random_uuid();
 ELSE
  SELECT coalesce((SELECT state_version FROM clan_innata_private.actor_state WHERE actor_id=a.id AND technique_id=p_technique_id),0)INTO p_expected_version;
  authority:=gen_random_uuid();receipt:=gen_random_uuid();
  preimage:=jsonb_build_object('actor_id',a.id,'technique_id',p_technique_id,'session_id',coalesce(p_master_session,p_location),
   'purpose','innata_l1_activation','authority_version',1);h:=public.combat_v2_sha256(preimage);
  INSERT INTO clan_innata_private.narrative_authorities(authority_id,actor_id,technique_id,session_id,purpose,authority_version,canonical_preimage,authority_sha256,active)
   VALUES(authority,a.id,p_technique_id,coalesce(p_master_session,p_location),'innata_l1_activation',1,preimage,h,true);
  INSERT INTO clan_innata_private.narrative_receipts(receipt_id,actor_id,technique_id,session_id,purpose,authority_id,authority_sha256,active)
   VALUES(receipt,a.id,p_technique_id,coalesce(p_master_session,p_location),'innata_l1_activation',authority,h,true);
  flag:=current_setting('app.allow_chakra_delta',true);PERFORM set_config('app.allow_chakra_delta','1',true);
  native_result:=clan_innata_private.state_set_core(a.id,p_technique_id,p_desired_state,p_request_key,p_expected_version,'authorized_narrative',receipt);
  PERFORM set_config('app.allow_chakra_delta',coalesce(flag,''),true);
  UPDATE clan_innata_private.narrative_receipts SET consumed_request_key=p_request_key,consumed_at=coalesce(consumed_at,clock_timestamp()),active=false
   WHERE receipt_id=receipt AND(consumed_request_key IS NULL OR consumed_request_key=p_request_key);
  IF NOT FOUND THEN RAISE EXCEPTION 'INNATA_RECEIPT_CHANGED' USING ERRCODE='40001';END IF;
  UPDATE clan_innata_private.narrative_authorities SET active=false WHERE authority_id=authority;
  act:=(native_result->>'active')::boolean;sv:=(native_result->>'state_version')::bigint;cost:=(native_result->>'chakra_spent')::integer;
  SELECT chakra INTO a.chakra FROM public.characters WHERE id=a.id;
 END IF;
 result:=jsonb_build_object('schema_version','innata-narrative-command/1','request_key',p_request_key,'character_id',a.id,
  'location_id',p_location,'master_session_id',p_master_session,'technique_id',p_technique_id,'active',act,'state_version',sv,
  'chakra_spent',cost,'chakra_balance',CASE WHEN(scope->>'is_test')::boolean THEN c.chakra ELSE a.chakra END,
  'is_test',(scope->>'is_test')::boolean,'values_written',NOT(scope->>'is_test')::boolean AND cost>0,
  'main_action_consumed',false,'source_receipt_id',receipt,'replayed',false);
 INSERT INTO clan_innata_narrative_private.receipts_v1(character_id,request_key,fingerprint,context_id,is_test,result)
  VALUES(a.id,p_request_key,fp,c.context_id,(scope->>'is_test')::boolean,result);
 RETURN result;
END $function$;

DO $quotes$
DECLARE d jsonb;p jsonb;seal text;q clan_innata_narrative_private.config_quotes_v1;c clan_innata_private.config_versions;
BEGIN
 FOR d IN SELECT x FROM jsonb_array_elements(clan_innata_narrative_private.catalog_v2())x WHERE x->>'family'='sharingan'AND(x->>'tier')::integer>1 LOOP
  IF NOT EXISTS(SELECT 1 FROM public.clan_techniques t WHERE t.id=(d->>'technique_id')::uuid AND t.is_active AND t.is_innata AND t.clan='Uchiha'
    AND t.level=(d->>'tier')::integer AND t.chakra_cost=(d->>'activation_cost')::integer AND t.consumption_type='per_turno')
  THEN RAISE EXCEPTION 'SHARINGAN_CATALOG_DRIFT' USING ERRCODE='42501';END IF;
  p:=jsonb_build_object('technique_id',(d->>'technique_id')::uuid,'config_version',1,'activation_cost',(d->>'activation_cost')::integer,'upkeep_cost',(d->>'upkeep_cost')::integer);seal:=public.combat_v2_sha256(p);
  SELECT * INTO c FROM clan_innata_private.config_versions WHERE technique_id=(d->>'technique_id')::uuid;
  IF FOUND AND(c.config_version,c.activation_cost,c.upkeep_cost,c.editorial_seal,c.reviewed,c.active)IS DISTINCT FROM(1,(d->>'activation_cost')::integer,(d->>'upkeep_cost')::integer,seal,true,true)
  THEN RAISE EXCEPTION 'SHARINGAN_CONFIG_DRIFT' USING ERRCODE='42501';END IF;
  IF EXISTS(SELECT 1 FROM clan_innata_private.editorial_approvals a WHERE a.technique_id=(d->>'technique_id')::uuid AND(a.config_version<>1 OR a.canonical_preimage IS DISTINCT FROM p OR a.approval_sha256 IS DISTINCT FROM seal OR NOT a.approved))
  THEN RAISE EXCEPTION 'SHARINGAN_APPROVAL_DRIFT' USING ERRCODE='42501';END IF;
  INSERT INTO clan_innata_private.config_versions(technique_id,config_version,activation_cost,upkeep_cost,editorial_seal,reviewed,active)
   VALUES((d->>'technique_id')::uuid,1,(d->>'activation_cost')::integer,(d->>'upkeep_cost')::integer,seal,true,true)ON CONFLICT DO NOTHING;
  INSERT INTO clan_innata_private.editorial_approvals(technique_id,config_version,approval_sha256,canonical_preimage,approved)
   VALUES((d->>'technique_id')::uuid,1,seal,p,true)ON CONFLICT DO NOTHING;
  SELECT * INTO q FROM clan_innata_narrative_private.config_quotes_v1 WHERE technique_id=(d->>'technique_id')::uuid;
  IF FOUND AND(q.config_version,q.activation_cost,q.upkeep_cost,q.source_kind,q.source_preimage,q.source_sha256)
    IS DISTINCT FROM(1,(d->>'activation_cost')::integer,(d->>'upkeep_cost')::integer,'canonical_config'::text,p,seal)
  THEN RAISE EXCEPTION 'SHARINGAN_QUOTE_DRIFT' USING ERRCODE='42501';END IF;
  INSERT INTO clan_innata_narrative_private.config_quotes_v1(technique_id,config_version,activation_cost,upkeep_cost,source_kind,source_preimage,source_sha256)
   VALUES((d->>'technique_id')::uuid,1,(d->>'activation_cost')::integer,(d->>'upkeep_cost')::integer,'canonical_config',p,seal)ON CONFLICT DO NOTHING;
 END LOOP;
END $quotes$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.quote_v1(p_technique uuid, p_real boolean)
 RETURNS clan_innata_narrative_private.config_quotes_v1
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE q clan_innata_narrative_private.config_quotes_v1;cfg clan_innata_private.config_versions;
BEGIN
 SELECT * INTO STRICT q FROM clan_innata_narrative_private.config_quotes_v1 WHERE technique_id=p_technique;
 IF q.source_sha256 IS DISTINCT FROM public.combat_v2_sha256(q.source_preimage)
 OR NOT EXISTS(SELECT 1 FROM public.clan_techniques t WHERE t.id=q.technique_id AND t.is_active AND t.is_innata
 AND(t.level=1 OR EXISTS(SELECT 1 FROM clan_innata_narrative_private.byakugan_catalog_v1 tier74 WHERE tier74.technique_id=t.id AND tier74.level=t.level) OR(NOT p_real AND t.id IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid))))
 THEN RAISE EXCEPTION 'INNATA_CONFIG_CHANGED' USING ERRCODE='40001';END IF;
 IF EXISTS(SELECT 1 FROM clan_innata_narrative_private.byakugan_catalog_v1 tier74 WHERE tier74.technique_id=q.technique_id)THEN
  PERFORM clan_innata_narrative_private.byakugan_quote_v1(q.technique_id);
 END IF;
 IF q.source_kind='native_function' AND md5(pg_get_functiondef(to_regprocedure(q.source_preimage->>'signature')))
 IS DISTINCT FROM q.source_preimage->>'ddl_md5' THEN RAISE EXCEPTION 'INNATA_COST_AUTHORITY_CHANGED' USING ERRCODE='40001';END IF;
 SELECT * INTO cfg FROM clan_innata_private.config_versions WHERE technique_id=q.technique_id AND reviewed AND active;
 IF p_real OR q.source_kind='canonical_config' THEN
  IF cfg.technique_id IS NULL OR(cfg.config_version,cfg.activation_cost,cfg.upkeep_cost)
    IS DISTINCT FROM(q.config_version,q.activation_cost,q.upkeep_cost)
   OR NOT EXISTS(SELECT 1 FROM clan_innata_private.editorial_approvals ap
    WHERE ap.technique_id=cfg.technique_id AND ap.config_version=cfg.config_version AND ap.approved
    AND ap.approval_sha256=cfg.editorial_seal AND ap.approval_sha256=public.combat_v2_sha256(ap.canonical_preimage)
    AND ap.canonical_preimage=jsonb_build_object('technique_id',cfg.technique_id,'config_version',cfg.config_version,
      'activation_cost',cfg.activation_cost,'upkeep_cost',cfg.upkeep_cost))
  THEN RAISE EXCEPTION 'INNATA_CANONICAL_CONFIG_REQUIRED' USING ERRCODE='55000';END IF;
 END IF;
 RETURN q;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.sharingan_selected_v2(p_actor uuid) RETURNS uuid
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors;d jsonb;t uuid;n integer;
BEGIN
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor;
 SELECT count(*),(array_agg(s.technique_id ORDER BY s.technique_id))[1]INTO n,t
 FROM clan_innata_combat_private.combat_state s WHERE s.actor_id=p_actor AND s.session_id=a.session_id AND s.active AND s.technique_id IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid);
 IF n>1 THEN RAISE EXCEPTION 'SHARINGAN_FAMILY_ALREADY_ACTIVE' USING ERRCODE='55000';END IF;
 IF n=1 THEN RETURN t;END IF;
 d:=clan_innata_narrative_private.staff_profile_actor_v1(p_actor);
 IF d->>'family'='sharingan' THEN RETURN(d->>'technique_id')::uuid;END IF;
 RETURN '4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid;
END;
$f$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.sharingan_quote_for_actor_v2(p_actor uuid) RETURNS integer
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE t uuid;d jsonb;q clan_innata_narrative_private.config_quotes_v1;
BEGIN
 t:=clan_innata_narrative_private.sharingan_selected_v2(p_actor);
 IF t='4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid THEN RETURN 5;END IF;
 d:=clan_innata_narrative_private.staff_profile_actor_v1(p_actor);
 IF d->>'family'IS DISTINCT FROM 'sharingan'OR d->>'technique_id'IS DISTINCT FROM t::text THEN RAISE EXCEPTION 'INNATA_PROFILE_INVALID' USING ERRCODE='42501';END IF;
 q:=clan_innata_narrative_private.quote_v1(t,false);RETURN q.activation_cost;
END;
$f$;

CREATE OR REPLACE FUNCTION clan_innata_private.sharingan_combat_scope_core(p_actor uuid, p_require_profile boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; pg public.characters%ROWTYPE;
 c clan_innata_combat_private.actor_context; ss public.combat_v2_sessions%ROWTYPE;
 gate clan_hyuga_private.release_gate%ROWTYPE; test boolean;
 principals uuid[]; characters_in_scene uuid[]; pg_count integer;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 c:=clan_innata_private.combat_context(a.id);
 SELECT * INTO STRICT ss FROM public.combat_v2_sessions WHERE id=a.session_id;
 SELECT * INTO STRICT gate FROM clan_hyuga_private.release_gate WHERE singleton;
 IF NOT EXISTS(SELECT 1 FROM clan_innata_private.config_versions cfg
   JOIN clan_innata_private.editorial_approvals approval
     ON approval.technique_id=cfg.technique_id AND approval.config_version=cfg.config_version
   WHERE cfg.technique_id='4056f62d-77f3-47f9-8ecb-9a7799682a9d' AND cfg.config_version=1
     AND cfg.reviewed AND cfg.active AND cfg.activation_cost=5 AND cfg.upkeep_cost=5
     AND approval.approved AND approval.approval_sha256=cfg.editorial_seal
     AND approval.approval_sha256=encode(extensions.digest(approval.canonical_preimage::text,'sha256'),'hex')
     AND approval.canonical_preimage=jsonb_build_object('technique_id',cfg.technique_id,
       'config_version',cfg.config_version,'activation_cost',5,'upkeep_cost',5)) THEN
  RAISE EXCEPTION 'uchiha_cost_config_not_qualified' USING ERRCODE='42501'; END IF;
 IF ss.closed_at IS NOT NULL OR ss.state IN ('chiusa','annullata','sospeso')
   OR ss.location_id IS DISTINCT FROM c.location_id
   OR c.phase IN ('closed','setup','suspended')
   OR a.actor_kind<>'pg' OR a.companion_id IS NOT NULL OR a.controller_user IS NULL
   OR a.state<>'attivo' OR jsonb_typeof(a.mechanics_snapshot->'vita') IS DISTINCT FROM 'number'
   OR coalesce((a.mechanics_snapshot->>'vita')::integer,0)<=0 THEN
  RAISE EXCEPTION 'uchiha_actor_not_available' USING ERRCODE='42501'; END IF;
 IF c.activity_kind='ordinary_v2' THEN
  IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.members m WHERE m.session_id=a.session_id
     AND m.actor_id=a.id AND m.character_id=a.character_id) THEN
   RAISE EXCEPTION 'uchiha_member_not_registered' USING ERRCODE='42501'; END IF;
 ELSIF c.activity_kind='master_v2' THEN
  IF c.personal_turn_id IS NULL OR NOT gate.master_enabled THEN
   RAISE EXCEPTION 'uchiha_master_not_enabled' USING ERRCODE='42501'; END IF;
 ELSE RAISE EXCEPTION 'uchiha_activity_not_supported' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT pg FROM public.characters WHERE id=a.character_id AND user_id=a.controller_user;
 test:=NOT public.combat_v2_values_written(a.session_id);
 IF p_require_profile IS NULL OR (NOT p_require_profile AND NOT test) THEN
  RAISE EXCEPTION 'uchiha_profile_preparation_scope_invalid' USING ERRCODE='42501'; END IF;
 IF test AND clan_innata_narrative_private.staff_profile_actor_v1(a.id)IS NOT NULL THEN
  IF NOT gate.staff_enabled OR NOT EXISTS(SELECT 1 FROM clan_hyuga_private.staff_profiles p WHERE p.session_id=a.session_id AND p.actor_id=a.id AND p.is_active
   AND p.profile_version=(clan_innata_narrative_private.staff_profile_actor_v1(a.id)->>'profile_key')||'/1')
  THEN RAISE EXCEPTION 'INNATA_PROFILE_BIND_INVALID' USING ERRCODE='42501';END IF;
  IF NOT coalesce(clan_innata_narrative_private.staff_profile_actor_v1(a.id)->>'profile_key'IN('sharingan-l1','sharingan-l2','sharingan-l3','sharingan-l4'),false)THEN RAISE EXCEPTION 'INNATA_PROFILE_INVALID' USING ERRCODE='42501';END IF;
 ELSIF test THEN
  SELECT count(*),array_agg(DISTINCT x.controller_user ORDER BY x.controller_user),
      array_agg(DISTINCT x.character_id ORDER BY x.character_id)
    INTO pg_count,principals,characters_in_scene
    FROM public.combat_v2_actors x JOIN public.characters p ON p.id=x.character_id AND p.user_id=x.controller_user
    WHERE x.session_id=a.session_id AND x.actor_kind='pg' AND x.companion_id IS NULL;
  IF c.policy_id IS DISTINCT FROM 'staff_test_no_persistent_resources_v1'
   OR c.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   OR NOT gate.staff_enabled OR pg_count<>2 OR cardinality(principals) IS DISTINCT FROM 2
   OR characters_in_scene IS DISTINCT FROM ARRAY['2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid]
   OR (SELECT count(*) FROM public.combat_v2_actors WHERE session_id=a.session_id AND actor_kind='pg')<>2
   OR NOT combat_consumer_private.staff_test_allowed(c.location_id,principals,false)
   OR (p_require_profile AND NOT EXISTS(SELECT 1 FROM clan_hyuga_private.staff_profiles p WHERE p.session_id=a.session_id
      AND p.actor_id=a.id AND p.profile_version='sharingan-l1/1' AND p.is_active)) THEN
   RAISE EXCEPTION 'uchiha_staff_scope_invalid' USING ERRCODE='42501'; END IF;
  IF c.activity_kind='ordinary_v2' AND (
    (SELECT count(*) FROM combat_consumer_private.members WHERE session_id=a.session_id)<>2
    OR EXISTS(SELECT 1 FROM combat_consumer_private.members m
      LEFT JOIN public.combat_v2_actors x ON x.id=m.actor_id AND x.session_id=m.session_id AND x.character_id=m.character_id
      WHERE m.session_id=a.session_id AND (x.id IS NULL OR x.actor_kind<>'pg')))
  THEN RAISE EXCEPTION 'uchiha_staff_members_invalid' USING ERRCODE='42501'; END IF;
 ELSE
  IF NOT gate.sharingan_public_enabled OR pg.clan IS DISTINCT FROM 'Uchiha'
    OR coalesce(pg.kekkei_genkai,0)<30 OR coalesce(public._grade_rank(pg.rank),-1)<public._grade_rank('Genin')
    OR (c.activity_kind='ordinary_v2' AND c.policy_id IS DISTINCT FROM 'free_duel_nonlethal_real_resources_v1')
    OR (c.activity_kind='master_v2' AND c.policy_id IS DISTINCT FROM 'master_game_resources_v1')
    OR NOT EXISTS(SELECT 1 FROM public.character_abilities WHERE character_id=pg.id
       AND technique_id='4056f62d-77f3-47f9-8ecb-9a7799682a9d' AND state='attiva') THEN
   RAISE EXCEPTION 'uchiha_not_eligible' USING ERRCODE='42501'; END IF;
 END IF;
 PERFORM clan_innata_private.runtime_release_assert();
 RETURN jsonb_build_object('actor_id',a.id,'session_id',a.session_id,'character_id',a.character_id,
   'round_id',c.exchange_id,'personal_turn_id',c.personal_turn_id,'activity_kind',c.activity_kind,
   'context_version',c.context_version,'is_test',test,'policy_id',c.policy_id,
   'turn_owner',c.turn_actor_id=a.id,'phase',c.phase);
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.sharingan_staff_bind_ready(p_actor uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; scope jsonb;
BEGIN
 IF clan_innata_narrative_private.staff_profile_actor_v1(p_actor)IS NOT NULL THEN RETURN false;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND controller_user=auth.uid();
 IF NOT FOUND THEN RETURN false; END IF;
 IF EXISTS(SELECT 1 FROM clan_hyuga_private.staff_profiles WHERE session_id=a.session_id AND actor_id=a.id AND profile_version='sharingan-l1/1' AND is_active)
  OR EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_state WHERE session_id=a.session_id AND actor_id=a.id AND active) THEN RETURN false; END IF;
 scope:=clan_innata_private.sharingan_combat_scope_core(a.id,false);
 RETURN (scope->>'is_test')::boolean AND scope->>'phase'='action' AND (scope->>'turn_owner')::boolean
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations
      WHERE round_id=(scope->>'round_id')::uuid AND actor_id=a.id)
   AND NOT EXISTS(SELECT 1 FROM clan_marionettisti_private.sources
      WHERE session_id=a.session_id AND owner_actor_id=a.id)
   AND NOT clan_sabaku_private.narrative_pending(a.session_id);
EXCEPTION WHEN insufficient_privilege THEN RETURN false;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_scope(p_actor uuid, p_technique uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 IF p_technique='001f907c-8f32-4758-8a16-ad1730e72c59'::uuid THEN
  RETURN clan_innata_private.combat_scope(p_actor);
 ELSIF p_technique='4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid AND NOT clan_innata_narrative_private.byakugan_enabled_v1(p_actor)THEN RETURN clan_hyuga_private.combat_scope(p_actor);
 ELSIF p_technique IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid) THEN
  RETURN clan_innata_narrative_private.byakugan_scope_v1(p_actor,p_technique);
 ELSIF p_technique IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)THEN
  IF (clan_innata_narrative_private.staff_profile_actor_v1(p_actor)->>'technique_id')IS DISTINCT FROM p_technique::text THEN RAISE EXCEPTION 'common_combat_technique_not_supported' USING ERRCODE='22023';END IF;
  PERFORM clan_innata_narrative_private.quote_v1(p_technique,false);
  RETURN clan_innata_private.sharingan_combat_scope(p_actor);
 ELSIF p_technique='4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid THEN RETURN clan_innata_private.sharingan_combat_scope(p_actor);
  ELSIF p_technique='c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid THEN RETURN clan_inuzuka_private.quattro_scope(p_actor);
 END IF;
 RAISE EXCEPTION 'common_combat_technique_not_supported' USING ERRCODE='22023';
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_activation_window(p_actor uuid, p_technique uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; c clan_innata_combat_private.actor_context;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 c:=clan_innata_private.combat_context(a.id);
 IF p_technique IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)AND(clan_innata_narrative_private.staff_profile_actor_v1(p_actor)->>'technique_id')IS DISTINCT FROM p_technique::text THEN RETURN false;END IF;
 IF p_technique NOT IN ('001f907c-8f32-4758-8a16-ad1730e72c59'::uuid,'4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid) OR p_technique IS NULL THEN RETURN false; END IF;
 RETURN c.activity_kind='ordinary_v2' AND c.phase='action' AND c.turn_actor_id=a.id
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=c.exchange_id AND d.actor_id=a.id)
   AND NOT EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_receipts r WHERE r.session_id=a.session_id
     AND r.actor_id=a.id AND r.round_id=c.exchange_id AND
       ((r.operation='activate' AND r.chakra_spent>0) OR (r.operation='deactivate' AND r.technique_id=p_technique)))
   AND NOT EXISTS(SELECT 1 FROM combat_consumer_private.offers o WHERE o.session_id=a.session_id
     AND o.exchange_id=c.exchange_id AND o.principal_character_id=a.character_id AND o.state='consumed'
     AND o.operation='control' AND (o.source_payload->>'sabaku_operation'='transport'
       OR o.source_payload->>'marionetta_operation' IN ('move','relink')));
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_begin_turn(p_actor uuid, p_technique uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; c clan_innata_combat_private.actor_context;
 s clan_innata_combat_private.combat_state%ROWTYPE; key uuid;
BEGIN
 IF p_technique='4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid THEN p_technique:=clan_innata_narrative_private.sharingan_selected_v2(p_actor);END IF;
 IF p_technique='4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid THEN
 SELECT st.technique_id INTO key FROM clan_innata_combat_private.combat_state st JOIN clan_innata_narrative_private.byakugan_catalog_v1 q ON q.technique_id=st.technique_id WHERE st.actor_id=p_actor AND st.active;
 IF key IS NOT NULL THEN p_technique:=key;END IF;END IF;
 IF p_technique='001f907c-8f32-4758-8a16-ad1730e72c59'::uuid THEN
  PERFORM clan_innata_private.combat_begin_turn(p_actor); RETURN; END IF;
 IF (p_technique IS NULL OR p_technique NOT IN ('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid)) THEN
  RAISE EXCEPTION 'common_combat_technique_not_supported' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 PERFORM 1 FROM public.combat_v2_sessions WHERE id=a.session_id FOR UPDATE;
 PERFORM 1 FROM combat_consumer_private.activities WHERE session_id=a.session_id FOR UPDATE;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 c:=clan_innata_private.combat_context(a.id);
 SELECT * INTO s FROM clan_innata_combat_private.combat_state WHERE session_id=a.session_id
   AND actor_id=a.id AND technique_id=p_technique FOR UPDATE;
 IF NOT coalesce(s.active,false) THEN RETURN; END IF;
 IF a.actor_kind='png'AND NOT clan_innata_narrative_private.png_profile_valid_v1(a.id,p_technique)THEN
  PERFORM clan_innata_private.combat_terminal(a.id,p_technique,'innata_off');RETURN;
 END IF;
 IF coalesce((a.mechanics_snapshot->>'vita')::integer,0)<=0 THEN
  PERFORM clan_innata_private.combat_terminal(a.id,p_technique,'owner_ko'); RETURN; END IF;
 IF a.state<>'attivo' THEN
  PERFORM clan_innata_private.combat_terminal(a.id,p_technique,'owner_inoperative'); RETURN; END IF;
 IF a.actor_kind='pg'AND NOT EXISTS(SELECT 1 FROM public.presence WHERE user_id=a.controller_user AND location_id=c.location_id) THEN
  PERFORM clan_innata_private.combat_terminal(a.id,p_technique,'owner_absent'); RETURN; END IF;
 IF s.last_upkeep_round_id=c.exchange_id THEN RETURN; END IF;
 IF c.phase<>'action' OR c.turn_actor_id<>a.id THEN RAISE EXCEPTION 'common_upkeep_wrong_turn'; END IF;
 key:=md5('common-upkeep:'||a.session_id||':'||a.id||':'||p_technique||':'||c.exchange_id)::uuid;
 IF p_technique='4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid THEN
  BEGIN
   PERFORM clan_innata_private.combat_transition(a.id,p_technique,'upkeep',key,s.state_version);
  EXCEPTION WHEN insufficient_privilege THEN
   -- Rejected scope rolls back the upkeep subtransaction; terminal is native, no refund.
   PERFORM clan_innata_private.combat_terminal(a.id,p_technique,'innata_off');
  END;
 ELSE
  PERFORM clan_innata_private.combat_transition(a.id,p_technique,'upkeep',key,s.state_version);
 END IF;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_terminal(p_actor uuid, p_technique uuid, p_reason text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; c clan_innata_combat_private.actor_context;
 s clan_innata_combat_private.combat_state%ROWTYPE; key uuid; receipt uuid:=gen_random_uuid(); result jsonb;
BEGIN
 IF p_technique='4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid THEN p_technique:=clan_innata_narrative_private.sharingan_selected_v2(p_actor);END IF;
 IF p_technique='4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid THEN
 SELECT st.technique_id INTO key FROM clan_innata_combat_private.combat_state st JOIN clan_innata_narrative_private.byakugan_catalog_v1 q ON q.technique_id=st.technique_id WHERE st.actor_id=p_actor AND st.active;
 IF key IS NOT NULL THEN p_technique:=key;END IF;END IF;
 IF p_technique='001f907c-8f32-4758-8a16-ad1730e72c59'::uuid THEN
  PERFORM clan_innata_private.combat_terminal(p_actor,p_reason); RETURN; END IF;
 IF (p_technique IS NULL OR p_technique NOT IN ('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid))
   OR p_reason IS NULL OR p_reason NOT IN ('owner_ko','owner_absent','owner_inoperative','combat_end','innata_off') THEN
  RAISE EXCEPTION 'common_terminal_request_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 PERFORM 1 FROM public.combat_v2_sessions WHERE id=a.session_id FOR UPDATE;
 PERFORM 1 FROM combat_consumer_private.activities WHERE session_id=a.session_id FOR UPDATE;
 c:=clan_innata_private.combat_context(a.id);
 PERFORM 1 FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 SELECT * INTO s FROM clan_innata_combat_private.combat_state WHERE session_id=a.session_id AND actor_id=a.id
   AND technique_id=p_technique FOR UPDATE;
 IF NOT coalesce(s.active,false) THEN RETURN; END IF;
 UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1
  WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=p_technique RETURNING * INTO s;
 key:=md5('common-terminal:'||a.session_id||':'||a.id||':'||p_technique||':'||s.state_version)::uuid;
 result:=jsonb_build_object('contract_version','common-combat-innata/1','receipt_id',receipt,
   'technique_id',p_technique,'operation','deactivate','active',false,'state_version',s.state_version,
   'chakra_spent',0,'main_action_consumed',false,'is_test',s.is_test,'values_written',false,
   'replayed',false,'termination_reason',p_reason,'source','lifecycle');
 INSERT INTO clan_innata_combat_private.combat_receipts(receipt_id,session_id,round_id,actor_id,technique_id,
   operation,request_id,fingerprint,chakra_spent,is_test,result)
 VALUES(receipt,a.session_id,c.exchange_id,a.id,p_technique,'deactivate',key,
   public.combat_v2_sha256(jsonb_build_object('actor',a.id,'technique_id',p_technique,
     'state_version',s.state_version,'reason',p_reason)),0,s.is_test,result);
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_transition(p_actor uuid, p_technique uuid, p_operation text, p_request uuid, p_expected_state bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; c clan_innata_combat_private.actor_context;
 s clan_innata_combat_private.combat_state%ROWTYPE; previous clan_innata_combat_private.combat_receipts%ROWTYPE;
 scope jsonb; cost_quote jsonb; fp text; amount integer:=0; before_balance integer; real_balance integer;
 receipt uuid; result jsonb; prior_flag text; terminate_reason text;
 t uuid:=p_technique;base_cost integer:=5;replaced jsonb;
BEGIN
 IF t='001f907c-8f32-4758-8a16-ad1730e72c59'::uuid THEN
  RETURN clan_innata_private.combat_transition(p_actor,p_operation,p_request,p_expected_state); END IF;
 IF p_request IS NULL OR p_expected_state IS NULL OR p_operation IS NULL
   OR p_operation NOT IN ('activate','deactivate','upkeep') THEN
   RAISE EXCEPTION 'common_combat_request_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 PERFORM 1 FROM public.combat_v2_sessions WHERE id=a.session_id FOR UPDATE;
 PERFORM 1 FROM combat_consumer_private.activities WHERE session_id=a.session_id FOR UPDATE;
 c:=clan_innata_private.combat_context(a.id);
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 IF p_operation='deactivate'AND a.actor_kind='png'THEN
  scope:=clan_innata_narrative_private.png_drain_scope_v1(a.id,t);
 ELSE scope:=clan_innata_private.combat_scope(p_actor,t);END IF;
 IF t IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid)AND p_operation<>'deactivate'THEN base_cost:=(clan_innata_narrative_private.byakugan_quote_v1(t)).base_cost;END IF;
 IF t IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)AND p_operation<>'deactivate'THEN base_cost:=(clan_innata_narrative_private.quote_v1(t,false)).activation_cost;END IF;
 IF p_operation='activate'AND a.actor_kind='png'THEN
 INSERT INTO clan_innata_narrative_private.png_selections_v1(session_id,actor_id,technique_id,provider_instance_id,mechanical_version_id,source_sha256,snapshot_sha256,selection_request)
 SELECT a.session_id,a.id,t,i.id,i.mechanical_version_ref,i.source_sha256,i.snapshot_sha256,p_request
 FROM public.combat_v2_provider_instances_v1 i WHERE i.id=a.provider_instance_v1_id AND clan_innata_narrative_private.png_profile_valid_v1(a.id,t)
 ON CONFLICT(session_id,actor_id,technique_id)DO NOTHING;
 END IF;
 IF p_operation='activate' AND EXISTS(
   SELECT 1 FROM clan_marionettisti_private.links WHERE owner_actor_id=a.id AND state='connected') THEN
   RAISE EXCEPTION 'common_combat_jutsu_blocked_by_threads' USING ERRCODE='55000'; END IF;
 -- OFF è immediato anche fuori dal turno d'azione; ownership, sessione
 -- e condizioni dello scope restano verificate prima di questa distinzione.
 IF p_operation<>'deactivate' AND (c.phase<>'action' OR c.turn_actor_id<>a.id) THEN
   RAISE EXCEPTION 'common_combat_turn_invalid' USING ERRCODE='55000'; END IF;
 fp:=public.combat_v2_sha256(jsonb_build_object('session',a.session_id,'actor',a.id,
   'round',c.exchange_id,'technique_id',t,'operation',p_operation,'expected_state',p_expected_state));
 SELECT * INTO previous FROM clan_innata_combat_private.combat_receipts
   WHERE session_id=a.session_id AND actor_id=a.id AND request_id=p_request;
 IF FOUND THEN
   IF previous.fingerprint<>fp THEN RAISE EXCEPTION 'common_combat_request_conflict' USING ERRCODE='22023'; END IF;
   RETURN previous.result||jsonb_build_object('replayed',true);
 END IF;
 IF p_operation='deactivate'AND a.actor_kind='png'THEN
  SELECT * INTO STRICT s FROM clan_innata_combat_private.combat_state WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t FOR UPDATE;
 ELSE s:=clan_innata_private.combat_state_ensure(a.id,t);END IF;
 IF s.state_version<>p_expected_state THEN RAISE EXCEPTION 'common_combat_state_stale' USING ERRCODE='40001'; END IF;

 IF p_operation='activate' AND NOT s.active AND c.activity_kind='ordinary_v2'
   AND NOT clan_innata_private.combat_activation_window(a.id,t) THEN
  RAISE EXCEPTION 'common_activation_window_closed' USING ERRCODE='55000'; END IF;
 IF p_operation='activate' AND NOT s.active THEN amount:=base_cost;
 ELSIF p_operation='upkeep' THEN
   IF NOT s.active THEN RAISE EXCEPTION 'common_combat_innata_inactive' USING ERRCODE='55000'; END IF;
   IF s.activated_round_id IS DISTINCT FROM c.exchange_id AND s.last_upkeep_round_id IS DISTINCT FROM c.exchange_id THEN amount:=base_cost; END IF;
 END IF;
 IF amount>0 THEN
  cost_quote:=clan_hyuga_private.sedici_cost_quote(a.id,amount);
  amount:=(cost_quote->>'total')::integer;
 END IF;
 IF jsonb_typeof(a.mechanics_snapshot->'chakra') IS DISTINCT FROM 'number' THEN
   RAISE EXCEPTION 'common_combat_chakra_snapshot_invalid'; END IF;
 before_balance:=(a.mechanics_snapshot->>'chakra')::integer;
 IF before_balance<amount THEN
   IF p_operation='upkeep' THEN amount:=0; terminate_reason:='insufficient_chakra';
   ELSE RAISE EXCEPTION 'common_combat_insufficient_chakra' USING ERRCODE='22023'; END IF;
 END IF;
 IF amount>0 AND NOT (scope->>'is_test')::boolean AND a.actor_kind='pg' THEN
   SELECT chakra INTO STRICT real_balance FROM public.characters WHERE id=a.character_id FOR UPDATE;
   IF real_balance<amount THEN
     IF p_operation='upkeep' THEN amount:=0; terminate_reason:='insufficient_chakra';
     ELSE RAISE EXCEPTION 'common_combat_insufficient_real_chakra' USING ERRCODE='22023'; END IF;
   END IF;
 END IF;
 IF terminate_reason IS NOT NULL THEN
   UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1,
     last_upkeep_round_id=c.exchange_id
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 ELSIF p_operation='activate' AND NOT s.active THEN
   IF(scope->>'is_test')::boolean AND t IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)THEN
    SELECT coalesce(jsonb_agg(jsonb_build_object('technique_id',x.technique_id,'state_version',x.state_version)ORDER BY x.technique_id),'[]'::jsonb)INTO replaced FROM clan_innata_combat_private.combat_state x WHERE x.session_id=a.session_id AND x.actor_id=a.id AND x.active AND x.technique_id<>t AND x.technique_id IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid);
    UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1 WHERE session_id=a.session_id AND actor_id=a.id AND active AND technique_id<>t AND technique_id IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid);
   END IF;
   UPDATE clan_innata_combat_private.combat_state SET active=true,state_version=state_version+1,
     activated_round_id=c.exchange_id,last_upkeep_round_id=c.exchange_id
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 ELSIF p_operation='deactivate' AND s.active THEN
   UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 ELSIF p_operation='upkeep' AND amount>0 THEN
   UPDATE clan_innata_combat_private.combat_state SET state_version=state_version+1,last_upkeep_round_id=c.exchange_id
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 END IF;
 receipt:=gen_random_uuid();
 result:=jsonb_build_object('contract_version','common-combat-innata/1','receipt_id',receipt,
   'operation',p_operation,'technique_id',t,'active',s.active,'state_version',s.state_version,
   'technique_cost',CASE WHEN amount>0 THEN cost_quote ELSE NULL END,'chakra_spent',amount,'main_action_consumed',false,'is_test',(scope->>'is_test')::boolean,
   'values_written',amount>0 AND NOT (scope->>'is_test')::boolean,'replayed',false,'termination_reason',terminate_reason);
 IF replaced IS NOT NULL THEN result:=result||jsonb_build_object('replaced_family_states',replaced);END IF;
 INSERT INTO clan_innata_combat_private.combat_receipts(receipt_id,session_id,round_id,actor_id,technique_id,
   operation,request_id,fingerprint,chakra_spent,is_test,result)
   VALUES(receipt,a.session_id,c.exchange_id,a.id,
     t,
     p_operation,p_request,fp,amount,(scope->>'is_test')::boolean,result);
 IF amount>0 THEN
   INSERT INTO clan_innata_combat_private.combat_resource_ledger(receipt_id,expected_amount,committed_amount,
     applied_amount,is_test,balance_before,balance_after)
     VALUES(receipt,amount,amount,CASE WHEN (scope->>'is_test')::boolean THEN 0 ELSE amount END,
       (scope->>'is_test')::boolean,before_balance,before_balance-amount);
   UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(mechanics_snapshot,'{chakra}',to_jsonb(before_balance-amount),false)
     WHERE id=a.id;
   IF NOT (scope->>'is_test')::boolean AND a.actor_kind='pg' THEN
     prior_flag:=current_setting('app.allow_chakra_delta',true);
     PERFORM set_config('app.allow_chakra_delta','1',true);
     UPDATE public.characters SET chakra=chakra-amount WHERE id=a.character_id;
     PERFORM set_config('app.allow_chakra_delta',coalesce(prior_flag,''),true);
   END IF;
 END IF;
 RETURN result;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.sharingan_consumer_options(p jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE aid uuid:=(p#>>'{viewer,actor_id}')::uuid; sid uuid:=(p#>>'{context,activity_id}')::uuid;
 a public.combat_v2_actors%ROWTYPE; c combat_consumer_private.activities%ROWTYPE;
 state clan_innata_combat_private.combat_state%ROWTYPE;
 offers jsonb:=coalesce(p->'offers','[]'::jsonb); scene integer:=(p#>>'{context,scene_version}')::integer;
BEGIN
 IF aid IS NULL OR sid IS NULL OR p->>'status'<>'ready' THEN RETURN p; END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=aid AND session_id=sid AND controller_user=auth.uid();
 IF NOT FOUND THEN RETURN p; END IF;
 SELECT * INTO STRICT c FROM combat_consumer_private.activities WHERE session_id=sid;
 IF clan_innata_private.sharingan_staff_bind_ready(aid) THEN
  offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,null,scene,'control',
    'Prepara prova Uchiha Genin: Sharingan · Innata 45',jsonb_build_object('sharingan_operation','staff_profile','expected_state',0)));
  RETURN jsonb_set(p,'{offers}',offers);
 END IF;
 IF clan_innata_narrative_private.staff_profile_actor_v1(aid)IS NULL AND clan_uchiha_private.fireball_staff_bind_ready(aid) THEN
  offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,null,scene,'control',
    'Prepara la prova Uchiha: Katon e Risonanza',jsonb_build_object('sharingan_operation','katon_profile','expected_state',0)));
 END IF;
 BEGIN PERFORM clan_innata_private.sharingan_combat_scope(aid);
 EXCEPTION WHEN insufficient_privilege THEN RETURN p; END;
 state:=clan_innata_private.combat_state_read(aid,clan_innata_narrative_private.sharingan_selected_v2(aid));
 IF state.active THEN
  offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,null,scene,'control',
    'Spegni Sharingan · gratuito',jsonb_build_object('sharingan_operation','deactivate','expected_state',state.state_version)));
 ELSIF clan_innata_private.combat_activation_window(aid,clan_innata_narrative_private.sharingan_selected_v2(aid)::uuid) AND coalesce((a.mechanics_snapshot->>'chakra')::integer,0)>=(clan_hyuga_private.sedici_cost_quote(a.id,clan_innata_narrative_private.sharingan_quote_for_actor_v2(a.id))->>'total')::integer
   AND NOT EXISTS(SELECT 1 FROM clan_marionettisti_private.links link WHERE link.owner_actor_id=aid AND link.state='connected') THEN
  offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,null,scene,'control',
    'Attiva Sharingan · '||(clan_hyuga_private.sedici_cost_quote(a.id,clan_innata_narrative_private.sharingan_quote_for_actor_v2(a.id))->>'total')||' chakra',jsonb_build_object('sharingan_operation','activate','expected_state',state.state_version)));
 END IF;
 RETURN jsonb_set(p,'{offers}',offers);
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.sharingan_master_control_offers(p_context uuid, p_expected bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; scope jsonb;
 a public.combat_v2_actors%ROWTYPE; s clan_innata_combat_private.combat_state%ROWTYPE;
 operation text; label text;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.command_actor_id IS NULL THEN RETURN; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal();
 IF clan_innata_private.sharingan_staff_bind_ready(a.id) THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control',
     'Prepara prova Uchiha Genin: Sharingan · Innata 45',false,jsonb_build_object('adapter','master_v2',
       'dispatch','sharingan_control','sharingan_operation','staff_profile','expected_state',0));
   RETURN;
 END IF;
 IF clan_innata_narrative_private.staff_profile_actor_v1(a.id)IS NULL AND clan_uchiha_private.fireball_staff_bind_ready(a.id) THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control',
     'Prepara la prova Uchiha: Katon e Risonanza',false,jsonb_build_object('adapter','master_v2',
       'dispatch','sharingan_control','sharingan_operation','katon_profile','expected_state',0));
 END IF;
 BEGIN scope:=clan_innata_private.sharingan_combat_scope(a.id);
 EXCEPTION WHEN insufficient_privilege THEN RETURN; END;
 s:=clan_innata_private.combat_state_read(a.id,clan_innata_narrative_private.sharingan_selected_v2(a.id));
 IF s.active THEN operation:='deactivate'; label:='Spegni Sharingan · gratuito';
 ELSIF scope->>'phase'='action' AND coalesce((a.mechanics_snapshot->>'chakra')::integer,0)>=(clan_hyuga_private.sedici_cost_quote(a.id,clan_innata_narrative_private.sharingan_quote_for_actor_v2(a.id))->>'total')::integer
   AND NOT EXISTS(SELECT 1 FROM clan_marionettisti_private.links WHERE owner_actor_id=a.id AND state='connected') THEN
   operation:='activate'; label:='Attiva Sharingan · '||(clan_hyuga_private.sedici_cost_quote(a.id,clan_innata_narrative_private.sharingan_quote_for_actor_v2(a.id))->>'total')||' chakra';
 END IF;
 IF operation IS NOT NULL THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control',label,false,
     jsonb_build_object('adapter','master_v2','dispatch','sharingan_control','sharingan_operation',operation,'expected_state',s.state_version));
 END IF;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.sharingan_commit_control(p jsonb, prepared jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_consumer_private.activities%ROWTYPE; o combat_consumer_private.offers%ROWTYPE;
 aid uuid:=(prepared->>'actor_id')::uuid; cid uuid:=(prepared->>'principal_character_id')::uuid;
 key uuid:=(p->>'request_key')::uuid; op text; expected bigint; event jsonb; eid uuid;
 result jsonb; envelope jsonb; label jsonb; receipt jsonb;
BEGIN
 SELECT * INTO STRICT c FROM combat_consumer_private.activities WHERE session_id=(p->>'activity_id')::uuid FOR UPDATE;
 SELECT * INTO STRICT o FROM combat_consumer_private.offers WHERE id=(p->>'offer_id')::uuid FOR UPDATE;
 op:=o.source_payload->>'sharingan_operation'; expected:=(o.source_payload->>'expected_state')::bigint;
 IF p->>'operation'<>'control' OR o.operation<>'control' OR o.state<>'offered'
   OR o.principal_character_id<>cid OR o.session_id<>c.session_id OR o.exchange_id<>c.exchange_id
   OR o.context_version<>c.context_version OR expected IS NULL
   OR op NOT IN ('staff_profile','katon_profile','activate','deactivate') OR op IS NULL
   OR o.source_payload<>jsonb_build_object('sharingan_operation',op,'expected_state',expected)
   OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=aid AND session_id=c.session_id
     AND character_id=cid AND controller_user=auth.uid() AND actor_kind='pg' AND state='attivo') THEN
   PERFORM combat_consumer_private.fail('offer_not_available',key); END IF;
 IF op='deactivate' THEN
   IF NOT clan_innata_private.sharingan_off_offer_valid(o.id,aid) THEN
     PERFORM combat_consumer_private.fail('offer_not_available',key); END IF;
 ELSIF c.phase<>'action' OR c.turn_actor_id<>aid THEN
   PERFORM combat_consumer_private.fail('offer_not_available',key);
 END IF;
 event:=public.combat_v2_event_begin(o.id,key,'combat_consumer_control',p); eid:=(event->>'event_id')::uuid;
 CASE op
  WHEN 'staff_profile' THEN result:=clan_innata_private.sharingan_staff_bind(aid,key);
  WHEN 'katon_profile' THEN result:=clan_uchiha_private.fireball_staff_bind(aid,key);
  WHEN 'activate' THEN result:=clan_innata_private.combat_transition(aid,clan_innata_narrative_private.sharingan_selected_v2(aid),'activate',key,expected);
  WHEN 'deactivate' THEN result:=clan_innata_private.combat_transition(aid,clan_innata_narrative_private.sharingan_selected_v2(aid),'deactivate',key,expected);
 END CASE;
 UPDATE combat_consumer_private.activities SET context_version=context_version+1,last_action_at=clock_timestamp()
  WHERE session_id=c.session_id;
 envelope:=combat_consumer_private.state_projection(c.location_id);
 label:=combat_consumer_private.display_label(c.session_id,aid,aid,null);
 receipt:=jsonb_build_object('receipt_id',eid,'request_key',key,'operation','control','replayed',false,
  'activity_id',c.session_id,'exchange_id',c.exchange_id,'context_version_before',c.context_version,
  'context_version_after',c.context_version+1,'declaration_id',null,'report_id',null,'report_sha256',null,
  'values_written',coalesce((result->>'values_written')::boolean,false),
  'display_events',jsonb_build_array(combat_consumer_private.validate_display_event(jsonb_build_object(
    'event_id',eid,'event_kind','control_changed','actor_id',aid,'display_name',label->>'display_name',
    'label_version',label->'label_version','target_actor_id',null,'target_display_name',null,'target_label_version',null,
    'summary',(label->>'display_name')||': '||(o.viewer_projection->>'label')||'.'))));
 envelope:=jsonb_set(envelope,'{receipt}',receipt);
 UPDATE combat_consumer_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id;
 INSERT INTO combat_consumer_private.request_receipts(principal_character_id,request_key,command_sha256,operation,event_id,viewer_envelope)
  VALUES(cid,key,prepared->>'command_sha256','control',eid,envelope);
 RETURN public.combat_v2_event_complete(eid,envelope);
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.sharingan_commit_master_control(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p jsonb; uid uuid:=auth.uid(); key uuid; fp text; receipt_id uuid:=gen_random_uuid();
 prior combat_panel_private.request_receipts%ROWTYPE; o combat_panel_private.offers%ROWTYPE;
 c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 env jsonb; result jsonb; event jsonb; receipt jsonb; operation text; expected bigint; label text;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 p:=combat_panel_private.validate_command(p_command); key:=(p->>'request_key')::uuid; fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF FOUND THEN
   IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);
 END IF;
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid
   AND kind='control' AND combat_panel_private.offers.operation='control' AND source_payload->>'adapter'='master_v2'
   AND source_payload->>'dispatch'='sharingan_control';
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=o.context_id AND principal_user=uid;
 IF c.activity_kind<>'master_v2' OR c.round_id IS NULL
   OR c.location_id IS DISTINCT FROM (p->>'location_id')::uuid OR c.activity_id IS DISTINCT FROM (p->>'activity_id')::uuid
   OR combat_panel_private.access_reason(c.location_id,'master_v2') IS NOT NULL THEN
   RAISE EXCEPTION 'panel_activity_scope_invalid' USING ERRCODE='42501'; END IF;
 PERFORM public.combat_v2_lock_round(c.round_id);
 env:=combat_panel_private.master_projection(c.location_id,c.command_actor_id);
 PERFORM 1 FROM combat_panel_private.contexts WHERE id=c.id FOR UPDATE;
 c:=combat_panel_private.owned_context(c.id,(p->>'context_version')::bigint);
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=o.id FOR UPDATE;
 IF o.state<>'offered' OR o.context_version<>c.context_version OR o.source_fingerprint IS DISTINCT FROM c.source_fingerprint
   OR o.scene_version IS DISTINCT FROM c.scene_version OR o.actor_id IS DISTINCT FROM c.command_actor_id
   OR jsonb_array_length(p->'selected_option_ids')<>0 OR jsonb_array_length(p->'inputs')<>0 THEN
   RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='40001'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=o.actor_id AND session_id=c.activity_id
   AND controller_user=uid AND actor_kind='pg' AND companion_id IS NULL AND state='attivo' FOR UPDATE;
 operation:=o.source_payload->>'sharingan_operation'; expected:=(o.source_payload->>'expected_state')::bigint;
 IF expected IS NULL OR operation IS NULL OR operation NOT IN ('staff_profile','katon_profile','activate','deactivate')
   OR o.source_payload IS DISTINCT FROM jsonb_build_object('adapter','master_v2','dispatch','sharingan_control',
      'sharingan_operation',operation,'expected_state',expected) THEN
  RAISE EXCEPTION 'sharingan_master_offer_invalid' USING ERRCODE='22023'; END IF;
 CASE operation
 WHEN 'staff_profile' THEN result:=clan_innata_private.sharingan_staff_bind(a.id,key);
 WHEN 'katon_profile' THEN result:=clan_uchiha_private.fireball_staff_bind(a.id,key);
 WHEN 'activate','deactivate' THEN result:=clan_innata_private.combat_transition(a.id,clan_innata_narrative_private.sharingan_selected_v2(a.id),operation,key,expected);
 ELSE RAISE EXCEPTION 'sharingan_master_operation_invalid' USING ERRCODE='22023';
 END CASE;
 IF result->'main_action_consumed' IS DISTINCT FROM 'false'::jsonb THEN
   RAISE EXCEPTION 'sharingan_master_main_consumed' USING ERRCODE='22023'; END IF;
 SELECT value->>'display_name' INTO label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=a.id::text;
 event:=jsonb_build_object('event_id',receipt_id,'event_kind','control_changed','actor_id',a.id,'display_name',label,
   'label_version',c.context_version,'target_actor_id',NULL,'target_display_name',NULL,'target_label_version',NULL,
   'summary',CASE operation WHEN 'staff_profile' THEN 'Prova Uchiha preparata' WHEN 'katon_profile' THEN 'Katon e Risonanza pronti per la prova' WHEN 'activate' THEN 'Sharingan attivo'
     WHEN 'deactivate' THEN 'Sharingan spento' END);
 env:=combat_panel_private.master_projection(c.location_id,a.id);
 receipt:=jsonb_build_object('receipt_id',receipt_id,'request_key',key,'operation','control','replayed',false,
   'activity_id',c.activity_id,'round_id',c.round_id,'context_version_before',o.context_version,
   'context_version_after',env#>'{context,version}','declaration_id',NULL,'report_id',NULL,
   'values_written',(result->>'values_written')::boolean,'display_events',jsonb_build_array(event));
 env:=jsonb_set(env,'{receipt}',receipt);
 UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id;
 INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)
   VALUES(uid,key,fp,o.id,receipt_id,env);
 RETURN env;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.sharingan_off_offer_valid(p_offer uuid, p_actor uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE scope jsonb;
BEGIN
 scope:=clan_innata_private.sharingan_combat_scope(p_actor);
 RETURN EXISTS(SELECT 1 FROM combat_consumer_private.offers o
  JOIN clan_innata_combat_private.combat_state s ON s.session_id=o.session_id AND s.actor_id=p_actor
    AND s.technique_id=clan_innata_narrative_private.sharingan_selected_v2(p_actor)
  WHERE o.id=p_offer AND o.operation='control' AND o.offer_kind='control' AND o.state='offered'
    AND o.session_id=(scope->>'session_id')::uuid AND o.exchange_id=(scope->>'round_id')::uuid
    AND o.context_version=(scope->>'context_version')::bigint
    AND o.principal_character_id=(scope->>'character_id')::uuid AND s.active
    AND o.source_payload=jsonb_build_object('sharingan_operation','deactivate','expected_state',s.state_version));
EXCEPTION WHEN insufficient_privilege THEN RETURN false;
END $function$;

CREATE OR REPLACE FUNCTION clan_hyuga_private.sedici_common_cost_guard()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE r clan_innata_combat_private.combat_receipts%ROWTYPE; amount integer; base integer;
BEGIN
 IF TG_TABLE_NAME='combat_receipts' THEN
  -- SP07: a native Byakugan base10 is not a legacy base5+Sedici5 cause.
  -- Initial release is limited to the existing, server-proven Staff simulation.
  IF NEW.is_test AND NEW.chakra_spent>0
   AND NEW.technique_id IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,
    '8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,
    'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)
   AND EXISTS(SELECT 1 FROM public.combat_v2_sessions ss
    JOIN public.combat_v2_actors aa ON aa.session_id=ss.id AND aa.id=NEW.actor_id
    JOIN public.combat_v2_rounds rr ON rr.session_id=ss.id AND rr.id=NEW.round_id
    WHERE ss.id=NEW.session_id AND ss.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
     AND ss.closed_at IS NULL AND NOT public.combat_v2_values_written(ss.id))
   AND (clan_innata_narrative_private.staff_profile_actor_v1(NEW.actor_id)->>'technique_id')::uuid=NEW.technique_id THEN
   IF NEW.operation IS NULL OR NEW.operation NOT IN('activate','upkeep') THEN
    RAISE EXCEPTION 'sedici_common_receipt_cause_required' USING ERRCODE='22023'; END IF;
   SELECT CASE NEW.operation WHEN 'activate' THEN q.activation_cost ELSE q.upkeep_cost END
    INTO STRICT base FROM clan_innata_narrative_private.config_quotes_v1 q
    WHERE q.technique_id=NEW.technique_id;
   IF base IS NULL OR base<=0 THEN
    RAISE EXCEPTION 'sedici_common_receipt_cause_required' USING ERRCODE='22023'; END IF;
   amount:=clan_hyuga_private.sedici_frozen_cost(NEW.actor_id,
    jsonb_build_object('chakra',base,'technique_cost',NEW.result->'technique_cost'));
   IF amount IS DISTINCT FROM NEW.chakra_spent
    OR NEW.result->'technique_cost' IS DISTINCT FROM clan_hyuga_private.sedici_cost_quote(NEW.actor_id,base) THEN
    RAISE EXCEPTION 'sedici_common_receipt_cause_required' USING ERRCODE='22023'; END IF;
  ELSIF NEW.chakra_spent=10 THEN
   amount:=clan_hyuga_private.sedici_frozen_cost(NEW.actor_id,
    jsonb_build_object('chakra',5,'technique_cost',NEW.result->'technique_cost'));
   IF amount<>10 OR NEW.result#>>'{technique_cost,sedici_delta}' IS DISTINCT FROM '5'
    OR NEW.result->'technique_cost' IS DISTINCT FROM clan_hyuga_private.sedici_cost_quote(NEW.actor_id,5) THEN
    RAISE EXCEPTION 'sedici_common_receipt_cause_required' USING ERRCODE='22023'; END IF;
  END IF;
 ELSE
  SELECT * INTO STRICT r FROM clan_innata_combat_private.combat_receipts WHERE receipt_id=NEW.receipt_id;
  IF NEW.expected_amount IS DISTINCT FROM r.chakra_spent OR NEW.committed_amount IS DISTINCT FROM r.chakra_spent
   OR NEW.is_test IS DISTINCT FROM r.is_test OR NEW.applied_amount IS DISTINCT FROM (CASE WHEN r.is_test THEN 0 ELSE r.chakra_spent END) THEN
   RAISE EXCEPTION 'sedici_common_ledger_receipt_mismatch' USING ERRCODE='22023'; END IF;
 END IF;
 RETURN NEW;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.byakugan_family_guard_v1()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE k uuid;
BEGIN
 IF NEW.active AND EXISTS(SELECT 1 FROM clan_innata_narrative_private.byakugan_catalog_v1 q WHERE q.technique_id=NEW.technique_id)THEN
 IF TG_TABLE_SCHEMA='clan_innata_combat_private'THEN
 PERFORM pg_advisory_xact_lock(hashtextextended('byakugan-family:'||NEW.actor_id::text,0));
 IF EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_state s JOIN clan_innata_narrative_private.byakugan_catalog_v1 q ON q.technique_id=s.technique_id
 WHERE s.actor_id=NEW.actor_id AND s.session_id=NEW.session_id AND s.active AND s.technique_id<>NEW.technique_id)
 THEN RAISE EXCEPTION 'BYAKUGAN_FAMILY_ALREADY_ACTIVE' USING ERRCODE='55000';END IF;
 ELSE
 PERFORM pg_advisory_xact_lock(hashtextextended('byakugan-family-character:'||NEW.actor_id::text,0));
 IF EXISTS(SELECT 1 FROM clan_innata_private.actor_state s JOIN clan_innata_narrative_private.byakugan_catalog_v1 q ON q.technique_id=s.technique_id
 WHERE s.actor_id=NEW.actor_id AND s.active AND s.technique_id<>NEW.technique_id)
 THEN RAISE EXCEPTION 'BYAKUGAN_FAMILY_ALREADY_ACTIVE' USING ERRCODE='55000';END IF;
 END IF;END IF;
 IF NEW.active AND NEW.technique_id IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)THEN
  IF TG_TABLE_SCHEMA='clan_innata_combat_private'THEN
   IF NEW.is_test AND EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_state x WHERE x.session_id=NEW.session_id AND x.actor_id=NEW.actor_id AND x.active AND x.technique_id<>NEW.technique_id AND x.technique_id IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid))THEN RAISE EXCEPTION 'SHARINGAN_FAMILY_ALREADY_ACTIVE' USING ERRCODE='55000';END IF;
  END IF;
 END IF;
 RETURN NEW;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.staff_profile_actor_v1(p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors;s public.combat_v2_sessions;c clan_innata_narrative_private.contexts_v1;d jsonb;mark jsonb;principals uuid[];
BEGIN
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind='pg'AND companion_id IS NULL;
 IF a.id IS NULL THEN RETURN NULL;END IF;SELECT * INTO s FROM public.combat_v2_sessions WHERE id=a.session_id;
 IF s.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid OR public.combat_v2_values_written(s.id)
 OR s.closed_at IS NOT NULL OR NOT EXISTS(SELECT 1 FROM clan_innata_narrative_private.gate_v1 WHERE singleton AND staff_enabled)
 THEN RETURN NULL;END IF;
 SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE context_id=(a.mechanics_snapshot#>>'{innata_staff_profile,context_id}')::uuid
 AND character_id=a.character_id AND location_id=s.location_id AND active AND(bound_combat_session_id IS NULL OR bound_combat_session_id=s.id);
 IF c.context_id IS NULL OR c.staff_ability_profile->>'profile_key'IS NULL THEN RETURN NULL;END IF;
 IF NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.profiles pr ON pr.id=ch.user_id WHERE ch.id=a.character_id AND ch.user_id=a.controller_user
 AND pr.role IN('admin','master')AND c.staff_ability_profile->>'created_by'=ch.user_id::text)
 THEN RETURN NULL;END IF;
 SELECT array_agg(DISTINCT controller_user)INTO principals FROM public.combat_v2_actors WHERE session_id=s.id AND actor_kind='pg'AND companion_id IS NULL;
 IF NOT combat_consumer_private.staff_test_allowed(s.location_id,principals,false)
 OR (clan_innata_private.combat_context(a.id)).policy_id IS DISTINCT FROM 'staff_test_no_persistent_resources_v1' THEN RETURN NULL;END IF;
 d:=clan_innata_narrative_private.profile_definition_v2(c.staff_ability_profile->>'profile_key');
 IF s.master_session_id IS NOT NULL AND d->>'family'IN('byakugan','sharingan')
 AND NOT EXISTS(SELECT 1 FROM clan_hyuga_private.release_gate WHERE singleton AND staff_enabled AND master_enabled)
 THEN RAISE EXCEPTION 'INNATA_PROFILE_RUNTIME_UNAVAILABLE' USING ERRCODE='42501';END IF;
 mark:=jsonb_build_object('context_id',c.context_id,'profile_version',(c.staff_ability_profile->>'version')::bigint,
 'profile_key',d->'profile_key','technique_id',d->'technique_id','actor_id',a.id,'session_id',s.id,'character_id',a.character_id,'controller_user',a.controller_user);
 IF a.mechanics_snapshot->'innata_staff_profile'IS DISTINCT FROM mark THEN RETURN NULL;END IF;
 IF d->>'profile_key'='sabaku-l1' THEN
  IF NOT EXISTS(SELECT 1 FROM clan_sabaku_private.staff_profiles p WHERE p.session_id=s.id AND p.actor_id=a.id
   AND p.profile_version='sabaku-trasporto-l1/1' AND p.bind_result @> jsonb_build_object('operation','staff_profile',
    'profile_context',c.context_id,'profile_version',c.staff_ability_profile->'version','is_test',true,'values_written',false))
  THEN RETURN NULL;END IF;
 ELSIF d->>'family'IN('byakugan','sharingan') THEN
  IF NOT EXISTS(SELECT 1 FROM clan_hyuga_private.staff_profiles p WHERE p.session_id=s.id AND p.actor_id=a.id
   AND p.is_active AND p.profile_version=(d->>'profile_key')||'/1')THEN RETURN NULL;END IF;
 ELSIF d->>'lifecycle_kind'='passive_permission'THEN
  IF a.mechanics_snapshot->'innata_permission_fact'IS DISTINCT FROM clan_innata_narrative_private.permission_fact_v2(c.context_id)THEN RETURN NULL;END IF;
 ELSE RETURN NULL;
 END IF;
 RETURN d||jsonb_build_object('context_id',c.context_id,'profile_version',(c.staff_ability_profile->>'version')::bigint);
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.staff_profile_bind_v1(p_context uuid, p_actor uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c clan_innata_narrative_private.contexts_v1;a public.combat_v2_actors;s public.combat_v2_sessions;d jsonb;mark jsonb;snap jsonb;ability jsonb;prior clan_sabaku_private.reserves;req uuid;
BEGIN
 SELECT * INTO STRICT c FROM clan_innata_narrative_private.contexts_v1 WHERE context_id=p_context FOR UPDATE;
 IF c.staff_ability_profile->>'profile_key'IS NULL THEN RETURN;END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND character_id=c.character_id AND actor_kind='pg'AND companion_id IS NULL FOR UPDATE;
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=a.session_id;
 IF s.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid OR c.location_id<>s.location_id OR public.combat_v2_values_written(s.id)
 OR NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.profiles pr ON pr.id=ch.user_id WHERE ch.id=a.character_id AND ch.user_id=a.controller_user
 AND pr.role IN('admin','master')AND c.staff_ability_profile->>'created_by'=ch.user_id::text)
 THEN RAISE EXCEPTION 'INNATA_STAFF_ONLY' USING ERRCODE='42501';END IF;
 d:=clan_innata_narrative_private.profile_definition_v2(c.staff_ability_profile->>'profile_key');
 IF EXISTS(SELECT 1 FROM clan_innata_narrative_private.states_v1 WHERE context_id=c.context_id AND active AND technique_id<>(d->>'technique_id')::uuid)
 THEN RAISE EXCEPTION 'INNATA_PROFILE_ACTIVE' USING ERRCODE='55000';END IF;
 mark:=jsonb_build_object('context_id',c.context_id,'profile_version',(c.staff_ability_profile->>'version')::bigint,'profile_key',d->'profile_key','technique_id',d->'technique_id',
 'actor_id',a.id,'session_id',s.id,'character_id',a.character_id,'controller_user',a.controller_user);
 IF d->>'lifecycle_kind'='passive_permission'THEN
  snap:=a.mechanics_snapshot;
  SELECT coalesce(jsonb_agg(x ORDER BY x->>'name'),'[]'::jsonb)INTO ability FROM jsonb_array_elements(coalesce(snap->'abilities','[]'::jsonb))x
   WHERE NOT(x->>'source'='clan'AND x->>'id' IN('94c45ec9-78c7-423e-9045-4b4cf2104b15','d2d98dad-fb9f-4ff1-b6b2-3d3f2d222fae','6d264e00-1db3-4daa-b7cc-e5f011e1dab1','2fb3e027-a4ff-4058-9d5d-0212facb3f68','bc2569b5-eab4-44b4-9843-c199724caff4','09097efd-e162-4cae-a644-5e643fe94f8c','dd2026b4-bffc-490e-8646-be411d4746b3','fdf79ce1-1c5b-44c4-aaa1-789be08e01de','ed808bc6-57f6-4853-80bf-9e6985ca0cc3','41254b82-5b5e-46e9-9820-b3d604bbe38f','2fb9e210-225d-460a-a9f9-39ee64f8fce1','ab64415a-cca3-472f-9203-84ad60c09405','4a527ff2-0420-4da9-bc1f-5489c753b285','8e20bafe-cb3c-4967-b9c7-2a4bca694996','9b384de3-35f0-43c0-b145-94f985fa758a','a50808fa-e7cd-45ee-b4d4-33ad8c65d472','b0748ef4-bea8-4d85-95a1-7d9db1b4381c','843031ac-521a-4c5b-832e-37a0398a9862','537945fc-b7a3-4661-8144-e3fbcd6b24d0','d48b7246-44bf-4ecc-a4dc-a9bb705c331a','4d742b75-2592-4379-81c0-07ddf436f32b','6e4b8efc-e324-404a-a8c7-b4c39b8070b8','559606f3-f3a0-401d-9e8c-7685624bb880','7fef3cc6-ec43-49a2-a740-cd9f4ee1c31a','20341270-6241-45cd-9633-437d3ce80447','32d0749c-6167-45da-8880-bb3f60dd401f','a4704025-1ef8-43c9-9e5b-113582a7e621','6c56bb2f-4936-4c43-873e-dde65fe42d2b','001f907c-8f32-4758-8a16-ad1730e72c59','e6cc70fa-7ef3-4eaf-afb7-4ca6f588c2b4','efd15ad1-c1ae-4495-aaa5-0f9415f4be0a','e0456437-21d5-4a04-9d8a-9bffbf87c26d','4056f62d-77f3-47f9-8ecb-9a7799682a9d','65b30dec-6f9f-459e-b78c-49173d74f251','f3673da7-42c9-497e-abe1-1c0982429f35','1ab6d359-f337-45ed-839c-4e626d2e2819'));
  ability:=ability||jsonb_build_array(jsonb_build_object('source','clan','id',d->'technique_id','name',d->'name','kind','abilita',
   'usage','passiva','consumption_type','passiva','chakra_cost',NULL,'defensive',false,'di_scena',false,'diversivo',false));
  snap:=jsonb_set(snap,'{abilities}',ability,true)||jsonb_build_object('innata_staff_profile',mark,'innata_staff_required_grade',d->'required_grade',
   'innata_permission_fact',clan_innata_narrative_private.permission_fact_v2(c.context_id));
  -- Permission does not alter statistics; required KG/grade remain simulated eligibility metadata only.
  UPDATE public.combat_v2_actors SET mechanics_snapshot=snap WHERE id=a.id;
  IF clan_innata_narrative_private.staff_profile_actor_v1(a.id)IS NULL THEN RAISE EXCEPTION 'INNATA_PERMISSION_BIND_INVALID' USING ERRCODE='42501';END IF;
  RETURN;
 END IF;
 SELECT jsonb_build_object('source','clan','id',t.id,'name',t.name,'kind',coalesce(t.category,'fisico'),'usage',t.uso,'defensive',coalesce(t.difensiva,false),
 'di_scena',coalesce(t.di_scena,false),'diversivo',false,'consumption_type','per_turno','range',t.gittata,'chakra_cost',q.activation_cost,'damage_base',coalesce(t.danno_base,0))INTO ability
 FROM public.clan_techniques t JOIN clan_innata_narrative_private.config_quotes_v1 q ON q.technique_id=t.id WHERE t.id=(d->>'technique_id')::uuid;
 SELECT coalesce(jsonb_agg(x ORDER BY x->>'name'),'[]'::jsonb)INTO snap FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]'::jsonb))x
 WHERE NOT EXISTS(SELECT 1 FROM public.clan_techniques t WHERE t.id::text=x->>'id'AND x->>'source'='clan'AND(t.is_innata OR t.id IN('94c45ec9-78c7-423e-9045-4b4cf2104b15'::uuid,'d2d98dad-fb9f-4ff1-b6b2-3d3f2d222fae'::uuid,'6d264e00-1db3-4daa-b7cc-e5f011e1dab1'::uuid,'2fb3e027-a4ff-4058-9d5d-0212facb3f68'::uuid,'bc2569b5-eab4-44b4-9843-c199724caff4'::uuid,'09097efd-e162-4cae-a644-5e643fe94f8c'::uuid,'dd2026b4-bffc-490e-8646-be411d4746b3'::uuid,'fdf79ce1-1c5b-44c4-aaa1-789be08e01de'::uuid,'ed808bc6-57f6-4853-80bf-9e6985ca0cc3'::uuid,'41254b82-5b5e-46e9-9820-b3d604bbe38f'::uuid,'2fb9e210-225d-460a-a9f9-39ee64f8fce1'::uuid,'ab64415a-cca3-472f-9203-84ad60c09405'::uuid,'4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid,'b0748ef4-bea8-4d85-95a1-7d9db1b4381c'::uuid,'843031ac-521a-4c5b-832e-37a0398a9862'::uuid,'537945fc-b7a3-4661-8144-e3fbcd6b24d0'::uuid,'d48b7246-44bf-4ecc-a4dc-a9bb705c331a'::uuid,'4d742b75-2592-4379-81c0-07ddf436f32b'::uuid,'6e4b8efc-e324-404a-a8c7-b4c39b8070b8'::uuid,'559606f3-f3a0-401d-9e8c-7685624bb880'::uuid,'7fef3cc6-ec43-49a2-a740-cd9f4ee1c31a'::uuid,'20341270-6241-45cd-9633-437d3ce80447'::uuid,'32d0749c-6167-45da-8880-bb3f60dd401f'::uuid,'a4704025-1ef8-43c9-9e5b-113582a7e621'::uuid,'6c56bb2f-4936-4c43-873e-dde65fe42d2b'::uuid,'001f907c-8f32-4758-8a16-ad1730e72c59'::uuid,'e6cc70fa-7ef3-4eaf-afb7-4ca6f588c2b4'::uuid,'efd15ad1-c1ae-4495-aaa5-0f9415f4be0a'::uuid,'e0456437-21d5-4a04-9d8a-9bffbf87c26d'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)));
 snap:=jsonb_set(a.mechanics_snapshot,'{abilities}',snap||jsonb_build_array(ability),false);
 snap:=jsonb_set(snap,'{kekkei_genkai}',to_jsonb((d->>'required_kg')::integer),false);
 snap:=snap||jsonb_build_object('innata_staff_profile',mark,'innata_staff_required_grade',d->'required_grade');
 UPDATE public.combat_v2_actors SET mechanics_snapshot=snap WHERE id=a.id;
 req:=extensions.uuid_generate_v5(c.context_id,a.id::text||':innata-profile:'||(c.staff_ability_profile->>'version'));
 IF d->>'profile_key'='sabaku-l1' THEN
  INSERT INTO clan_sabaku_private.staff_profiles(session_id,actor_id,request_id,receipt_id,bind_result)
  VALUES(s.id,a.id,req,req,jsonb_build_object('operation','staff_profile','profile_context',c.context_id,'profile_version',c.staff_ability_profile->'version','is_test',true,'values_written',false));
  IF NOT EXISTS(SELECT 1 FROM clan_sabaku_private.reserves WHERE session_id=s.id AND actor_id=a.id AND is_test)THEN
   SELECT r.* INTO prior FROM clan_sabaku_private.reserves r JOIN public.combat_v2_sessions cs ON cs.id=r.session_id
   WHERE r.character_id=a.character_id AND r.is_test AND cs.location_id=s.location_id AND cs.closed_at IS NOT NULL ORDER BY cs.closed_at DESC LIMIT 1;
   INSERT INTO clan_sabaku_private.reserves(character_id,session_id,actor_id,is_test,capacity,current_amount)
   VALUES(a.character_id,s.id,a.id,true,15,CASE WHEN prior.id IS NULL THEN 15 ELSE least(15,prior.current_amount)END);
  END IF;
 ELSE
  INSERT INTO clan_hyuga_private.staff_profiles(session_id,actor_id,profile_version,created_request,is_active)
  VALUES(s.id,a.id,(d->>'profile_key')||'/1',req,true);
 END IF;
 IF clan_innata_narrative_private.staff_profile_actor_v1(a.id)IS NULL THEN RAISE EXCEPTION 'INNATA_PROFILE_BIND_INVALID' USING ERRCODE='42501';END IF;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.permission_role_link_v2(p_message uuid,p_character uuid,p_location uuid) RETURNS void
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path='' AS $f$
DECLARE c clan_innata_narrative_private.contexts_v1;f jsonb;link jsonb;old jsonb;doc jsonb;role_master uuid;
BEGIN
 IF p_message IS NULL OR p_location IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN RETURN;END IF;
 IF auth.uid()IS NULL OR NOT public.is_staff()OR NOT EXISTS(SELECT 1 FROM public.characters WHERE id=p_character AND user_id=auth.uid())THEN RETURN;END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('innata-narrative:'||p_character::text,0));
 SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE character_id=p_character AND location_id=p_location ORDER BY created_at DESC,context_id DESC LIMIT 1 FOR UPDATE;
 IF c.context_id IS NULL OR c.staff_ability_profile->>'profile_key'IS NULL THEN RETURN;END IF;
 f:=clan_innata_narrative_private.permission_fact_v2(c.context_id);IF f IS NULL THEN RETURN;END IF;
 IF NOT EXISTS(SELECT 1 FROM public.messages WHERE id=p_message AND character_id=p_character AND location_id=p_location)
 THEN RAISE EXCEPTION 'INNATA_ACCEPTED_MESSAGE_REQUIRED' USING ERRCODE='42501';END IF;
 -- Native message capture has completed inside INSERT before this hook; no role body is read.
 SELECT master_session_id INTO role_master FROM mission_generic_owner.role_submissions WHERE message_id=p_message LIMIT 1;
 IF NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions s JOIN public.combat_v2_actors a ON a.session_id=s.id WHERE a.character_id=p_character AND s.closed_at IS NULL)THEN
  c:=clan_innata_narrative_private.ensure_context_v1(p_character,p_location,role_master,NULL);
  f:=clan_innata_narrative_private.permission_fact_v2(c.context_id);
 END IF;
 link:=jsonb_build_object('schema_version','innata-permission-role-link/1','message_id',p_message,'context_id',c.context_id,'owner_character_id',p_character,
  'master_session_id',role_master,'fact_receipt_id',f->'receipt_id','fact_sha256',f->'sha256','profile_version',f->'profile_version','fact',f,'values_written',false);
 SELECT x INTO old FROM jsonb_array_elements(coalesce(c.staff_ability_profile->'permission_role_links','[]'::jsonb))x WHERE x->>'message_id'=p_message::text;
 IF old IS NOT NULL THEN IF old IS DISTINCT FROM link THEN RAISE EXCEPTION 'INNATA_PERMISSION_ROLE_CONFLICT' USING ERRCODE='40001';END IF;RETURN;END IF;
 doc:=jsonb_set(c.staff_ability_profile,'{permission_role_links}',coalesce(c.staff_ability_profile->'permission_role_links','[]'::jsonb)||jsonb_build_array(link),true);
 UPDATE clan_innata_narrative_private.contexts_v1 SET staff_ability_profile=doc WHERE context_id=c.context_id;
END;
$f$;

CREATE OR REPLACE FUNCTION public.post_message(p_location uuid, p_body text, p_technique uuid DEFAULT NULL::uuid, p_companion uuid DEFAULT NULL::uuid, p_companion_body text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_char public.characters%rowtype;
  v_body text := btrim(coalesce(p_body,''));
  v_cbody text := btrim(coalesce(p_companion_body,''));
  v_id uuid; v_cost int; v_tname text; v_state text; v_len int;
  v_pulito text; v_prefisso text; v_conta text;
  v_sess uuid; v_fase text; v_turn uuid; v_round int; v_part uuid; v_fuori boolean;
  v_cmd jsonb; v_ncmd int := 0; v_motore boolean := false;
  v_bers text; v_target uuid; v_nbers int; v_reaz text; v_rap text; v_sposta int;
  v_colpo boolean := false; v_tecnome text; v_trov jsonb; v_tectrig uuid;
  v_fonte text; v_err text; v_agisce boolean := false; v_libero boolean := false;
  v_guidata boolean := false;
  in74_master uuid;in74_key uuid;in74_activation jsonb;
begin
  if auth.uid() is null then raise exception 'non autenticato'; end if;
  if length(v_body) = 0 and length(v_cbody) = 0 then raise exception 'messaggio vuoto'; end if;
  if length(v_body) > 5000 then raise exception 'messaggio troppo lungo (max 5000)'; end if;
  if length(v_cbody) > 2500 then raise exception 'azione del compagno troppo lunga (max 2500)'; end if;
  if not exists (select 1 from public.locations l where l.id = p_location and l.is_active) then
    raise exception 'luogo non valido'; end if;

  IF EXISTS(SELECT 1 FROM public.master_v2_sessions hm40 JOIN public.locations hl40 ON hl40.id=hm40.location_id AND NOT hl40.is_test AND NOT hl40.is_exam_room JOIN mission_launch_owner.capabilities hc40 ON hc40.mission_id=hm40.mission_id AND hc40.configuration_schema_version='mission-launch-capability/2' JOIN mission_narrative_internal.scene_runtime_v1 hs40 ON hs40.master_session_id=hm40.id AND hs40.is_active JOIN public.master_v2_participants hp40 ON hp40.session_id=hm40.id AND hp40.user_id_snapshot=auth.uid() AND hp40.left_at IS NULL AND hp40.engagement_state='attivo' JOIN public.characters ch40 ON ch40.id=hp40.character_id AND ch40.user_id=auth.uid() WHERE hm40.location_id=p_location AND hm40.owner_kind='ai_service' AND hm40.closed_at IS NULL) AND coalesce(current_setting('app.combat_guidata',true),'')<>'1' THEN
   IF (coalesce(nullif(current_setting('request.headers',true),''),'{}')::jsonb->>'x-tus-client-contract') IS DISTINCT FROM 'mission-narrative-host/1' OR nullif(current_setting('app.mission_role_session',true),'') IS NULL
    OR nullif(current_setting('app.mission_role_command_v2',true),'') IS NULL THEN
    RAISE SQLSTATE 'PT428' USING MESSAGE='Ricarica la pagina e invia l’azione dal pannello della missione.';
   END IF;
  END IF;

  if nullif(current_setting('app.mission_role_session',true),'') is not null
     or nullif(current_setting('app.mission_role_character',true),'') is not null then
    if nullif(current_setting('app.mission_role_session',true),'') is null
       or nullif(current_setting('app.mission_role_character',true),'') is null
    then raise exception 'ROLE_SUBMIT_BINDING_INCOMPLETE' using errcode='42501'; end if;
    if not exists (
      select 1 from public.master_v2_sessions ms
      join public.locations ml on ml.id=ms.location_id
      join mission_generic_owner.flow_staff_sessions fs
        on fs.master_session_id=ms.id and fs.enabled
      join public.master_v2_participants mp
        on mp.session_id=ms.id and mp.user_id_snapshot=auth.uid()
         and mp.character_id=nullif(current_setting('app.mission_role_character',true),'')::uuid
         and mp.left_at is null and mp.engagement_state='attivo'
      where ms.id=nullif(current_setting('app.mission_role_session',true),'')::uuid
        and ms.location_id=p_location and ms.owner_kind='ai_service'
        and ms.closed_at is null and ml.is_test
    ) AND NOT EXISTS(
      SELECT 1 FROM public.master_v2_sessions pm40 JOIN public.locations pl40 ON pl40.id=pm40.location_id AND pl40.is_active AND NOT pl40.is_test AND NOT pl40.is_exam_room
      JOIN public.master_v2_participants pp40 ON pp40.session_id=pm40.id AND pp40.user_id_snapshot=auth.uid()
       AND pp40.character_id=nullif(current_setting('app.mission_role_character',true),'')::uuid AND pp40.left_at IS NULL AND pp40.engagement_state='attivo'
      JOIN public.characters pc40 ON pc40.id=pp40.character_id AND pc40.user_id=auth.uid()
      WHERE pm40.id=nullif(current_setting('app.mission_role_session',true),'')::uuid AND pm40.location_id=p_location
       AND pm40.owner_kind='ai_service' AND pm40.closed_at IS NULL AND EXISTS(SELECT 1 FROM mission_public_owner.session_admissions_v1 s87_ad JOIN mission_public_owner.publications_v2 innata_current_pub ON innata_current_pub.request_key=s87_ad.publication_request AND innata_current_pub.mission_id=s87_ad.mission_id AND innata_current_pub.source_mission_id=s87_ad.mission_id AND innata_current_pub.config_version=s87_ad.capability_version AND innata_current_pub.target='public' AND innata_current_pub.visibility='open' AND innata_current_pub.state='open' WHERE s87_ad.master_session_id=pm40.id AND mission_public_owner.c1266_regia_public_qualification_v1(s87_ad.mission_id,innata_current_pub.release_revision_sha256,false)->>'schema_version'='mission-scene-public-qualification/1' AND mission_public_owner.role_session_allowed_v1(s87_ad.master_session_id))
    ) then raise exception 'ROLE_SUBMIT_BINDING_INVALID' using errcode='42501'; end if;
    select * into v_char from public.characters
      where id=nullif(current_setting('app.mission_role_character',true),'')::uuid
        and user_id=auth.uid();
  else
    select * into v_char from public.characters where user_id = auth.uid() limit 1;
  end if;

  if v_char.id is null then raise exception 'nessun personaggio associato'; end if;
  if p_companion is not null then
    if not exists (select 1 from public.character_companions cc
                   where cc.id = p_companion and cc.character_id = v_char.id and cc.is_active) then
      raise exception 'compagno non valido o non attivo'; end if;
    if length(v_cbody) = 0 then raise exception 'scrivi l''azione del compagno o chiudi il suo riquadro'; end if;
  elsif length(v_cbody) > 0 then raise exception 'compagno non indicato';
  end if;
  if length(v_body) = 0 then v_body := ''; end if;

  v_pulito   := regexp_replace(v_body, '^\s*【[^】]{0,60}】\s*', '');
  v_prefisso := substr(v_body, 1, length(v_body) - length(v_pulito));
  v_libero   := exists (select 1 from public.locations where id = p_location and is_test) and public._puo_test_room();
  -- [GATE UI] alzata da combat_azione: il testo della finestra guidata e' narrativa,
  -- non un comando. Senza questa bandiera, in Test Room lo staff dichiarerebbe due volte.
  v_guidata  := coalesce(current_setting('app.combat_guidata', true), '') = '1';

  select s.id, s.fase, s.turn_of, s.round into v_sess, v_fase, v_turn, v_round
    from public.combat_sessions s where s.location_id = p_location and s.state = 'aperto' limit 1;
  if v_sess is not null then
    select p.id, p.fuori into v_part, v_fuori from public.combat_participants p
     where p.session_id = v_sess and p.user_id = auth.uid() and p.ruolo = 'combattente';
  end if;

  if v_part is not null and not coalesce(v_fuori,false) and v_libero and not v_guidata then
    v_cmd  := public._combat_leggi_comandi(v_pulito);
    v_ncmd := coalesce((v_cmd->>'comandi')::int, 0);
    v_motore := (v_ncmd > 0)
             or (p_technique is not null and v_turn = auth.uid())
             or (v_turn = auth.uid() and (jsonb_array_length(v_cmd->'errori') > 0
                                       or jsonb_array_length(v_cmd->'avvisi') > 0));
  end if;

  if v_part is not null and not coalesce(v_fuori,false) and not v_libero and p_technique is not null then
    raise exception 'Durante uno scontro la tecnica si sceglie dalla finestra dell''azione, non dal testo.';
  end if;

  if exists (select 1 from public.blocked_terms bt
    where bt.category = 'offensive' and length(btrim(bt.term)) > 0
      and case when bt.match = 'exact'
            then (v_body || ' ' || v_cbody) ~* ('\m' || regexp_replace(bt.term, '[^[:alnum:] ]', '', 'g') || '\M')
            else (v_body || ' ' || v_cbody) ilike '%' || bt.term || '%' end
  ) then raise exception 'contenuto non consentito'; end if;

  if v_motore then
    if jsonb_array_length(v_cmd->'errori') > 0 then
      select string_agg(x, ' · ') into v_err from jsonb_array_elements_text(v_cmd->'errori') x;
      raise exception '%', v_err; end if;
    if jsonb_array_length(v_cmd->'avvisi') > 0 then
      select string_agg(x, ' · ') into v_err from jsonb_array_elements_text(v_cmd->'avvisi') x;
      raise exception '%', v_err; end if;
    if v_turn <> auth.uid() then
      raise exception 'Non è il tuo turno: aspetta l''esito prima di dichiarare. Per scrivere di scena, togli i comandi e la tecnica.'; end if;
    v_bers   := v_cmd->>'bersaglio';
    v_sposta := nullif(v_cmd->>'sposta','')::int;
    v_reaz   := v_cmd->>'reazione';
    v_rap    := v_cmd->>'rapida';
    v_colpo  := coalesce((v_cmd->>'colpo')::boolean, false);
    v_tecnome := v_cmd->>'tecnica';
    if v_rap is not null then
      raise exception '[%] non è in vigore: Guardia e le altre azioni rapide sono ritirate.', v_rap; end if;
    if v_reaz is not null and v_fase <> 'difesa' then
      raise exception '[%] è una difesa: si dichiara quando tocca a te difenderti.', v_reaz; end if;
    if v_colpo and p_technique is not null then
      raise exception 'Hai scelto una tecnica e scritto [colpo]: nel tuo turno si fa una sola azione principale. Togline una.'; end if;
    if v_tecnome is not null then
      if p_technique is not null or v_colpo then
        raise exception 'Hai già un''azione principale: [tecnica: …] si gioca da sola.'; end if;
      v_trov := public._combat_trova_tecnica(v_tecnome, v_libero, v_char.id);
      if v_trov ? 'errore' then raise exception '%', v_trov->>'errore'; end if;
      v_tectrig := (v_trov->>'id')::uuid;
      v_fonte   := v_trov->>'fonte';
    end if;
    v_agisce := (p_technique is not null) or (v_tectrig is not null)
             or (v_fase = 'attacco' and (v_bers is not null or v_colpo))
             or (v_fase = 'difesa'  and v_reaz is not null);
    if v_fase = 'attacco' and v_agisce then
      if v_bers is null then
        select count(*), (array_agg(p.user_id))[1] into v_nbers, v_target from public.combat_participants p
         where p.session_id = v_sess and p.ruolo = 'combattente' and not p.fuori and p.user_id <> auth.uid();
        if v_nbers = 0 then raise exception 'non c''è nessuno da attaccare'; end if;
        if v_nbers > 1 then raise exception 'Siete in più di due: scrivi chi attacchi, per esempio [bersaglio %]',
          (select p.character_name from public.combat_participants p where p.session_id = v_sess
            and p.ruolo='combattente' and not p.fuori and p.user_id <> auth.uid() order by p.iniziativa desc limit 1); end if;
      else
        select count(*), (array_agg(p.user_id))[1] into v_nbers, v_target from public.combat_participants p
         where p.session_id = v_sess and p.ruolo = 'combattente' and not p.fuori and p.user_id <> auth.uid()
           and lower(p.character_name) like lower(v_bers) || '%';
        if v_nbers = 0 then raise exception 'Non trovo «%» fra chi sta combattendo.', v_bers; end if;
        if v_nbers > 1 then raise exception '«%» può essere più di uno: scrivi il nome per intero.', v_bers; end if;
      end if;
    end if;
    if v_fase = 'difesa' and not v_agisce and v_sposta is null then
      raise exception 'Tocca a te difenderti: scrivi come ti copri — [schivata] o [parata] — oppure scegli una tecnica di difesa.'; end if;
  end if;

  if v_motore then
    v_pulito := public._combat_togli_trigger(v_pulito, v_cmd->'consumati');
    v_body   := btrim(v_prefisso || v_pulito);
  end if;

  v_conta := public._combat_normalizza(v_pulito);
  v_len := length(btrim(v_conta)) + length(v_cbody);
  if v_len < public._role_soglia_apertura() and not public.is_staff() and not v_libero then
    raise exception 'Un turno di role vuole almeno % caratteri: ne hai scritti %',
      public._role_soglia_apertura(), v_len;
  end if;

  if p_technique is not null then
    select t.chakra_cost, t.name, case when v_libero then 'attiva' else ca.state end
      into v_cost, v_tname, v_state
      from public.clan_techniques t
      left join public.character_abilities ca on ca.technique_id = t.id and ca.character_id = v_char.id
     where t.id = p_technique and t.is_active
       and (ca.character_id is not null or v_libero);
    v_fonte := 'clan';
    if v_tname is null then
      select j.chakra_cost, j.name_it, 'attiva' into v_cost, v_tname, v_state
        from public.jutsu j
        left join public.character_jutsu cj on cj.jutsu_id = j.id and cj.user_id = auth.uid()
       where j.id = p_technique and j.is_active
         and (cj.user_id is not null or v_libero);
      v_fonte := 'jutsu';
    end if;
    if clan_innata_narrative_private.staff_profile_for_character_v1(p_location,NULL::uuid,v_char.id)is not null
     and p_technique in('94c45ec9-78c7-423e-9045-4b4cf2104b15'::uuid,'d2d98dad-fb9f-4ff1-b6b2-3d3f2d222fae'::uuid,'6d264e00-1db3-4daa-b7cc-e5f011e1dab1'::uuid,'2fb3e027-a4ff-4058-9d5d-0212facb3f68'::uuid,'bc2569b5-eab4-44b4-9843-c199724caff4'::uuid,'09097efd-e162-4cae-a644-5e643fe94f8c'::uuid,'dd2026b4-bffc-490e-8646-be411d4746b3'::uuid,'fdf79ce1-1c5b-44c4-aaa1-789be08e01de'::uuid,'ed808bc6-57f6-4853-80bf-9e6985ca0cc3'::uuid,'41254b82-5b5e-46e9-9820-b3d604bbe38f'::uuid,'2fb9e210-225d-460a-a9f9-39ee64f8fce1'::uuid,'ab64415a-cca3-472f-9203-84ad60c09405'::uuid,'4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid,'b0748ef4-bea8-4d85-95a1-7d9db1b4381c'::uuid,'843031ac-521a-4c5b-832e-37a0398a9862'::uuid,'537945fc-b7a3-4661-8144-e3fbcd6b24d0'::uuid,'d48b7246-44bf-4ecc-a4dc-a9bb705c331a'::uuid,'4d742b75-2592-4379-81c0-07ddf436f32b'::uuid,'6e4b8efc-e324-404a-a8c7-b4c39b8070b8'::uuid,'559606f3-f3a0-401d-9e8c-7685624bb880'::uuid,'7fef3cc6-ec43-49a2-a740-cd9f4ee1c31a'::uuid,'20341270-6241-45cd-9633-437d3ce80447'::uuid,'32d0749c-6167-45da-8880-bb3f60dd401f'::uuid,'a4704025-1ef8-43c9-9e5b-113582a7e621'::uuid,'6c56bb2f-4936-4c43-873e-dde65fe42d2b'::uuid,'001f907c-8f32-4758-8a16-ad1730e72c59'::uuid,'e6cc70fa-7ef3-4eaf-afb7-4ca6f588c2b4'::uuid,'efd15ad1-c1ae-4495-aaa5-0f9415f4be0a'::uuid,'e0456437-21d5-4a04-9d8a-9bffbf87c26d'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)
     and not clan_innata_narrative_private.command_admitted_v1(p_location,v_char.id,p_technique)then
      raise exception 'INNATA_PROFILE_TECHNIQUE_NOT_ACTIVATABLE' using errcode='42501';end if;
    if v_tname is null or v_state is distinct from 'attiva' then
      raise exception 'tecnica non disponibile o non ancora attiva'; end if;
    v_cost := coalesce(v_cost,0);
    if not v_motore then
      if not v_guidata and clan_innata_narrative_private.command_admitted_v1(p_location,v_char.id,p_technique) then
        select ms.id into in74_master from public.master_v2_sessions ms join public.master_v2_participants mp
          on mp.session_id=ms.id and mp.character_id=v_char.id and mp.user_id_snapshot=auth.uid()
          and mp.left_at is null and mp.engagement_state='attivo'
         where ms.location_id=p_location and ms.closed_at is null order by ms.created_at desc limit 1;
        in74_key:=gen_random_uuid();
        in74_activation:=clan_innata_narrative_private.activate_v1(p_location,in74_master,v_char.id,p_technique,in74_key);
      elsif v_cost > 0 and coalesce(v_char.chakra_max,0) > 0
         and not exists (select 1 from public.locations where id = p_location and is_test) then
        if coalesce(v_char.chakra,0) < v_cost then
          raise exception 'Chakra insufficiente: servono % (ne hai %)', v_cost, coalesce(v_char.chakra,0); end if;
        perform set_config('app.allow_chakra_delta','1', true);
        update public.characters set chakra = chakra - v_cost where id = v_char.id;
      end if;
      v_body := v_body || '  〈' || v_tname || '〉';
    end if;
  end if;

  if not (v_motore and length(btrim(v_pulito)) = 0 and length(v_cbody) = 0) then
    -- [ROLE-REC-AUTOSTART-006] Gettone di transazione monouso per trg_role_autojoin:
    -- porta al trigger il conteggio che il server ha appena calcolato, insieme al
    -- luogo per cui vale. E' l'unico punto del database che lo deposita, ed e' per
    -- questo che nessun altro percorso di scrittura in messages puo' aprire una REC.
    -- Sta DENTRO questo `if`: se il messaggio non si scrive, il gettone non nasce.
    perform set_config('app.role_turno', p_location::text || ':' || v_len::text, true);
    insert into public.messages(location_id, character_id, author_name, body, companion_id, companion_body)
    values (p_location, v_char.id, v_char.name, v_body, p_companion, nullif(v_cbody,''))
    returning id into v_id;
    perform clan_innata_narrative_private.permission_role_link_v2(v_id,v_char.id,p_location);
    if in74_key is not null then perform clan_innata_narrative_private.link_message_v1(v_id,v_char.id,p_technique,in74_key);end if;
  end if;
  insert into public.presence(user_id, last_seen, location_id) values (auth.uid(), now(), p_location)
    on conflict (user_id) do update set last_seen = now(), location_id = excluded.location_id;

  if v_motore then
    if v_sposta is not null then perform public.combat_muovi(v_sess, v_sposta); end if;
    if v_agisce then
      if v_fase = 'attacco' then
        perform public.combat_dichiara_attacco(v_sess, v_target, null, coalesce(p_technique, v_tectrig), v_fonte, null, null, false);
      else
        perform public.combat_dichiara_difesa(v_sess, coalesce(v_reaz,'schivata'), coalesce(p_technique, v_tectrig));
      end if;
    end if;
  end if;
  return v_id;
end; $function$;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.materialize_v1(p_session uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE s public.combat_v2_sessions;l public.locations;a public.combat_v2_actors;
 c clan_innata_narrative_private.contexts_v1;st record;canonical record;first_round uuid;fp text;receipt jsonb;
 native_context clan_innata_combat_private.actor_context;
BEGIN
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=p_session FOR UPDATE;
 IF NOT EXISTS(SELECT 1 FROM clan_innata_narrative_private.gate_v1 g JOIN public.locations gate_location ON gate_location.id=s.location_id
 WHERE g.singleton AND CASE WHEN gate_location.is_test THEN g.staff_enabled ELSE g.public_enabled END)THEN RETURN;END IF;
 SELECT * INTO STRICT l FROM public.locations WHERE id=s.location_id;
 SELECT id INTO first_round FROM public.combat_v2_rounds WHERE session_id=s.id ORDER BY round_no,id LIMIT 1;
 IF first_round IS NULL THEN RAISE EXCEPTION 'INNATA_FIRST_ROUND_REQUIRED' USING ERRCODE='55000';END IF;
 -- Legacy non-Common openings are not repaired by a reader. Their normal binding must precede this hook.
 IF s.master_session_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM combat_panel_private.master_panel_sessions WHERE master_session_id=s.master_session_id)
 THEN RAISE EXCEPTION 'INNATA_COMMON_BINDING_REQUIRED' USING ERRCODE='55000';END IF;
 FOR a IN SELECT * FROM public.combat_v2_actors WHERE session_id=s.id AND actor_kind='pg'AND companion_id IS NULL ORDER BY character_id LOOP
  PERFORM pg_advisory_xact_lock(hashtextextended('innata-narrative:'||a.character_id::text,0));
  IF l.is_test THEN
   SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE character_id=a.character_id AND location_id=l.id
    ORDER BY created_at DESC,context_id DESC LIMIT 1 FOR UPDATE;
   IF NOT FOUND THEN CONTINUE;END IF;
   IF c.bound_combat_session_id=s.id THEN
    IF NOT EXISTS(SELECT 1 FROM clan_innata_narrative_private.materializations_v1 x WHERE x.context_id=c.context_id AND x.combat_session_id=s.id AND x.actor_id=a.id)
    THEN RAISE EXCEPTION 'INNATA_MATERIALIZATION_RECEIPT_REQUIRED' USING ERRCODE='40001';END IF;
    CONTINUE;
   END IF;
   c:=clan_innata_narrative_private.ensure_context_v1(a.character_id,l.id,s.master_session_id,a.mechanics_snapshot);
   IF public.combat_v2_values_written(s.id) OR l.id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    OR (a.mechanics_snapshot->>'chakra_max')::integer IS DISTINCT FROM c.chakra_max
   THEN RAISE EXCEPTION 'INNATA_PROTECTED_RESOURCE_SCOPE_CHANGED' USING ERRCODE='40001';END IF;
   PERFORM clan_innata_narrative_private.staff_profile_bind_v1(c.context_id,a.id);
   UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(mechanics_snapshot,'{chakra}',to_jsonb(c.chakra),false)WHERE id=a.id;
   -- Activation occurred in the previous narrative round, not this Combat round.
   -- Leave first upkeep pending for the existing native legal-turn mechanism.
   FOR st IN SELECT * FROM clan_innata_narrative_private.states_v1 WHERE context_id=c.context_id ORDER BY technique_id LOOP
    INSERT INTO clan_innata_combat_private.combat_state(session_id,actor_id,technique_id,is_test,active,state_version,activated_round_id,last_upkeep_round_id)
     VALUES(s.id,a.id,st.technique_id,true,st.active,st.state_version,NULL::uuid,NULL::uuid);
    INSERT INTO clan_innata_narrative_private.carry_receipts_v1(session_id,actor_id,technique_id,first_round_id,source_kind,source_id,state_version,active,receipt)
    VALUES(s.id,a.id,st.technique_id,first_round,'protected_context',c.context_id,st.state_version,st.active,
    jsonb_build_object('schema_version','innata-carry/1','activation_cost',0,'source_context',c.context_id,'source_version',st.state_version,'active',st.active,'is_test',true,'values_written',false));
   END LOOP;
   fp:=public.combat_v2_sha256(jsonb_build_object('context',c.context_id,'session',s.id,'actor',a.id,'chakra',c.chakra,
    'permission_fact',clan_innata_narrative_private.permission_fact_v2(c.context_id),'permission_role_links',coalesce(c.staff_ability_profile->'permission_role_links','[]'::jsonb),
    'states',(SELECT jsonb_agg(to_jsonb(x)ORDER BY technique_id)FROM clan_innata_narrative_private.states_v1 x WHERE x.context_id=c.context_id)));
   receipt:=jsonb_build_object('schema_version','innata-narrative-materialization/1','context_id',c.context_id,'session_id',s.id,
    'actor_id',a.id,'chakra',c.chakra,'activation_cost',0,'values_written',false,'fingerprint',fp,
    'permission_fact',clan_innata_narrative_private.permission_fact_v2(c.context_id),
    'permission_role_links',coalesce(c.staff_ability_profile->'permission_role_links','[]'::jsonb));
   INSERT INTO clan_innata_narrative_private.materializations_v1(context_id,combat_session_id,actor_id,fingerprint,receipt)
    VALUES(c.context_id,s.id,a.id,fp,receipt);
   UPDATE clan_innata_narrative_private.contexts_v1 SET bound_combat_session_id=s.id WHERE context_id=c.context_id;
  ELSE
   IF NOT public.combat_v2_values_written(s.id) THEN CONTINUE;END IF;
   FOR canonical IN SELECT x.* FROM clan_innata_private.actor_state x JOIN clan_innata_narrative_private.config_quotes_v1 q ON q.technique_id=x.technique_id
    WHERE x.actor_id=a.character_id ORDER BY x.technique_id LOOP
    INSERT INTO clan_innata_combat_private.combat_state(session_id,actor_id,technique_id,is_test,active,state_version,activated_round_id,last_upkeep_round_id)
     VALUES(s.id,a.id,canonical.technique_id,false,canonical.active,canonical.state_version,
      NULL::uuid,NULL::uuid)
     ON CONFLICT(session_id,actor_id,technique_id)DO NOTHING;
    IF NOT EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_state cs WHERE cs.session_id=s.id AND cs.actor_id=a.id
    AND cs.technique_id=canonical.technique_id AND NOT cs.is_test AND cs.active=canonical.active AND cs.state_version=canonical.state_version)
    THEN RAISE EXCEPTION 'INNATA_CARRY_STATE_DRIFT' USING ERRCODE='40001';END IF;
    INSERT INTO clan_innata_narrative_private.carry_receipts_v1(session_id,actor_id,technique_id,first_round_id,source_kind,source_id,state_version,active,receipt)
    VALUES(s.id,a.id,canonical.technique_id,first_round,'canonical_actor_state',a.character_id,canonical.state_version,canonical.active,
    jsonb_build_object('schema_version','innata-carry/1','activation_cost',0,'source_character',a.character_id,'source_version',canonical.state_version,
    'source_receipt_id',canonical.source_receipt_id,'active',canonical.active,'is_test',false,'values_written',false))
    ON CONFLICT(session_id,actor_id,technique_id)DO NOTHING;
   END LOOP;
  END IF;
 END LOOP;
 -- SP06: constructors may establish the native first turn before narrative
 -- carry exists. Re-enter only its legal own-turn lifecycle after all PG
 -- states, receipts and context bindings are complete. Native keys/last_upkeep
 -- retain replay idempotence, including Master geometry binding's second hook.
 IF l.is_test AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  AND s.closed_at IS NULL AND NOT public.combat_v2_values_written(s.id) THEN
  FOR a IN SELECT carried_actor.* FROM public.combat_v2_actors carried_actor
   WHERE carried_actor.session_id=s.id AND carried_actor.actor_kind='pg'
    AND carried_actor.companion_id IS NULL AND carried_actor.state='attivo'
    AND EXISTS(SELECT 1 FROM clan_innata_narrative_private.materializations_v1 mat
     JOIN clan_innata_narrative_private.contexts_v1 bound_context ON bound_context.context_id=mat.context_id
     WHERE mat.combat_session_id=s.id AND mat.actor_id=carried_actor.id
      AND bound_context.bound_combat_session_id=s.id)
    AND EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_state carried_state
     WHERE carried_state.session_id=s.id AND carried_state.actor_id=carried_actor.id
      AND carried_state.is_test AND carried_state.active)
   ORDER BY carried_actor.character_id,carried_actor.id LOOP
   native_context:=clan_innata_private.combat_context(a.id);
   IF native_context.session_id=s.id AND native_context.location_id=l.id
    AND native_context.policy_id='staff_test_no_persistent_resources_v1'
    AND native_context.phase='action' AND native_context.turn_actor_id=a.id THEN
    PERFORM clan_innata_private.combat_begin_turn(a.id);
   END IF;
  END LOOP;
 END IF;
END $function$;

CREATE OR REPLACE FUNCTION clan_aburame_private.staff_scope(p_actor uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT CASE WHEN coalesce(clan_innata_narrative_private.staff_profile_actor_v1(p_actor)->>'family','')='aburame' THEN EXISTS(SELECT 1 FROM clan_aburame_private.release_gate WHERE singleton AND staff_enabled) ELSE EXISTS(
  SELECT 1 FROM public.combat_v2_actors a
  JOIN public.combat_v2_sessions s ON s.id=a.session_id AND s.source_kind IN ('ordinary','master')
  JOIN public.locations l ON l.id=s.location_id AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND l.is_test AND l.is_active
  WHERE a.id=p_actor AND a.actor_kind='pg' AND a.state='attivo'
    AND a.character_id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
    AND a.controller_user='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid
    AND s.closed_at IS NULL AND s.state NOT IN ('chiusa','annullata')
    AND NOT public.combat_v2_values_written(s.id)
    AND ((s.source_kind='ordinary' AND EXISTS(SELECT 1 FROM combat_consumer_private.activities c
      WHERE c.session_id=s.id AND c.location_id=s.location_id AND c.policy_id='staff_test_no_persistent_resources_v1'
       AND c.phase<>'closed' AND c.closed_at IS NULL)
      AND combat_consumer_private.staff_test_allowed(l.id,ARRAY(
       SELECT DISTINCT x.controller_user FROM public.combat_v2_actors x WHERE x.session_id=s.id ORDER BY x.controller_user),false))
     OR (s.source_kind='master' AND s.master_session_id IS NOT NULL AND EXISTS(SELECT 1 FROM public.master_v2_sessions m
       WHERE m.id=s.master_session_id AND m.location_id=l.id AND m.stato NOT IN ('chiusa','annullata'))))
 ) AND EXISTS(SELECT 1 FROM clan_aburame_private.release_gate WHERE singleton AND staff_enabled)END
$function$;

CREATE OR REPLACE FUNCTION clan_aburame_private.actor_allowed(p_actor uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$

 SELECT CASE WHEN clan_innata_narrative_private.staff_profile_actor_v1(p_actor)IS NOT NULL THEN
  (clan_innata_narrative_private.staff_profile_actor_v1(p_actor)->>'family')='aburame'
  AND EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN clan_aburame_private.colonies c ON c.owner_id=a.character_id AND c.scope_id=a.session_id WHERE a.id=p_actor)
  AND EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.characters ch ON ch.id=a.character_id WHERE a.id=p_actor AND ch.clan='Aburame'AND clan_aburame_private.passive_permission(ch.id)IS NOT NULL)
 ELSE clan_aburame_private.staff_scope(p_actor) OR clan_aburame_private.public_scope(p_actor)END

$function$;

CREATE OR REPLACE FUNCTION clan_aburame_private.actor_has_technique(p_actor uuid, p_technique uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT clan_aburame_private.actor_allowed(p_actor) AND (
  (clan_innata_narrative_private.staff_profile_actor_v1(p_actor)IS NULL AND clan_aburame_private.staff_scope(p_actor)) OR EXISTS(
   SELECT 1 FROM public.combat_v2_actors a CROSS JOIN LATERAL jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]')) x
   WHERE a.id=p_actor AND x->>'source'='clan' AND (x->>'id')::uuid=p_technique))
$function$;

CREATE OR REPLACE FUNCTION clan_aburame_private.ensure_scope(p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE;c public.characters%ROWTYPE;scope uuid;kind text;root uuid;r jsonb;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 SELECT * INTO STRICT c FROM public.characters WHERE id=a.character_id;
 IF clan_aburame_private.simulation_scope(p_actor) THEN scope:=a.session_id;kind:='simulation';root:=p_actor;
 ELSIF clan_aburame_private.public_scope(p_actor) THEN scope:=c.id;kind:='persistent';root:=c.id;
 ELSE RAISE EXCEPTION 'aburame_actor_not_allowed' USING ERRCODE='42501';END IF;
 IF clan_innata_narrative_private.staff_profile_actor_v1(p_actor)IS NOT NULL AND NOT EXISTS(SELECT 1 FROM clan_aburame_private.colonies WHERE owner_id=c.id AND scope_id=scope)THEN RAISE EXCEPTION 'INNATA_CAPABILITY_AUTHORITY_UNAVAILABLE' USING ERRCODE='42501';END IF;
 IF NOT EXISTS(SELECT 1 FROM clan_aburame_private.colonies WHERE owner_id=c.id AND scope_id=scope) THEN
  r:=clan_aburame_private.colony_transition(c.id,scope,kind,'initialize',root,0,NULL,0,c.kekkei_genkai);
 END IF;
 RETURN jsonb_build_object('owner',c.id,'scope',scope,'scope_kind',kind);
END $function$;

CREATE OR REPLACE FUNCTION clan_inuzuka_private.owner_scope(p_actor uuid, p_require_quattro boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE actor public.combat_v2_actors%ROWTYPE;pg public.characters%ROWTYPE;
 session public.combat_v2_sessions%ROWTYPE;context clan_innata_combat_private.actor_context;
 gate clan_inuzuka_private.release_gate%ROWTYPE;principals uuid[];characters_in_scene uuid[];
 pg_count integer;is_test boolean;staff_scope boolean:=false;user_test_scope boolean:=false;
BEGIN
 SELECT * INTO actor FROM public.combat_v2_actors WHERE id=p_actor;
 IF NOT FOUND OR actor.actor_kind<>'pg' OR actor.companion_id IS NOT NULL OR actor.controller_user IS NULL
  OR actor.state<>'attivo' OR coalesce((actor.mechanics_snapshot->>'vita')::integer,0)<=0 THEN
  RAISE EXCEPTION 'inuzuka_actor_not_available' USING ERRCODE='42501';END IF;
 context:=clan_innata_private.combat_context(actor.id);
 SELECT * INTO STRICT session FROM public.combat_v2_sessions WHERE id=actor.session_id;
 SELECT * INTO STRICT gate FROM clan_inuzuka_private.release_gate WHERE singleton;
 IF session.closed_at IS NOT NULL OR session.state IN ('chiuso','annullato','sospeso')
  OR session.location_id IS DISTINCT FROM context.location_id OR context.phase IN ('closed','setup','suspended') THEN
  RAISE EXCEPTION 'inuzuka_session_not_available' USING ERRCODE='42501';END IF;
 IF context.activity_kind='ordinary_v2' THEN
  IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.members m WHERE m.session_id=actor.session_id
   AND m.actor_id=actor.id AND m.character_id=actor.character_id) THEN
   RAISE EXCEPTION 'inuzuka_member_not_registered' USING ERRCODE='42501';END IF;
 ELSIF context.activity_kind='master_v2' THEN
  IF context.personal_turn_id IS NULL THEN RAISE EXCEPTION 'inuzuka_master_turn_required' USING ERRCODE='42501';END IF;
 ELSE RAISE EXCEPTION 'inuzuka_activity_not_supported' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT pg FROM public.characters WHERE id=actor.character_id AND user_id=actor.controller_user;
 IF p_require_quattro AND clan_innata_narrative_private.staff_profile_actor_v1(p_actor)IS NOT NULL AND(
  clan_innata_narrative_private.staff_profile_actor_v1(p_actor)->>'family'IS DISTINCT FROM 'inuzuka'OR pg.clan IS DISTINCT FROM 'Inuzuka'
  OR NOT EXISTS(SELECT 1 FROM public.character_abilities ca WHERE ca.character_id=pg.id AND ca.technique_id='b0748ef4-bea8-4d85-95a1-7d9db1b4381c'::uuid AND ca.state='attiva')
  OR NOT EXISTS(SELECT 1 FROM public.character_abilities ca WHERE ca.character_id=pg.id AND ca.technique_id='c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid AND ca.state='attiva'))
 THEN RAISE EXCEPTION 'INNATA_CAPABILITY_AUTHORITY_UNAVAILABLE' USING ERRCODE='42501';END IF;
 is_test:=NOT public.combat_v2_values_written(actor.session_id);
 IF is_test AND context.policy_id='staff_test_no_persistent_resources_v1'
  AND context.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN
  SELECT count(*),array_agg(DISTINCT x.controller_user ORDER BY x.controller_user),
      array_agg(DISTINCT x.character_id ORDER BY x.character_id)
   INTO pg_count,principals,characters_in_scene
  FROM public.combat_v2_actors x JOIN public.characters c ON c.id=x.character_id AND c.user_id=x.controller_user
  WHERE x.session_id=actor.session_id AND x.actor_kind='pg' AND x.companion_id IS NULL;
  IF NOT gate.staff_enabled OR context.policy_id IS DISTINCT FROM 'staff_test_no_persistent_resources_v1'
   OR context.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   OR pg_count<>2 OR cardinality(principals) IS DISTINCT FROM 2
   OR(coalesce(clan_innata_narrative_private.staff_profile_actor_v1(p_actor)->>'family','')<>'inuzuka'AND characters_in_scene IS DISTINCT FROM ARRAY['2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid])
   OR NOT combat_consumer_private.staff_test_allowed(context.location_id,principals,false) THEN
   RAISE EXCEPTION 'inuzuka_staff_scope_invalid' USING ERRCODE='42501';END IF;
  staff_scope:=true;
 ELSIF is_test AND context.policy_id='user_test_private_no_persistent_resources_v1'
  AND EXISTS(SELECT 1 FROM user_testroom_common_private.contexts t
    WHERE t.id=session.id AND t.owner_user=actor.controller_user AND t.character_id=actor.character_id
      AND t.pg_actor_id=actor.id AND t.location_id=context.location_id AND t.state='active') THEN
  IF NOT gate.staff_enabled OR actor.character_id IS DISTINCT FROM '2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
   OR actor.controller_user IS DISTINCT FROM '15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid THEN
   RAISE EXCEPTION 'inuzuka_user_test_scope_invalid' USING ERRCODE='42501';END IF;
  user_test_scope:=true;
 ELSE
  IF NOT gate.public_enabled OR pg.clan IS DISTINCT FROM 'Inuzuka'
   OR coalesce(pg.kekkei_genkai,0)<30 OR coalesce(public._grade_rank(pg.rank),-1)<public._grade_rank('Genin')
   OR (context.activity_kind='ordinary_v2'
      AND context.policy_id IS DISTINCT FROM 'free_duel_nonlethal_real_resources_v1')
   OR (context.activity_kind='master_v2' AND context.policy_id IS DISTINCT FROM 'master_game_resources_v1')
   OR NOT EXISTS(SELECT 1 FROM public.character_abilities ca WHERE ca.character_id=pg.id
      AND ca.technique_id='b0748ef4-bea8-4d85-95a1-7d9db1b4381c' AND ca.state='attiva')
   OR (p_require_quattro AND NOT EXISTS(SELECT 1 FROM public.character_abilities ca WHERE ca.character_id=pg.id
      AND ca.technique_id='c11ecd52-43cd-479b-8d5d-08187beba56e' AND ca.state='attiva')) THEN
   RAISE EXCEPTION 'inuzuka_not_eligible' USING ERRCODE='42501';END IF;
 END IF;
 RETURN jsonb_build_object('actor_id',actor.id,'session_id',actor.session_id,'character_id',actor.character_id,
  'round_id',context.exchange_id,'personal_turn_id',context.personal_turn_id,'activity_kind',context.activity_kind,
  'context_version',context.context_version,'is_test',is_test,'staff_scope',staff_scope,'user_test_scope',user_test_scope,'policy_id',context.policy_id,
  'turn_owner',context.turn_actor_id=actor.id,'phase',context.phase);
END $function$;

CREATE OR REPLACE FUNCTION clan_inuzuka_private.staff_profile_needed(p_actor uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE scope jsonb;a public.combat_v2_actors%ROWTYPE;required uuid[]:=ARRAY[
 'b0748ef4-bea8-4d85-95a1-7d9db1b4381c'::uuid,
 'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid,
 'b076a976-c75b-4b5a-8813-b0e8e2c3af03'::uuid];
BEGIN
 IF clan_innata_narrative_private.staff_profile_actor_v1(p_actor)IS NOT NULL THEN RETURN false;END IF;
 BEGIN scope:=clan_inuzuka_private.owner_scope(p_actor,false);
 EXCEPTION WHEN insufficient_privilege OR no_data_found THEN RETURN false;END;
 IF coalesce((scope->>'staff_scope')::boolean,false) IS NOT TRUE THEN RETURN false;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind='pg' AND state='attivo';
 IF NOT FOUND THEN RETURN false;END IF;
 RETURN EXISTS(SELECT 1 FROM unnest(required) id WHERE NOT EXISTS(
  SELECT 1 FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]')) ability
  WHERE ability->>'source'='clan' AND ability->>'id'=id::text));
END $function$;

CREATE OR REPLACE FUNCTION clan_inuzuka_private.staff_profile_apply(p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE scope jsonb;a public.combat_v2_actors%ROWTYPE;abilities jsonb;item jsonb;
 canonical constant jsonb:=jsonb_build_array(
  jsonb_build_object('id','b0748ef4-bea8-4d85-95a1-7d9db1b4381c','name','Simbiosi coi Ninken',
   'source','clan','kind','abilita','usage','passiva','range','personale','chakra_cost',0,
   'damage_base',0,'defensive',false,'di_scena',false,'diversivo',false,'consumption_type','passiva'),
  jsonb_build_object('id','c11ecd52-43cd-479b-8d5d-08187beba56e','name','Quattro Zampe',
   'source','clan','kind','ninjutsu','usage','rapida','range','personale','chakra_cost',5,
   'damage_base',0,'defensive',false,'di_scena',false,'diversivo',false,'consumption_type','per_turno'),
  jsonb_build_object('id','b076a976-c75b-4b5a-8813-b0e8e2c3af03','name','Zanna Perforante',
   'source','clan','kind','fisico','usage','principale','range','contatto','chakra_cost',5,
   'damage_base',10,'power_base',15,'defense_base',10,'defensive',false,'di_scena',false,
   'diversivo',false,'consumption_type','ad_utilizzo'));
BEGIN
 IF clan_innata_narrative_private.staff_profile_actor_v1(p_actor)IS NOT NULL THEN RAISE EXCEPTION 'INNATA_CAPABILITY_AUTHORITY_UNAVAILABLE' USING ERRCODE='42501';END IF;
 scope:=clan_inuzuka_private.owner_scope(p_actor,false);
 IF coalesce((scope->>'staff_scope')::boolean,false) IS NOT TRUE THEN
  RAISE EXCEPTION 'inuzuka_staff_profile_scope_invalid' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind='pg'
  AND controller_user=auth.uid() AND state='attivo' FOR UPDATE;
 abilities:=coalesce(a.mechanics_snapshot->'abilities','[]');
 FOR item IN SELECT value FROM jsonb_array_elements(canonical) LOOP
  IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(abilities) old
    WHERE old->>'source'='clan' AND old->>'id'=item->>'id') THEN
   abilities:=abilities||jsonb_build_array(item);END IF;
 END LOOP;
 UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(mechanics_snapshot,'{abilities}',abilities,true)
  WHERE id=a.id;
 RETURN jsonb_build_object('operation','staff_profile','actor_id',a.id,'values_written',false,
  'abilities',jsonb_build_array('b0748ef4-bea8-4d85-95a1-7d9db1b4381c','c11ecd52-43cd-479b-8d5d-08187beba56e','b076a976-c75b-4b5a-8813-b0e8e2c3af03'));
END $function$;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.consumer_options(p jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare sid uuid;aid uuid;ctx combat_consumer_private.activities%rowtype;scene integer;
 offers jsonb;placement jsonb;item jsonb;source jsonb;target record;offered jsonb;caps jsonb;
 move_cap combat_spatial.movement_capabilities%rowtype;direction text;
begin
 sid:=(p#>>'{context,activity_id}')::uuid;aid:=(p#>>'{viewer,actor_id}')::uuid;
 if aid is null or p->>'status'<>'ready' then return p;end if;
 select * into ctx from combat_consumer_private.activities where session_id=sid;
 if ctx.phase='defense' then return clan_marionettisti_private.consumer_defense_options(p);end if;
 if ctx.phase<>'action' or ctx.turn_actor_id<>aid then return p;end if;
 if not exists(select 1 from public.combat_v2_actors a join combat_consumer_private.members m
  on m.actor_id=a.id and m.session_id=a.session_id and m.character_id=a.character_id
  where a.id=aid and a.session_id=sid and a.actor_kind='pg' and a.controller_user=auth.uid() and a.state='attivo') then
  perform combat_consumer_private.fail('not_participant');end if;
 offers:=coalesce(p->'offers','[]');scene:=(p#>>'{context,scene_version}')::integer;
 if clan_innata_narrative_private.staff_profile_actor_v1(aid)is null
 and coalesce((select staff_enabled from clan_marionettisti_private.release_gate where singleton),false)
  and ctx.policy_id='staff_test_no_persistent_resources_v1'
  and combat_consumer_private.staff_test_allowed(ctx.location_id,array[auth.uid()],false)
  and not exists(select 1 from clan_marionettisti_private.sources where session_id=sid and owner_actor_id=aid)
  and not exists(select 1 from public.combat_v2_declarations d join public.combat_v2_rounds r on r.id=d.round_id
   where r.session_id=sid and d.actor_id=aid) then
  placement:=clan_marionettisti_private.staff_placement(aid);
  if placement is not null then
   offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,null,scene,'control',
    'Prova Marionetta da Combattimento',jsonb_build_object('marionetta_operation','staff_profile','placement',placement)));
  end if;
 end if;
 if ctx.policy_id='free_duel_nonlethal_real_resources_v1'
  and clan_marionettisti_private.owner_eligible(aid,false)
  and not exists(select 1 from public.combat_v2_actors x join clan_marionettisti_private.sources src on src.id=x.companion_id
   join public.combat_v2_actors owner on owner.id=aid where x.session_id=sid and src.owner_character_id=owner.character_id)
  and not exists(select 1 from public.combat_v2_declarations d join public.combat_v2_rounds r on r.id=d.round_id where r.session_id=sid and d.actor_id=aid) then
  placement:=clan_marionettisti_private.staff_placement(aid);
  if placement is not null then
   for target in select src.id from clan_marionettisti_private.sources src
    join clan_marionettisti_private.chassis h on h.companion_id=src.id and h.operational
    join public.character_companions cc on cc.id=src.real_companion_id and cc.is_active and cc.kind='marionetta'
    join public.combat_v2_actors owner on owner.id=aid and owner.character_id=cc.character_id
    where src.source_kind='real' and src.is_active and src.owner_character_id=owner.character_id
     and not exists(select 1 from public.combat_v2_actors x join public.combat_v2_sessions sess on sess.id=x.session_id
      where x.companion_id=src.id and sess.closed_at is null) loop
    offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,null,scene,'control',
     'Collega il compagno presente alla scena',jsonb_build_object('marionetta_operation','real_body','source_id',target.id,'placement',placement)));
   end loop;
  end if;
 end if;
 -- Il bersaglio resta il corpo visibile, non il suo controllore.
 for target in select x.id from public.combat_v2_actors x join public.combat_v2_actors own on own.id=aid
  where x.session_id=sid and x.id<>aid and x.team_key<>own.team_key and x.state='attivo'
   and (x.companion_id is null or clan_marionettisti_private.actor_visible(sid,x.id,auth.uid())) loop
  if clan_marionettisti_private.owner_eligible(aid,true)
   and not exists(select 1 from combat_panel_private.multiplication_formations where actor_id=target.id and state='active') then
   begin
    perform clan_marionettisti_private.ensure_initial_link(aid);
    source:=clan_marionettisti_private.attack_source(ctx.exchange_id,aid,target.id);
    offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,target.id,scene,'declare',
      'Marionetta da Combattimento',jsonb_build_object('intent',jsonb_build_object('kind','attacco','ability_source','clan',
       'ability_id','e361f7c3-f90b-47ec-bfee-ccbda21257d9','target_actor',target.id),'marionetta_source',source)));
   exception when sqlstate '22023' or no_data_found then null;
   end;
  end if;
  -- Il colpo base al PG è già offerto dal consumer; aggiungere solo compagno.
  if exists(select 1 from public.combat_v2_actors where id=target.id and companion_id is not null) then
   caps:=combat_consumer_private.approach_capabilities(sid,aid,target.id);
   if combat_consumer_private.melee_eligible(sid,aid,target.id) or jsonb_array_length(caps)>0 then
    offered:=combat_consumer_private.offer_exchange(sid,aid,target.id,scene,'declare','Colpo alla marionetta',
     jsonb_build_object('intent',jsonb_build_object('kind','attacco','ability_source','mano','target_actor',target.id)));
    offered:=combat_consumer_private.attach_movement(offered,caps,aid,target.id);
    if offered is not null then offers:=offers||jsonb_build_array(offered);end if;
   end if;
  end if;
 end loop;
 for item in select value from jsonb_array_elements(clan_marionettisti_private.relink_options(ctx.exchange_id,aid)) loop
  offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,null,scene,'control',item->>'label',
   jsonb_build_object('marionetta_operation','relink','relink_offer_id',item->'option_id')));
 end loop;
 for item in select value from jsonb_array_elements(clan_marionettisti_private.companion_movement_options(aid)) loop
  -- Direzione sul piano SVG: +x destra, +y basso. Usare il tratto effettivo dopo collisioni.
  select c.* into strict move_cap from combat_spatial.movement_capabilities c
   join combat_spatial.arena_instances i on i.instance_id=c.instance_id and i.encounter_id=sid
   join clan_marionettisti_private.links l on l.instance_id=c.instance_id
    and l.companion_actor_id=c.actor_id and l.owner_actor_id=aid
   where c.capability_id=(item->>'option_id')::uuid;
  direction:=case when move_cap.end_x_m>move_cap.start_x_m then 'a destra'
   when move_cap.end_x_m<move_cap.start_x_m then 'a sinistra'
   when move_cap.end_y_m<move_cap.start_y_m then 'verso l''alto'
   else 'verso il basso' end;
  offered:=combat_consumer_private.offer_exchange(sid,aid,null,scene,'control',
   'Muovi la marionetta di '||(item->>'distance_m')||' m '||direction||' sulla mappa',
   jsonb_build_object('marionetta_operation','move','capability_id',item->'option_id'));
  offered:=offered||jsonb_build_object('companion_movement',jsonb_build_object(
   'direction',case when move_cap.end_x_m>move_cap.start_x_m then 'right'
    when move_cap.end_x_m<move_cap.start_x_m then 'left'
    when move_cap.end_y_m<move_cap.start_y_m then 'up' else 'down' end,
   'distance_m',(item->>'distance_m')::numeric));
  update combat_consumer_private.offers set viewer_projection=offered
   where id=(offered->>'offer_id')::uuid and session_id=sid and exchange_id=ctx.exchange_id
    and principal_character_id=(select character_id from public.combat_v2_actors where id=aid)
    and source_payload=jsonb_build_object('marionetta_operation','move','capability_id',item->'option_id');
  if not found then raise exception 'marionetta_movement_projection_mismatch' using errcode='22023';end if;
  offers:=offers||jsonb_build_array(offered);
 end loop;
 if clan_marionettisti_private.is_dedicated_scene(sid)
  and coalesce((select rinuncia_enabled from clan_marionettisti_private.release_gate where singleton),false) then
  offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,null,scene,'declare','Passa',
   jsonb_build_object('intent',jsonb_build_object('kind','passa'))));
 end if;
 return jsonb_set(p,'{offers}',offers);
end;
$function$;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.staff_profile_bind(p_owner uuid, p_placement jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare a public.combat_v2_actors%rowtype;ctx combat_consumer_private.activities%rowtype;
 src uuid; companion uuid; snapshot jsonb; abilities jsonb; current_placement jsonb;
 principals uuid[]; member record;
begin
 if clan_innata_narrative_private.staff_profile_actor_v1(p_owner)is not null then raise exception 'INNATA_CAPABILITY_AUTHORITY_UNAVAILABLE' using errcode='42501';end if;
 select * into strict a from public.combat_v2_actors where id=p_owner;
 perform 1 from public.combat_v2_sessions where id=a.session_id for update;
 select * into strict ctx from combat_consumer_private.activities where session_id=a.session_id for update;
 perform 1 from public.combat_v2_actors where session_id=a.session_id order by id for update;
 select * into strict a from public.combat_v2_actors where id=p_owner;
 if auth.uid() is null or a.controller_user is distinct from auth.uid() or a.actor_kind<>'pg'
  or a.state<>'attivo' or ctx.phase<>'action' or ctx.turn_actor_id<>a.id
  or ctx.policy_id<>'staff_test_no_persistent_resources_v1' then
  raise exception 'staff_profile_authority_invalid' using errcode='42501';end if;
 select array_agg(distinct x.controller_user order by x.controller_user) into principals
  from combat_consumer_private.members m join public.combat_v2_actors x
   on x.id=m.actor_id and x.session_id=m.session_id and x.character_id=m.character_id
  join public.characters c on c.id=x.character_id and c.user_id=x.controller_user
  where m.session_id=a.session_id and x.actor_kind='pg';
 if cardinality(principals) is distinct from 2
  or (select count(*) from public.combat_v2_actors where session_id=a.session_id and actor_kind='pg')<>2
  or not combat_consumer_private.staff_test_allowed(ctx.location_id,principals,false)
  or public.combat_v2_values_written(a.session_id) then
  raise exception 'staff_profile_scope_invalid' using errcode='42501';end if;
 if exists(select 1 from clan_marionettisti_private.sources where session_id=a.session_id and owner_actor_id=a.id)
  or exists(select 1 from public.combat_v2_declarations d join public.combat_v2_rounds r on r.id=d.round_id
   where r.session_id=a.session_id and d.actor_id=a.id) then
  raise exception 'staff_profile_already_started' using errcode='22023';end if;
 current_placement:=clan_marionettisti_private.staff_placement(a.id);
 if current_placement is null or current_placement is distinct from p_placement then
  raise exception 'staff_profile_placement_stale' using errcode='40001';end if;
 snapshot:=a.mechanics_snapshot;
 -- Nessun ripristino delle risorse: si conserva il saldo simulato corrente.
 if jsonb_typeof(snapshot->'chakra') is distinct from 'number'
  or jsonb_typeof(snapshot->'vita') is distinct from 'number'
  or (snapshot->>'chakra')::integer<0 or (snapshot->>'vita')::integer<=0 then
  raise exception 'staff_profile_resources_invalid' using errcode='22023';end if;
 select coalesce(jsonb_agg(j),'[]') into abilities
  from jsonb_array_elements(coalesce(snapshot->'abilities','[]')) j where j->>'source' is distinct from 'clan';
 abilities:=abilities||jsonb_build_array(
  jsonb_build_object('id','4d742b75-2592-4379-81c0-07ddf436f32b','source','clan','name','Padronanza dei Fili e delle Marionette','chakra_cost',0,'consumption_type','passiva','usage','passiva','defensive',false),
  jsonb_build_object('id','bfe4b934-5979-4e5a-8bff-982f9c41cfe7','source','clan','name','Fili di Chakra','chakra_cost',0,'consumption_type','passiva','usage','passiva','defensive',false),
  jsonb_build_object('id','e361f7c3-f90b-47ec-bfee-ccbda21257d9','source','clan','name','Marionetta da Combattimento','chakra_cost',5,'consumption_type','ad_utilizzo','usage','principale','kind','fisico','damage_base',10,'range','contatto','max_range',3,'defensive',false,'di_scena',false,'diversivo',false));
 src:=gen_random_uuid();
 insert into clan_marionettisti_private.sources(id,source_kind,session_id,owner_actor_id,owner_character_id,profile_version)
  values(src,'staff',a.session_id,a.id,a.character_id,'marionetta-l1/1');
 perform clan_marionettisti_private.assert_source(src);
 insert into clan_marionettisti_private.chassis(companion_id,owner_character_id) values(src,a.character_id);
 update public.combat_v2_actors set mechanics_snapshot=snapshot||jsonb_build_object(
  'kekkei_genkai',30,'ninjutsu',30,'abilities',abilities,'staff_profile','marionetta-l1/1') where id=a.id;
 companion:=clan_marionettisti_private.ordinary_body_bind(a.id,src,p_placement);
 return companion;
end;
$function$;

REVOKE ALL ON FUNCTION clan_innata_narrative_private.catalog_v2() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_innata_narrative_private.catalog_v2() TO postgres;

REVOKE ALL ON FUNCTION clan_innata_narrative_private.profile_definition_v2(text) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_innata_narrative_private.profile_definition_v2(text) TO postgres;

REVOKE ALL ON FUNCTION clan_innata_narrative_private.profile_definition_by_id_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_innata_narrative_private.profile_definition_by_id_v2(uuid) TO postgres;

REVOKE ALL ON FUNCTION clan_innata_narrative_private.permission_fact_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_innata_narrative_private.permission_fact_v2(uuid) TO postgres;

REVOKE ALL ON FUNCTION clan_innata_narrative_private.profile_busy_reason_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_innata_narrative_private.profile_busy_reason_v2(uuid) TO postgres;

REVOKE ALL ON FUNCTION clan_innata_narrative_private.profile_state_core_v2(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_innata_narrative_private.profile_state_core_v2(uuid,uuid) TO postgres;

REVOKE ALL ON FUNCTION public.clan_innata_staff_profile_state_v2(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.clan_innata_staff_profile_state_v2(uuid,uuid) TO authenticated,postgres;

REVOKE ALL ON FUNCTION public.clan_innata_staff_profile_set_v2(uuid,uuid,text,uuid,bigint) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.clan_innata_staff_profile_set_v2(uuid,uuid,text,uuid,bigint) TO authenticated,postgres;

REVOKE ALL ON FUNCTION clan_innata_narrative_private.sharingan_selected_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_innata_narrative_private.sharingan_selected_v2(uuid) TO postgres;

REVOKE ALL ON FUNCTION clan_innata_narrative_private.sharingan_quote_for_actor_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_innata_narrative_private.sharingan_quote_for_actor_v2(uuid) TO postgres;

REVOKE ALL ON FUNCTION clan_innata_narrative_private.permission_role_link_v2(uuid,uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_innata_narrative_private.permission_role_link_v2(uuid,uuid,uuid) TO postgres;

COMMIT;
