-- Candidate only. Separate independent review, local qualification and named production gate.
BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='30s';
SET LOCAL search_path TO public,extensions;
LOCK TABLE combat_consumer_private.narrative_claims, combat_consumer_private.scene_attempts_v2 IN SHARE ROW EXCLUSIVE MODE;
DO $pre$ DECLARE checked_at timestamptz; BEGIN
 checked_at:=clock_timestamp();
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'multiplication_lifecycle_postgres_required'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_consumer_private.narrative_tech_sources_v1(uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='955228bdc23c89cdb287198db57231b8'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_consumer_private.narrative_tech_sources_v1(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_consumer_private.scene_snapshot_v2(uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='a417e6a98201a2177cb8c244a736bb3c'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_consumer_private.scene_snapshot_v2(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_attack_finish(uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='f60b492d859826ab5ecec533d2e55c24'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_attack_finish(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_finish(uuid,text)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='37bcebd323ebc8efaf063e528447865f'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_finish(uuid,text)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_resolve_choice(uuid,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='a714486e7aa9d72dd447c928e2dbd6c4'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_resolve_choice(uuid,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_selection_immutable()')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='245f77354bd850b318831f2a2a04bac3'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_selection_immutable()'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_state_guard()')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='f4729b355136bab6528798b8f12911f8'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_state_guard()'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_v2_sha256(jsonb)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='4dc3868f16311c1fffdb3d6b2fd733ce'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_v2_sha256(jsonb)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_assault_end()')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='16ac1cebd0b314a09d07f8e93e764104'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_assault_end()'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='ecca3d1eb3f65c5bf5badb76899181a1'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_v2_round_resolve(uuid,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='ade52361f248f3e09a85825ac501d503'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_v2_round_resolve(uuid,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_narrative_claim_v1(uuid,text,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='5bc5cd86dd03ebe4687c7388131165a3'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='1668f80c8d0503ec16d4b87f60e9d204'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_scene_acquire_v2(uuid,text,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='be12d9b6c331465ff4c338b8b66566d3'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_scene_acquire_v2(uuid,text,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_scene_complete_v2(uuid,text,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='153777708128d14d5b482d08dad24f9e'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_scene_complete_v2(uuid,text,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_scene_permit_v2(uuid,text,uuid,text,bigint)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='55af27b8ee0746648d1f7676a1a4e97b'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_scene_permit_v2(uuid,text,uuid,text,bigint)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_scene_save_v2(uuid,text,uuid,text)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='c1e86541aa230e0d2438079895b0451f'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_scene_save_v2(uuid,text,uuid,text)'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) || jsonb_build_object('constraints',(SELECT jsonb_agg(jsonb_build_object(
        'name',co.conname,'type',co.contype,'definition',pg_catalog.pg_get_constraintdef(co.oid)) ORDER BY co.conname)
        FROM pg_catalog.pg_constraint co WHERE co.conrelid=c.oid),
        'triggers',(SELECT jsonb_agg(jsonb_build_object('name',tr.tgname,'enabled',tr.tgenabled,
         'definition',pg_catalog.pg_get_triggerdef(tr.oid),'function',tr.tgfoid::regprocedure::text) ORDER BY tr.tgname)
         FROM pg_catalog.pg_trigger tr WHERE tr.tgrelid=c.oid AND NOT tr.tgisinternal)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('combat_panel_private.multiplication_formations')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"id","type":"uuid","notnull":true},{"name":"session_id","type":"uuid","notnull":true},{"name":"round_id","type":"uuid","notnull":true},{"name":"actor_id","type":"uuid","notnull":true},{"name":"declaration_id","type":"uuid","notnull":true},{"name":"instance_id","type":"uuid","notnull":true},{"name":"source_body_version","type":"bigint","notnull":true},{"name":"mode","type":"text","notnull":true},{"name":"copy_count","type":"integer","notnull":true},{"name":"copy_cap","type":"integer","notnull":true},{"name":"figures","type":"jsonb","notnull":true},{"name":"original_index","type":"integer","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"state_version","type":"bigint","notnull":true},{"name":"terminal_reason","type":"text","notnull":false},{"name":"created_at","type":"timestamp with time zone","notnull":true},{"name":"ended_at","type":"timestamp with time zone","notnull":false}],"constraints":[{"name":"multiplication_formations_actor_id_fkey","type":"f","definition":"FOREIGN KEY (actor_id) REFERENCES combat_v2_actors(id)"},{"name":"multiplication_formations_check","type":"c","definition":"CHECK ((copy_cap >= copy_count))"},{"name":"multiplication_formations_check1","type":"c","definition":"CHECK (combat_panel_private.multiplication_formation_valid(figures, copy_count, copy_cap, original_index))"},{"name":"multiplication_formations_check2","type":"c","definition":"CHECK (((state = ''active''::text) = (ended_at IS NULL)))"},{"name":"multiplication_formations_check3","type":"c","definition":"CHECK (((state = ''active''::text) = (terminal_reason IS NULL)))"},{"name":"multiplication_formations_check4","type":"c","definition":"CHECK (((state <> ''consumed''::text) OR (terminal_reason = ANY (ARRAY[''first_attack''::text, ''assault_resolved''::text]))))"},{"name":"multiplication_formations_check5","type":"c","definition":"CHECK (((state <> ''expired''::text) OR (terminal_reason <> ALL (ARRAY[''first_attack''::text, ''assault_resolved''::text]))))"},{"name":"multiplication_formations_copy_count_check","type":"c","definition":"CHECK ((copy_count > 0))"},{"name":"multiplication_formations_declaration_id_fkey","type":"f","definition":"FOREIGN KEY (declaration_id) REFERENCES combat_v2_declarations(id)"},{"name":"multiplication_formations_declaration_id_key","type":"u","definition":"UNIQUE (declaration_id)"},{"name":"multiplication_formations_instance_id_fkey","type":"f","definition":"FOREIGN KEY (instance_id) REFERENCES combat_spatial.arena_instances(instance_id)"},{"name":"multiplication_formations_mode_check","type":"c","definition":"CHECK ((mode = ANY (ARRAY[''diversivo''::text, ''copertura''::text, ''assalto''::text])))"},{"name":"multiplication_formations_pkey","type":"p","definition":"PRIMARY KEY (id)"},{"name":"multiplication_formations_round_id_fkey","type":"f","definition":"FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id)"},{"name":"multiplication_formations_session_id_fkey","type":"f","definition":"FOREIGN KEY (session_id) REFERENCES combat_v2_sessions(id)"},{"name":"multiplication_formations_source_body_version_check","type":"c","definition":"CHECK ((source_body_version > 0))"},{"name":"multiplication_formations_state_check","type":"c","definition":"CHECK ((state = ANY (ARRAY[''active''::text, ''consumed''::text, ''expired''::text])))"},{"name":"multiplication_formations_state_version_check","type":"c","definition":"CHECK ((state_version > 0))"},{"name":"multiplication_formations_terminal_reason_check","type":"c","definition":"CHECK ((terminal_reason = ANY (ARRAY[''first_attack''::text, ''assault_resolved''::text, ''owner_next_action''::text, ''owner_inoperative''::text, ''combat_end''::text, ''formation_invalid''::text])))"}],"triggers":[{"name":"panel_multiplication_identity","enabled":"O","function":"combat_panel_private.multiplication_state_guard()","definition":"CREATE TRIGGER panel_multiplication_identity BEFORE INSERT OR UPDATE ON combat_panel_private.multiplication_formations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_state_guard()"},{"name":"sabaku_clone_formation_created","enabled":"O","function":"clan_sabaku_private.clone_formation_trigger()","definition":"CREATE TRIGGER sabaku_clone_formation_created AFTER INSERT ON combat_panel_private.multiplication_formations FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_formation_trigger()"}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','combat_panel_private.multiplication_formations'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) || jsonb_build_object('constraints',(SELECT jsonb_agg(jsonb_build_object(
        'name',co.conname,'type',co.contype,'definition',pg_catalog.pg_get_constraintdef(co.oid)) ORDER BY co.conname)
        FROM pg_catalog.pg_constraint co WHERE co.conrelid=c.oid),
        'triggers',(SELECT jsonb_agg(jsonb_build_object('name',tr.tgname,'enabled',tr.tgenabled,
         'definition',pg_catalog.pg_get_triggerdef(tr.oid),'function',tr.tgfoid::regprocedure::text) ORDER BY tr.tgname)
         FROM pg_catalog.pg_trigger tr WHERE tr.tgrelid=c.oid AND NOT tr.tgisinternal)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('combat_panel_private.multiplication_resolutions')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"formation_id","type":"uuid","notnull":true},{"name":"attack_target_id","type":"uuid","notnull":true},{"name":"chooser_actor_id","type":"uuid","notnull":true},{"name":"selected_index","type":"integer","notnull":true},{"name":"choice_kind","type":"text","notnull":true},{"name":"outcome","type":"text","notnull":true},{"name":"rng_seed","type":"bytea","notnull":false},{"name":"facts","type":"jsonb","notnull":true},{"name":"receipt_sha256","type":"text","notnull":true},{"name":"created_at","type":"timestamp with time zone","notnull":true}],"constraints":[{"name":"multiplication_resolutions_attack_target_id_fkey","type":"f","definition":"FOREIGN KEY (attack_target_id) REFERENCES combat_v2_attack_targets(id)"},{"name":"multiplication_resolutions_check","type":"c","definition":"CHECK (((choice_kind = ''server_random''::text) = (rng_seed IS NOT NULL)))"},{"name":"multiplication_resolutions_choice_kind_check","type":"c","definition":"CHECK ((choice_kind = ANY (ARRAY[''explicit''::text, ''server_random''::text, ''formation_coverage''::text, ''active_dojutsu''::text])))"},{"name":"multiplication_resolutions_chooser_actor_id_fkey","type":"f","definition":"FOREIGN KEY (chooser_actor_id) REFERENCES combat_v2_actors(id)"},{"name":"multiplication_resolutions_facts_check","type":"c","definition":"CHECK ((jsonb_typeof(facts) = ''object''::text))"},{"name":"multiplication_resolutions_formation_id_fkey","type":"f","definition":"FOREIGN KEY (formation_id) REFERENCES combat_panel_private.multiplication_formations(id)"},{"name":"multiplication_resolutions_outcome_check","type":"c","definition":"CHECK ((outcome = ANY (ARRAY[''copy_hit''::text, ''original_found''::text])))"},{"name":"multiplication_resolutions_pkey","type":"p","definition":"PRIMARY KEY (formation_id, attack_target_id)"},{"name":"multiplication_resolutions_receipt_sha256_check","type":"c","definition":"CHECK ((receipt_sha256 ~ ''^[0-9a-f]{64}$''::text))"},{"name":"multiplication_resolutions_rng_seed_check","type":"c","definition":"CHECK (((rng_seed IS NULL) OR (octet_length(rng_seed) = 32)))"},{"name":"multiplication_resolutions_selected_index_check","type":"c","definition":"CHECK ((selected_index > 0))"}],"triggers":[{"name":"panel_multiplication_resolution_immutable","enabled":"O","function":"combat_panel_private.multiplication_selection_immutable()","definition":"CREATE TRIGGER panel_multiplication_resolution_immutable BEFORE DELETE OR UPDATE ON combat_panel_private.multiplication_resolutions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_selection_immutable()"}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','combat_panel_private.multiplication_resolutions'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) || jsonb_build_object('constraints',(SELECT jsonb_agg(jsonb_build_object(
        'name',co.conname,'type',co.contype,'definition',pg_catalog.pg_get_constraintdef(co.oid)) ORDER BY co.conname)
        FROM pg_catalog.pg_constraint co WHERE co.conrelid=c.oid),
        'triggers',(SELECT jsonb_agg(jsonb_build_object('name',tr.tgname,'enabled',tr.tgenabled,
         'definition',pg_catalog.pg_get_triggerdef(tr.oid),'function',tr.tgfoid::regprocedure::text) ORDER BY tr.tgname)
         FROM pg_catalog.pg_trigger tr WHERE tr.tgrelid=c.oid AND NOT tr.tgisinternal)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('public.combat_v2_attack_targets')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres,service_role=arw/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"id","type":"uuid","notnull":true},{"name":"round_id","type":"uuid","notnull":true},{"name":"attack_declaration_id","type":"uuid","notnull":true},{"name":"ordinal","type":"smallint","notnull":true},{"name":"target_actor_id","type":"uuid","notnull":true},{"name":"target_controller_version","type":"bigint","notnull":true},{"name":"target_position_m","type":"integer","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"outcome","type":"jsonb","notnull":false},{"name":"rng_receipt_sha256","type":"text","notnull":false},{"name":"created_at","type":"timestamp with time zone","notnull":true}],"constraints":[{"name":"combat_v2_attack_targets_attack_declaration_id_fkey","type":"f","definition":"FOREIGN KEY (attack_declaration_id) REFERENCES combat_v2_declarations(id) ON DELETE RESTRICT"},{"name":"combat_v2_attack_targets_attack_declaration_id_ordinal_key","type":"u","definition":"UNIQUE (attack_declaration_id, ordinal)"},{"name":"combat_v2_attack_targets_attack_declaration_id_target_actor_key","type":"u","definition":"UNIQUE (attack_declaration_id, target_actor_id)"},{"name":"combat_v2_attack_targets_id_attack_declaration_id_key","type":"u","definition":"UNIQUE (id, attack_declaration_id)"},{"name":"combat_v2_attack_targets_ordinal_check","type":"c","definition":"CHECK (((ordinal >= 1) AND (ordinal <= 3)))"},{"name":"combat_v2_attack_targets_outcome_check","type":"c","definition":"CHECK (((outcome IS NULL) OR (jsonb_typeof(outcome) = ''object''::text)))"},{"name":"combat_v2_attack_targets_pkey","type":"p","definition":"PRIMARY KEY (id)"},{"name":"combat_v2_attack_targets_rng_receipt_sha256_check","type":"c","definition":"CHECK (((rng_receipt_sha256 IS NULL) OR (rng_receipt_sha256 ~ ''^[0-9a-f]{64}$''::text)))"},{"name":"combat_v2_attack_targets_round_id_fkey","type":"f","definition":"FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id) ON DELETE RESTRICT"},{"name":"combat_v2_attack_targets_state_check","type":"c","definition":"CHECK ((state = ANY (ARRAY[''attesa_difesa''::text, ''coperta''::text, ''risolta''::text, ''superflua''::text])))"},{"name":"combat_v2_attack_targets_target_actor_id_fkey","type":"f","definition":"FOREIGN KEY (target_actor_id) REFERENCES combat_v2_actors(id) ON DELETE RESTRICT"}],"triggers":[{"name":"panel_immobilization_attack","enabled":"O","function":"combat_panel_private.immobilization_attack_trigger()","definition":"CREATE TRIGGER panel_immobilization_attack AFTER INSERT OR UPDATE OF state, outcome ON public.combat_v2_attack_targets FOR EACH ROW EXECUTE FUNCTION combat_panel_private.immobilization_attack_trigger()"}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','public.combat_v2_attack_targets'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) || jsonb_build_object('constraints',(SELECT jsonb_agg(jsonb_build_object(
        'name',co.conname,'type',co.contype,'definition',pg_catalog.pg_get_constraintdef(co.oid)) ORDER BY co.conname)
        FROM pg_catalog.pg_constraint co WHERE co.conrelid=c.oid),
        'triggers',(SELECT jsonb_agg(jsonb_build_object('name',tr.tgname,'enabled',tr.tgenabled,
         'definition',pg_catalog.pg_get_triggerdef(tr.oid),'function',tr.tgfoid::regprocedure::text) ORDER BY tr.tgname)
         FROM pg_catalog.pg_trigger tr WHERE tr.tgrelid=c.oid AND NOT tr.tgisinternal)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('public.combat_v2_declarations')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"id","type":"uuid","notnull":true},{"name":"round_id","type":"uuid","notnull":true},{"name":"actor_id","type":"uuid","notnull":true},{"name":"kind","type":"text","notnull":true},{"name":"parent_attack_id","type":"uuid","notnull":false},{"name":"target_actor_id","type":"uuid","notnull":false},{"name":"sanitized_intent","type":"jsonb","notnull":true},{"name":"declaration_text","type":"text","notnull":true},{"name":"controller_user_snapshot","type":"uuid","notnull":true},{"name":"controller_version_snapshot","type":"bigint","notnull":true},{"name":"request_key","type":"uuid","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"outcome","type":"jsonb","notnull":false},{"name":"order_no","type":"integer","notnull":false},{"name":"tie_break","type":"bigint","notnull":false},{"name":"cost_snapshot","type":"jsonb","notnull":true},{"name":"created_at","type":"timestamp with time zone","notnull":true},{"name":"frozen_at","type":"timestamp with time zone","notnull":false}],"constraints":[{"name":"combat_v2_declarations_actor_id_fkey","type":"f","definition":"FOREIGN KEY (actor_id) REFERENCES combat_v2_actors(id) ON DELETE RESTRICT"},{"name":"combat_v2_declarations_cost_snapshot_check","type":"c","definition":"CHECK ((jsonb_typeof(cost_snapshot) = ''object''::text))"},{"name":"combat_v2_declarations_declaration_text_check","type":"c","definition":"CHECK ((char_length(declaration_text) <= 5000))"},{"name":"combat_v2_declarations_kind_check","type":"c","definition":"CHECK ((kind = ANY (ARRAY[''attacco''::text, ''difesa''::text, ''movimento''::text, ''utilita''::text, ''passa''::text, ''nessuna''::text])))"},{"name":"combat_v2_declarations_parent_attack_id_fkey","type":"f","definition":"FOREIGN KEY (parent_attack_id) REFERENCES combat_v2_declarations(id) ON DELETE RESTRICT"},{"name":"combat_v2_declarations_parent_chk","type":"c","definition":"CHECK (((kind = ANY (ARRAY[''difesa''::text, ''nessuna''::text])) = (parent_attack_id IS NOT NULL)))"},{"name":"combat_v2_declarations_pkey","type":"p","definition":"PRIMARY KEY (id)"},{"name":"combat_v2_declarations_round_id_fkey","type":"f","definition":"FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id) ON DELETE RESTRICT"},{"name":"combat_v2_declarations_round_id_request_key_key","type":"u","definition":"UNIQUE (round_id, request_key)"},{"name":"combat_v2_declarations_sanitized_intent_check","type":"c","definition":"CHECK ((jsonb_typeof(sanitized_intent) = ''object''::text))"},{"name":"combat_v2_declarations_state_check","type":"c","definition":"CHECK ((state = ANY (ARRAY[''bozza_server''::text, ''inviata''::text, ''congelata''::text, ''risolta''::text, ''superflua''::text])))"},{"name":"combat_v2_declarations_target_actor_id_fkey","type":"f","definition":"FOREIGN KEY (target_actor_id) REFERENCES combat_v2_actors(id) ON DELETE RESTRICT"},{"name":"combat_v2_declarations_target_chk","type":"c","definition":"CHECK (((kind <> ''attacco''::text) OR (target_actor_id IS NOT NULL)))"}],"triggers":[{"name":"combat_v2_declarations_multitarget_sync","enabled":"O","function":"combat_v2_multitarget_internal.sync_declaration()","definition":"CREATE TRIGGER combat_v2_declarations_multitarget_sync AFTER INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_v2_multitarget_internal.sync_declaration()"},{"name":"marionetta_terminal_event","enabled":"O","function":"clan_marionettisti_private.declaration_terminal_trigger()","definition":"CREATE TRIGGER marionetta_terminal_event AFTER UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_marionettisti_private.declaration_terminal_trigger()"},{"name":"panel_actor_turn_declaration","enabled":"O","function":"combat_panel_private.actor_turn_lifecycle()","definition":"CREATE TRIGGER panel_actor_turn_declaration AFTER INSERT OR UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle()"},{"name":"panel_declaration_ready","enabled":"O","function":"combat_panel_private.master_entry_trigger()","definition":"CREATE TRIGGER panel_declaration_ready BEFORE INSERT OR UPDATE OF round_id, actor_id, kind ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_entry_trigger()"},{"name":"panel_multiplication_assault_end","enabled":"O","function":"combat_panel_private.multiplication_assault_end()","definition":"CREATE TRIGGER panel_multiplication_assault_end AFTER UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_assault_end()"},{"name":"panel_multiplication_next_action","enabled":"O","function":"combat_panel_private.multiplication_next_action()","definition":"CREATE TRIGGER panel_multiplication_next_action BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_next_action()"},{"name":"sabaku_master_main","enabled":"O","function":"clan_sabaku_private.master_turn_lifecycle()","definition":"CREATE TRIGGER sabaku_master_main BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.master_turn_lifecycle()"}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','public.combat_v2_declarations'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) || jsonb_build_object('constraints',(SELECT jsonb_agg(jsonb_build_object(
        'name',co.conname,'type',co.contype,'definition',pg_catalog.pg_get_constraintdef(co.oid)) ORDER BY co.conname)
        FROM pg_catalog.pg_constraint co WHERE co.conrelid=c.oid),
        'triggers',(SELECT jsonb_agg(jsonb_build_object('name',tr.tgname,'enabled',tr.tgenabled,
         'definition',pg_catalog.pg_get_triggerdef(tr.oid),'function',tr.tgfoid::regprocedure::text) ORDER BY tr.tgname)
         FROM pg_catalog.pg_trigger tr WHERE tr.tgrelid=c.oid AND NOT tr.tgisinternal)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('public.combat_v2_rounds')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"id","type":"uuid","notnull":true},{"name":"session_id","type":"uuid","notnull":true},{"name":"round_no","type":"integer","notnull":true},{"name":"phase","type":"text","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"engine_version","type":"text","notnull":true},{"name":"resolver_version","type":"text","notnull":true},{"name":"order_version","type":"text","notnull":true},{"name":"quality_version","type":"text","notnull":true},{"name":"evaluation_mode","type":"text","notnull":true},{"name":"rng_order_commitment","type":"text","notnull":false},{"name":"freeze_at","type":"timestamp with time zone","notnull":false},{"name":"resolved_at","type":"timestamp with time zone","notnull":false},{"name":"narrated_at","type":"timestamp with time zone","notnull":false},{"name":"report_id","type":"uuid","notnull":false},{"name":"created_at","type":"timestamp with time zone","notnull":true}],"constraints":[{"name":"combat_v2_rounds_evaluation_mode_check","type":"c","definition":"CHECK ((evaluation_mode = ANY (ARRAY[''umana''::text, ''neutra''::text])))"},{"name":"combat_v2_rounds_phase_check","type":"c","definition":"CHECK ((phase = ANY (ARRAY[''raccolta_azioni''::text, ''raccolta_difese''::text, ''congelato''::text, ''valutazione''::text, ''risoluzione''::text, ''risolto''::text, ''narrazione''::text, ''narrato''::text])))"},{"name":"combat_v2_rounds_pkey","type":"p","definition":"PRIMARY KEY (id)"},{"name":"combat_v2_rounds_rng_order_commitment_check","type":"c","definition":"CHECK (((rng_order_commitment IS NULL) OR (rng_order_commitment ~ ''^[0-9a-f]{64}$''::text)))"},{"name":"combat_v2_rounds_round_no_check","type":"c","definition":"CHECK ((round_no >= 1))"},{"name":"combat_v2_rounds_session_id_fkey","type":"f","definition":"FOREIGN KEY (session_id) REFERENCES combat_v2_sessions(id) ON DELETE RESTRICT"},{"name":"combat_v2_rounds_session_id_round_no_key","type":"u","definition":"UNIQUE (session_id, round_no)"},{"name":"combat_v2_rounds_state_check","type":"c","definition":"CHECK ((state = ANY (ARRAY[''raccolta_azioni''::text, ''raccolta_difese''::text, ''congelato''::text, ''valutazione''::text, ''risoluzione''::text, ''risolto''::text, ''narrazione''::text, ''narrato''::text])))"}],"triggers":[{"name":"marionetta_command_window","enabled":"O","function":"clan_marionettisti_private.round_window_trigger()","definition":"CREATE TRIGGER marionetta_command_window AFTER INSERT OR UPDATE OF phase ON public.combat_v2_rounds FOR EACH ROW EXECUTE FUNCTION clan_marionettisti_private.round_window_trigger()"},{"name":"panel_actor_turn_round","enabled":"O","function":"combat_panel_private.actor_turn_lifecycle()","definition":"CREATE TRIGGER panel_actor_turn_round AFTER INSERT OR UPDATE OF phase ON public.combat_v2_rounds FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle()"},{"name":"sabaku_clone_round_end","enabled":"O","function":"clan_sabaku_private.clone_lifecycle_trigger()","definition":"CREATE TRIGGER sabaku_clone_round_end AFTER UPDATE OF phase ON public.combat_v2_rounds FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_lifecycle_trigger()"}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','public.combat_v2_rounds'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('combat_consumer_private.narrative_claims')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"id","type":"uuid","notnull":true},{"name":"session_id","type":"uuid","notnull":true},{"name":"round_id","type":"uuid","notnull":true},{"name":"report_id","type":"uuid","notnull":true},{"name":"report_sha256","type":"text","notnull":true},{"name":"context_version","type":"bigint","notnull":true},{"name":"control_version","type":"bigint","notnull":true},{"name":"context_payload","type":"jsonb","notnull":true},{"name":"context_sha256","type":"text","notnull":true},{"name":"request_key","type":"uuid","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"claimed_at","type":"timestamp with time zone","notnull":true},{"name":"expires_at","type":"timestamp with time zone","notnull":true},{"name":"completion_sha256","type":"text","notnull":false},{"name":"completion_result","type":"jsonb","notnull":false},{"name":"provider_response_id","type":"text","notnull":false},{"name":"provider_request_sha256","type":"text","notnull":false},{"name":"raw_output_sha256","type":"text","notnull":false},{"name":"failure_code","type":"text","notnull":false}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','combat_consumer_private.narrative_claims'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('combat_consumer_private.scene_attempts_v2')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"claim_id","type":"uuid","notnull":true},{"name":"request_key","type":"uuid","notnull":true},{"name":"round_id","type":"uuid","notnull":true},{"name":"session_id","type":"uuid","notnull":true},{"name":"scene_payload","type":"jsonb","notnull":true},{"name":"scene_sha256","type":"text","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"permit_at","type":"timestamp with time zone","notnull":false},{"name":"result_bytes","type":"text","notnull":false},{"name":"result_payload","type":"jsonb","notnull":false},{"name":"result_sha256","type":"text","notnull":false},{"name":"provider_response_id","type":"text","notnull":false},{"name":"failure_code","type":"text","notnull":false},{"name":"completion","type":"jsonb","notnull":false},{"name":"created_at","type":"timestamp with time zone","notnull":true},{"name":"result_at","type":"timestamp with time zone","notnull":false},{"name":"redelivery_at","type":"timestamp with time zone","notnull":false},{"name":"redelivery_state","type":"text","notnull":false},{"name":"redelivery_request_id","type":"bigint","notnull":false}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','combat_consumer_private.scene_attempts_v2'; END IF;

 -- checked_at is sampled once AFTER both table locks, never at transaction start.
 -- Ignore only an exhausted legacy claim with no attempt or recorded result.
 -- Any attempt (including generated/provider_reserved beyond lease) remains blocking.
 IF EXISTS (
  SELECT 1 FROM combat_consumer_private.narrative_claims c
  WHERE c.context_payload->>'ordinary'='true'
    AND c.state NOT IN ('completed','failed','expired')
    AND NOT (
      c.state='claimed'
      AND c.expires_at IS NOT NULL AND c.expires_at < checked_at
      AND c.completion_sha256 IS NULL
      AND c.completion_result IS NULL
      AND c.provider_response_id IS NULL
      AND c.provider_request_sha256 IS NULL
      AND c.raw_output_sha256 IS NULL
      AND NOT EXISTS (
        SELECT 1 FROM combat_consumer_private.scene_attempts_v2 a
        WHERE a.claim_id=c.id OR a.round_id=c.round_id
      )
    )
 ) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_ordinary_claim_inflight'; END IF;

