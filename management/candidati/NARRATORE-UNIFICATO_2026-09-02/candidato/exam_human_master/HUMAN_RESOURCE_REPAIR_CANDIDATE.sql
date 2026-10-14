DO $preflight$ BEGIN IF current_user<>'postgres' OR md5(pg_get_functiondef('public.mission_factory_sensitive_review_state_v1(uuid)'::regprocedure)) IS DISTINCT FROM '6cab84fba9f15226a8838a089a7c2268' THEN RAISE EXCEPTION 'HUMAN_SENSITIVE_STATE_BASELINE_CAS';END IF; IF EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND closed_at IS NULL) THEN RAISE EXCEPTION 'HUMAN_SENSITIVE_STATE_STAFF_QUIESCENCE';END IF; PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1(); END $preflight$;
CREATE OR REPLACE FUNCTION public.mission_factory_sensitive_review_state_v1(p_draft uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare d mission_factory_owner.drafts; r mission_factory_owner.sensitive_reviews;
        admin_role boolean;
begin
  select * into strict d from mission_factory_owner.drafts where id=p_draft;
  perform mission_factory_owner.assert_editor(d.author_user);
  select p.role='admin' into admin_role from public.profiles p where p.id=auth.uid();
  select * into r from mission_factory_owner.sensitive_reviews
    where draft_id=p_draft and document_sha256=d.document_sha256
    order by requested_at desc,request_key desc limit 1;
  return jsonb_build_object('schema_version','mission-factory-sensitive-review-state/1',
    'draft_id',p_draft,'required',d.sensitive_review_required,'document_sha256',d.document_sha256,
    'request_key',r.request_key,'status',case when not d.sensitive_review_required then 'not_requested'
      when r.request_key is null then 'needs_request' else r.status end,
    'can_decide',coalesce(admin_role,false) and coalesce(r.status='requested',false));
end $function$
;
DO $postflight$ BEGIN IF md5((SELECT prosrc FROM pg_proc WHERE oid='public.mission_factory_sensitive_review_state_v1(uuid)'::regprocedure)) IS DISTINCT FROM 'a9b97352a15680a287eb590e272c0cb8' THEN RAISE EXCEPTION 'HUMAN_SENSITIVE_STATE_POST_CAS';END IF; PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1(); END $postflight$;
