-- Raccordo Clan: sorgente candidata, nessun apply implicito.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='20s';
DO $pin$ BEGIN
 IF md5(pg_get_functiondef('combat_consumer_private.dispatch_narrative(text)'::regprocedure)) IS DISTINCT FROM 'd9d399ed945714805a0c9d12fb708595' THEN RAISE EXCEPTION 'clan_continuation_baseline_drift'; END IF;
 IF md5(pg_get_functiondef('combat_panel_private.narrative_ordinary_context(uuid)'::regprocedure)) IS DISTINCT FROM '943c604e222c9e0e3a662249ee743f96' THEN RAISE EXCEPTION 'clan_continuation_baseline_drift'; END IF;
 IF to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)') IS NOT NULL THEN RAISE EXCEPTION 'clan_continuation_already_present'; END IF;
 IF md5(pg_get_functiondef('combat_consumer_private.narrative_allowed(uuid)'::regprocedure)) IS DISTINCT FROM '9ea79b4c6f08a99352413acb88685044' THEN RAISE EXCEPTION 'clan_continuation_dependency_drift'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.is_dedicated_scene(uuid)'::regprocedure)) IS DISTINCT FROM '85c8f044f8383f4587a1d8175d9a0ec9' THEN RAISE EXCEPTION 'clan_continuation_dependency_drift'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.narrative_attack_allowed(uuid)'::regprocedure)) IS DISTINCT FROM '2f8aaa28220e6af251144b4b23213272' THEN RAISE EXCEPTION 'clan_continuation_dependency_drift'; END IF;
END $pin$;
CREATE FUNCTION combat_consumer_private.narrative_declaration_supported(p_declaration uuid)
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE d public.combat_v2_declarations%ROWTYPE; facts jsonb; sid uuid;
BEGIN
 SELECT * INTO d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.id IS NULL OR d.state IS DISTINCT FROM 'risolta' THEN RETURN false; END IF;
 IF d.kind='attacco' THEN
   RETURN clan_marionettisti_private.narrative_attack_allowed(d.id);
 END IF;
 SELECT session_id INTO sid FROM public.combat_v2_rounds WHERE id=d.round_id;
 IF sid IS NULL THEN RETURN false; END IF;
 IF d.kind='passa' THEN
   RETURN clan_marionettisti_private.is_dedicated_scene(sid)
     AND coalesce((SELECT rinuncia_enabled FROM clan_marionettisti_private.release_gate WHERE singleton),false);
 END IF;
 IF d.kind NOT IN ('utilita','movimento') THEN RETURN false; END IF;
 -- Le utility già supportate entrano soltanto dal contesto Staff protetto.
 -- Accessi/roster/provider restano verificati da narrative_allowed nel dispatch/acquire.
 IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities c
   JOIN public.combat_v2_sessions s ON s.id=c.session_id
   JOIN public.locations l ON l.id=c.location_id
   WHERE c.session_id=sid AND c.exchange_id=d.round_id AND c.phase='resolved'
     AND l.is_test AND c.policy_id='staff_test_no_persistent_resources_v1'
     AND s.source_kind='ordinary' AND s.location_id=c.location_id
     AND NOT public.combat_v2_values_written(s.id)) THEN RETURN false; END IF;
 facts:=combat_panel_private.narrative_declaration_facts(d.id);
 RETURN CASE WHEN d.kind='utilita' THEN
   (facts ? 'multiplication_created' OR facts->'result' ? 'escape' OR facts ? 'clone_creation')
   ELSE facts ? 'clone_events' END;
