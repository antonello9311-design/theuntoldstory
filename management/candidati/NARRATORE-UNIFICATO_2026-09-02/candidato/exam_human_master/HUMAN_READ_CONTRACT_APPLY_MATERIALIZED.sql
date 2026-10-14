BEGIN;
SELECT pg_catalog.set_config('tus.human_read_contract_authority','reviewed:0/0/0',true);
SELECT pg_catalog.set_config('tus.human23_root_authority',$root_authority${"schema_version":"human23-root-authority/1","request_key":"0f735929-aae9-466c-9279-2a3c698ea70c","operation":"install_complete_Human_read_contract_after_actual_Human22_postflight_own_suspended","human_aggregate":23,"review_findings":[0,0,0],"review_sha256":"2b5b010d8313c212089dd06dbdae1aa9bb92f073550326fe226753c698dd1e91","source_sha256":"e86bf12fe92e700cb686fd6ee47b1a31570b930d8c9b862d94670a0b997435c3","issued_at":"2026-10-14T20:06:53.348316+00:00","expires_at":"2026-10-14T20:12:53.348316+00:00","campaign_deadline":"2026-10-14T20:14:02.801045+00:00","human_extension":"Autorizzo altri 20 minuti","session_id":"97d2a684-956d-57ad-8d84-aca627dd9e5c","Human22_actual_postflight_required_not_yet_claimed":true,"provider_calls":0,"provider_tokens":0,"WIP_reset":false,"Staff_renewal":false,"client_sha256":"fc1fd74d4e916de520d807bad60138ce060ff5e1b4666626aafe6dc0893a2541","scope":"CompleteHumanreadGETgraph only, currentH22pinchain, preserveordinaryAI/mutatinglocks/ACL/sourceauthority/C463lease. Freshbaseline ownnormalUIsuspension H22postflight and independentmaterial0/0/0 required."}$root_authority$,true);
DO $root_permit$ DECLARE e jsonb:=current_setting('tus.human23_root_authority',true)::jsonb;BEGIN IF current_user<>'postgres' OR e->>'schema_version'<>'human23-root-authority/1' OR e->'review_findings'<>'[0,0,0]'::jsonb OR (e->>'expires_at')::timestamptz<=clock_timestamp() THEN RAISE EXCEPTION 'HUMAN23_FRESH_ROOT_PERMIT';END IF;END $root_permit$;DO $guard$ BEGIN IF current_user<>'postgres' OR current_setting('tus.human_read_contract_authority',true) IS DISTINCT FROM 'reviewed:0/0/0' THEN RAISE EXCEPTION 'HUMAN23_AUTHORITY';END IF;IF md5(pg_get_functiondef('mission_generic_owner.regia_human_direction_context_v1(uuid)'::regprocedure)) IS DISTINCT FROM '8ac252aa82faf5fb802d92610ac628ef' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_generic_owner.regia_human_direction_context_v1(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_generic_owner.regia_human_direction_context_v1(uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN23_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('mission_factory_owner.c444_source_read_assert_v1(uuid)'::regprocedure)) IS DISTINCT FROM '6e18de2d68527bcf821e3ee5cc153201' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c444_source_read_assert_v1(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.c444_source_read_assert_v1(uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN23_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('public.mission_factory_quest_human_runtime_state_v1(uuid)'::regprocedure)) IS DISTINCT FROM 'c918b2c79cdc0792b4d7368bdb8c402c' OR (SELECT proacl::text FROM pg_proc WHERE oid='public.mission_factory_quest_human_runtime_state_v1(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres,authenticated=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='public.mission_factory_quest_human_runtime_state_v1(uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN23_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('mission_factory_owner.c444_terminal_confirmed_v1(uuid)'::regprocedure)) IS DISTINCT FROM 'a8d27247451c0c2bcc2edeece1e2a350' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c444_terminal_confirmed_v1(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.c444_terminal_confirmed_v1(uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN23_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('public.mission_factory_quest_d100_binding_scope_v1(uuid)'::regprocedure)) IS DISTINCT FROM '672ad1ed79deec55e492f8a0dc559b92' OR (SELECT proacl::text FROM pg_proc WHERE oid='public.mission_factory_quest_d100_binding_scope_v1(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres,authenticated=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='public.mission_factory_quest_d100_binding_scope_v1(uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN23_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('mission_factory_owner.quest_scene_v1(uuid,text)'::regprocedure)) IS DISTINCT FROM '80f4a846496e18ceab4175faf81af840' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.quest_scene_v1(uuid,text)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.quest_scene_v1(uuid,text)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN23_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('mission_factory_owner.c408_stage1_complete_assert_v1()'::regprocedure)) IS DISTINCT FROM 'd82dfb39b3a1330d5179818026c86e83' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c408_stage1_complete_assert_v1()'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.c408_stage1_complete_assert_v1()'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN23_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure)) IS DISTINCT FROM '3ebc1662e60b104e66c2c6e9a690bf0f' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN23_BASELINE_DRIFT';END IF;END $guard$;
CREATE OR REPLACE FUNCTION mission_generic_owner.regia_human_direction_context_v1(p_master_session uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE m public.master_v2_sessions%ROWTYPE; run public.mission_run_state%ROWTYPE;
 he mission_creation_owner.human_encounters%ROWTYPE; cs public.combat_v2_sessions%ROWTYPE;
 rr public.combat_v2_rounds%ROWTYPE; rep public.combat_v2_round_reports%ROWTYPE;
 spec jsonb; pg_ids uuid[]:='{}'::uuid[]; png_ids uuid[]:='{}'::uuid[];
 causes uuid[]:='{}'::uuid[]; started timestamptz; allowed boolean:=false;
 reason text:='REGIA_ENTRY_STAGING_REQUIRED'; terminal boolean:=false; active_teams integer;
BEGIN
 IF mission_factory_owner.c395_human_mode_v1(p_master_session) THEN
 PERFORM mission_factory_owner.c407_identity_v1(p_master_session);
 PERFORM mission_factory_owner.c444_source_read_assert_v1(p_master_session);
 IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources source JOIN public.master_v2_sessions master ON master.id=source.session_id WHERE source.session_id=p_master_session AND source.state='started' AND master.closed_at IS NULL AND master.suspended_at IS NULL AND master.stato IN('in_corso','chiusura') AND master.master_user=auth.uid() AND auth.role()='authenticated' AND source.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND source.availability_scope='staff' AND source.execution_context='staff_simulation') THEN RAISE EXCEPTION 'C395_HUMAN_ACTIVE_STAFF_SCOPE_REQUIRED' USING ERRCODE='42501';END IF;
 ELSE PERFORM mission_creation_owner.human_assert(p_master_session);END IF;
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_master_session;
 SELECT * INTO STRICT run FROM public.mission_run_state WHERE master_session_id=m.id;
 IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_session_optins_v1 opt
  WHERE opt.master_session_id=m.id AND opt.actor_user=m.master_user)
  OR (m.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND NOT mission_public_owner.human_session_allowed_v1(m.id))
 THEN RAISE EXCEPTION 'REGIA_NOT_OPTED_IN' USING ERRCODE='42501'; END IF;
 SELECT coalesce(max(e.created_at),run.created_at) INTO started
 FROM public.mission_run_events e WHERE e.master_session_id=m.id
  AND e.status='committed' AND e.step_after=run.current_step_key
  AND e.version_after=run.control_version;
 SELECT coalesce(array_agg(id ORDER BY created_at,id),'{}'::uuid[]) INTO causes FROM (
  SELECT msg.id,msg.created_at FROM public.messages msg
   WHERE msg.location_id=m.location_id AND msg.created_at>=started
    AND msg.created_at<=clock_timestamp() AND msg.recipient_user IS NULL
    AND ((msg.kind='say' AND EXISTS(SELECT 1 FROM public.master_v2_participants part
      JOIN public.characters ch ON ch.id=part.character_id AND ch.user_id=part.user_id_snapshot
      WHERE part.session_id=m.id AND part.character_id=msg.character_id
        AND part.joined_at<=msg.created_at AND (part.left_at IS NULL OR part.left_at>msg.created_at)))
     OR (msg.kind='fato' AND msg.character_id IS NULL
       AND (EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches ub
         WHERE ub.master_session_id=m.id AND ub.message_id=msg.id AND ub.state='published')
       OR EXISTS(SELECT 1 FROM public.fato_manual_audit a
         WHERE a.message_id=msg.id AND a.actor_user=m.master_user AND a.location_id=m.location_id))))
   ORDER BY msg.created_at DESC,msg.id DESC LIMIT 20
 ) recent;
 SELECT * INTO he FROM mission_creation_owner.human_encounters
  WHERE master_session_id=m.id AND step_key=run.current_step_key
   AND run_control_version=run.control_version;
 IF he.encounter_id IS NOT NULL THEN
  SELECT * INTO cs FROM public.combat_v2_sessions
   WHERE id=he.encounter_id AND state='in_corso' AND (NOT lesiva OR mission_public_owner.human_session_allowed_v1(m.id));
  IF cs.id IS NOT NULL AND mission_public_owner.human_resource_scope_v1(m.id,cs.id,true) THEN
   SELECT x INTO spec FROM jsonb_array_elements(mission_generic_owner.scene(m.id,run.current_step_key)->'encounters') x
    WHERE x->>'encounter_key'=he.encounter_key;
   SELECT coalesce(array_agg(a.id ORDER BY a.id),'{}'::uuid[]) INTO pg_ids
    FROM public.combat_v2_actors a WHERE a.session_id=cs.id AND a.actor_kind='pg'
     AND a.state='attivo' AND a.companion_id IS NULL;
   SELECT coalesce(array_agg(a.id ORDER BY a.id),'{}'::uuid[]) INTO png_ids
    FROM public.combat_v2_actors a WHERE a.session_id=cs.id AND a.actor_kind='png'
     AND a.state='attivo' AND a.companion_id IS NULL
     AND a.team_key IS DISTINCT FROM spec->>'pg_team';
   SELECT count(DISTINCT team_key) INTO active_teams FROM public.combat_v2_actors
    WHERE session_id=cs.id AND state='attivo' AND companion_id IS NULL;
   terminal:=active_teams<2;
   SELECT * INTO rr FROM public.combat_v2_rounds WHERE session_id=cs.id ORDER BY round_no DESC LIMIT 1;
   IF rr.round_no=1 AND rr.state='raccolta_azioni'
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows w WHERE w.round_id=rr.id)
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=rr.id)
    AND NOT terminal THEN
    allowed:=true;reason:=NULL;
   ELSIF rr.state='risolto' THEN
    SELECT * INTO rep FROM public.combat_v2_round_reports
     WHERE round_id=rr.id AND narration_state='attesa'
      AND values_written IS NOT DISTINCT FROM public.combat_v2_values_written(cs.id);
    IF rep.id IS NOT NULL AND rep.mechanics_sha256 ~ '^[0-9a-f]{64}$'
     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t
       WHERE t.round_id=rr.id AND t.state='attesa_difesa')
     AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_windows_v1 w
       WHERE w.source_round_id=rr.id OR w.source_report_id=rep.id)
     AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows w
       WHERE w.round_id=rr.id AND w.publication_id IS NOT NULL) THEN
      allowed:=true;reason:=NULL;
    ELSE reason:='REGIA_REPORT_NOT_READY'; END IF;
   ELSE reason:='REGIA_REPORT_NOT_READY'; END IF;
  ELSE reason:='REGIA_REPORT_NOT_READY'; END IF;
 END IF;
 RETURN jsonb_build_object('schema','regia-round-direction-context/1',
  'scene_step_key',run.current_step_key,
  'context_version',mission_generic_owner.regia_entry_revision_v1(m.id),
  'source_round_id',CASE WHEN allowed AND rr.state='risolto' THEN rr.id ELSE NULL END,
  'source_report_id',CASE WHEN allowed AND rr.state='risolto' THEN rep.id ELSE NULL END,
  'source_report_sha256',CASE WHEN allowed AND rr.state='risolto' THEN rep.mechanics_sha256 ELSE NULL END,
  'eligible',jsonb_build_object('pg',CASE WHEN allowed THEN to_jsonb(pg_ids) ELSE '[]'::jsonb END,
    'fato',CASE WHEN allowed THEN to_jsonb(png_ids) ELSE '[]'::jsonb END),
  'cause_message_ids',to_jsonb(causes),'can_direct',allowed,
  'reason_code',reason,'terminal',terminal);