END $pre$;
CREATE OR REPLACE FUNCTION combat_consumer_private.narrative_tech_sources_v1(p_claim uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE claim combat_consumer_private.narrative_claims%ROWTYPE;
  unit public.combat_v2_rounds%ROWTYPE; ref record; event record; content jsonb;
  sources jsonb:='[]'; endings jsonb:='[]'; native_id uuid; source_kind text; multiplication_seen uuid[]:=ARRAY[]::uuid[];
BEGIN
 SELECT * INTO STRICT claim FROM combat_consumer_private.narrative_claims WHERE id=p_claim;
 SELECT * INTO STRICT unit FROM public.combat_v2_rounds WHERE id=claim.round_id;
 IF unit.session_id IS DISTINCT FROM claim.session_id OR claim.context_payload->>'ordinary' IS DISTINCT FROM 'true'
   OR claim.context_payload->>'genere' IS DISTINCT FROM 'azione_risolta' THEN
   RAISE EXCEPTION 'narrative_tech_scope_invalid' USING ERRCODE='22023';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities staff_activity
      JOIN public.combat_v2_sessions staff_session ON staff_session.id=staff_activity.session_id
      JOIN public.locations staff_location ON staff_location.id=staff_activity.location_id
      WHERE staff_activity.session_id=claim.session_id AND staff_activity.exchange_id=claim.round_id
        AND staff_activity.phase='resolved' AND staff_activity.policy_id='staff_test_no_persistent_resources_v1'
        AND staff_session.source_kind='ordinary' AND staff_session.location_id=staff_activity.location_id
        AND staff_location.is_test AND NOT public.combat_v2_values_written(staff_session.id)
        AND combat_consumer_private.staff_test_allowed(staff_location.id,
          (SELECT array_agg(actor.controller_user ORDER BY actor.id)
           FROM combat_consumer_private.members member JOIN public.combat_v2_actors actor
             ON actor.id=member.actor_id AND actor.session_id=member.session_id
             AND actor.character_id=member.character_id
           WHERE member.session_id=claim.session_id),false)) THEN
   RAISE EXCEPTION 'narrative_tech_staff_scope_required' USING ERRCODE='42501';
 END IF;
 -- Native rows certify use: no role-text/name lookup, no inventory scan.
 FOR ref IN
  SELECT DISTINCT x.catalog,x.actor_id FROM (
   SELECT 'clan_techniques'::text catalog,d.actor_id
    FROM public.combat_v2_declarations d
    WHERE d.round_id=claim.round_id AND d.state='risolta'
      AND d.outcome->'sabaku_clone'->>'schema_version'='sabaku-clone/1'
      AND d.kind='utilita'
   UNION
   SELECT 'clan_techniques',c.actor_id FROM clan_sabaku_private.clone_captures cc
    JOIN clan_sabaku_private.clones c ON c.id=cc.clone_id
    WHERE cc.round_id=claim.round_id AND c.session_id=claim.session_id
   UNION
   SELECT 'jutsu',f.actor_id FROM combat_panel_private.multiplication_formations f
    JOIN public.combat_v2_declarations d ON d.id=f.declaration_id
    WHERE f.session_id=claim.session_id AND d.round_id=claim.round_id AND d.state='risolta'
   UNION
   SELECT 'jutsu',f.actor_id FROM combat_panel_private.multiplication_resolutions mr
    JOIN combat_panel_private.multiplication_formations f ON f.id=mr.formation_id
    JOIN public.combat_v2_attack_targets t ON t.id=mr.attack_target_id
    JOIN public.combat_v2_declarations d ON d.id=t.attack_declaration_id
    WHERE f.session_id=claim.session_id AND d.round_id=claim.round_id AND d.state='risolta'
      AND t.state IN('risolta','superflua')
   UNION
   SELECT 'jutsu',f.actor_id FROM clan_sabaku_private.clone_captures cc
    JOIN combat_panel_private.multiplication_formations f ON f.id=cc.formation_id
    WHERE cc.round_id=claim.round_id AND f.session_id=claim.session_id
  ) x ORDER BY x.catalog,x.actor_id
 LOOP
  IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.members m
    WHERE m.session_id=claim.session_id AND m.actor_id=ref.actor_id) THEN
   RAISE EXCEPTION 'narrative_tech_actor_not_in_scene' USING ERRCODE='22023';
  END IF;
  IF ref.catalog='clan_techniques' THEN
   native_id:='617484d6-af7b-41c3-a37f-615b22818421';
   SELECT jsonb_build_object('id',id,'name',name,'description',description,'danno_effetto',danno_effetto)
     INTO STRICT content FROM public.clan_techniques WHERE id=native_id;
  ELSE
   native_id:='c6e31b7b-38fe-4b4f-b3c7-05f3e922d193';
   SELECT jsonb_build_object('id',id,'name_it',name_it,'effect',effect,'limits',limits)
     INTO STRICT content FROM public.jutsu WHERE id=native_id;
  END IF;
  sources:=sources||jsonb_build_array(jsonb_build_object('catalog',ref.catalog,'technique_id',native_id,
    'actor_id',ref.actor_id,'mapping_version','ordinary-tech/1','source_sha256',
    encode(extensions.digest(convert_to(content::text,'UTF8'),'sha256'),'hex'),'content',content));
 END LOOP;
 -- Terminal event only when the native capture and native terminal state agree.
 -- No original index, figures, coordinates, dice, private stats, or inference from damage.
 FOR event IN
  SELECT cc.id,cc.copy_hit,cc.result,c.actor_id,c.state,c.end_reason,c.ended_at,cc.created_at
  FROM clan_sabaku_private.clone_captures cc JOIN clan_sabaku_private.clones c ON c.id=cc.clone_id
  WHERE cc.round_id=claim.round_id AND c.session_id=claim.session_id
  ORDER BY cc.created_at,cc.id
 LOOP
  IF event.result->>'schema_version' IS DISTINCT FROM 'sabaku-clone-capture/1'
    OR event.result->'copy_hit' IS DISTINCT FROM to_jsonb(event.copy_hit)
    OR jsonb_typeof(event.result->'success') IS DISTINCT FROM 'boolean' THEN
   RAISE EXCEPTION 'narrative_tech_capture_invalid' USING ERRCODE='22023';
  END IF;
  IF event.result->'success'='false'::jsonb THEN
   IF event.state IS DISTINCT FROM 'ended' OR event.ended_at IS NULL
    OR event.ended_at<event.created_at
    OR event.end_reason IS DISTINCT FROM (CASE WHEN event.copy_hit THEN 'copy_triggered' ELSE 'capture_failed' END) THEN
    RAISE EXCEPTION 'narrative_tech_terminal_event_missing' USING ERRCODE='22023';
   END IF;
   endings:=endings||jsonb_build_array(jsonb_build_object('tecnica','Clone di Sabbia','actor_id',event.actor_id,
      'stato','terminato','causa',event.end_reason));
  END IF;
 END LOOP;

 -- Moltiplicazione: immutable resolution receipt + exact resolved target/round.
 -- Native terminal state alone is insufficient; never infer an ending from damage.
 FOR event IN
  SELECT mr.formation_id, mr.attack_target_id, mr.facts, mr.receipt_sha256,
    mr.created_at AS receipt_at, mr.choice_kind, mr.outcome AS choice_outcome,
    f.actor_id, f.mode, f.state AS formation_state, f.terminal_reason, f.ended_at,
    f.declaration_id AS formation_declaration, t.state AS target_state,
    t.target_actor_id, t.outcome AS target_outcome,
    d.id AS attack_id, d.actor_id AS attacker_id, d.state AS attack_state
  FROM combat_panel_private.multiplication_resolutions mr
  JOIN combat_panel_private.multiplication_formations f ON f.id=mr.formation_id
  JOIN public.combat_v2_attack_targets t ON t.id=mr.attack_target_id
  JOIN public.combat_v2_declarations d ON d.id=t.attack_declaration_id
  WHERE f.session_id=claim.session_id AND t.round_id=claim.round_id
    AND d.round_id=claim.round_id
  ORDER BY mr.formation_id, mr.created_at, mr.attack_target_id
 LOOP
  IF unit.resolved_at IS NULL OR unit.report_id IS DISTINCT FROM claim.report_id
    OR unit.phase NOT IN ('risolto','narrato')
    OR event.attack_state IS DISTINCT FROM 'risolta'
    OR event.target_state IS DISTINCT FROM 'risolta'
    OR jsonb_typeof(event.facts) IS DISTINCT FROM 'object'
    OR event.facts->>'schema_version' IS DISTINCT FROM 'combat-multiplication-resolution/1'
    OR event.facts->'formation_id' IS DISTINCT FROM to_jsonb(event.formation_id)
    OR event.facts->'attack_target_id' IS DISTINCT FROM to_jsonb(event.attack_target_id)
    OR event.facts->>'mode' IS DISTINCT FROM event.mode
    OR event.facts->>'choice_kind' IS DISTINCT FROM event.choice_kind
    OR event.facts->>'outcome' IS DISTINCT FROM event.choice_outcome
    OR event.choice_outcome NOT IN ('original_found','copy_hit')
    OR event.receipt_sha256 IS DISTINCT FROM public.combat_v2_sha256(event.facts)
    OR jsonb_typeof(event.target_outcome->'multiplication') IS DISTINCT FROM 'array'
    OR NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(CASE
        WHEN jsonb_typeof(event.target_outcome->'multiplication')='array'
        THEN event.target_outcome->'multiplication' ELSE '[]'::jsonb END) item
      WHERE item - 'role' = event.facts
    ) THEN
   RAISE EXCEPTION 'narrative_multiplication_receipt_invalid' USING ERRCODE='22023';
  END IF;
  IF event.formation_state IS DISTINCT FROM 'consumed'
    OR event.ended_at IS NULL OR event.ended_at < event.receipt_at
    OR event.ended_at > unit.resolved_at
    OR event.terminal_reason IS DISTINCT FROM (CASE
      WHEN event.mode='assalto' AND event.formation_declaration=event.attack_id
        AND event.actor_id=event.attacker_id THEN 'assault_resolved'
      ELSE 'first_attack' END)
    OR NOT (
      event.actor_id=event.target_actor_id OR
      (event.mode='assalto' AND event.formation_declaration=event.attack_id
        AND event.actor_id=event.attacker_id)
    )
    OR NOT EXISTS (SELECT 1 FROM combat_consumer_private.members m
      WHERE m.session_id=claim.session_id AND m.actor_id=event.actor_id) THEN
   RAISE EXCEPTION 'narrative_multiplication_terminal_event_invalid' USING ERRCODE='22023';
  END IF;
  IF NOT event.formation_id=ANY(multiplication_seen) THEN
   endings:=endings||jsonb_build_array(jsonb_build_object(
     'tecnica','Moltiplicazione del corpo','actor_id',event.actor_id,
     'stato','terminato','causa',CASE event.terminal_reason
       WHEN 'first_attack' THEN 'primo_attacco_risolto'
       WHEN 'assault_resolved' THEN 'assalto_risolto' END));
   multiplication_seen:=array_append(multiplication_seen,event.formation_id);
  END IF;
 END LOOP;
 RETURN jsonb_build_object('fonti_tecniche',sources,'conclusioni_effetti_server',endings);
