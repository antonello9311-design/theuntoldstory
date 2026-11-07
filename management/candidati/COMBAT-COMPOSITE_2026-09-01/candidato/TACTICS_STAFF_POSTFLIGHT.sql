WITH targets(signature,expected_source_md5,old_ddl_md5,contract,expected_oid) AS(VALUES
('clan_innata_narrative_private.fenice_staff_proof_v1(uuid)','6ebcfee584480f0b6129789e631044d6',NULL,'{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "s"}'::jsonb,NULL),
('clan_innata_narrative_private.staff_profile_bind_v1(uuid,uuid)','547bdbb6bda2165fa7a29e798491825b','492484888b32bd02c453a604c77a2e15','{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "v"}'::jsonb,'665885'),
('clan_innata_private.eligibility_release_assert()',md5(replace('
declare v_marionetta boolean:=false; v_panel boolean:=false;
begin

 -- La porta pubblica aggiornata è ammessa solo insieme al suo producer
 -- originale privato e alla redazione esatta: corpi, autorità e ACL pinzati.
 with expected(sig,sha,acl) as(values (''public.combat_v2_round_options(uuid,uuid)'',''0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1'',''authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false''),(''combat_panel_private.round_options_authoritative(uuid,uuid)'',''879b5d69f1ca6a8f9cc28421699b77d649e3e277f4130a40308ca3acfc8a895c'',''postgres:EXECUTE:false''),(''combat_panel_private.mask_native_state(jsonb)'',''1d2f6ad44b2ff1e9c15d897e38fee54b67c744411081f906bc33a26a42600dac'',''postgres:EXECUTE:false'')),
 observed as(select e.*,p.oid,p.proowner,p.prosecdef,p.proconfig,
   case when p.oid is null then null else encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),''UTF8''),''sha256''),''hex'') end actual_sha,
   (select string_agg(coalesce(r.rolname,''PUBLIC'')||'':''||x.privilege_type||'':''||x.is_grantable,'','' order by coalesce(r.rolname,''PUBLIC''),x.privilege_type,x.is_grantable)
     from aclexplode(coalesce(p.proacl,acldefault(''f'',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl
   from expected e left join pg_proc p on p.oid=to_regprocedure(e.sig))
 select count(*)=3 and bool_and(coalesce(oid is not null and actual_sha=sha and actual_acl=acl
   and proowner=''postgres''::regrole and prosecdef and proconfig=array[''search_path=""''],false))
 into v_panel from observed;
 if exists(select 1 from supabase_migrations.schema_migrations where name=''marionetta_ordinary_staff_001'' or version=''20260907084651'') then
   if (select count(*) from supabase_migrations.schema_migrations where name=''marionetta_ordinary_staff_001'' or version=''20260907084651'')<>1
     or not exists(select 1 from supabase_migrations.schema_migrations where version=''20260907084651'' and name=''marionetta_ordinary_staff_001''
       and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''''),''UTF8''),''sha256''),''hex'')=''3d3b6643c1b513728ee8e2366fbde983aa374cf9d330f0976d71c5f122318f17'') then
     raise exception ''runtime_eligibility_marionetta_release_drift''; end if;
   v_marionetta:=true;
 end if;
 if (select count(*) from supabase_migrations.schema_migrations where version=''20260902055751'' and name=''genin_elemental_eligibility_common_009'' and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''''),''UTF8''),''sha256''),''hex'')=''e2ca4e296401307496cdc1ed108f4cf22ee4469a34072172c7b9855063a97c2e'')<>1
 or (select count(*) from supabase_migrations.schema_migrations where version between ''20260902005704'' and ''20260902055751'')<>4
 or (select count(*) from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'')>1
 or ((select count(*) from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'')=0 and ((select count(*) from supabase_migrations.schema_migrations)<>452 or (select version from supabase_migrations.schema_migrations order by version desc limit 1) is distinct from ''20260902055751''))
 or ((select count(*) from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'')=1 and not exists(select 1 from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'' and version~''^[0-9]{14}$'' and version>''20260902055751'' and cardinality(statements)=1))
 then raise exception ''runtime_eligibility_history_drift'';end if;
 if to_regnamespace(''combat_v2_elemental_internal'') is null
 or (select count(*) from pg_proc p where p.pronamespace=''combat_v2_elemental_internal''::regnamespace)<>91
 or (select pg_get_userbyid(n.nspowner)||''|''||coalesce(n.nspacl::text,'''') from pg_namespace n where n.oid=''combat_v2_elemental_internal''::regnamespace) is distinct from ''postgres|{postgres=UC/postgres,service_role=U/postgres}''
 then raise exception ''runtime_eligibility_schema_drift'';end if;

 -- Rilascio Suiton verificato: insieme chiuso di 35 helper aggiuntivi.
 -- I due helper storici mantengono le verifiche originali sottostanti.
 if (select count(*) from supabase_migrations.schema_migrations
     where version=''20260912191445'' and name=''elementali_staff_suiton_install_20260912_1912''
       and cardinality(statements)=1
       and encode(extensions.digest(convert_to(array_to_string(statements,''''),''UTF8''),''sha256''),''hex'')=''e7bd1cb6dea7505399fc9dbce5b39ec5078eb9474f55990def7502a68fbbdb18'')<>1
 then raise exception ''runtime_eligibility_suiton_release_drift'';end if;
 if exists(
  with expected(sig,sha,definer) as(values
   (''combat_v2_elemental_internal.comparison_channels(uuid,uuid,uuid,jsonb,integer,uuid)'', ''4db77777b8277750fb1468b8789915facbf71864d81f2647dedad6a0d40f26f8'', true),
   (''combat_v2_elemental_internal.comparison_reserve(uuid,uuid,uuid)'', ''712095a7757a2828bed68307408edba803169e8465b1f31b62e3b408b04749df'', true),
   (''combat_v2_elemental_internal.suiton_ability_meta(uuid,jsonb)'', ''8856c83e2aac23fbac02b3fa893caf0f0809234bf8a7ff42aeac6b246db14838'', true),
   (''combat_v2_elemental_internal.suiton_bind_source(uuid)'', ''1fd85f165e897d3e90ddb0f04bc2c5523b73587f26d1037e0ab45635ac1208f5'', true),
   (''combat_v2_elemental_internal.suiton_commit_control(jsonb,jsonb)'', ''aca8de9ce4d1caf737ea789d11aeb5de4e8a55be2840f4700eb0daaa8b5357dc'', true),
   (''combat_v2_elemental_internal.suiton_commit_master_control(jsonb)'', ''8e3dc679cced28892d6270a5310d49b975b9da9e483cfff635140db331e0e43d'', true),
   (''combat_v2_elemental_internal.suiton_consumer_options(jsonb)'', ''82231c040ab41b619f29616499fad90e6d6efebfc614bebe67e8b91c82081ca5'', true),
   (''combat_v2_elemental_internal.suiton_control_apply(text,uuid,uuid,uuid)'', ''15c8ce32ece8af8c407bac7e46fbbb414184fd87bfb3e1238a3b4e461f43ba39'', true),
   (''combat_v2_elemental_internal.suiton_control_target(text,uuid,uuid)'', ''83833b6ff5f114c3b870c3767565d00ea829bbf85f02606f034e197e4c37ab03'', true),
   (''combat_v2_elemental_internal.suiton_declaration_meta(uuid,uuid,uuid,jsonb)'', ''7b13ed2ad7acc320c88350a5ec0fd2d9155614f51b5ea6682094e88e6bfbba36'', true),
   (''combat_v2_elemental_internal.suiton_draw_range(uuid,uuid,boolean)'', ''b178d00a882a8e2cff719795874d1a553e4478f0369ef6eb5a9ed4e20ccb71f4'', true),
   (''combat_v2_elemental_internal.suiton_force_from_outcome(uuid,uuid)'', ''aa3b68e633cc12f401505a6ba3492e92e94c44598940bf90e7c70473e90ca7f0'', true),
   (''combat_v2_elemental_internal.suiton_geometry(uuid,uuid,boolean)'', ''422ce58f19b0c0d9692fbf639f409f54b45d054b6c3f01e580b8be1f43222288'', true),
   (''combat_v2_elemental_internal.suiton_master_options(uuid,bigint)'', ''a2359c02aaeb2192ecef01fae57d05f6fb548d0c245380494915427341499d5f'', true),
   (''combat_v2_elemental_internal.suiton_meta(uuid)'', ''65375ebe226f598927e0873b228d0daaa9f239249f6b2e9196ad4ae5a2282f7b'', true),
   (''combat_v2_elemental_internal.suiton_narrative_facts(uuid)'', ''b6936b0bd08eee059ae94cffcdd3c2e7319b3aa6f7430e38a91bfc088cd49901'', true),
   (''combat_v2_elemental_internal.suiton_narrative_projection(uuid)'', ''d34e9dc4d467ab47f8a263d837b8f00d6f0f3f02c7b59d1b4063ce1aa7022276'', true),
   (''combat_v2_elemental_internal.suiton_narrative_supported(uuid)'', ''660838edb1eef2ba8afbab180edf21ec295170aa36b0122e163fc17c59f42a48'', true),
   (''combat_v2_elemental_internal.suiton_offer_label(uuid,jsonb,text)'', ''71ef19352a96939de8a8034cc821f79326a0d33eb0fa4c673a4aabe6f8aa1fe0'', true),
   (''combat_v2_elemental_internal.suiton_ordinary_copy_offers(uuid,bigint,jsonb)'', ''3392390a180bee9b10b58495a32d889d05da52cfdec5611c47c7769599fbaef5'', true),
   (''combat_v2_elemental_internal.suiton_png_owned(uuid,uuid)'', ''b2d3877e7497adbdc4a76139d2627ac0744b192a0823d54dbc90afaabf6bd659'', true),
   (''combat_v2_elemental_internal.suiton_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)'', ''973b09c57a37f9721e216f8dfd4b1e0dbfc29d80c8cb4615a175603366e36c87'', true),
   (''combat_v2_elemental_internal.suiton_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)'', ''9ef708a90471da085ffb0d804f31a010f021ce227d43b40060ecd8e7cb707b12'', true),
   (''combat_v2_elemental_internal.suiton_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)'', ''1b5986868ba2679c2ebd8dbf824a22cee4190ec4c0e17852d089ab8093e78655'', true),
   (''combat_v2_elemental_internal.suiton_prepare_ordinary(uuid,uuid,uuid)'', ''b3c5628855bd2c213c268d209219559a362c67f399133e15186eaf3e78497ad3'', true),
   (''combat_v2_elemental_internal.suiton_preset_ready(uuid,uuid)'', ''c65ac30e5d1b1a8bf88ee73e636a15da683f9ae3f97c124ae9b5b9199a386ec7'', true),
   (''combat_v2_elemental_internal.suiton_profile(uuid,uuid)'', ''f8174ccbe1808bedc756e452c4fb8cf7cd9f9f6629fe627ed473b36d516a65c6'', true),
   (''combat_v2_elemental_internal.suiton_quote(uuid,uuid)'', ''900157dfaaf19810d4d21a4138a9a63c77ae6cc460d0d296425556a6efa653a1'', true),
   (''combat_v2_elemental_internal.suiton_source_valid(uuid)'', ''d937562a6537b70bf92233e0f3a3182ff346a93c7a586d73139febe7370d5969'', true),
   (''combat_v2_elemental_internal.suiton_staff_bind(uuid,uuid,uuid)'', ''09bcc66bf8d7cf5e5f04f41cc6b071841a6472d9cf45d750f789d679fdf3a576'', true),
   (''combat_v2_elemental_internal.suiton_staff_binding(uuid,uuid)'', ''fbbf2c198e245b92424046ed58bc79c7b2d4ff440e82722ab90187de89d20152'', true),
   (''combat_v2_elemental_internal.suiton_substitution_available(uuid)'', ''7535c6c3c7366a23e22f697c5eb20bf8e3cd422208909881ab32327106b5ee1a'', true),
   (''combat_v2_elemental_internal.suiton_substitution_options(jsonb)'', ''3d07b691098cdf4b698ed8822ab4c554de722a90d586b917dad59a0131fe3aaa'', true),
   (''combat_v2_elemental_internal.suiton_target_visible(uuid,uuid,numeric)'', ''5eff813391e64689028888e8449b89abcf2486601428e72c5917e59ffb72769d'', true),
   (''combat_v2_elemental_internal.technique_profile_v1(uuid)'', ''6446b74bbe092d8627820dc064d778aaf188eec6c7dd28e79e985843b995bd93'', false)),
  observed as(select e.*,p.oid,p.proowner,p.prosecdef,p.proconfig,
   case when p.oid is null then null else encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),''UTF8''),''sha256''),''hex'') end actual_sha,
   (select string_agg(coalesce(r.rolname,''PUBLIC'')||'':''||x.privilege_type||'':''||x.is_grantable,'','' order by coalesce(r.rolname,''PUBLIC''),x.privilege_type,x.is_grantable)
    from aclexplode(coalesce(p.proacl,acldefault(''f'',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl
   from expected e left join pg_proc p on p.oid=to_regprocedure(e.sig))
  select 1 from observed where oid is null or actual_sha is distinct from sha
   or proowner is distinct from ''postgres''::regrole or prosecdef is distinct from definer
   or proconfig is distinct from array[''search_path=""'']
   or actual_acl is distinct from ''postgres:EXECUTE:false''
 ) then raise exception ''runtime_eligibility_suiton_helper_drift'';end if;

 if exists(
  with expected(sig,sha,acl) as(values
   (''combat_v2_elemental_internal.is_target_v1(uuid)'',''8af6bdfc87b76ed118b596f7c7885c6de849c5d89140f61cdd1845047cbd5724'',''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''combat_v2_elemental_internal.eligible_v1(uuid,uuid,boolean)'',''a5161f2993a4e0ce51864ac67ea88ba3fa6966457da1caf4ca390f17c2b1d8e9'',''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''public.combat_v2_character_snapshot(uuid)'',case when v_marionetta then ''20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3'' else ''323d6dd5a1cfac2ad6535fb73a4aefb03d33c7aa2894b9196489c17880046f87'' end,''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''public.combat_v2_actor_ability(uuid,text,uuid,boolean)'',''b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a'',''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''public.combat_v2_round_options(uuid,uuid)'',case when v_panel then ''0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1'' when v_marionetta then ''6b9012a057baa9bc06b201ce6bcc5b8d8bb4a832ae9a462444c5e3ef55e0c8cb'' else ''3be90b0da7f02c826ffdfcd594d2132a4af9128291e3417278ad6adac88f6129'' end,''authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false'')),
  observed as(select e.*,encode(extensions.digest(convert_to(pg_get_functiondef(e.sig::regprocedure),''UTF8''),''sha256''),''hex'') actual_sha,p.proowner,p.prosecdef,p.proconfig,(select string_agg(coalesce(r.rolname,''PUBLIC'')||'':''||x.privilege_type||'':''||x.is_grantable,'','' order by coalesce(r.rolname,''PUBLIC''),x.privilege_type,x.is_grantable) from aclexplode(coalesce(p.proacl,acldefault(''f'',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl from expected e join pg_proc p on p.oid=e.sig::regprocedure)
  select 1 from observed where actual_sha is distinct from sha or actual_acl is distinct from acl or proowner<>''postgres''::regrole or not prosecdef or proconfig is distinct from array[''search_path=""''])
 then raise exception ''runtime_eligibility_full_seal_drift'';end if;
 if encode(extensions.digest(convert_to(pg_get_functiondef(''public.character_elementi(uuid)''::regprocedure),''UTF8''),''sha256''),''hex'') is distinct from ''2e62fad3aa654ab452c516549ca82068dd33f6496a3c1e17e3a8c805a8ddacd7''
 then raise exception ''runtime_eligibility_character_elementi_drift'';end if;

 IF EXISTS(WITH expected(sig,hash,sd) AS (VALUES (''combat_v2_elemental_internal.other_meta(uuid)'',''18a6130387a81b22c993feaaf2613612'',true),(''combat_v2_elemental_internal.other_staff_binding(uuid,uuid)'',''cb15a27f82e60cf2ace2f22de4ca1e73'',true),(''combat_v2_elemental_internal.other_png_owned(uuid,uuid)'',''1730fa382f3f2da21b05ba43e1876330'',true),(''combat_v2_elemental_internal.other_profile(uuid,uuid)'',''f71b7422e1af07cfb2784137d5d05f03'',true),(''combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)'',''07a3babec6e05865d9265b09c22d0859'',true),(''combat_v2_elemental_internal.other_staff_bind(uuid,uuid,uuid)'',''a4fb778f33ab73c31e63904f51299985'',true),(''combat_v2_elemental_internal.other_geometry(uuid,uuid,pg_catalog.bool)'',''8776c899d5534308eb256de2ba451ae8'',true),(''combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,pg_catalog.bool,jsonb)'',''0e93d6425a2e8a151765040279758310'',true),(''combat_v2_elemental_internal.other_declaration_meta(uuid,uuid,uuid,jsonb)'',''d37f38beb455ecfbcda7a63962013542'',true),(''combat_v2_elemental_internal.other_bind_source(uuid)'',''35714da91f1df0f2d90d5921099e1177'',true),(''combat_v2_elemental_internal.other_source_valid(uuid)'',''20b96bb421f4bfbd3eb74a33294a3080'',true),(''combat_v2_elemental_internal.other_prepare_ordinary(uuid,uuid,uuid)'',''bb260ba226bc3557058820bdd5cacc93'',true),(''combat_v2_elemental_internal.other_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)'',''1159e41bd29afbed0f8a5e828a0a79de'',true),(''combat_v2_elemental_internal.other_preset_ready(uuid,uuid)'',''eda00ca66bd5e24d1ac8cd1e620bf9c4'',true),(''combat_v2_elemental_internal.other_quote(uuid,uuid)'',''d50b47aedacd9734f5561067a3d62ba8'',true),(''combat_v2_elemental_internal.other_target_visible(uuid,uuid,pg_catalog.numeric)'',''f4440fc78dec1369349183c0957b1d1e'',true),(''combat_v2_elemental_internal.other_offer_label(uuid,jsonb,text)'',''4d40c4838291ae873d83ee544a4b0044'',true),(''combat_v2_elemental_internal.other_draw_range(uuid,uuid,pg_catalog.bool)'',''4856b88270f39cc66a656ec4a679d8d3'',true),(''combat_v2_elemental_internal.other_substitution_available(uuid)'',''a89a389d107dc8ad30a007f25ef1981a'',true),(''combat_v2_elemental_internal.other_substitution_options(jsonb)'',''5c08c47feed36d8c9c7f2d44f2ab9309'',true),(''combat_v2_elemental_internal.other_consumer_options(jsonb)'',''204fe2a77ba4c45cc862113859836151'',true),(''combat_v2_elemental_internal.other_ordinary_copy_offers(uuid,pg_catalog.int8,jsonb)'',''00bec9479f3d07cac011cc6139e27ad1'',true),(''combat_v2_elemental_internal.other_master_options(uuid,pg_catalog.int8)'',''13cd420ffe7d757af62bc723f27ce8b3'',true),(''combat_v2_elemental_internal.other_control_target(text,uuid,uuid)'',''b811c5e103dd67321aa8a2e3c601efbf'',true),(''combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)'',''63e4716e93d126611ca0490fe218fc57'',true),(''combat_v2_elemental_internal.other_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)'',''44d80129a84b21ab9345adfb4864736f'',true),(''combat_v2_elemental_internal.other_commit_control(jsonb,jsonb)'',''21538535df526b17d42dc91c7a3d4013'',true),(''combat_v2_elemental_internal.other_commit_master_control(jsonb)'',''c1690a97d6d6398360a401098588e56a'',true),(''combat_v2_elemental_internal.other_comparison(uuid,uuid,jsonb,pg_catalog.int4)'',''3b918a70932e681e148f7a90028f2d1c'',true),(''combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid)'',''429727092531f7f07cfa99e06c7808d6'',true),(''combat_v2_elemental_internal.other_narrative_supported(uuid)'',''4a0d496f8d0528005aa3309ed60e3d0b'',true),(''combat_v2_elemental_internal.other_narrative_projection(uuid)'',''8ff935d763f4e4aeac25c3d6d017ecd3'',true),(''combat_v2_elemental_internal.scudo_profile(uuid)'',''92cfb95b3f56d8249d56c7d574e38d26'',true),(''combat_v2_elemental_internal.scudo_prepare_defense(uuid,uuid,uuid,uuid,uuid,jsonb)'',''b5808b034b5a3bcf50b7bcb8336d212a'',true),(''combat_v2_elemental_internal.scudo_declaration_meta(uuid,uuid,uuid,uuid,jsonb)'',''c27749ce44a439b3d59361a59e2337e9'',true),(''combat_v2_elemental_internal.scudo_bind_source(uuid)'',''cb840b147ea888fbfa57e3e55be49697'',true),(''combat_v2_elemental_internal.scudo_source_valid(uuid)'',''eacac569a8408d9e081344eebe12f9e2'',true),(''combat_v2_elemental_internal.scudo_meta(uuid)'',''92d3214d9de700399b263d1ee9ba8f93'',true),(''combat_v2_elemental_internal.scudo_staff_binding(uuid,uuid)'',''bf78d306e9a024a88ab453b9e8317671'',true),(''combat_v2_elemental_internal.scudo_staff_bind(uuid,uuid,uuid)'',''5f0c851bc78380fd88f246ca65fdb7fe'',true),(''combat_v2_elemental_internal.scudo_preset_ready(uuid,uuid)'',''b822c5fd7f3b549d455bbbcbe9e985c5'',true),(''combat_v2_elemental_internal.scudo_control_target(text,uuid,uuid)'',''014ec28c115fd3712b43d4253ffc39a9'',true),(''combat_v2_elemental_internal.scudo_control_apply(text,uuid,uuid,uuid)'',''2730009defb70b8c045be6430f496967'',true),(''combat_v2_elemental_internal.scudo_commit_control(jsonb,jsonb)'',''8b86c31c9d637aeb01beeb1c2fa2d1e7'',true),(''combat_v2_elemental_internal.scudo_commit_master_control(jsonb)'',''9bde876c7796180ea80bea206fe5829f'',true),(''combat_v2_elemental_internal.scudo_ability_meta(uuid,jsonb)'',''029b589a7af1a873e58cd3435bee3343'',true),(''combat_v2_elemental_internal.scudo_quote(uuid)'',''5c768cd419a7166e6e23420d5af3164b'',true),(''combat_v2_elemental_internal.scudo_consumer_options(jsonb)'',''e84aa35091f26367645f35a8815c78b1'',true),(''combat_v2_elemental_internal.scudo_master_options(uuid,pg_catalog.int8)'',''33fb2ed8a14cb05a3414e7be89556659'',true),(''combat_v2_elemental_internal.scudo_prepare_native(uuid,uuid,uuid,uuid,jsonb)'',''df51b64ad4443f0acdde37fbfdd5284e'',true),(''combat_v2_elemental_internal.scudo_narrative(uuid)'',''c580ef1cdbaff1598a7863603aa5c9a3'',true),(''combat_v2_elemental_internal.scarica_contact_range(uuid,uuid)'',''f92feff3bb5167ba034931dcb3832f4e'',true),(''combat_v2_elemental_internal.scarica_contact_witness(uuid,uuid,uuid,uuid)'',''34fb9bc5836831510ebd6e300e60a408'',true),(''combat_v2_elemental_internal.scarica_source_contact_valid(uuid)'',''57ed0bac1c1d36d8fd259010ceab4538'',true)) SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) WHERE p.oid IS NULL OR md5(p.prosrc) IS DISTINCT FROM e.hash OR p.prosecdef IS DISTINCT FROM e.sd OR p.proowner IS DISTINCT FROM ''postgres''::regrole OR p.proconfig IS DISTINCT FROM ARRAY[''search_path=""''] OR p.proacl IS DISTINCT FROM ''{postgres=X/postgres}''::aclitem[]) THEN RAISE EXCEPTION ''runtime_elemental_complete_helper_drift'';END IF;
end ','b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a',encode(extensions.digest(convert_to(pg_get_functiondef('public.combat_v2_actor_ability(uuid,text,uuid,boolean)'::regprocedure),'UTF8'),'sha256'),'hex'))),'8de6ce1265be1420cc2e89479a8bac98','{"acl": "{postgres=X/postgres}", "nargs": 0, "owner": "postgres", "config": ["search_path=pg_catalog, public, clan_innata_private"], "secdef": true, "strict": false, "defaults": null, "language": "plpgsql", "parallel": "u", "arg_modes": null, "arg_names": null, "arg_types": "", "leakproof": false, "return_oid": "2278", "volatility": "s", "returns_set": false, "variadic_type": "0", "default_arg_count": 0}'::jsonb,'41419'),
('combat_panel_private.multiplication_add_layout_groups(uuid,uuid,jsonb)','a7b90e33513fff4685afb46a21e57b8f','f2515609aa9a224d7f2ff542a3f503c1','{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "v"}'::jsonb,'45632'),
('combat_panel_private.multiplication_layout_options_for_figure(uuid,integer,text,uuid,uuid,bigint,integer)','3e4184f1bfe0bafe5cde44b08e552b1a','7b36f3d868c85c3941f120844c286dd9','{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "v"}'::jsonb,'45714'),
('public.combat_v2_actor_ability(uuid,text,uuid,boolean)','b6180f3bc0d3ec90d2c18dac3c6f54e8','ec79a59f561042dee9eac224926afe28','{"acl": "{postgres=X/postgres,service_role=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "sql", "parallel": "u", "leakproof": false, "volatility": "s"}'::jsonb,'31311')),
fn AS MATERIALIZED(
 SELECT t.signature,t.expected_source_md5,t.old_ddl_md5,t.contract,t.expected_oid,p.*,n.nspname,l.lanname,
 pg_get_functiondef(p.oid) actual_ddl,pg_get_userbyid(p.proowner) function_owner
 FROM targets t JOIN pg_proc p ON p.oid=to_regprocedure(t.signature)
 JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang),
