BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='15s';
DO $pre$ BEGIN
PERFORM pg_advisory_xact_lock(hashtextextended('C1242-human-general-placement',611));
IF (SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_creation_owner.bind_human_arena(uuid,uuid,uuid)')) IS DISTINCT FROM $pin${"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"eaf1cb72f887c5739561c90c82005cbd","signature":"mission_creation_owner.bind_human_arena(uuid,uuid,uuid)","source_md5":"e6104abcb437d4685076962cd417710e"}$pin$::jsonb THEN RAISE EXCEPTION 'C1242_FUNCTION_DRIFT:%', 'mission_creation_owner.bind_human_arena(uuid,uuid,uuid)'; END IF;
IF (SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_creation_owner.general_choose_points(jsonb)')) IS DISTINCT FROM $pin${"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"b5a2d35d26c4231d84ee2592982239f1","signature":"mission_creation_owner.general_choose_points(jsonb)","source_md5":"738b9fb1fc7026e2950b27927b89ce4b"}$pin$::jsonb THEN RAISE EXCEPTION 'C1242_FUNCTION_DRIFT:%', 'mission_creation_owner.general_choose_points(jsonb)'; END IF;
IF (SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_creation_owner.general_plan_positions(text,integer,integer,integer)')) IS DISTINCT FROM $pin${"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"bf5bdc1bf00ffd8e75131f9c0a955825","signature":"mission_creation_owner.general_plan_positions(text,integer,integer,integer)","source_md5":"2626e239e2d10755c6f27c2731476236"}$pin$::jsonb THEN RAISE EXCEPTION 'C1242_FUNCTION_DRIFT:%', 'mission_creation_owner.general_plan_positions(text,integer,integer,integer)'; END IF;
IF (SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef) FROM pg_proc p WHERE p.oid=to_regprocedure('clan_marionettisti_private.scene_slot_legal(text,integer,numeric,numeric,numeric)')) IS DISTINCT FROM $pin${"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"0542bf77cf7de7aaab86f417081d0921","signature":"clan_marionettisti_private.scene_slot_legal(text,integer,numeric,numeric,numeric)","source_md5":"f9aee1e4ac853c2291dabfa0db45bff8"}$pin$::jsonb THEN RAISE EXCEPTION 'C1242_FUNCTION_DRIFT:%', 'clan_marionettisti_private.scene_slot_legal(text,integer,numeric,numeric,numeric)'; END IF;
IF (SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef) FROM pg_proc p WHERE p.oid=to_regprocedure('combat_spatial.template_errors(text,integer)')) IS DISTINCT FROM $pin${"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"4611920469706f8d0b56345b39dc5478","signature":"combat_spatial.template_errors(text,integer)","source_md5":"168b5e4047516083612b098bbdb02d53"}$pin$::jsonb THEN RAISE EXCEPTION 'C1242_FUNCTION_DRIFT:%', 'combat_spatial.template_errors(text,integer)'; END IF;
IF (SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_creation_owner.human_assert(uuid)')) IS DISTINCT FROM $pin${"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"64240b718db9c55cb6039a8dce4d6c1b","signature":"mission_creation_owner.human_assert(uuid)","source_md5":"1ce886cdc79e7119ec47b59f52185c32"}$pin$::jsonb THEN RAISE EXCEPTION 'C1242_FUNCTION_DRIFT:%', 'mission_creation_owner.human_assert(uuid)'; END IF;
IF (SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_creation_owner.human_open(uuid,uuid)')) IS DISTINCT FROM $pin${"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"a0c5ff84b03ad800f0e6f58730a03457","signature":"mission_creation_owner.human_open(uuid,uuid)","source_md5":"fc283362174d39a7cdabfbc4f67d2c4f"}$pin$::jsonb THEN RAISE EXCEPTION 'C1242_FUNCTION_DRIFT:%', 'mission_creation_owner.human_open(uuid,uuid)'; END IF;
IF (SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_generic_owner.regia_entry_permit_valid_v1(uuid,uuid)')) IS DISTINCT FROM $pin${"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"f3ed41062c17be0782d5ca7d2e213276","signature":"mission_generic_owner.regia_entry_permit_valid_v1(uuid,uuid)","source_md5":"4339bcf8ff9b8210be3196f8e355f0ae"}$pin$::jsonb THEN RAISE EXCEPTION 'C1242_FUNCTION_DRIFT:%', 'mission_generic_owner.regia_entry_permit_valid_v1(uuid,uuid)'; END IF;
IF (SELECT jsonb_agg(jsonb_build_object('table',c.conrelid::regclass::text,'name',c.conname,'definition',pg_get_constraintdef(c.oid)) ORDER BY c.conrelid::regclass::text,c.conname) FROM pg_constraint c WHERE c.conrelid IN ('combat_spatial.actor_states'::regclass,'combat_panel_private.master_placement_options'::regclass)) IS DISTINCT FROM $pin$[{"name":"master_placement_options_actor_id_fkey","table":"combat_panel_private.master_placement_options","definition":"FOREIGN KEY (actor_id) REFERENCES combat_v2_actors(id)"},{"name":"master_placement_options_claim_id_actor_id_slot_key_key","table":"combat_panel_private.master_placement_options","definition":"UNIQUE (claim_id, actor_id, slot_key)"},{"name":"master_placement_options_claim_id_fkey","table":"combat_panel_private.master_placement_options","definition":"FOREIGN KEY (claim_id) REFERENCES combat_panel_private.master_scene_claims(id)"},{"name":"master_placement_options_pkey","table":"combat_panel_private.master_placement_options","definition":"PRIMARY KEY (id)"},{"name":"master_placement_options_radius_m_check","table":"combat_panel_private.master_placement_options","definition":"CHECK (((radius_m > (0)::numeric) AND (radius_m <> ALL (ARRAY['NaN'::numeric, 'Infinity'::numeric]))))"},{"name":"master_placement_options_x_m_check","table":"combat_panel_private.master_placement_options","definition":"CHECK (((x_m >= (0)::numeric) AND (x_m <> ALL (ARRAY['NaN'::numeric, 'Infinity'::numeric]))))"},{"name":"master_placement_options_y_m_check","table":"combat_panel_private.master_placement_options","definition":"CHECK (((y_m >= (0)::numeric) AND (y_m <> ALL (ARRAY['NaN'::numeric, 'Infinity'::numeric]))))"},{"name":"actor_states_actor_kind_check","table":"combat_spatial.actor_states","definition":"CHECK ((actor_kind = ANY (ARRAY['PG'::text, 'PNG'::text])))"},{"name":"actor_states_body_version_check","table":"combat_spatial.actor_states","definition":"CHECK ((body_version > 0))"},{"name":"actor_states_footprint_radius_m_check","table":"combat_spatial.actor_states","definition":"CHECK ((footprint_radius_m > (0)::numeric))"},{"name":"actor_states_instance_id_fkey","table":"combat_spatial.actor_states","definition":"FOREIGN KEY (instance_id) REFERENCES combat_spatial.arena_instances(instance_id)"},{"name":"actor_states_instance_id_projection_subject_id_key","table":"combat_spatial.actor_states","definition":"UNIQUE (instance_id, projection_subject_id)"},{"name":"actor_states_instance_id_slot_key_key","table":"combat_spatial.actor_states","definition":"UNIQUE (instance_id, slot_key)"},{"name":"actor_states_pkey","table":"combat_spatial.actor_states","definition":"PRIMARY KEY (instance_id, actor_id)"},{"name":"actor_states_state_check","table":"combat_spatial.actor_states","definition":"CHECK ((state = ANY (ARRAY['active'::text, 'removed'::text])))"}]$pin$::jsonb THEN RAISE EXCEPTION 'C1242_PLACEMENT_CONSTRAINT_DRIFT'; END IF;
IF NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m JOIN public.locations l ON l.id=m.location_id
 WHERE m.id='6ed892dc-ff74-467e-b656-b3960dc17bdc' AND m.stato='preparazione' AND m.closed_at IS NULL
 AND m.owner_kind='human' AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND l.is_test AND l.is_active)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND closed_at IS NULL AND id<>'6ed892dc-ff74-467e-b656-b3960dc17bdc')
 OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND closed_at IS NULL)
 THEN RAISE EXCEPTION 'C1242_STAFF_STATE_CHANGED'; END IF;
END $pre$;
CREATE OR REPLACE FUNCTION mission_creation_owner.bind_human_arena(p_master uuid, p_encounter uuid, p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare e mission_creation_owner.human_encounters;b mission_generic_owner.run_bindings;m public.master_v2_sessions;
 t combat_spatial.arena_templates;src jsonb;pid uuid;claim uuid;iid uuid;policy text;chosen boolean;
 a record;slot record;radius numeric;principal uuid;
 positions jsonb;pg_count integer;png_count integer;actor_index integer:=0;
begin
 select * into strict e from mission_creation_owner.human_encounters where encounter_id=p_encounter and master_session_id=p_master;
 if NOT mission_generic_owner.regia_entry_permit_valid_v1(p_master,p_request) then
  perform mission_creation_owner.human_assert(p_master);
 end if;
 select * into strict m from public.master_v2_sessions where id=p_master for update;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_master;
 src:=mission_creation_owner.arena_for_step(p_master,e.step_key);
 select * into strict t from combat_spatial.arena_templates
 where template_key=src->>'template_key' and template_version=(src->>'template_version')::integer and status='ready' for share;
 perform 1 from combat_spatial.arena_slots where template_key=t.template_key and template_version=t.template_version order by slot_key for share;
 perform 1 from combat_spatial.arena_objects where template_key=t.template_key and template_version=t.template_version order by object_key for share;
 if src->>'zone_key'<>'arena' or src->>'catalog_sha256' is distinct from combat_panel_private.universal_arena_hash(t.template_key,t.template_version)
 or t.geometry_hash is distinct from combat_spatial.geometry_fingerprint(t.template_key,t.template_version)
 or combat_spatial.template_errors(t.template_key,t.template_version)<>'[]'::jsonb
 then raise exception 'MG_ARENA_FROZEN_CATALOG_DRIFT' using errcode='40001';end if;
 if exists(select 1 from combat_spatial.arena_instances where encounter_id=p_encounter)
 or exists(select 1 from public.combat_v2_declarations d join public.combat_v2_rounds r on r.id=d.round_id where r.session_id=p_encounter)
 then raise exception 'MG_ARENA_ALREADY_BOUND_OR_DECLARED';end if;
 policy:=case when (select is_test from public.locations where id=m.location_id)
 then 'staff_test_no_persistent_resources_v1' else 'master_game_resources_v1' end;
 pid:=mission_ai_service_owner.uuid5(p_encounter,'generic-arena-profile');
 claim:=mission_ai_service_owner.uuid5(p_encounter,'generic-arena-claim');
 iid:=mission_ai_service_owner.uuid5(p_encounter,'generic-arena-instance');
 insert into combat_panel_private.master_panel_sessions(master_session_id,location_id,policy_id)
 values(p_master,m.location_id,policy) on conflict(master_session_id) do nothing;
 if not exists(select 1 from combat_panel_private.master_panel_sessions where master_session_id=p_master and location_id=m.location_id and policy_id=policy)
 then raise exception 'MG_ARENA_PANEL_POLICY_CONFLICT';end if;
 insert into combat_panel_private.master_scene_profiles(id,location_id,label,template_key,template_version,profile_version,geometry_fingerprint,policy_id,visibility_mode,enabled)
 values(pid,m.location_id,'Arena missione',t.template_key,t.template_version,1,t.geometry_hash,policy,'participants',true);
 insert into combat_panel_private.master_scene_claims(id,profile_id,profile_version,master_session_id,encounter_id,
 template_key,template_version,authority_principal_id,authority_control_version,geometry_fingerprint,roster_fingerprint,policy_id,visibility_mode)
 values(claim,pid,1,p_master,p_encounter,t.template_key,t.template_version,m.master_user,m.control_version,
 t.geometry_hash,combat_panel_private.master_roster_fingerprint(p_encounter),policy,'participants');
 insert into combat_spatial.arena_instances(instance_id,master_session_id,encounter_id,binding_id,template_key,template_version,map_version,state,context_source,panel_claim_id)
 values(iid,p_master,p_encounter,null,t.template_key,t.template_version,1,'open','panel_master',claim);
 -- General-v1: suggerimenti facoltativi; il generatore server restituisce PG prima dei PNG.
 if t.contract_version='arena-template/general-v1' then
  select count(*) filter(where actor_kind='pg'),count(*) filter(where actor_kind='png')
  into pg_count,png_count from public.combat_v2_actors where session_id=p_encounter and state='attivo';
  if t.actor_radius_m is distinct from 0.5 or exists(select 1 from public.combat_v2_actors
   where session_id=p_encounter and state='attivo' and actor_kind not in ('pg','png'))
  then raise exception 'MG_GENERAL_ROSTER_INVALID' using errcode='22023';end if;
  positions:=mission_creation_owner.general_plan_positions(t.template_key,t.template_version,pg_count,png_count);
  if jsonb_array_length(positions) is distinct from pg_count+png_count
  then raise exception 'MG_GENERAL_POSITION_COUNT' using errcode='22023';end if;
 end if;
 -- Le opzioni e le collisioni derivano dal catalogo server; nessuna coordinata IA/client.
 for a in select * from public.combat_v2_actors where session_id=p_encounter and state='attivo' order by actor_kind,id loop
  radius:=t.actor_radius_m;chosen:=false;
  actor_index:=actor_index+1;
  for slot in
   select v.slot_key,v.x_m,v.y_m from (
    select h.slot_key,h.x_m,h.y_m from combat_spatial.arena_slots h
     where positions is null and h.template_key=t.template_key and h.template_version=t.template_version
     and h.actor_kind=upper(a.actor_kind)
    union all
    select q.value->>'slot_key',(q.value->>'x')::numeric,(q.value->>'y')::numeric
     from jsonb_array_elements(coalesce(positions,'[]'::jsonb)) with ordinality q(value,ordinal)
     where positions is not null and q.ordinal=actor_index
   ) v order by v.slot_key loop
   if clan_marionettisti_private.scene_slot_legal(t.template_key,t.template_version,round(slot.x_m),round(slot.y_m),radius)
   and not exists(select 1 from combat_spatial.actor_states z where z.instance_id=iid and
   (z.slot_key=slot.slot_key or combat_spatial.distance_m(z.x_m,z.y_m,round(slot.x_m),round(slot.y_m))<=z.footprint_radius_m+radius)) then
    principal:=case when a.actor_kind='pg' then a.controller_user else m.master_user end;
    insert into combat_panel_private.master_placement_options(claim_id,actor_id,slot_key,x_m,y_m,radius_m)
    values(claim,a.id,slot.slot_key,round(slot.x_m),round(slot.y_m),radius);
    insert into combat_spatial.actor_states(instance_id,actor_id,actor_kind,slot_key,controller_principal_id,projection_subject_id,x_m,y_m,footprint_radius_m,body_version,state)
    values(iid,a.id,upper(a.actor_kind),slot.slot_key,principal,gen_random_uuid(),round(slot.x_m),round(slot.y_m),radius,1,'active');
    chosen:=true;exit;
   end if;
  end loop;
  if not chosen then raise exception 'MG_ARENA_LEGAL_SLOTS_INSUFFICIENT' using errcode='22023';end if;
 end loop;
 insert into combat_spatial.viewer_grants(instance_id,viewer_principal_id,subject_actor_id,can_view_map,can_view_objects,grant_version)
 select iid,v.controller_principal_id,z.actor_id,true,true,1 from combat_spatial.actor_states z
 cross join (select distinct controller_principal_id from combat_spatial.actor_states where instance_id=iid) v where z.instance_id=iid;
 insert into combat_spatial.object_states(instance_id,object_key,state,state_version)
 select iid,object_key,case when substitutable then 'available' else 'blocked' end,1 from combat_spatial.arena_objects
 where template_key=t.template_key and template_version=t.template_version;
 for a in select * from combat_spatial.actor_states where instance_id=iid loop
  if combat_spatial.path_first_block_t(iid,a.actor_id,a.x_m,a.y_m,a.x_m,a.y_m,null)<1
  then raise exception 'MG_ARENA_FINAL_OCCUPANCY_INVALID' using errcode='22023';end if;
 end loop;
 return jsonb_build_object('instance_id',iid,'claim_id',claim,'map_version',1);
end $function$
;
DO $post$ BEGIN
IF (SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_creation_owner.bind_human_arena(uuid,uuid,uuid)')) IS DISTINCT FROM $pin${"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"c4a0cc6e17a872c1a9086e75686810b0","signature":"mission_creation_owner.bind_human_arena(uuid,uuid,uuid)","source_md5":"2d0bdad5c047f70e9a925f97413fdd40"}$pin$::jsonb THEN RAISE EXCEPTION 'C1242_FUNCTION_DRIFT:%', 'mission_creation_owner.bind_human_arena(uuid,uuid,uuid)'; END IF;
END $post$;
COMMIT;
