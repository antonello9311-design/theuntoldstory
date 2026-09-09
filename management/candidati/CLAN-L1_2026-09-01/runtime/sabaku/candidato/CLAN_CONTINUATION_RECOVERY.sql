-- Recovery candidato raccordo: richiede gate nominativo separato. Nessun DROP, dato o flag modificato.
-- Ripristina due baseline; la nuova helper rimane privata e sempre false.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='20s';
DO $pin$ BEGIN
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=to_regprocedure('combat_consumer_private.dispatch_narrative(text)') AND md5(pg_get_functiondef(oid))='24fc74582116842cc0bdc86f5ef2378f' AND proacl::text='{postgres=X/postgres}' AND pg_get_userbyid(proowner)='postgres') THEN RAISE EXCEPTION 'clan_recovery_candidate_drift'; END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=to_regprocedure('combat_panel_private.narrative_ordinary_context(uuid)') AND md5(pg_get_functiondef(oid))='ec6a66b6599cdfb3d80aea6c12c9dd43' AND proacl::text='{postgres=X/postgres}' AND pg_get_userbyid(proowner)='postgres') THEN RAISE EXCEPTION 'clan_recovery_candidate_drift'; END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)') AND md5(pg_get_functiondef(oid))='5d92acb102cf08fb6407c25efb6032b0' AND proacl::text='{postgres=X/postgres}' AND pg_get_userbyid(proowner)='postgres') THEN RAISE EXCEPTION 'clan_recovery_candidate_drift'; END IF;
END $pin$;
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
      and exists(select 1 from public.combat_v2_declarations d where d.round_id=c.exchange_id and (clan_marionettisti_private.narrative_attack_allowed(d.id)
        or (d.kind='passa' and clan_marionettisti_private.is_dedicated_scene(c.session_id)
         and coalesce((select rinuncia_enabled from clan_marionettisti_private.release_gate where singleton),false))))
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
 IF d.kind='attacco' THEN
   IF NOT clan_marionettisti_private.narrative_attack_allowed(d.id) THEN
     RAISE EXCEPTION 'ordinary_narrative_source_not_ready'; END IF;
 ELSIF NOT ((d.kind='utilita' AND (facts ? 'multiplication_created' OR facts->'result' ? 'escape' OR facts ? 'clone_creation'))
   OR (d.kind IN ('passa','movimento') AND facts ? 'clone_events')) THEN
   RAISE EXCEPTION 'ordinary_narrative_utility_not_supported';
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
CREATE OR REPLACE FUNCTION combat_consumer_private.narrative_declaration_supported(p_declaration uuid)
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $inert$
BEGIN
 RETURN false;
END $inert$;
REVOKE ALL ON FUNCTION combat_consumer_private.dispatch_narrative(text) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION combat_consumer_private.dispatch_narrative(text) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.narrative_ordinary_context(uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.narrative_ordinary_context(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_consumer_private.narrative_declaration_supported(uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION combat_consumer_private.narrative_declaration_supported(uuid) TO postgres;
DO $verify$ BEGIN
IF md5(pg_get_functiondef('combat_consumer_private.dispatch_narrative(text)'::regprocedure)) IS DISTINCT FROM 'd9d399ed945714805a0c9d12fb708595' THEN RAISE EXCEPTION 'clan_recovery_baseline_mismatch'; END IF;
IF md5(pg_get_functiondef('combat_panel_private.narrative_ordinary_context(uuid)'::regprocedure)) IS DISTINCT FROM '943c604e222c9e0e3a662249ee743f96' THEN RAISE EXCEPTION 'clan_recovery_baseline_mismatch'; END IF;
IF combat_consumer_private.narrative_declaration_supported(NULL) IS DISTINCT FROM false OR combat_consumer_private.narrative_declaration_supported('00000000-0000-0000-0000-000000000001'::uuid) IS DISTINCT FROM false THEN RAISE EXCEPTION 'clan_recovery_helper_not_inert'; END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=to_regprocedure('combat_consumer_private.dispatch_narrative(text)') AND proacl::text='{postgres=X/postgres}' AND pg_get_userbyid(proowner)='postgres') THEN RAISE EXCEPTION 'clan_recovery_acl_mismatch'; END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=to_regprocedure('combat_panel_private.narrative_ordinary_context(uuid)') AND proacl::text='{postgres=X/postgres}' AND pg_get_userbyid(proowner)='postgres') THEN RAISE EXCEPTION 'clan_recovery_acl_mismatch'; END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)') AND proacl::text='{postgres=X/postgres}' AND pg_get_userbyid(proowner)='postgres') THEN RAISE EXCEPTION 'clan_recovery_acl_mismatch'; END IF;
END $verify$;
COMMIT;