headers AS MATERIALIZED(
 SELECT signature,expected_source_md5,old_ddl_md5,contract,expected_oid,
 jsonb_build_object('signature',signature,'oid',oid::text,'nspname',nspname,'proname',proname,'kind',prokind::text,
 'owner',function_owner,'acl',proacl::text,'language',lanname,'config',to_jsonb(proconfig),'secdef',prosecdef,
 'volatility',provolatile::text,'parallel',proparallel::text,'strict',proisstrict,'leakproof',proleakproof,
 'arg_types',proargtypes::text,'all_arg_types',to_jsonb(proallargtypes),'arg_modes',to_jsonb(proargmodes),'arg_names',to_jsonb(proargnames),
 'nargs',pronargs,'default_arg_count',pronargdefaults,'defaults',pg_get_expr(proargdefaults,0),
 'variadic_type',provariadic::text,'return_oid',prorettype::text,'returns_set',proretset,
 'arguments',pg_get_function_arguments(oid),'returns',pg_get_function_result(oid),
 'ddl_md5',md5(actual_ddl),'source_md5',md5(prosrc),'ddl_sha256',encode(extensions.digest(convert_to(actual_ddl,'UTF8'),'sha256'),'hex'),
 'source_sha256',encode(extensions.digest(convert_to(prosrc,'UTF8'),'sha256'),'hex'),
 'ddl_bytes',octet_length(actual_ddl),'source_bytes',octet_length(prosrc))h
 FROM fn),
