-- SOURCE RECOVERY TEMPLATE: genuine postflight expected_rows required. No bodyrestore/delete.
BEGIN;SET LOCAL search_path=pg_catalog;SET LOCAL lock_timeout='5s';
DO $human_recovery$
DECLARE ev jsonb:=nullif(current_setting('tus_human_cfg.root_evidence',true),'')::jsonb;
 rows_now jsonb; kept_before jsonb; kept_after jsonb; public_before jsonb; public_pin jsonb; affected integer;
BEGIN
 IF current_user IS DISTINCT FROM 'postgres' OR ev IS NULL
 OR NOT mission_factory_owner.keys_exact_v2(ev,ARRAY['schema_version','operation','review_sha256','request_key','release_sha256','expected_rows'])
 OR (ev->>'schema_version') IS DISTINCT FROM 'human-land-cfg-recovery/1'
 OR (ev->>'operation') IS DISTINCT FROM 'close_own_manual_human_staff'
 OR coalesce((ev->>'review_sha256'),'') !~ '^[0-9a-f]{64}$'
 OR ((ev->>'request_key'))::uuid IS NULL
 OR (ev->>'release_sha256') IS DISTINCT FROM '37dac90525b249f53fc0404b50adb4ed92df0123649326c99260bf656119d806'
 THEN RAISE EXCEPTION 'HUMAN_RECOVERY_AUTHORITY_REQUIRED';END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('human-land-cfg-20261013',13102026));
 LOCK TABLE mission_factory_owner.c384_control,mission_factory_owner.c395_control,
 mission_factory_owner.c407_control,mission_factory_owner.c412_control,
 mission_factory_owner.c416_kind_admission,mission_factory_owner.c444_runtime_control,
 mission_factory_owner.c463_optin_control,mission_factory_owner.c464_control,
 mission_factory_owner.manual_authoring_admissions_v1,
 mission_factory_owner.provider_authoring_admissions IN SHARE ROW EXCLUSIVE MODE;
 LOCK TABLE mission_public_owner.public_authoring_gate_v1,
 mission_factory_owner.quest_fixed30_admission,
 mission_factory_owner.quest_arcs,mission_factory_owner.quest_run_sources IN SHARE ROW EXCLUSIVE MODE;
 public_before:=jsonb_build_object('public_authoring_gate',(SELECT jsonb_build_object('enabled',enabled,'release_sha256',release_sha256,'provider_enabled',provider_enabled) FROM mission_public_owner.public_authoring_gate_v1 WHERE singleton),'fixed_gates',(SELECT jsonb_build_object('staff_enabled',staff_enabled,'public_enabled',public_enabled,'public_staff_enabled',public_staff_enabled,'scheduler_staff_enabled',scheduler_staff_enabled,'scheduler_public_enabled',scheduler_public_enabled) FROM mission_factory_owner.quest_fixed30_admission WHERE singleton));
 IF public_before IS DISTINCT FROM $public_expected${"fixed_gates":{"staff_enabled":false,"public_enabled":false,"public_staff_enabled":false,"scheduler_staff_enabled":false,"scheduler_public_enabled":false},"public_authoring_gate":{"enabled":false,"release_sha256":null,"provider_enabled":false}}$public_expected$::jsonb
 OR mission_public_owner.public_authoring_allowed_v1(false) IS DISTINCT FROM false
 THEN RAISE EXCEPTION 'HUMAN_CFG_PUBLIC_GATE_DRIFT'; END IF;
 FOR public_pin IN SELECT value FROM jsonb_array_elements($publicpins$[{"ddl_md5":"749af8b1814fe5a5e15fcd2a61429dbe","signature":"mission_factory_owner.quest_publication_scope_v3(uuid,boolean)"},{"ddl_md5":"9f7591ca1b250c2872c7eae765ebecd7","signature":"mission_factory_owner.quest_public_open_v3(uuid)"},{"ddl_md5":"c1817c9d483581bea98960281fe9a87e","signature":"mission_factory_owner.quest_execution_assert_v4(uuid,boolean)"},{"ddl_md5":"5e2f03193dc89332d13da9e746714a6f","signature":"mission_public_owner.public_authoring_allowed_v1(boolean)"},{"ddl_md5":"ca0225fd2a1486e5050d3a6358e3e10c","signature":"mission_factory_owner.c384_human_identity_v1(uuid)"},{"ddl_md5":"a70ec1466b5dafa67ea07638c423c047","signature":"mission_factory_owner.c395_revision_assert_v1(uuid)"},{"ddl_md5":"88db535e51a63c320ed871c6869bef78","signature":"mission_factory_owner.c395_active_human_assert_v1(uuid)"},{"ddl_md5":"1e98938354fcb8e27cf826ab90f22770","signature":"mission_factory_owner.c407_identity_v1(uuid)"},{"ddl_md5":"81648004bde571b78c0161701574b22c","signature":"mission_factory_owner.c407_active_v1(uuid,text)"},{"ddl_md5":"1cd93323b761cb3dce2e532c57c834ba","signature":"mission_factory_owner.c412_read_identity_v1(uuid)"},{"ddl_md5":"32ec00ca959f80230de52b27d01aea2f","signature":"mission_factory_owner.c416_draft_assert_v1(uuid,boolean)"},{"ddl_md5":"25128ad39faa60077da6f10b0f277b1a","signature":"mission_factory_owner.c416_arc_assert_v1(uuid,boolean)"}]$publicpins$::jsonb) LOOP
  IF to_regprocedure((public_pin->>'signature')) IS NULL
  OR md5(pg_get_functiondef(to_regprocedure((public_pin->>'signature')))) IS DISTINCT FROM (public_pin->>'ddl_md5')
  THEN RAISE EXCEPTION 'HUMAN_CFG_PUBLIC_HUMAN_GUARD_DRIFT'; END IF;
 END LOOP;
 rows_now:=jsonb_build_object('c384',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c384_control hrow WHERE singleton),'c395',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c395_control hrow WHERE singleton),'c407',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c407_control hrow WHERE singleton),'c412',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c412_control hrow WHERE singleton),'c416',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c416_kind_admission hrow WHERE singleton),'c444',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c444_runtime_control hrow WHERE singleton),'c463',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c463_optin_control hrow WHERE singleton),'c464',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c464_control hrow WHERE singleton),'manual',(SELECT coalesce(jsonb_agg(to_jsonb(hrow) ORDER BY actor_user,release_sha256),'[]'::jsonb) FROM mission_factory_owner.manual_authoring_admissions_v1 hrow),'provider_admissions',(SELECT coalesce(jsonb_agg(jsonb_build_object('enabled',enabled,'expires_at',expires_at) ORDER BY enabled,expires_at),'[]'::jsonb) FROM mission_factory_owner.provider_authoring_admissions hrow));
 IF (rows_now-'manual') IS DISTINCT FROM ((ev->'expected_rows')-'manual')
 OR NOT((rows_now->'manual') @> (ev#>'{expected_rows,manual}') AND (ev#>'{expected_rows,manual}') @> (rows_now->'manual'))
 OR jsonb_array_length((rows_now->'manual'))<>jsonb_array_length((ev#>'{expected_rows,manual}'))
 OR (rows_now#>>'{c416,request_key}') IS DISTINCT FROM (ev->>'request_key')
 OR (rows_now#>>'{c416,review_sha256}') IS DISTINCT FROM (ev->>'review_sha256')
 OR (rows_now#>>'{c444,review_sha256}') IS DISTINCT FROM (ev->>'review_sha256')
 THEN RAISE EXCEPTION 'HUMAN_RECOVERY_NOT_EXACT_OWN_POSTIMAGE';END IF;
 IF EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND closed_at IS NULL)
 THEN RAISE EXCEPTION 'HUMAN_RECOVERY_CLOSE_OWN_SCENES_NORMALLY_FIRST';END IF;
 kept_before:=jsonb_build_object('c384',(rows_now->'c384'),'c395',(rows_now->'c395'),'c407',(rows_now->'c407'),'c412',(rows_now->'c412'),'old_manual',(SELECT jsonb_agg(to_jsonb(hrow) ORDER BY actor_user,release_sha256) FROM mission_factory_owner.manual_authoring_admissions_v1 hrow WHERE release_sha256<>'37dac90525b249f53fc0404b50adb4ed92df0123649326c99260bf656119d806'),'c464',(rows_now->'c464'),'c463',(rows_now->'c463'),'provider',(rows_now->'provider_admissions'));
 UPDATE mission_factory_owner.manual_authoring_admissions_v1 SET enabled=false
 WHERE release_sha256=(ev->>'release_sha256') AND actor_user IN('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid);
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>2 THEN RAISE EXCEPTION 'HUMAN_RECOVERY_ADMISSION_COUNT';END IF;
 UPDATE mission_factory_owner.c416_kind_admission SET enabled=false WHERE singleton;
 UPDATE mission_factory_owner.c444_runtime_control SET enabled=false WHERE singleton;
 rows_now:=jsonb_build_object('c384',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c384_control hrow WHERE singleton),'c395',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c395_control hrow WHERE singleton),'c407',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c407_control hrow WHERE singleton),'c412',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c412_control hrow WHERE singleton),'c416',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c416_kind_admission hrow WHERE singleton),'c444',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c444_runtime_control hrow WHERE singleton),'c463',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c463_optin_control hrow WHERE singleton),'c464',(SELECT to_jsonb(hrow) FROM mission_factory_owner.c464_control hrow WHERE singleton),'manual',(SELECT coalesce(jsonb_agg(to_jsonb(hrow) ORDER BY actor_user,release_sha256),'[]'::jsonb) FROM mission_factory_owner.manual_authoring_admissions_v1 hrow),'provider_admissions',(SELECT coalesce(jsonb_agg(jsonb_build_object('enabled',enabled,'expires_at',expires_at) ORDER BY enabled,expires_at),'[]'::jsonb) FROM mission_factory_owner.provider_authoring_admissions hrow));
 IF jsonb_build_object('public_authoring_gate',(SELECT jsonb_build_object('enabled',enabled,'release_sha256',release_sha256,'provider_enabled',provider_enabled) FROM mission_public_owner.public_authoring_gate_v1 WHERE singleton),'fixed_gates',(SELECT jsonb_build_object('staff_enabled',staff_enabled,'public_enabled',public_enabled,'public_staff_enabled',public_staff_enabled,'scheduler_staff_enabled',scheduler_staff_enabled,'scheduler_public_enabled',scheduler_public_enabled) FROM mission_factory_owner.quest_fixed30_admission WHERE singleton)) IS DISTINCT FROM public_before THEN RAISE EXCEPTION 'HUMAN_RECOVERY_PUBLIC_SCOPE_CHANGED'; END IF;
 kept_after:=jsonb_build_object('c384',(rows_now->'c384'),'c395',(rows_now->'c395'),'c407',(rows_now->'c407'),'c412',(rows_now->'c412'),'old_manual',(SELECT jsonb_agg(to_jsonb(hrow) ORDER BY actor_user,release_sha256) FROM mission_factory_owner.manual_authoring_admissions_v1 hrow WHERE release_sha256<>'37dac90525b249f53fc0404b50adb4ed92df0123649326c99260bf656119d806'),'c464',(rows_now->'c464'),'c463',(rows_now->'c463'),'provider',(rows_now->'provider_admissions'));
 IF kept_after IS DISTINCT FROM kept_before THEN RAISE EXCEPTION 'HUMAN_RECOVERY_SHARED_DRIFT';END IF;
END $human_recovery$;COMMIT;
