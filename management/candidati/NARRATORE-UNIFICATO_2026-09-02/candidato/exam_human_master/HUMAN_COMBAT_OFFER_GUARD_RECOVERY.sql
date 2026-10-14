BEGIN;DO $guard$ BEGIN IF current_user<>'postgres' OR current_setting('tus.human_combat_offer_guard_recovery',true) IS DISTINCT FROM 'reviewed:0/0/0' THEN RAISE EXCEPTION 'HUMAN25_AUTHORITY';END IF;IF md5(pg_get_functiondef('mission_factory_owner.quest_combat_offer_source_guard_v1()'::regprocedure)) IS DISTINCT FROM 'f8bf245cd0febaf305479598b95bae46' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.quest_combat_offer_source_guard_v1()'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.quest_combat_offer_source_guard_v1()'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN25_BASELINE_DRIFT';END IF;IF NOT EXISTS(SELECT 1 FROM pg_trigger WHERE tgname='master_v2_nb_quest_offer_source_guard' AND tgrelid='public.master_v2_nb_actor_offers_v1'::regclass AND tgfoid='mission_factory_owner.quest_combat_offer_source_guard_v1()'::regprocedure AND tgenabled='O') THEN RAISE EXCEPTION 'HUMAN25_TRIGGER_BINDING_DRIFT';END IF;IF NOT EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE id='97d2a684-956d-57ad-8d84-aca627dd9e5c' AND suspended_at IS NOT NULL AND closed_at IS NULL) OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE master_session_id='97d2a684-956d-57ad-8d84-aca627dd9e5c' AND state NOT IN('chiuso','annullato')) THEN RAISE EXCEPTION 'HUMAN25_SUSPENDED_SCOPE_REQUIRED';END IF;PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();END $guard$;
CREATE OR REPLACE FUNCTION mission_factory_owner.quest_combat_offer_source_guard_v1()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare q mission_factory_owner.quest_run_sources%rowtype;
  m public.master_v2_sessions%rowtype;
  r public.mission_run_state%rowtype;
  c mission_ai_service_owner.capabilities%rowtype;
  d mission_generic_owner.definitions%rowtype;
