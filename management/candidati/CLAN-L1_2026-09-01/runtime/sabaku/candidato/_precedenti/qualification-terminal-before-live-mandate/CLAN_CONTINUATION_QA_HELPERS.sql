-- Solo database locale sintetico, nessuna rete/provider. Auth simulata esplicita.
CREATE SCHEMA qa_clan_cont;
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
CREATE FUNCTION qa_clan_cont.clone_case() RETURNS uuid LANGUAGE plpgsql AS $$
DECLARE s jsonb;o jsonb;offer jsonb;dir jsonb;dist jsonb;res jsonb;aid uuid;tid uuid;declaration uuid;who integer;
BEGIN
 PERFORM marionetta_qa.put('staff_protected','null');
 -- Presa garantita dai pool sintetici, senza alterare RNG o risultato del resolver.
 UPDATE public.characters SET ninjutsu=greatest(ninjutsu,100),velocita=greatest(velocita,20) WHERE id IN(marionetta_qa.pg(1),marionetta_qa.pg(2));
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
 SELECT value INTO STRICT offer FROM jsonb_array_elements(o->'offers') WHERE value->>'label'='Prepara la prova Sabaku: giara personale';
 res:=qa_integrated.commit_offer(1,o,offer,'');PERFORM qa_integrated.check(res->>'status'='ready','bind');
 o:=qa_integrated.panel(1,aid);
 SELECT value INTO STRICT offer FROM jsonb_array_elements(o->'offers') WHERE value->>'label'='Attiva Controllo della Sabbia · 5 chakra';
 res:=qa_integrated.commit_offer(1,o,offer,'');PERFORM qa_integrated.check(res->>'status'='ready','innata');
 o:=qa_integrated.panel(1,aid);
 SELECT value INTO STRICT offer FROM jsonb_array_elements(o->'offers') WHERE value->>'label' LIKE 'Clone di Sabbia%';
 SELECT opt INTO STRICT dir FROM jsonb_array_elements(offer->'choices') g CROSS JOIN jsonb_array_elements(g->'options') opt
 WHERE g->>'label'='Direzione del piazzamento' AND opt->>'label'=CASE WHEN (o#>>'{map,pov,x_m}')::numeric<(SELECT x_m FROM combat_spatial.actor_states WHERE actor_id=tid) THEN 'Est' ELSE 'Ovest' END;
 SELECT opt INTO STRICT dist FROM jsonb_array_elements(offer->'choices') g CROSS JOIN jsonb_array_elements(g->'options') opt WHERE g->>'depends_on'=dir->>'option_id' AND (opt->>'distance_m')::numeric=3;
 res:=marionetta_qa.rpc(1,format('public.combat_panel_commit_v1(%L::jsonb)',jsonb_build_object('schema_version','combat-panel-command/1',
 'request_key',gen_random_uuid(),'location_id',marionetta_qa.loc(true),'activity_id',o#>'{context,activity_id}','context_version',o#>'{context,version}',
 'offer_id',offer->'offer_id','selected_option_ids',jsonb_build_array(dir->'option_id',dist->'option_id'),'inputs','[]'::jsonb,
 'narrative_text','Il personaggio sintetico crea un Clone di Sabbia nel punto scelto, lasciando al motore la risoluzione della presa.')));
 PERFORM qa_integrated.check(res->>'status'='ready' AND res#>>'{context,phase}'='resolved','clone_resolved');
 declaration:=(res#>>'{receipt,declaration_id}')::uuid;
 PERFORM qa_integrated.check(declaration IS NOT NULL,'clone_declaration');
 RETURN declaration;
END $$;
CREATE FUNCTION qa_clan_cont.escape_case() RETURNS uuid LANGUAGE plpgsql AS $$
DECLARE d uuid;aid uuid;o jsonb;offer jsonb;choice jsonb;res jsonb;
BEGIN
 d:=qa_clan_cont.clone_case();
 PERFORM qa_integrated.check((SELECT count(*)=1 FROM combat_panel_private.immobilizations WHERE state='active'),'native_capture');
 PERFORM qa_clan_cont.publish_current();
 SELECT turn_actor_id INTO STRICT aid FROM combat_consumer_private.activities WHERE phase='action';
 o:=qa_integrated.panel(2,aid);
 SELECT value INTO STRICT offer FROM jsonb_array_elements(o->'offers') WHERE value->>'label'='Tenta di liberarti';
 SELECT opt INTO STRICT choice FROM jsonb_array_elements(offer->'choices') g CROSS JOIN jsonb_array_elements(g->'options') opt;
 res:=marionetta_qa.rpc(2,format('public.combat_panel_commit_v1(%L::jsonb)',jsonb_build_object('schema_version','combat-panel-command/1',
 'request_key',gen_random_uuid(),'location_id',marionetta_qa.loc(true),'activity_id',o#>'{context,activity_id}','context_version',o#>'{context,version}',
 'offer_id',offer->'offer_id','selected_option_ids',jsonb_build_array(choice->'option_id'),'inputs','[]'::jsonb,
 'narrative_text','Il personaggio sintetico tenta di liberarsi dalla presa, senza anticipare il risultato.')));
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
 SELECT value INTO STRICT offer FROM jsonb_array_elements(o->'offers') WHERE value->>'label'='Colpo a mani nude';
 res:=qa_integrated.commit_offer((s->>'owner')::integer,o,offer);
 PERFORM qa_integrated.check(res#>>'{context,phase}'='defense','hand_defense_window');
 attack:=(res#>>'{receipt,declaration_id}')::uuid;
 o:=qa_integrated.panel(3-(s->>'owner')::integer,(s->>'target')::uuid);
 SELECT value INTO STRICT offer FROM jsonb_array_elements(o->'offers') WHERE value->>'label'='Parata';
 res:=qa_integrated.commit_offer(3-(s->>'owner')::integer,o,offer);
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
