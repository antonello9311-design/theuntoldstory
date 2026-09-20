begin;

do $apply$
declare
 current_definition text;
 current_md5 text;
 result_md5 text;
 old_fragment constant text:=$old$arenas:=arenas||jsonb_build_array(jsonb_build_object('step_key',step_key,'zone_key','arena',
    'template_key',case when c#>>'{map,mode}'='default10' then 'mission_map_bind_3ac00867783c8910b81a43b61015ce0b' else c#>>'{map,template_key}' end,
    'template_version',case when c#>>'{map,mode}'='default10' then 1 else (c#>>'{map,template_version}')::integer end));$old$;
 new_fragment constant text:=$new$if c#>>'{map,mode}'='specific' then
    arenas:=arenas||jsonb_build_array(jsonb_build_object('step_key',step_key,'zone_key','arena',
     'template_key',c#>>'{map,template_key}','template_version',(c#>>'{map,template_version}')::integer));
   end if;$new$;
begin
 select pg_get_functiondef(p.oid),md5(p.prosrc) into strict current_definition,current_md5 from pg_proc p
 where p.oid='mission_rapid_owner.technical_document(mission_rapid_owner.drafts,jsonb)'::regprocedure;
 if current_md5='30a9523e58702a14aca5f7d8d4a05eae' then return;end if;
 if current_md5<>'11c649ab270b192571d268b05404849e'
  or (length(current_definition)-length(replace(current_definition,old_fragment,'')))/length(old_fragment)<>1
 then raise exception 'MR_DEFAULT_MAP_SCOPE_BASELINE_DRIFT' using errcode='40001';end if;
 if md5((select prosrc from pg_proc where oid='mission_rapid_owner.preview_for(mission_rapid_owner.drafts)'::regprocedure))<>'c988923b347cc600b85bb215ea025663'
  or md5((select prosrc from pg_proc where oid='public.mission_creation_preflight_v2(jsonb)'::regprocedure))<>'2bfa56c88e45c52eb4495ee1f7c5d870'
  or md5((select prosrc from pg_proc where oid='public.mission_create_complete_v1(uuid,jsonb)'::regprocedure))<>'8a512021ec0335f6eddb8b859607b056'
 then raise exception 'MR_DEFAULT_MAP_SCOPE_DEPENDENCY_DRIFT' using errcode='40001';end if;
 execute replace(current_definition,old_fragment,new_fragment);
 select md5(p.prosrc) into strict result_md5 from pg_proc p
 where p.oid='mission_rapid_owner.technical_document(mission_rapid_owner.drafts,jsonb)'::regprocedure;
 if result_md5<>'30a9523e58702a14aca5f7d8d4a05eae'
 then raise exception 'MR_DEFAULT_MAP_SCOPE_INSTALL_MISMATCH' using errcode='40001';end if;
end
$apply$;

commit;
