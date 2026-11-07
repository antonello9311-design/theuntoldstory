-- FROZEN CODE MATERIAL: only the separate reviewed aggregate installer is executable.
-- PRIVATE SOURCE ONLY: NOT_INSTALLABLE_ROOT_REVIEW_AND_S16_CLOSE_PENDING.
-- Native future context may descend from admitted origin820c; no future UUID is invented.
-- Do not remove this STOP until exact integrated Root/Admin and independent review qualify the package.
-- Component source STOP is replaced by the aggregate installer STOP.

DO $fenice_cas$ DECLARE expected jsonb;actual jsonb;BEGIN
 IF to_regprocedure('clan_innata_narrative_private.fenice_staff_proof_v1(uuid)')IS NOT NULL THEN RAISE EXCEPTION 'FENICE_HELPER_ALREADY_EXISTS';END IF;
 FOR expected IN SELECT value FROM jsonb_array_elements('[{"oid":665885,"signature":"clan_innata_narrative_private.staff_profile_bind_v1(uuid,uuid)","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","ddl_md5":"492484888b32bd02c453a604c77a2e15","language":"plpgsql"},{"oid":31311,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","ddl_md5":"ec79a59f561042dee9eac224926afe28","language":"sql"}]'::jsonb)LOOP
 SELECT jsonb_build_object('oid',p.oid::bigint,'signature',replace(n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')',' ',''),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,'provolatile',p.provolatile,
 'language',l.lanname,'ddl_md5',md5(pg_get_functiondef(p.oid)))INTO actual FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
 JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=(expected->>'oid')::oid;
 IF actual IS DISTINCT FROM expected THEN RAISE EXCEPTION 'FENICE_BASELINE_CAS_DRIFT: %',expected->>'signature';END IF;END LOOP;
END $fenice_cas$;


-- SOURCE ONLY, parent Root e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce.
-- NOT INSTALLABLE: integrated Root/Admin/review/live CAS and own S16 close proof are required.
-- Component source STOP is replaced by the aggregate installer STOP.

DO $t3_perf_cas$ DECLARE expected jsonb;actual jsonb;BEGIN
 FOR expected IN SELECT value FROM jsonb_array_elements('[{"oid":44935,"schema":"combat_panel_private","proname":"add_choice","args":"p_group uuid, p_label text, p_payload jsonb, p_distance numeric, p_direction text","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","language":"plpgsql","ddl_md5":"bf10a590d59722b07b08cfa6cee42cce"},{"oid":44934,"schema":"combat_panel_private","proname":"add_group","args":"p_offer uuid, p_label text, p_purpose text, p_mode text, p_min integer, p_max integer, p_dependency uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","language":"plpgsql","ddl_md5":"c8ab455a415cebf8c64042c969417f02"},{"oid":45632,"schema":"combat_panel_private","proname":"multiplication_add_layout_groups","args":"p_offer uuid, p_dependency uuid, p_layouts jsonb","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","language":"plpgsql","ddl_md5":"f2515609aa9a224d7f2ff542a3f503c1"},{"oid":44654,"schema":"combat_panel_private","proname":"owned_context","args":"p_context uuid, p_expected bigint","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"plpgsql","ddl_md5":"0e0b91899d48c1ca7d5a84d7a3c5ab1a"},{"oid":46301,"schema":"combat_panel_private","proname":"body_visible_to_viewer","args":"p_instance uuid, p_actor uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"plpgsql","ddl_md5":"799e4bca3ff05feb4b94f07992778aa6"},{"oid":45714,"schema":"combat_panel_private","proname":"multiplication_layout_options_for_figure","args":"p_actor uuid, p_copies integer, p_mode text, p_target uuid, p_formation uuid, p_version bigint, p_index integer","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","language":"plpgsql","ddl_md5":"7b36f3d868c85c3941f120844c286dd9"},{"oid":45633,"schema":"combat_panel_private","proname":"multiplication_offers","args":"p_context uuid, p_expected bigint, p_view jsonb","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","language":"plpgsql","ddl_md5":"dbbfccc95dade54d951a4a5e62a3806b"},{"oid":45722,"schema":"combat_panel_private","proname":"multiplication_target_geometry_for_body","args":"p_actor uuid, p_target uuid, p_source uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"plpgsql","ddl_md5":"e73f7c394502436b0a315b5b0ecbd8c8"},{"oid":45638,"schema":"combat_panel_private","proname":"multiplication_target_figure","args":"p_actor uuid, p_target uuid, p_formation uuid, p_version bigint, p_index integer","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"plpgsql","ddl_md5":"05bdfab8c01966de7b16f5465bc6f010"},{"oid":45637,"schema":"combat_panel_private","proname":"multiplication_target_geometry","args":"p_actor uuid, p_target uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"plpgsql","ddl_md5":"931416e56edb3af79537a8fd3d4b1be9"},{"oid":45543,"schema":"combat_panel_private","proname":"multiplication_random_figure","args":"p_count integer, p_seed bytea","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"i","language":"plpgsql","ddl_md5":"9d90310f9b09edcf34b62bc9c9cdab8c"},{"oid":51621,"schema":"combat_panel_private","proname":"multiplication_tactics_allowed","args":"p_actor uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"sql","ddl_md5":"86d93a7e6f27d8e7adf6f852f8ef3de3"}]'::jsonb) LOOP
  SELECT jsonb_build_object('oid',p.oid::bigint,'schema',n.nspname,'proname',p.proname,'args',pg_get_function_identity_arguments(p.oid),
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,
   'provolatile',p.provolatile,'language',l.lanname,'ddl_md5',md5(pg_get_functiondef(p.oid))) INTO actual
  FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=(expected->>'oid')::oid;
  IF actual IS DISTINCT FROM expected THEN RAISE EXCEPTION 'T3_PERF_FUNCTION_CAS_DRIFT: %',expected->>'proname';END IF;
 END LOOP;
 FOR expected IN SELECT value FROM jsonb_array_elements('[{"acl":"{postgres=arwdDxtm/postgres}","oid":44556,"rls":true,"name":"combat_panel_private.choice_groups","owner":"postgres","force_rls":false,"columns_sha":"fee6bc136e517b02de6c6f2acfa0b226","triggers_sha":"d751713988987e9331980363e24189ce","constraints_sha":"533ae9013d64846c1f38d474c7583ed1"},{"acl":"{postgres=arwdDxtm/postgres}","oid":44581,"rls":true,"name":"combat_panel_private.choice_options","owner":"postgres","force_rls":false,"columns_sha":"99db1bcb56a36b28d4206abd37f9ac8e","triggers_sha":"d751713988987e9331980363e24189ce","constraints_sha":"13d7e8c4146413a7e2e35466433b8244"}]'::jsonb) LOOP
  SELECT jsonb_build_object('oid',c.oid::bigint,'name',n.nspname||'.'||c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,
   'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,
   'columns_sha',md5((SELECT jsonb_agg(jsonb_build_object('n',a.attnum,'name',a.attname,'type',pg_catalog.format_type(a.atttypid,a.atttypmod),
    'not_null',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid))ORDER BY a.attnum)::text FROM pg_attribute a
    LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)),
   'constraints_sha',md5((SELECT jsonb_agg(jsonb_build_object('name',co.conname,'def',pg_get_constraintdef(co.oid))ORDER BY co.conname)::text
    FROM pg_constraint co WHERE co.conrelid=c.oid)),
   'triggers_sha',md5(coalesce((SELECT jsonb_agg(pg_get_triggerdef(t.oid)ORDER BY t.tgname)::text FROM pg_trigger t
    WHERE t.tgrelid=c.oid AND NOT t.tgisinternal),'[]'))) INTO actual
  FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid=(expected->>'oid')::oid;
  IF actual IS DISTINCT FROM expected THEN RAISE EXCEPTION 'T3_PERF_TABLE_CAS_DRIFT: %',expected->>'name';END IF;
 END LOOP;
END $t3_perf_cas$;


CREATE OR REPLACE FUNCTION clan_innata_narrative_private.fenice_staff_proof_v1(p_actor uuid)
 RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors;s public.combat_v2_sessions;c clan_innata_narrative_private.contexts_v1;
 origin clan_innata_narrative_private.contexts_v1;t public.clan_techniques;sel jsonb;ability jsonb;prior jsonb;proof jsonb;ids uuid[];controllers uuid[];n integer;valid_chain boolean;
