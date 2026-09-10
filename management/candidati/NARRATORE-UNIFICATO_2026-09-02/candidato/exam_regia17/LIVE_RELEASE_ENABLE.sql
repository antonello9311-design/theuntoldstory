BEGIN;
DO $enable$ DECLARE n integer; BEGIN
 IF NOT EXISTS(SELECT 1 FROM exam_regia_private.runtime WHERE singleton AND NOT enabled AND NOT provider_enabled AND version='EXAM-REGIA17/1' AND provider_call_cap=17)
 OR NOT EXISTS(SELECT 1 FROM exam_regia_private.ordinary_gate WHERE singleton AND NOT ordinary_enabled)
 OR NOT EXISTS(SELECT 1 FROM mission_exam_private.release_gate WHERE singleton AND enabled)
 OR EXISTS(SELECT 1 FROM exam_regia_private.bindings WHERE state<>'closed')
 OR EXISTS(SELECT 1 FROM exam_regia_private.admissions)
 THEN RAISE EXCEPTION 'live60_enable_state_drift'; END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_spatial.arena_templates WHERE template_key='exam_konoha_10x10_v1' AND template_version=1 AND status='ready')
 OR NOT EXISTS(SELECT 1 FROM public.locations WHERE id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND is_active AND is_test)
 OR NOT EXISTS(SELECT 1 FROM public.locations WHERE id='df83cd65-b13d-49d6-ad77-a44f35d5ea00' AND is_active AND is_exam_room AND is_academy AND NOT is_test)
 THEN RAISE EXCEPTION 'live60_enable_route_not_ready'; END IF;
 INSERT INTO exam_regia_private.admissions(owner_user,character_id,location_id,template_key,template_version,surface,enabled,expires_at)
 SELECT c.user_id,c.id,'0b85f354-9cdb-47e1-baf9-3d266bb7e06b','exam_konoha_10x10_v1',1,'staff_test',true,clock_timestamp()+interval '7 days'
 FROM public.characters c JOIN public.profiles p ON p.id=c.user_id
 WHERE (c.id='2a877f02-4993-4e65-9172-7d29f08c5b86' AND c.user_id='15448f47-3b43-416f-a703-dbe7a74d36ce' AND p.role='master')
 OR (c.id='6bceee99-974f-426b-8d92-38b43b4a4267' AND c.user_id='f0856d53-83a6-4de0-bc0c-12c87916e665' AND p.role='admin');
 GET DIAGNOSTICS n=ROW_COUNT;
 IF n<>2 THEN RAISE EXCEPTION 'live60_staff_identity_drift'; END IF;
 UPDATE exam_regia_private.runtime SET enabled=true,provider_enabled=true WHERE singleton;
 UPDATE exam_regia_private.ordinary_gate SET ordinary_enabled=true WHERE singleton;
END $enable$;
COMMIT;
