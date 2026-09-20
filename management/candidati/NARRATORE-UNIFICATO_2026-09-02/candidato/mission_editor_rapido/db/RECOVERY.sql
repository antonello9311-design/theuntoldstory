-- MISSION-RAPID-DB/2026-09-19.mvp1 · conservative recovery.
-- Preserves drafts, publications, terminal rules/events, audit and recovery receipts.
begin;

do $preflight$
begin
 if to_regnamespace('mission_rapid_owner') is null then raise exception 'MR_RECOVERY_NOT_INSTALLED' using errcode='55000';end if;
 if to_regprocedure('public.mission_rapid_publish_v1(uuid,bigint,text,uuid)') is null
 or to_regprocedure('public.mission_rapid_preview_v1(uuid,bigint)') is null
 then raise exception 'MR_RECOVERY_VERSION_DRIFT' using errcode='40001';end if;
end $preflight$;

do $restore_progress$
declare baseline text;current_definition text;expected_definition text;
 old_fragment text;new_fragment text;
begin
 select definition into strict baseline
 from mission_rapid_owner.shared_function_baselines
 where signature='mission_generic_owner.progress_step(uuid,uuid,uuid)'
  and definition_md5=md5(definition);
 current_definition:=pg_get_functiondef('mission_generic_owner.progress_step(uuid,uuid,uuid)'::regprocedure);
 old_fragment:=E' if exists(select 1 from public.mission_run_outbox uo where uo.master_session_id=p_session and uo.state=''pending'' and not exists(select 1 from mission_generic_owner.unified_batches ub where ub.master_session_id=p_session and ub.state=''preparing'' and ub.route->>''event_id''=uo.event_id::text))\n then return mission_generic_owner.progress_result(p_session,p_user,''narration_pending'');end if;\n settings:=mission_generic_owner.run_plan_settings(p_session);';
 new_fragment:=E' if exists(select 1 from public.mission_run_outbox uo where uo.master_session_id=p_session and uo.state=''pending'' and not exists(select 1 from mission_generic_owner.unified_batches ub where ub.master_session_id=p_session and ub.state=''preparing'' and ub.route->>''event_id''=uo.event_id::text))\n then return mission_generic_owner.progress_result(p_session,p_user,''narration_pending'');end if;\n res:=mission_rapid_owner.try_native_terminal(p_session);\n if res is not null then return mission_generic_owner.progress_result(p_session,p_user,''transitioned'');end if;\n settings:=mission_generic_owner.run_plan_settings(p_session);';
 if (length(baseline)-length(replace(baseline,old_fragment,'')))/length(old_fragment)<>1
 then raise exception 'MR_RECOVERY_BASELINE_INVALID' using errcode='40001';end if;
 expected_definition:=replace(baseline,old_fragment,new_fragment);
 if current_definition is distinct from expected_definition
 then raise exception 'MR_RECOVERY_PROGRESS_DRIFT' using errcode='40001';end if;
 execute baseline;
end $restore_progress$;

update mission_rapid_owner.authoring_policy
set enabled=false,control_version=control_version+1
where singleton;

revoke all on function
 public.mission_rapid_compile_request_v1(uuid,jsonb),
 public.mission_rapid_compile_state_v1(uuid),
 public.mission_rapid_catalog_v1(),
 public.mission_rapid_draft_save_v1(uuid,bigint,jsonb),
 public.mission_rapid_preview_v1(uuid,bigint),
 public.mission_rapid_publish_v1(uuid,bigint,text,uuid),
 public.mission_rapid_compile_claim_v1(uuid,uuid),
 public.mission_rapid_compile_complete_v1(uuid,uuid,jsonb,jsonb),
 public.mission_rapid_compile_reject_v1(uuid,uuid,text,integer),
 public.mission_rapid_terminal_evaluate_v1(uuid,jsonb,uuid),
 public.mission_rapid_media_ticket_v1(uuid,text,uuid,uuid,text,bigint,text),
 public.mission_rapid_media_register_v1(uuid,text,bigint,text,integer,integer)
from public,anon,authenticated,service_role;

grant execute on function
 public.mission_rapid_compile_request_v1(uuid,jsonb),
 public.mission_rapid_compile_state_v1(uuid),
 public.mission_rapid_catalog_v1(),
 public.mission_rapid_draft_save_v1(uuid,bigint,jsonb),
 public.mission_rapid_preview_v1(uuid,bigint),
 public.mission_rapid_publish_v1(uuid,bigint,text,uuid),
 public.mission_rapid_compile_claim_v1(uuid,uuid),
 public.mission_rapid_compile_complete_v1(uuid,uuid,jsonb,jsonb),
 public.mission_rapid_compile_reject_v1(uuid,uuid,text,integer),
 public.mission_rapid_terminal_evaluate_v1(uuid,jsonb,uuid),
 public.mission_rapid_media_ticket_v1(uuid,text,uuid,uuid,text,bigint,text),
 public.mission_rapid_media_register_v1(uuid,text,bigint,text,integer,integer)
to postgres;

do $postflight$
begin
 if (select enabled from mission_rapid_owner.authoring_policy where singleton) then raise exception 'MR_RECOVERY_POLICY_STILL_ENABLED';end if;
 if has_function_privilege('authenticated','public.mission_rapid_publish_v1(uuid,bigint,text,uuid)','execute')
 or has_function_privilege('service_role','public.mission_rapid_compile_claim_v1(uuid,uuid)','execute')
 or has_function_privilege('authenticated','public.mission_rapid_media_ticket_v1(uuid,text,uuid,uuid,text,bigint,text)','execute')
 or has_function_privilege('service_role','public.mission_rapid_media_register_v1(uuid,text,bigint,text,integer,integer)','execute')
 then raise exception 'MR_RECOVERY_GRANT_DRIFT';end if;
 if md5(pg_get_functiondef('mission_generic_owner.progress_step(uuid,uuid,uuid)'::regprocedure))<>
  (select definition_md5 from mission_rapid_owner.shared_function_baselines where signature='mission_generic_owner.progress_step(uuid,uuid,uuid)')
 then raise exception 'MR_RECOVERY_PROGRESS_NOT_RESTORED';end if;
end $postflight$;

commit;