BEGIN
 IF statement_timestamp()<'2026-11-07T19:00:58.461822Z'::timestamptz
 OR statement_timestamp()>='2026-11-07T20:30:58.461822Z'::timestamptz THEN RETURN NULL;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind='pg' AND companion_id IS NULL AND state='attivo'
 AND character_id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid AND controller_user='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid;
 IF a.id IS NULL THEN RETURN NULL;END IF;
 SELECT * INTO s FROM public.combat_v2_sessions WHERE id=a.session_id;
 SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE context_id=(a.mechanics_snapshot#>>'{innata_staff_profile,context_id}')::uuid;
 SELECT * INTO origin FROM clan_innata_narrative_private.contexts_v1 WHERE context_id='820c5cbf-b2da-466b-bd5c-ecd03be8414c'::uuid;
 IF c.context_id IS NULL OR origin.context_id IS NULL OR c.context_id=origin.context_id
 OR s.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR s.created_at<'2026-11-07T19:00:58.461822Z'::timestamptz OR s.closed_at IS NOT NULL OR s.state IN('chiusa','annullata','sospeso')
 OR public.combat_v2_values_written(s.id) OR NOT c.active OR c.character_id IS DISTINCT FROM a.character_id
 OR c.location_id IS DISTINCT FROM s.location_id OR c.master_session_id IS DISTINCT FROM s.master_session_id
 OR c.scope_key IS DISTINCT FROM coalesce(c.master_session_id,c.location_id)
 OR(c.bound_combat_session_id IS NOT NULL AND c.bound_combat_session_id<>s.id)
 OR c.staff_ability_profile IS DISTINCT FROM origin.staff_ability_profile
 OR c.staff_ability_profile->>'profile_key' IS DISTINCT FROM 'byakugan-l3'
 OR c.staff_ability_profile->>'version' IS DISTINCT FROM '7'
 OR c.staff_ability_profile->>'created_by' IS DISTINCT FROM a.controller_user::text
 OR clan_innata_narrative_private.staff_profile_actor_v1(a.id)->>'profile_key' IS DISTINCT FROM 'byakugan-l3'
 OR(clan_innata_private.combat_context(a.id)).policy_id IS DISTINCT FROM 'staff_test_no_persistent_resources_v1'
 OR(clan_innata_private.combat_context(a.id)).activity_kind NOT IN('ordinary_v2','master_v2') THEN RETURN NULL;END IF;
 WITH RECURSIVE chain AS(
  SELECT c.context_id id,c.previous_context_id prev,ARRAY[c.context_id]path,true ok,c.created_at node_at
  UNION ALL
  SELECT x.context_id,x.previous_context_id,k.path||x.context_id,
   k.ok AND x.character_id=a.character_id AND x.location_id=s.location_id
   AND x.scope_key=coalesce(x.master_session_id,x.location_id) AND x.created_at<=k.node_at
   AND x.staff_ability_profile=origin.staff_ability_profile
   AND(x.bound_combat_session_id IS NULL OR EXISTS(SELECT 1 FROM public.combat_v2_sessions old
    WHERE old.id=x.bound_combat_session_id AND old.closed_at IS NOT NULL AND old.location_id=s.location_id
    AND NOT public.combat_v2_values_written(old.id))),x.created_at
  FROM chain k JOIN clan_innata_narrative_private.contexts_v1 x ON x.context_id=k.prev
  WHERE k.id<>origin.context_id AND cardinality(k.path)<16 AND NOT x.context_id=ANY(k.path))
 SELECT EXISTS(SELECT 1 FROM chain WHERE id=origin.context_id AND ok)INTO valid_chain;
 IF NOT valid_chain THEN RETURN NULL;END IF;
 SELECT e INTO sel FROM jsonb_array_elements(c.staff_ability_profile->'journal')e
 WHERE e->>'request_key'='707100f5-67b9-456b-8ee6-bda488ecd3fb'
 AND e->>'fingerprint'='87ec8a45674d8309f602710ec29880e2570ccbe1f4e68ba00c9fc91649a29400'
 AND e->>'api_version'='2' AND e#>>'{result,context_id}'='d92a97b8-8484-4957-8ccb-ce61c8920128'
 AND e#>>'{result,profile_version}'='7';
 IF sel IS NULL THEN RETURN NULL;END IF;
 SELECT array_agg(DISTINCT character_id ORDER BY character_id),array_agg(DISTINCT controller_user ORDER BY controller_user),count(*)
 INTO ids,controllers,n FROM public.combat_v2_actors WHERE session_id=s.id AND actor_kind='pg';
 IF n<>2 OR ids IS DISTINCT FROM ARRAY['2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid]
 OR controllers IS DISTINCT FROM ARRAY['15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid,'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid]
 OR NOT combat_consumer_private.staff_test_allowed(s.location_id,controllers,false)THEN RETURN NULL;END IF;
 SELECT * INTO t FROM public.clan_techniques WHERE id='6cc40917-1719-4759-9ba8-3064b806c24e'::uuid;
 IF(t.is_active AND t.macro='clan'AND t.clan='Uchiha'AND t.uso='principale'AND t.req_grade='Genin'
 AND t.req_stat='Kekkei Genkai'AND t.req_stat_value=40 AND t.req_tecnica IS NULL AND t.req_elements IS NULL
 AND t.requirements='Grande Palla di Fuoco · grado Genin · Kekkei Genkai ≥ 40'
 AND t.chakra_cost=5 AND t.danno_base=15 AND t.gittata='media'AND t.consumption_type='ad_utilizzo'
 AND NOT t.difensiva AND NOT t.di_scena AND NOT t.is_innata
 AND coalesce((a.mechanics_snapshot->>'kekkei_genkai')::integer,0)>=40
 AND public._grade_rank(clan_innata_narrative_private.staff_profile_actor_v1(a.id)->>'required_grade')>=public._grade_rank('Genin'))IS DISTINCT FROM true
 THEN RETURN NULL;END IF;
 ability:=combat_v2_multitarget_internal.enrich_ability_v1(jsonb_build_object('source','clan','id',t.id,'name',t.name,'kind',t.category,
 'usage',t.uso,'defensive',false,'di_scena',false,'diversivo',false,'consumption_type',t.consumption_type,'range',t.gittata,
 'chakra_cost',t.chakra_cost,'damage_base',t.danno_base,'element','Fuoco'));
 IF ability->'targeting'IS DISTINCT FROM '{"mode":"multi","affects":"enemies_only","geometry":"per_target_line","selection":"manual","max_targets":3,"damage_policy":"full_each","schema_version":"combat-targeting/1.1","geometry_status":"ready"}'::jsonb THEN RETURN NULL;END IF;
 SELECT coalesce(jsonb_agg(x.value ORDER BY x.ordinality),'[]'::jsonb)INTO prior
 FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]'::jsonb))WITH ORDINALITY x(value,ordinality)
 WHERE NOT(x.value->>'source'='clan'AND x.value->>'id'=t.id::text);
 proof:=jsonb_build_object('schema_version','staff-fenice-dependency/1','campaign','COMBAT-TACTICS-FACING-F3MAX2-20261107',
 'origin_context',origin.context_id,'context_id',c.context_id,'selection_request',sel->'request_key','selection_receipt_sha256',public.combat_v2_sha256(sel),
 'profile_version',7,'actor_id',a.id,'session_id',s.id,'character_id',a.character_id,'controller_user',a.controller_user,'controller_version',a.controller_version,
 'abilities_before_sha256',public.combat_v2_sha256(prior),'ability',ability,'is_test',true,'values_written',false,'chakra_spent',0,'main_action_consumed',false,'statistics_changed',false,
 'simulated_requirements',jsonb_build_object('clan_permission','Uchiha','element_permission','Fuoco','grade_minimum','Genin','kekkei_genkai_minimum',40,
 'prerequisite_permission','1260dbc8-ab0c-4b2b-9b94-909d39b7ffbe','prerequisite_ability_granted',false));
 RETURN proof||jsonb_build_object('sha256',public.combat_v2_sha256(proof));
END $function$;
ALTER FUNCTION clan_innata_narrative_private.fenice_staff_proof_v1(uuid) OWNER TO postgres;
REVOKE ALL ON FUNCTION clan_innata_narrative_private.fenice_staff_proof_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.staff_profile_bind_v1(p_context uuid, p_actor uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c clan_innata_narrative_private.contexts_v1;a public.combat_v2_actors;s public.combat_v2_sessions;d jsonb;mark jsonb;snap jsonb;ability jsonb;prior clan_sabaku_private.reserves;req uuid;fenice jsonb;
BEGIN
 SELECT * INTO STRICT c FROM clan_innata_narrative_private.contexts_v1 WHERE context_id=p_context FOR UPDATE;
 IF c.staff_ability_profile->>'profile_key'IS NULL THEN RETURN;END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND character_id=c.character_id AND actor_kind='pg'AND companion_id IS NULL FOR UPDATE;
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=a.session_id;
 IF s.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid OR c.location_id<>s.location_id OR public.combat_v2_values_written(s.id)
 OR NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.profiles pr ON pr.id=ch.user_id WHERE ch.id=a.character_id AND ch.user_id=a.controller_user
 AND pr.role IN('admin','master')AND c.staff_ability_profile->>'created_by'=ch.user_id::text)
 THEN RAISE EXCEPTION 'INNATA_STAFF_ONLY' USING ERRCODE='42501';END IF;
 d:=clan_innata_narrative_private.profile_definition_v2(c.staff_ability_profile->>'profile_key');
 IF EXISTS(SELECT 1 FROM clan_innata_narrative_private.states_v1 WHERE context_id=c.context_id AND active AND technique_id<>(d->>'technique_id')::uuid)
 THEN RAISE EXCEPTION 'INNATA_PROFILE_ACTIVE' USING ERRCODE='55000';END IF;
 mark:=jsonb_build_object('context_id',c.context_id,'profile_version',(c.staff_ability_profile->>'version')::bigint,'profile_key',d->'profile_key','technique_id',d->'technique_id',
 'actor_id',a.id,'session_id',s.id,'character_id',a.character_id,'controller_user',a.controller_user);
 IF d->>'lifecycle_kind'='passive_permission'THEN
  snap:=a.mechanics_snapshot;
  SELECT coalesce(jsonb_agg(x ORDER BY x->>'name'),'[]'::jsonb)INTO ability FROM jsonb_array_elements(coalesce(snap->'abilities','[]'::jsonb))x
   WHERE NOT(x->>'source'='clan'AND x->>'id' IN('94c45ec9-78c7-423e-9045-4b4cf2104b15','d2d98dad-fb9f-4ff1-b6b2-3d3f2d222fae','6d264e00-1db3-4daa-b7cc-e5f011e1dab1','2fb3e027-a4ff-4058-9d5d-0212facb3f68','bc2569b5-eab4-44b4-9843-c199724caff4','09097efd-e162-4cae-a644-5e643fe94f8c','dd2026b4-bffc-490e-8646-be411d4746b3','fdf79ce1-1c5b-44c4-aaa1-789be08e01de','ed808bc6-57f6-4853-80bf-9e6985ca0cc3','41254b82-5b5e-46e9-9820-b3d604bbe38f','2fb9e210-225d-460a-a9f9-39ee64f8fce1','ab64415a-cca3-472f-9203-84ad60c09405','4a527ff2-0420-4da9-bc1f-5489c753b285','8e20bafe-cb3c-4967-b9c7-2a4bca694996','9b384de3-35f0-43c0-b145-94f985fa758a','a50808fa-e7cd-45ee-b4d4-33ad8c65d472','b0748ef4-bea8-4d85-95a1-7d9db1b4381c','843031ac-521a-4c5b-832e-37a0398a9862','537945fc-b7a3-4661-8144-e3fbcd6b24d0','d48b7246-44bf-4ecc-a4dc-a9bb705c331a','4d742b75-2592-4379-81c0-07ddf436f32b','6e4b8efc-e324-404a-a8c7-b4c39b8070b8','559606f3-f3a0-401d-9e8c-7685624bb880','7fef3cc6-ec43-49a2-a740-cd9f4ee1c31a','20341270-6241-45cd-9633-437d3ce80447','32d0749c-6167-45da-8880-bb3f60dd401f','a4704025-1ef8-43c9-9e5b-113582a7e621','6c56bb2f-4936-4c43-873e-dde65fe42d2b','001f907c-8f32-4758-8a16-ad1730e72c59','e6cc70fa-7ef3-4eaf-afb7-4ca6f588c2b4','efd15ad1-c1ae-4495-aaa5-0f9415f4be0a','e0456437-21d5-4a04-9d8a-9bffbf87c26d','4056f62d-77f3-47f9-8ecb-9a7799682a9d','65b30dec-6f9f-459e-b78c-49173d74f251','f3673da7-42c9-497e-abe1-1c0982429f35','1ab6d359-f337-45ed-839c-4e626d2e2819'));
  ability:=ability||jsonb_build_array(jsonb_build_object('source','clan','id',d->'technique_id','name',d->'name','kind','abilita',
   'usage','passiva','consumption_type','passiva','chakra_cost',NULL,'defensive',false,'di_scena',false,'diversivo',false));
  snap:=jsonb_set(snap,'{abilities}',ability,true)||jsonb_build_object('innata_staff_profile',mark,'innata_staff_required_grade',d->'required_grade',
   'innata_permission_fact',clan_innata_narrative_private.permission_fact_v2(c.context_id));
  -- Permission does not alter statistics; required KG/grade remain simulated eligibility metadata only.
  UPDATE public.combat_v2_actors SET mechanics_snapshot=snap WHERE id=a.id;
  IF clan_innata_narrative_private.staff_profile_actor_v1(a.id)IS NULL THEN RAISE EXCEPTION 'INNATA_PERMISSION_BIND_INVALID' USING ERRCODE='42501';END IF;
  RETURN;
 END IF;
 SELECT jsonb_build_object('source','clan','id',t.id,'name',t.name,'kind',coalesce(t.category,'fisico'),'usage',t.uso,'defensive',coalesce(t.difensiva,false),
 'di_scena',coalesce(t.di_scena,false),'diversivo',false,'consumption_type','per_turno','range',t.gittata,'chakra_cost',q.activation_cost,'damage_base',coalesce(t.danno_base,0))INTO ability
 FROM public.clan_techniques t JOIN clan_innata_narrative_private.config_quotes_v1 q ON q.technique_id=t.id WHERE t.id=(d->>'technique_id')::uuid;
 SELECT coalesce(jsonb_agg(x ORDER BY x->>'name'),'[]'::jsonb)INTO snap FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]'::jsonb))x
 WHERE NOT EXISTS(SELECT 1 FROM public.clan_techniques t WHERE t.id::text=x->>'id'AND x->>'source'='clan'AND(t.is_innata OR t.id IN('94c45ec9-78c7-423e-9045-4b4cf2104b15'::uuid,'d2d98dad-fb9f-4ff1-b6b2-3d3f2d222fae'::uuid,'6d264e00-1db3-4daa-b7cc-e5f011e1dab1'::uuid,'2fb3e027-a4ff-4058-9d5d-0212facb3f68'::uuid,'bc2569b5-eab4-44b4-9843-c199724caff4'::uuid,'09097efd-e162-4cae-a644-5e643fe94f8c'::uuid,'dd2026b4-bffc-490e-8646-be411d4746b3'::uuid,'fdf79ce1-1c5b-44c4-aaa1-789be08e01de'::uuid,'ed808bc6-57f6-4853-80bf-9e6985ca0cc3'::uuid,'41254b82-5b5e-46e9-9820-b3d604bbe38f'::uuid,'2fb9e210-225d-460a-a9f9-39ee64f8fce1'::uuid,'ab64415a-cca3-472f-9203-84ad60c09405'::uuid,'4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid,'b0748ef4-bea8-4d85-95a1-7d9db1b4381c'::uuid,'843031ac-521a-4c5b-832e-37a0398a9862'::uuid,'537945fc-b7a3-4661-8144-e3fbcd6b24d0'::uuid,'d48b7246-44bf-4ecc-a4dc-a9bb705c331a'::uuid,'4d742b75-2592-4379-81c0-07ddf436f32b'::uuid,'6e4b8efc-e324-404a-a8c7-b4c39b8070b8'::uuid,'559606f3-f3a0-401d-9e8c-7685624bb880'::uuid,'7fef3cc6-ec43-49a2-a740-cd9f4ee1c31a'::uuid,'20341270-6241-45cd-9633-437d3ce80447'::uuid,'32d0749c-6167-45da-8880-bb3f60dd401f'::uuid,'a4704025-1ef8-43c9-9e5b-113582a7e621'::uuid,'6c56bb2f-4936-4c43-873e-dde65fe42d2b'::uuid,'001f907c-8f32-4758-8a16-ad1730e72c59'::uuid,'e6cc70fa-7ef3-4eaf-afb7-4ca6f588c2b4'::uuid,'efd15ad1-c1ae-4495-aaa5-0f9415f4be0a'::uuid,'e0456437-21d5-4a04-9d8a-9bffbf87c26d'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)));
 snap:=jsonb_set(a.mechanics_snapshot,'{abilities}',snap||jsonb_build_array(ability),false);
 snap:=jsonb_set(snap,'{kekkei_genkai}',to_jsonb((d->>'required_kg')::integer),false);
 snap:=snap||jsonb_build_object('innata_staff_profile',mark,'innata_staff_required_grade',d->'required_grade');
 UPDATE public.combat_v2_actors SET mechanics_snapshot=snap WHERE id=a.id;
 req:=extensions.uuid_generate_v5(c.context_id,a.id::text||':innata-profile:'||(c.staff_ability_profile->>'version'));
 IF d->>'profile_key'='sabaku-l1' THEN
  INSERT INTO clan_sabaku_private.staff_profiles(session_id,actor_id,request_id,receipt_id,bind_result)
  VALUES(s.id,a.id,req,req,jsonb_build_object('operation','staff_profile','profile_context',c.context_id,'profile_version',c.staff_ability_profile->'version','is_test',true,'values_written',false));
  IF NOT EXISTS(SELECT 1 FROM clan_sabaku_private.reserves WHERE session_id=s.id AND actor_id=a.id AND is_test)THEN
   SELECT r.* INTO prior FROM clan_sabaku_private.reserves r JOIN public.combat_v2_sessions cs ON cs.id=r.session_id
   WHERE r.character_id=a.character_id AND r.is_test AND cs.location_id=s.location_id AND cs.closed_at IS NOT NULL ORDER BY cs.closed_at DESC LIMIT 1;
   INSERT INTO clan_sabaku_private.reserves(character_id,session_id,actor_id,is_test,capacity,current_amount)
   VALUES(a.character_id,s.id,a.id,true,15,CASE WHEN prior.id IS NULL THEN 15 ELSE least(15,prior.current_amount)END);
  END IF;
 ELSE
  INSERT INTO clan_hyuga_private.staff_profiles(session_id,actor_id,profile_version,created_request,is_active)
  VALUES(s.id,a.id,(d->>'profile_key')||'/1',req,true);
 END IF;
 IF clan_innata_narrative_private.staff_profile_actor_v1(a.id)IS NULL THEN RAISE EXCEPTION 'INNATA_PROFILE_BIND_INVALID' USING ERRCODE='42501';END IF;
 fenice:=clan_innata_narrative_private.fenice_staff_proof_v1(a.id);
 IF fenice IS NOT NULL THEN
  SELECT mechanics_snapshot INTO snap FROM public.combat_v2_actors WHERE id=a.id FOR UPDATE;
  IF snap ? 'fenice_staff_dependency'AND snap->'fenice_staff_dependency'IS DISTINCT FROM fenice
  THEN RAISE EXCEPTION 'FENICE_RECEIPT_CONFLICT' USING ERRCODE='22023';END IF;
  SELECT coalesce(jsonb_agg(x.value ORDER BY x.ordinality),'[]'::jsonb)INTO ability
  FROM jsonb_array_elements(snap->'abilities')WITH ORDINALITY x(value,ordinality)
  WHERE NOT(x.value->>'source'='clan'AND x.value->>'id'='6cc40917-1719-4759-9ba8-3064b806c24e');
  UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(snap,'{abilities}',ability||jsonb_build_array(fenice->'ability'),false)
   ||jsonb_build_object('fenice_staff_dependency',fenice)WHERE id=a.id;
 END IF;

END $function$
;

CREATE OR REPLACE FUNCTION public.combat_v2_actor_ability(p_actor uuid, p_source text, p_ability uuid, p_defense boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT CASE WHEN p_source='clan'AND p_ability='6cc40917-1719-4759-9ba8-3064b806c24e'::uuid
 AND EXISTS(SELECT 1 FROM public.combat_v2_actors a WHERE a.id=p_actor AND a.mechanics_snapshot ? 'fenice_staff_dependency')THEN
 (SELECT proof->'ability'FROM public.combat_v2_actors a
 CROSS JOIN LATERAL(SELECT clan_innata_narrative_private.fenice_staff_proof_v1(a.id)proof)q
 WHERE a.id=p_actor AND p_defense IS FALSE AND proof IS NOT NULL AND proof=a.mechanics_snapshot->'fenice_staff_dependency'
 AND(SELECT count(*)FROM jsonb_array_elements(a.mechanics_snapshot->'abilities')x WHERE x=proof->'ability')=1)
 ELSE(SELECT CASE WHEN p_source='clan' AND p_ability='58a2f5cd-6409-40f6-8f18-cfdb4410ca26'::uuid THEN
 CASE WHEN p_defense THEN clan_hyuga_private.rotation_ability_meta(p_actor) ELSE NULL END
 ELSE clan_aburame_private.actor_ability(p_actor,p_source,p_ability,p_defense,(select combat_v2_elemental_internal.scudo_ability_meta(p_actor,combat_v2_elemental_internal.other_ability_meta(p_actor,combat_v2_elemental_internal.suiton_ability_meta(p_actor,clan_uchiha_private.fireball_ability_meta(p_actor,clan_hyuga_private.sedici_ability_meta(p_actor,a.value)))))
  from public.combat_v2_actors x
  cross join lateral jsonb_array_elements(coalesce(x.mechanics_snapshot->'abilities','[]'::jsonb)) a(value)
  where x.id=p_actor and a.value->>'source'=p_source and (a.value->>'id')::uuid=p_ability
    and (not p_defense or coalesce((a.value->>'defensive')::boolean,false))
    and CASE WHEN p_source='clan' AND p_ability IN (
          '1260dbc8-ab0c-4b2b-9b94-909d39b7ffbe'::uuid,'5bf9764e-b719-4972-9d75-083b4cb633e7'::uuid)
        THEN clan_uchiha_private.fireball_ability_meta(p_actor,a.value) IS NOT NULL
        ELSE (not combat_v2_elemental_internal.is_target_v1(p_ability)
         or combat_v2_elemental_internal.eligible_v1(x.character_id,p_ability,p_defense)
         or (p_defense AND p_source='clan' AND p_ability='9061c022-ca82-4d2b-8102-e208fcc6c1a2'::uuid AND combat_v2_elemental_internal.scudo_profile(p_actor) IS NOT NULL)
         or (NOT p_defense AND p_source='clan' AND coalesce(combat_v2_elemental_internal.suiton_profile(p_actor,p_ability),combat_v2_elemental_internal.other_profile(p_actor,p_ability)) IS NOT NULL)) END
    and clan_hyuga_private.sedici_ability_meta(p_actor,a.value) IS NOT NULL
    and clan_uchiha_private.fireball_ability_meta(p_actor,a.value) IS NOT NULL
  limit 1)) END)END
$function$;

CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_add_layout_groups(p_offer uuid, p_dependency uuid, p_layouts jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE held_offer combat_panel_private.offers%ROWTYPE;held_context combat_panel_private.contexts%ROWTYPE;optimized_batch boolean:=false;
 staged_groups combat_panel_private.choice_groups[]:=ARRAY[]::combat_panel_private.choice_groups[];
 staged_options combat_panel_private.choice_options[]:=ARRAY[]::combat_panel_private.choice_options[];
 choice_ordinals jsonb:='{}'::jsonb;group_ordinal integer;choice_ordinal integer;staged_choice uuid;
 direction_group uuid; direction_option uuid; layout_group uuid; layout_option uuid; original_group uuid;
 layout jsonb; original jsonb; dir record; label text; private_index integer; private_figures jsonb;
BEGIN
 IF jsonb_typeof(p_layouts) IS DISTINCT FROM 'array' OR jsonb_array_length(p_layouts)=0 THEN
   RAISE EXCEPTION 'panel_multiplication_layouts_missing' USING ERRCODE='22023'; END IF;
 -- Same owner/state/context authority as add_group, held for the complete batch.
 SELECT * INTO STRICT held_offer FROM combat_panel_private.offers WHERE id=p_offer
  AND principal_user=exam_regia_private.current_principal() AND state='offered' FOR UPDATE;
 held_context:=combat_panel_private.owned_context(held_offer.context_id,held_offer.context_version);
 optimized_batch:=combat_panel_private.multiplication_tactics_allowed(held_context.command_actor_id);
 SELECT coalesce(max(ordinal)+1,0) INTO group_ordinal
  FROM combat_panel_private.choice_groups WHERE offer_id=held_offer.id;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(p_layouts) x WHERE x->>'endpoint_layout'='true') THEN
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(p_layouts) x WHERE x->>'endpoint_layout' IS DISTINCT FROM 'true') THEN
   RAISE EXCEPTION 'panel_multiplication_endpoint_layout_mixed' USING ERRCODE='22023'; END IF;
  -- Il raggruppamento nativo può associare più capability allo stesso layout.
  -- Ogni alternativa resta una scelta distinta, con il proprio insieme bersagli sigillato.
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(p_layouts) l
    WHERE jsonb_typeof(l->'original_options') IS DISTINCT FROM 'array'
       OR jsonb_array_length(l->'original_options')=0) THEN
   RAISE EXCEPTION 'panel_multiplication_endpoint_original_invalid' USING ERRCODE='22023'; END IF;
  SELECT jsonb_agg(jsonb_set(l.value,'{original_options}',jsonb_build_array(o.value))
    ORDER BY l.ordinal,o.ordinal) INTO p_layouts
   FROM jsonb_array_elements(p_layouts) WITH ORDINALITY l(value,ordinal)
   CROSS JOIN LATERAL jsonb_array_elements(l.value->'original_options') WITH ORDINALITY o(value,ordinal);
  IF optimized_batch THEN
   direction_group:=pg_catalog.gen_random_uuid();
   staged_groups:=array_append(staged_groups,ROW(direction_group,p_offer,'Distanza dal bersaglio','single','movement_direction',1,1,p_dependency,group_ordinal)::combat_panel_private.choice_groups);
   group_ordinal:=group_ordinal+1;
  ELSE
   direction_group:=combat_panel_private.add_group(p_offer,'Distanza dal bersaglio','movement_direction','single',1,1,p_dependency);
  END IF;
  FOR dir IN SELECT DISTINCT (value->>'target_distance_m')::integer AS gap FROM jsonb_array_elements(p_layouts) ORDER BY gap LOOP
   IF dir.gap NOT IN (0,1,2) THEN RAISE EXCEPTION 'panel_multiplication_endpoint_gap_invalid' USING ERRCODE='22023';END IF;
   IF optimized_batch THEN
    direction_option:=pg_catalog.gen_random_uuid();
    choice_ordinal:=coalesce((choice_ordinals->>(direction_group)::text)::integer,0);
    staged_options:=array_append(staged_options,ROW(direction_option,p_offer,direction_group,'Termina a '||dir.gap||' m',dir.gap,NULL,'{}'::jsonb,choice_ordinal)::combat_panel_private.choice_options);
    choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(direction_group)::text],to_jsonb(choice_ordinal+1),true);
   ELSE
    direction_option:=combat_panel_private.add_choice(direction_group,'Termina a '||dir.gap||' m','{}'::jsonb,dir.gap,NULL);
   END IF;
   IF optimized_batch THEN
    layout_group:=pg_catalog.gen_random_uuid();
    staged_groups:=array_append(staged_groups,ROW(layout_group,p_offer,'Punto d’arrivo','single','movement_distance',1,1,direction_option,group_ordinal)::combat_panel_private.choice_groups);
    group_ordinal:=group_ordinal+1;
   ELSE
    layout_group:=combat_panel_private.add_group(p_offer,'Punto d’arrivo','movement_distance','single',1,1,direction_option);
   END IF;
   FOR layout IN SELECT value FROM jsonb_array_elements(p_layouts) WHERE (value->>'target_distance_m')::integer=dir.gap
    ORDER BY (value->>'extent_m')::numeric,(value->>'endpoint_x_m')::numeric,(value->>'endpoint_y_m')::numeric LOOP
    IF jsonb_array_length(layout->'original_options')<>1 THEN RAISE EXCEPTION 'panel_multiplication_endpoint_original_invalid' USING ERRCODE='22023';END IF;
    -- Permutazione solo dopo l'aggregazione native draw_layouts e prima del payload offerta.
    -- La geometria canonica interna non viene consegnata con indiceoriginale fisso.
    private_index:=combat_panel_private.multiplication_random_figure(jsonb_array_length(layout->'figures'),extensions.gen_random_bytes(32));
    SELECT jsonb_agg((f.value-'figure_index')||jsonb_build_object('figure_index',
       1+mod((f.value->>'figure_index')::integer+private_index-2,jsonb_array_length(layout->'figures')))
       ORDER BY 1+mod((f.value->>'figure_index')::integer+private_index-2,jsonb_array_length(layout->'figures')))
     INTO private_figures FROM jsonb_array_elements(layout->'figures') f;
    IF optimized_batch THEN
     layout_option:=pg_catalog.gen_random_uuid();
     choice_ordinal:=coalesce((choice_ordinals->>(layout_group)::text)::integer,0);
     staged_options:=array_append(staged_options,ROW(layout_option,p_offer,layout_group,'Arrivo ('||(layout->>'endpoint_x_m')||', '||(layout->>'endpoint_y_m')||') · percorso '||(layout->>'extent_m')||' m',(layout->>'extent_m')::numeric,NULL::text,jsonb_build_object('multiplication_figures',private_figures),choice_ordinal)::combat_panel_private.choice_options);
     choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(layout_group)::text],to_jsonb(choice_ordinal+1),true);
    ELSE
     layout_option:=combat_panel_private.add_choice(layout_group,'Arrivo ('||(layout->>'endpoint_x_m')||', '||(layout->>'endpoint_y_m')||') · percorso '||(layout->>'extent_m')||' m',
      jsonb_build_object('multiplication_figures',private_figures),(layout->>'extent_m')::numeric);
    END IF;
    IF optimized_batch THEN
     original_group:=pg_catalog.gen_random_uuid();
     staged_groups:=array_append(staged_groups,ROW(original_group,p_offer,'Originale · arrivo scelto','single','generic',1,1,layout_option,group_ordinal)::combat_panel_private.choice_groups);
     group_ordinal:=group_ordinal+1;
    ELSE
     original_group:=combat_panel_private.add_group(p_offer,'Originale · arrivo scelto','generic','single',1,1,layout_option);
    END IF;
    original:=(layout->'original_options'->0)||jsonb_build_object('figure_index',private_index);
    IF optimized_batch THEN
     staged_choice:=pg_catalog.gen_random_uuid();
     choice_ordinal:=coalesce((choice_ordinals->>(original_group)::text)::integer,0);
     staged_options:=array_append(staged_options,ROW(staged_choice,p_offer,original_group,'Arrivo selezionato · distanza finale '||(original->>'target_distance_m')||' m',(original->>'distance_m')::numeric,NULL::text,jsonb_build_object('multiplication_original',original->'figure_index','multiplication_movement_capability_id',original->'movement_capability_id',
        'multiplication_endpoint_gap_m',original->'target_distance_m','multiplication_endpoint_contract','assault-endpoint/1')
       ||CASE WHEN original ? 'assault_draw' THEN jsonb_build_object('multiplication_assault_draw',original->'assault_draw') ELSE '{}'::jsonb END,choice_ordinal)::combat_panel_private.choice_options);
     choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(original_group)::text],to_jsonb(choice_ordinal+1),true);
    ELSE
     PERFORM combat_panel_private.add_choice(original_group,'Arrivo selezionato · distanza finale '||(original->>'target_distance_m')||' m',
      jsonb_build_object('multiplication_original',original->'figure_index','multiplication_movement_capability_id',original->'movement_capability_id',
        'multiplication_endpoint_gap_m',original->'target_distance_m','multiplication_endpoint_contract','assault-endpoint/1')
       ||CASE WHEN original ? 'assault_draw' THEN jsonb_build_object('multiplication_assault_draw',original->'assault_draw') ELSE '{}'::jsonb END,
      (original->>'distance_m')::numeric);
    END IF;
   END LOOP;
  END LOOP;
 IF optimized_batch THEN
 -- Native same-offer dependency FK is DEFERRABLE INITIALLY DEFERRED.
 -- All new parent groups exist before inserting their options; no constraint is disabled.
 INSERT INTO combat_panel_private.choice_groups(id,offer_id,label,selection_mode,purpose,min_selected,max_selected,depends_on,ordinal)
  SELECT r.id,r.offer_id,r.label,r.selection_mode,r.purpose,r.min_selected,r.max_selected,r.depends_on,r.ordinal
  FROM unnest(staged_groups) r;
 INSERT INTO combat_panel_private.choice_options(id,offer_id,group_id,label,distance_m,direction,source_payload,ordinal)
  SELECT r.id,r.offer_id,r.group_id,r.label,r.distance_m,r.direction,r.source_payload,r.ordinal
  FROM unnest(staged_options) r;
 END IF;
  RETURN;
 END IF;
 IF optimized_batch THEN
  direction_group:=pg_catalog.gen_random_uuid();
  staged_groups:=array_append(staged_groups,ROW(direction_group,p_offer,'Direzione delle figure','single','movement_direction',1,1,p_dependency,group_ordinal)::combat_panel_private.choice_groups);
  group_ordinal:=group_ordinal+1;
 ELSE
  direction_group:=combat_panel_private.add_group(p_offer,'Direzione delle figure','movement_direction','single',1,1,p_dependency);
 END IF;
 FOR dir IN SELECT DISTINCT value->>'direction' AS code FROM jsonb_array_elements(p_layouts) ORDER BY code LOOP
   label:=CASE dir.code WHEN 'up' THEN 'Nord' WHEN 'down' THEN 'Sud' WHEN 'right' THEN 'Est' WHEN 'left' THEN 'Ovest' END;
   IF label IS NULL THEN RAISE EXCEPTION 'panel_multiplication_direction_invalid' USING ERRCODE='22023'; END IF;
   IF optimized_batch THEN
    direction_option:=pg_catalog.gen_random_uuid();
    choice_ordinal:=coalesce((choice_ordinals->>(direction_group)::text)::integer,0);
    staged_options:=array_append(staged_options,ROW(direction_option,p_offer,direction_group,label,NULL,dir.code,'{}'::jsonb,choice_ordinal)::combat_panel_private.choice_options);
    choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(direction_group)::text],to_jsonb(choice_ordinal+1),true);
   ELSE
    direction_option:=combat_panel_private.add_choice(direction_group,label,'{}'::jsonb,NULL,dir.code);
   END IF;
   IF optimized_batch THEN
    layout_group:=pg_catalog.gen_random_uuid();
    staged_groups:=array_append(staged_groups,ROW(layout_group,p_offer,'Disposizione delle figure','single','movement_distance',1,1,direction_option,group_ordinal)::combat_panel_private.choice_groups);
    group_ordinal:=group_ordinal+1;
   ELSE
    layout_group:=combat_panel_private.add_group(p_offer,'Disposizione delle figure','movement_distance','single',1,1,direction_option);
   END IF;
   FOR layout IN SELECT value FROM jsonb_array_elements(p_layouts) WHERE value->>'direction'=dir.code ORDER BY (value->>'extent_m')::numeric LOOP
     IF optimized_batch THEN
      layout_option:=pg_catalog.gen_random_uuid();
      choice_ordinal:=coalesce((choice_ordinals->>(layout_group)::text)::integer,0);
      staged_options:=array_append(staged_options,ROW(layout_option,p_offer,layout_group,'Figure fino a '||(layout->>'extent_m')||' m',(layout->>'extent_m')::numeric,NULL::text,jsonb_build_object('multiplication_figures',layout->'figures'),choice_ordinal)::combat_panel_private.choice_options);
      choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(layout_group)::text],to_jsonb(choice_ordinal+1),true);
     ELSE
      layout_option:=combat_panel_private.add_choice(layout_group,'Figure fino a '||(layout->>'extent_m')||' m',
       jsonb_build_object('multiplication_figures',layout->'figures'),(layout->>'extent_m')::numeric);
     END IF;
     IF optimized_batch THEN
      original_group:=pg_catalog.gen_random_uuid();
      staged_groups:=array_append(staged_groups,ROW(original_group,p_offer,'Originale · scelta privata','single','generic',1,1,layout_option,group_ordinal)::combat_panel_private.choice_groups);
      group_ordinal:=group_ordinal+1;
     ELSE
      original_group:=combat_panel_private.add_group(p_offer,'Originale · scelta privata','generic','single',1,1,layout_option);
     END IF;
     FOR original IN SELECT value FROM jsonb_array_elements(layout->'original_options') ORDER BY (value->>'figure_index')::integer LOOP
       IF optimized_batch THEN
        staged_choice:=pg_catalog.gen_random_uuid();
        choice_ordinal:=coalesce((choice_ordinals->>(original_group)::text)::integer,0);
        staged_options:=array_append(staged_options,ROW(staged_choice,p_offer,original_group,'Figura '||(original->>'figure_index')||CASE WHEN original->>'target_distance_m' IS NOT NULL THEN ' · termina a '||(original->>'target_distance_m')||' m' ELSE ' · spostamento '||round((original->>'distance_m')::numeric,2)||' m' END,(original->>'distance_m')::numeric,NULL::text,jsonb_build_object('multiplication_original',original->'figure_index','multiplication_movement_capability_id',original->'movement_capability_id')
          ||CASE WHEN original ? 'assault_draw' THEN jsonb_build_object('multiplication_assault_draw',original->'assault_draw') ELSE '{}'::jsonb END,choice_ordinal)::combat_panel_private.choice_options);
        choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(original_group)::text],to_jsonb(choice_ordinal+1),true);
       ELSE
        PERFORM combat_panel_private.add_choice(original_group,'Figura '||(original->>'figure_index')||CASE WHEN original->>'target_distance_m' IS NOT NULL THEN ' · termina a '||(original->>'target_distance_m')||' m' ELSE ' · spostamento '||round((original->>'distance_m')::numeric,2)||' m' END,
         jsonb_build_object('multiplication_original',original->'figure_index','multiplication_movement_capability_id',original->'movement_capability_id')
          ||CASE WHEN original ? 'assault_draw' THEN jsonb_build_object('multiplication_assault_draw',original->'assault_draw') ELSE '{}'::jsonb END,
         (original->>'distance_m')::numeric);
       END IF;
     END LOOP;
   END LOOP;
 END LOOP;
 IF optimized_batch THEN
 -- Native same-offer dependency FK is DEFERRABLE INITIALLY DEFERRED.
 -- All new parent groups exist before inserting their options; no constraint is disabled.
 INSERT INTO combat_panel_private.choice_groups(id,offer_id,label,selection_mode,purpose,min_selected,max_selected,depends_on,ordinal)
  SELECT r.id,r.offer_id,r.label,r.selection_mode,r.purpose,r.min_selected,r.max_selected,r.depends_on,r.ordinal
  FROM unnest(staged_groups) r;
 INSERT INTO combat_panel_private.choice_options(id,offer_id,group_id,label,distance_m,direction,source_payload,ordinal)
  SELECT r.id,r.offer_id,r.group_id,r.label,r.distance_m,r.direction,r.source_payload,r.ordinal
  FROM unnest(staged_options) r;
 END IF;
