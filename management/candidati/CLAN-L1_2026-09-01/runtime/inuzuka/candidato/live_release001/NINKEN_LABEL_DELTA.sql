BEGIN;
SET LOCAL lock_timeout='3s';
DO $pre$ BEGIN
IF md5(pg_get_functiondef('combat_panel_private.master_projection(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '30aa9f3303663b82c69f33b6ddb621fa' THEN RAISE EXCEPTION 'inuzuka_master_label_pre'; END IF;
END $pre$;
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
DO $post$ BEGIN
IF md5(pg_get_functiondef('combat_panel_private.master_projection(uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'd86d087746aef28851e87fb7f57c1d56' THEN RAISE EXCEPTION 'inuzuka_master_label_post'; END IF;
END $post$;
COMMIT;