END $function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.c444_source_read_assert_v1(p_session uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare q mission_factory_owner.quest_run_sources%rowtype;
m public.master_v2_sessions%rowtype;
e mission_factory_owner.quest_episodes%rowtype;
a mission_factory_owner.quest_arcs%rowtype;
pub mission_factory_owner.publications%rowtype;
p public.mission_plans%rowtype;
v public.mission_plan_versions%rowtype;
d mission_generic_owner.definitions%rowtype;
b mission_generic_owner.run_bindings%rowtype;
loc public.locations%rowtype;
users uuid[];
begin

PERFORM mission_factory_owner.c444_read_identity_v1(p_session);
PERFORM mission_factory_owner.c412_revision_provenance_v1(p_session);
select * into strict q from mission_factory_owner.quest_run_sources where session_id=p_session;
select * into strict m from public.master_v2_sessions where id=p_session;
select * into strict e from mission_factory_owner.quest_episodes where id=q.episode_id;
select * into strict a from mission_factory_owner.quest_arcs where id=q.arc_id;
select * into strict pub from mission_factory_owner.publications
where request_key=a.publication_request;
select * into strict p from public.mission_plans where id=q.plan_id;
select * into strict v from public.mission_plan_versions where id=q.plan_version_id;
select * into strict d from mission_generic_owner.definitions where id=q.definition_id;
select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
select * into strict loc from public.locations where id=q.location_id;
select array_agg(c.user_id order by x.ord) into users
from unnest(q.roster_character_ids) with ordinality x(id,ord)
join public.characters c on c.id=x.id and c.user_id is not null;
if m.tipo<>'quest' or m.owner_kind<>'human' or m.master_user IS DISTINCT FROM (SELECT assigned_master FROM mission_factory_owner.c384_human_bindings WHERE session_id=p_session)
or m.mission_id is not null or m.quest_kind is distinct from a.quest_kind
or m.location_id<>q.location_id
or (q.state not in ('terminal','cancelled') and m.stato in ('chiusa','annullata'))
or e.arc_id<>q.arc_id or e.source_sha256<>q.source_sha256 or e.ordinal<>q.episode_ordinal or e.member_character_ids is distinct from q.roster_character_ids
or (q.episode_ordinal>1 and not exists(select 1 from mission_factory_owner.quest_terminal_receipts tr
join mission_factory_owner.quest_episodes pe on pe.id=tr.episode_id
join mission_factory_owner.quest_run_sources pq on pq.episode_id=pe.id and pq.terminal_receipt_id=tr.id
where tr.id=q.previous_episode_terminal_receipt_id and pe.arc_id=q.arc_id and pe.ordinal=q.episode_ordinal-1
and pq.state='terminal' and tr.continuity_private_sha256=q.continuity_sha256
and tr.continuity_private_sha256=mission_factory_owner.sha(tr.continuity_private)))
or (q.state='prepared' and e.state<>'source_only')
or (q.state in('opening_pending','uncertain','started')
and e.state not in('source_only','open','in_progress'))
or a.state not in ('staff_source','public_source','in_progress','completed','failed')
or pub.content_kind<>'quest_human' or not mission_factory_owner.quest_public_open_v3(a.id)
or pub.quest_arc_id<>q.arc_id
or pub.release_revision_sha256 is distinct from q.staff_release_sha256
or p.source_kind<>'quest' or p.quest_episode_id<>q.episode_id
or p.quest_source_sha256<>q.source_sha256
or p.mission_id is not null or v.plan_id<>q.plan_id or v.stato<>'approvata'
or v.plan_sha256<>q.plan_sha256
or d.plan_version_id<>q.plan_version_id or d.plan_sha256<>q.plan_sha256
or d.definition_sha256<>q.definition_sha256
or d.definition_sha256<>mission_internal.fingerprint(d.definition)
or d.definition->>'schema_version'<>'mission-factory-quest-definition/1'
or d.definition->>'quest_episode_id' is distinct from q.episode_id::text
or d.definition->>'source_sha256' is distinct from q.source_sha256
or b.definition_id is distinct from q.definition_id
or b.snapshot is distinct from mission_factory_owner.c395_binding_projection_v1(q)
or b.snapshot_sha256 is distinct from mission_internal.fingerprint(b.snapshot)
or q.roster_snapshot_sha256<>mission_factory_owner.sha(to_jsonb(q.roster_character_ids))
or cardinality(users)<>cardinality(q.roster_character_ids)
or (select count(distinct x) from unnest(q.roster_character_ids)x)<>cardinality(q.roster_character_ids)
or not loc.is_active or loc.is_test is distinct from mission_factory_owner.quest_is_simulation_v4(q.arc_id) or (not mission_factory_owner.quest_is_simulation_v4(q.arc_id) and loc.is_exam_room)
or (mission_factory_owner.quest_is_simulation_v4(q.arc_id) and not combat_consumer_private.staff_test_allowed(q.location_id,users,false))
or q.execution_context is distinct from a.execution_context or q.execution_qualification_sha256 is distinct from a.execution_qualification_sha256
or (a.execution_context='staff_simulation' and a.availability_scope='public' and (q.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid or exists(select 1 from public.characters c where c.id=any(q.roster_character_ids) and not(c.user_id=any(a.execution_auth_ids)))))
or q.availability_scope is distinct from a.availability_scope or q.public_release_sha256 is distinct from a.public_release_sha256
then raise exception 'MF_QUEST_RUN_SOURCE_STALE' using errcode='42501'; end if;
if q.availability_scope='public' then perform mission_factory_owner.quest_execution_assert_v4(a.id,q.state not in('terminal','cancelled'));end if;
return jsonb_build_object('schema_version','quest-run-source/1',
'session_id',q.session_id,'arc_id',q.arc_id,'episode_id',q.episode_id,
'source_sha256',q.source_sha256,'plan_version_id',q.plan_version_id,
'plan_sha256',q.plan_sha256,'roster_snapshot_sha256',q.roster_snapshot_sha256,
'staff_release_sha256',q.staff_release_sha256,'location_id',q.location_id,
'state',q.state,'control_version',q.control_version);
end $function$
;
CREATE OR REPLACE FUNCTION public.mission_factory_quest_human_runtime_state_v1(p_session uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE q mission_factory_owner.quest_run_sources;m public.master_v2_sessions;r public.mission_run_state;ev public.mission_run_events;hw mission_generic_owner.regia_human_windows_v1;scene jsonb;scope jsonb;ctx jsonb;term jsonb;ds jsonb:='[]'::jsonb;reason text;active boolean;pending boolean;enc boolean;options jsonb:='[]'::jsonb;ascope jsonb;ne mission_factory_owner.quest_episodes;nextdto jsonb;
BEGIN
 PERFORM mission_factory_owner.c407_identity_v1(p_session);PERFORM mission_factory_owner.c444_source_read_assert_v1(p_session);
 SELECT * INTO STRICT q FROM mission_factory_owner.quest_run_sources WHERE session_id=p_session;SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_session;SELECT * INTO STRICT r FROM public.mission_run_state WHERE master_session_id=p_session;
 SELECT * INTO ev FROM public.mission_run_events WHERE id=r.last_event_id AND master_session_id=p_session;
 SELECT * INTO hw FROM mission_generic_owner.regia_human_windows_v1 WHERE master_session_id=p_session ORDER BY preparation_revision DESC,id DESC LIMIT 1;
 pending:=EXISTS(SELECT 1 FROM public.mission_run_outbox WHERE master_session_id=p_session AND state IN('pending','human_directed'));
 active:=q.state='started' AND m.stato='in_corso' AND m.closed_at IS NULL AND r.run_phase='in_corso';
 reason:=CASE WHEN NOT mission_factory_owner.c444_enabled_v1() OR NOT EXISTS(SELECT 1 FROM mission_factory_owner.c407_control WHERE singleton AND admission_enabled AND manual_fato_enabled AND d100_enabled) OR NOT EXISTS(SELECT 1 FROM mission_factory_owner.c412_control WHERE singleton AND runtime_enabled) THEN 'DISABLED' WHEN q.state='terminal' THEN 'TERMINAL' WHEN NOT active THEN 'NOT_ACTIVE' WHEN pending THEN 'FATO_PENDING' ELSE 'READY' END;
 ascope:=mission_factory_owner.c444_action_scope_v1(p_session);
 IF active THEN
  scene:=mission_factory_owner.quest_scene_v1(p_session,r.current_step_key);options:=coalesce(ascope->'decisions','[]'::jsonb);
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(options)o WHERE (o->'to_step_key'='null'::jsonb AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(scene->'terminal_options','[]'::jsonb))t WHERE t->>'decision_key'=o->>'decision_key' AND t->'to_step_key'='null'::jsonb)) OR (o->'to_step_key'<>'null'::jsonb AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(scene->'triggers','[]'::jsonb))t WHERE t->>'decision_key'=o->>'decision_key'))) THEN RAISE EXCEPTION 'C456_NATIVE_COMPILED_DECISION_SOURCE_DRIFT' USING ERRCODE='40001';END IF;
  IF reason='READY' THEN scope:=public.mission_factory_quest_d100_binding_scope_v1(p_session);END IF;
 END IF;
 IF q.state='terminal' THEN term:=mission_factory_owner.c444_terminal_confirmed_v1(p_session);SELECT * INTO ne FROM mission_factory_owner.quest_episodes WHERE arc_id=q.arc_id AND ordinal=q.episode_ordinal+1;IF ne.id IS NOT NULL THEN nextdto:=jsonb_build_object('quest_episode_id',ne.id,'ordinal',ne.ordinal,'source_sha256',ne.source_sha256,'eligible',mission_factory_owner.c444_enrollment_open_v1(ne.id),'reason_code',CASE WHEN NOT mission_factory_owner.c444_enabled_v1() OR mission_factory_owner.c416_kind_live_v1() IS DISTINCT FROM true THEN 'DISABLED' WHEN mission_factory_owner.c444_enrollment_open_v1(ne.id) THEN 'READY' ELSE 'NATIVE_ENROLLMENT_CLOSED' END);END IF;END IF;
 SELECT coalesce(jsonb_agg(jsonb_build_object('receipt_id',rec.id,'binding_id',b.id,'source_sha256',rec.native_facts_sha256,'decision_key',rec.decision_key,'consumed',t.receipt_id IS NOT NULL) ORDER BY rec.created_at,rec.id),'[]'::jsonb) INTO ds FROM mission_factory_owner.c353_d100_bindings b JOIN mission_factory_owner.c353_d100_receipts rec ON rec.binding_id=b.id LEFT JOIN mission_factory_owner.c360_d100_transitions t ON t.receipt_id=rec.id WHERE b.session_id=p_session AND b.quest_source_sha256=q.source_sha256 AND b.step_key=r.current_step_key AND b.run_control_version=r.control_version;
 enc:=EXISTS(SELECT 1 FROM mission_creation_owner.human_encounters he JOIN public.combat_v2_sessions cs ON cs.id=he.encounter_id WHERE he.master_session_id=p_session AND he.step_key=r.current_step_key AND he.run_control_version=r.control_version AND cs.state='in_corso');
 IF reason='READY' AND enc AND EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_session_optins_v1 o WHERE o.master_session_id=p_session AND o.actor_user=auth.uid()) THEN ctx:=mission_generic_owner.regia_human_direction_context_v1(p_session);END IF;
 RETURN jsonb_build_object('schema_version','quest-human-runtime-state/1','native_session_id',p_session,'quest_episode_id',q.episode_id,'source_sha256',q.source_sha256,'phase',q.state,'current_step_key',r.current_step_key,'run_control_version',r.control_version,'master_control_version',m.control_version,'current_event',CASE WHEN ev.id IS NULL THEN NULL ELSE jsonb_build_object('event_id',ev.id,'operation_kind',ev.operation_kind,'status',ev.status,'version_after',ev.version_after,'result',ev.result) END,'scene',scene,'decisions',options,'action_scope',ascope,'next_episode',nextdto,'window',CASE WHEN hw.id IS NULL THEN NULL ELSE jsonb_build_object('window_id',hw.id,'state',hw.state,'side',hw.side,'preparation_revision',hw.preparation_revision,'source_round_id',hw.source_round_id,'source_report_id',hw.source_report_id,'next_round_id',hw.next_round_id,'publication_id',hw.publication_id,'request_key',hw.publication_request_key) END,'regia_context',ctx,'d100_scope',scope,'d100_receipts',ds,'terminal',term,'reward_policy',mission_factory_owner.quest_reward_fixed30_document_v2(),'can',jsonb_build_object('bind_d100',coalesce((scope->>'can_bind')::boolean,false),'consume_d100',reason='READY' AND EXISTS(SELECT 1 FROM jsonb_array_elements(ds)x WHERE x->>'consumed'='false'),'prepare_direction',reason='READY' AND coalesce((ctx->>'can_direct')::boolean,false)),'reason_code',reason);
