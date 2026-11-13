BEGIN;
SET LOCAL lock_timeout='4s';
DO $gate$
BEGIN
 IF current_user<>'postgres' OR auth.uid() IS NOT NULL
 OR NOT EXISTS (SELECT 1 FROM mission_factory_owner.editor_release_readiness WHERE singleton AND revision_sha256='f9ad89a82dfc1912f042907a6ad7a6b7196370abbf288f1fdd3e52f31de664f1' AND observed_revision_sha256=revision_sha256 FOR UPDATE)
 OR NOT EXISTS (SELECT 1 FROM combat_facing_private.release_gate WHERE singleton AND staff_enabled AND NOT public_enabled)
 OR EXISTS (SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL)
 OR EXISTS (SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato IN ('preparazione','in_corso','sospesa','chiusura'))
 OR md5(pg_get_functiondef('combat_panel_private.master_companion_projection(uuid)'::regprocedure)) IS DISTINCT FROM '86ca642361d288bc8c902c019dc22e11'
 THEN RAISE EXCEPTION 'FACING_COMPANION_BASELINE_DRIFT'; END IF;
END $gate$;
CREATE OR REPLACE FUNCTION combat_panel_private.master_companion_projection(p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE owner_actor public.combat_v2_actors%ROWTYPE; b public.combat_v2_actors%ROWTYPE;
 src clan_marionettisti_private.sources%ROWTYPE; h clan_marionettisti_private.chassis%ROWTYPE;
 link clan_marionettisti_private.links%ROWTYPE; label text;
BEGIN
 IF auth.uid() IS NULL OR p_actor IS NULL THEN RETURN NULL; END IF;
 SELECT a.* INTO owner_actor FROM public.combat_v2_actors a
   JOIN public.combat_v2_sessions s ON s.id=a.session_id AND s.source_kind='master'
   JOIN combat_panel_private.master_panel_sessions p ON p.master_session_id=s.master_session_id
   WHERE a.id=p_actor AND a.controller_user=auth.uid() AND a.actor_kind='pg' AND a.companion_id IS NULL;
 IF owner_actor.id IS NULL THEN RETURN NULL; END IF;
 SELECT a.* INTO b FROM public.combat_v2_actors a JOIN clan_marionettisti_private.sources s ON s.id=a.companion_id
   WHERE a.session_id=owner_actor.session_id AND s.owner_character_id=owner_actor.character_id AND s.is_active;
 IF b.id IS NULL THEN RETURN NULL; END IF;
 PERFORM clan_marionettisti_private.assert_companion_actor(b.id,false);
 SELECT * INTO STRICT src FROM clan_marionettisti_private.sources WHERE id=b.companion_id;
 SELECT * INTO STRICT h FROM clan_marionettisti_private.chassis WHERE companion_id=src.id;
 SELECT * INTO link FROM clan_marionettisti_private.links WHERE owner_actor_id=owner_actor.id AND companion_actor_id=b.id;
 -- Match the authoritative Master roster display label for the same body.
 label:='Marionetta';
 RETURN jsonb_build_object('schema_version','combat-companion/1','actor_id',b.id,'display_name',label,
   'commanded_by_me',true,'passive',true,'simulated',src.source_kind='staff',
   'integrity',h.integrity,'integrity_max',h.integrity_max,'link_state',
   CASE WHEN b.state<>'attivo' OR owner_actor.state<>'attivo' OR NOT h.operational THEN 'unavailable'
     ELSE coalesce(link.state,'unavailable') END);
END $function$;
COMMIT;
