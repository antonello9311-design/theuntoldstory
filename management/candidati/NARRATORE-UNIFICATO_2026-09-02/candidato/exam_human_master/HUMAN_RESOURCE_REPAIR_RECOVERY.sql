-- Conservative stop only; retain new code and all resource/history rows.
-- Close own test via normal UI before applying this recovery.
DO $recovery$ BEGIN
IF current_user IS DISTINCT FROM 'postgres' OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND closed_at IS NULL) THEN RAISE EXCEPTION 'HUMAN_RESOURCE_REPAIR_QUIESCENT_ROOT_RECOVERY_REQUIRED';END IF;
IF md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=pg_catalog.to_regprocedure('mission_factory_owner.c352_native_resource_source_v1()'))) IS DISTINCT FROM '5902f4292ef7b167aa1ad664255fdcee' THEN RAISE EXCEPTION 'HUMAN_RESOURCE_REPAIR_POST_BODY:c352_native_resource_source_v1';END IF;
IF md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=pg_catalog.to_regprocedure('mission_factory_owner.c352_prepare_resource_v1(jsonb)'))) IS DISTINCT FROM 'e40a932dcdd73e39068268e94f8345d0' THEN RAISE EXCEPTION 'HUMAN_RESOURCE_REPAIR_POST_BODY:c352_prepare_resource_v1';END IF;
IF md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=pg_catalog.to_regprocedure('mission_factory_owner.c352_resource_catalog_v1()'))) IS DISTINCT FROM 'b77c874e033de63803c9958672d36fe1' THEN RAISE EXCEPTION 'HUMAN_RESOURCE_REPAIR_POST_BODY:c352_resource_catalog_v1';END IF;
IF md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=pg_catalog.to_regprocedure('mission_factory_owner.c408_stage1_complete_assert_v1()'))) IS DISTINCT FROM '5e6ffd85200853f395de66a474cab046' THEN RAISE EXCEPTION 'HUMAN_RESOURCE_REPAIR_POST_BODY:c408_stage1_complete_assert_v1';END IF;
IF md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=pg_catalog.to_regprocedure('mission_factory_owner.c444_runtime_ports_complete_assert_v1()'))) IS DISTINCT FROM 'd48f7ef77c9f47fb7147a2520859001a' THEN RAISE EXCEPTION 'HUMAN_RESOURCE_REPAIR_POST_BODY:c444_runtime_ports_complete_assert_v1';END IF;
UPDATE mission_factory_owner.c352_resource_selection SET enabled=false,control_version=control_version+1,updated_at=statement_timestamp() WHERE singleton AND enabled AND control_version=1 AND resource_version_id='a533b3c8-6092-4605-ad52-baadc460e3ad';
IF NOT FOUND THEN RAISE EXCEPTION 'HUMAN_RESOURCE_REPAIR_RECOVERY_SELECTION_CAS';END IF;
END $recovery$;