END $function$;

CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_layout_options_for_figure(p_actor uuid, p_copies integer, p_mode text, p_target uuid, p_formation uuid, p_version bigint, p_index integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; b combat_spatial.actor_states%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE; template combat_spatial.arena_templates%ROWTYPE;
 target_x numeric; target_y numeric; target_geometry jsonb; profile jsonb; budget jsonb; remaining numeric;
 direction record; rid uuid; figures jsonb; figure jsonb; available jsonb; layouts jsonb:='[]'::jsonb;
 bound jsonb:='[]'::jsonb; layout jsonb; option_row jsonb; native jsonb;
 reuse_target_geometry boolean:=false;valid boolean; can_move boolean; x numeric; y numeric; d numeric; target_radius numeric; target_gap numeric; key text; prefix text; cid uuid;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 IF num_nonnulls(p_formation,p_version,p_index) NOT IN (0,3)
   OR (p_formation IS NOT NULL AND p_mode NOT IN ('assalto','copertura')) THEN
   RAISE EXCEPTION 'panel_multiplication_target_selection_invalid' USING ERRCODE='22023'; END IF;
 IF p_mode IS NULL OR p_mode NOT IN ('diversivo','copertura','assalto')
   OR (p_mode IN ('assalto','copertura')) IS DISTINCT FROM (p_target IS NOT NULL) THEN
   RAISE EXCEPTION 'panel_multiplication_mode_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal()
   AND companion_id IS NULL AND state='attivo';
 reuse_target_geometry:=combat_panel_private.multiplication_tactics_allowed(a.id);
 IF p_mode<>'assalto' AND NOT reuse_target_geometry THEN RETURN layouts; END IF;
 profile:=combat_panel_private.multiplication_actor_profile(a.id);
 IF profile IS NULL OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(profile->'copy_options') WHERE (value->>'copies')::integer=p_copies) THEN RETURN layouts; END IF;
 rid:=(profile->>'round_id')::uuid;
 PERFORM public.combat_v2_lock_round(rid);
 profile:=combat_panel_private.multiplication_actor_profile(a.id);
 IF profile IS NULL OR profile->>'round_id' IS DISTINCT FROM rid::text
   OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(profile->'copy_options') WHERE (value->>'copies')::integer=p_copies) THEN RETURN layouts; END IF;
 SELECT * INTO STRICT i FROM combat_spatial.arena_instances WHERE encounter_id=a.session_id AND state='open' FOR UPDATE;
 SELECT * INTO STRICT b FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id AND state='active';
 IF b.controller_principal_id IS DISTINCT FROM exam_regia_private.current_principal() OR NOT combat_panel_private.shared_movement_scope(i.instance_id) THEN
   RAISE EXCEPTION 'panel_multiplication_controller_stale' USING ERRCODE='40001'; END IF;
 SELECT * INTO STRICT template FROM combat_spatial.arena_templates WHERE template_key=i.template_key AND template_version=i.template_version;
 budget:=combat_panel_private.movement_budget(a.id,(profile->>'round_id')::uuid);remaining:=(budget->>'remaining_m')::numeric;
 can_move:=remaining>0 AND (budget->>'spent_m')::numeric=0 AND combat_panel_private.movement_block_reason(a.id) IS NULL;
 IF p_mode IN ('assalto','copertura') THEN
   IF NOT EXISTS(SELECT 1 FROM public.combat_v2_actors t WHERE t.id=p_target AND t.session_id=a.session_id AND t.state='attivo' AND t.team_key<>a.team_key)
     OR ((NOT reuse_target_geometry OR p_formation IS NULL)
      AND NOT combat_panel_private.body_visible_to_viewer(i.instance_id,p_target)) THEN RETURN layouts; END IF;
   -- Released formed-target geometry below verifies canonical visibility once.
   -- Scopes not admitted by the existing Tactics gate keep legacy helper calls.
   IF p_formation IS NOT NULL THEN
     IF NOT EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations f
       WHERE f.id=p_formation AND f.actor_id=p_target AND f.state='active' AND f.state_version=p_version
         AND f.mode IN ('copertura','diversivo','assalto')) THEN RETURN layouts; END IF;
     IF reuse_target_geometry THEN
     target_geometry:=combat_panel_private.multiplication_target_geometry(a.id,p_target);
     IF target_geometry IS NULL THEN
       -- Preserve invisible -> no layout, and visible stale -> 40001.
       IF NOT combat_panel_private.body_visible_to_viewer(i.instance_id,p_target) THEN RETURN layouts; END IF;
       RAISE EXCEPTION 'panel_multiplication_target_stale' USING ERRCODE='40001';
     END IF;
     IF target_geometry->>'formation_id' IS DISTINCT FROM p_formation::text
       OR target_geometry->>'state_version' IS DISTINCT FROM p_version::text THEN
       RAISE EXCEPTION 'panel_multiplication_target_stale' USING ERRCODE='40001';END IF;
     SELECT value INTO figure FROM jsonb_array_elements(target_geometry->'figures')
       WHERE (value->>'figure_index')::integer=p_index;
     IF figure IS NULL THEN RAISE EXCEPTION 'panel_multiplication_target_figure_invalid' USING ERRCODE='22023';END IF;
     target_geometry:=(target_geometry-'figures')||jsonb_build_object('figure',figure);
     ELSE
     target_geometry:=combat_panel_private.multiplication_target_figure(a.id,p_target,p_formation,p_version,p_index);
     END IF;
     target_x:=(target_geometry#>>'{figure,x_m}')::numeric;target_y:=(target_geometry#>>'{figure,y_m}')::numeric;
   ELSE
     IF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=p_target AND state='active') THEN RETURN layouts; END IF;
     SELECT tb.x_m,tb.y_m INTO STRICT target_x,target_y FROM combat_spatial.actor_states tb
       WHERE tb.instance_id=i.instance_id AND tb.actor_id=p_target AND tb.state='active';
   END IF;
   SELECT footprint_radius_m INTO STRICT target_radius FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=p_target AND state='active';
 END IF;
 IF p_mode='assalto' THEN
  -- Scope congelato: niente movimento+Assalto verso una copia distante.
  -- Le figure gia' nella portata fisica attuale restano selezionabili.
  IF p_formation IS NOT NULL
    AND (target_x-b.x_m)^2+(target_y-b.y_m)^2>(b.footprint_radius_m+target_radius+2)^2 THEN
   RETURN '[]'::jsonb;
  END IF;
  RETURN combat_panel_private.multiplication_assault_endpoint_layouts(i.instance_id,a.id,p_target,
   target_x,target_y,target_radius,CASE WHEN can_move THEN least(remaining,5) ELSE 0 END,
   'assalto:'||rid||':'||coalesce(p_formation::text,'-')||':'||coalesce(p_version,0)||':'||coalesce(p_index,0),
   p_copies,(profile->>'copy_cap')::integer);
 END IF;
 prefix:='multiplication:'||(profile->>'round_id')||':'||b.body_version||':'||remaining||':';
 IF p_mode='copertura' THEN
  prefix:='multiplication-cover:'||p_target||':'||coalesce(p_formation::text,'-')||':'||coalesce(p_version,0)||':'||coalesce(p_index,0)
    ||':'||(profile->>'round_id')||':'||b.body_version||':'||remaining||':';
 END IF;
 FOR direction IN SELECT * FROM (VALUES(1,0,'right'),(-1,0,'left'),(0,1,'down'),(0,-1,'up')) x(dx,dy,label) LOOP
  -- Le copie possono disporsi entro5m anche se il corpo resta fermo e non ha budget.
  FOR extent IN 1..(CASE WHEN can_move THEN greatest(5,floor(remaining)::integer) ELSE 5 END) LOOP
   figures:=combat_panel_private.multiplication_line_figures(b.x_m,b.y_m,direction.dx,direction.dy,extent,p_copies);
   available:='[]'::jsonb;valid:=true;
   FOR figure IN SELECT value FROM jsonb_array_elements(figures) LOOP
    x:=(figure->>'x_m')::numeric;y:=(figure->>'y_m')::numeric;d:=combat_spatial.distance_m(b.x_m,b.y_m,x,y);
    IF x NOT BETWEEN b.footprint_radius_m AND template.width_m-b.footprint_radius_m
      OR y NOT BETWEEN b.footprint_radius_m AND template.height_m-b.footprint_radius_m
      OR (d>0 AND combat_spatial.path_first_block_t(i.instance_id,a.id,b.x_m,b.y_m,x,y)<1) THEN valid:=false;EXIT; END IF;
    -- Ratifica08/09: a0m soltanto la figura coincidente con il corpo attuale.
    IF d>0 AND (NOT can_move OR d>remaining) THEN CONTINUE; END IF;
    IF p_mode='copertura' AND (d<>5
      OR (x-b.x_m)*(target_x-b.x_m)+(y-b.y_m)*(target_y-b.y_m)>=0
      OR combat_spatial.distance_m(x,y,target_x,target_y)<=combat_spatial.distance_m(b.x_m,b.y_m,target_x,target_y)) THEN CONTINUE; END IF;
    IF p_mode='assalto' AND (round(greatest(0,combat_spatial.distance_m(x,y,target_x,target_y)-b.footprint_radius_m-target_radius),8) NOT IN (0,1,2)
      OR (x-b.x_m)*(target_x-b.x_m)+(y-b.y_m)*(target_y-b.y_m)<0
      OR (target_x-x)*(target_x-b.x_m)+(target_y-y)*(target_y-b.y_m)<0
      OR combat_spatial.path_first_block_t(i.instance_id,a.id,x,y,target_x,target_y,p_target)<1) THEN CONTINUE; END IF;
    key:=prefix||md5(jsonb_build_object('x',x,'y',y)::text);
    target_gap:=CASE WHEN p_mode='assalto' THEN round(greatest(0,combat_spatial.distance_m(x,y,target_x,target_y)-b.footprint_radius_m-target_radius),8) ELSE NULL END;
    available:=available||jsonb_build_array(jsonb_build_object('figure_index',figure->'figure_index','choice_key',key,'distance_m',d,'target_distance_m',target_gap,'x_m',x,'y_m',y));
   END LOOP;
   IF valid AND jsonb_array_length(available)>0 THEN
    layouts:=layouts||jsonb_build_array(jsonb_build_object('direction',direction.label,'extent_m',extent,'figures',figures,'original_options',available));
    FOR option_row IN SELECT value FROM jsonb_array_elements(available) LOOP
     IF (option_row->>'distance_m')::numeric=0 THEN CONTINUE; END IF;
     INSERT INTO combat_spatial.movement_semantic_choices(instance_id,actor_id,choice_key,endpoint_x_m,endpoint_y_m,max_budget_m,choice_version,enabled)
      VALUES(i.instance_id,a.id,option_row->>'choice_key',(option_row->>'x_m')::numeric,(option_row->>'y_m')::numeric,remaining,1,true)
      ON CONFLICT(instance_id,actor_id,choice_key) DO NOTHING;
    END LOOP;
   END IF;
  END LOOP;
 END LOOP;
 IF jsonb_array_length(layouts)=0 THEN RETURN layouts; END IF;
 -- Una sola chiamata nativa per questa combinazione, non una per figura.
 native:='[]'::jsonb;
 IF can_move AND EXISTS(SELECT 1 FROM jsonb_array_elements(layouts) l
   CROSS JOIN LATERAL jsonb_array_elements(l->'original_options') o WHERE (o->>'distance_m')::numeric>0) THEN
   native:=combat_spatial.movement_options(i.instance_id,a.id,remaining); END IF;
 FOR layout IN SELECT value FROM jsonb_array_elements(layouts) LOOP
  available:='[]'::jsonb;
  FOR option_row IN SELECT value FROM jsonb_array_elements(layout->'original_options') LOOP
   IF (option_row->>'distance_m')::numeric=0 THEN
     IF ((option_row->>'x_m')::numeric,(option_row->>'y_m')::numeric) IS DISTINCT FROM (b.x_m,b.y_m) THEN
       RAISE EXCEPTION 'panel_multiplication_stationary_original_invalid' USING ERRCODE='22023'; END IF;
     available:=available||jsonb_build_array(jsonb_build_object('figure_index',option_row->'figure_index',
       'distance_m',0,'movement_capability_id',NULL));
     CONTINUE;
   END IF;
   cid:=NULL;
   SELECT c.capability_id INTO cid FROM combat_spatial.movement_capabilities c
    WHERE c.instance_id=i.instance_id AND c.actor_id=a.id AND c.choice_key=option_row->>'choice_key'
     AND c.actor_body_version=b.body_version AND c.map_version=i.map_version AND c.state='offered'
     AND c.end_x_m=(option_row->>'x_m')::numeric AND c.end_y_m=(option_row->>'y_m')::numeric
     AND EXISTS(SELECT 1 FROM jsonb_array_elements(native) WHERE value->>'option_id'=c.capability_id::text);
   IF cid IS NOT NULL THEN available:=available||jsonb_build_array(jsonb_build_object('figure_index',option_row->'figure_index',
      'distance_m',option_row->'distance_m','target_distance_m',option_row->'target_distance_m','movement_capability_id',cid)); END IF;
  END LOOP;
  IF jsonb_array_length(available)>0 THEN bound:=bound||jsonb_build_array(jsonb_set(layout,'{original_options}',available)); END IF;
 END LOOP;
 RETURN bound;
