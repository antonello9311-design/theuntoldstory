-- Recovery dati separato, solo route Konoha di questo rilascio. Nessuna cancellazione.
DO $disable$
DECLARE bid constant uuid:=md5('exam-binding|konoha|10x10|v1')::uuid;
BEGIN
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'SEED_OWNER_REQUIRED'; END IF;
 IF EXISTS(SELECT 1 FROM public.esame_prove WHERE stato='aperta')
 OR EXISTS(SELECT 1 FROM combat_spatial.arena_instances WHERE binding_id=bid AND state='open') THEN
  RAISE EXCEPTION 'SEED_DISABLE_QUIESCENCE_REQUIRED'; END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_spatial.exam_arena_routes_v1
  WHERE class_location_id='df83cd65-b13d-49d6-ad77-a44f35d5ea00' AND binding_id=bid
   AND template_key='exam_konoha_10x10_v1' AND template_version=1 AND route_version=1) THEN
  RAISE EXCEPTION 'SEED_DISABLE_TARGET_DRIFT'; END IF;
 UPDATE combat_spatial.exam_arena_routes_v1 SET enabled=false
 WHERE class_location_id='df83cd65-b13d-49d6-ad77-a44f35d5ea00' AND binding_id=bid;
 UPDATE combat_spatial.mission_bindings SET enabled=false WHERE binding_id=bid;
END $disable$;
