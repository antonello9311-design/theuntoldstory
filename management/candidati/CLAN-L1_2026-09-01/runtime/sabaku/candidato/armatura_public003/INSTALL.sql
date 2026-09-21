BEGIN;

DO $pre$
DECLARE
  x record;
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM clan_sabaku_private.armor_release_gate
    WHERE singleton AND staff_enabled AND NOT public_enabled
  ) THEN
    RAISE EXCEPTION 'armor_public_gate_preflight_failed';
  END IF;

  IF (SELECT count(*) FROM clan_sabaku_private.armor_release_gate) <> 1 THEN
    RAISE EXCEPTION 'armor_public_gate_cardinality_drift';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM supabase_migrations.schema_migrations
    WHERE version = '20260920121925' AND name = 'sabaku_armor_passive_restore_20260920'
  ) OR NOT EXISTS (
    SELECT 1 FROM supabase_migrations.schema_migrations
    WHERE version = '20260920125041' AND name = 'sabaku_armor_narrative_route_20260920'
  ) THEN
    RAISE EXCEPTION 'armor_public_version_not_installed';
  END IF;

  FOR x IN
    SELECT * FROM jsonb_to_recordset('[
      {"signature":"clan_sabaku_private.armor_eligible(uuid)","md5":"ef9636b2fcf9f359b5c1887a7129b2b5"},
      {"signature":"clan_sabaku_private.armor_view(uuid)","md5":"90fe0d4d182c535c83974ee52efb807d"},
      {"signature":"clan_sabaku_private.armor_activate(uuid,uuid)","md5":"34c9eed8b323df32c3565e43da4517fc"},
      {"signature":"clan_sabaku_private.armor_upkeep(uuid)","md5":"ec65446a98c62cca01ee5b1beef9e3d1"},
      {"signature":"clan_sabaku_private.armor_absorb(uuid,integer)","md5":"e23261cc3fd2dcd2fcbe7152a0db046e"},
      {"signature":"clan_sabaku_private.consumer_options(jsonb)","md5":"38da00e07241064c3b53936b8e6ae5ac"},
      {"signature":"combat_consumer_private.narrative_context(uuid)","md5":"eea64327d3c61def5386f8ef666d5b54"}
    ]'::jsonb) AS j(signature text, md5 text)
  LOOP
    IF to_regprocedure(x.signature) IS NULL
       OR (SELECT md5(p.prosrc) FROM pg_proc p WHERE p.oid = to_regprocedure(x.signature)) <> x.md5 THEN
      RAISE EXCEPTION 'armor_public_function_drift:%', x.signature;
    END IF;
  END LOOP;

  IF NOT EXISTS (
    SELECT 1
    FROM public.clan_techniques
    WHERE id = 'bb9bd1d4-e0b2-4e20-9bd4-48d14fe8344d'::uuid
      AND name = 'Armatura di Sabbia'
      AND is_active
      AND uso = 'passiva'
  ) THEN
    RAISE EXCEPTION 'armor_public_catalog_not_ready';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'clan_sabaku_private'
      AND c.relname = 'armor_release_gate'
      AND c.relrowsecurity
      AND c.relforcerowsecurity
  ) THEN
    RAISE EXCEPTION 'armor_public_gate_rls_drift';
  END IF;

  IF has_table_privilege('anon', 'clan_sabaku_private.armor_release_gate', 'SELECT,INSERT,UPDATE,DELETE')
     OR has_table_privilege('authenticated', 'clan_sabaku_private.armor_release_gate', 'SELECT,INSERT,UPDATE,DELETE')
     OR has_table_privilege('service_role', 'clan_sabaku_private.armor_release_gate', 'SELECT,INSERT,UPDATE,DELETE')
     OR EXISTS (SELECT 1 FROM pg_policy WHERE polrelid = 'clan_sabaku_private.armor_release_gate'::regclass)
     OR EXISTS (SELECT 1 FROM pg_trigger WHERE tgrelid = 'clan_sabaku_private.armor_release_gate'::regclass AND NOT tgisinternal) THEN
    RAISE EXCEPTION 'armor_public_gate_security_drift';
  END IF;
END $pre$;

UPDATE clan_sabaku_private.armor_release_gate
SET public_enabled = true
WHERE singleton AND staff_enabled AND NOT public_enabled;

DO $post$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM clan_sabaku_private.armor_release_gate
    WHERE singleton AND staff_enabled AND public_enabled
  ) THEN
    RAISE EXCEPTION 'armor_public_gate_enable_failed';
  END IF;

  IF has_table_privilege('anon', 'clan_sabaku_private.armor_release_gate', 'SELECT,INSERT,UPDATE,DELETE')
     OR has_table_privilege('authenticated', 'clan_sabaku_private.armor_release_gate', 'SELECT,INSERT,UPDATE,DELETE')
     OR has_table_privilege('service_role', 'clan_sabaku_private.armor_release_gate', 'SELECT,INSERT,UPDATE,DELETE')
     OR EXISTS (SELECT 1 FROM pg_policy WHERE polrelid = 'clan_sabaku_private.armor_release_gate'::regclass)
     OR EXISTS (SELECT 1 FROM pg_trigger WHERE tgrelid = 'clan_sabaku_private.armor_release_gate'::regclass AND NOT tgisinternal) THEN
    RAISE EXCEPTION 'armor_public_gate_acl_drift';
  END IF;
END $post$;

COMMIT;