END $function$;

-- SOURCE ONLY: exact derived seal metadata member, integrated after the five qualified functional DDL.
-- No arbitrary expected SHA. Old code/ABI/CAS are fixed; new member is derived from the already-qualified actor's actual normalized DDL.
DO $eligibility_seal_pre$ BEGIN
 IF NOT coalesce((SELECT jsonb_build_object('oid',p.oid::bigint,'signature',replace(n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')',' ',''),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,'volatility',p.provolatile::text,
 'parallel',p.proparallel::text,'strict',p.proisstrict,'leakproof',p.proleakproof,'arg_types',p.proargtypes::text,'all_arg_types',to_jsonb(p.proallargtypes),
 'arg_names',to_jsonb(p.proargnames),'arg_modes',to_jsonb(p.proargmodes),'nargs',p.pronargs,'default_arg_count',p.pronargdefaults,
 'defaults',pg_get_expr(p.proargdefaults,0),'return_oid',p.prorettype::text,'returns_set',p.proretset,'variadic_type',p.provariadic::text,
 'arguments',pg_get_function_arguments(p.oid),'returns',pg_get_function_result(p.oid),'language',l.lanname,
 'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc))
 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=41419)='{"oid":41419,"signature":"clan_innata_private.eligibility_release_assert()","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=pg_catalog, public, clan_innata_private"],"prosecdef":true,"volatility":"s","parallel":"u","strict":false,"leakproof":false,"arg_types":"","all_arg_types":null,"arg_names":null,"arg_modes":null,"nargs":0,"default_arg_count":0,"defaults":null,"return_oid":"2278","returns_set":false,"variadic_type":"0","arguments":"","returns":"void","language":"plpgsql","ddl_md5":"8de6ce1265be1420cc2e89479a8bac98","source_md5":"0c3c825c5b71f775ca7dc51f2ebdbf85"}'::jsonb,false)THEN RAISE EXCEPTION 'ELIGIBILITY_SEAL_BASELINE_CAS';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef(41419),'UTF8'),'sha256'),'hex')<>'1fbfe144883e6ecbe40c59d74c7c30ff347cb49ccda3f17e876a157921a7d993' THEN RAISE EXCEPTION 'ELIGIBILITY_SEAL_BASELINE_FULL_SHA';END IF;