END $function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.c444_terminal_confirmed_v1(p_session uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare q mission_factory_owner.quest_run_sources%rowtype;
  tr mission_factory_owner.quest_terminal_receipts%rowtype;
  ep mission_factory_owner.quest_episodes%rowtype;
  a mission_factory_owner.quest_arcs%rowtype;
  m public.master_v2_sessions%rowtype;
  r public.mission_run_state%rowtype;
  ev public.mission_run_events%rowtype;
  ob public.mission_run_outbox%rowtype;
  cap mission_ai_service_owner.capabilities%rowtype;
  has_next boolean;
begin
PERFORM mission_factory_owner.c444_source_read_assert_v1(p_session);

  if p_session is null then return null; end if;
  select * into q from mission_factory_owner.quest_run_sources
    where session_id=p_session;
  if q.session_id is null or q.state<>'terminal' or q.terminal_receipt_id is null
  then return null; end if;
  select * into tr from mission_factory_owner.quest_terminal_receipts
    where id=q.terminal_receipt_id and session_id=p_session;
  select * into ep from mission_factory_owner.quest_episodes
    where id=q.episode_id;
  select * into a from mission_factory_owner.quest_arcs
    where id=q.arc_id;
  select * into m from public.master_v2_sessions
    where id=p_session;
  select * into r from public.mission_run_state
    where master_session_id=p_session;
  select * into ev from public.mission_run_events
    where id=tr.close_event_id and master_session_id=p_session;
  select * into ob from public.mission_run_outbox
    where event_id=tr.close_event_id and master_session_id=p_session;
  select exists(select 1 from mission_factory_owner.quest_episodes ne
    where ne.arc_id=q.arc_id and ne.ordinal=ep.ordinal+1) into has_next;
  if tr.id is null or ep.id is null or a.id is null or m.id is null
     or r.master_session_id is null or ev.id is null or ob.event_id is null
     or tr.episode_id is distinct from q.episode_id
     or tr.source_sha256 is distinct from q.source_sha256
     or tr.decision_receipt_id::text is distinct from
       ev.result->>'decision_receipt_id'
     or tr.outcome is distinct from ev.result->>'outcome'
     or tr.receipt->>'schema_version' is distinct from 'quest-episode-terminal/1'
     or tr.receipt->>'native_terminal_receipt_id' is distinct from tr.id::text
     or tr.receipt->>'request_key' is distinct from tr.request_key::text
     or tr.receipt->>'outcome' is distinct from tr.outcome
     or tr.continuity_public_sha256 is distinct from
       mission_factory_owner.sha(tr.continuity_public)
     or tr.continuity_private_sha256 is distinct from
       mission_factory_owner.sha(tr.continuity_private)
     or ev.operation_kind<>'close' or ev.status<>'committed'
     or ev.request_key_sha256 is distinct from
       mission_internal.request_key_sha256(tr.request_key)
     or ev.result->>'schema_version' is distinct from 'quest-native-close/1'
     or ev.plan_version_id is distinct from q.plan_version_id
     or ob.state<>'published' or ob.publication_id is distinct from tr.publication_id
     or not exists(select 1 from public.mission_run_publications p
       where p.id=tr.publication_id and p.event_id=ev.id
         and p.master_session_id=p_session and p.status='committed')
     or not exists(select 1 from public.mission_run_messages msg
       where msg.publication_id=tr.publication_id)
     or m.stato<>'chiusa' or m.closed_at is null
     or r.source_kind is distinct from 'quest'
     or r.quest_episode_id is distinct from q.episode_id
     or r.plan_version_id is distinct from q.plan_version_id
     or r.last_event_id is distinct from ev.id
     or r.control_version is distinct from ev.version_after+1
     or r.run_phase is distinct from
       (case when tr.outcome='success' then 'conclusa' else 'fallita' end)
     or ep.arc_id is distinct from q.arc_id
     or ep.source_sha256 is distinct from q.source_sha256
     or ep.terminal_receipt is distinct from tr.receipt
     or ep.state is distinct from
       (case when tr.outcome='success' then 'completed' else 'failed' end)
     or (not has_next and a.state is distinct from (case when tr.outcome='failure' then 'failed' else 'completed' end))
     or (has_next and a.state not in('in_progress','completed','failed'))
  then return null; end if;
  return tr.receipt;
end; $function$
;
CREATE OR REPLACE FUNCTION public.mission_factory_quest_d100_binding_scope_v1(p_session uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE q mission_factory_owner.quest_run_sources;r public.mission_run_state;m public.master_v2_sessions;
 e mission_factory_owner.quest_episodes;b mission_factory_owner.c353_d100_bindings;
 ph jsonb;refs jsonb;roster jsonb;phase_sha text;reason text;guide uuid;support uuid;all_active boolean;
BEGIN
IF mission_factory_owner.c395_human_mode_v1(p_session) THEN PERFORM mission_factory_owner.c407_identity_v1(p_session);END IF;
 IF auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated' OR p_session IS NULL THEN RAISE EXCEPTION 'C372_NORMAL_AUTH_REQUIRED' USING ERRCODE='42501';END IF;
 IF mission_factory_owner.c395_human_mode_v1(p_session) THEN PERFORM mission_factory_owner.c444_source_read_assert_v1(p_session);ELSE PERFORM mission_factory_owner.quest_run_source_assert_v1(p_session);END IF;
 IF mission_factory_owner.c395_human_mode_v1(p_session) THEN SELECT * INTO STRICT q FROM mission_factory_owner.quest_run_sources WHERE session_id=p_session; ELSE SELECT * INTO STRICT q FROM mission_factory_owner.quest_run_sources WHERE session_id=p_session FOR SHARE; END IF;
 -- Same authority as bind_v1: normal Staff operator may be outside the PG roster.
 PERFORM mission_factory_owner.quest_operator_assert_v3(q.episode_id);
 IF mission_factory_owner.c395_human_mode_v1(p_session) THEN SELECT * INTO STRICT r FROM public.mission_run_state WHERE master_session_id=p_session; ELSE SELECT * INTO STRICT r FROM public.mission_run_state WHERE master_session_id=p_session FOR SHARE; END IF;
 IF mission_factory_owner.c395_human_mode_v1(p_session) THEN SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_session; ELSE SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_session FOR SHARE; END IF;
 IF mission_factory_owner.c395_human_mode_v1(p_session) THEN SELECT * INTO STRICT e FROM mission_factory_owner.quest_episodes WHERE id=q.episode_id; ELSE SELECT * INTO STRICT e FROM mission_factory_owner.quest_episodes WHERE id=q.episode_id FOR SHARE; END IF;
 IF q.state<>'started' OR r.source_kind<>'quest' OR r.run_phase<>'in_corso' OR m.stato<>'in_corso'
  OR m.closed_at IS NOT NULL OR (m.owner_kind<>'ai_service' AND NOT(m.owner_kind='human' AND mission_factory_owner.c395_human_mode_v1(p_session))) OR m.mission_id IS NOT NULL
  OR q.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  OR mission_factory_owner.quest_is_simulation_v4(q.arc_id) IS DISTINCT FROM true
  OR r.control_version<=0 OR m.control_version<=0 OR cardinality(q.roster_character_ids) NOT BETWEEN 1 AND 4
 THEN RAISE EXCEPTION 'C372_CURRENT_PROTECTED_QUEST_REQUIRED' USING ERRCODE='42501';END IF;
 SELECT value INTO STRICT ph FROM jsonb_array_elements(e.source_document->'phases') WHERE value->>'step_key'=r.current_step_key;
 SELECT count(*)=cardinality(q.roster_character_ids),coalesce(jsonb_agg(jsonb_build_object('character_id',c.id,'display_name',c.name,'qualified',true) ORDER BY x.ord),'[]'::jsonb)
 INTO all_active,roster FROM unnest(q.roster_character_ids) WITH ORDINALITY x(id,ord)
 JOIN public.characters c ON c.id=x.id AND c.user_id IS NOT NULL
 JOIN public.master_v2_participants mp ON mp.session_id=p_session AND mp.character_id=c.id
  AND mp.left_at IS NULL AND mp.engagement_state='attivo';
 IF ph->>'capability_key' IS DISTINCT FROM 'd100.native' THEN reason:='NOT_D100';
 ELSE
  PERFORM mission_factory_owner.c360_native_phase_assert_v1(ph);
  refs:=ph->'d100_binding';phase_sha:=mission_factory_owner.sha(ph);
  SELECT * INTO b FROM mission_factory_owner.c353_d100_bindings WHERE session_id=p_session AND step_key=r.current_step_key AND run_control_version=r.control_version;
  IF b.id IS NOT NULL THEN
   IF b.quest_source_sha256<>q.source_sha256 OR b.phase_sha256<>phase_sha OR b.phase_snapshot IS DISTINCT FROM ph OR b.roster_character_ids IS DISTINCT FROM q.roster_character_ids
    OR b.native_policy_sha256 IS DISTINCT FROM refs->>'native_policy_sha256'
   THEN RAISE EXCEPTION 'C372_CURRENT_BINDING_DRIFT' USING ERRCODE='40001';END IF;
   guide:=b.guide_character_id;support:=b.support_character_id;
  END IF;
  IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c353_d100_control WHERE singleton AND enabled) OR (mission_factory_owner.c395_human_mode_v1(p_session) AND NOT EXISTS(SELECT 1 FROM mission_factory_owner.c407_control WHERE singleton AND d100_enabled)) THEN reason:='DISABLED';
  ELSIF all_active IS DISTINCT FROM true THEN reason:='ROSTER_INACTIVE';
  ELSIF EXISTS(SELECT 1 FROM public.mission_run_outbox WHERE master_session_id=p_session AND event_version_after=r.control_version AND step_key=r.current_step_key AND state IN('pending','human_directed')) THEN reason:='FATO_PENDING';
  ELSIF b.id IS NOT NULL THEN reason:='ALREADY_BOUND';
  END IF;
 END IF;
 RETURN jsonb_build_object('schema_version','quest-d100-binding-scope/1','master_session_id',p_session,
  'current_step_key',r.current_step_key,'run_control_version',r.control_version,'master_control_version',m.control_version,
  'source_sha256',q.source_sha256,'phase_sha256',phase_sha,'d100_binding',refs,'roster',roster,
  'support_required',cardinality(q.roster_character_ids)>1,
  'assignment',jsonb_build_object('guide_character_id',guide,'support_character_id',support),
  'can_bind',reason IS NULL,'reason_code',reason);
END $function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.quest_scene_v1(p_session uuid, p_step text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare q mission_factory_owner.quest_run_sources%rowtype;
  d mission_generic_owner.definitions%rowtype;
  scene jsonb; n integer;
begin
  IF mission_factory_owner.c395_human_mode_v1(p_session) THEN PERFORM mission_factory_owner.c444_source_read_assert_v1(p_session);ELSE PERFORM mission_factory_owner.quest_run_source_assert_v1(p_session);END IF;
  IF mission_factory_owner.c395_human_mode_v1(p_session) THEN select * into strict q from mission_factory_owner.quest_run_sources
    where session_id=p_session; ELSE select * into strict q from mission_factory_owner.quest_run_sources
    where session_id=p_session for share; END IF;
  IF mission_factory_owner.c395_human_mode_v1(p_session) THEN select * into strict d from mission_generic_owner.definitions
    where id=q.definition_id; ELSE select * into strict d from mission_generic_owner.definitions
    where id=q.definition_id for share; END IF;
  if p_step is null or jsonb_typeof(d.definition->'scenes')<>'array'
  then raise exception 'MF_QUEST_SCENE_SOURCE' using errcode='55000'; end if;
  select count(*) into n
    from jsonb_array_elements(d.definition->'scenes') x
    where x.value->>'step_key'=p_step;
  if n<>1 then raise exception 'MF_QUEST_SCENE_STEP' using errcode='55000'; end if;
  select x.value into strict scene
    from jsonb_array_elements(d.definition->'scenes') x
    where x.value->>'step_key'=p_step;
  return scene;
end $function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.c408_stage1_complete_assert_v1()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN

 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p JOIN pg_catalog.pg_language l ON l.oid=p.prolang WHERE p.oid=pg_catalog.to_regprocedure('mission_factory_owner.c416_kind_renewal_continuity_v1(uuid,uuid,uuid)') AND md5(p.prosrc)='daf00919217a021a27572479a19073a7' AND p.proowner='postgres'::regrole AND p.proacl::text='{postgres=X/postgres}' AND p.prosecdef AND p.provolatile='s' AND p.proconfig=ARRAY['search_path=""']::text[] AND p.prokind='f' AND p.proparallel='u' AND NOT p.proisstrict AND p.provariadic=0 AND p.proargmodes IS NULL AND p.proallargtypes IS NULL AND p.proargdefaults IS NULL AND p.prorettype='boolean'::regtype AND NOT p.proretset AND p.pronargdefaults=0 AND p.proargnames=ARRAY['p_draft','p_original_request','p_author']::text[] AND p.proargtypes::text='2950 2950 2950' AND l.lanname='sql') THEN RAISE EXCEPTION 'HUMAN16_CONTINUITY_CERTIFICATE_HELPER_ABI';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c422_install_progress WHERE singleton AND complete AND next_unit=20 AND source_input_sha256='8085b8a1127f9d2d86301eafac37e2f6c70fb48cde55f2a9f5bfdcc94eee7093') THEN RAISE EXCEPTION 'C422_COMPOSED_HUMAN_QUALIFICATION_REQUIRED' USING ERRCODE='42501';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c408_install_progress WHERE singleton AND source_input_sha256='17d5690518e455e22925aaf3f3d0f44bdd82ae86df6872fa7aea621a6a7e98b3' AND complete AND next_unit=16 AND target_ddl_qualification_sha256~'^[0-9a-f]{64}$') THEN RAISE EXCEPTION 'C408_ALL_UNITS_AND_ACTUAL_DDL_QUALIFICATION_REQUIRED' USING ERRCODE='42501';END IF;
 IF EXISTS(SELECT 1 FROM (SELECT jsonb_build_array(('["mission_academy_owner","mission_creation_owner","mission_factory_owner","mission_public_owner","public"]'::jsonb->>(p->>0)::int)||'.'||(p->>1)||'('||coalesce((SELECT string_agg('["mission_factory_owner.quest_run_sources","pg_catalog._text","pg_catalog._uuid","pg_catalog.bool","pg_catalog.int4","pg_catalog.int8","pg_catalog.jsonb","pg_catalog.text","pg_catalog.timestamptz","pg_catalog.uuid","public.mission_plan_transitions","public.mission_run_state"]'::jsonb->>v::int,',' ORDER BY o) FROM jsonb_array_elements_text(p->2)WITH ORDINALITY AS z(v,o)),'')||')',p->3)||('[[true,"v","postgres",["search_path=\"\""],["postgres"]],[true,"s","postgres",["search_path=\"\""],["postgres"]],[false,"v","postgres",["search_path=\"\""],["postgres"]],[true,"s","postgres",["search_path=\"\""],["authenticated","postgres"]],[false,"i","postgres",["search_path=\"\""],["postgres"]],[true,"v","postgres",["search_path=\"\""],["authenticated","postgres"]],[true,"v","postgres",["search_path=\"\""],["postgres","service_role"]]]'::jsonb->(p->>4)::int) AS e FROM jsonb_array_elements('[[2,"c347_receipt_immutable_v1",[],"0126db34638caad0c40be6769c1d9d4e",0],[2,"c347_native_facts_v1",[9,7,9,7],"a222ed36c37b64f89dbe2b69cc5c8430",0],[2,"c347_issue_native_receipt_v1",[9,7,9,7,9],"a57dbd085d2e61ce319e670ed5fb1f20",0],[2,"c347_validate_native_receipt_v1",[6,9,7,8],"5b2a22345f2be306c891ee74b836b4cf",0],[2,"c352_history_immutable_v1",[],"b0a870be4f5fe115f082be38a514e783",0],[2,"c352_native_resource_source_v1",[],"5902f4292ef7b167aa1ad664255fdcee",1],[2,"c352_prepare_resource_v1",[6],"e40a932dcdd73e39068268e94f8345d0",2],[2,"c352_resource_catalog_v1",[],"b77c874e033de63803c9958672d36fe1",1],[4,"mission_factory_catalog_v1",[],"0b3a4e84fd53535061dd2bb2365d7f0f",3],[4,"mission_factory_catalog_v2",[],"8cf99c6a615ad5eeac3eabddcbe6f4f7",1],[0,"c353_effective_threshold_v1",[4,4,4],"49ffebf8d9071f694d38c9146fa545e3",4],[2,"c353_d100_immutable_v1",[],"3c87bd34a14a37b09572b82b96346392",0],[4,"mission_factory_quest_d100_policy_catalog_v1",[9],"7776317a0494bc7399fdb1300707771b",5],[4,"mission_factory_quest_d100_bind_receipt_v1",[9],"6ccdcab28455c1ce108fe8658a2ee4f9",5],[4,"mission_factory_quest_d100_bind_v1",[9,9,7,7,9,9,7,7,5,9],"48793d9952ac0dcbb181213bc91357d0",5],[2,"c353_after_d100_v1",[9,9,9,4],"e5d1694567e73c4d52775b3377d0ba14",0],[2,"c353_d100_receipt_assert_v1",[9,9],"dd1f942ea6854165e06a160625c1c4e7",0],[0,"after_d100",[9,9,9,4],"ce9c2580b8752105427d3a3b0291286c",0],[2,"c360_phase_shape_v1",[6],"f2e2c8743c7ac168d7a78b806ee74f1f",4],[2,"c360_native_phase_assert_v1",[6],"e61d7db8292f98acdb2518077f3601f3",1],[4,"mission_factory_quest_d100_draft_policy_catalog_v1",[9,5],"da84606351828d80fdada5b64c2af7f8",3],[4,"mission_factory_quest_d100_wakeup_scope_v1",[9,9],"ffc02816fcc5e335ba7899fa72eb3fe5",6],[4,"mission_factory_quest_d100_pending_v1",[9],"57e7babb21507b6df6ca4d0d5c1aee35",6],[4,"mission_factory_quest_d100_consume_v1",[9,9,7],"d2ce506b547f1d7082194d57d1739dc7",6],[2,"validate_quest_draft_v2",[6],"0da0e5522287738b33f17b90d7a1c432",4],[2,"quest_deep_validate_v2",[9,6],"72b51aecd719c425d1d6c6dd3739f952",0],[2,"quest_compile_v1",[9],"e31e74e9fc87bf1582b63f4626267f30",0],[2,"quest_compile_check_v1",[9],"b1a3a6e9339da34d45cea23d21ee4832",1],[2,"quest_preview_basis_v1",[9,5,3],"21939a37af4b02c54d34719be2745e23",0],[2,"quest_decision_issue_v1",[9,9,5,7,7,9,7],"2fc5c1e420c123f032d2f2108e604ad9",0],[2,"quest_validate_evidence_v1",[11,10,6,8],"8475b5d8c73c3e1717961d6542e8cc99",0],[2,"c360_activate_staff_catalog_v1",[6],"94832819f80c8bb3f99dc0fcf45c721c",0],[4,"mission_factory_quest_d100_binding_scope_v1",[9],"b2fb7cf48d26f6ff35177b9265709394",5],[2,"c384_validate_variant_v2",[6,6,7],"0c74df4b6335a21c24b7ba1eed34a069",4],[2,"c384_validate_dual_draft_v3",[6],"aaf868bba0da5b5eaece8bebf85f286c",4],[2,"c384_immutable_v1",[],"32299e2f2f941b22708fb8efd5f86c67",0],[2,"c384_dual_save_v1",[9,5,6,9],"ef79df6cbdd4ed5f700aaae4345f2cc5",0],[2,"c384_human_identity_v1",[9],"d51d2239739d5d5dfe264a2877d52d37",1],[2,"c384_human_publication_replay_v1",[9,9,7,5,9],"28da0ea196460f7810a67fafe3a786be",1],[2,"c384_human_bind_seal_v1",[9,9,5,9,9,9],"f7859e1d6b17f93a6fe7a54a0fc0f0d9",0],[2,"c395_prepare_assert_v1",[9,5,9,9],"2be3242bf59b21fcce437f062b0a32af",0],[2,"c395_revision_issue_v1",[9,5,9,9,9],"a863ba94b3412d0c58c2e7c2efa8139b",0],[2,"c395_binding_projection_v1",[0],"0b66c70fde49fea2925ce146ccd2f23b",1],[2,"c395_binding_insert_assert_v1",[9,9,6,7],"baa7abfe2e70335660d32b26cd77e888",0],[2,"c395_revision_assert_v1",[9],"00ecc50309178677bec990dce0e93daa",1],[2,"c395_human_mode_v1",[9],"98c2dd9142429998bfc8d137aee19c40",1],[2,"c395_active_human_assert_v1",[9],"8b80feeff37e0402120fa68b2b086947",0],[2,"c395_start_assert_v1",[9],"d0f82355e6d1ef9897edc76a26c96d54",0],[4,"mission_factory_quest_human_prepare_v1",[9,9,9,2,9,5,9],"2a83b1c57d14cc4f37b1326c0b68cc8b",5],[4,"mission_factory_quest_human_start_v1",[9,5,9],"8b72b71be42b248c1ca85b3eccadcaf9",5],[2,"c395_source_assert_v1",[9],"56dc0aaf7b5cde324f58947752510d50",0],[2,"quest_run_binding_guard_v1",[],"5efa189afcb8e3639054b42efaa37d2f",0],[1,"is_human",[9],"f9f3cfd42b5f9a0059247a97e8167881",1],[1,"human_assert",[9],"1ce886cdc79e7119ec47b59f52185c32",0],[2,"quest_run_source_assert_v1",[9],"0fb2f5aca06a41479f22c1ecf07738ee",0],[1,"route_human_outbox",[],"e909272590bc59976f63ce6f3a44e914",0],[2,"c407_identity_v1",[9],"ef0a29b5053665ad13f2df4fb57cccd3",1],[2,"c407_active_v1",[9,7],"ee1cd8d251f1eebbc056baf69b019239",0],[2,"c407_enroll_v1",[9],"e6d59bd7d1515ecea0388626cde25a5a",0],[2,"c407_arena_v1",[9,7],"ce8a15514bc292939a455f687bea04c1",1],[4,"mission_factory_quest_human_fato_publish_v1",[9,9,7,9],"77ec29bb0d60fde6d9d5cc08d446d168",5],[4,"mission_factory_quest_human_d100_consume_v1",[9,9,7],"01bbdb51911e2a380847da0040a2c3eb",5],[1,"human_enroll",[9],"a73a003f10d4a1cff816635cf9990ccb",0],[1,"arena_for_step",[9,7],"1e6146a461ce898ec9d846b92d936f95",1],[1,"human_open",[9,9],"cf39dfb2460cbe8d9bdb228f110d5d20",0],[3,"human_fato_scope_allowed_v2",[9],"c9f378ec6523f9d035435fa2fb353e34",1],[2,"quest_apply_authority_v1",[9,9,5,5,7,7,9,7,9],"09d2cd933b2f09f39cd3da13bcb9ffba",0],[2,"c412_read_identity_v1",[9],"7bdd302698207fd7f01b8cbf49920aaf",1],[2,"c412_revision_provenance_v1",[9],"707f715cbe2b964406560dd9c0b83b94",1],[2,"c412_source_assert_v1",[9],"a9526ea4216b8ba83d9097ebc0c92fef",0],[4,"mission_factory_quest_dual_save_v3",[9,5,6,9],"9a8b197d1d78ad0a928ca2b4de99b7f8",5],[4,"mission_factory_quest_dual_get_v3",[9,5],"8e7e961d7882cec1d327081df78cd17c",3],[2,"c412_fact_issue_v1",[9,9,5,7,7,9,7],"b9c290f201b1fc59938a024030242d6a",0],[2,"c412_fact_assert_v1",[9,9,5,7,7,7],"bc2377f4dd9a6c9d838b0a62889546e1",1],[4,"mission_factory_quest_human_terminal_prepare_v1",[9,9,5,9],"92df20717f2485b94a04220603ac32af",5],[4,"mission_factory_quest_human_terminal_publish_v1",[9,9,7,9],"770a3a4d053e3e9ef1d60b11563d44f6",5],[4,"mission_factory_quest_human_phase_action_v1",[9,5,7,7,9],"c275d93276703b033fdf874c31bbbea1",5],[4,"mission_factory_quest_human_round_publish_v1",[9,9,7,5,9],"054ae3e2c80bb9bca9c209048021bd19",5],[2,"c412_manual_fato_write_v1",[9,9,7,9],"a00e737d3e0363a7244c199b4707dc67",0],[2,"c416_kind_live_v1",[],"96766167969aff87b3b11452fd15c598",1],[2,"c416_cap_allowed_v1",[6,7],"86e797ff93036bafaab6867253618b45",1],[2,"c416_root_kind_register_v1",[7,7,1,2,9,6],"e664dbaa69f3f6ced90c6eb81952f8bc",0],[2,"c416_draft_assert_v1",[9,3],"4c8fb91e06a036f3998342bfbc98b3b8",1],[2,"c416_arc_assert_v1",[9,3],"2a18f541eafd92baa107cda0f15d2550",1],[4,"mission_factory_quest_dual_create_v3",[9,5,6,2,9],"1262390e33c3c3e885216b26bb1e609d",5],[2,"c416_validate_human_draft_v3",[6],"b36495eebd3071f3c62bb715e19b068a",4],[2,"c416_preview_basis_v3",[9,5,3],"5b5982b93629c7ca47e2d9679693cda9",0],[4,"mission_factory_quest_human_preview_v3",[9,5],"89efad0cce80f20c2b3f29ed9e5df565",5],[4,"mission_factory_quest_human_publish_v3",[9,5,7,9,7,8],"55ada638bbf2e5dd6c92ca882141afb5",5],[2,"npc_item_v2",[9,9,7,3],"dc260f7771e6ffd8d6d99ce67eb96de7",0],[2,"npc_custom_authoring_check_v1",[9,5,7,3],"7d14a659984865eaac36f0dbf271bc60",0],[2,"quest_publication_scope_v3",[9,3],"775033ca8434cbd732ca9fce7668b9d1",0],[2,"quest_roster_scope_assert_v3",[9,9,2],"cb8a7829e234612c84a9d21673c71e9c",0],[4,"mission_factory_context_media_ticket_v2",[9,7,7,9,7,5,7],"d6a233ac4e184c550625ee11a2dbf173",5],[4,"mission_factory_context_media_register_v2",[9,7,5,7,4,4],"a483d59ca8f9cbc742da777db08c6dee",6],[4,"mission_factory_context_media_catalog_v2",[9,7],"a5c4f7faaeeeb65e40dd344df600add9",3],[4,"mission_factory_quest_dual_import_v3",[9,5,6,2,9,5,9],"811bd99d9fce22b8b9714485ea4dae98",5]]'::jsonb) AS z(p)) AS seal LEFT JOIN pg_proc f ON f.oid=to_regprocedure(e->>0) WHERE f.oid IS NULL OR md5(f.prosrc) IS DISTINCT FROM e->>1 OR f.prosecdef IS DISTINCT FROM (e->>2)::boolean OR f.provolatile::text IS DISTINCT FROM e->>3 OR pg_get_userbyid(f.proowner) IS DISTINCT FROM e->>4 OR to_jsonb(f.proconfig) IS DISTINCT FROM e->5 OR coalesce((SELECT jsonb_agg(CASE WHEN a.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(a.grantee) END ORDER BY CASE WHEN a.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(a.grantee) END) FROM aclexplode(coalesce(f.proacl,acldefault('f',f.proowner))) a WHERE a.privilege_type='EXECUTE'),'[]'::jsonb) IS DISTINCT FROM e->6 OR EXISTS(SELECT 1 FROM aclexplode(coalesce(f.proacl,acldefault('f',f.proowner))) a WHERE a.is_grantable)) THEN RAISE EXCEPTION 'C408_COMPLETE_FUNCTION_CAS' USING ERRCODE='40001';END IF;