END $fn$;
REVOKE ALL ON FUNCTION combat_consumer_private.narrative_declaration_supported(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_consumer_private.narrative_declaration_supported(uuid) TO postgres;

CREATE OR REPLACE FUNCTION combat_consumer_private.dispatch_narrative(p_tick_token text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare endpoint text; candidate record; dispatch combat_consumer_private.narrative_dispatches%rowtype; net_id bigint;
begin
  select narrative_edge_url into endpoint from combat_consumer_private.runtime_config
    where singleton and ((enabled and provider_enabled)
      or (staff_test_enabled and staff_test_provider_enabled));
  if endpoint is null or nullif(p_tick_token,'') is null then return; end if;
  for candidate in
    select c.exchange_id from combat_consumer_private.activities c
    join combat_consumer_private.narrative_authorities a on a.session_id=c.session_id and a.mode='ai_auto'
    join public.combat_v2_round_reports r on r.round_id=c.exchange_id and r.narration_state='attesa'
    where combat_consumer_private.narrative_allowed(c.session_id)
      and c.phase='resolved' and not exists(select 1 from combat_consumer_private.narrative_dispatches d where d.round_id=c.exchange_id)
      and exists(select 1 from public.combat_v2_declarations d where d.round_id=c.exchange_id and combat_consumer_private.narrative_declaration_supported(d.id))
    order by c.session_id limit 4
  loop
    perform public.combat_v2_lock_round(candidate.exchange_id);
    -- Rilettura dopo il lock: un altro worker, una chiusura o il Master possono aver vinto.
    insert into combat_consumer_private.narrative_dispatches(round_id,report_id,report_sha256,state)
      select r.round_id,r.id,r.mechanics_sha256,'prepared' from public.combat_v2_round_reports r
      join combat_consumer_private.activities c on c.exchange_id=r.round_id and c.phase='resolved'
      join combat_consumer_private.narrative_authorities a on a.session_id=c.session_id and a.mode='ai_auto'
      where r.round_id=candidate.exchange_id and r.narration_state='attesa'
        and combat_consumer_private.narrative_allowed(c.session_id)
        and not exists(select 1 from combat_consumer_private.narrative_claims cl where cl.round_id=r.round_id)
      on conflict(round_id) do nothing returning * into dispatch;
    if not found then continue; end if;
    begin
      net_id:=net.http_post(url:=endpoint,
        headers:=jsonb_build_object('Content-Type','application/json','x-tick-token',p_tick_token,'x-combat-ordinary','1'),
        body:=jsonb_build_object('ordinary_round_id',dispatch.round_id,'report_sha256',dispatch.report_sha256,
          'request_key',dispatch.request_key),timeout_milliseconds:=55000);
      update combat_consumer_private.narrative_dispatches set state='queued',net_request_id=net_id where round_id=dispatch.round_id;
    exception when others then
      -- Una consegna fallita resta visibile e terminale; nessun retry provider nascosto.
      update combat_consumer_private.narrative_dispatches set state='failed' where round_id=dispatch.round_id;
    end;
  end loop;
  perform combat_consumer_private.scene_redeliver_v2(p_tick_token);
end $function$;

CREATE OR REPLACE FUNCTION combat_panel_private.narrative_ordinary_context(p_round uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_consumer_private.activities%ROWTYPE; d public.combat_v2_declarations%ROWTYPE;
 defense public.combat_v2_declarations%ROWTYPE; source public.characters%ROWTYPE; target public.characters%ROWTYPE;
 link combat_consumer_private.declaration_messages%ROWTYPE; facts jsonb; reports jsonb; place text; prior text;
 masked boolean; moved boolean; source_body uuid; target_body uuid; technique text;
BEGIN
 SELECT * INTO STRICT c FROM combat_consumer_private.activities WHERE exchange_id=p_round AND phase='resolved';
 IF NOT EXISTS(SELECT 1 FROM public.combat_v2_round_reports WHERE round_id=p_round AND narration_state='attesa') THEN
   RAISE EXCEPTION 'ordinary_report_not_ready'; END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations
   WHERE round_id=p_round AND kind IN ('attacco','utilita','passa','movimento');
 facts:=combat_panel_private.narrative_declaration_facts(d.id);
 IF NOT combat_consumer_private.narrative_declaration_supported(d.id) THEN
   RAISE EXCEPTION 'ordinary_narrative_source_not_ready';
 END IF;
 SELECT ch.* INTO STRICT source FROM public.characters ch JOIN combat_consumer_private.members m ON m.character_id=ch.id
   WHERE m.session_id=c.session_id AND m.actor_id=d.actor_id;
 SELECT ch.* INTO STRICT target FROM public.characters ch JOIN combat_consumer_private.members m ON m.character_id=ch.id
   WHERE m.session_id=c.session_id AND m.actor_id<>d.actor_id;
 IF nullif(btrim(source.name),'') IS NULL OR nullif(btrim(target.name),'') IS NULL THEN
   RAISE EXCEPTION 'ordinary_narrative_projection_missing'; END IF;
 source_body:=coalesce((SELECT companion_actor_id FROM clan_marionettisti_private.offensive_profiles WHERE declaration_id=d.id),d.actor_id);
 target_body:=coalesce(d.target_actor_id,(SELECT actor_id FROM combat_consumer_private.members WHERE session_id=c.session_id AND actor_id<>d.actor_id));
 SELECT name INTO STRICT place FROM public.locations WHERE id=c.location_id;
 SELECT n.body INTO prior FROM public.combat_v2_narratives n JOIN public.combat_v2_rounds r ON r.id=n.round_id
   WHERE r.session_id=c.session_id AND r.id<>p_round AND r.state='narrato' ORDER BY r.round_no DESC LIMIT 1;
 SELECT * INTO STRICT link FROM combat_consumer_private.declaration_messages WHERE declaration_id=d.id;
 reports:=jsonb_build_object('attack',public._combat_narrative_report(link.message_id,link.message_sha256,c.location_id,source.id));
 IF d.kind='attacco' THEN
   SELECT * INTO STRICT defense FROM public.combat_v2_declarations WHERE parent_attack_id=d.id AND kind IN ('difesa','nessuna');
   SELECT * INTO STRICT link FROM combat_consumer_private.declaration_messages WHERE declaration_id=defense.id;
   reports:=reports||jsonb_build_object('defense',public._combat_narrative_report(link.message_id,link.message_sha256,c.location_id,target.id));
 END IF;
 -- Le distanze reali e il movimento dell'originale non sono fatti pubblici
 -- durante il mascheramento. La sola presenza/risoluzione delle copie non li rivela.
 masked:=facts ? 'multiplication_created' OR facts ? 'clone_events' OR EXISTS(
   SELECT 1 FROM combat_panel_private.multiplication_formations f WHERE f.session_id=c.session_id
     AND f.actor_id IN(d.actor_id,target_body) AND (f.state='active' OR EXISTS(
       SELECT 1 FROM combat_panel_private.multiplication_resolutions mr JOIN public.combat_v2_attack_targets t ON t.id=mr.attack_target_id
       WHERE mr.formation_id=f.id AND t.attack_declaration_id=d.id)));
 moved:=EXISTS(SELECT 1 FROM combat_spatial.spatial_events e WHERE e.actor_id=source_body
   AND e.event_kind='movement_settled' AND (e.after_state->>'d_eff_m')::numeric>0
   AND (e.root_id=d.request_key OR EXISTS(SELECT 1 FROM combat_consumer_private.offers o WHERE o.id=e.root_id AND o.exchange_id=p_round)));
 technique:=CASE WHEN facts ? 'clone_creation' THEN 'Clone di Sabbia'
   WHEN d.kind='passa' THEN 'Conclusione del turno senza altra azione'
   WHEN d.kind='movimento' THEN 'Spostamento'
   WHEN facts->'result' ? 'escape' THEN 'Tenta di liberarti'
   WHEN facts ? 'multiplication_created' THEN 'Moltiplicazione del corpo'
   WHEN source_body<>d.actor_id THEN 'Marionetta da Combattimento: arto rinforzato contundente, controllato tramite Fili di Chakra'
   ELSE 'Colpo a mani nude' END;
 RETURN jsonb_build_object('ordinary',true,'genere','azione_risolta','non_offensivo',d.kind<>'attacco',
   'autore',jsonb_build_object('nome',source.name,'sesso',source.sex),
   'testimone',CASE WHEN EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=target_body AND companion_id IS NOT NULL)
      THEN jsonb_build_object('nome','Marionetta','sesso',null) ELSE jsonb_build_object('nome',target.name,'sesso',target.sex) END,
   'luogo',place,'tecnica',technique,'fatti',facts,
   'movimento',CASE WHEN masked THEN 'non_esposto' WHEN moved THEN 'avvenuto' ELSE 'assente' END,
   'reazione',CASE WHEN d.kind='attacco' THEN defense.sanitized_intent->>'reaction' ELSE NULL END,
   'player_reports',reports,'gia_visto',left(coalesce(prior,''),400),'model','gpt-5.6-luna');
END $function$;

COMMIT;