END $eligibility_seal_pre$;
DO $eligibility_seal_derive$
DECLARE before_ddl text;before_src text;actor_sha text;after_ddl text;after_src text;
BEGIN
 IF NOT coalesce((SELECT jsonb_build_object('oid',p.oid::bigint,'signature',replace(n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')',' ',''),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,'volatility',p.provolatile::text,
 'parallel',p.proparallel::text,'strict',p.proisstrict,'leakproof',p.proleakproof,'arg_types',p.proargtypes::text,'all_arg_types',to_jsonb(p.proallargtypes),
 'arg_names',to_jsonb(p.proargnames),'arg_modes',to_jsonb(p.proargmodes),'nargs',p.pronargs,'default_arg_count',p.pronargdefaults,
 'defaults',pg_get_expr(p.proargdefaults,0),'return_oid',p.prorettype::text,'returns_set',p.proretset,'variadic_type',p.provariadic::text,
 'arguments',pg_get_function_arguments(p.oid),'returns',pg_get_function_result(p.oid),'language',l.lanname,
 'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc))
 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=41419)='{"oid":41419,"signature":"clan_innata_private.eligibility_release_assert()","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=pg_catalog, public, clan_innata_private"],"prosecdef":true,"volatility":"s","parallel":"u","strict":false,"leakproof":false,"arg_types":"","all_arg_types":null,"arg_names":null,"arg_modes":null,"nargs":0,"default_arg_count":0,"defaults":null,"return_oid":"2278","returns_set":false,"variadic_type":"0","arguments":"","returns":"void","language":"plpgsql","ddl_md5":"8de6ce1265be1420cc2e89479a8bac98","source_md5":"0c3c825c5b71f775ca7dc51f2ebdbf85"}'::jsonb,false)THEN RAISE EXCEPTION 'ELIGIBILITY_SEAL_BASELINE_CAS';END IF;
 IF NOT coalesce((SELECT jsonb_build_object('oid',p.oid::bigint,'signature',replace(n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')',' ',''),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,'volatility',p.provolatile::text,
 'parallel',p.proparallel::text,'strict',p.proisstrict,'leakproof',p.proleakproof,'arg_types',p.proargtypes::text,'all_arg_types',to_jsonb(p.proallargtypes),
 'arg_names',to_jsonb(p.proargnames),'arg_modes',to_jsonb(p.proargmodes),'nargs',p.pronargs,'default_arg_count',p.pronargdefaults,
 'defaults',pg_get_expr(p.proargdefaults,0),'return_oid',p.prorettype::text,'returns_set',p.proretset,'variadic_type',p.provariadic::text,
 'arguments',pg_get_function_arguments(p.oid),'returns',pg_get_function_result(p.oid),'language',l.lanname,
 'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc))
 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=31311)-'ddl_md5'='{"oid":31311,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"volatility":"s","parallel":"u","strict":false,"leakproof":false,"arg_types":"2950 25 2950 16","all_arg_types":null,"arg_names":["p_actor","p_source","p_ability","p_defense"],"arg_modes":null,"nargs":4,"default_arg_count":1,"defaults":"false","return_oid":"3802","returns_set":false,"variadic_type":"0","arguments":"p_actor uuid, p_source text, p_ability uuid, p_defense boolean DEFAULT false","returns":"jsonb","language":"sql","source_md5":"b6180f3bc0d3ec90d2c18dac3c6f54e8"}'::jsonb,false)THEN RAISE EXCEPTION 'ELIGIBILITY_ACTOR_APPROVED_SOURCE_ABI_REQUIRED';END IF;
 SELECT pg_get_functiondef(p.oid),p.prosrc INTO STRICT before_ddl,before_src FROM pg_proc p WHERE p.oid=41419;
 IF encode(extensions.digest(convert_to(before_ddl,'UTF8'),'sha256'),'hex')<>'1fbfe144883e6ecbe40c59d74c7c30ff347cb49ccda3f17e876a157921a7d993'
 OR(length(before_ddl)-length(replace(before_ddl,'b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a','')))/64<>1
 OR(length(before_src)-length(replace(before_src,'b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a','')))/64<>1 THEN RAISE EXCEPTION 'ELIGIBILITY_SEAL_PROVENANCE';END IF;
 actor_sha:=encode(extensions.digest(convert_to(pg_get_functiondef(31311),'UTF8'),'sha256'),'hex');
 IF actor_sha!~'^[0-9a-f]{64}$'OR actor_sha='b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a' THEN RAISE EXCEPTION 'ELIGIBILITY_DERIVED_ACTOR_MEMBER_INVALID';END IF;
 EXECUTE replace(before_ddl,'b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a',actor_sha);
 SELECT pg_get_functiondef(p.oid),p.prosrc INTO STRICT after_ddl,after_src FROM pg_proc p WHERE p.oid=41419;
 IF after_ddl IS DISTINCT FROM replace(before_ddl,'b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a',actor_sha)
 OR after_src IS DISTINCT FROM replace(before_src,'b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a',actor_sha)
 OR((SELECT jsonb_build_object('oid',p.oid::bigint,'signature',replace(n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')',' ',''),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,'volatility',p.provolatile::text,
 'parallel',p.proparallel::text,'strict',p.proisstrict,'leakproof',p.proleakproof,'arg_types',p.proargtypes::text,'all_arg_types',to_jsonb(p.proallargtypes),
 'arg_names',to_jsonb(p.proargnames),'arg_modes',to_jsonb(p.proargmodes),'nargs',p.pronargs,'default_arg_count',p.pronargdefaults,
 'defaults',pg_get_expr(p.proargdefaults,0),'return_oid',p.prorettype::text,'returns_set',p.proretset,'variadic_type',p.provariadic::text,
 'arguments',pg_get_function_arguments(p.oid),'returns',pg_get_function_result(p.oid),'language',l.lanname,
 'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc))
 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=41419)-ARRAY['ddl_md5','source_md5'])IS DISTINCT FROM('{"oid":41419,"signature":"clan_innata_private.eligibility_release_assert()","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=pg_catalog, public, clan_innata_private"],"prosecdef":true,"volatility":"s","parallel":"u","strict":false,"leakproof":false,"arg_types":"","all_arg_types":null,"arg_names":null,"arg_modes":null,"nargs":0,"default_arg_count":0,"defaults":null,"return_oid":"2278","returns_set":false,"variadic_type":"0","arguments":"","returns":"void","language":"plpgsql","ddl_md5":"8de6ce1265be1420cc2e89479a8bac98","source_md5":"0c3c825c5b71f775ca7dc51f2ebdbf85"}'::jsonb-ARRAY['ddl_md5','source_md5'])
 THEN RAISE EXCEPTION 'ELIGIBILITY_SEAL_EXACT_SUBSTITUTION_REQUIRED';END IF;
END $eligibility_seal_derive$;