begin
  if tg_op='UPDATE' then
    if (old.source_kind,old.master_session_id,old.mission_id,
        old.quest_episode_id,old.quest_source_sha256,
        old.narrative_template_id,old.narrative_version_id,
        old.mechanical_template_id,old.mechanical_version_id)
       is distinct from
       (new.source_kind,new.master_session_id,new.mission_id,
        new.quest_episode_id,new.quest_source_sha256,
        new.narrative_template_id,new.narrative_version_id,
        new.mechanical_template_id,new.mechanical_version_id)
    then raise exception 'MF_QUEST_OFFER_IDENTITY_IMMUTABLE' using errcode='42501'; end if;
  end if;
  if new.source_kind='mission' then return new; end if;
  perform mission_factory_owner.quest_run_source_assert_v1(new.master_session_id);
  select * into strict q from mission_factory_owner.quest_run_sources
    where session_id=new.master_session_id for share;
  select * into strict m from public.master_v2_sessions
    where id=new.master_session_id for share;
  select * into strict r from public.mission_run_state
    where master_session_id=new.master_session_id for share;
  select * into strict d from mission_generic_owner.definitions
    where id=q.definition_id for share;
  IF mission_factory_owner.c395_human_mode_v1(new.master_session_id) THEN
    RAISE EXCEPTION 'HUMAN25_RECOVERY_COMBAT_OFFER_CLOSED' USING ERRCODE='42501';
    PERFORM mission_factory_owner.c407_active_v1(new.master_session_id,'admission');
    IF auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated'
       OR m.master_user IS DISTINCT FROM auth.uid() OR m.owner_kind IS DISTINCT FROM 'human'
       OR q.state IS DISTINCT FROM 'started' OR m.stato IS DISTINCT FROM 'in_corso'
       OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL
       OR new.source_kind IS DISTINCT FROM 'quest' OR new.mission_id IS NOT NULL
       OR new.recipient_kind IS DISTINCT FROM 'human' OR new.recipient_user IS DISTINCT FROM m.master_user
       OR new.recipient_service_capability IS NOT NULL OR new.created_by_service_capability IS NOT NULL
       OR new.created_by IS DISTINCT FROM auth.uid()
       OR new.quest_episode_id IS DISTINCT FROM q.episode_id OR new.quest_source_sha256 IS DISTINCT FROM q.source_sha256
       OR m.tipo IS DISTINCT FROM 'quest' OR m.mission_id IS NOT NULL
       OR r.source_kind IS DISTINCT FROM 'quest' OR r.quest_episode_id IS DISTINCT FROM q.episode_id
       OR r.plan_version_id IS DISTINCT FROM q.plan_version_id OR r.current_step_key IS NULL
       OR r.run_phase IS DISTINCT FROM 'in_corso' OR (tg_op='INSERT' AND new.expected_master_control_version IS DISTINCT FROM m.control_version)
       OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(d.definition->'scenes') sc,
          LATERAL jsonb_array_elements(sc.value->'encounters') en,
          LATERAL jsonb_array_elements(en.value->'actors') actor
          JOIN public.nb_mechanical_bindings binding ON binding.id=(actor.value->>'mechanical_binding_id')::uuid
          WHERE sc.value->>'step_key'=r.current_step_key AND actor.value->>'combat'='true'
          AND (actor.value->>'narrative_template_id')::uuid=new.narrative_template_id
          AND (actor.value->>'narrative_version_id')::uuid=new.narrative_version_id
          AND binding.narrative_template_id=new.narrative_template_id
          AND binding.narrative_version_id=new.narrative_version_id
          AND binding.mechanical_template_id=new.mechanical_template_id
          AND binding.mechanical_version_id=new.mechanical_version_id
          AND binding.active AND binding.lifecycle_state='approved'
          AND mission_generic_owner.binding_is_pinned(new.master_session_id,binding.id))
    THEN RAISE EXCEPTION 'MF_QUEST_HUMAN_OFFER_SOURCE_INVALID' USING ERRCODE='42501';END IF;
    RETURN new;
  END IF;
  select * into strict c from mission_ai_service_owner.capabilities
    where id=mission_factory_owner.quest_capability_assert_v1(new.master_session_id)
      and id=new.recipient_service_capability for share;
  if q.state<>'started' or new.recipient_kind<>'ai_service'
     or new.recipient_user is not null or new.created_by is not null
     or new.created_by_service_capability is distinct from c.id
     or new.quest_episode_id is distinct from q.episode_id
     or new.quest_source_sha256 is distinct from q.source_sha256
     or m.tipo<>'quest' or m.mission_id is not null
     or m.owner_kind<>'ai_service' or m.stato<>'in_corso'
     or r.source_kind<>'quest' or r.quest_episode_id is distinct from q.episode_id
     or r.plan_version_id is distinct from q.plan_version_id
     or r.current_step_key is null or r.run_phase<>'in_corso'
     or c.master_session_id is distinct from q.session_id or c.state<>'active'
     or not exists(select 1 from jsonb_array_elements(d.definition->'scenes') sc,
          lateral jsonb_array_elements(sc.value->'encounters') en,
          lateral jsonb_array_elements(en.value->'actors') actor
       where sc.value->>'step_key'=r.current_step_key
         and actor.value->>'combat'='true'
         and (actor.value->>'narrative_template_id')::uuid=new.narrative_template_id
         and (actor.value->>'narrative_version_id')::uuid=new.narrative_version_id
         and (actor.value->>'mechanical_binding_id')::uuid in
           (select b.id from public.nb_mechanical_bindings b
             where b.narrative_template_id=new.narrative_template_id
               and b.narrative_version_id=new.narrative_version_id
               and b.mechanical_template_id=new.mechanical_template_id
               and b.mechanical_version_id=new.mechanical_version_id
               and b.active and b.lifecycle_state='approved'))
  then raise exception 'MF_QUEST_OFFER_SOURCE_INVALID' using errcode='42501'; end if;
  return new;
end; $function$
;
DO $post$ BEGIN IF md5((SELECT prosrc FROM pg_proc WHERE oid='mission_factory_owner.quest_combat_offer_source_guard_v1()'::regprocedure)) IS DISTINCT FROM '4a3d8c2124eaa8b8bcb8d7d0467b455e' THEN RAISE EXCEPTION 'HUMAN25_POSTFLIGHT_DRIFT';END IF;PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();END $post$;COMMIT;
