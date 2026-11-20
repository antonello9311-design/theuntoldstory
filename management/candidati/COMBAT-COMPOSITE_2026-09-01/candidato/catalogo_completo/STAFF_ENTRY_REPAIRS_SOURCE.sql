-- SOURCE COMPONENTE, NON INSTALLER AUTONOMO: due corpi owning minimi; nessun DB apply eseguito.
-- Source B 680f9d1d43250a7a62ad29537a6d0b2ac13abfdc06f510372c669794b15a403d
BEGIN;
DO $contact_pre$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;
BEGIN
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL THEN RAISE EXCEPTION 'STAFF_ENTRY_OPERATOR_REQUIRED';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN RAISE EXCEPTION 'STAFF_ENTRY_AVAILABILITY_BUSY';END IF;
 PERFORM set_config('app.cure_reaction_paralisi_gate_before',(SELECT to_jsonb(g)::text FROM combat_v2_genjutsu_internal.gate g WHERE singleton),true);
 PERFORM set_config('app.cure_reaction_cure_gate_before',(SELECT to_jsonb(g)::text FROM combat_panel_private.cure_gate_v1 g WHERE singleton),true);
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE;
 IF rr.revision_sha256 IS DISTINCT FROM 'b3e9fcf8927cf169969f53dc642fe9d4b37fac38450e51c816f51bf4e59a926f' OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM rr.revision_sha256
 OR octet_length(rr.canonical_preimage)>524288 THEN RAISE EXCEPTION 'palmo_ordinary_baseline_root_drift';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN('preparazione','in_corso','sospeso'))
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND suspended_at IS NULL)
 THEN RAISE EXCEPTION 'palmo_ordinary_requires_quiescence';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('combat_panel_private.cure_contact_v1(uuid,uuid)'::regprocedure),'UTF8'),'sha256'),'hex') IS DISTINCT FROM '94e8edaf1ce243a8dd19cb3458d44b15a72423039548fa06d648420e3250a675'
 OR encode(extensions.digest(convert_to(pg_get_functiondef('clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure),'UTF8'),'sha256'),'hex') IS DISTINCT FROM '5c6d0b8482ced37b7459eefb5f1a3c5dca3e37f2cfab83f11ef8fda414d147a9'
 THEN RAISE EXCEPTION 'palmo_ordinary_owning_ddl_drift';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('combat_panel_private.master_projection(uuid,uuid)'::regprocedure),'UTF8'),'sha256'),'hex') IS DISTINCT FROM '6610db89b6bdb52df243967e0228ccd5ddb74a43d31280e4c80ab32394aa348e' THEN RAISE EXCEPTION 'STAFF_ENTRY_PROJECTION_BASELINE_DRIFT';END IF;
END $contact_pre$;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_contact_v1(p_actor uuid, p_target uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE;t public.combat_v2_actors%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE;ab combat_spatial.actor_states%ROWTYPE;tb combat_spatial.actor_states%ROWTYPE;
BEGIN
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor;
 SELECT * INTO t FROM public.combat_v2_actors WHERE id=p_target;
 IF a.id IS NULL OR t.id IS NULL OR t.actor_kind IS DISTINCT FROM 'pg'
  OR a.session_id<>t.session_id OR a.team_key<>t.team_key
  OR a.state<>'attivo' OR coalesce((a.mechanics_snapshot->>'vita')::integer,0)<=0
  OR t.state NOT IN('attivo','fuori') OR t.companion_id IS NOT NULL
  OR (t.state='fuori' AND coalesce((t.mechanics_snapshot->>'vita')::integer,-1)<>0)
  OR jsonb_typeof(t.mechanics_snapshot->'vita') IS DISTINCT FROM 'number'
  OR jsonb_typeof(t.mechanics_snapshot->'vita_max') IS DISTINCT FROM 'number'
  OR (t.mechanics_snapshot->>'vita')::integer<0
  OR (t.mechanics_snapshot->>'vita_max')::integer<=0
  OR (t.mechanics_snapshot->>'vita')::integer>(t.mechanics_snapshot->>'vita_max')::integer THEN RETURN NULL; END IF;
 SELECT * INTO i FROM combat_spatial.arena_instances WHERE encounter_id=a.session_id
  AND context_source IN('ordinary','panel_master') AND state='open';
 IF i.instance_id IS NULL THEN RETURN NULL; END IF;
 SELECT * INTO ab FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id AND state='active';
 SELECT * INTO tb FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=t.id AND state='active';
 IF ab.actor_id IS NULL OR tb.actor_id IS NULL THEN RETURN NULL; END IF;
 -- Self ordinary Staff usa la stessa ownership della mappa ordinary, non i grant del Master.
 -- Nessuna dipendenza da auth.uid(): anche il resolver server rilegge il contatto congelato.
 IF NOT(CASE WHEN a.id=t.id AND i.context_source='ordinary'
  AND combat_panel_private.cure_staff_execution_scope_v1(a.id) THEN EXISTS(
   SELECT 1 FROM combat_consumer_private.members m
   JOIN combat_consumer_private.activities c ON c.session_id=m.session_id
   JOIN public.combat_v2_sessions s ON s.id=c.session_id
   JOIN public.characters ch ON ch.id=m.character_id
   JOIN combat_spatial.arena_templates template
    ON template.template_key=i.template_key AND template.template_version=i.template_version
   WHERE m.session_id=a.session_id AND m.actor_id=a.id AND m.character_id=a.character_id
    AND ch.user_id=a.controller_user AND ab.controller_principal_id=a.controller_user
    AND c.location_id=s.location_id AND c.phase NOT IN('setup','closed','suspended')
    AND c.policy_id='staff_test_no_persistent_resources_v1'
    AND s.source_kind='ordinary' AND s.master_session_id IS NULL AND s.closed_at IS NULL AND s.state='in_corso'
    AND i.encounter_id=s.id AND i.state='open'
    AND NOT public.combat_v2_values_written(s.id) AND combat_panel_private.uses_simulated_pools(s.id)
    AND (SELECT count(*) FROM combat_consumer_private.members exact_members WHERE exact_members.session_id=s.id)=2
    AND mission_creation_owner.map_binding_ordinary_template_allowed(template.template_key,template.template_version,s.id)
    AND combat_spatial.template_errors(template.template_key,template.template_version)='[]'::jsonb
  ) ELSE false END)
 AND NOT EXISTS(SELECT 1 FROM combat_spatial.viewer_grants
  WHERE instance_id=i.instance_id AND viewer_principal_id=exam_regia_private.actor_principal(a.id,a.controller_user)
  AND subject_actor_id=t.id AND can_view_map) THEN RETURN NULL; END IF;
 IF a.id<>t.id AND (combat_spatial.distance_m(ab.x_m,ab.y_m,tb.x_m,tb.y_m)>2
  OR combat_spatial.path_first_block_t(i.instance_id,a.id,ab.x_m,ab.y_m,tb.x_m,tb.y_m,t.id)<1) THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('instance_id',i.instance_id,'actor_body_version',ab.body_version,
  'target_body_version',tb.body_version,'actor_x',ab.x_m,'actor_y',ab.y_m,'target_x',tb.x_m,'target_y',tb.y_m);
END $function$
;
CREATE OR REPLACE FUNCTION clan_innata_private.catalogo_eligibility_release_v1()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;root jsonb;binding jsonb;amendment jsonb;
 params constant jsonb:=$compat_metadata${"expected_alias_count":7,"shared_functions":[{"oid":"42942","signature":"combat_consumer_private.narrative_context(uuid)","source_md5":"bb4d81831292676d2e50e16d14f3192c","ddl_md5":"b94718dd0bd16443163b82057d27da82","abi":{"acl":"{postgres=X/postgres}","oid":"42942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_context(uuid)","volatility":"s"}},{"oid":"46723","signature":"combat_consumer_private.narrative_declaration_supported(uuid)","source_md5":"b2d2c4047c4f63cb104effede756b4b8","ddl_md5":"7e8aa5b6991c26251bcc1ca3dcc834ca","abi":{"acl":"{postgres=X/postgres}","oid":"46723","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_declaration_supported","returns":"boolean","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_declaration_supported(uuid)","volatility":"s"}},{"oid":"42968","signature":"combat_consumer_private.validate_narrative_result(jsonb)","source_md5":"a1ce0576cc6ca82207301ae0bbc21904","ddl_md5":"0cfd40e8d0b43add0d4cc25e6c8767b7","abi":{"acl":"{postgres=X/postgres}","oid":"42968","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_consumer_private","proname":"validate_narrative_result","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_consumer_private.validate_narrative_result(jsonb)","volatility":"i"}},{"oid":"52137","signature":"combat_effects_private.lifecycle_before_report(uuid)","source_md5":"bc4009af6a274d51e6b96fc51f7a7a78","ddl_md5":"ee929b8e4bb4efcd584e7755aa5df682","abi":{"acl":"{postgres=X/postgres}","oid":"52137","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_before_report","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_before_report(uuid)","volatility":"v"}},{"oid":"52136","signature":"combat_effects_private.lifecycle_main_end(uuid)","source_md5":"a1948e8ce4fc505fc23e4e4089958507","ddl_md5":"0b743c53cb23a3402542468dc3096430","abi":{"acl":"{postgres=X/postgres}","oid":"52136","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_main_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_main_end(uuid)","volatility":"v"}},{"oid":"52133","signature":"combat_effects_private.lifecycle_open(uuid,uuid)","source_md5":"f94e3ef794064277d596354feba2cd50","ddl_md5":"9a45b13e8d31dd58447d212b28031fe0","abi":{"acl":"{postgres=X/postgres}","oid":"52133","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_open","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_effects_private.lifecycle_open(uuid,uuid)","volatility":"v"}},{"oid":"51910","signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","source_md5":"125e376708eaccc758e7887a9bcef705","ddl_md5":"53f87f6235e1f557317df936effbcd74","abi":{"acl":"{postgres=X/postgres}","oid":"51910","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"51906","signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","source_md5":"e7ec43224a4640d00c53bad72ac0132d","ddl_md5":"d023d8a651a5e8ef8fdb1cc834b93391","abi":{"acl":"{postgres=X/postgres}","oid":"51906","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_start","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"44942","signature":"combat_panel_private.commit_master_actor(jsonb)","source_md5":"0c39121bcbd32a49608e4d925560ba41","ddl_md5":"b531bb7f50d4346a09e822b2f2e95144","abi":{"acl":"{postgres=X/postgres}","oid":"44942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"commit_master_actor","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.commit_master_actor(jsonb)","volatility":"v"}},{"oid":"45916","signature":"combat_panel_private.immobilization_actor_lifecycle()","source_md5":"5244a1f635ad7d7336d24140d288b82a","ddl_md5":"f8677e282d09ca9015c01de07391f1bc","abi":{"acl":"{postgres=X/postgres}","oid":"45916","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_actor_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_actor_lifecycle()","volatility":"v"}},{"oid":"45918","signature":"combat_panel_private.immobilization_session_lifecycle()","source_md5":"a4671931aa6e908a94af2ad2d788d933","ddl_md5":"38bc9bc060bc1af88cf087f5e4a687bb","abi":{"acl":"{postgres=X/postgres}","oid":"45918","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_session_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_session_lifecycle()","volatility":"v"}},{"oid":"44940","signature":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"84c29f6a84fbe579caf5bb3fec7a2382","ddl_md5":"c11111f77595c311b997d46a98eb30fa","abi":{"acl":"{postgres=X/postgres}","oid":"44940","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"master_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.master_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"45000","signature":"combat_panel_private.movement_block_reason(uuid)","source_md5":"9cd995d873f2ae85f3cac5c0d7ff21ad","ddl_md5":"4830deea719904406d11aa4b05cfd764","abi":{"acl":"{postgres=X/postgres}","oid":"45000","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"movement_block_reason","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_body"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.movement_block_reason(uuid)","volatility":"s"}},{"oid":"46019","signature":"combat_panel_private.narrative_declaration_facts(uuid)","source_md5":"f4639eff179e6fdf1f998c0656ada09d","ddl_md5":"40d6973235b85e949ebbdd6ff06790eb","abi":{"acl":"{postgres=X/postgres}","oid":"46019","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_declaration_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_declaration_facts(uuid)","volatility":"s"}},{"oid":"46020","signature":"combat_panel_private.narrative_ordinary_context(uuid)","source_md5":"37d04042d9ee9cfec4ac237c7d9a5f37","ddl_md5":"c6eacfaec260f73134ad6f066021b4e2","abi":{"acl":"{postgres=X/postgres}","oid":"46020","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_ordinary_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_ordinary_context(uuid)","volatility":"s"}},{"oid":"46018","signature":"combat_panel_private.narrative_outcome_facts(jsonb)","source_md5":"988cc3b61d0ebf41effda90d32e173b5","ddl_md5":"a4d973f30fbd64ace5540ea3438c8e26","abi":{"acl":"{postgres=X/postgres}","oid":"46018","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"narrative_outcome_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_outcome"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.narrative_outcome_facts(jsonb)","volatility":"s"}},{"oid":"44669","signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"4337c8fe49127d7d72edc0789fc0352b","ddl_md5":"c88bca3336e5a3e37cd81b4693b373b4","abi":{"acl":"{postgres=X/postgres}","oid":"44669","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"ordinary_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"44955","signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","source_md5":"23722822d09c8d2a12a5121d04c141a6","ddl_md5":"883d64a10bb28250187b01e96e2dcf5e","abi":{"acl":"{postgres=X/postgres}","oid":"44955","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"round_details_from_source","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_source","p_roster","p_offers"],"arg_types":"3802 3802 3802","leakproof":false,"signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","volatility":"i"}},{"oid":"46316","signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"f275757957dd43a023cf45d8fe96bdf5","ddl_md5":"b798cabe68a2fcb9d6f45c2460d98cf2","abi":{"acl":"{postgres=X/postgres}","oid":"46316","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"round_options_authoritative","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","volatility":"v"}},{"oid":"61967","signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","source_md5":"8423c49ce8a83f2b19361b82a53fa9f4","ddl_md5":"0d57fa274c2b6b63dc5ed1ef0a7c8ca9","abi":{"acl":"{postgres=X/postgres}","oid":"61967","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_consumer_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","volatility":"v"}},{"oid":"61972","signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","source_md5":"4cf97ca72ff52f1bd33445ba54c8dd16","ddl_md5":"9066a8a35e086727ed0240ea05fce684","abi":{"acl":"{postgres=X/postgres}","oid":"61972","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_apply","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor","p_request"],"arg_types":"25 2950 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","volatility":"v"}},{"oid":"61971","signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","source_md5":"b1af00f3eab38ed9e74836c5441616d7","ddl_md5":"03724449dfc52ef8fcf4f89ae6eabb34","abi":{"acl":"{postgres=X/postgres}","oid":"61971","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_target","returns":"uuid","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor"],"arg_types":"25 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","volatility":"v"}},{"oid":"61970","signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","source_md5":"0c79a6a78b76b9e9ef8028d75e514af7","ddl_md5":"38e2e92e5566275950c270ef5a8fe3d6","abi":{"acl":"{postgres=X/postgres}","oid":"61970","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_master_options","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_context","p_expected"],"arg_types":"2950 20","leakproof":false,"signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","volatility":"v"}},{"oid":"61954","signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","source_md5":"6e54b476b36ca716cf8c14f33ef9667e","ddl_md5":"98acc6f2f9fcb26b47f3e6e830763e42","abi":{"acl":"{postgres=X/postgres}","oid":"61954","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_prepare_native","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_request","p_intent","p_push","p_native_ref"],"arg_types":"2950 2950 2950 3802 16 3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","volatility":"v"}},{"oid":"61950","signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","source_md5":"dd1e62e9052469fae4c98fed245c730a","ddl_md5":"0959ae18dc9357f65d8d8169e39b0cb2","abi":{"acl":"{postgres=X/postgres}","oid":"61950","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_profile","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_technique"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","volatility":"s"}},{"oid":"39291","signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","source_md5":"e9c7eb293c1791e36ba5fe70204af224","ddl_md5":"e494d3c9c4ee71bbdc81751c030ae3f7","abi":{"acl":"{postgres=X/postgres}","oid":"39291","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_multitarget_internal","proname":"resolve_parent","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_round","p_attack","p_values"],"arg_types":"2950 2950 2950 16","leakproof":false,"signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","volatility":"v"}},{"oid":"42947","signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","source_md5":"1b51f51abc7ee3201a994c520fbcc64c","ddl_md5":"63c1f412532da4ecfc6a82a5aca7bdfa","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42947","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_claim_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_report_sha256","p_request_key"],"arg_types":"2950 25 2950","leakproof":false,"signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","volatility":"v"}},{"oid":"42969","signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","source_md5":"2d60a9af131230e7f40ff99ed6456180","ddl_md5":"f9f6185f3de24ed7ae34aa2c0c5e7173","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42969","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_complete_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_claim","p_result","p_request_key"],"arg_types":"2950 3802 2950","leakproof":false,"signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","volatility":"v"}},{"oid":"44808","signature":"public.combat_panel_commit_v1(jsonb)","source_md5":"ce0c32cce5f6da141e20c015aba9e880","ddl_md5":"7c285429ea93b118c2d390e5a62cbe90","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"44808","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_panel_commit_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"public.combat_panel_commit_v1(jsonb)","volatility":"v"}},{"oid":"31324","signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","source_md5":"56a48200d4a15178b63e52445cb42ba7","ddl_md5":"6fdd865937ad47382b686820332e78b6","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31324","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_action_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31311","signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","source_md5":"6bc1065e07011266fead520f4b7d3b47","ddl_md5":"12183e1b698dbbbf8b904c6a24d89a51","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"31311","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_actor_ability","returns":"jsonb","language":"sql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_source","p_ability","p_defense"],"arg_types":"2950 25 2950 16","leakproof":false,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","volatility":"s"}},{"oid":"31326","signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","source_md5":"7e947fd7937ec49f19101a58d95432d8","ddl_md5":"568d4c124fee6d53dedd1d6e9eb6e9bd","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31326","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_defense_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_attack_declaration","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31331","signature":"public.combat_v2_round_resolve(uuid,uuid)","source_md5":"954c762bcaf8a4638d51a9061a275f24","ddl_md5":"ab38f8891a4f0d663410276047ea254d","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"31331","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_round_resolve","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_request_key"],"arg_types":"2950 2950","leakproof":false,"signature":"public.combat_v2_round_resolve(uuid,uuid)","volatility":"v"}},{"oid":"19700","signature":"public.post_heal(uuid,uuid)","source_md5":"dcde447ee079472efa4fd41c1c911633","ddl_md5":"9fb236d5f72312f6fb33587a2981e427","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"19700","kind":"f","owner":"postgres","config":["search_path=public"],"secdef":true,"strict":false,"nspname":"public","proname":"post_heal","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_target_user"],"arg_types":"2950 2950","leakproof":false,"signature":"public.post_heal(uuid,uuid)","volatility":"v"}}],"private_functions":[{"signature":"combat_panel_private.catalog_lifecycle_lines_v1(jsonb,jsonb)","source_md5":"8a472424ef8d1bc4d04283d18a0d049e"},{"signature":"combat_panel_private.catalog_result_label_v1(jsonb)","source_md5":"acae3722db638c3e8449b39f627fcfca"},{"signature":"combat_panel_private.cure_bind_v1(uuid)","source_md5":"a9c1bde3a9b0de30c44312b12be60eff"},{"signature":"combat_panel_private.cure_commit_v1(jsonb)","source_md5":"61532836e90ed32ae807b92ee6632b71"},{"signature":"combat_panel_private.cure_contact_v1(uuid,uuid)","source_md5":"21de7dd5e62b5403b50065d2635e20bf"},{"signature":"combat_panel_private.cure_declaration_meta_v1(uuid,uuid,uuid,jsonb)","source_md5":"9fdec7a42f67372bc1f2e2f408f16ba1"},{"signature":"combat_panel_private.cure_defense_guard_v1()","source_md5":"72b7362b50720f93672dfa1ab96338bc"},{"signature":"combat_panel_private.cure_frozen_turn_valid_v1(uuid,uuid)","source_md5":"7785ea336dd4a1deb9dd19487756d638"},{"signature":"combat_panel_private.cure_narrative_facts_v1(uuid)","source_md5":"a32f97cddb31ccf9581ba328f1e94e49"},{"signature":"combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)","source_md5":"0f48477bfc086b98e113e2dd70bba0de"},{"signature":"combat_panel_private.cure_note_voluntary_v1(uuid,uuid,text,text)","source_md5":"669353b795c5f327bdcd338c9990716d"},{"signature":"combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)","source_md5":"db137b63815164ffd8435bcf87ce245c"},{"signature":"combat_panel_private.cure_persistent_execution_scope_v1(uuid)","source_md5":"ea6a91fa5940c0d3680a36c4ee962880"},{"signature":"combat_panel_private.cure_persistent_scope_v1(uuid)","source_md5":"4fdb37eb54e15b3da2845a41809ccc57"},{"signature":"combat_panel_private.cure_prepare_v1(uuid,uuid,uuid,uuid)","source_md5":"bf7f19036a2846412374c68950126ac5"},{"signature":"combat_panel_private.cure_profile_v1(uuid)","source_md5":"88ec3750ea8aa0661eaa573747325e87"},{"signature":"combat_panel_private.cure_resolve_v1(uuid)","source_md5":"d385538828e19526af5e59dc8d18f167"},{"signature":"combat_panel_private.cure_staff_execution_scope_v1(uuid)","source_md5":"9adc4dfa74e700f54ba58d8691fb8f76"},{"signature":"combat_panel_private.cure_staff_scope_v1(uuid)","source_md5":"343140ae23ba4787fa511d1e6f27092e"},{"signature":"combat_panel_private.cure_turn_clear_v1(uuid,uuid)","source_md5":"ff5fac17361830d01e19aeba05430328"},{"signature":"combat_panel_private.cure_turn_used_v1(uuid,uuid)","source_md5":"11badbd523e79faba44fa282150be54b"},{"signature":"combat_panel_private.cure_voluntary_receipt_guard_v1()","source_md5":"08bacb86944bec00bc213eddf9815dca"},{"signature":"combat_v2_genjutsu_internal.actor_meta(uuid)","source_md5":"df3798ced5e32f7cb5aef4283fd88a00"},{"signature":"combat_v2_genjutsu_internal.ally_contact(uuid,uuid)","source_md5":"09fe1a174c9e813dcf541f1ad41a7016"},{"signature":"combat_v2_genjutsu_internal.bind_release(uuid)","source_md5":"1c6bfe3e32950c77afbb8c7b91a21078"},{"signature":"combat_v2_genjutsu_internal.bind_source(uuid)","source_md5":"80c79fc14b48e386b5920d021d537ba7"},{"signature":"combat_v2_genjutsu_internal.binding(uuid)","source_md5":"404fc795700a7fbe3334464c97a5058b"},{"signature":"combat_v2_genjutsu_internal.comparison(uuid,uuid,jsonb)","source_md5":"e63a4943d52d01b719d9693039c18d6c"},{"signature":"combat_v2_genjutsu_internal.consumer_options(jsonb)","source_md5":"c8daec5fcb19dc88267f7ceab87a2be8"},{"signature":"combat_v2_genjutsu_internal.declaration_events(uuid)","source_md5":"194b5c80d8e4779c66f0fdb8c50f1de3"},{"signature":"combat_v2_genjutsu_internal.declaration_meta(uuid,uuid,uuid,jsonb)","source_md5":"1dadbb12c0a1965b0461133ca0efc5d3"},{"signature":"combat_v2_genjutsu_internal.decorate_outcome(uuid,uuid,jsonb)","source_md5":"d0160238be06fafb4ce521553d4e745a"},{"signature":"combat_v2_genjutsu_internal.defense_intent_allowed(uuid,jsonb)","source_md5":"bf261ee2a0f55a52a8bb9462333058bd"},{"signature":"combat_v2_genjutsu_internal.end_context(uuid,uuid)","source_md5":"9d931f4ac19d9170e6119458d4825b23"},{"signature":"combat_v2_genjutsu_internal.event_binding(uuid,jsonb)","source_md5":"8b3b23a81afc7c2092902373cedbe0d2"},{"signature":"combat_v2_genjutsu_internal.event_public(text)","source_md5":"ecaea9744e8960072a32e7908856f9c0"},{"signature":"combat_v2_genjutsu_internal.kai_defense_valid(uuid,uuid)","source_md5":"1ab8564f473d8a008ba29e8095a4a6de"},{"signature":"combat_v2_genjutsu_internal.master_options(uuid,bigint)","source_md5":"0111ecc9e4034eb295e5a898cd4cd88e"},{"signature":"combat_v2_genjutsu_internal.movement_blocked(uuid)","source_md5":"8a243e907877525d58c71429cfbb8f98"},{"signature":"combat_v2_genjutsu_internal.narrative_facts(uuid)","source_md5":"de22bbd83e9ab8edb6a025e5131edde0"},{"signature":"combat_v2_genjutsu_internal.narrative_supported(uuid)","source_md5":"8c498c00f438621c617ae6132318ab66"},{"signature":"combat_v2_genjutsu_internal.open_turn(uuid,uuid)","source_md5":"701defaed0c81b0a6f4ccef2857a4a42"},{"signature":"combat_v2_genjutsu_internal.panel_options(uuid,bigint)","source_md5":"cb344a077d919955ef0f570ba9313d35"},{"signature":"combat_v2_genjutsu_internal.prepare(uuid,uuid,uuid,jsonb)","source_md5":"7275b845d7140c81fd2ec2ac48d3cd91"},{"signature":"combat_v2_genjutsu_internal.preset_ready(uuid)","source_md5":"b087938ff9bdc51ee5518c72beb88c04"},{"signature":"combat_v2_genjutsu_internal.profile()","source_md5":"87cf137eefa6f81cd178c039859c1c45"},{"signature":"combat_v2_genjutsu_internal.quote(uuid)","source_md5":"28ff62253407034032035e6acd8a2b6b"},{"signature":"combat_v2_genjutsu_internal.raw_attack_facts(uuid)","source_md5":"da147cc5595cac875224cbbebfe82ef8"},{"signature":"combat_v2_genjutsu_internal.real_owned(uuid)","source_md5":"f6e8ecb85aeb3c938cdc71eb0cbf80cd"},{"signature":"combat_v2_genjutsu_internal.record_event(text,uuid,jsonb)","source_md5":"9ba46dc99acb5e3063e0d813b55d0f3f"},{"signature":"combat_v2_genjutsu_internal.release_intents(uuid)","source_md5":"e1ddaf358a32b03d0ae3aed3023d57a7"},{"signature":"combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)","source_md5":"1d0416d6f715524c8ac1374dbabae55d"},{"signature":"combat_v2_genjutsu_internal.report_facts(uuid)","source_md5":"03c90f3dd07812d1061c7037216304d9"},{"signature":"combat_v2_genjutsu_internal.report_projection(uuid)","source_md5":"d3c2e36c0248730650a6c6c4b34d1e47"},{"signature":"combat_v2_genjutsu_internal.resolution_enter(uuid,uuid)","source_md5":"c45574805f3171628ef99392fa255eb2"},{"signature":"combat_v2_genjutsu_internal.resolution_leave()","source_md5":"612f97c08785e572226423ed5c1f68ed"},{"signature":"combat_v2_genjutsu_internal.resolve_release(uuid)","source_md5":"cb9fcdd4ff035ca7938144412be57e2c"},{"signature":"combat_v2_genjutsu_internal.runtime_allowed(uuid)","source_md5":"8512b2d982094a3b339de4ec3bfd3327"},{"signature":"combat_v2_genjutsu_internal.scope(uuid)","source_md5":"17ac15ea8ea5a734ff4eb0cc9d6e7f34"},{"signature":"combat_v2_genjutsu_internal.source_valid(uuid)","source_md5":"84ca595cfd34b8467b69c0256e94e254"},{"signature":"combat_v2_genjutsu_internal.staff_bind(uuid,uuid)","source_md5":"b8b6261b5c8f7df3c91400d5969d8eae"},{"signature":"combat_v2_genjutsu_internal.success(jsonb,integer,boolean)","source_md5":"90faca8a42e9f7f54726276f5a1e94bf"},{"signature":"combat_v2_genjutsu_internal.turn_end(uuid,uuid,uuid,text)","source_md5":"5130f380992a3585b502934e2833e716"},{"signature":"combat_v2_genjutsu_internal.turn_start(uuid,uuid,uuid,text)","source_md5":"b1781f3637f8c3414a9dd2c4038869c2"},{"signature":"combat_v2_genjutsu_internal.validate_attack_facts(jsonb)","source_md5":"0c6434b64a325213dbf8d18c603ed061"},{"signature":"combat_v2_genjutsu_internal.validate_release_facts(jsonb)","source_md5":"a46a047fa733321603e24a6102d7183d"}],"relations":[{"name":"combat_panel_private.cure_gate_v1","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":"true"},{"name":"staff_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"public_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"contract_version","type":"text","not_null":true,"default":"'palmo-curativo/1'::text"}]},{"name":"combat_panel_private.cure_ledger_v1","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"hp_before","type":"integer","not_null":true,"default":null},{"name":"hp_after","type":"integer","not_null":true,"default":null},{"name":"hp_max","type":"integer","not_null":true,"default":null},{"name":"expected_gain","type":"integer","not_null":true,"default":null},{"name":"committed_gain","type":"integer","not_null":true,"default":null},{"name":"applied_real_gain","type":"integer","not_null":true,"default":"0"},{"name":"is_simulated","type":"boolean","not_null":true,"default":null},{"name":"facts","type":"jsonb","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_preparations_v1","columns":[{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_staff_profiles_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"context_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"ability","type":"jsonb","not_null":true,"default":null},{"name":"proof_sha256","type":"text","not_null":true,"default":null},{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_voluntary_actions_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"source_kind","type":"text","not_null":true,"default":null},{"name":"source_key","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.effects","columns":[{"name":"id","type":"uuid","not_null":true,"default":"gen_random_uuid()"},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source_declaration_id","type":"uuid","not_null":true,"default":null},{"name":"source_attack_target_id","type":"uuid","not_null":true,"default":null},{"name":"source_actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"profile","type":"jsonb","not_null":true,"default":null},{"name":"source_outcome_sha256","type":"text","not_null":true,"default":null},{"name":"adapter","type":"text","not_null":true,"default":null},{"name":"excluded_turn_id","type":"uuid","not_null":false,"default":null},{"name":"due_turn_id","type":"uuid","not_null":false,"default":null},{"name":"state","type":"text","not_null":true,"default":null},{"name":"state_version","type":"bigint","not_null":true,"default":"1"},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"},{"name":"ended_at","type":"timestamp with time zone","not_null":false,"default":null},{"name":"end_reason","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.events","columns":[{"name":"event_key","type":"text","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":true,"default":null},{"name":"result_sha256","type":"text","not_null":true,"default":null},{"name":"binding","type":"jsonb","not_null":true,"default":null},{"name":"binding_sha256","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.gate","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":null},{"name":"enabled","type":"boolean","not_null":true,"default":null},{"name":"staff_enabled","type":"boolean","not_null":true,"default":null},{"name":"public_enabled","type":"boolean","not_null":true,"default":null},{"name":"version","type":"integer","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.preparations","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.release_plans","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"declaration_sha256","type":"text","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":false,"default":null},{"name":"result_sha256","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.sources","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"declaration_sha256","type":"text","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.staff_receipts","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"receipt","type":"jsonb","not_null":true,"default":null},{"name":"receipt_sha256","type":"text","not_null":true,"default":null}]}],"triggers":[{"table":"clan_akimichi_private.form_commands","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_hoki_private.combat_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_innata_combat_private.combat_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_inuzuka_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.control_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_sabaku_private.armor_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.master_movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.request_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"public.combat_v2_declarations","name":"cure_turn_defense_guard_v1","function":"combat_panel_private.cure_defense_guard_v1()","type":7}],"native_functions":[{"signature":"public.combat_v2_substitution_options_v1(uuid)","source_md5":"913cfd7a596794334b9b3ec8baa103a2","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_attack_declaration"],"arg_modes":null,"arg_types":"2950","ddl_md5":"1dc4d3088d39991411d875ec662c5123"},{"signature":"public.combat_v2_substitution_round_offers_v1(uuid,uuid)","source_md5":"7f3c2e198105d066aceb762872f51a3d","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_round","p_actor"],"arg_modes":null,"arg_types":"2950 2950","ddl_md5":"3a2b1781cc15da44f69cb940e527e864"},{"signature":"public.combat_v2_substitution_select_v1(uuid,uuid)","source_md5":"209648a06d537ad5b8870bdf8fe5c4cb","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_substitution_option_id","p_request_key"],"arg_modes":null,"arg_types":"2950 2950","ddl_md5":"f2f454ef2248e5f310fdfade6e868657"}]}$compat_metadata$::jsonb;
 shared_manifest jsonb:='[]';private_manifest jsonb:='[]';relation_manifest jsonb:='[]';trigger_manifest jsonb:='[]';
 native_manifest jsonb:='[]';changed_manifest jsonb;item jsonb;h jsonb;abi jsonb;cols jsonb;descriptor jsonb;next_descriptor jsonb;kv record;
 relation_oid oid;function_oid oid;actual_count integer;aliases integer:=0;
 shared_sha text;private_sha text;relations_sha text;
 pending_paths text[]:=ARRAY['["db_core"]'];current_path text[];stack_size integer;
BEGIN
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton;
 root:=rr.canonical_preimage::jsonb;binding:=root#>'{db_core,catalogo_eligibility_compat}';
 -- Legacy/recovery non acquisisce un PASS dal nuovo ramo: resta il sigillo storico completo.
 IF binding IS NULL OR binding->>'state'='inert_recovery' THEN RETURN false;END IF;
 IF binding->>'schema_version'IS DISTINCT FROM 'catalogo-eligibility-compat/1'
 OR binding->>'state'IS DISTINCT FROM 'active_compatibility'
 OR binding->>'parent_root'IS DISTINCT FROM 'f460be0a321e1640d7993a15285cf1b6352166cda41e991f0c644f29bd6a3658'
 OR binding->>'base_catalogo_source_bundle_sha256'IS DISTINCT FROM '825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5'
 OR coalesce(binding->>'source_bundle_sha256','')!~'^[0-9a-f]{64}$'
 OR coalesce(binding#>>'{review,sha256}','')!~'^[0-9a-f]{64}$'OR nullif(binding#>>'{review,ref}','')IS NULL
 OR binding#>'{review,P0}'IS DISTINCT FROM '0'::jsonb OR binding#>'{review,P1}'IS DISTINCT FROM '0'::jsonb OR binding#>'{review,P2}'IS DISTINCT FROM '0'::jsonb
 OR rr.state NOT IN('enabled','prepared')OR rr.scope<>'staff'OR NOT rr.staff_guards_verified OR NOT rr.published_assets_verified
 OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')IS DISTINCT FROM rr.revision_sha256
 OR octet_length(rr.canonical_preimage)>524288
 OR root#>>'{db_core,sha256}'IS DISTINCT FROM public.combat_v2_sha256((root->'db_core')-'sha256')
 OR root#>>'{config,sha256}'IS DISTINCT FROM public.combat_v2_sha256((root->'config')-'sha256')
 OR root#>>'{db_core,catalogo_completo,source_bundle_sha256}'IS DISTINCT FROM binding->>'base_catalogo_source_bundle_sha256'
 OR root#>'{config,catalogo_eligibility_compat}'IS DISTINCT FROM binding
 THEN RAISE EXCEPTION 'catalogo_eligibility_root_admission_drift';END IF;
 IF binding->>'normalized_source_identity_sha256'IS DISTINCT FROM '17fd985dfe72c4c6ad3638c01ad019a1f3deb1c21f587a6a0e98c39458e6550f'
 OR public.combat_v2_sha256(binding->'normalized_source_identity')IS DISTINCT FROM binding->>'normalized_source_identity_sha256'
 THEN RAISE EXCEPTION 'catalogo_eligibility_peer_identity_drift';END IF;
 IF EXISTS(WITH expected(sig,sha,acl)AS(VALUES ('combat_panel_private.mask_native_state(jsonb)','1d2f6ad44b2ff1e9c15d897e38fee54b67c744411081f906bc33a26a42600dac','postgres:EXECUTE:false'),('combat_panel_private.round_options_authoritative(uuid,uuid)','8202022a72be61ee4353130124718e8840a9c949e53cd9d4484301a52985ad7f','postgres:EXECUTE:false'),('combat_v2_elemental_internal.eligible_v1(uuid,uuid,boolean)','a5161f2993a4e0ce51864ac67ea88ba3fa6966457da1caf4ca390f17c2b1d8e9','postgres:EXECUTE:false,service_role:EXECUTE:false'),('combat_v2_elemental_internal.is_target_v1(uuid)','8af6bdfc87b76ed118b596f7c7885c6de849c5d89140f61cdd1845047cbd5724','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_actor_ability(uuid,text,uuid,boolean)','3f86b9972ead72801b6a4c392d2b180d011ca2605075855cd21a59b848f665e4','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_character_snapshot(uuid)','20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_round_options(uuid,uuid)','0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1','authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false'))SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig)
 WHERE p.oid IS NULL OR encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex')IS DISTINCT FROM e.sha
 OR p.proowner IS DISTINCT FROM 'postgres'::regrole OR p.prosecdef IS DISTINCT FROM true OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']
 OR(SELECT string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,','ORDER BY coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable)
 FROM aclexplode(coalesce(p.proacl,acldefault('f',p.proowner)))x LEFT JOIN pg_roles r ON r.oid=x.grantee)IS DISTINCT FROM e.acl)
 THEN RAISE EXCEPTION 'catalogo_eligibility_owning_port_drift';END IF;
 amendment:=root#>'{db_core,cure_command_amendment}';
 IF amendment->>'schema_version'IS DISTINCT FROM 'cure-command-amendment/1'OR coalesce(amendment->>'state','')NOT IN('active_amendment','inert_recovery')
 OR amendment->>'active_repair_kind'IS DISTINCT FROM 'palmo-ordinary-contact/1'
 OR amendment->>'commit_source_md5'IS DISTINCT FROM '61532836e90ed32ae807b92ee6632b71'
 OR amendment->>'normalized_source_identity_sha256'IS DISTINCT FROM '80ff4085fd32dde40d5ff008e54a95a2395f03f9767b5178c6ddb354cb882658'
 OR public.combat_v2_sha256(amendment->'normalized_source_identity')IS DISTINCT FROM amendment->>'normalized_source_identity_sha256'
 OR amendment->>'base_catalogo_source_bundle_sha256'IS DISTINCT FROM '825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5'
 OR amendment->>'base_compat_source_bundle_sha256'IS DISTINCT FROM binding->>'source_bundle_sha256'
 OR amendment->>'base_compat_source_bundle_sha256'IS DISTINCT FROM '654f8fff2f42019ffc4b3ccc6c467fff443ba81f00c7aa020fbd6d7950e2445e'
 OR amendment->>'base_private_functions_manifest_sha256'IS DISTINCT FROM root#>>'{db_core,catalogo_completo,private_functions_manifest_sha256}'
 OR coalesce(amendment->>'source_bundle_sha256','')!~'^[0-9a-f]{64}$'
 OR binding->>'active_amendment_source_bundle_sha256'IS DISTINCT FROM amendment->>'source_bundle_sha256'
 OR root#>'{config,cure_command_amendment}'IS DISTINCT FROM amendment
 OR coalesce(amendment#>>'{review,sha256}','')!~'^[0-9a-f]{64}$'OR nullif(amendment#>>'{review,ref}','')IS NULL
 OR amendment#>'{review,P0}'IS DISTINCT FROM '0'::jsonb OR amendment#>'{review,P1}'IS DISTINCT FROM '0'::jsonb OR amendment#>'{review,P2}'IS DISTINCT FROM '0'::jsonb
 THEN RAISE EXCEPTION 'cure_command_active_amendment_drift';END IF;
 IF amendment->>'state'='inert_recovery'AND NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE singleton AND NOT staff_enabled AND NOT public_enabled)THEN RAISE EXCEPTION 'cure_neutral_inert_requires_cure_off';END IF;
 -- Snapshot condiviso DOPO i delta PM. Nessuna esecuzione di corpi storici.
 FOR item IN SELECT value FROM jsonb_array_elements(params->'shared_functions') ORDER BY value->>'signature' LOOP
  SELECT jsonb_build_object('oid',p.oid::text,'signature',p.oid::regprocedure::text,
   'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,
   'volatility',p.provolatile::text,'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,
   'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),'arg_names',p.proargnames,'arg_modes',p.proargmodes,
   'arg_types',p.proargtypes::text,'leakproof',p.proleakproof,'nspname',n.nspname,'proname',p.proname)
   INTO h FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
   WHERE p.oid=to_regprocedure(item->>'signature') AND p.prokind='f';
  IF h IS NULL OR h->>'oid' IS DISTINCT FROM item->>'oid'
  OR h->>'source_md5' IS DISTINCT FROM item->>'source_md5' OR h->>'ddl_md5' IS DISTINCT FROM item->>'ddl_md5'
  OR h-ARRAY['source_md5','ddl_md5'] IS DISTINCT FROM item->'abi' THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_SHARED_ABI_OR_BODY_DRIFT:%',item->>'signature';END IF;
  shared_manifest:=shared_manifest||jsonb_build_array(h);
 END LOOP;
 IF (SELECT count(DISTINCT value->>'oid') FROM jsonb_array_elements(shared_manifest))<>jsonb_array_length(shared_manifest) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_DUPLICATE_SHARED_OID';END IF;
 -- Stack di soli percorsi: non replica l'intera Root in righe o gruppi SQL.
 WHILE coalesce(cardinality(pending_paths),0)>0 LOOP
  stack_size:=cardinality(pending_paths);
  SELECT ARRAY(SELECT jsonb_array_elements_text(pending_paths[stack_size]::jsonb)) INTO current_path;
  pending_paths:=pending_paths[1:stack_size-1];descriptor:=root#>current_path;
  IF jsonb_typeof(descriptor)='object' THEN
   SELECT value INTO h FROM jsonb_array_elements(shared_manifest) WHERE value->>'oid'=descriptor->>'oid';
   IF descriptor ? 'oid' AND h IS NOT NULL THEN
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor) WHERE key=ANY(ARRAY['owner','acl','config','secdef','strict','language','parallel','arg_modes','arg_names','arg_types','leakproof','returns','volatility','kind','signature','nspname','proname']) LOOP
     IF kv.value IS DISTINCT FROM h->kv.key THEN RAISE EXCEPTION 'CATALOGO_ROOT_ALIAS_ABI_DRIFT:%',array_to_string(current_path,'.');END IF;
    END LOOP;
    next_descriptor:=descriptor;
    IF descriptor ? 'source_md5' THEN next_descriptor:=jsonb_set(next_descriptor,'{source_md5}',h->'source_md5',false);END IF;
    IF descriptor ? 'ddl_md5' THEN next_descriptor:=jsonb_set(next_descriptor,'{ddl_md5}',h->'ddl_md5',false);END IF;
    IF next_descriptor IS DISTINCT FROM descriptor THEN RAISE EXCEPTION 'catalogo_eligibility_root_alias_drift';END IF;
    root:=jsonb_set(root,current_path,next_descriptor,false);aliases:=aliases+1;
   ELSE
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor) WHERE jsonb_typeof(value)IN('object','array') LOOP
     pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);
    END LOOP;
   END IF;
  ELSIF jsonb_typeof(descriptor)='array' THEN
   FOR kv IN SELECT(ord-1)::text AS key,value FROM jsonb_array_elements(descriptor)WITH ORDINALITY x(value,ord)
    WHERE jsonb_typeof(value)IN('object','array') LOOP
    pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);
   END LOOP;
  END IF;
 END LOOP;
 IF aliases IS DISTINCT FROM(params->>'expected_alias_count')::integer THEN RAISE EXCEPTION 'CATALOGO_ROOT_ALIAS_COUNT';END IF;
 shared_sha:=public.combat_v2_sha256(shared_manifest);

 FOR item IN SELECT value FROM jsonb_array_elements(params->'private_functions') ORDER BY value->>'signature' LOOP
  function_oid:=to_regprocedure(item->>'signature');
  SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,
   'volatility',p.provolatile::text,'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,
   'returns',pg_get_function_result(p.oid),'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)
   INTO h FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
   WHERE p.oid=function_oid AND p.prokind='f' AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND(p.proname LIKE 'cure\_%' ESCAPE '\' OR p.proname IN('catalog_result_label_v1','catalog_lifecycle_lines_v1'))));
  IF h IS NULL OR h->>'source_md5' IS DISTINCT FROM item->>'source_md5' OR h->>'owner'<>'postgres'
   OR has_function_privilege('anon',function_oid,'EXECUTE') OR has_function_privilege('authenticated',function_oid,'EXECUTE') THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_PRIVATE_BODY_OR_PRIVILEGE:%',item->>'signature';END IF;
  private_manifest:=private_manifest||jsonb_build_array(h);
 END LOOP;
 SELECT count(*) INTO actual_count FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
  WHERE p.prokind='f' AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND(p.proname LIKE 'cure\_%' ESCAPE '\' OR p.proname IN('catalog_result_label_v1','catalog_lifecycle_lines_v1'))));
 IF actual_count<>jsonb_array_length(private_manifest)
 OR actual_count<>(SELECT count(DISTINCT value->>'signature')FROM jsonb_array_elements(private_manifest)) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_PRIVATE_MANIFEST_COVERAGE';END IF;
 private_sha:=public.combat_v2_sha256(private_manifest);

 FOR item IN SELECT value FROM jsonb_array_elements(params->'relations') ORDER BY value->>'name' LOOP
  relation_oid:=to_regclass(item->>'name');
  SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),
   'not_null',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid))ORDER BY a.attnum) INTO cols
   FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum
   WHERE a.attrelid=relation_oid AND a.attnum>0 AND NOT a.attisdropped;
  SELECT jsonb_build_object('name',n.nspname||'.'||c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,
   'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'persistence',c.relpersistence::text,'columns',cols,
   'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',k.conname,'definition',pg_get_constraintdef(k.oid),'validated',k.convalidated)ORDER BY k.conname),'[]')FROM pg_constraint k WHERE k.conrelid=c.oid),
   'indexes',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',ic.relname,'definition',pg_get_indexdef(i.indexrelid),'valid',i.indisvalid)ORDER BY ic.relname),'[]')FROM pg_index i JOIN pg_class ic ON ic.oid=i.indexrelid WHERE i.indrelid=c.oid),
   'policies',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',p.polname,'command',p.polcmd,'roles',p.polroles::text,'using',pg_get_expr(p.polqual,p.polrelid),'check',pg_get_expr(p.polwithcheck,p.polrelid))ORDER BY p.polname),'[]')FROM pg_policy p WHERE p.polrelid=c.oid))
   INTO h FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid=relation_oid AND c.relkind IN('r','p')
    AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND c.relname LIKE 'cure\_%' ESCAPE '\'));
  IF h IS NULL OR h->'rls' IS DISTINCT FROM 'true'::jsonb OR h->>'owner'<>'postgres' OR cols IS DISTINCT FROM item->'columns'
   OR has_table_privilege('anon',relation_oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
   OR has_table_privilege('authenticated',relation_oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER') THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_RELATION_SCHEMA_OR_PRIVILEGE:%',item->>'name';END IF;
  relation_manifest:=relation_manifest||jsonb_build_array(h);
 END LOOP;
 SELECT count(*) INTO actual_count FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE c.relkind IN('r','p')AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND c.relname LIKE 'cure\_%' ESCAPE '\'));
 IF actual_count<>jsonb_array_length(relation_manifest)
 OR actual_count<>(SELECT count(DISTINCT value->>'name')FROM jsonb_array_elements(relation_manifest))THEN RAISE EXCEPTION 'CATALOGO_ROOT_RELATION_COVERAGE';END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(params->'triggers') ORDER BY value->>'table',value->>'name' LOOP
  SELECT jsonb_build_object('table',item->'table','name',t.tgname,'function',t.tgfoid::regprocedure::text,
   'type',t.tgtype,'enabled',t.tgenabled::text,'definition',pg_get_triggerdef(t.oid),'arguments_sha256',encode(extensions.digest(t.tgargs,'sha256'),'hex'))
   INTO h FROM pg_trigger t JOIN pg_proc tf ON tf.oid=t.tgfoid JOIN pg_namespace tn ON tn.oid=tf.pronamespace
   WHERE t.tgrelid=to_regclass(item->>'table')AND t.tgname=item->>'name'AND NOT t.tgisinternal
    AND tn.nspname='combat_panel_private'AND tf.proname LIKE 'cure\_%' ESCAPE '\';
  IF h IS NULL OR h->>'function' IS DISTINCT FROM item->>'function' OR h->'type' IS DISTINCT FROM item->'type'
   OR h->>'enabled' IS DISTINCT FROM 'O' THEN RAISE EXCEPTION 'CATALOGO_ROOT_TRIGGER_PIN:%',item->>'name';END IF;
  trigger_manifest:=trigger_manifest||jsonb_build_array(h);
 END LOOP;
 IF (SELECT count(DISTINCT jsonb_build_array(value->'table',value->'name'))FROM jsonb_array_elements(trigger_manifest))<>10
 OR (SELECT count(*)FROM pg_trigger t JOIN pg_proc f ON f.oid=t.tgfoid JOIN pg_namespace n ON n.oid=f.pronamespace
  WHERE NOT t.tgisinternal AND n.nspname='combat_panel_private' AND f.proname LIKE 'cure\_%' ESCAPE '\')<>10 THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_TRIGGER_COVERAGE';END IF;
 relations_sha:=public.combat_v2_sha256(jsonb_build_object('relations',relation_manifest,'triggers',trigger_manifest));

 IF shared_sha IS DISTINCT FROM amendment->>'shared_manifest_sha256'
 OR private_sha IS DISTINCT FROM amendment->>'private_functions_manifest_sha256'
 OR relations_sha IS DISTINCT FROM root#>>'{db_core,catalogo_completo,relations_manifest_sha256}'
 OR shared_sha IS DISTINCT FROM binding->>'shared_manifest_sha256'
 OR private_sha IS DISTINCT FROM binding->>'private_functions_manifest_sha256'
 OR relations_sha IS DISTINCT FROM binding->>'relations_manifest_sha256'
 THEN RAISE EXCEPTION 'catalogo_eligibility_integrated_manifest_drift';END IF;

 -- Three owning substitution ports, exact bodies/ABI; authority stays native.
 FOR item IN SELECT value FROM jsonb_array_elements(params->'native_functions')ORDER BY value->>'signature'LOOP
  SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
   'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'returns',pg_get_function_result(p.oid),
   'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)INTO h
   FROM pg_proc p JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=to_regprocedure(item->>'signature')AND p.prokind='f';
  IF h IS DISTINCT FROM item THEN RAISE EXCEPTION 'cure_reaction_native_body_or_abi_drift:%',item->>'signature';END IF;
  native_manifest:=native_manifest||jsonb_build_array(h);
 END LOOP;
 IF jsonb_array_length(native_manifest)<>3 OR public.combat_v2_sha256(native_manifest)IS DISTINCT FROM amendment->>'native_functions_manifest_sha256'
 THEN RAISE EXCEPTION 'cure_reaction_native_manifest_drift';END IF;
 -- Own helper metadata is bound externally by the reviewed Root, never a literal self hash.
 SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
  'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)
  ORDER BY p.oid::regprocedure::text)INTO changed_manifest FROM pg_proc p WHERE p.oid IN(
  'combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,
  'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,
  'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure);
 IF jsonb_array_length(changed_manifest)<>6 OR public.combat_v2_sha256(changed_manifest)IS DISTINCT FROM amendment->>'functions_manifest_sha256'
 THEN RAISE EXCEPTION 'cure_reaction_changed_manifest_drift';END IF;
 RETURN true;
END $function$
;
CREATE OR REPLACE FUNCTION combat_panel_private.master_projection(p_location uuid, p_actor uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE multiplication jsonb; src jsonb; c combat_panel_private.contexts%ROWTYPE; sid uuid; mid uuid; rid uuid; actor uuid;
 is_master boolean; is_admin boolean; is_test boolean; simulated boolean; policy text; phase text; phase_label text;
 controlled jsonb:='[]'; roster jsonb:='[]'; item jsonb; resources jsonb; map_view jsonb:=null;
 companion_view jsonb:=null; sabaku_view jsonb:=null; narrative_view jsonb:=null; narrative_meta jsonb; meta public.combat_v2_actors%ROWTYPE;
 actor_state text; distance numeric; body_only boolean; due boolean; selected boolean;
BEGIN
 src:=public.master_v2_ui_state(p_location)->'data';
 IF src->>'publication_state'='pending' AND src->>'reason_code'='REGIA_FATO_PENDING' THEN
  RETURN jsonb_build_object('schema_version','combat-panel/1','status','blocked','reason_code','REGIA_FATO_PENDING',
   'context',NULL,'viewer',jsonb_build_object('command_actor_id',NULL,'controlled_actors','[]'::jsonb,
    'is_master',false,'is_admin',coalesce((src#>>'{viewer,is_admin}')::boolean,false),'can_command',false),
   'actors','[]'::jsonb,'map',NULL,'offers','[]'::jsonb,'movement_explanations',NULL,'companion',NULL,
   'sabaku_transport',NULL,'aburame_colony',NULL,'multiplication',NULL,'narrative',NULL,'receipt',NULL,'round_details',NULL);
 END IF;
 is_master:=coalesce((src#>>'{viewer,is_master}')::boolean,false);
 is_admin:=coalesce((src#>>'{viewer,is_admin}')::boolean,false);
 mid:=(src#>>'{master,id}')::uuid;
 IF mid IS NULL THEN is_master:=coalesce(public.master_v2_is_master(exam_regia_private.current_principal()),false); END IF; sid:=(src#>>'{encounter,id}')::uuid; rid:=(src#>>'{round,id}')::uuid;
 SELECT coalesce(l.is_test,false) INTO is_test FROM public.locations l WHERE l.id=p_location AND l.is_active;
 IF NOT FOUND THEN RAISE EXCEPTION 'panel_location_not_available' USING ERRCODE='42501'; END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(src->'actors') LOOP
   IF coalesce((item->>'mine')::boolean,false) AND EXISTS(SELECT 1 FROM public.combat_v2_actors
     WHERE id=(item->>'id')::uuid AND session_id=sid AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL) THEN
     controlled:=controlled||jsonb_build_array(jsonb_build_object('actor_id',item->'id','label',item->'name'));
   END IF;
 END LOOP;
 actor:=p_actor;
 IF actor IS NULL AND NOT(is_master OR is_admin) AND jsonb_array_length(controlled)>0 THEN
   actor:=(controlled#>>'{0,actor_id}')::uuid;
 END IF;
 IF actor IS NOT NULL AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(controlled) AS a(value)
   WHERE value->>'actor_id'=actor::text) THEN
   RAISE EXCEPTION 'panel_actor_not_controlled' USING ERRCODE='42501'; END IF;
 phase:=CASE WHEN src#>>'{master,stato}'='sospesa' OR src#>>'{encounter,state}'='sospeso' THEN 'suspended'
   WHEN sid IS NULL OR rid IS NULL THEN 'setup'
   WHEN NOT EXISTS(SELECT 1 FROM combat_spatial.arena_instances WHERE encounter_id=sid)
     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d JOIN public.combat_v2_rounds r ON r.id=d.round_id WHERE r.session_id=sid) THEN 'setup'
   ELSE CASE src#>>'{round,phase}' WHEN 'raccolta_azioni' THEN 'action' WHEN 'raccolta_difese' THEN 'defense'
     WHEN 'congelato' THEN 'review' WHEN 'valutazione' THEN 'review' WHEN 'risoluzione' THEN 'resolving'
     WHEN 'risolto' THEN 'resolved' WHEN 'narrazione' THEN 'resolved' WHEN 'narrato' THEN 'resolved' ELSE NULL END END;
 IF phase IS NULL THEN RAISE EXCEPTION 'panel_master_phase_unsupported' USING ERRCODE='22023'; END IF;
 phase_label:=CASE phase WHEN 'setup' THEN 'Preparazione dello scontro' WHEN 'action' THEN 'Raccolta delle azioni'
   WHEN 'defense' THEN 'Raccolta delle difese' WHEN 'review' THEN 'Valutazione del Master'
   WHEN 'resolving' THEN 'Risoluzione in corso' WHEN 'resolved' THEN 'Esito del round' ELSE 'Scontro sospeso' END;
 IF rid IS NOT NULL AND combat_panel_private.human_duel_round(rid) THEN
   phase_label:=CASE phase WHEN 'action' THEN 'Duello a iniziativa · turno di attacco'
     WHEN 'defense' THEN 'Duello a iniziativa · risposta difensiva' ELSE phase_label END;
 END IF;
 simulated:=CASE WHEN sid IS NULL THEN is_test ELSE NOT public.combat_v2_values_written(sid) END;
 policy:=CASE WHEN exam_human_private.execution_session_v1(mid) THEN 'exam_protected_no_persistent_resources_v1' WHEN exam_regia_private.is_bound(sid) THEN 'exam_protected_no_persistent_resources_v1' WHEN is_test THEN 'staff_test_no_persistent_resources_v1' ELSE 'master_game_resources_v1' END;
 IF sid IS NOT NULL AND (actor IS NOT NULL OR is_master OR is_admin) THEN
   map_view:=combat_panel_private.master_map(sid,actor);
 END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(src->'actors') LOOP
   SELECT * INTO STRICT meta FROM public.combat_v2_actors WHERE id=(item->>'id')::uuid AND session_id=sid;
   body_only:=meta.companion_id IS NOT NULL;
   actor_state:=CASE item->>'state' WHEN 'attivo' THEN 'active' WHEN 'fuori' THEN 'out' WHEN 'ritirato' THEN 'withdrawn' ELSE NULL END;
   IF actor_state IS NULL THEN RAISE EXCEPTION 'panel_actor_state_unsupported' USING ERRCODE='22023'; END IF;
   selected:=actor IS NOT NULL AND meta.id=actor;
   resources:=combat_panel_private.participant_resources(sid,meta.id,simulated);
   distance:=NULL;
   IF jsonb_typeof(map_view->'pov')='object' AND NOT selected THEN
     SELECT round(combat_spatial.distance_m((map_view#>>'{pov,x_m}')::numeric,(map_view#>>'{pov,y_m}')::numeric,
       (value->>'x_m')::numeric,(value->>'y_m')::numeric),2) INTO distance
       FROM jsonb_array_elements(map_view->'actors') WHERE value->>'actor_id'=meta.id::text;
   END IF;
   -- Il compagno resta passivo: risponde il controllore tramite le stesse
   -- difese ammesse dal consumer, anche con Fili recisi (Nessuna difesa).
   due:=NOT body_only AND actor_state='active' AND phase='defense'
     AND (is_master OR is_admin OR exam_regia_private.actor_principal(meta.id,meta.controller_user)=exam_regia_private.current_principal())
     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d
       WHERE d.round_id=rid AND d.actor_id=meta.id AND d.kind IN ('difesa','nessuna'))
     AND EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t
       WHERE t.round_id=rid AND t.state='attesa_difesa' AND (
         t.target_actor_id=meta.id OR (
           EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(map_view->'actors','[]')) v
             WHERE v->>'actor_id'=t.target_actor_id::text)
           AND clan_marionettisti_private.defends_body(meta.id,t.target_actor_id,'nessuna'))));
   roster:=roster||jsonb_build_array(jsonb_build_object('actor_id',meta.id,
     'kind',CASE WHEN body_only THEN 'companion' ELSE meta.actor_kind END,'body_only',body_only,
     'display_name',CASE WHEN body_only THEN coalesce((
       SELECT to_jsonb(CASE
         WHEN clan_marionettisti_private.actor_visible(sid,meta.id,exam_regia_private.current_principal())
           THEN coalesce(nullif(btrim(cc.name),''),'Ninken')
         ELSE 'Ninken' END)
       FROM public.character_companions cc
       JOIN clan_marionettisti_private.sources ns ON ns.id=cc.id
          AND ns.profile_version='ninken-l1/1' AND ns.owner_character_id=cc.character_id
          AND ns.real_companion_id=cc.id AND ns.source_kind='real'
       WHERE cc.id=meta.companion_id AND cc.kind='cane_ninja'
     ),to_jsonb('Marionetta'::text)) ELSE item->'name' END,'team',item->'team','state',actor_state,'mine',selected,
     'action_due',NOT body_only AND actor_state='active' AND phase='action' AND combat_panel_private.human_duel_turn_allowed(rid,meta.id) AND mission_generic_owner.unified_turn_allowed(rid,meta.id) AND NOT coalesce((item->>'has_action')::boolean,false),
     'defense_due',due,'resources',resources,'distance_from_viewer_m',distance));
 END LOOP;
 IF sid IS NOT NULL AND rid IS NOT NULL THEN
   narrative_meta:=combat_panel_private.narrative_details(p_location,sid,rid);
   narrative_view:=jsonb_build_object('schema_version','combat-panel-narrative/1','activity_id',sid,'round_id',rid,
     'mode','human','state',CASE WHEN narrative_meta#>>'{last_published,round_id}'=rid::text THEN 'published'
       WHEN phase='resolved' THEN 'waiting' ELSE 'idle' END,'reason_code',null,
     'report_id',narrative_meta->'report_id','report_sha256',narrative_meta->'report_sha256',
     'last_published',narrative_meta->'last_published');
 END IF;
 multiplication:=combat_panel_private.multiplication_view(p_location,map_view->'actors');
 map_view:=combat_panel_private.multiplication_mask_map(map_view,multiplication);
 roster:=combat_panel_private.multiplication_mask_roster(roster,multiplication);
 -- Versione fissa per il fingerprint: non dipende dalla versione che genera.
 companion_view:=combat_panel_private.master_companion_projection(actor);
 sabaku_view:=clan_sabaku_private.master_panel_projection(actor,1);
 c:=combat_panel_private.refresh_context(p_location,actor,
   CASE WHEN coalesce(sid,mid) IS NULL THEN NULL ELSE 'master_v2' END,coalesce(sid,mid),rid,
   (map_view->>'map_version')::bigint,(jsonb_build_object('participant_resources',roster,'multiplication',multiplication,'is_master',is_master,'is_admin',is_admin,'source',src,'map',map_view,'narrative',narrative_view,'sabaku',sabaku_view,'companion',companion_view,
     -- Stato nativo stabile: il preset cambia le offerte senza consumare una principale.
     -- Solo fingerprint interno; nessun dato aggiunto alla risposta del viewer.
     'other_control_state',(SELECT coalesce(jsonb_agg(jsonb_build_object('technique_id',z.technique_id,'controller_version',z.controller_version,'receipt_sha256',z.receipt_sha256) ORDER BY z.technique_id,z.controller_version),'[]'::jsonb) FROM combat_v2_elemental_internal.other_staff_receipts z WHERE z.actor_id=actor AND z.session_id=sid),
     'suiton_control_state',(SELECT coalesce(jsonb_agg(jsonb_build_object(
       'technique_id',s.technique_id,'controller_version',s.controller_version,'receipt_sha256',s.receipt_sha256)
       ORDER BY s.technique_id,s.controller_version),'[]'::jsonb)
       FROM combat_v2_elemental_internal.suiton_staff_receipts s WHERE s.actor_id=actor AND s.session_id=sid),
     'scudo_control_state',(SELECT coalesce(jsonb_agg(jsonb_build_object(
       'technique_id',s.technique_id,'controller_version',s.controller_version,'receipt_sha256',s.receipt_sha256) ORDER BY s.technique_id,s.controller_version),'[]'::jsonb) FROM combat_v2_elemental_internal.scudo_staff_receipts s WHERE s.actor_id=actor AND s.session_id=sid),
     'hyuga_control_state',jsonb_build_object(
       'profiles',(SELECT coalesce(jsonb_agg(jsonb_build_object('profile_version',h.profile_version,'active',h.is_active)
           ORDER BY h.profile_version,h.is_active,h.created_request),'[]'::jsonb)
         FROM clan_hyuga_private.staff_profiles h WHERE h.actor_id=actor AND h.session_id=sid),
       'offensive_receipts',(SELECT count(*) FROM clan_hyuga_private.offensive_staff_receipts h
         WHERE h.actor_id=actor AND h.session_id=sid),
       'byakugan',(SELECT coalesce(jsonb_agg(jsonb_build_object('technique_id',h.technique_id,'active',h.active,'state_version',h.state_version)ORDER BY h.technique_id),'[]'::jsonb)
         FROM clan_innata_combat_private.combat_state h WHERE h.actor_id=actor AND h.session_id=sid AND h.technique_id IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid)))) ||
     -- Il preset Katon cambia le offerte disponibili nella simulazione Staff.
     CASE WHEN p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND simulated THEN
       jsonb_strip_nulls(jsonb_build_object('staff_katon_receipt',(
         SELECT f.receipt_sha256
         FROM clan_uchiha_private.fireball_staff_receipts f
         JOIN public.combat_v2_actors a ON a.id=f.actor_id AND a.session_id=f.session_id
           AND a.controller_user=f.controller_user AND a.controller_version=f.controller_version
         JOIN clan_hyuga_private.staff_profiles h ON h.actor_id=f.actor_id AND h.session_id=f.session_id
           AND h.profile_version='sharingan-l1/1' AND h.is_active AND h.created_request=f.common_profile_request
         WHERE f.actor_id=actor AND f.session_id=sid
       )))
     ELSE '{}'::jsonb END ||
     -- La ricevuta Staff Paralisi cambia le offerte; il dato resta nel solo fingerprint.
     -- Senza una ricevuta valida il contributo e' {}, quindi non invalida altri contesti.
     (CASE WHEN simulated AND actor IS NOT NULL
       AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN
       jsonb_strip_nulls(jsonb_build_object('staff_paralisi_receipt',(
         SELECT g.receipt_sha256 FROM combat_v2_genjutsu_internal.staff_receipts g
         JOIN public.combat_v2_actors pa ON pa.id=g.actor_id AND pa.session_id=g.session_id
          AND pa.controller_user=g.controller_user AND pa.controller_version=g.controller_version
         WHERE g.actor_id=actor AND g.session_id=sid
          AND combat_v2_genjutsu_internal.binding(pa.id) IS NOT NULL
       ))) ELSE '{}'::jsonb END) ||
     -- Le offerte Inuzuka dipendono dal profilo e dallo stato di Quattro Zampe.
     (CASE WHEN simulated AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN
       jsonb_strip_nulls(jsonb_build_object('staff_inuzuka_abilities',(
         SELECT jsonb_agg(skill.doc->>'id' ORDER BY skill.doc->>'id') FROM public.combat_v2_actors a
         CROSS JOIN LATERAL jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]'::jsonb)) skill(doc)
         WHERE a.id=actor AND a.session_id=sid AND skill.doc->>'source'='clan'
           AND skill.doc->>'id' IN ('b0748ef4-bea8-4d85-95a1-7d9db1b4381c','c11ecd52-43cd-479b-8d5d-08187beba56e','b076a976-c75b-4b5a-8813-b0e8e2c3af03')
       ))) ELSE '{}'::jsonb END) ||
     jsonb_strip_nulls(jsonb_build_object('inuzuka_quattro_state',(
       SELECT jsonb_agg(jsonb_build_array(q.active,q.state_version) ORDER BY q.state_version,q.active)
       FROM clan_innata_combat_private.combat_state q WHERE q.actor_id=actor AND q.session_id=sid
       AND q.technique_id='c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid
     )))));
 RETURN clan_hoki_private.panel_projection(clan_inuzuka_private.master_projection(
   clan_sabaku_private.clone_attach_map(jsonb_build_object('schema_version','combat-panel/1','status','ready','reason_code',null,
   'context',jsonb_build_object('activity_id',coalesce(sid,mid),'activity_kind',c.activity_kind,
     'location_id',p_location,'round_id',rid,'round_no',to_jsonb(exam_regia_private.logical_round_no(rid)),'phase',phase,'phase_label',phase_label,
     'version',c.context_version,'scene_version',c.scene_version,'policy_id',policy,'simulated',simulated),
   'viewer',jsonb_build_object('command_actor_id',actor,'controlled_actors',controlled,'is_master',is_master,
     'is_admin',is_admin,'can_command',is_master OR is_admin OR (actor IS NOT NULL AND (phase='defense' OR (phase='action' AND combat_panel_private.human_duel_turn_allowed(rid,actor) AND mission_generic_owner.unified_turn_allowed(rid,actor))))),
   'actors',roster,'map',map_view,'offers','[]'::jsonb,'movement_explanations',null,
   'multiplication',multiplication,'companion',companion_view,'sabaku_transport',CASE WHEN sabaku_view IS NULL THEN NULL
     ELSE jsonb_set(sabaku_view,'{context_version}',to_jsonb(c.context_version)) END,'narrative',narrative_view,
   'round_details',combat_panel_private.round_details_from_source(src,roster),'receipt',null))));
END $function$
;
DO $catalogo_root$
DECLARE
 expected_parameters_sha256 constant text:='__STAFF_ENTRY_REPAIRS_PARAMETERS_SHA256__';
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
 params:=nullif(current_setting('app.staff_entry_repairs_parameters',true),'')::jsonb;old_root_sha:=params#>>'{expected_current,root_sha256}';old_row_sha:=params#>>'{expected_current,root_row_sha256}';
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF rr.revision_sha256<>old_root_sha OR rr.observed_revision_sha256 IS DISTINCT FROM old_root_sha
 OR public.combat_v2_sha256(to_jsonb(rr))<>old_row_sha
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')<>old_root_sha
 OR octet_length(rr.canonical_preimage)<>(params#>>'{expected_current,root_bytes}')::integer THEN RAISE EXCEPTION 'CATALOGO_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso' AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata') AND closed_at IS NULL) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REQUIRES_QUIESCENCE';END IF;
 params:=nullif(current_setting('app.staff_entry_repairs_parameters',true),'')::jsonb;
 IF expected_parameters_sha256 !~ '^[0-9a-f]{64}$' OR params IS NULL
 OR public.combat_v2_sha256(params)<>expected_parameters_sha256
 OR params->>'schema_version' IS DISTINCT FROM 'staff-entry-repairs-parameters/1' THEN
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
 WHERE p.prokind='f'AND p.oid IN('combat_panel_private.cure_contact_v1(uuid,uuid)'::regprocedure,'combat_panel_private.master_projection(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)ORDER BY p.oid::regprocedure::text)
  INTO relation_manifest FROM pg_proc p WHERE p.oid IN('clan_innata_private.eligibility_release_assert()'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
 shared_sha:=public.combat_v2_sha256(shared_manifest);private_sha:=public.combat_v2_sha256(private_manifest);
 IF jsonb_array_length(shared_manifest)<>34 OR jsonb_array_length(private_manifest)<>66 OR jsonb_array_length(native_manifest)<>3
 OR jsonb_array_length(changed_headers)<>3 OR jsonb_array_length(relation_manifest)<>2 OR shared_sha<>'8f5350768fd6b922001f0f3ec84631852d36391e9858ef9df5a5c35cc4c9a8f9'OR private_sha<>'738506bdca70d1a39219535f7aa12ffc8dc4c1807939b9b6d8f986c9890f0833'
 OR public.combat_v2_sha256(native_manifest)<>'2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f'THEN RAISE EXCEPTION 'cure_reaction_post_manifest_drift';END IF;
 IF jsonb_array_length(trigger_manifest)<>6 OR public.combat_v2_sha256(trigger_manifest)<>'b1ea13b3d629d9b3063b28b020447e0fc6d9e7d579782e66f12379f4dac7820c'THEN RAISE EXCEPTION 'palmo_completion_peer6_drift';END IF;
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
 IF aliases<>2 THEN RAISE EXCEPTION 'staff_entry_repairs_alias_count';END IF;
 binding:=$entry_amendment${"state":"active_amendment","parent_root":"b3e9fcf8927cf169969f53dc642fe9d4b37fac38450e51c816f51bf4e59a926f","schema_version":"cure-command-amendment/1","commit_source_md5":"61532836e90ed32ae807b92ee6632b71","helper_source_md5":"87a4cf8d832bc113c49eeca55c127bb9","active_repair_kind":"palmo-ordinary-contact/1","neutral_source_md5":"0f48477bfc086b98e113e2dd70bba0de","source_bundle_sha256":"680f9d1d43250a7a62ad29537a6d0b2ac13abfdc06f510372c669794b15a403d","shared_manifest_sha256":"8f5350768fd6b922001f0f3ec84631852d36391e9858ef9df5a5c35cc4c9a8f9","functions_manifest_sha256":"b1ea13b3d629d9b3063b28b020447e0fc6d9e7d579782e66f12379f4dac7820c","normalized_source_identity":{"schema_version":"palmo-ordinary-contact-peer-amendment/1","parent_root":"b3e9fcf8927cf169969f53dc642fe9d4b37fac38450e51c816f51bf4e59a926f","previous_source_bundle_sha256":"085482ab9fe948763eaf77e9bdd3f8580e2b86f95be108b3198c765828139278","previous_amendment_identity_sha256":"7c24a6b523c5f05714bfd0f085e4963664486b2b064f4dde850e3a09bd66b248","private_functions_manifest_sha256":"738506bdca70d1a39219535f7aa12ffc8dc4c1807939b9b6d8f986c9890f0833","shared_manifest_sha256":"8f5350768fd6b922001f0f3ec84631852d36391e9858ef9df5a5c35cc4c9a8f9","native_functions_manifest_sha256":"2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f","publisher_source_md5":"5bc0eeaea3b3b64578105067b4b40c28","qa_state":"ORDINARY_SELF_NOT_RUN","staff_pass":false,"public_enabled":false},"base_compat_source_bundle_sha256":"654f8fff2f42019ffc4b3ccc6c467fff443ba81f00c7aa020fbd6d7950e2445e","native_functions_manifest_sha256":"2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f","normalized_source_identity_sha256":"80ff4085fd32dde40d5ff008e54a95a2395f03f9767b5178c6ddb354cb882658","private_functions_manifest_sha256":"738506bdca70d1a39219535f7aa12ffc8dc4c1807939b9b6d8f986c9890f0833","base_catalogo_source_bundle_sha256":"825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5","base_private_functions_manifest_sha256":"3eb9bba89fc99206710cd079207631f4949dec9893a38d97d7d46e07386b5cc0","previous_cure_command_source_bundle_sha256":"085482ab9fe948763eaf77e9bdd3f8580e2b86f95be108b3198c765828139278"}$entry_amendment$::jsonb;
 binding:=binding||jsonb_build_object('state','active_amendment','source_bundle_sha256','680f9d1d43250a7a62ad29537a6d0b2ac13abfdc06f510372c669794b15a403d','review',review,
   'availability',(SELECT jsonb_build_object('cure_staff_enabled',c.staff_enabled,'cure_public_enabled',c.public_enabled,
    'paralisi_staff_enabled',g.staff_enabled,'paralisi_public_enabled',g.public_enabled)
    FROM combat_panel_private.cure_gate_v1 c CROSS JOIN combat_v2_genjutsu_internal.gate g WHERE c.singleton AND g.singleton));
 root:=jsonb_set(root,'{db_core,cure_command_amendment}',binding,false);root:=jsonb_set(root,'{config,cure_command_amendment}',binding,false);
 cfg:=root#>'{db_core,catalogo_eligibility_compat}';
 cfg:=cfg||jsonb_build_object('shared_manifest_sha256',shared_sha,'private_functions_manifest_sha256',private_sha,'helper_source_md5','87a4cf8d832bc113c49eeca55c127bb9',
  'active_amendment_source_bundle_sha256',binding->'source_bundle_sha256','functions',relation_manifest,'functions_manifest_sha256',public.combat_v2_sha256(relation_manifest));
 root:=jsonb_set(root,'{db_core,catalogo_eligibility_compat}',cfg,false);root:=jsonb_set(root,'{config,catalogo_eligibility_compat}',cfg,false);
 descriptor:=jsonb_build_object('schema_version','paralisi-profile-refresh/1',
  'source_bundle_sha256','9c9c84ddb2fcc037b0b2164877d296c72a99529b86f3dfcaf59e5c62d4cb65c3','projection_source_md5','271ea56acb5f135ad6e3d24d8601e3b1',
  'integrated_source_bundle_sha256',params->'source_bundle_sha256','review',review);
 root:=jsonb_set(root,'{db_core,paralisi_profile_refresh}',descriptor,true);
 root:=jsonb_set(root,'{config,paralisi_profile_refresh}',descriptor,true);
 core:=root->'db_core';db_sha:=public.combat_v2_sha256(core-'sha256');core:=jsonb_set(core,'{sha256}',to_jsonb(db_sha),false);root:=jsonb_set(root,'{db_core}',core,false);
 cfg:=root->'config';config_sha:=public.combat_v2_sha256(cfg-'sha256');cfg:=jsonb_set(cfg,'{sha256}',to_jsonb(config_sha),false);root:=jsonb_set(root,'{config}',cfg,false);
 expected_ui:=before_root->'ui';
 IF public.combat_v2_sha256(expected_ui)IS DISTINCT FROM 'cd76714cb188ea3f69189ac5dd793304acdc2179da724aad852f961d12ab3014' THEN RAISE EXCEPTION 'cure_entry_recovery_ui_drift';END IF;
 identity:=jsonb_build_object('schema_version','staff-entry-repairs-code-identity/1','parent_root',old_root_sha,'parent_code_identity',before_root#>'{contract,code_identity_sha256}',
  'normalized_amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,
  'active_private_functions_manifest_sha256',private_sha,'native_functions_manifest_sha256',binding->'native_functions_manifest_sha256',
  'source_bundle_sha256',params->'source_bundle_sha256','db_sha256',db_sha,'client_sha256',public.combat_v2_sha256(root->'ui'),'ui_graph_sha256',root#>>'{ui,import_graph_sha256}','amendment_state',binding->'state');
 identity_sha:=public.combat_v2_sha256(identity);root:=jsonb_set(root,'{contract,code_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,semantic_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,cure_command_amendment}',jsonb_build_object('parent_root',old_root_sha,'state',binding->'state',
  'previous_semantic_identity',before_root#>'{recovery,semantic_identity_sha256}','policy','forward_cure_genjutsu_off_keep_entry_repairs'),false);
 IF root->'ui'IS DISTINCT FROM expected_ui OR root->'edge_bundles'IS DISTINCT FROM before_root->'edge_bundles'
 OR(root->'config')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat','paralisi_profile_refresh']IS DISTINCT FROM(before_root->'config')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat','paralisi_profile_refresh']
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
 PERFORM set_config('app.staff_entry_repairs_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),
  'db_sha256',db_sha,'configuration_sha256',config_sha,'code_identity_sha256',identity_sha,'aliases_updated',aliases,
  'amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,'active_private_functions_manifest_sha256',private_sha,
  'new_techniques_staff_pass',false,'provider_calls',0)::text,true);
END $catalogo_root$;
DO $contact_post$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;r jsonb;a jsonb;
BEGIN
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton;
 r:=rr.canonical_preimage::jsonb;a:=r#>'{db_core,cure_command_amendment}';
 IF a IS NULL OR a IS DISTINCT FROM r#>'{config,cure_command_amendment}'
 OR a->>'active_repair_kind' IS DISTINCT FROM 'palmo-ordinary-contact/1'
 OR a->>'source_bundle_sha256' IS DISTINCT FROM '680f9d1d43250a7a62ad29537a6d0b2ac13abfdc06f510372c669794b15a403d'
 OR a->>'normalized_source_identity_sha256' IS DISTINCT FROM '80ff4085fd32dde40d5ff008e54a95a2395f03f9767b5178c6ddb354cb882658'
 OR a->>'private_functions_manifest_sha256' IS DISTINCT FROM '738506bdca70d1a39219535f7aa12ffc8dc4c1807939b9b6d8f986c9890f0833'
 OR a->>'functions_manifest_sha256' IS DISTINCT FROM 'b1ea13b3d629d9b3063b28b020447e0fc6d9e7d579782e66f12379f4dac7820c'
 OR a#>'{review,P0}' IS DISTINCT FROM '0'::jsonb OR a#>'{review,P1}' IS DISTINCT FROM '0'::jsonb OR a#>'{review,P2}' IS DISTINCT FROM '0'::jsonb
 OR coalesce(a#>>'{review,sha256}','')!~'^[0-9a-f]{64}$' OR a#>>'{review,sha256}' IS NOT DISTINCT FROM '0ddac30c408bbb48f6625d459f188a6aeb13a994a273b3754db2e2c2e83a67aa'
 OR nullif(a#>>'{review,ref}','') IS NULL
 OR rr.revision_sha256 IS NOT DISTINCT FROM 'b3e9fcf8927cf169969f53dc642fe9d4b37fac38450e51c816f51bf4e59a926f' OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM rr.revision_sha256
 OR octet_length(rr.canonical_preimage)>524288
 OR r#>>'{db_core,sha256}' IS DISTINCT FROM public.combat_v2_sha256((r->'db_core')-'sha256')
 OR r#>>'{config,sha256}' IS DISTINCT FROM public.combat_v2_sha256((r->'config')-'sha256')
 OR NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE singleton AND staff_enabled AND NOT public_enabled)
 THEN RAISE EXCEPTION 'palmo_ordinary_pm_integrated_root_required';END IF;
 IF clan_innata_private.catalogo_eligibility_release_v1() IS DISTINCT FROM true THEN RAISE EXCEPTION 'palmo_ordinary_global_guard_failed';END IF;
END $contact_post$;
DO $paralisi_refresh_post$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;r jsonb;p jsonb;
BEGIN
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton;
 r:=rr.canonical_preimage::jsonb;p:=r#>'{db_core,paralisi_profile_refresh}';
 IF rr.revision_sha256 IS NOT DISTINCT FROM 'b3e9fcf8927cf169969f53dc642fe9d4b37fac38450e51c816f51bf4e59a926f' OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM rr.revision_sha256
 OR octet_length(rr.canonical_preimage)>524288 OR p IS NULL OR p IS DISTINCT FROM r#>'{config,paralisi_profile_refresh}'
 OR p->>'schema_version' IS DISTINCT FROM 'paralisi-profile-refresh/1'
 OR p->>'source_bundle_sha256' IS DISTINCT FROM '9c9c84ddb2fcc037b0b2164877d296c72a99529b86f3dfcaf59e5c62d4cb65c3'
 OR p->>'projection_source_md5' IS DISTINCT FROM '271ea56acb5f135ad6e3d24d8601e3b1'
 OR p#>'{review,P0}' IS DISTINCT FROM '0'::jsonb OR p#>'{review,P1}' IS DISTINCT FROM '0'::jsonb OR p#>'{review,P2}' IS DISTINCT FROM '0'::jsonb
 OR coalesce(p#>>'{review,sha256}','')!~'^[0-9a-f]{64}$' OR nullif(p#>>'{review,ref}','') IS NULL
 OR r#>>'{db_core,sha256}' IS DISTINCT FROM public.combat_v2_sha256((r->'db_core')-'sha256')
 OR r#>>'{config,sha256}' IS DISTINCT FROM public.combat_v2_sha256((r->'config')-'sha256')
 OR md5((SELECT prosrc FROM pg_proc WHERE oid='combat_panel_private.master_projection(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '271ea56acb5f135ad6e3d24d8601e3b1'
 OR NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.gate WHERE singleton AND enabled AND staff_enabled AND NOT public_enabled)
 OR clan_innata_private.catalogo_eligibility_release_v1() IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'paralisi_refresh_integrated_root_required';END IF;
END $paralisi_refresh_post$;
COMMIT;
