-- SOURCE ONLY: compose with INNATA_ALL_CLAN source and current Root; review required.
DO $not_installable$ BEGIN RAISE EXCEPTION 'INNATA_ALL_QA_RESOURCE_PORT_COMPOSITION_REQUIRED'; END $not_installable$;
BEGIN;
CREATE OR REPLACE FUNCTION public.combat_test_restore_resources_v1(p_location uuid, p_session uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE uid uuid:=auth.uid(); ctx combat_consumer_private.activities%ROWTYPE;
 sess public.combat_v2_sessions%ROWTYPE; round_row public.combat_v2_rounds%ROWTYPE;
 actor_row public.combat_v2_actors%ROWTYPE; original_actors jsonb; protected_before jsonb; protected_after jsonb;
 characters_before text; characters_after text; participants jsonb; event jsonb; result jsonb;
 rid uuid; changed integer:=0; changed_now integer; event_key uuid:=gen_random_uuid();
BEGIN
 IF uid IS NULL OR public.is_staff() IS DISTINCT FROM true OR public._puo_test_room() IS DISTINCT FROM true THEN
  RAISE EXCEPTION 'Il ripristino della prova è riservato allo Staff autenticato.' USING ERRCODE='42501'; END IF;
 IF p_location IS NULL OR p_session IS NULL OR combat_consumer_private.staff_test_allowed(p_location,ARRAY[uid],false) IS DISTINCT FROM true THEN
  RAISE EXCEPTION 'Questa stanza non consente il ripristino delle risorse di prova.' USING ERRCODE='42501'; END IF;
 SELECT exchange_id INTO rid FROM combat_consumer_private.activities WHERE session_id=p_session AND location_id=p_location;
 IF rid IS NULL THEN RAISE EXCEPTION 'La prova non è disponibile in questa stanza.' USING ERRCODE='22023'; END IF;
 -- Same domain order: session/round/actors/characters before activity and panel contexts.
 PERFORM public.combat_v2_lock_round(rid);
 SELECT * INTO ctx FROM combat_consumer_private.activities WHERE session_id=p_session AND location_id=p_location FOR UPDATE;
 SELECT * INTO sess FROM public.combat_v2_sessions WHERE id=p_session;
 SELECT * INTO round_row FROM public.combat_v2_rounds WHERE id=rid AND session_id=p_session;
 IF ctx.exchange_id IS DISTINCT FROM rid OR ctx.closed_at IS NOT NULL OR ctx.phase IS DISTINCT FROM 'action'
  OR sess.location_id IS DISTINCT FROM p_location OR sess.source_kind IS DISTINCT FROM 'ordinary'
  OR sess.closed_at IS NOT NULL OR ctx.policy_id IS DISTINCT FROM 'staff_test_no_persistent_resources_v1'
  OR round_row.phase IS DISTINCT FROM 'raccolta_azioni' OR round_row.state IS DISTINCT FROM 'raccolta_azioni'
  OR round_row.freeze_at IS NOT NULL OR round_row.resolved_at IS NOT NULL OR round_row.report_id IS NOT NULL THEN
  RAISE EXCEPTION 'Attendi un nuovo turno libero prima di ripristinare la prova.' USING ERRCODE='40001'; END IF;
 IF combat_panel_private.uses_simulated_pools(p_session) IS DISTINCT FROM true
  OR public.combat_v2_values_written(p_session) OR exam_regia_private.is_bound(p_session)
  OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN combat_consumer_private.members m
    ON m.actor_id=a.id AND m.session_id=a.session_id AND m.character_id=a.character_id
    WHERE a.session_id=p_session AND a.controller_user=uid)
  OR (
   (SELECT array_agg(a.character_id ORDER BY a.character_id) FROM public.combat_v2_actors a WHERE a.session_id=p_session AND a.actor_kind='pg' AND a.companion_id IS NULL)
    IS DISTINCT FROM ARRAY['2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid]
   AND NOT (
    (SELECT array_agg(innata_qa_actor.character_id ORDER BY innata_qa_actor.character_id)
      FROM public.combat_v2_actors innata_qa_actor
      WHERE innata_qa_actor.session_id=p_session AND innata_qa_actor.actor_kind='pg' AND innata_qa_actor.companion_id IS NULL)
     IS NOT DISTINCT FROM ARRAY['6bceee99-974f-426b-8d92-38b43b4a4267'::uuid,'f335b077-34a1-41c3-94aa-58ec674b649b'::uuid]
    AND round_row.round_no IS NOT DISTINCT FROM 1
    AND NOT EXISTS (
     SELECT 1 FROM public.combat_v2_actors innata_qa_pg
     CROSS JOIN LATERAL (
      SELECT clan_innata_narrative_private.staff_profile_actor_v1(innata_qa_pg.id) AS profile_proof
     ) innata_qa_bound
     WHERE innata_qa_pg.session_id=p_session AND innata_qa_pg.actor_kind='pg' AND innata_qa_pg.companion_id IS NULL
      AND (innata_qa_bound.profile_proof IS NULL
       OR coalesce(cardinality(clan_innata_narrative_private.staff_profile_active_ids_v1(
          (innata_qa_bound.profile_proof->>'context_id')::uuid)),-1)<>0)
    )
   )
  )
  OR EXISTS(SELECT 1 FROM public.combat_v2_actors a WHERE a.session_id=p_session AND a.actor_kind='pg' AND (a.state<>'attivo' OR a.companion_id IS NOT NULL)) THEN
  RAISE EXCEPTION 'Il ripristino richiede i due partecipanti autorizzati e risorse simulate protette.' USING ERRCODE='42501'; END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=rid)
  OR EXISTS(SELECT 1 FROM public.combat_v2_round_reports rr JOIN public.combat_v2_rounds r ON r.id=rr.round_id
    WHERE r.session_id=p_session AND (rr.round_id=rid OR rr.narration_state='attesa'))
  OR EXISTS(SELECT 1 FROM public.combat_v2_rounds r WHERE r.session_id=p_session AND r.id<>rid
    AND r.state NOT IN('risolto','narrato')) THEN
  RAISE EXCEPTION 'Concludi le azioni e la narrazione pendenti prima di ripristinare la prova.' USING ERRCODE='40001'; END IF;
 SELECT jsonb_agg(to_jsonb(a) ORDER BY a.id) INTO original_actors FROM public.combat_v2_actors a WHERE a.session_id=p_session;
 FOR actor_row IN SELECT * FROM public.combat_v2_actors WHERE session_id=p_session AND actor_kind='pg' AND companion_id IS NULL ORDER BY id LOOP
  IF jsonb_typeof(actor_row.mechanics_snapshot->'vita') IS DISTINCT FROM 'number'
   OR jsonb_typeof(actor_row.mechanics_snapshot->'chakra') IS DISTINCT FROM 'number'
   OR jsonb_typeof(actor_row.mechanics_snapshot->'vita_max') IS DISTINCT FROM 'number'
   OR jsonb_typeof(actor_row.mechanics_snapshot->'chakra_max') IS DISTINCT FROM 'number'
   OR NOT ((actor_row.mechanics_snapshot->>'vita')::numeric BETWEEN 1 AND (actor_row.mechanics_snapshot->>'vita_max')::numeric)
   OR NOT ((actor_row.mechanics_snapshot->>'chakra')::numeric BETWEEN 0 AND (actor_row.mechanics_snapshot->>'chakra_max')::numeric) THEN
   RAISE EXCEPTION 'Le risorse simulate non sono valide: il ripristino è stato fermato.' USING ERRCODE='22023'; END IF;
  IF actor_row.mechanics_snapshot->'vita' IS DISTINCT FROM actor_row.mechanics_snapshot->'vita_max'
   OR actor_row.mechanics_snapshot->'chakra' IS DISTINCT FROM actor_row.mechanics_snapshot->'chakra_max' THEN changed:=changed+1; END IF;
 END LOOP;
 -- Existing lifecycle triggers remain enabled; changing any effect/reserve aborts this transaction.
 SELECT jsonb_build_object(
  'reserves',(SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM clan_sabaku_private.reserves x WHERE x.session_id=p_session),
  'clones',(SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM clan_sabaku_private.clones x WHERE x.session_id=p_session),
  'innata',(SELECT jsonb_agg(to_jsonb(x) ORDER BY x.actor_id,x.technique_id) FROM clan_innata_combat_private.combat_state x WHERE x.session_id=p_session),
  'copies',(SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM combat_panel_private.multiplication_formations x WHERE x.session_id=p_session),
  'holds',(SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM combat_panel_private.immobilizations x WHERE x.session_id=p_session)
 ) INTO protected_before;
 SELECT md5(string_agg(to_jsonb(ch)::text,'|' ORDER BY ch.id)) INTO characters_before FROM public.characters ch
  WHERE ch.id IN(SELECT a.character_id FROM public.combat_v2_actors a WHERE a.session_id=p_session);
 IF changed>0 THEN
  PERFORM 1 FROM combat_panel_private.contexts WHERE activity_id=p_session AND activity_kind='ordinary_v2' ORDER BY id FOR UPDATE;
  event:=public.combat_v2_event_begin(p_session,event_key,'combat_test_restore_resources',jsonb_build_object('location_id',p_location,'session_id',p_session),ctx.context_version);
  UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(jsonb_set(mechanics_snapshot,'{vita}',mechanics_snapshot->'vita_max',false),'{chakra}',mechanics_snapshot->'chakra_max',false)
   WHERE session_id=p_session AND actor_kind='pg' AND companion_id IS NULL AND (mechanics_snapshot->'vita' IS DISTINCT FROM mechanics_snapshot->'vita_max' OR mechanics_snapshot->'chakra' IS DISTINCT FROM mechanics_snapshot->'chakra_max');
  GET DIAGNOSTICS changed_now=ROW_COUNT;
  IF changed_now<>changed THEN RAISE EXCEPTION 'La prova è cambiata durante il ripristino.' USING ERRCODE='40001'; END IF;
  -- Updating context_version alone does not trigger phase/turn/round lifecycle or sand refill.
  UPDATE combat_consumer_private.activities SET context_version=context_version+1 WHERE session_id=p_session RETURNING * INTO ctx;
  UPDATE combat_consumer_private.offers SET state='revoked' WHERE session_id=p_session AND state='offered';
  UPDATE combat_panel_private.contexts SET context_version=context_version+1,updated_at=clock_timestamp()
   WHERE activity_id=p_session AND activity_kind='ordinary_v2';
  UPDATE combat_panel_private.offers o SET state='revoked' FROM combat_panel_private.contexts c
   WHERE o.context_id=c.id AND c.activity_id=p_session AND c.activity_kind='ordinary_v2' AND o.state='offered';
 END IF;
 SELECT jsonb_build_object(
  'reserves',(SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM clan_sabaku_private.reserves x WHERE x.session_id=p_session),
  'clones',(SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM clan_sabaku_private.clones x WHERE x.session_id=p_session),
  'innata',(SELECT jsonb_agg(to_jsonb(x) ORDER BY x.actor_id,x.technique_id) FROM clan_innata_combat_private.combat_state x WHERE x.session_id=p_session),
  'copies',(SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM combat_panel_private.multiplication_formations x WHERE x.session_id=p_session),
  'holds',(SELECT jsonb_agg(to_jsonb(x) ORDER BY x.id) FROM combat_panel_private.immobilizations x WHERE x.session_id=p_session)
 ) INTO protected_after;
 SELECT md5(string_agg(to_jsonb(ch)::text,'|' ORDER BY ch.id)) INTO characters_after FROM public.characters ch
  WHERE ch.id IN(SELECT a.character_id FROM public.combat_v2_actors a WHERE a.session_id=p_session);
 IF protected_after IS DISTINCT FROM protected_before OR characters_after IS DISTINCT FROM characters_before
  OR (SELECT jsonb_agg((to_jsonb(a)-'mechanics_snapshot')||jsonb_build_object('mechanics_snapshot',CASE WHEN a.actor_kind='pg' AND a.companion_id IS NULL THEN a.mechanics_snapshot-ARRAY['vita','chakra'] ELSE a.mechanics_snapshot END) ORDER BY a.id)
      FROM public.combat_v2_actors a WHERE a.session_id=p_session)
   IS DISTINCT FROM (SELECT jsonb_agg((x-'mechanics_snapshot')||jsonb_build_object('mechanics_snapshot',CASE WHEN x->>'actor_kind'='pg' AND x->>'companion_id' IS NULL THEN (x->'mechanics_snapshot')-ARRAY['vita','chakra'] ELSE x->'mechanics_snapshot' END) ORDER BY x->>'id') FROM jsonb_array_elements(original_actors)x) THEN
  RAISE EXCEPTION 'Un altro effetto della prova è cambiato: ripristino annullato.' USING ERRCODE='40001'; END IF;
 SELECT jsonb_agg(jsonb_build_object('actor_id',a.id,'pv',jsonb_build_object('current',a.mechanics_snapshot->'vita','max',a.mechanics_snapshot->'vita_max'),
  'chakra',jsonb_build_object('current',a.mechanics_snapshot->'chakra','max',a.mechanics_snapshot->'chakra_max')) ORDER BY a.id)
 INTO participants FROM public.combat_v2_actors a WHERE a.session_id=p_session AND a.actor_kind='pg' AND a.companion_id IS NULL;
 result:=jsonb_build_object('success',true,'restored',changed,'participants',participants,'context_version',ctx.context_version,'simulated',true,'values_written',false);
 IF changed>0 THEN RETURN public.combat_v2_event_complete((event->>'event_id')::uuid,result); END IF;
 RETURN result;
END;
$function$;

COMMIT;
