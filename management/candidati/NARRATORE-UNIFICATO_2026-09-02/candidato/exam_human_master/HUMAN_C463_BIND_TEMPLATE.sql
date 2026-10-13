-- SOURCE TEMPLATE ONLY: session ID and genuine fresh Root evidence missing.
-- No apply, no Auth impersonation, no session start or Native optin insertion.
BEGIN;
SET LOCAL search_path=pg_catalog;
SET LOCAL lock_timeout='5s';
DO $human_c463$
DECLARE
 ev jsonb:=nullif(current_setting('tus_human_c463.root_evidence',true),'')::jsonb;
 ctrl mission_factory_owner.c463_optin_control;
 human_ctrl mission_factory_owner.c444_runtime_control;
 kind_ctrl mission_factory_owner.c416_kind_admission;
 master_row public.master_v2_sessions;
 source_row mission_factory_owner.quest_run_sources;
 binding_row mission_factory_owner.c384_human_bindings;
 prepared_row mission_factory_owner.c395_prepared_sources;
 runtime_row public.mission_run_state;
 actor_ids uuid[];sid uuid;lease_end timestamptz;changed integer;
BEGIN
 IF current_user IS DISTINCT FROM 'postgres' OR ev IS NULL
 OR NOT mission_factory_owner.keys_exact_v2(ev,ARRAY['schema_version','operation','session_id','prepare_request_key','expected_source_sha256','expected_control_version','expected_c463','expected_c444','expected_c416','review_sha256','review_findings','authority_sha256','authority_ref','review_ref','permit_expires_at','function_pins'])
 OR (ev->>'schema_version') IS DISTINCT FROM 'human-land-c463-root/1'
 OR (ev->>'operation') IS DISTINCT FROM 'bind_single_prepared_human_session'
 OR (ev->'review_findings') IS DISTINCT FROM '[0,0,0]'::jsonb
 OR coalesce(ev->>'review_sha256','') !~ '^[0-9a-f]{64}$'
 OR coalesce(ev->>'authority_sha256','') !~ '^[0-9a-f]{64}$'
 OR nullif(btrim(ev->>'authority_ref'),'') IS NULL
 OR nullif(btrim(ev->>'review_ref'),'') IS NULL
 OR (ev->>'session_id') IS NULL OR (ev->>'prepare_request_key') IS NULL
 OR coalesce(ev->>'expected_source_sha256','') !~ '^[0-9a-f]{64}$'
 OR (ev->>'expected_control_version') IS DISTINCT FROM '1'
 OR (ev->>'permit_expires_at') IS NULL
 OR (ev->>'permit_expires_at')::timestamptz<=statement_timestamp()
 OR (ev->>'permit_expires_at')::timestamptz>statement_timestamp()+interval '15 minutes'
 THEN RAISE EXCEPTION 'HUMAN_C463_GENUINE_PREPARED_ROOT_SCOPE_REQUIRED';END IF;
 sid:=(ev->>'session_id')::uuid;
 PERFORM pg_advisory_xact_lock(hashtextextended('human-land-c463-bind',13102026));
 LOCK TABLE mission_factory_owner.c463_optin_control,mission_factory_owner.c444_runtime_control,
 mission_factory_owner.c416_kind_admission IN SHARE ROW EXCLUSIVE MODE;
 SELECT * INTO STRICT ctrl FROM mission_factory_owner.c463_optin_control WHERE singleton FOR UPDATE;
 SELECT * INTO STRICT human_ctrl FROM mission_factory_owner.c444_runtime_control WHERE singleton FOR SHARE;
 SELECT * INTO STRICT kind_ctrl FROM mission_factory_owner.c416_kind_admission WHERE singleton FOR SHARE;
 IF to_jsonb(ctrl) IS DISTINCT FROM (ev->'expected_c463')
 OR to_jsonb(human_ctrl) IS DISTINCT FROM (ev->'expected_c444')
 OR to_jsonb(kind_ctrl) IS DISTINCT FROM (ev->'expected_c416')
 OR ctrl.enabled OR cardinality(ctrl.master_user_ids)<>0 OR cardinality(ctrl.session_ids)<>0
 OR NOT human_ctrl.enabled OR human_ctrl.bound_at>statement_timestamp() OR human_ctrl.expires_at<=statement_timestamp()
 OR NOT kind_ctrl.enabled OR kind_ctrl.bound_at>statement_timestamp() OR kind_ctrl.expires_at<=statement_timestamp()
 THEN RAISE EXCEPTION 'HUMAN_C463_CONTROL_BASELINE_DRIFT';END IF;
 -- Root must replace this failclosed sentinel with an exact OID/full-DDL/ACL/config pin loop
 -- from fresh live capture before freeze; accepting a caller-supplied pin array is not verification.
 RAISE EXCEPTION 'HUMAN_C463_TEMPLATE_UNFROZEN_FUNCTION_PINS';
 PERFORM 1 FROM public.locations WHERE id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid FOR UPDATE;
 PERFORM public.master_v2_lock_scope(sid);
 SELECT * INTO STRICT master_row FROM public.master_v2_sessions WHERE id=sid FOR UPDATE;
 SELECT * INTO STRICT source_row FROM mission_factory_owner.quest_run_sources WHERE session_id=sid FOR UPDATE;
 SELECT * INTO STRICT binding_row FROM mission_factory_owner.c384_human_bindings WHERE session_id=sid FOR SHARE;
 SELECT * INTO STRICT prepared_row FROM mission_factory_owner.c395_prepared_sources WHERE session_id=sid FOR SHARE;
 SELECT * INTO STRICT runtime_row FROM public.mission_run_state WHERE master_session_id=sid FOR SHARE;
 SELECT array_agg(c.user_id ORDER BY roster.ord) INTO actor_ids
 FROM unnest(source_row.roster_character_ids) WITH ORDINALITY roster(id,ord)
 JOIN public.characters c ON c.id=roster.id;
 IF master_row.master_user IS DISTINCT FROM 'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid
 OR binding_row.assigned_master IS DISTINCT FROM master_row.master_user
 OR prepared_row.assigned_master IS DISTINCT FROM master_row.master_user
 OR master_row.tipo IS DISTINCT FROM 'quest' OR master_row.owner_kind IS DISTINCT FROM 'human'
 OR master_row.mission_id IS NOT NULL OR master_row.stato IS DISTINCT FROM 'preparazione'
 OR master_row.closed_at IS NOT NULL OR master_row.suspended_at IS NOT NULL
 OR master_row.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR master_row.control_version<>1 OR source_row.control_version<>1 OR runtime_row.control_version<>1
 OR source_row.state IS DISTINCT FROM 'prepared' OR source_row.start_request_key IS NOT NULL
 OR source_row.prepare_request_key IS DISTINCT FROM (ev->>'prepare_request_key')::uuid
 OR prepared_row.prepare_request IS DISTINCT FROM source_row.prepare_request_key
 OR source_row.source_sha256 IS DISTINCT FROM (ev->>'expected_source_sha256')
 OR source_row.location_id IS DISTINCT FROM master_row.location_id
 OR source_row.availability_scope IS DISTINCT FROM 'staff' OR source_row.execution_context IS DISTINCT FROM 'staff_simulation'
 OR runtime_row.run_phase IS DISTINCT FROM 'preparazione' OR runtime_row.source_kind IS DISTINCT FROM 'quest'
 OR runtime_row.mission_id IS NOT NULL OR runtime_row.quest_episode_id IS DISTINCT FROM source_row.episode_id
 OR runtime_row.plan_version_id IS DISTINCT FROM source_row.plan_version_id
 OR cardinality(actor_ids) IS DISTINCT FROM cardinality(source_row.roster_character_ids)
 OR cardinality(actor_ids) NOT BETWEEN 1 AND 4
 OR NOT(actor_ids <@ ARRAY['f0856d53-83a6-4de0-bc0c-12c87916e665','b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b']::uuid[])
 OR NOT EXISTS(SELECT 1 FROM public.locations WHERE id=master_row.location_id AND is_active AND is_test)
 OR combat_consumer_private.staff_test_allowed(master_row.location_id,array_append(actor_ids,master_row.master_user),false) IS DISTINCT FROM true
 OR EXISTS(SELECT 1 FROM mission_creation_owner.human_encounters WHERE master_session_id=sid)
 OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE master_session_id=sid AND state NOT IN('chiuso','annullato'))
 OR EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_session_optins_v1 WHERE master_session_id=sid)
 THEN RAISE EXCEPTION 'HUMAN_C463_NOT_EXACT_OWN_PROTECTED_PREPARED_SCOPE';END IF;
 lease_end:=least(human_ctrl.expires_at,kind_ctrl.expires_at);
 -- Existing CHECK requires exactly 120 minutes. Inherit the Human window, never renew it.
 UPDATE mission_factory_owner.c463_optin_control SET enabled=true,
 review_sha256=ev->>'review_sha256',master_user_ids=ARRAY[master_row.master_user],session_ids=ARRAY[sid],
 bound_at=lease_end-interval '120 minutes',expires_at=lease_end WHERE singleton;
 GET DIAGNOSTICS changed=ROW_COUNT;IF changed<>1 THEN RAISE EXCEPTION 'HUMAN_C463_UPDATE_COUNT';END IF;
END $human_c463$;
COMMIT;
