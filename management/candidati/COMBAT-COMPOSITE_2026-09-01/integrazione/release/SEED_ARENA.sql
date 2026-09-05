-- Migration separata proposta: esame_spatial_arena_konoha_seed_001.
-- Versione assegnata/verificata assente da DB-CORE: 20260904233137.
-- SOLO Konoha reale attiva. Nessun account/sessione/prova, Suna o Staff flag.
-- Il binding usa metadata del contratto Esame a due slot, NON un roster Missioni.
-- L'abilitazione della route e' esplicita: eseguire soltanto nel GO nominato del seed.
DO $seed$
DECLARE
 loc constant uuid := 'df83cd65-b13d-49d6-ad77-a44f35d5ea00';
 tk constant text := 'exam_konoha_10x10_v1';
 bid constant uuid := md5('exam-binding|konoha|10x10|v1')::uuid;
 slot_contract jsonb := '{"contract":"exam-dynamic-two-slots/1","candidate":"esame_prove.candidate_character","opponent":"esame_prove.profilo_id","slots":["PG-A","PNG-A"]}';
 geometry jsonb := '[["A1","palo di legno",1.5,8,0.25],["A2","cassa di legno piccola",3,7,0.30],["A3","cavalletto di ferro",6.5,7.5,0.25],["A4","cilindro blu",7.5,6,0.35],["A5","cassa di legno grande",8.5,5,0.40],["A6","rotoli di stuoia",1,2.5,0.60],["A7","cavalletto di legno",4.5,3,0.25],["A8","secondo cavalletto di legno",5.5,3.5,0.25]]';
 migration_version text; g jsonb; shape_value jsonb;
BEGIN
 IF current_user <> 'postgres' THEN RAISE EXCEPTION 'SEED_OWNER_REQUIRED'; END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('exam-arena-seed:konoha:v1',0));
 IF EXISTS(SELECT 1 FROM public.esame_prove WHERE stato='aperta') THEN RAISE EXCEPTION 'SEED_ACTIVE_EXAM_BLOCKED'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.locations WHERE id=loc AND region='konoha'
  AND is_active AND is_academy AND is_exam_room AND NOT is_test) THEN RAISE EXCEPTION 'SEED_LOCATION_DRIFT'; END IF;
 IF EXISTS(SELECT 1 FROM combat_spatial.exam_arena_routes_v1 WHERE class_location_id=loc)
 OR EXISTS(SELECT 1 FROM combat_spatial.arena_templates WHERE template_key=tk)
 OR EXISTS(SELECT 1 FROM combat_spatial.mission_bindings WHERE binding_id=bid OR binding_key='exam-konoha-10x10-v1') THEN
  RAISE EXCEPTION 'SEED_ALREADY_PRESENT_OR_DRIFT'; END IF;
 SELECT version INTO STRICT migration_version FROM supabase_migrations.schema_migrations
  WHERE name='esame_spatial_integrated_release_001';
 IF migration_version<>'20260904233136' THEN RAISE EXCEPTION 'SEED_RELEASE_VERSION_DRIFT'; END IF;
 IF (SELECT md5(prosrc) FROM pg_catalog.pg_proc WHERE oid=to_regprocedure('public._esame_payload_v5_complete_v1(uuid,jsonb)'))
  IS DISTINCT FROM '31e16bcaaba7cab4b3b096d135b8a8f0' THEN RAISE EXCEPTION 'SEED_RELEASE_NOT_INSTALLED'; END IF;
 INSERT INTO combat_spatial.arena_templates(template_key,template_version,contract_version,width_m,height_m,actor_radius_m,
  geometry_contract_id,geometry_contract_version,geometry_hash,required_shape_keys,status,source_asset_sha256)
 VALUES(tk,1,'exam-arena/1',10,10,.5,'exam-konoha-ratified-geometry',1,'pending',
  ARRAY['A1','A2','A3','A4','A5','A6','A7','A8'],'ready',
  '1ac91f308fcce1f866c4f90f0686808f1b42e55981f8a83c6b08196488cf0b7d');
 INSERT INTO combat_spatial.arena_slots(template_key,template_version,slot_key,actor_kind,x_m,y_m)
 VALUES(tk,1,'PG-A','PG',2,5),(tk,1,'PNG-A','PNG',7,5);
 FOR g IN SELECT value FROM jsonb_array_elements(geometry) LOOP
  shape_value:=jsonb_build_object('cx',(g->>2)::numeric,'cy',(g->>3)::numeric,'radius',(g->>4)::numeric);
  INSERT INTO combat_spatial.arena_objects(template_key,template_version,object_key,object_kind,semantic_label,
   shape_kind,shape,shape_hash,blocks_movement,substitutable,lifecycle,geometry_version)
  VALUES(tk,1,g->>0,'substitution_anchor',g->>1,'circle',shape_value,
   encode(extensions.digest(shape_value::text,'sha256'),'hex'),true,true,'portable_single_use',1);
 END LOOP;
 UPDATE combat_spatial.arena_templates SET geometry_hash=combat_spatial.geometry_fingerprint(tk,1)
 WHERE template_key=tk AND template_version=1;
 INSERT INTO combat_spatial.mission_bindings(binding_id,binding_key,binding_version,location_id,template_key,template_version,
  roster_contract_id,roster_contract_version,roster_seal_sha256,roster_profile_id,roster_profile_key,roster_profile_sha256,
  guard_migration_version,guard_migration_name,guard_function_md5,enabled)
 VALUES(bid,'exam-konoha-10x10-v1',1,loc,tk,1,'exam-dynamic-two-slots',1,
  encode(extensions.digest(slot_contract::text,'sha256'),'hex'),md5('exam-dynamic-two-slots|1')::uuid,
  'exam-dynamic-two-slots-v1',encode(extensions.digest(slot_contract::text,'sha256'),'hex'),
  migration_version,'esame_spatial_integrated_release_001',
  jsonb_build_object('public._esame_payload_v5_complete_v1(uuid,jsonb)','31e16bcaaba7cab4b3b096d135b8a8f0'),true);
 INSERT INTO combat_spatial.exam_arena_routes_v1(class_location_id,binding_id,template_key,template_version,
  candidate_slot_key,png_slot_key,route_version,enabled)
 VALUES(loc,bid,tk,1,'PG-A','PNG-A',1,true);
 IF (SELECT count(*) FROM combat_spatial.arena_objects WHERE template_key=tk AND template_version=1)<>8
 OR (SELECT count(*) FROM combat_spatial.arena_slots WHERE template_key=tk AND template_version=1)<>2
 OR (SELECT geometry_hash FROM combat_spatial.arena_templates WHERE template_key=tk AND template_version=1)
  IS DISTINCT FROM combat_spatial.geometry_fingerprint(tk,1) THEN RAISE EXCEPTION 'SEED_POSTCONDITION_FAILED'; END IF;
END $seed$;
