begin;

do $recovery$
declare
 current_definition text;
 current_md5 text;
 result_md5 text;
 old_fragment constant text:=$old$'event_kind',mission_rapid_owner.rule_transition(rule),'priority',-10$old$;
 new_fragment constant text:=$new$'event_kind',mission_rapid_owner.rule_transition(rule),'priority',0$new$;
begin
 select pg_get_functiondef(p.oid),md5(p.prosrc) into strict current_definition,current_md5 from pg_proc p
 where p.oid='mission_rapid_owner.technical_document(mission_rapid_owner.drafts,jsonb)'::regprocedure;
 if current_md5='30a9523e58702a14aca5f7d8d4a05eae' then return;end if;
 if current_md5<>'66b271669c92a89db12f497fcb4ac098'
  or (length(current_definition)-length(replace(current_definition,new_fragment,'')))/length(new_fragment)<>1
 then raise exception 'MR_TRANSITION_PRIORITY_RECOVERY_DRIFT' using errcode='40001';end if;
 if md5((select prosrc from pg_proc where oid='mission_rapid_owner.preview_for(mission_rapid_owner.drafts)'::regprocedure))<>'c988923b347cc600b85bb215ea025663'
  or md5((select prosrc from pg_proc where oid='public.mission_creation_preflight_v2(jsonb)'::regprocedure))<>'2bfa56c88e45c52eb4495ee1f7c5d870'
  or md5((select prosrc from pg_proc where oid='public.mission_create_complete_v1(uuid,jsonb)'::regprocedure))<>'8a512021ec0335f6eddb8b859607b056'
 then raise exception 'MR_TRANSITION_PRIORITY_DEPENDENCY_DRIFT' using errcode='40001';end if;
 execute replace(current_definition,new_fragment,old_fragment);
 select md5(p.prosrc) into strict result_md5 from pg_proc p
 where p.oid='mission_rapid_owner.technical_document(mission_rapid_owner.drafts,jsonb)'::regprocedure;
 if result_md5<>'30a9523e58702a14aca5f7d8d4a05eae'
 then raise exception 'MR_TRANSITION_PRIORITY_RECOVERY_MISMATCH' using errcode='40001';end if;
end
$recovery$;

commit;