guard AS MATERIALIZED(
 SELECT count(*)=6 AND bool_and(h->>'source_md5'=expected_source_md5 AND h @> contract
 AND(expected_oid IS NULL OR h->>'oid'=expected_oid)
 AND(old_ddl_md5 IS NULL OR h->>'ddl_md5'<>old_ddl_md5))ok FROM headers),
bundle AS MATERIALIZED(
 SELECT jsonb_build_object('schema_version','tactics-staff-function-proof/1','functions',jsonb_agg(h ORDER BY signature))full_header_manifest,
 jsonb_object_agg(signature,h) target_bodies_after FROM headers HAVING count(*)=6),
witness AS MATERIALIZED(
 SELECT b.*,jsonb_build_object('sha256',public.combat_v2_sha256(full_header_manifest),'source_sha256','70532b3233ce24e12d18396eacb02e71db5a215df46f6ef88f60160a71384cca')compact
 FROM bundle b CROSS JOIN guard g WHERE g.ok) SELECT jsonb_build_object('root_revision',r.revision_sha256,'observed_root',r.observed_revision_sha256,'root_sha256',public.combat_v2_sha256(r.canonical_preimage::jsonb),'root_bytes',octet_length(r.canonical_preimage),'compact',r.canonical_preimage::jsonb#>'{db_core,tactics_staff}','calculated_compact',w.compact,'full_header_manifest',w.full_header_manifest,'target_bodies_after',w.target_bodies_after,'bundle_matches',w.compact=r.canonical_preimage::jsonb#>'{db_core,tactics_staff}') AS postflight FROM witness w CROSS JOIN mission_factory_owner.editor_release_readiness r WHERE r.singleton;
