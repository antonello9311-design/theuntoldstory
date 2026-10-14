BEGIN;DO $guard$ BEGIN IF current_user<>'postgres' OR current_setting('tus.human_arena_read_authority',true) IS DISTINCT FROM 'reviewed:0/0/0' THEN RAISE EXCEPTION 'HUMAN28_AUTHORITY';END IF;IF md5(pg_get_functiondef('mission_factory_owner.c408_stage1_complete_assert_v1()'::regprocedure)) IS DISTINCT FROM 'bbe6f3c025f1eed0a7202dd1aaff5ca6' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c408_stage1_complete_assert_v1()'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.c408_stage1_complete_assert_v1()'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN28_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('mission_factory_owner.c444_source_read_assert_v1(uuid)'::regprocedure)) IS DISTINCT FROM 'e5465b8559d26f3859f1b5b7546f4706' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c444_source_read_assert_v1(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.c444_source_read_assert_v1(uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN28_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure)) IS DISTINCT FROM '557b15687a93af5f6218a252c6de0332' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN28_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('public.universal_arena_state_v1(uuid)'::regprocedure)) IS DISTINCT FROM 'e880037a61aba8aec7a2e2508fd9a0e7' OR (SELECT proacl::text FROM pg_proc WHERE oid='public.universal_arena_state_v1(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres,authenticated=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='public.universal_arena_state_v1(uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN28_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('mission_generic_owner.arena_state(uuid)'::regprocedure)) IS DISTINCT FROM 'bbf91ef6c2c18dae633440b82a29aedb' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_generic_owner.arena_state(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_generic_owner.arena_state(uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN28_BASELINE_DRIFT';END IF;IF NOT EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE id='97d2a684-956d-57ad-8d84-aca627dd9e5c' AND suspended_at IS NOT NULL AND closed_at IS NULL) THEN RAISE EXCEPTION 'HUMAN28_SUSPENDED_OWN_SCOPE_REQUIRED';END IF;PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();END $guard$;
CREATE OR REPLACE FUNCTION mission_generic_owner.arena_state(p_master uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare q mission_factory_owner.quest_run_sources%rowtype;
 r public.mission_run_state%rowtype;
 m public.master_v2_sessions%rowtype;
 sc jsonb; ar jsonb;
begin
 if exists(select 1 from mission_factory_owner.quest_run_sources where session_id=p_master) then
   IF mission_factory_owner.c395_human_mode_v1(p_master) THEN
     PERFORM mission_factory_owner.c444_source_read_assert_v1(p_master);
     SELECT * INTO STRICT q FROM mission_factory_owner.quest_run_sources WHERE session_id=p_master;
     SELECT * INTO STRICT r FROM public.mission_run_state WHERE master_session_id=p_master;
     SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_master;
   ELSE
   perform mission_factory_owner.quest_run_source_assert_v1(p_master);
   select * into strict q from mission_factory_owner.quest_run_sources where session_id=p_master for share;
   select * into strict r from public.mission_run_state where master_session_id=p_master for share;
   select * into strict m from public.master_v2_sessions where id=p_master for share;
   END IF;
   if q.state<>'started' or r.source_kind<>'quest' or r.run_phase<>'in_corso'
      or not exists(select 1 from public.mission_run_outbox o
        where o.master_session_id=p_master and o.step_key=r.current_step_key
          and o.event_version_after=r.control_version and o.state='published'
          and o.publication_id is not null)
   then return jsonb_build_object('schema_version','universal-arena-state/1',
     'status','unavailable','reason','scene_not_published','master_session_id',p_master); end if;
   sc:=mission_factory_owner.quest_scene_v1(p_master,r.current_step_key);
   ar:=sc->'arena_ref';
   if jsonb_typeof(ar)<>'object' then return jsonb_build_object(
     'schema_version','universal-arena-state/1','status','unavailable',
     'reason','narrative_phase','master_session_id',p_master); end if;
   return jsonb_build_object('schema_version','universal-arena-state/1',
     'status','ready','master_session_id',p_master,'origin','quest',
     'quest_episode_id',q.episode_id,'location_id',m.location_id,
     'template_key',ar->>'template_key',
     'template_version',(ar->>'template_version')::integer,
     'zone_key',ar->>'zone_key',
     'catalog_sha256',(sc->'encounters'->0)->>'arena_catalog_sha256',
     'frozen_at',q.created_at);
 end if;
 return (select case when b.snapshot?'creation' then mission_creation_owner.arena_state(p_master) else jsonb_build_object('schema_version','universal-arena-state/1','status','ready','master_session_id',p_master,
 'origin','mission','mission_id',native_ms.mission_id,'location_id',native_ms.location_id,
 'template_key',b.snapshot#>>'{arena,template_key}','template_version',(b.snapshot#>>'{arena,template_version}')::integer,
 'zone_key',b.snapshot#>>'{arena,zone_key}','catalog_sha256',b.snapshot#>>'{arena,catalog_sha256}','frozen_at',b.attached_at) end
 from mission_generic_owner.run_bindings b join public.master_v2_sessions native_ms on native_ms.id=b.master_session_id
 where b.master_session_id=p_master and b.snapshot_sha256=mission_internal.fingerprint(b.snapshot));
end $function$
;
DO $post$ BEGIN IF md5((SELECT prosrc FROM pg_proc WHERE oid='mission_generic_owner.arena_state(uuid)'::regprocedure)) IS DISTINCT FROM '1fad310e5f479e8561fdb390be270f2b' THEN RAISE EXCEPTION 'HUMAN28_POST_DRIFT';END IF;PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();END $post$;COMMIT;
