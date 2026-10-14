BEGIN;DO $recover$ BEGIN IF current_user<>'postgres' OR current_setting('tus.human_preview_policy_recovery',true) IS DISTINCT FROM 'reviewed:quiescent' THEN RAISE EXCEPTION 'HUMAN_PREVIEW_POLICY_RECOVERY_AUTHORITY';END IF;IF md5((SELECT prosrc FROM pg_proc WHERE oid='public.mission_factory_quest_reward_policy_qualify_v2(uuid)'::regprocedure)) IS DISTINCT FROM '86e76aa5671eb1ed989cc022a9de7666' OR (SELECT proacl::text FROM pg_proc WHERE oid='public.mission_factory_quest_reward_policy_qualify_v2(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres,authenticated=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='public.mission_factory_quest_reward_policy_qualify_v2(uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN_PREVIEW_POLICY_RECOVERY_DRIFT';END IF;END $recover$;
CREATE OR REPLACE FUNCTION public.mission_factory_quest_reward_policy_qualify_v2(p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare old mission_factory_owner.quest_fixed30_policy_requests%rowtype;
 ident uuid; doc jsonb; sh text; receipt jsonb; c mission_factory_owner.catalog_versions%rowtype; rejection text;
begin
 perform mission_ai_board_owner.staff_only();
 if auth.uid() is null or p_request is null then raise exception 'MF_FIXED30_POLICY_INPUT' using errcode='22023'; end if;
 BEGIN
   perform mission_factory_owner.quest_fixed30_admission_assert_v2();
 EXCEPTION WHEN SQLSTATE '55000' THEN
   GET STACKED DIAGNOSTICS rejection=MESSAGE_TEXT;
   IF rejection IS DISTINCT FROM 'MF_FIXED30_STAFF_NOT_QUALIFIED' THEN RAISE;END IF;
   -- Policy qualification is authoring, while the G2 reward runtime gate remains unchanged.
   IF auth.role() IS DISTINCT FROM 'authenticated' OR public.is_staff() IS DISTINCT FROM true
      OR mission_factory_owner.c416_kind_live_v1() IS DISTINCT FROM true
      OR mission_factory_owner.c444_enabled_v1() IS DISTINCT FROM true
      OR png_builder_internal.npc_media_completion_staff_v1(auth.uid()) IS DISTINCT FROM true
   THEN RAISE;END IF;
   RAISE EXCEPTION 'HUMAN_PREVIEW_POLICY_RECOVERY_FALLBACK_CLOSED' USING ERRCODE='55000';
   perform mission_factory_owner.manual_authoring_assert_v1('preview',NULL);
 END;
 perform pg_advisory_xact_lock(hashtextextended(p_request::text,30092630));
 select * into old from mission_factory_owner.quest_fixed30_policy_requests where request_key=p_request for share;
 if found then
   if old.actor_user is distinct from auth.uid() then raise exception 'MF_FIXED30_REQUEST_CONFLICT' using errcode='23505'; end if;
   perform mission_factory_owner.quest_reward_policy_checked_v2(old.policy_id);
   return old.receipt;
 end if;
 select * into strict c from mission_factory_owner.catalog_versions where active and qualified for share;
 if c.document_sha256 is distinct from mission_factory_owner.sha(c.document) or not mission_factory_owner.quest_catalog_qualified_v2(c.version) then raise exception 'MF_FIXED30_CATALOG_NOT_QUALIFIED' using errcode='55000'; end if;
 doc:=mission_factory_owner.quest_reward_fixed30_document_v2(); sh:=mission_factory_owner.sha(doc);
 insert into mission_factory_owner.quest_reward_policy_versions(document,document_sha256,qualified,scope,created_by)
 values(doc,sh,true,'staff',auth.uid()) returning id into ident;
 receipt:=jsonb_build_object('schema_version','quest-reward-policy-qualified/2','request_key',p_request,
   'policy_id',ident,'policy_sha256',sh,'document',doc,'scope','staff','catalog_version',c.version,'catalog_sha256',c.document_sha256);
 insert into mission_factory_owner.quest_fixed30_policy_requests(request_key,actor_user,policy_id,document_sha256,catalog_version,catalog_sha256,receipt)
 values(p_request,auth.uid(),ident,sh,c.version,c.document_sha256,receipt);
 return receipt;
end;
$function$
;
DO $post$ BEGIN PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();END $post$;COMMIT;
