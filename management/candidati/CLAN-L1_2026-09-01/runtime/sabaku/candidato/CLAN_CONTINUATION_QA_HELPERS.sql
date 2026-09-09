-- Solo database locale sintetico, nessuna rete/provider. Auth simulata esplicita.
CREATE SCHEMA qa_clan_cont;

-- Selettore QA semantico: solo offerte ricevute, identità e sorgente native.
CREATE FUNCTION qa_clan_cont.find_offer(env jsonb, op text, target uuid DEFAULT NULL) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE found_offer jsonb; n integer;
BEGIN
 SELECT count(*), (jsonb_agg(v))->0 INTO n,found_offer
 FROM jsonb_array_elements(env->'offers') v
 JOIN combat_panel_private.offers po ON po.id=(v->>'offer_id')::uuid
 LEFT JOIN combat_consumer_private.offers co ON co.id=(po.source_payload->>'source_offer_id')::uuid
 WHERE po.state='offered' AND po.operation=v->>'operation'
 AND (target IS NULL OR co.source_payload->>'target_actor_id'=target::text OR co.source_payload#>>'{intent,target_actor}'=target::text OR co.viewer_projection->>'target_actor_id'=target::text)
 AND CASE op
 WHEN 'clone' THEN po.operation='declare' AND po.source_payload->>'dispatch'='sabaku_clone'
 WHEN 'escape' THEN po.operation='declare' AND po.source_payload->>'dispatch'='immobilization_escape'
 WHEN 'staff_profile' THEN po.operation='control' AND co.source_payload->>'sabaku_operation'='staff_profile'
 WHEN 'activate' THEN po.operation='control' AND co.source_payload->>'sabaku_operation'='activate'
 WHEN 'hand' THEN po.operation='declare' AND co.source_payload#>>'{intent,ability_source}'='mano'
 WHEN 'parry' THEN po.operation='defend' AND co.source_payload#>>'{intent,reaction}'='parata'
 ELSE false END;
 IF n<>1 THEN RAISE EXCEPTION 'qa_semantic_offer_cardinality:%:%',op,n; END IF;
 RETURN found_offer;
END $$;
CREATE FUNCTION qa_clan_cont.commit_staying(who integer, env jsonb, chosen jsonb) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE selected jsonb:='[]'; x uuid; group_count integer;
BEGIN
 SELECT count(*) INTO group_count FROM combat_panel_private.choice_groups WHERE offer_id=(chosen->>'offer_id')::uuid AND depends_on IS NULL;
 IF group_count>0 THEN
  SELECT co.id INTO STRICT x FROM combat_panel_private.choice_options co JOIN combat_panel_private.choice_groups cg ON cg.id=co.group_id
  WHERE co.offer_id=(chosen->>'offer_id')::uuid AND cg.depends_on IS NULL AND co.direction='stay';
  selected:=jsonb_build_array(x);
 END IF;
 RETURN marionetta_qa.rpc(who,format('public.combat_panel_commit_v1(%L::jsonb)',jsonb_build_object('schema_version','combat-panel-command/1',
 'request_key',gen_random_uuid(),'location_id',marionetta_qa.loc(true),'activity_id',env#>'{context,activity_id}',
 'context_version',env#>'{context,version}','offer_id',chosen->'offer_id','selected_option_ids',selected,'inputs','[]'::jsonb,
 'narrative_text','Il personaggio sintetico esegue il gesto selezionato restando sul posto; il motore decide l’esito.')));
END $$;

CREATE FUNCTION qa_clan_cont.request_current() RETURNS jsonb LANGUAGE sql AS $$
 SELECT jsonb_build_object('round_id',c.exchange_id,'session_id',c.session_id,'request_key',gen_random_uuid(),'report_sha256',r.mechanics_sha256)
 FROM combat_consumer_private.activities c JOIN public.combat_v2_round_reports r ON r.round_id=c.exchange_id WHERE c.phase='resolved'
$$;
CREATE FUNCTION qa_clan_cont.publish_current() RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE r jsonb:=qa_clan_cont.request_current(); a jsonb;
BEGIN
 UPDATE combat_consumer_private.runtime_config SET provider_enabled=false,staff_test_provider_enabled=true,narrative_edge_url=NULL;
 a:=qa_integrated.call('acquire',r);
 PERFORM qa_integrated.generated(r);PERFORM qa_integrated.published(r);RETURN r;
END $$;
CREATE FUNCTION qa_clan_cont.clone_case(far_fixture boolean DEFAULT false) RETURNS uuid LANGUAGE plpgsql AS $$
DECLARE s jsonb;o jsonb;offer jsonb;dir jsonb;dist jsonb;res jsonb;aid uuid;tid uuid;declaration uuid;who integer;
BEGIN
 PERFORM marionetta_qa.put('staff_protected','null');
 -- Nessuna statistica modificata; esito nativo accettato e verificato come tale.
 s:=marionetta_qa.open_scene(true);who:=(s->>'owner')::integer;
 IF who=2 THEN
  -- Principale nativa disponibile senza marionetta; originale fermo e copia a Nord.
  res:=qa_scene.copies(who,(s->>'actor')::uuid,'Copertura');
  PERFORM qa_integrated.check(res#>>'{context,phase}'='resolved','setup_copies');
  PERFORM qa_clan_cont.publish_current();
 END IF;
 SELECT turn_actor_id INTO aid FROM combat_consumer_private.activities WHERE session_id=(s->>'session')::uuid;
 SELECT id INTO tid FROM public.combat_v2_actors WHERE session_id=(s->>'session')::uuid AND character_id=marionetta_qa.pg(2);
 PERFORM qa_integrated.check((SELECT character_id=marionetta_qa.pg(1) FROM public.combat_v2_actors WHERE id=aid),'sabaku_turn');
 o:=qa_integrated.panel(1,aid);
 offer:=qa_clan_cont.find_offer(o,'staff_profile');
 res:=qa_integrated.commit_offer(1,o,offer,'');PERFORM qa_integrated.check(res->>'status'='ready','bind');
 o:=qa_integrated.panel(1,aid);
 offer:=qa_clan_cont.find_offer(o,'activate');
 res:=qa_integrated.commit_offer(1,o,offer,'');PERFORM qa_integrated.check(res->>'status'='ready','innata');
 o:=qa_integrated.panel(1,aid);
 offer:=qa_clan_cont.find_offer(o,'clone');
 SELECT v INTO STRICT dir FROM jsonb_array_elements(offer->'choices') g CROSS JOIN jsonb_array_elements(g->'options') v
 JOIN combat_panel_private.choice_options co ON co.id=(v->>'option_id')::uuid
 WHERE co.source_payload->>'clone_direction'=CASE WHEN far_fixture THEN 'here' WHEN (o#>>'{map,pov,x_m}')::numeric<(SELECT x_m FROM combat_spatial.actor_states WHERE actor_id=tid) THEN 'east' ELSE 'west' END;
 SELECT v INTO STRICT dist FROM jsonb_array_elements(offer->'choices') g CROSS JOIN jsonb_array_elements(g->'options') v
 JOIN combat_panel_private.choice_options co ON co.id=(v->>'option_id')::uuid
 WHERE g->>'depends_on'=dir->>'option_id' AND co.source_payload ? 'clone_position' AND (v->>'distance_m')::numeric=CASE WHEN far_fixture THEN 0 ELSE 3 END;
 res:=marionetta_qa.rpc(1,format('public.combat_panel_commit_v1(%L::jsonb)',jsonb_build_object('schema_version','combat-panel-command/1',
 'request_key',gen_random_uuid(),'location_id',marionetta_qa.loc(true),'activity_id',o#>'{context,activity_id}','context_version',o#>'{context,version}',
 'offer_id',offer->'offer_id','selected_option_ids',jsonb_build_array(dir->'option_id',dist->'option_id'),'inputs','[]'::jsonb,
 'narrative_text','Il personaggio sintetico crea un Clone di Sabbia nel punto scelto, lasciando al motore la risoluzione della presa.')));
 PERFORM qa_integrated.check(res->>'status'='ready' AND res#>>'{context,phase}'='resolved','clone_resolved');
 declaration:=(res#>>'{receipt,declaration_id}')::uuid;
 PERFORM qa_integrated.check(declaration IS NOT NULL,'clone_declaration');
 PERFORM qa_integrated.check(EXISTS(SELECT 1 FROM clan_sabaku_private.clones WHERE declaration_id=declaration),'native_clone_created');
 RETURN declaration;
END $$;
CREATE FUNCTION qa_clan_cont.escape_case() RETURNS uuid LANGUAGE plpgsql AS $$
DECLARE d uuid;aid uuid;o jsonb;offer jsonb;choice jsonb;res jsonb;c clan_sabaku_private.clones%ROWTYPE;
 a public.combat_v2_actors%ROWTYPE; cap uuid:='d9631800-0000-4000-8000-000000000003';
 entropy bytea; dice integer[]; domain text; calc jsonb; idx integer; chosen_idx integer; effect uuid;
 vectors jsonb:='["4ca779d3e6e08d03789b17a554095b2567b5750ccb31f270b920311e8daedca1", "d96904be553734a7b846e5c6480350730bb16913e5d4ed598a75830265dd5cf9", "62ddfcafe24150024828c2915a7886a931bd36a4fd74462d834b0b44b770b6aa", "ba1f03e2b2c65592edb73f316286a87f26a6657ddb1df09aefd88d5cb873f145", "39101be558ad1f1613e9d11ba576ca7e62b4333d4cf9e568da7561537189d5b0", "d79f798271fa4a24df4ff680fc503893850dd9f5fe1aa996929912bda203376c", "0d750a34893f454e363a92e22964362e855ff56da580ceddaf878fdf1b40de0a", "36e662cda8222bf10794197ffcc230a366163e5724c69a1dcb27bdbcc0ebe0d5", "5ce21caa1ad12b5269683a9189a63b3509826e956a7c9b45a2a24d9138360443", "8fbe6e8860b3a778f456e328bb203c83cfa0cc3142080024df65ae091656d315", "2f1fb72756773e7d10d2b0aa7af0d9b4d204fb2a3ef292d3a6feeb78f63e5b3a", "72f0b87394fcc2cf09b735e7ccb537fa502668abddf136832d74945654497d52", "0652843c026b9030503d223cdd160492e89b0c59bf0591721599e344318a7414", "acd6cf491dc2419ab3a950eae819e91732f3c3380bce8eb28ffa7096cb765485"]'::jsonb;
BEGIN
 d:=qa_clan_cont.clone_case(true);
 SELECT * INTO STRICT c FROM clan_sabaku_private.clones WHERE declaration_id=d;
 PERFORM qa_integrated.check(c.state='armed' AND NOT EXISTS(SELECT 1 FROM clan_sabaku_private.clone_captures WHERE clone_id=c.id),'synthetic_precondition_no_native_capture');
 PERFORM qa_clan_cont.publish_current();
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE session_id=c.session_id AND character_id=marionetta_qa.pg(2);
 -- Contatto sintetico dichiarato: non è un movimento del PG né una cattura storica.
 UPDATE combat_spatial.actor_states SET x_m=c.x_m+1,y_m=c.y_m,body_version=body_version+1 WHERE instance_id=c.instance_id AND actor_id=a.id;
 UPDATE combat_spatial.arena_instances SET map_version=map_version+1 WHERE instance_id=c.instance_id;
 domain:='combat-v2/sabaku-clone-capture/1:'||c.session_id::text||':'||c.id::text||':'||cap::text;
 FOR idx IN 0..13 LOOP
  entropy:=decode(vectors->>idx,'hex');
  dice:=ARRAY[public.combat_v2_derive_d10(entropy,domain,1),public.combat_v2_derive_d10(entropy,domain,2),public.combat_v2_derive_d10(entropy,domain,3),public.combat_v2_derive_d10(entropy,domain,4)];
  calc:=clan_sabaku_private.clone_capture_result(c.source_kekkei_genkai,c.source_ninjutsu,(a.mechanics_snapshot->>'velocita')::numeric,(a.mechanics_snapshot->>'taijutsu')::numeric,dice);
  IF (calc->>'success')::boolean THEN chosen_idx:=idx+1;EXIT; END IF;
 END LOOP;
 IF chosen_idx IS NULL THEN RAISE EXCEPTION 'qa_frozen_vector_set_has_no_positive';END IF;
 INSERT INTO clan_sabaku_private.clone_captures(id,clone_id,round_id,target_actor_id,trigger_kind,copy_hit,target_velocity,target_taijutsu,entropy,dice,result)
 VALUES(cap,c.id,c.created_round_id,a.id,'initial_presence',false,(a.mechanics_snapshot->>'velocita')::numeric,(a.mechanics_snapshot->>'taijutsu')::numeric,entropy,dice,calc);
 effect:=clan_sabaku_private.clone_apply_immobilization(cap);
 PERFORM qa_integrated.check(effect IS NOT NULL,'synthetic_validated_capture_applied');
 UPDATE clan_sabaku_private.clones SET state='holding',state_version=state_version+1 WHERE id=c.id;
 RAISE NOTICE 'QA_FIXTURE:%',jsonb_build_object('provenance','SINTETICA','session_id',c.session_id,'clone_id',c.id,'capture_id',cap,'target_actor_id',a.id,'domain',domain,'vector_index',chosen_idx,'dice',dice,'computed_result',calc,'validator_accepted',true);
 SELECT turn_actor_id INTO STRICT aid FROM combat_consumer_private.activities WHERE session_id=c.session_id AND phase='action';
 PERFORM qa_integrated.check(aid=a.id,'escape_turn_native');
 o:=qa_integrated.panel(2,aid);offer:=qa_clan_cont.find_offer(o,'escape');
 SELECT v INTO STRICT choice FROM jsonb_array_elements(offer->'choices') g CROSS JOIN jsonb_array_elements(g->'options') v
 JOIN combat_panel_private.choice_options co ON co.id=(v->>'option_id')::uuid WHERE co.source_payload->>'immobilization_effect_id'=effect::text;
 res:=marionetta_qa.rpc(2,format('public.combat_panel_commit_v1(%L::jsonb)',jsonb_build_object('schema_version','combat-panel-command/1',
 'request_key',gen_random_uuid(),'location_id',marionetta_qa.loc(true),'activity_id',o#>'{context,activity_id}','context_version',o#>'{context,version}',
 'offer_id',offer->'offer_id','selected_option_ids',jsonb_build_array(choice->'option_id'),'inputs','[]'::jsonb,
 'narrative_text','Il personaggio sintetico tenta di liberarsi dalla presa; il motore decide il risultato.')));
 PERFORM qa_integrated.check(res->>'status'='ready' AND res#>>'{context,phase}'='resolved','escape_resolved');
 RETURN (res#>>'{receipt,declaration_id}')::uuid;
END $$;
CREATE FUNCTION qa_clan_cont.check_and_publish(d uuid) RETURNS void LANGUAGE plpgsql AS $$
DECLARE r uuid;ctx jsonb;
BEGIN
 SELECT round_id INTO STRICT r FROM public.combat_v2_declarations WHERE id=d;
 PERFORM qa_integrated.check(combat_consumer_private.narrative_declaration_supported(d),'declaration_selected');
 ctx:=combat_consumer_private.narrative_context(r);
 PERFORM qa_integrated.check(ctx->>'genere'='azione_risolta','native_context');
 PERFORM qa_clan_cont.publish_current();
 PERFORM marionetta_qa.assert_staff_protected('utility_published');
END $$;

CREATE FUNCTION qa_clan_cont.hand_case() RETURNS uuid LANGUAGE plpgsql AS $$
DECLARE s jsonb;o jsonb;offer jsonb;res jsonb;attack uuid;
BEGIN
 s:=marionetta_qa.open_scene(true);
 -- Posizioni iniziali sintetiche adiacenti; nessuna pretesa di collaudare il movimento.
 UPDATE combat_spatial.actor_states SET x_m=CASE WHEN actor_id=(s->>'actor')::uuid THEN 5 ELSE 6 END,
   y_m=5,body_version=body_version+1 WHERE actor_id IN((s->>'actor')::uuid,(s->>'target')::uuid);
 UPDATE combat_spatial.arena_instances SET map_version=map_version+1 WHERE encounter_id=(s->>'session')::uuid;
 o:=qa_integrated.panel((s->>'owner')::integer,(s->>'actor')::uuid);
 offer:=qa_clan_cont.find_offer(o,'hand',(s->>'target')::uuid);
 res:=qa_clan_cont.commit_staying((s->>'owner')::integer,o,offer);
 PERFORM qa_integrated.check(res#>>'{context,phase}'='defense','hand_defense_window');
 attack:=(res#>>'{receipt,declaration_id}')::uuid;
 o:=qa_integrated.panel(3-(s->>'owner')::integer,(s->>'target')::uuid);
 offer:=qa_clan_cont.find_offer(o,'parry');
 res:=qa_clan_cont.commit_staying(3-(s->>'owner')::integer,o,offer);
 PERFORM qa_integrated.check(res#>>'{context,phase}'='resolved','hand_resolved');
 PERFORM qa_integrated.check(combat_consumer_private.narrative_declaration_supported(attack),'hand_selected');
 PERFORM qa_integrated.check(combat_consumer_private.narrative_context((s->>'round')::uuid)->>'genere'='confronto','hand_context');
 PERFORM qa_clan_cont.publish_current();
 PERFORM marionetta_qa.assert_staff_protected('hand_published');
 RETURN attack;
END $$;

-- Adattatore solo QA: registra il trasporto, non contatta alcun provider.
CREATE OR REPLACE FUNCTION net.http_post(url text,body jsonb DEFAULT '{}',params jsonb DEFAULT '{}',headers jsonb DEFAULT '{}',timeout_milliseconds integer DEFAULT 1000)
RETURNS bigint LANGUAGE plpgsql AS $$ DECLARE n bigint; BEGIN
 IF current_database()<>'tus_clan_continuation_qa' OR url<>'https://aaaaaaaaaaaaaaaaaaaa.supabase.co/functions/v1/combat_narratore_ai' THEN RAISE EXCEPTION 'qa_network_forbidden'; END IF;
 INSERT INTO qa_scene.net_calls(url,body) VALUES(url,body) RETURNING id INTO n;RETURN n; END $$;
