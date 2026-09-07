-- PROPOSTA NON APPLICATA · MARIONETTA-ORDINARY-VISIBILITY-001
-- Fuori freeze77. Eseguibile solo dopo review e GO nominativo; zero DML.
BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='30s';
DO $visibility_fix$
DECLARE f regprocedure; before_meta jsonb; after_meta jsonb; source text; needle text;
BEGIN
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'visibility_owner_required'; END IF;
 f:=to_regprocedure('clan_marionettisti_private.actor_visible(uuid,uuid,uuid)');
 IF f IS NULL THEN RAISE EXCEPTION 'visibility_signature_missing'; END IF;
 SELECT jsonb_build_object('owner',pg_get_userbyid(proowner),'acl',proacl::text,
  'security_definer',prosecdef,'volatility',provolatile,'config',proconfig,
  'result',pg_get_function_result(oid),'arguments',pg_get_function_arguments(oid),
  'strict',proisstrict,'leakproof',proleakproof,'parallel',proparallel,'cost',procost,'rows',prorows)
 INTO before_meta FROM pg_proc WHERE oid=f;
 IF before_meta->>'owner'<>'postgres' OR before_meta->>'acl'<>'{postgres=X/postgres}'
 OR (before_meta->>'security_definer')::boolean IS DISTINCT FROM true
 OR before_meta->>'volatility'<>'s' OR before_meta->'config' IS DISTINCT FROM to_jsonb(ARRAY['search_path=""']::text[])
 THEN RAISE EXCEPTION 'visibility_contract_drift'; END IF;
 SELECT pg_get_functiondef(f) INTO source;
 IF md5(source)<>'ade067af90fe923cc9ebc5d9c88687e0' THEN RAISE EXCEPTION 'visibility_body_drift'; END IF;
 IF md5(pg_get_functiondef('combat_consumer_private.state_projection(uuid)'::regprocedure))<>'3fcf5f9c7b0e655c09d3dceedf99d296'
 THEN RAISE EXCEPTION 'ordinary_authority_drift'; END IF;
 needle:=$old_fragment$and (a.controller_user=p_viewer or exists($old_fragment$;
 IF (length(source)-length(replace(source,needle,'')))/length(needle)<>1
 THEN RAISE EXCEPTION 'visibility_patch_match'; END IF;
 source:=replace(source,needle,$new_fragment$and (a.controller_user=p_viewer
   or (
    -- Identica autorità PG della mappa ordinary neutra; nessun grant sintetico.
    i.context_source='ordinary' and a.actor_kind='pg' and a.companion_id is null
    and a.state='attivo'
    and exists(
     select 1 from combat_consumer_private.activities ctx
     join combat_spatial.arena_templates t
      on t.template_key=i.template_key and t.template_version=i.template_version
     join combat_consumer_private.members subject_member
      on subject_member.session_id=ctx.session_id and subject_member.actor_id=a.id
     join combat_consumer_private.members viewer_member
      on viewer_member.session_id=ctx.session_id
     join public.combat_v2_actors viewer_actor
      on viewer_actor.id=viewer_member.actor_id and viewer_actor.session_id=ctx.session_id
     join public.characters viewer_character
      on viewer_character.id=viewer_member.character_id and viewer_character.user_id=p_viewer
     join combat_spatial.actor_states viewer_body
      on viewer_body.instance_id=i.instance_id and viewer_body.actor_id=viewer_actor.id
     where ctx.session_id=p_session and ctx.phase<>'closed'
      and viewer_actor.character_id=viewer_character.id
      and viewer_actor.controller_user=p_viewer and viewer_actor.actor_kind='pg'
      and viewer_actor.state='attivo' and viewer_body.state='active'
      and t.template_key='ordinary_neutral_v1' and t.template_version=1
      and t.geometry_hash='1920b919137f4f58de6d71af2811061a'
      and combat_spatial.template_errors(t.template_key,t.template_version)='[]'::jsonb
      and (select count(*) from combat_consumer_private.members mem where mem.session_id=ctx.session_id)=2
      and combat_consumer_private.runtime_allowed(ctx.location_id,p_viewer)
      and not exists(select 1 from public.combat_sessions legacy
       where legacy.location_id=ctx.location_id and legacy.state='aperto')
    )
   )
   or exists($new_fragment$);
 EXECUTE source;
 -- Helper interno: GRANT esplicito owner soltanto; ACL effettiva invariata.
 GRANT EXECUTE ON FUNCTION clan_marionettisti_private.actor_visible(uuid,uuid,uuid) TO postgres;
 SELECT jsonb_build_object('owner',pg_get_userbyid(proowner),'acl',proacl::text,
  'security_definer',prosecdef,'volatility',provolatile,'config',proconfig,
  'result',pg_get_function_result(oid),'arguments',pg_get_function_arguments(oid),
  'strict',proisstrict,'leakproof',proleakproof,'parallel',proparallel,'cost',procost,'rows',prorows)
 INTO after_meta FROM pg_proc WHERE oid=f;
 IF after_meta IS DISTINCT FROM before_meta OR pg_get_functiondef(f) IS DISTINCT FROM source
 THEN RAISE EXCEPTION 'visibility_postflight_drift'; END IF;
END $visibility_fix$;
COMMIT;
