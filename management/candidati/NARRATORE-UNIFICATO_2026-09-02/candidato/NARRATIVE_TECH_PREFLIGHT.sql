-- Readonly assertions of body, owner and exact ACL. No silent normalization.
DO $pin$ BEGIN
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'narrative_tech_postgres_owner_required'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_consumer_private.scene_snapshot_v2(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='542eb2b95627522ee8e0f28507fdf29b'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_consumer_private.scene_snapshot_v2(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_panel_private.narrative_ordinary_context(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='ec6a66b6599cdfb3d80aea6c12c9dd43'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_panel_private.narrative_ordinary_context(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_panel_private.narrative_declaration_facts(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='037f85e391975594049c08b91df5008a'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_panel_private.narrative_declaration_facts(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_panel_private.narrative_clone_facts(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='6341d8856acf6a01e877a891feee4019'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_panel_private.narrative_clone_facts(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_actor_profile(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='ae1c065dcea82548cb954768b2bffce4'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_panel_private.multiplication_actor_profile(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_bind_declaration(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='f5eee385a0ac19ea360bb99b14d0c371'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_panel_private.multiplication_bind_declaration(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('clan_sabaku_private.clone_release(uuid,text)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='ee1aee1336e24b53bbb756b4ecd11045'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: clan_sabaku_private.clone_release(uuid,text)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('clan_sabaku_private.clone_ready(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='3e09f5c8d13089c4754b9bbebe1164c9'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: clan_sabaku_private.clone_ready(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('clan_sabaku_private.clone_trigger_nearby(uuid,uuid,text,uuid,uuid,uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='bb273f4aa9001c29ea6d337a7af8d4b1'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: clan_sabaku_private.clone_trigger_nearby(uuid,uuid,text,uuid,uuid,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='80434afefcecbc48e190999830389cee'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('public.combat_v2_values_written(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='843e9ef632c305142e1825513f5c1da5'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: public.combat_v2_values_written(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='5d92acb102cf08fb6407c25efb6032b0'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_consumer_private.narrative_declaration_supported(uuid)'; END IF;
 IF to_regprocedure('combat_consumer_private.narrative_tech_sources_v1(uuid)') IS NOT NULL THEN RAISE EXCEPTION 'narrative_tech_helper_exists'; END IF;
END $pin$;
