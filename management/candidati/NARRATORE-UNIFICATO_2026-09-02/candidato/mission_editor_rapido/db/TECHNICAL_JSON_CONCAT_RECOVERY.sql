begin;

do $recovery$
declare
 current_definition text;
 current_md5 text;
 result_md5 text;
 old_trigger constant text:=$old$'term_'||rule->>'rule_key'$old$;
 new_trigger constant text:=$new$'term_'||(rule->>'rule_key')$new$;
 old_label constant text:=$old$'Condizione missione: '||rule->>'rule_key'$old$;
 new_label constant text:=$new$'Condizione missione: '||(rule->>'rule_key')$new$;
begin
 select pg_get_functiondef(p.oid),md5(p.prosrc) into strict current_definition,current_md5 from pg_proc p
 where p.oid='mission_rapid_owner.technical_document(mission_rapid_owner.drafts,jsonb)'::regprocedure;
 if current_md5='6ff11ad4312d7acf2f89f7f3498e47fc' then return;end if;
 if current_md5<>'11c649ab270b192571d268b05404849e'
  or (length(current_definition)-length(replace(current_definition,new_trigger,'')))/length(new_trigger)<>1
  or (length(current_definition)-length(replace(current_definition,new_label,'')))/length(new_label)<>1
 then raise exception 'MR_TECHNICAL_JSON_CONCAT_RECOVERY_DRIFT' using errcode='40001';end if;
 if md5((select prosrc from pg_proc where oid='mission_rapid_owner.preview_for(mission_rapid_owner.drafts)'::regprocedure))<>'c988923b347cc600b85bb215ea025663'
  or md5((select prosrc from pg_proc where oid='public.mission_creation_preflight_v2(jsonb)'::regprocedure))<>'2bfa56c88e45c52eb4495ee1f7c5d870'
  or md5((select prosrc from pg_proc where oid='public.mission_create_complete_v1(uuid,jsonb)'::regprocedure))<>'8a512021ec0335f6eddb8b859607b056'
 then raise exception 'MR_TECHNICAL_JSON_CONCAT_DEPENDENCY_DRIFT' using errcode='40001';end if;
 execute replace(replace(current_definition,new_trigger,old_trigger),new_label,old_label);
 select md5(p.prosrc) into strict result_md5 from pg_proc p
 where p.oid='mission_rapid_owner.technical_document(mission_rapid_owner.drafts,jsonb)'::regprocedure;
 if result_md5<>'6ff11ad4312d7acf2f89f7f3498e47fc'
 then raise exception 'MR_TECHNICAL_JSON_CONCAT_RECOVERY_MISMATCH' using errcode='40001';end if;
end
$recovery$;

commit;