END $function$;
ALTER FUNCTION combat_consumer_private.narrative_tech_sources_v1(uuid) OWNER TO postgres;
REVOKE ALL ON FUNCTION combat_consumer_private.narrative_tech_sources_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_consumer_private.narrative_tech_sources_v1(uuid) TO postgres;
DO $post$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_consumer_private.narrative_tech_sources_v1(uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='6d7cbbfbd1ecbae7f8efad6e7eeaca36'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_consumer_private.narrative_tech_sources_v1(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_consumer_private.scene_snapshot_v2(uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='a417e6a98201a2177cb8c244a736bb3c'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_consumer_private.scene_snapshot_v2(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_attack_finish(uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='f60b492d859826ab5ecec533d2e55c24'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_attack_finish(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_finish(uuid,text)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='37bcebd323ebc8efaf063e528447865f'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_finish(uuid,text)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_resolve_choice(uuid,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='a714486e7aa9d72dd447c928e2dbd6c4'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_resolve_choice(uuid,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_selection_immutable()')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='245f77354bd850b318831f2a2a04bac3'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_selection_immutable()'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_state_guard()')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='f4729b355136bab6528798b8f12911f8'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_state_guard()'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_v2_sha256(jsonb)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='4dc3868f16311c1fffdb3d6b2fd733ce'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_v2_sha256(jsonb)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_assault_end()')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='16ac1cebd0b314a09d07f8e93e764104'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_panel_private.multiplication_assault_end()'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='ecca3d1eb3f65c5bf5badb76899181a1'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('combat_v2_round_resolve(uuid,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='ade52361f248f3e09a85825ac501d503'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','combat_v2_round_resolve(uuid,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_narrative_claim_v1(uuid,text,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='5bc5cd86dd03ebe4687c7388131165a3'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='1668f80c8d0503ec16d4b87f60e9d204'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_scene_acquire_v2(uuid,text,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='be12d9b6c331465ff4c338b8b66566d3'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_scene_acquire_v2(uuid,text,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_scene_complete_v2(uuid,text,uuid)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='153777708128d14d5b482d08dad24f9e'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_scene_complete_v2(uuid,text,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_scene_permit_v2(uuid,text,uuid,text,bigint)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='55af27b8ee0746648d1f7676a1a4e97b'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_scene_permit_v2(uuid,text,uuid,text,bigint)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure('public.combat_consumer_scene_save_v2(uuid,text,uuid,text)')
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))='c1e86541aa230e0d2438079895b0451f'
    AND pg_catalog.pg_get_userbyid(p.proowner)='postgres'
    AND p.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %','public.combat_consumer_scene_save_v2(uuid,text,uuid,text)'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) || jsonb_build_object('constraints',(SELECT jsonb_agg(jsonb_build_object(
        'name',co.conname,'type',co.contype,'definition',pg_catalog.pg_get_constraintdef(co.oid)) ORDER BY co.conname)
        FROM pg_catalog.pg_constraint co WHERE co.conrelid=c.oid),
        'triggers',(SELECT jsonb_agg(jsonb_build_object('name',tr.tgname,'enabled',tr.tgenabled,
         'definition',pg_catalog.pg_get_triggerdef(tr.oid),'function',tr.tgfoid::regprocedure::text) ORDER BY tr.tgname)
         FROM pg_catalog.pg_trigger tr WHERE tr.tgrelid=c.oid AND NOT tr.tgisinternal)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('combat_panel_private.multiplication_formations')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"id","type":"uuid","notnull":true},{"name":"session_id","type":"uuid","notnull":true},{"name":"round_id","type":"uuid","notnull":true},{"name":"actor_id","type":"uuid","notnull":true},{"name":"declaration_id","type":"uuid","notnull":true},{"name":"instance_id","type":"uuid","notnull":true},{"name":"source_body_version","type":"bigint","notnull":true},{"name":"mode","type":"text","notnull":true},{"name":"copy_count","type":"integer","notnull":true},{"name":"copy_cap","type":"integer","notnull":true},{"name":"figures","type":"jsonb","notnull":true},{"name":"original_index","type":"integer","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"state_version","type":"bigint","notnull":true},{"name":"terminal_reason","type":"text","notnull":false},{"name":"created_at","type":"timestamp with time zone","notnull":true},{"name":"ended_at","type":"timestamp with time zone","notnull":false}],"constraints":[{"name":"multiplication_formations_actor_id_fkey","type":"f","definition":"FOREIGN KEY (actor_id) REFERENCES combat_v2_actors(id)"},{"name":"multiplication_formations_check","type":"c","definition":"CHECK ((copy_cap >= copy_count))"},{"name":"multiplication_formations_check1","type":"c","definition":"CHECK (combat_panel_private.multiplication_formation_valid(figures, copy_count, copy_cap, original_index))"},{"name":"multiplication_formations_check2","type":"c","definition":"CHECK (((state = ''active''::text) = (ended_at IS NULL)))"},{"name":"multiplication_formations_check3","type":"c","definition":"CHECK (((state = ''active''::text) = (terminal_reason IS NULL)))"},{"name":"multiplication_formations_check4","type":"c","definition":"CHECK (((state <> ''consumed''::text) OR (terminal_reason = ANY (ARRAY[''first_attack''::text, ''assault_resolved''::text]))))"},{"name":"multiplication_formations_check5","type":"c","definition":"CHECK (((state <> ''expired''::text) OR (terminal_reason <> ALL (ARRAY[''first_attack''::text, ''assault_resolved''::text]))))"},{"name":"multiplication_formations_copy_count_check","type":"c","definition":"CHECK ((copy_count > 0))"},{"name":"multiplication_formations_declaration_id_fkey","type":"f","definition":"FOREIGN KEY (declaration_id) REFERENCES combat_v2_declarations(id)"},{"name":"multiplication_formations_declaration_id_key","type":"u","definition":"UNIQUE (declaration_id)"},{"name":"multiplication_formations_instance_id_fkey","type":"f","definition":"FOREIGN KEY (instance_id) REFERENCES combat_spatial.arena_instances(instance_id)"},{"name":"multiplication_formations_mode_check","type":"c","definition":"CHECK ((mode = ANY (ARRAY[''diversivo''::text, ''copertura''::text, ''assalto''::text])))"},{"name":"multiplication_formations_pkey","type":"p","definition":"PRIMARY KEY (id)"},{"name":"multiplication_formations_round_id_fkey","type":"f","definition":"FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id)"},{"name":"multiplication_formations_session_id_fkey","type":"f","definition":"FOREIGN KEY (session_id) REFERENCES combat_v2_sessions(id)"},{"name":"multiplication_formations_source_body_version_check","type":"c","definition":"CHECK ((source_body_version > 0))"},{"name":"multiplication_formations_state_check","type":"c","definition":"CHECK ((state = ANY (ARRAY[''active''::text, ''consumed''::text, ''expired''::text])))"},{"name":"multiplication_formations_state_version_check","type":"c","definition":"CHECK ((state_version > 0))"},{"name":"multiplication_formations_terminal_reason_check","type":"c","definition":"CHECK ((terminal_reason = ANY (ARRAY[''first_attack''::text, ''assault_resolved''::text, ''owner_next_action''::text, ''owner_inoperative''::text, ''combat_end''::text, ''formation_invalid''::text])))"}],"triggers":[{"name":"panel_multiplication_identity","enabled":"O","function":"combat_panel_private.multiplication_state_guard()","definition":"CREATE TRIGGER panel_multiplication_identity BEFORE INSERT OR UPDATE ON combat_panel_private.multiplication_formations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_state_guard()"},{"name":"sabaku_clone_formation_created","enabled":"O","function":"clan_sabaku_private.clone_formation_trigger()","definition":"CREATE TRIGGER sabaku_clone_formation_created AFTER INSERT ON combat_panel_private.multiplication_formations FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_formation_trigger()"}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','combat_panel_private.multiplication_formations'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) || jsonb_build_object('constraints',(SELECT jsonb_agg(jsonb_build_object(
        'name',co.conname,'type',co.contype,'definition',pg_catalog.pg_get_constraintdef(co.oid)) ORDER BY co.conname)
        FROM pg_catalog.pg_constraint co WHERE co.conrelid=c.oid),
        'triggers',(SELECT jsonb_agg(jsonb_build_object('name',tr.tgname,'enabled',tr.tgenabled,
         'definition',pg_catalog.pg_get_triggerdef(tr.oid),'function',tr.tgfoid::regprocedure::text) ORDER BY tr.tgname)
         FROM pg_catalog.pg_trigger tr WHERE tr.tgrelid=c.oid AND NOT tr.tgisinternal)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('combat_panel_private.multiplication_resolutions')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"formation_id","type":"uuid","notnull":true},{"name":"attack_target_id","type":"uuid","notnull":true},{"name":"chooser_actor_id","type":"uuid","notnull":true},{"name":"selected_index","type":"integer","notnull":true},{"name":"choice_kind","type":"text","notnull":true},{"name":"outcome","type":"text","notnull":true},{"name":"rng_seed","type":"bytea","notnull":false},{"name":"facts","type":"jsonb","notnull":true},{"name":"receipt_sha256","type":"text","notnull":true},{"name":"created_at","type":"timestamp with time zone","notnull":true}],"constraints":[{"name":"multiplication_resolutions_attack_target_id_fkey","type":"f","definition":"FOREIGN KEY (attack_target_id) REFERENCES combat_v2_attack_targets(id)"},{"name":"multiplication_resolutions_check","type":"c","definition":"CHECK (((choice_kind = ''server_random''::text) = (rng_seed IS NOT NULL)))"},{"name":"multiplication_resolutions_choice_kind_check","type":"c","definition":"CHECK ((choice_kind = ANY (ARRAY[''explicit''::text, ''server_random''::text, ''formation_coverage''::text, ''active_dojutsu''::text])))"},{"name":"multiplication_resolutions_chooser_actor_id_fkey","type":"f","definition":"FOREIGN KEY (chooser_actor_id) REFERENCES combat_v2_actors(id)"},{"name":"multiplication_resolutions_facts_check","type":"c","definition":"CHECK ((jsonb_typeof(facts) = ''object''::text))"},{"name":"multiplication_resolutions_formation_id_fkey","type":"f","definition":"FOREIGN KEY (formation_id) REFERENCES combat_panel_private.multiplication_formations(id)"},{"name":"multiplication_resolutions_outcome_check","type":"c","definition":"CHECK ((outcome = ANY (ARRAY[''copy_hit''::text, ''original_found''::text])))"},{"name":"multiplication_resolutions_pkey","type":"p","definition":"PRIMARY KEY (formation_id, attack_target_id)"},{"name":"multiplication_resolutions_receipt_sha256_check","type":"c","definition":"CHECK ((receipt_sha256 ~ ''^[0-9a-f]{64}$''::text))"},{"name":"multiplication_resolutions_rng_seed_check","type":"c","definition":"CHECK (((rng_seed IS NULL) OR (octet_length(rng_seed) = 32)))"},{"name":"multiplication_resolutions_selected_index_check","type":"c","definition":"CHECK ((selected_index > 0))"}],"triggers":[{"name":"panel_multiplication_resolution_immutable","enabled":"O","function":"combat_panel_private.multiplication_selection_immutable()","definition":"CREATE TRIGGER panel_multiplication_resolution_immutable BEFORE DELETE OR UPDATE ON combat_panel_private.multiplication_resolutions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_selection_immutable()"}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','combat_panel_private.multiplication_resolutions'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) || jsonb_build_object('constraints',(SELECT jsonb_agg(jsonb_build_object(
        'name',co.conname,'type',co.contype,'definition',pg_catalog.pg_get_constraintdef(co.oid)) ORDER BY co.conname)
        FROM pg_catalog.pg_constraint co WHERE co.conrelid=c.oid),
        'triggers',(SELECT jsonb_agg(jsonb_build_object('name',tr.tgname,'enabled',tr.tgenabled,
         'definition',pg_catalog.pg_get_triggerdef(tr.oid),'function',tr.tgfoid::regprocedure::text) ORDER BY tr.tgname)
         FROM pg_catalog.pg_trigger tr WHERE tr.tgrelid=c.oid AND NOT tr.tgisinternal)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('public.combat_v2_attack_targets')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres,service_role=arw/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"id","type":"uuid","notnull":true},{"name":"round_id","type":"uuid","notnull":true},{"name":"attack_declaration_id","type":"uuid","notnull":true},{"name":"ordinal","type":"smallint","notnull":true},{"name":"target_actor_id","type":"uuid","notnull":true},{"name":"target_controller_version","type":"bigint","notnull":true},{"name":"target_position_m","type":"integer","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"outcome","type":"jsonb","notnull":false},{"name":"rng_receipt_sha256","type":"text","notnull":false},{"name":"created_at","type":"timestamp with time zone","notnull":true}],"constraints":[{"name":"combat_v2_attack_targets_attack_declaration_id_fkey","type":"f","definition":"FOREIGN KEY (attack_declaration_id) REFERENCES combat_v2_declarations(id) ON DELETE RESTRICT"},{"name":"combat_v2_attack_targets_attack_declaration_id_ordinal_key","type":"u","definition":"UNIQUE (attack_declaration_id, ordinal)"},{"name":"combat_v2_attack_targets_attack_declaration_id_target_actor_key","type":"u","definition":"UNIQUE (attack_declaration_id, target_actor_id)"},{"name":"combat_v2_attack_targets_id_attack_declaration_id_key","type":"u","definition":"UNIQUE (id, attack_declaration_id)"},{"name":"combat_v2_attack_targets_ordinal_check","type":"c","definition":"CHECK (((ordinal >= 1) AND (ordinal <= 3)))"},{"name":"combat_v2_attack_targets_outcome_check","type":"c","definition":"CHECK (((outcome IS NULL) OR (jsonb_typeof(outcome) = ''object''::text)))"},{"name":"combat_v2_attack_targets_pkey","type":"p","definition":"PRIMARY KEY (id)"},{"name":"combat_v2_attack_targets_rng_receipt_sha256_check","type":"c","definition":"CHECK (((rng_receipt_sha256 IS NULL) OR (rng_receipt_sha256 ~ ''^[0-9a-f]{64}$''::text)))"},{"name":"combat_v2_attack_targets_round_id_fkey","type":"f","definition":"FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id) ON DELETE RESTRICT"},{"name":"combat_v2_attack_targets_state_check","type":"c","definition":"CHECK ((state = ANY (ARRAY[''attesa_difesa''::text, ''coperta''::text, ''risolta''::text, ''superflua''::text])))"},{"name":"combat_v2_attack_targets_target_actor_id_fkey","type":"f","definition":"FOREIGN KEY (target_actor_id) REFERENCES combat_v2_actors(id) ON DELETE RESTRICT"}],"triggers":[{"name":"panel_immobilization_attack","enabled":"O","function":"combat_panel_private.immobilization_attack_trigger()","definition":"CREATE TRIGGER panel_immobilization_attack AFTER INSERT OR UPDATE OF state, outcome ON public.combat_v2_attack_targets FOR EACH ROW EXECUTE FUNCTION combat_panel_private.immobilization_attack_trigger()"}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','public.combat_v2_attack_targets'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) || jsonb_build_object('constraints',(SELECT jsonb_agg(jsonb_build_object(
        'name',co.conname,'type',co.contype,'definition',pg_catalog.pg_get_constraintdef(co.oid)) ORDER BY co.conname)
        FROM pg_catalog.pg_constraint co WHERE co.conrelid=c.oid),
        'triggers',(SELECT jsonb_agg(jsonb_build_object('name',tr.tgname,'enabled',tr.tgenabled,
         'definition',pg_catalog.pg_get_triggerdef(tr.oid),'function',tr.tgfoid::regprocedure::text) ORDER BY tr.tgname)
         FROM pg_catalog.pg_trigger tr WHERE tr.tgrelid=c.oid AND NOT tr.tgisinternal)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('public.combat_v2_declarations')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"id","type":"uuid","notnull":true},{"name":"round_id","type":"uuid","notnull":true},{"name":"actor_id","type":"uuid","notnull":true},{"name":"kind","type":"text","notnull":true},{"name":"parent_attack_id","type":"uuid","notnull":false},{"name":"target_actor_id","type":"uuid","notnull":false},{"name":"sanitized_intent","type":"jsonb","notnull":true},{"name":"declaration_text","type":"text","notnull":true},{"name":"controller_user_snapshot","type":"uuid","notnull":true},{"name":"controller_version_snapshot","type":"bigint","notnull":true},{"name":"request_key","type":"uuid","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"outcome","type":"jsonb","notnull":false},{"name":"order_no","type":"integer","notnull":false},{"name":"tie_break","type":"bigint","notnull":false},{"name":"cost_snapshot","type":"jsonb","notnull":true},{"name":"created_at","type":"timestamp with time zone","notnull":true},{"name":"frozen_at","type":"timestamp with time zone","notnull":false}],"constraints":[{"name":"combat_v2_declarations_actor_id_fkey","type":"f","definition":"FOREIGN KEY (actor_id) REFERENCES combat_v2_actors(id) ON DELETE RESTRICT"},{"name":"combat_v2_declarations_cost_snapshot_check","type":"c","definition":"CHECK ((jsonb_typeof(cost_snapshot) = ''object''::text))"},{"name":"combat_v2_declarations_declaration_text_check","type":"c","definition":"CHECK ((char_length(declaration_text) <= 5000))"},{"name":"combat_v2_declarations_kind_check","type":"c","definition":"CHECK ((kind = ANY (ARRAY[''attacco''::text, ''difesa''::text, ''movimento''::text, ''utilita''::text, ''passa''::text, ''nessuna''::text])))"},{"name":"combat_v2_declarations_parent_attack_id_fkey","type":"f","definition":"FOREIGN KEY (parent_attack_id) REFERENCES combat_v2_declarations(id) ON DELETE RESTRICT"},{"name":"combat_v2_declarations_parent_chk","type":"c","definition":"CHECK (((kind = ANY (ARRAY[''difesa''::text, ''nessuna''::text])) = (parent_attack_id IS NOT NULL)))"},{"name":"combat_v2_declarations_pkey","type":"p","definition":"PRIMARY KEY (id)"},{"name":"combat_v2_declarations_round_id_fkey","type":"f","definition":"FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id) ON DELETE RESTRICT"},{"name":"combat_v2_declarations_round_id_request_key_key","type":"u","definition":"UNIQUE (round_id, request_key)"},{"name":"combat_v2_declarations_sanitized_intent_check","type":"c","definition":"CHECK ((jsonb_typeof(sanitized_intent) = ''object''::text))"},{"name":"combat_v2_declarations_state_check","type":"c","definition":"CHECK ((state = ANY (ARRAY[''bozza_server''::text, ''inviata''::text, ''congelata''::text, ''risolta''::text, ''superflua''::text])))"},{"name":"combat_v2_declarations_target_actor_id_fkey","type":"f","definition":"FOREIGN KEY (target_actor_id) REFERENCES combat_v2_actors(id) ON DELETE RESTRICT"},{"name":"combat_v2_declarations_target_chk","type":"c","definition":"CHECK (((kind <> ''attacco''::text) OR (target_actor_id IS NOT NULL)))"}],"triggers":[{"name":"combat_v2_declarations_multitarget_sync","enabled":"O","function":"combat_v2_multitarget_internal.sync_declaration()","definition":"CREATE TRIGGER combat_v2_declarations_multitarget_sync AFTER INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_v2_multitarget_internal.sync_declaration()"},{"name":"marionetta_terminal_event","enabled":"O","function":"clan_marionettisti_private.declaration_terminal_trigger()","definition":"CREATE TRIGGER marionetta_terminal_event AFTER UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_marionettisti_private.declaration_terminal_trigger()"},{"name":"panel_actor_turn_declaration","enabled":"O","function":"combat_panel_private.actor_turn_lifecycle()","definition":"CREATE TRIGGER panel_actor_turn_declaration AFTER INSERT OR UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle()"},{"name":"panel_declaration_ready","enabled":"O","function":"combat_panel_private.master_entry_trigger()","definition":"CREATE TRIGGER panel_declaration_ready BEFORE INSERT OR UPDATE OF round_id, actor_id, kind ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_entry_trigger()"},{"name":"panel_multiplication_assault_end","enabled":"O","function":"combat_panel_private.multiplication_assault_end()","definition":"CREATE TRIGGER panel_multiplication_assault_end AFTER UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_assault_end()"},{"name":"panel_multiplication_next_action","enabled":"O","function":"combat_panel_private.multiplication_next_action()","definition":"CREATE TRIGGER panel_multiplication_next_action BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_next_action()"},{"name":"sabaku_master_main","enabled":"O","function":"clan_sabaku_private.master_turn_lifecycle()","definition":"CREATE TRIGGER sabaku_master_main BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.master_turn_lifecycle()"}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','public.combat_v2_declarations'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) || jsonb_build_object('constraints',(SELECT jsonb_agg(jsonb_build_object(
        'name',co.conname,'type',co.contype,'definition',pg_catalog.pg_get_constraintdef(co.oid)) ORDER BY co.conname)
        FROM pg_catalog.pg_constraint co WHERE co.conrelid=c.oid),
        'triggers',(SELECT jsonb_agg(jsonb_build_object('name',tr.tgname,'enabled',tr.tgenabled,
         'definition',pg_catalog.pg_get_triggerdef(tr.oid),'function',tr.tgfoid::regprocedure::text) ORDER BY tr.tgname)
         FROM pg_catalog.pg_trigger tr WHERE tr.tgrelid=c.oid AND NOT tr.tgisinternal)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('public.combat_v2_rounds')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"id","type":"uuid","notnull":true},{"name":"session_id","type":"uuid","notnull":true},{"name":"round_no","type":"integer","notnull":true},{"name":"phase","type":"text","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"engine_version","type":"text","notnull":true},{"name":"resolver_version","type":"text","notnull":true},{"name":"order_version","type":"text","notnull":true},{"name":"quality_version","type":"text","notnull":true},{"name":"evaluation_mode","type":"text","notnull":true},{"name":"rng_order_commitment","type":"text","notnull":false},{"name":"freeze_at","type":"timestamp with time zone","notnull":false},{"name":"resolved_at","type":"timestamp with time zone","notnull":false},{"name":"narrated_at","type":"timestamp with time zone","notnull":false},{"name":"report_id","type":"uuid","notnull":false},{"name":"created_at","type":"timestamp with time zone","notnull":true}],"constraints":[{"name":"combat_v2_rounds_evaluation_mode_check","type":"c","definition":"CHECK ((evaluation_mode = ANY (ARRAY[''umana''::text, ''neutra''::text])))"},{"name":"combat_v2_rounds_phase_check","type":"c","definition":"CHECK ((phase = ANY (ARRAY[''raccolta_azioni''::text, ''raccolta_difese''::text, ''congelato''::text, ''valutazione''::text, ''risoluzione''::text, ''risolto''::text, ''narrazione''::text, ''narrato''::text])))"},{"name":"combat_v2_rounds_pkey","type":"p","definition":"PRIMARY KEY (id)"},{"name":"combat_v2_rounds_rng_order_commitment_check","type":"c","definition":"CHECK (((rng_order_commitment IS NULL) OR (rng_order_commitment ~ ''^[0-9a-f]{64}$''::text)))"},{"name":"combat_v2_rounds_round_no_check","type":"c","definition":"CHECK ((round_no >= 1))"},{"name":"combat_v2_rounds_session_id_fkey","type":"f","definition":"FOREIGN KEY (session_id) REFERENCES combat_v2_sessions(id) ON DELETE RESTRICT"},{"name":"combat_v2_rounds_session_id_round_no_key","type":"u","definition":"UNIQUE (session_id, round_no)"},{"name":"combat_v2_rounds_state_check","type":"c","definition":"CHECK ((state = ANY (ARRAY[''raccolta_azioni''::text, ''raccolta_difese''::text, ''congelato''::text, ''valutazione''::text, ''risoluzione''::text, ''risolto''::text, ''narrazione''::text, ''narrato''::text])))"}],"triggers":[{"name":"marionetta_command_window","enabled":"O","function":"clan_marionettisti_private.round_window_trigger()","definition":"CREATE TRIGGER marionetta_command_window AFTER INSERT OR UPDATE OF phase ON public.combat_v2_rounds FOR EACH ROW EXECUTE FUNCTION clan_marionettisti_private.round_window_trigger()"},{"name":"panel_actor_turn_round","enabled":"O","function":"combat_panel_private.actor_turn_lifecycle()","definition":"CREATE TRIGGER panel_actor_turn_round AFTER INSERT OR UPDATE OF phase ON public.combat_v2_rounds FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle()"},{"name":"sabaku_clone_round_end","enabled":"O","function":"clan_sabaku_private.clone_lifecycle_trigger()","definition":"CREATE TRIGGER sabaku_clone_round_end AFTER UPDATE OF phase ON public.combat_v2_rounds FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_lifecycle_trigger()"}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','public.combat_v2_rounds'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('combat_consumer_private.narrative_claims')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"id","type":"uuid","notnull":true},{"name":"session_id","type":"uuid","notnull":true},{"name":"round_id","type":"uuid","notnull":true},{"name":"report_id","type":"uuid","notnull":true},{"name":"report_sha256","type":"text","notnull":true},{"name":"context_version","type":"bigint","notnull":true},{"name":"control_version","type":"bigint","notnull":true},{"name":"context_payload","type":"jsonb","notnull":true},{"name":"context_sha256","type":"text","notnull":true},{"name":"request_key","type":"uuid","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"claimed_at","type":"timestamp with time zone","notnull":true},{"name":"expires_at","type":"timestamp with time zone","notnull":true},{"name":"completion_sha256","type":"text","notnull":false},{"name":"completion_result","type":"jsonb","notnull":false},{"name":"provider_response_id","type":"text","notnull":false},{"name":"provider_request_sha256","type":"text","notnull":false},{"name":"raw_output_sha256","type":"text","notnull":false},{"name":"failure_code","type":"text","notnull":false}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','combat_consumer_private.narrative_claims'; END IF;
 IF (SELECT jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)) FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass('combat_consumer_private.scene_attempts_v2')) IS DISTINCT FROM '{"owner":"postgres","acl":"{postgres=arwdDxtm/postgres}","relrowsecurity":true,"relforcerowsecurity":true,"columns":[{"name":"claim_id","type":"uuid","notnull":true},{"name":"request_key","type":"uuid","notnull":true},{"name":"round_id","type":"uuid","notnull":true},{"name":"session_id","type":"uuid","notnull":true},{"name":"scene_payload","type":"jsonb","notnull":true},{"name":"scene_sha256","type":"text","notnull":true},{"name":"state","type":"text","notnull":true},{"name":"permit_at","type":"timestamp with time zone","notnull":false},{"name":"result_bytes","type":"text","notnull":false},{"name":"result_payload","type":"jsonb","notnull":false},{"name":"result_sha256","type":"text","notnull":false},{"name":"provider_response_id","type":"text","notnull":false},{"name":"failure_code","type":"text","notnull":false},{"name":"completion","type":"jsonb","notnull":false},{"name":"created_at","type":"timestamp with time zone","notnull":true},{"name":"result_at","type":"timestamp with time zone","notnull":false},{"name":"redelivery_at","type":"timestamp with time zone","notnull":false},{"name":"redelivery_state","type":"text","notnull":false},{"name":"redelivery_request_id","type":"bigint","notnull":false}]}'::jsonb THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %','combat_consumer_private.scene_attempts_v2'; END IF;
END $post$;
COMMIT;
