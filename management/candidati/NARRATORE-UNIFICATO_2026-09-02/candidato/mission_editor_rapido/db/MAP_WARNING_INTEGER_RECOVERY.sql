begin;

do $recovery$
declare
 current_definition text;
 current_md5 text;
 result_md5 text;
 shared_md5 text;
 old_fragment constant text:=$old$else
   mappreview:=public.mission_map_preview_v1(mapspec,(p_draft.compiled#>>'{mission,team_max}')::int,jsonb_array_length(p_draft.compiled->'actors'));$old$;
 new_fragment constant text:=$new$else
   mapspec:=jsonb_set(mapspec,'{suggested_entries}',(select coalesce(jsonb_agg(value||jsonb_build_object('x_m',((value->>'x_m')::numeric)::integer,'y_m',((value->>'y_m')::numeric)::integer) order by ordinality),'[]'::jsonb) from jsonb_array_elements(mapspec->'suggested_entries') with ordinality),false);
   mappreview:=public.mission_map_preview_v1(mapspec,(p_draft.compiled#>>'{mission,team_max}')::int,jsonb_array_length(p_draft.compiled->'actors'));$new$;
begin
 select pg_get_functiondef(p.oid),md5(p.prosrc) into strict current_definition,current_md5
 from pg_proc p where p.oid='mission_rapid_owner.preview_for(mission_rapid_owner.drafts)'::regprocedure;
 if current_md5='f53d1a36873ee8a82c8c8d149e96fe79' then return;end if;
 if current_md5<>'c988923b347cc600b85bb215ea025663'
  or (length(current_definition)-length(replace(current_definition,new_fragment,'')))/length(new_fragment)<>1
 then raise exception 'MR_MAP_WARNING_INTEGER_RECOVERY_DRIFT' using errcode='40001';end if;
 select md5(p.prosrc) into strict shared_md5 from pg_proc p
 where p.oid='mission_creation_owner.general_spec_warnings(jsonb)'::regprocedure;
 if shared_md5<>'f5f2d08f0cccc141632c982890073d8d'
 then raise exception 'MR_MAP_WARNING_SHARED_DRIFT' using errcode='40001';end if;
 execute replace(current_definition,new_fragment,old_fragment);
 select md5(p.prosrc) into strict result_md5 from pg_proc p
 where p.oid='mission_rapid_owner.preview_for(mission_rapid_owner.drafts)'::regprocedure;
 if result_md5<>'f53d1a36873ee8a82c8c8d149e96fe79'
 then raise exception 'MR_MAP_WARNING_INTEGER_RECOVERY_MISMATCH' using errcode='40001';end if;
end
$recovery$;

commit;
