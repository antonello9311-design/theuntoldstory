BEGIN;
SELECT pg_catalog.set_config('app.elemental_label_binding_parameters',$elemental_binding_reviewed${"schema_version":"elemental-label-binding-parameters/1","mode":"source","source_bundle_sha256":"9c4b9872165bb35f3e6bc7e76aaca86dd060882dab855d71cc7b31e6e230ae68","expected_current":{"root_sha256":"2aebd274863581ff276348776a4cc487cfe1971b06983bde6723ea6bdbc5efc6","root_row_sha256":"5df208dc572677a65788a9d674e9a9aed8e4e608dcda86c29d7a9a2470ffdaa0","root_bytes":523105,"db_sha256":"d15c092eef93c9081224b3cf8697159b7ce4ba4a1a48ea58f2190c770923440c"},"expected_content_admission_rows_sha256":"74c9a5a1ce644c82a1e5333fc221fa08e569caf9695fcad4dbc91fb008ed4bdc","baseline_custody":{"ref":"ELEMENTAL_LABEL_BINDING_AUDIT.json#baseline","sha256":"2aebd274863581ff276348776a4cc487cfe1971b06983bde6723ea6bdbc5efc6"},"compatibility":{"scope":"existing_mission_capabilities_only","new_techniques_staff_pass":false,"ref":"ELEMENTAL_LABEL_BINDING_AUDIT.json#mission_compatibility","sha256":"4a1e214a3799904d4306da0291d8b74ce000e2699b025f018ed4f7bd554eac24"},"review":{"ref":"ELEMENTAL_LABEL_BINDING_REVIEW.json#R1","sha256":"30155e71bf96ea514cfa30af4c5b4fd7418633280c21ed08f2dd843c49017bbb","P0":0,"P1":0,"P2":0}}$elemental_binding_reviewed$,true);
DO $binding_pre$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;p jsonb;f jsonb;
BEGIN
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL THEN RAISE EXCEPTION 'ELEMENTAL_LABEL_BINDING_OPERATOR_REQUIRED';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN RAISE EXCEPTION 'ELEMENTAL_LABEL_BINDING_AVAILABILITY_BUSY';END IF;
 PERFORM set_config('app.cure_reaction_paralisi_gate_before',(SELECT to_jsonb(g)::text FROM combat_v2_genjutsu_internal.gate g WHERE singleton),true);
 PERFORM set_config('app.cure_reaction_cure_gate_before',(SELECT to_jsonb(g)::text FROM combat_panel_private.cure_gate_v1 g WHERE singleton),true);
 p:=nullif(current_setting('app.elemental_label_binding_parameters',true),'')::jsonb;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF p->>'mode' IS DISTINCT FROM 'source' OR rr.revision_sha256 IS DISTINCT FROM '2aebd274863581ff276348776a4cc487cfe1971b06983bde6723ea6bdbc5efc6'
 OR public.combat_v2_sha256(to_jsonb(rr)) IS DISTINCT FROM '5df208dc572677a65788a9d674e9a9aed8e4e608dcda86c29d7a9a2470ffdaa0'
 THEN RAISE EXCEPTION 'ELEMENTAL_LABEL_BINDING_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN('preparazione','in_corso','sospeso'))
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND suspended_at IS NULL) THEN RAISE EXCEPTION 'ELEMENTAL_LABEL_BINDING_REQUIRES_QUIESCENCE';END IF;
 FOR f IN SELECT value FROM jsonb_array_elements($binding_pins$[{"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"250e7511806ab0fe07b6bf24b2a1770a","ddl_sha256":"f3fa5fb40b8a83d422a1b1692e7d667b8b036b93224826bd39cbb4d932c14cda"},{"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"e52a8ac90fb15cad425cd0d17c9b4d4b","ddl_sha256":"72141f00f7b6c79aacf634334290e92debbcc3a5bd77365c55dc4ef3a82ea5f6"},{"signature":"clan_innata_private.runtime_release_assert()","source_md5":"6b9ed7edc3ea365017e1f5e84200ed79","ddl_sha256":"220301a349fe8d8d59717f82f84b9b5785c21acf0e8bd965682be6f85e513a38"},{"signature":"combat_panel_private.cure_contact_v1(uuid,uuid)","source_md5":"21de7dd5e62b5403b50065d2635e20bf","ddl_sha256":"0d5ef7dfd803fadfc2ec38aa4285467cd95f83bb613e6c0b6a0dde650d571f00"},{"signature":"combat_panel_private.master_projection(uuid,uuid)","source_md5":"271ea56acb5f135ad6e3d24d8601e3b1","ddl_sha256":"da26a20b86b168b4769b851405794371ddbe54095c1e8c775859c0b1c155cd0b"},{"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"7cf9d8be18c9dab5f75b62c74a5e9e37","ddl_sha256":"22bd8c8faf60ba44a644bf9ccd0f69ab8a5715383c79ff6014509dfd02290554"},{"signature":"combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)","source_md5":"aa3d6fe2cb785a3a132a7b281bdab70a","ddl_sha256":"15fab8ec94575b4a0e163cfbdcc46272b02d47d772daa262de5483a43b18f5ac"}]$binding_pins$::jsonb) LOOP
  IF md5((SELECT prosrc FROM pg_proc WHERE oid=to_regprocedure(f->>'signature'))) IS DISTINCT FROM f->>'source_md5'
   OR encode(extensions.digest(convert_to(pg_get_functiondef(to_regprocedure(f->>'signature')),'UTF8'),'sha256'),'hex') IS DISTINCT FROM f->>'ddl_sha256'
  THEN RAISE EXCEPTION 'ELEMENTAL_LABEL_BINDING_BODY_DRIFT:%',f->>'signature';END IF;
 END LOOP;
END $binding_pre$;
CREATE OR REPLACE FUNCTION clan_innata_private.eligibility_release_assert()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'clan_innata_private'
AS $function$
declare v_marionetta boolean:=false; v_panel boolean:=false; v_catalogo boolean:=false;
begin
 v_catalogo:=clan_innata_private.catalogo_eligibility_release_v1();

 -- La porta pubblica aggiornata è ammessa solo insieme al suo producer
 -- originale privato e alla redazione esatta: corpi, autorità e ACL pinzati.
 with expected(sig,sha,acl) as(values ('public.combat_v2_round_options(uuid,uuid)','0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1','authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false'),('combat_panel_private.round_options_authoritative(uuid,uuid)','879b5d69f1ca6a8f9cc28421699b77d649e3e277f4130a40308ca3acfc8a895c','postgres:EXECUTE:false'),('combat_panel_private.mask_native_state(jsonb)','1d2f6ad44b2ff1e9c15d897e38fee54b67c744411081f906bc33a26a42600dac','postgres:EXECUTE:false')),
 observed as(select e.*,p.oid,p.proowner,p.prosecdef,p.proconfig,
   case when p.oid is null then null else encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex') end actual_sha,
   (select string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,',' order by coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable)
     from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl
   from expected e left join pg_proc p on p.oid=to_regprocedure(e.sig))
 select count(*)=3 and bool_and(coalesce(oid is not null and actual_sha=sha and actual_acl=acl
   and proowner='postgres'::regrole and prosecdef and proconfig=array['search_path=""'],false))
 into v_panel from observed;
 IF v_catalogo THEN v_panel:=true;END IF;
 if exists(select 1 from supabase_migrations.schema_migrations where name='marionetta_ordinary_staff_001' or version='20260907084651') then
   if (select count(*) from supabase_migrations.schema_migrations where name='marionetta_ordinary_staff_001' or version='20260907084651')<>1
     or not exists(select 1 from supabase_migrations.schema_migrations where version='20260907084651' and name='marionetta_ordinary_staff_001'
       and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''),'UTF8'),'sha256'),'hex')='3d3b6643c1b513728ee8e2366fbde983aa374cf9d330f0976d71c5f122318f17') then
     raise exception 'runtime_eligibility_marionetta_release_drift'; end if;
   v_marionetta:=true;
 end if;
 if (select count(*) from supabase_migrations.schema_migrations where version='20260902055751' and name='genin_elemental_eligibility_common_009' and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''),'UTF8'),'sha256'),'hex')='e2ca4e296401307496cdc1ed108f4cf22ee4469a34072172c7b9855063a97c2e')<>1
 or (select count(*) from supabase_migrations.schema_migrations where version between '20260902005704' and '20260902055751')<>4
 or (select count(*) from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018')>1
 or ((select count(*) from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018')=0 and ((select count(*) from supabase_migrations.schema_migrations)<>452 or (select version from supabase_migrations.schema_migrations order by version desc limit 1) is distinct from '20260902055751'))
 or ((select count(*) from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018')=1 and not exists(select 1 from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018' and version~'^[0-9]{14}$' and version>'20260902055751' and cardinality(statements)=1))
 then raise exception 'runtime_eligibility_history_drift';end if;
 if to_regnamespace('combat_v2_elemental_internal') is null
 or (select count(*) from pg_proc p where p.pronamespace='combat_v2_elemental_internal'::regnamespace)<>91
 or (select pg_get_userbyid(n.nspowner)||'|'||coalesce(n.nspacl::text,'') from pg_namespace n where n.oid='combat_v2_elemental_internal'::regnamespace) is distinct from 'postgres|{postgres=UC/postgres,service_role=U/postgres}'
 then raise exception 'runtime_eligibility_schema_drift';end if;

 -- Rilascio Suiton verificato: insieme chiuso di 35 helper aggiuntivi.
 -- I due helper storici mantengono le verifiche originali sottostanti.
 if (select count(*) from supabase_migrations.schema_migrations
     where version='20260912191445' and name='elementali_staff_suiton_install_20260912_1912'
       and cardinality(statements)=1
       and encode(extensions.digest(convert_to(array_to_string(statements,''),'UTF8'),'sha256'),'hex')='e7bd1cb6dea7505399fc9dbce5b39ec5078eb9474f55990def7502a68fbbdb18')<>1
 then raise exception 'runtime_eligibility_suiton_release_drift';end if;
 if exists(
  with expected(sig,sha,definer) as(values
   ('combat_v2_elemental_internal.comparison_channels(uuid,uuid,uuid,jsonb,integer,uuid)', '4db77777b8277750fb1468b8789915facbf71864d81f2647dedad6a0d40f26f8', true),
   ('combat_v2_elemental_internal.comparison_reserve(uuid,uuid,uuid)', '712095a7757a2828bed68307408edba803169e8465b1f31b62e3b408b04749df', true),
   ('combat_v2_elemental_internal.suiton_ability_meta(uuid,jsonb)', '8856c83e2aac23fbac02b3fa893caf0f0809234bf8a7ff42aeac6b246db14838', true),
   ('combat_v2_elemental_internal.suiton_bind_source(uuid)', '1fd85f165e897d3e90ddb0f04bc2c5523b73587f26d1037e0ab45635ac1208f5', true),
   ('combat_v2_elemental_internal.suiton_commit_control(jsonb,jsonb)', 'aca8de9ce4d1caf737ea789d11aeb5de4e8a55be2840f4700eb0daaa8b5357dc', true),
   ('combat_v2_elemental_internal.suiton_commit_master_control(jsonb)', '8e3dc679cced28892d6270a5310d49b975b9da9e483cfff635140db331e0e43d', true),
   ('combat_v2_elemental_internal.suiton_consumer_options(jsonb)', '82231c040ab41b619f29616499fad90e6d6efebfc614bebe67e8b91c82081ca5', true),
   ('combat_v2_elemental_internal.suiton_control_apply(text,uuid,uuid,uuid)', '15c8ce32ece8af8c407bac7e46fbbb414184fd87bfb3e1238a3b4e461f43ba39', true),
   ('combat_v2_elemental_internal.suiton_control_target(text,uuid,uuid)', '83833b6ff5f114c3b870c3767565d00ea829bbf85f02606f034e197e4c37ab03', true),
   ('combat_v2_elemental_internal.suiton_declaration_meta(uuid,uuid,uuid,jsonb)', '7b13ed2ad7acc320c88350a5ec0fd2d9155614f51b5ea6682094e88e6bfbba36', true),
   ('combat_v2_elemental_internal.suiton_draw_range(uuid,uuid,boolean)', 'b178d00a882a8e2cff719795874d1a553e4478f0369ef6eb5a9ed4e20ccb71f4', true),
   ('combat_v2_elemental_internal.suiton_force_from_outcome(uuid,uuid)', 'aa3b68e633cc12f401505a6ba3492e92e94c44598940bf90e7c70473e90ca7f0', true),
   ('combat_v2_elemental_internal.suiton_geometry(uuid,uuid,boolean)', '422ce58f19b0c0d9692fbf639f409f54b45d054b6c3f01e580b8be1f43222288', true),
   ('combat_v2_elemental_internal.suiton_master_options(uuid,bigint)', 'a2359c02aaeb2192ecef01fae57d05f6fb548d0c245380494915427341499d5f', true),
   ('combat_v2_elemental_internal.suiton_meta(uuid)', '65375ebe226f598927e0873b228d0daaa9f239249f6b2e9196ad4ae5a2282f7b', true),
   ('combat_v2_elemental_internal.suiton_narrative_facts(uuid)', 'b6936b0bd08eee059ae94cffcdd3c2e7319b3aa6f7430e38a91bfc088cd49901', true),
   ('combat_v2_elemental_internal.suiton_narrative_projection(uuid)', 'd34e9dc4d467ab47f8a263d837b8f00d6f0f3f02c7b59d1b4063ce1aa7022276', true),
   ('combat_v2_elemental_internal.suiton_narrative_supported(uuid)', '660838edb1eef2ba8afbab180edf21ec295170aa36b0122e163fc17c59f42a48', true),
   ('combat_v2_elemental_internal.suiton_offer_label(uuid,jsonb,text)', '71ef19352a96939de8a8034cc821f79326a0d33eb0fa4c673a4aabe6f8aa1fe0', true),
   ('combat_v2_elemental_internal.suiton_ordinary_copy_offers(uuid,bigint,jsonb)', '3392390a180bee9b10b58495a32d889d05da52cfdec5611c47c7769599fbaef5', true),
   ('combat_v2_elemental_internal.suiton_png_owned(uuid,uuid)', 'b2d3877e7497adbdc4a76139d2627ac0744b192a0823d54dbc90afaabf6bd659', true),
   ('combat_v2_elemental_internal.suiton_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)', '973b09c57a37f9721e216f8dfd4b1e0dbfc29d80c8cb4615a175603366e36c87', true),
   ('combat_v2_elemental_internal.suiton_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)', '9ef708a90471da085ffb0d804f31a010f021ce227d43b40060ecd8e7cb707b12', true),
   ('combat_v2_elemental_internal.suiton_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)', '1b5986868ba2679c2ebd8dbf824a22cee4190ec4c0e17852d089ab8093e78655', true),
   ('combat_v2_elemental_internal.suiton_prepare_ordinary(uuid,uuid,uuid)', 'b3c5628855bd2c213c268d209219559a362c67f399133e15186eaf3e78497ad3', true),
   ('combat_v2_elemental_internal.suiton_preset_ready(uuid,uuid)', 'c65ac30e5d1b1a8bf88ee73e636a15da683f9ae3f97c124ae9b5b9199a386ec7', true),
   ('combat_v2_elemental_internal.suiton_profile(uuid,uuid)', 'f8174ccbe1808bedc756e452c4fb8cf7cd9f9f6629fe627ed473b36d516a65c6', true),
   ('combat_v2_elemental_internal.suiton_quote(uuid,uuid)', '900157dfaaf19810d4d21a4138a9a63c77ae6cc460d0d296425556a6efa653a1', true),
   ('combat_v2_elemental_internal.suiton_source_valid(uuid)', 'd937562a6537b70bf92233e0f3a3182ff346a93c7a586d73139febe7370d5969', true),
   ('combat_v2_elemental_internal.suiton_staff_bind(uuid,uuid,uuid)', '09bcc66bf8d7cf5e5f04f41cc6b071841a6472d9cf45d750f789d679fdf3a576', true),
   ('combat_v2_elemental_internal.suiton_staff_binding(uuid,uuid)', 'fbbf2c198e245b92424046ed58bc79c7b2d4ff440e82722ab90187de89d20152', true),
   ('combat_v2_elemental_internal.suiton_substitution_available(uuid)', '7535c6c3c7366a23e22f697c5eb20bf8e3cd422208909881ab32327106b5ee1a', true),
   ('combat_v2_elemental_internal.suiton_substitution_options(jsonb)', '3d07b691098cdf4b698ed8822ab4c554de722a90d586b917dad59a0131fe3aaa', true),
   ('combat_v2_elemental_internal.suiton_target_visible(uuid,uuid,numeric)', '5eff813391e64689028888e8449b89abcf2486601428e72c5917e59ffb72769d', true),
   ('combat_v2_elemental_internal.technique_profile_v1(uuid)', '6446b74bbe092d8627820dc064d778aaf188eec6c7dd28e79e985843b995bd93', false)),
  observed as(select e.*,p.oid,p.proowner,p.prosecdef,p.proconfig,
   case when p.oid is null then null else encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex') end actual_sha,
   (select string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,',' order by coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable)
    from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl
   from expected e left join pg_proc p on p.oid=to_regprocedure(e.sig))
  select 1 from observed where oid is null or actual_sha is distinct from sha
   or proowner is distinct from 'postgres'::regrole or prosecdef is distinct from definer
   or proconfig is distinct from array['search_path=""']
   or actual_acl is distinct from 'postgres:EXECUTE:false'
 ) then raise exception 'runtime_eligibility_suiton_helper_drift';end if;

 if exists(
  with expected(sig,sha,acl) as(values
   ('combat_v2_elemental_internal.is_target_v1(uuid)','8af6bdfc87b76ed118b596f7c7885c6de849c5d89140f61cdd1845047cbd5724','postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('combat_v2_elemental_internal.eligible_v1(uuid,uuid,boolean)','a5161f2993a4e0ce51864ac67ea88ba3fa6966457da1caf4ca390f17c2b1d8e9','postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_character_snapshot(uuid)',case when v_marionetta then '20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3' else '323d6dd5a1cfac2ad6535fb73a4aefb03d33c7aa2894b9196489c17880046f87' end,'postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_actor_ability(uuid,text,uuid,boolean)',CASE WHEN v_catalogo THEN '3f86b9972ead72801b6a4c392d2b180d011ca2605075855cd21a59b848f665e4' ELSE 'cb9e81c2b23aedb968eafa00f15dc3de188e57a5e72f04805a2d0617934575a7'END,'postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_round_options(uuid,uuid)',case when v_panel then '0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1' when v_marionetta then '6b9012a057baa9bc06b201ce6bcc5b8d8bb4a832ae9a462444c5e3ef55e0c8cb' else '3be90b0da7f02c826ffdfcd594d2132a4af9128291e3417278ad6adac88f6129' end,'authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false')),
  observed as(select e.*,encode(extensions.digest(convert_to(pg_get_functiondef(e.sig::regprocedure),'UTF8'),'sha256'),'hex') actual_sha,p.proowner,p.prosecdef,p.proconfig,(select string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,',' order by coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable) from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl from expected e join pg_proc p on p.oid=e.sig::regprocedure)
  select 1 from observed where actual_sha is distinct from sha or actual_acl is distinct from acl or proowner<>'postgres'::regrole or not prosecdef or proconfig is distinct from array['search_path=""'])
 then raise exception 'runtime_eligibility_full_seal_drift';end if;
 if encode(extensions.digest(convert_to(pg_get_functiondef('public.character_elementi(uuid)'::regprocedure),'UTF8'),'sha256'),'hex') is distinct from '2e62fad3aa654ab452c516549ca82068dd33f6496a3c1e17e3a8c805a8ddacd7'
 then raise exception 'runtime_eligibility_character_elementi_drift';end if;

 IF EXISTS(WITH expected(sig,hash,sd) AS (VALUES ('combat_v2_elemental_internal.other_meta(uuid)','18a6130387a81b22c993feaaf2613612',true),('combat_v2_elemental_internal.other_staff_binding(uuid,uuid)','cb15a27f82e60cf2ace2f22de4ca1e73',true),('combat_v2_elemental_internal.other_png_owned(uuid,uuid)','1730fa382f3f2da21b05ba43e1876330',true),('combat_v2_elemental_internal.other_profile(uuid,uuid)',CASE WHEN v_catalogo THEN 'dd1e62e9052469fae4c98fed245c730a' ELSE 'f71b7422e1af07cfb2784137d5d05f03'END,true),('combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)',CASE WHEN v_catalogo THEN 'aa3d6fe2cb785a3a132a7b281bdab70a' ELSE '07a3babec6e05865d9265b09c22d0859' END,true),('combat_v2_elemental_internal.other_staff_bind(uuid,uuid,uuid)','a4fb778f33ab73c31e63904f51299985',true),('combat_v2_elemental_internal.other_geometry(uuid,uuid,pg_catalog.bool)','8776c899d5534308eb256de2ba451ae8',true),('combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,pg_catalog.bool,jsonb)',CASE WHEN v_catalogo THEN '6e54b476b36ca716cf8c14f33ef9667e' ELSE '0e93d6425a2e8a151765040279758310'END,true),('combat_v2_elemental_internal.other_declaration_meta(uuid,uuid,uuid,jsonb)','d37f38beb455ecfbcda7a63962013542',true),('combat_v2_elemental_internal.other_bind_source(uuid)','35714da91f1df0f2d90d5921099e1177',true),('combat_v2_elemental_internal.other_source_valid(uuid)','20b96bb421f4bfbd3eb74a33294a3080',true),('combat_v2_elemental_internal.other_prepare_ordinary(uuid,uuid,uuid)','bb260ba226bc3557058820bdd5cacc93',true),('combat_v2_elemental_internal.other_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)','1159e41bd29afbed0f8a5e828a0a79de',true),('combat_v2_elemental_internal.other_preset_ready(uuid,uuid)','eda00ca66bd5e24d1ac8cd1e620bf9c4',true),('combat_v2_elemental_internal.other_quote(uuid,uuid)','d50b47aedacd9734f5561067a3d62ba8',true),('combat_v2_elemental_internal.other_target_visible(uuid,uuid,pg_catalog.numeric)','f4440fc78dec1369349183c0957b1d1e',true),('combat_v2_elemental_internal.other_offer_label(uuid,jsonb,text)','4d40c4838291ae873d83ee544a4b0044',true),('combat_v2_elemental_internal.other_draw_range(uuid,uuid,pg_catalog.bool)','4856b88270f39cc66a656ec4a679d8d3',true),('combat_v2_elemental_internal.other_substitution_available(uuid)','a89a389d107dc8ad30a007f25ef1981a',true),('combat_v2_elemental_internal.other_substitution_options(jsonb)','5c08c47feed36d8c9c7f2d44f2ab9309',true),('combat_v2_elemental_internal.other_consumer_options(jsonb)',CASE WHEN v_catalogo THEN '8423c49ce8a83f2b19361b82a53fa9f4' ELSE '204fe2a77ba4c45cc862113859836151'END,true),('combat_v2_elemental_internal.other_ordinary_copy_offers(uuid,pg_catalog.int8,jsonb)','00bec9479f3d07cac011cc6139e27ad1',true),('combat_v2_elemental_internal.other_master_options(uuid,pg_catalog.int8)',CASE WHEN v_catalogo THEN '0c79a6a78b76b9e9ef8028d75e514af7' ELSE '13cd420ffe7d757af62bc723f27ce8b3'END,true),('combat_v2_elemental_internal.other_control_target(text,uuid,uuid)',CASE WHEN v_catalogo THEN 'b1af00f3eab38ed9e74836c5441616d7' ELSE 'b811c5e103dd67321aa8a2e3c601efbf'END,true),('combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)',CASE WHEN v_catalogo THEN '4cf97ca72ff52f1bd33445ba54c8dd16' ELSE '63e4716e93d126611ca0490fe218fc57'END,true),('combat_v2_elemental_internal.other_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)','44d80129a84b21ab9345adfb4864736f',true),('combat_v2_elemental_internal.other_commit_control(jsonb,jsonb)','21538535df526b17d42dc91c7a3d4013',true),('combat_v2_elemental_internal.other_commit_master_control(jsonb)','c1690a97d6d6398360a401098588e56a',true),('combat_v2_elemental_internal.other_comparison(uuid,uuid,jsonb,pg_catalog.int4)','3b918a70932e681e148f7a90028f2d1c',true),('combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid)','429727092531f7f07cfa99e06c7808d6',true),('combat_v2_elemental_internal.other_narrative_supported(uuid)','4a0d496f8d0528005aa3309ed60e3d0b',true),('combat_v2_elemental_internal.other_narrative_projection(uuid)','8ff935d763f4e4aeac25c3d6d017ecd3',true),('combat_v2_elemental_internal.scudo_profile(uuid)','92cfb95b3f56d8249d56c7d574e38d26',true),('combat_v2_elemental_internal.scudo_prepare_defense(uuid,uuid,uuid,uuid,uuid,jsonb)','b5808b034b5a3bcf50b7bcb8336d212a',true),('combat_v2_elemental_internal.scudo_declaration_meta(uuid,uuid,uuid,uuid,jsonb)','c27749ce44a439b3d59361a59e2337e9',true),('combat_v2_elemental_internal.scudo_bind_source(uuid)','cb840b147ea888fbfa57e3e55be49697',true),('combat_v2_elemental_internal.scudo_source_valid(uuid)','eacac569a8408d9e081344eebe12f9e2',true),('combat_v2_elemental_internal.scudo_meta(uuid)','92d3214d9de700399b263d1ee9ba8f93',true),('combat_v2_elemental_internal.scudo_staff_binding(uuid,uuid)','bf78d306e9a024a88ab453b9e8317671',true),('combat_v2_elemental_internal.scudo_staff_bind(uuid,uuid,uuid)','5f0c851bc78380fd88f246ca65fdb7fe',true),('combat_v2_elemental_internal.scudo_preset_ready(uuid,uuid)','b822c5fd7f3b549d455bbbcbe9e985c5',true),('combat_v2_elemental_internal.scudo_control_target(text,uuid,uuid)','014ec28c115fd3712b43d4253ffc39a9',true),('combat_v2_elemental_internal.scudo_control_apply(text,uuid,uuid,uuid)','2730009defb70b8c045be6430f496967',true),('combat_v2_elemental_internal.scudo_commit_control(jsonb,jsonb)','8b86c31c9d637aeb01beeb1c2fa2d1e7',true),('combat_v2_elemental_internal.scudo_commit_master_control(jsonb)','9bde876c7796180ea80bea206fe5829f',true),('combat_v2_elemental_internal.scudo_ability_meta(uuid,jsonb)','029b589a7af1a873e58cd3435bee3343',true),('combat_v2_elemental_internal.scudo_quote(uuid)','5c768cd419a7166e6e23420d5af3164b',true),('combat_v2_elemental_internal.scudo_consumer_options(jsonb)','e84aa35091f26367645f35a8815c78b1',true),('combat_v2_elemental_internal.scudo_master_options(uuid,pg_catalog.int8)','33fb2ed8a14cb05a3414e7be89556659',true),('combat_v2_elemental_internal.scudo_prepare_native(uuid,uuid,uuid,uuid,jsonb)','df51b64ad4443f0acdde37fbfdd5284e',true),('combat_v2_elemental_internal.scudo_narrative(uuid)','c580ef1cdbaff1598a7863603aa5c9a3',true),('combat_v2_elemental_internal.scarica_contact_range(uuid,uuid)','f92feff3bb5167ba034931dcb3832f4e',true),('combat_v2_elemental_internal.scarica_contact_witness(uuid,uuid,uuid,uuid)','34fb9bc5836831510ebd6e300e60a408',true),('combat_v2_elemental_internal.scarica_source_contact_valid(uuid)','57ed0bac1c1d36d8fd259010ceab4538',true)) SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) WHERE p.oid IS NULL OR md5(p.prosrc) IS DISTINCT FROM e.hash OR p.prosecdef IS DISTINCT FROM e.sd OR p.proowner IS DISTINCT FROM 'postgres'::regrole OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""'] OR p.proacl IS DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN RAISE EXCEPTION 'runtime_elemental_complete_helper_drift';END IF;
end $function$
;
DO $catalogo_root$
DECLARE
 expected_parameters_sha256 constant text:='a54a86493459e2277c0c05b6ed41c672dbc8452b21a34670ed917fcc83fd84f5';
 old_root_sha text;
 old_row_sha text;
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';
 baseline_combat_ezbr constant text:='79bdb113f0203e5b0578a1211fb43f1c5cfb6b3bb5585714b4d9b5475ce27a11';
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 params jsonb;review jsonb;binding jsonb;before_root jsonb;root jsonb;core jsonb;cfg jsonb;identity jsonb;runtime_before jsonb;expected_ui jsonb;
 shared_manifest jsonb:='[]';private_manifest jsonb:='[]';relation_manifest jsonb:='[]';trigger_manifest jsonb:='[]';
 item jsonb;h jsonb;abi jsonb;cols jsonb;descriptor jsonb;next_descriptor jsonb;alias_row record;kv record;
 relation_oid oid;function_oid oid;actual_count integer;affected integer;aliases integer:=0;
 old_generic jsonb;old_combat jsonb;edge_receipt jsonb;edge_files jsonb;base_files jsonb;changed_files jsonb;
 db_stored text;db_old_recomputed text;db_sha text;shared_sha text;private_sha text;relations_sha text;
 config_sha text;identity_sha text;root_text text;new_root_sha text;bindings jsonb;qualification jsonb;
 content_row mission_public_owner.mission_content_admissions_v1%ROWTYPE;content_request uuid;content_payload jsonb;
 changed_headers jsonb;native_manifest jsonb;pending_paths text[]:=ARRAY['["db_core"]'];current_path text[];stack_size integer;
 raw_bytes bytea;compact_bytes bytea:=''::bytea;byte_chunks bytea[]:='{}';byte_chunk bytea:=''::bytea;
 byte_index integer;byte_value integer;inside_string boolean:=false;escaped boolean:=false;
 profile_row record;profile_state jsonb;schema_name text;name_only text;
 namespace_uuid constant uuid:='9ebf5297-66c5-5a19-b35a-589b626e4a4f';
BEGIN
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_OPERATOR_REQUIRED';END IF;
 PERFORM set_config('search_path','',true);
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_AVAILABILITY_BUSY';END IF;
 params:=nullif(current_setting('app.elemental_label_binding_parameters',true),'')::jsonb;old_root_sha:=params#>>'{expected_current,root_sha256}';old_row_sha:=params#>>'{expected_current,root_row_sha256}';
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF rr.revision_sha256<>old_root_sha OR rr.observed_revision_sha256 IS DISTINCT FROM old_root_sha
 OR public.combat_v2_sha256(to_jsonb(rr))<>old_row_sha
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')<>old_root_sha
 OR octet_length(rr.canonical_preimage)<>(params#>>'{expected_current,root_bytes}')::integer THEN RAISE EXCEPTION 'CATALOGO_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso' AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata') AND closed_at IS NULL) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REQUIRES_QUIESCENCE';END IF;
 params:=nullif(current_setting('app.elemental_label_binding_parameters',true),'')::jsonb;
 IF expected_parameters_sha256 !~ '^[0-9a-f]{64}$' OR params IS NULL
 OR public.combat_v2_sha256(params)<>expected_parameters_sha256
 OR params->>'schema_version' IS DISTINCT FROM 'elemental-label-binding-parameters/1' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEWED_PARAMETERS_REQUIRED';END IF;
 review:=params->'review';
 IF NOT mission_factory_owner.keys_exact_v2(review,ARRAY['ref','sha256','P0','P1','P2']) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEW_SHAPE';END IF;
 IF nullif(review->>'ref','') IS NULL OR octet_length(to_jsonb(review->>'ref')::text)>258 OR coalesce(review->>'sha256','')!~'^[0-9a-f]{64}$'
 OR review->'P0' IS DISTINCT FROM '0'::jsonb OR review->'P1' IS DISTINCT FROM '0'::jsonb OR review->'P2' IS DISTINCT FROM '0'::jsonb
 OR coalesce(params->>'source_bundle_sha256','')!~'^[0-9a-f]{64}$'
 OR params#>>'{baseline_custody,sha256}' IS DISTINCT FROM old_root_sha
 OR nullif(params#>>'{baseline_custody,ref}','') IS NULL
 OR params#>>'{compatibility,scope}' IS DISTINCT FROM 'existing_mission_capabilities_only'
 OR params#>'{compatibility,new_techniques_staff_pass}' IS DISTINCT FROM 'false'::jsonb
 OR coalesce(params#>>'{compatibility,sha256}','')!~'^[0-9a-f]{64}$'
 OR nullif(params#>>'{compatibility,ref}','') IS NULL THEN RAISE EXCEPTION 'CATALOGO_ROOT_REVIEW_SCOPE_REQUIRED';END IF;
 LOCK TABLE mission_public_owner.release_admissions_v1,mission_public_owner.public_qualification_attestations_v1,
  mission_public_owner.engine_profile_events_v1,mission_public_owner.mission_content_admissions_v1,
  mission_public_owner.party_launch_runtime_v1 IN SHARE ROW EXCLUSIVE MODE NOWAIT;
 before_root:=rr.canonical_preimage::jsonb;root:=before_root;
 -- Il JSON runtime è riletto esplicitamente per il CAS finale e conserva entrambi i booleani.
 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton FOR UPDATE;
 IF runtime_before IS DISTINCT FROM jsonb_build_object('singleton',true,'staff_enabled',true,'public_enabled',true,'release_sha256',old_root_sha) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_PARTY_BASELINE';END IF;
 SELECT value INTO STRICT old_generic FROM jsonb_array_elements(before_root->'edge_bundles') WHERE value->>'name'='mission_generic_ai';
 SELECT value INTO STRICT old_combat FROM jsonb_array_elements(before_root->'edge_bundles') WHERE value->>'name'='combat_narratore_ai';
 IF old_generic->>'ezbr_sha256'<>generic_ezbr OR old_generic->'version'<>'168'::jsonb
 OR old_combat->'version'IS DISTINCT FROM '45'::jsonb OR old_combat->>'ezbr_sha256'IS DISTINCT FROM '79bdb113f0203e5b0578a1211fb43f1c5cfb6b3bb5585714b4d9b5475ce27a11'
 OR public.combat_v2_sha256(root->'ui')<>'cd76714cb188ea3f69189ac5dd793304acdc2179da724aad852f961d12ab3014' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_UNRELATED_SURFACE_DRIFT';END IF;
 db_stored:=root#>>'{db_core,sha256}';db_old_recomputed:=public.combat_v2_sha256((root->'db_core')-'sha256');
 IF db_stored IS DISTINCT FROM params#>>'{expected_current,db_sha256}' OR db_old_recomputed IS DISTINCT FROM db_stored
 OR root#>>'{config,sha256}'<>public.combat_v2_sha256((root->'config')-'sha256') THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_HASH_RECONCILIATION_DRIFT';END IF;

SELECT jsonb_agg(jsonb_build_object('oid',p.oid::text,'signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
 'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),
 'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text,'leakproof',p.proleakproof,'nspname',n.nspname,'proname',p.proname)
 ORDER BY p.oid::regprocedure::text) INTO shared_manifest FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
 WHERE p.prokind='f'AND p.oid IN('combat_consumer_private.narrative_context(uuid)'::regprocedure,'combat_consumer_private.narrative_declaration_supported(uuid)'::regprocedure,'combat_consumer_private.validate_narrative_result(jsonb)'::regprocedure,'combat_effects_private.lifecycle_before_report(uuid)'::regprocedure,'combat_effects_private.lifecycle_main_end(uuid)'::regprocedure,'combat_effects_private.lifecycle_open(uuid,uuid)'::regprocedure,'combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)'::regprocedure,'combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)'::regprocedure,'combat_panel_private.commit_master_actor(jsonb)'::regprocedure,'combat_panel_private.immobilization_actor_lifecycle()'::regprocedure,'combat_panel_private.immobilization_session_lifecycle()'::regprocedure,'combat_panel_private.master_options(uuid,uuid,bigint)'::regprocedure,'combat_panel_private.movement_block_reason(uuid)'::regprocedure,'combat_panel_private.narrative_declaration_facts(uuid)'::regprocedure,'combat_panel_private.narrative_ordinary_context(uuid)'::regprocedure,'combat_panel_private.narrative_outcome_facts(jsonb)'::regprocedure,'combat_panel_private.ordinary_options(uuid,uuid,bigint)'::regprocedure,'combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)'::regprocedure,'combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,'combat_v2_elemental_internal.other_consumer_options(jsonb)'::regprocedure,'combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)'::regprocedure,'combat_v2_elemental_internal.other_control_target(text,uuid,uuid)'::regprocedure,'combat_v2_elemental_internal.other_master_options(uuid,bigint)'::regprocedure,'combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)'::regprocedure,'combat_v2_elemental_internal.other_profile(uuid,uuid)'::regprocedure,'combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'::regprocedure,'public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'::regprocedure,'public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'::regprocedure,'public.combat_panel_commit_v1(jsonb)'::regprocedure,'public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure,'public.combat_v2_actor_ability(uuid,text,uuid,boolean)'::regprocedure,'public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)'::regprocedure,'public.combat_v2_round_resolve(uuid,uuid)'::regprocedure,'public.post_heal(uuid,uuid)'::regprocedure);
SELECT coalesce(jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,'language',l.lanname,
 'strict',p.proisstrict,'parallel',p.proparallel::text,'returns',pg_get_function_result(p.oid),'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)
 ORDER BY p.oid::regprocedure::text),'[]'::jsonb) INTO private_manifest FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
 WHERE p.prokind='f'AND(n.nspname='combat_v2_genjutsu_internal'OR(n.nspname='combat_panel_private'AND(p.proname LIKE 'cure\_%'ESCAPE'\'OR p.proname IN('catalog_result_label_v1','catalog_lifecycle_lines_v1'))));
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
 'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'returns',pg_get_function_result(p.oid),
 'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)ORDER BY p.oid::regprocedure::text)
  INTO native_manifest FROM pg_proc p JOIN pg_language l ON l.oid=p.prolang WHERE p.prokind='f'AND p.oid IN('public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)ORDER BY p.oid::regprocedure::text)
  INTO trigger_manifest FROM pg_proc p WHERE p.oid IN('combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('oid',p.oid::text,'signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
 'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),
 'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text,'leakproof',p.proleakproof,'nspname',n.nspname,'proname',p.proname)
 ORDER BY p.oid::regprocedure::text) INTO changed_headers FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
 WHERE p.prokind='f'AND p.oid IN('clan_innata_private.eligibility_release_assert()'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)ORDER BY p.oid::regprocedure::text)
  INTO relation_manifest FROM pg_proc p WHERE p.oid IN('clan_innata_private.eligibility_release_assert()'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
 shared_sha:=public.combat_v2_sha256(shared_manifest);private_sha:=public.combat_v2_sha256(private_manifest);
 IF jsonb_array_length(shared_manifest)<>34 OR jsonb_array_length(private_manifest)<>66 OR jsonb_array_length(native_manifest)<>3
 OR jsonb_array_length(changed_headers)<>1 OR jsonb_array_length(relation_manifest)<>2 OR shared_sha<>'03f750c6bb386e6ef79db36673a0ec9382e9d131b6d4ad970dcb8690b3f5ed18'OR private_sha<>'738506bdca70d1a39219535f7aa12ffc8dc4c1807939b9b6d8f986c9890f0833'
 OR public.combat_v2_sha256(native_manifest)<>'2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f'THEN RAISE EXCEPTION 'cure_reaction_post_manifest_drift';END IF;
 IF jsonb_array_length(trigger_manifest)<>6 OR public.combat_v2_sha256(trigger_manifest)<>'21d366c4d5612fc1dbefba91a091c6c6538d63a6a0361d648aa235e322b6d7df'THEN RAISE EXCEPTION 'palmo_completion_peer6_drift';END IF;
 -- Update every existing touched-OID alias; ABI remains byte-exact.
 WHILE coalesce(cardinality(pending_paths),0)>0 LOOP
  stack_size:=cardinality(pending_paths);SELECT ARRAY(SELECT jsonb_array_elements_text(pending_paths[stack_size]::jsonb))INTO current_path;
  pending_paths:=pending_paths[1:stack_size-1];descriptor:=root#>current_path;
  IF jsonb_typeof(descriptor)='object'THEN
   SELECT value INTO h FROM jsonb_array_elements(changed_headers)WHERE value->>'oid'=descriptor->>'oid';
   IF descriptor?'oid'AND h IS NOT NULL THEN
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor)WHERE key=ANY(ARRAY['owner','acl','config','secdef','strict','language','parallel','arg_modes','arg_names','arg_types','leakproof','returns','volatility','kind','signature','nspname','proname'])LOOP
     IF kv.value IS DISTINCT FROM h->kv.key THEN RAISE EXCEPTION 'cure_reaction_alias_abi';END IF;
    END LOOP;
    next_descriptor:=descriptor;
    IF descriptor?'source_md5'THEN next_descriptor:=jsonb_set(next_descriptor,'{source_md5}',h->'source_md5',false);END IF;
    IF descriptor?'ddl_md5'THEN next_descriptor:=jsonb_set(next_descriptor,'{ddl_md5}',h->'ddl_md5',false);END IF;
    root:=jsonb_set(root,current_path,next_descriptor,false);aliases:=aliases+1;
   ELSE
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor)WHERE jsonb_typeof(value)IN('object','array')LOOP pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);END LOOP;
   END IF;
  ELSIF jsonb_typeof(descriptor)='array'THEN
   FOR kv IN SELECT(ord-1)::text AS key,value FROM jsonb_array_elements(descriptor)WITH ORDINALITY x(value,ord)WHERE jsonb_typeof(value)IN('object','array')LOOP pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);END LOOP;
  END IF;
 END LOOP;
 IF aliases<>1 THEN RAISE EXCEPTION 'staff_entry_repairs_alias_count';END IF;
 binding:=root#>'{db_core,cure_command_amendment}';
 cfg:=root#>'{db_core,catalogo_eligibility_compat}';
 cfg:=cfg||jsonb_build_object('guard_source_md5','ef199a674937b3bc4f9dbd49f35bf9b2','functions',relation_manifest,'functions_manifest_sha256',public.combat_v2_sha256(relation_manifest));
 root:=jsonb_set(root,'{db_core,catalogo_eligibility_compat}',cfg,false);root:=jsonb_set(root,'{config,catalogo_eligibility_compat}',cfg,false);
 core:=root->'db_core';db_sha:=public.combat_v2_sha256(core-'sha256');core:=jsonb_set(core,'{sha256}',to_jsonb(db_sha),false);root:=jsonb_set(root,'{db_core}',core,false);
 cfg:=root->'config';config_sha:=public.combat_v2_sha256(cfg-'sha256');cfg:=jsonb_set(cfg,'{sha256}',to_jsonb(config_sha),false);root:=jsonb_set(root,'{config}',cfg,false);
 expected_ui:=before_root->'ui';
 IF public.combat_v2_sha256(expected_ui)IS DISTINCT FROM 'cd76714cb188ea3f69189ac5dd793304acdc2179da724aad852f961d12ab3014' THEN RAISE EXCEPTION 'cure_entry_recovery_ui_drift';END IF;
 identity:=jsonb_build_object('schema_version','elemental-label-binding-code-identity/1','parent_root',old_root_sha,'parent_code_identity',before_root#>'{contract,code_identity_sha256}',
  'normalized_amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,
  'active_private_functions_manifest_sha256',private_sha,'native_functions_manifest_sha256',binding->'native_functions_manifest_sha256',
  'source_bundle_sha256',params->'source_bundle_sha256','mode',params->'mode','guard_source_md5','ef199a674937b3bc4f9dbd49f35bf9b2','db_sha256',db_sha,'client_sha256',public.combat_v2_sha256(root->'ui'),'ui_graph_sha256',root#>>'{ui,import_graph_sha256}','amendment_state',binding->'state');
 identity_sha:=public.combat_v2_sha256(identity);root:=jsonb_set(root,'{contract,code_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,semantic_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,cure_command_amendment}',jsonb_build_object('parent_root',old_root_sha,'state',binding->'state',
  'previous_semantic_identity',before_root#>'{recovery,semantic_identity_sha256}','policy','forward_binding_keep_code'),false);
 IF root->'ui'IS DISTINCT FROM expected_ui OR root->'edge_bundles'IS DISTINCT FROM before_root->'edge_bundles'
 OR(root->'config')-ARRAY['sha256','catalogo_eligibility_compat']IS DISTINCT FROM(before_root->'config')-ARRAY['sha256','catalogo_eligibility_compat']
 OR root#>'{db_core,catalogo_completo}'IS DISTINCT FROM before_root#>'{db_core,catalogo_completo}'THEN RAISE EXCEPTION 'cure_reaction_unrelated_config_changed';END IF;
 -- Lexer UTF8 a byte, memoria limitata: non usa token SQL, sort o aggregati.
 -- Si scarta soltanto whitespace JSON ASCII esterno alle stringhe.
 -- Gli escape e ogni byte interno alle stringhe restano identici; niente NFC.
 raw_bytes:=convert_to(root::text,'UTF8');
 IF octet_length(raw_bytes)>1048576 THEN RAISE EXCEPTION 'CATALOGO_ROOT_SERIALIZATION_INPUT_CAP';END IF;
 FOR byte_index IN 0..octet_length(raw_bytes)-1 LOOP
  byte_value:=get_byte(raw_bytes,byte_index);
  IF inside_string THEN
   IF escaped THEN escaped:=false;
   ELSIF byte_value=92 THEN escaped:=true;
   ELSIF byte_value=34 THEN inside_string:=false;END IF;
  ELSE
   IF byte_value=34 THEN inside_string:=true;
   ELSIF byte_value IN(9,10,13,32) THEN CONTINUE;END IF;
  END IF;
  byte_chunk:=byte_chunk||substring(raw_bytes FROM byte_index+1 FOR 1);
  IF octet_length(byte_chunk)>=4096 THEN
   byte_chunks:=array_append(byte_chunks,byte_chunk);byte_chunk:=''::bytea;
  END IF;
 END LOOP;
 IF inside_string OR escaped THEN RAISE EXCEPTION 'CATALOGO_ROOT_SERIALIZATION_STRING_STATE';END IF;
 IF octet_length(byte_chunk)>0 THEN byte_chunks:=array_append(byte_chunks,byte_chunk);END IF;
 FOREACH byte_chunk IN ARRAY byte_chunks LOOP compact_bytes:=compact_bytes||byte_chunk;END LOOP;
 root_text:=convert_from(compact_bytes,'UTF8');
 IF root_text IS NULL OR root_text::jsonb IS DISTINCT FROM root THEN RAISE EXCEPTION 'CATALOGO_ROOT_COMPACT_SERIALIZATION';END IF;
 IF octet_length(root_text)>524288 THEN RAISE EXCEPTION 'CATALOGO_ROOT_BYTES_CAP:%',octet_length(root_text);END IF;
 new_root_sha:=encode(extensions.digest(convert_to(root_text,'UTF8'),'sha256'),'hex');

 -- Baseline missione validata prima del passaggio; niente nuove capability.
 IF mission_public_owner.engine_qualification_v1(old_root_sha,true)IS NULL THEN RAISE EXCEPTION 'CATALOGO_ROOT_PREVIOUS_MISSION_UNQUALIFIED';END IF;
 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=old_root_sha FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1 WHERE release_sha256=old_root_sha FOR SHARE;
 IF(SELECT count(*)FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha)<>2
 OR(SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c)ORDER BY c.mission_id,c.request_key))FROM mission_public_owner.mission_content_admissions_v1 c WHERE engine_release_sha256=old_root_sha)
 IS DISTINCT FROM params->>'expected_content_admission_rows_sha256'
 THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_CONTENT_BASELINE';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha FOR SHARE LOOP
  IF mission_public_owner.content_admission_v1(content_row.mission_id,old_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_PREVIOUS_CONTENT_UNQUALIFIED';END IF;
 END LOOP;
 bindings:=jsonb_build_object('db_sha256',db_sha,'edge_sha256',generic_ezbr,'client_sha256',public.combat_v2_sha256(root->'ui'),'configuration_sha256',config_sha);
 UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=root_text,revision_sha256=new_root_sha,
  observed_revision_sha256=new_root_sha,client_build='mission-factory-admin/2:'||new_root_sha,
  independent_review_ref=review->>'ref',updated_at=clock_timestamp()
  WHERE singleton AND revision_sha256=old_root_sha AND public.combat_v2_sha256(to_jsonb(editor_release_readiness))=old_row_sha;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'CATALOGO_ROOT_ROW_CAS';END IF;
 INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,
  contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 VALUES(new_root_sha,db_sha,generic_ezbr,bindings->>'client_sha256',config_sha,prior_release.contract_version,
  review->>'ref',prior_release.staff_evidence_ref,prior_release.qualified_at,prior_release.public_enabled);
 FOR profile_row IN SELECT DISTINCT ON(profile_key)* FROM mission_public_owner.engine_profile_events_v1
  WHERE engine_release_sha256=old_root_sha ORDER BY profile_key,control_version DESC LOOP
  IF profile_row.profile_key IS DISTINCT FROM prior_qualification.payload->>'authoring_profile' THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_UNQUALIFIED_PROFILE_CARRYFORWARD';END IF;
  INSERT INTO mission_public_owner.engine_profile_events_v1(event_id,engine_release_sha256,profile_key,expected_control_version,
   control_version,authoring_enabled,runtime_enabled,actor_user,reason)
  VALUES(extensions.uuid_generate_v5(namespace_uuid,new_root_sha||':profile:'||profile_row.profile_key),new_root_sha,profile_row.profile_key,
   0,1,profile_row.authoring_enabled,profile_row.runtime_enabled,profile_row.actor_user,
   'Compatible carryforward of existing mission profile only; new catalog techniques have no Staff PASS');
 END LOOP;
 qualification:=prior_qualification.payload||jsonb_build_object('revision_sha256',new_root_sha,'bindings',bindings,'independent_review',review,
  'reuse_evidence',(prior_qualification.payload->'reuse_evidence')||jsonb_build_object('new_mission_QA_claim',false,
   'catalogo_compatibility',jsonb_build_object('parent_root',old_root_sha,'ref',params#>'{compatibility,ref}',
    'sha256',params#>'{compatibility,sha256}','scope','existing_mission_capabilities_only','new_techniques_staff_pass',false)));
 INSERT INTO mission_public_owner.public_qualification_attestations_v1(release_sha256,request_key,payload,payload_sha256,
  positive_staff_evidence_ref,authorized_test_manifest_ref,created_by)
 VALUES(new_root_sha,extensions.uuid_generate_v5(namespace_uuid,new_root_sha||':qualification'),qualification,mission_factory_owner.sha(qualification),
  prior_qualification.positive_staff_evidence_ref,prior_qualification.authorized_test_manifest_ref,prior_qualification.created_by);
 IF qualification->'capabilities' IS DISTINCT FROM prior_qualification.payload->'capabilities'
 OR mission_public_owner.engine_qualification_v1(new_root_sha,true)IS NULL THEN RAISE EXCEPTION 'CATALOGO_ROOT_MISSION_CARRYFORWARD_INVALID';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha ORDER BY mission_id LOOP
  content_request:=extensions.uuid_generate_v5(content_row.request_key,new_root_sha||':catalogo-compatible-adoption');
  content_payload:=content_row.payload||jsonb_build_object('request_key',content_request,'engine_release_sha256',new_root_sha,'created_at',clock_timestamp());
  INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)
  VALUES(content_request,content_row.mission_id,content_row.config_version,new_root_sha,content_row.publication_request,content_payload,mission_factory_owner.sha(content_payload));
  IF mission_public_owner.content_admission_v1(content_row.mission_id,new_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_CONTENT_CARRYFORWARD_INVALID';END IF;
 END LOOP;
 UPDATE mission_public_owner.party_launch_runtime_v1 x SET release_sha256=new_root_sha WHERE singleton AND to_jsonb(x)=runtime_before;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'CATALOGO_ROOT_PARTY_RUNTIME_CAS';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton
  AND to_jsonb(x)=jsonb_set(runtime_before,'{release_sha256}',to_jsonb(new_root_sha),false))THEN RAISE EXCEPTION 'CATALOGO_ROOT_PARTY_FLAGS_CHANGED';END IF;
 IF(SELECT to_jsonb(g)FROM combat_v2_genjutsu_internal.gate g WHERE singleton)IS DISTINCT FROM current_setting('app.cure_reaction_paralisi_gate_before')::jsonb THEN RAISE EXCEPTION 'cure_reaction_paralisi_gate_changed';END IF;
 IF(SELECT to_jsonb(g)FROM combat_panel_private.cure_gate_v1 g WHERE singleton)IS DISTINCT FROM current_setting('app.cure_reaction_cure_gate_before')::jsonb THEN RAISE EXCEPTION 'palmo_completion_cure_gate_changed';END IF;
 IF NOT clan_innata_private.catalogo_eligibility_release_v1()THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_BRANCH_NOT_ADMITTED';END IF;
 PERFORM set_config('app.elemental_label_binding_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),'source_bundle_sha256',params->'source_bundle_sha256',
  'db_sha256',db_sha,'configuration_sha256',config_sha,'code_identity_sha256',identity_sha,'aliases_updated',aliases,
  'amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,'active_private_functions_manifest_sha256',private_sha,
  'new_techniques_staff_pass',false,'provider_calls',0)::text,true);
END $catalogo_root$;
DO $binding_post$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;r jsonb;f jsonb;
BEGIN
 FOR f IN SELECT value FROM jsonb_array_elements($binding_pins$[{"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"ef199a674937b3bc4f9dbd49f35bf9b2","ddl_sha256":"680a47c514ab2255937d259a2fb0ecc8fd1b098670089d595b531839a23e33f9"},{"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"e52a8ac90fb15cad425cd0d17c9b4d4b","ddl_sha256":"72141f00f7b6c79aacf634334290e92debbcc3a5bd77365c55dc4ef3a82ea5f6"},{"signature":"clan_innata_private.runtime_release_assert()","source_md5":"6b9ed7edc3ea365017e1f5e84200ed79","ddl_sha256":"220301a349fe8d8d59717f82f84b9b5785c21acf0e8bd965682be6f85e513a38"},{"signature":"combat_panel_private.cure_contact_v1(uuid,uuid)","source_md5":"21de7dd5e62b5403b50065d2635e20bf","ddl_sha256":"0d5ef7dfd803fadfc2ec38aa4285467cd95f83bb613e6c0b6a0dde650d571f00"},{"signature":"combat_panel_private.master_projection(uuid,uuid)","source_md5":"271ea56acb5f135ad6e3d24d8601e3b1","ddl_sha256":"da26a20b86b168b4769b851405794371ddbe54095c1e8c775859c0b1c155cd0b"},{"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"7cf9d8be18c9dab5f75b62c74a5e9e37","ddl_sha256":"22bd8c8faf60ba44a644bf9ccd0f69ab8a5715383c79ff6014509dfd02290554"},{"signature":"combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)","source_md5":"aa3d6fe2cb785a3a132a7b281bdab70a","ddl_sha256":"15fab8ec94575b4a0e163cfbdcc46272b02d47d772daa262de5483a43b18f5ac"}]$binding_pins$::jsonb) LOOP
  IF md5((SELECT prosrc FROM pg_proc WHERE oid=to_regprocedure(f->>'signature'))) IS DISTINCT FROM f->>'source_md5'
   OR encode(extensions.digest(convert_to(pg_get_functiondef(to_regprocedure(f->>'signature')),'UTF8'),'sha256'),'hex') IS DISTINCT FROM f->>'ddl_sha256'
  THEN RAISE EXCEPTION 'ELEMENTAL_LABEL_BINDING_BODY_DRIFT:%',f->>'signature';END IF;
 END LOOP;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton;
 r:=rr.canonical_preimage::jsonb;
 IF r#>>'{db_core,catalogo_eligibility_compat,guard_source_md5}' IS DISTINCT FROM 'ef199a674937b3bc4f9dbd49f35bf9b2'
 OR r#>'{db_core,catalogo_eligibility_compat}' IS DISTINCT FROM r#>'{config,catalogo_eligibility_compat}'
 OR r#>>'{db_core,catalogo_eligibility_compat,functions_manifest_sha256}' IS DISTINCT FROM public.combat_v2_sha256(r#>'{db_core,catalogo_eligibility_compat,functions}')
 OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM rr.revision_sha256
 THEN RAISE EXCEPTION 'ELEMENTAL_LABEL_BINDING_ROOT_NOT_SEALED';END IF;
 PERFORM clan_innata_private.eligibility_release_assert();
END $binding_post$;
COMMIT;