END $function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.c444_runtime_ports_complete_assert_v1()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$BEGIN
IF EXISTS(SELECT 1 FROM jsonb_array_elements($c501_pins$[{"all_arg_types":[],"arg_modes":[],"arg_names":null,"body_md5":"e7cfa21ff763fbda18632b6fb247790d","configuration":["search_path=\"\""],"default_arg_count":0,"execute":["postgres"],"input_arg_types":[],"language":"plpgsql","lookup_signature":"mission_factory_owner.c408_stage1_complete_assert_v1()","oid":"279179","owner":"postgres","parallel":"u","return_type":"pg_catalog.void","returns_set":false,"security_definer":true,"strict":false,"variadic_type":null,"volatility":"s"}]$c501_pins$::jsonb) c501_expected LEFT JOIN pg_catalog.pg_proc c501_proc ON c501_proc.oid=pg_catalog.to_regprocedure(c501_expected->>'lookup_signature') WHERE c501_proc.oid IS NULL OR (c501_expected->>'oid' IS NOT NULL AND c501_proc.oid::text IS DISTINCT FROM c501_expected->>'oid') OR md5(c501_proc.prosrc) IS DISTINCT FROM c501_expected->>'body_md5' OR c501_proc.proargtypes::text IS DISTINCT FROM coalesce((SELECT string_agg(pg_catalog.to_regtype(c501_argtype)::oid::text,' ' ORDER BY c501_ord)FROM jsonb_array_elements_text(c501_expected->'input_arg_types')WITH ORDINALITY c501_inputs(c501_argtype,c501_ord)),'') OR coalesce((SELECT jsonb_agg(pg_catalog.format('%I.%I',c501_ns.nspname,c501_type.typname) ORDER BY c501_ord)FROM unnest(coalesce(c501_proc.proallargtypes,c501_proc.proargtypes::oid[]))WITH ORDINALITY c501_all(c501_type_oid,c501_ord)JOIN pg_catalog.pg_type c501_type ON c501_type.oid=c501_type_oid JOIN pg_catalog.pg_namespace c501_ns ON c501_ns.oid=c501_type.typnamespace),'[]'::jsonb) IS DISTINCT FROM c501_expected->'all_arg_types' OR to_jsonb(coalesce(c501_proc.proargmodes,array_fill('i'::"char",ARRAY[c501_proc.pronargs]))) IS DISTINCT FROM c501_expected->'arg_modes' OR coalesce(to_jsonb(c501_proc.proargnames),'null'::jsonb) IS DISTINCT FROM c501_expected->'arg_names' OR c501_proc.prorettype IS DISTINCT FROM pg_catalog.to_regtype(c501_expected->>'return_type') OR c501_proc.proretset IS DISTINCT FROM(c501_expected->>'returns_set')::boolean OR c501_proc.pronargdefaults IS DISTINCT FROM(c501_expected->>'default_arg_count')::integer OR (c501_proc.pronargdefaults=0 AND c501_proc.proargdefaults IS NOT NULL) OR c501_proc.provariadic IS DISTINCT FROM coalesce(pg_catalog.to_regtype(c501_expected->>'variadic_type')::oid,0::oid) OR c501_proc.proisstrict IS DISTINCT FROM(c501_expected->>'strict')::boolean OR c501_proc.provolatile::text IS DISTINCT FROM c501_expected->>'volatility' OR c501_proc.proparallel::text IS DISTINCT FROM c501_expected->>'parallel' OR c501_proc.prosecdef IS DISTINCT FROM(c501_expected->>'security_definer')::boolean OR(SELECT lanname FROM pg_catalog.pg_language WHERE oid=c501_proc.prolang)IS DISTINCT FROM c501_expected->>'language' OR to_jsonb(c501_proc.proconfig) IS DISTINCT FROM c501_expected->'configuration' OR pg_catalog.pg_get_userbyid(c501_proc.proowner)IS DISTINCT FROM c501_expected->>'owner' OR c501_proc.proleakproof OR coalesce((SELECT jsonb_agg(CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END ORDER BY CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END)FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.privilege_type='EXECUTE'),'[]'::jsonb)IS DISTINCT FROM c501_expected->'execute' OR EXISTS(SELECT 1 FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.is_grantable))THEN RAISE EXCEPTION 'C501_CURRENT_HUMAN_QUALIFIER_ABI_CAS' USING ERRCODE='40001';END IF;
PERFORM mission_factory_owner.c408_stage1_complete_assert_v1();
IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c444_install_progress WHERE singleton AND complete AND next_unit=26 AND source_input_sha256='9c814c08fba12afbdec246b477a73c0047d318b51dc7c83a23050bd9da9e0aa9')THEN RAISE EXCEPTION 'C501_SOURCE_FAMILY_COMPLETE_PREFIX_REQUIRED';END IF;
IF EXISTS(SELECT 1 FROM jsonb_array_elements((SELECT jsonb_agg('{"configuration":["search_path=\"\""],"default_arg_count":0,"owner":"postgres","parallel":"u","returns_set":false,"security_definer":true,"strict":false,"variadic_type":null}'::jsonb||p)FROM jsonb_array_elements('[{"all_arg_types":[],"arg_modes":[],"arg_names":null,"body_md5":"75fcad93b0da5fee0fc6b7af652a5e85","execute":["postgres"],"input_arg_types":[],"language":"sql","lookup_signature":"mission_factory_owner.c444_enabled_v1()","oid":null,"return_type":"pg_catalog.bool","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"0a7fa43e594605d397504828f1961f55","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_read_identity_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"c0eba4dc35f44c49e544137d799cc97b","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_source_read_assert_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"3ea3a2a0749910a979216b801a09bb2e","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_episode_read_assert_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.void","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"5d1943abf0a90cd395165756207e934e","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_enrollment_open_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.bool","volatility":"v"},{"all_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"arg_modes":["i","i","i","i","i"],"arg_names":["p_episode","p_operation","p_ready","p_expected_version","p_request"],"body_md5":"1bad66b63bff109cf4e65d14be59722f","execute":["postgres"],"input_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_enrollment_v1(pg_catalog.uuid,pg_catalog.text,pg_catalog.bool,pg_catalog.int8,pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"arg_modes":["i","i","i","i","i"],"arg_names":["p_episode","p_operation","p_ready","p_expected_version","p_request"],"body_md5":"555a2c26cd901ba41d34c5365aa89755","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_enrollment_v1(pg_catalog.uuid,pg_catalog.text,pg_catalog.bool,pg_catalog.int8,pg_catalog.uuid)","oid":"276409","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"95504e51b86b13df5b02a175043cc4b7","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_terminal_confirmed_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"1c6a6240f27b3add37546175768633a2","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.quest_terminal_confirmed_v1(pg_catalog.uuid)","oid":"276431","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"5fa62eda7260904e189b55b06088254b","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_participant_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"2169f3ddfbae60cf757cd2c555a9e2f7","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_participant_state_v1(pg_catalog.uuid)","oid":"276446","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_request"],"body_md5":"d06ad7832dd3bc64fc0d0472d9965534","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_run_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_request"],"body_md5":"17a33bc8b9d5bdd4468aa582002cb7fa","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_run_state_v1(pg_catalog.uuid)","oid":"276432","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"8d2d40aa16abbf40ea7801ae4ec49774","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_action_scope_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"150bbe0d9d07c4e5b63d062d47cbaf13","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_human_runtime_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"0bda32f1607eb10808df90b042f5473a","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_human_phase_state_v1(pg_catalog.uuid)","oid":"50702","return_type":"pg_catalog.jsonb","volatility":"s"}]'::jsonb)z(p))) c501_expected LEFT JOIN pg_catalog.pg_proc c501_proc ON c501_proc.oid=pg_catalog.to_regprocedure(c501_expected->>'lookup_signature') WHERE c501_proc.oid IS NULL OR (c501_expected->>'oid' IS NOT NULL AND c501_proc.oid::text IS DISTINCT FROM c501_expected->>'oid') OR md5(c501_proc.prosrc) IS DISTINCT FROM c501_expected->>'body_md5' OR c501_proc.proargtypes::text IS DISTINCT FROM coalesce((SELECT string_agg(pg_catalog.to_regtype(c501_argtype)::oid::text,' ' ORDER BY c501_ord)FROM jsonb_array_elements_text(c501_expected->'input_arg_types')WITH ORDINALITY c501_inputs(c501_argtype,c501_ord)),'') OR coalesce((SELECT jsonb_agg(pg_catalog.format('%I.%I',c501_ns.nspname,c501_type.typname) ORDER BY c501_ord)FROM unnest(coalesce(c501_proc.proallargtypes,c501_proc.proargtypes::oid[]))WITH ORDINALITY c501_all(c501_type_oid,c501_ord)JOIN pg_catalog.pg_type c501_type ON c501_type.oid=c501_type_oid JOIN pg_catalog.pg_namespace c501_ns ON c501_ns.oid=c501_type.typnamespace),'[]'::jsonb) IS DISTINCT FROM c501_expected->'all_arg_types' OR to_jsonb(coalesce(c501_proc.proargmodes,array_fill('i'::"char",ARRAY[c501_proc.pronargs]))) IS DISTINCT FROM c501_expected->'arg_modes' OR coalesce(to_jsonb(c501_proc.proargnames),'null'::jsonb) IS DISTINCT FROM c501_expected->'arg_names' OR c501_proc.prorettype IS DISTINCT FROM pg_catalog.to_regtype(c501_expected->>'return_type') OR c501_proc.proretset IS DISTINCT FROM(c501_expected->>'returns_set')::boolean OR c501_proc.pronargdefaults IS DISTINCT FROM(c501_expected->>'default_arg_count')::integer OR (c501_proc.pronargdefaults=0 AND c501_proc.proargdefaults IS NOT NULL) OR c501_proc.provariadic IS DISTINCT FROM coalesce(pg_catalog.to_regtype(c501_expected->>'variadic_type')::oid,0::oid) OR c501_proc.proisstrict IS DISTINCT FROM(c501_expected->>'strict')::boolean OR c501_proc.provolatile::text IS DISTINCT FROM c501_expected->>'volatility' OR c501_proc.proparallel::text IS DISTINCT FROM c501_expected->>'parallel' OR c501_proc.prosecdef IS DISTINCT FROM(c501_expected->>'security_definer')::boolean OR(SELECT lanname FROM pg_catalog.pg_language WHERE oid=c501_proc.prolang)IS DISTINCT FROM c501_expected->>'language' OR to_jsonb(c501_proc.proconfig) IS DISTINCT FROM c501_expected->'configuration' OR pg_catalog.pg_get_userbyid(c501_proc.proowner)IS DISTINCT FROM c501_expected->>'owner' OR c501_proc.proleakproof OR coalesce((SELECT jsonb_agg(CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END ORDER BY CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END)FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.privilege_type='EXECUTE'),'[]'::jsonb)IS DISTINCT FROM c501_expected->'execute' OR EXISTS(SELECT 1 FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.is_grantable))THEN RAISE EXCEPTION 'C501_PORTS_EFFECTIVE_FULL_ABI_ACL_CAS' USING ERRCODE='40001';END IF;
END$function$
;
DO $post$ BEGIN PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();PERFORM mission_factory_owner.c463_optin_complete_assert_v1();END $post$;COMMIT;
