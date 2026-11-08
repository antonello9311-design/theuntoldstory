-- AGG5 FINAL SOURCE_ONLY. Fix private S22 queue witness for pg_net0.20.3 MVCC; AGG4 durable proof preserved.

CREATE OR REPLACE FUNCTION combat_consumer_private.tactics_w9_never_sent_v1(p_claim uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT (coalesce(p_claim='7828af22-05b3-4bc0-b697-cd3bec9eea25'::uuid AND EXISTS(
 SELECT 1 FROM combat_consumer_private.narrative_claims c
 JOIN combat_consumer_private.scene_attempts_v2 a ON a.claim_id=c.id
 JOIN combat_consumer_private.activities ctx ON ctx.session_id=c.session_id
 JOIN combat_consumer_private.narrative_authorities au ON au.session_id=c.session_id
 JOIN public.combat_v2_round_reports r ON r.id=c.report_id AND r.round_id=c.round_id
 WHERE c.id=p_claim AND c.session_id='0efaeff6-b310-4d37-81cd-f7bdb99ddddc'::uuid AND c.round_id='cfd45e3e-2ea1-494c-a1fd-f5c02102cc76'::uuid AND c.report_id='977e5b96-72ff-4dd7-b7c7-64a6e6b219d2'::uuid
 AND public.combat_v2_sha256(to_jsonb(c))='982cee3d324ada86c311f85bb867b52065169f2674be456bdb222b9848eaf8ea' AND public.combat_v2_sha256(to_jsonb(a))='503a21a9a77faada07a44c1bc12eee42a35e67bd019cd6acb7abcecf8b8953ef'
 AND public.combat_v2_sha256(to_jsonb(ctx))='0418f857877c3913c77a908319b3f5d874d5396e2ad183d39eda95ac79f04f92'
 AND c.state IN('claimed','expired')AND c.expires_at<clock_timestamp()AND c.completion_result IS NULL
 AND c.provider_response_id IS NULL AND c.provider_request_sha256 IS NULL AND c.raw_output_sha256 IS NULL
 AND a.state='claimed'AND a.permit_at IS NULL AND a.result_payload IS NULL AND a.provider_response_id IS NULL
 AND ctx.phase='resolved'AND ctx.exchange_id=c.round_id AND ctx.context_version=c.context_version
 AND au.mode='ai_auto'AND au.control_version=c.control_version AND r.narration_state='attesa'AND r.mechanics_sha256=c.report_sha256
 AND combat_consumer_private.tactics_w9_ordinary_policy_v1(c.session_id,true)IS NOT NULL
 AND NOT EXISTS(SELECT 1 FROM staff_ai_quota_private.calls q WHERE q.producer='combat_narratore_ai'AND(q.source_id=c.id OR q.scope_id=c.session_id))
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_narratives n WHERE n.round_id=c.round_id)
 AND combat_consumer_private.narrative_allowed(c.session_id)
 AND (SELECT count(*)=2 AND bool_and(coalesce(h.status_code=503 AND NOT h.timed_out AND CASE WHEN left(ltrim(h.content),1)='{' THEN h.content::jsonb->>'state'='uncertain'
 AND h.content::jsonb->>'phase'='provider_authorization'AND h.content::jsonb->'provider_retry_allowed'='false'::jsonb ELSE false END,false))
 FROM net._http_response h WHERE h.id IN(11,12))
 ),false)) OR (coalesce(p_claim='8461c789-8998-4493-bd7c-729b54d82e49'::uuid AND EXISTS(
 SELECT 1 FROM combat_consumer_private.recovery_claims_v1 c
 JOIN combat_consumer_private.recovery_attempts_v1 a ON a.claim_id=c.id
 JOIN combat_consumer_private.activities ctx ON ctx.session_id=c.session_id
 JOIN combat_consumer_private.narrative_authorities au ON au.session_id=c.session_id
 JOIN public.combat_v2_round_reports r ON r.id=c.report_id AND r.round_id=c.round_id
 WHERE c.id=p_claim AND c.parent_claim_id='7828af22-05b3-4bc0-b697-cd3bec9eea25'::uuid AND c.session_id='0efaeff6-b310-4d37-81cd-f7bdb99ddddc'::uuid AND c.round_id='cfd45e3e-2ea1-494c-a1fd-f5c02102cc76'::uuid
 AND c.request_key='ac71bdd9-c8fc-51f4-bac3-e37a6d5b4ed1'::uuid AND a.request_key=c.request_key
 AND public.combat_v2_sha256(to_jsonb(c))='7d521955988323f4cff93ec8f0c1e19f480f32170db672ec7882428d4b67c9e8'
 AND public.combat_v2_sha256(to_jsonb(a))='2710577e97af01c6690c7c8d3490e74fb1af057bb6286d09b7c932e538e1cd74'
 AND public.combat_v2_sha256(to_jsonb(ctx))='0418f857877c3913c77a908319b3f5d874d5396e2ad183d39eda95ac79f04f92'
 AND c.state='claimed'AND c.expires_at<clock_timestamp()AND c.completion_result IS NULL
 AND c.provider_response_id IS NULL AND c.provider_request_sha256 IS NULL AND c.raw_output_sha256 IS NULL
 AND a.state='claimed'AND a.permit_at IS NULL AND a.result_payload IS NULL AND a.provider_response_id IS NULL
 AND ctx.phase='resolved'AND ctx.exchange_id=c.round_id AND ctx.context_version=c.context_version
 AND au.mode='ai_auto'AND au.control_version=c.control_version AND r.narration_state='attesa'AND r.mechanics_sha256=c.report_sha256
 AND combat_consumer_private.tactics_w9_ordinary_policy_v1(c.session_id,true)IS NOT NULL
 AND NOT EXISTS(SELECT 1 FROM staff_ai_quota_private.calls q WHERE q.producer='combat_narratore_ai'AND(q.scope_id=c.session_id OR q.source_id IN(c.id,c.parent_claim_id)))
 AND NOT EXISTS(SELECT 1 FROM public.ai_orchestra_audit aa WHERE aa.origine_tabella='combat_s22_count'AND aa.origine_id=c.id::text)
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_narratives n WHERE n.round_id=c.round_id)
 AND NOT EXISTS(SELECT 1 FROM public.ai_orchestra_audit aa WHERE aa.origine_tabella='combat_s22_resume'AND aa.origine_id=c.id::text AND aa.versione_funzione='combat-w10-resume/1'AND aa.usage_api->>'stage'='lease_resumed')
 AND (EXISTS(SELECT 1 FROM net._http_response h WHERE h.id=13 AND h.status_code=503 AND NOT h.timed_out
 AND public.combat_v2_sha256(jsonb_build_object('id',h.id,'status_code',h.status_code,'content',h.content,'timed_out',h.timed_out,'created',h.created))='f441faa3ddacb97c770c08bcb6f5ce16227ca3d164aacf3fc47dbbc667b837a8') OR EXISTS(SELECT 1 FROM public.ai_orchestra_audit dp WHERE dp.consumer='combat_narratore_ai'AND dp.origine_tabella='combat_s22_resume'AND dp.origine_id='8461c789-8998-4493-bd7c-729b54d82e49'AND dp.versione_funzione='combat-w10-ttl-proof/1'
 AND dp.impronta_prompt='9ac25b4bc06041dbeab952b667f5ba813e6f0b295042d36ad30f46927443d929'AND dp.impronta_repertorio='5b14515d62b3d4cd23cf9088541989f221703de395426a14eb2a0f99cff0fae5'AND public.combat_v2_sha256(dp.usage_api)='9ac25b4bc06041dbeab952b667f5ba813e6f0b295042d36ad30f46927443d929'AND dp.usage_api->>'stage'='ttl_prepared'
 AND EXISTS(SELECT 1 FROM supabase_migrations.schema_migrations em WHERE em.version='20261108204525'AND em.name='combat_ordinary_s22_context_enable_staff_w10_20261108'AND cardinality(em.statements)=1 AND octet_length(em.statements[1])=97979
 AND encode(extensions.digest(convert_to(em.statements[1],'UTF8'),'sha256'),'hex')='329699cc0125503eef2cf511d83d327a33986cd9a2b9c981c0db5d3f2d587f2a'
 AND encode(extensions.digest(convert_to(to_jsonb(em.statements)::text,'UTF8'),'sha256'),'hex')='6b447a53acf330192dd94f21d75af4b657d5304d8870600d6ae80b5a0e0f82c1')))
 AND EXISTS(
 SELECT 1 FROM combat_consumer_private.recovery_approvals_v1 queue_admission
 CROSS JOIN LATERAL(SELECT CASE WHEN queue_admission.evidence_reference~'^S22-W10-NEVER_SENT:QUEUED:[0-9]{1,18}$'
 THEN substring(queue_admission.evidence_reference FROM '[0-9]+$')::bigint ELSE NULL END own_queue_id)queue_authority
 WHERE queue_admission.parent_claim_id=c.parent_claim_id AND queue_admission.is_active
 AND queue_admission.valid_until>clock_timestamp()
 AND(queue_admission.evidence_reference='S22-W10-NEVER_SENT:TTL_READY'OR queue_authority.own_queue_id>14)
 AND(SELECT coalesce(bool_and(coalesce(CASE
   WHEN q.id IN(11,12,13,14)THEN false
   WHEN(q.body IS NOT NULL AND parsed.queue_body IS NULL)THEN false
   WHEN q.id=queue_authority.own_queue_id
     OR parsed.queue_body->>'ordinary_round_id'=c.round_id::text
     OR parsed.queue_body->>'round_id'=c.round_id::text
     OR parsed.queue_body->>'request_key'=c.request_key::text
     OR parsed.queue_body->>'session_id'=c.session_id::text
   THEN queue_authority.own_queue_id>14 AND q.id=queue_authority.own_queue_id
     AND q.method='POST'AND q.timeout_milliseconds=55000
     AND parsed.queue_body=jsonb_build_object('ordinary_round_id',c.round_id,'report_sha256',c.report_sha256,'request_key',c.request_key,'recovery',true)
     AND q.body=convert_to(jsonb_build_object('ordinary_round_id',c.round_id,'report_sha256',c.report_sha256,'request_key',c.request_key,'recovery',true)::text,'UTF8')
   ELSE true END,false)),true)
   AND count(*)FILTER(WHERE q.id=queue_authority.own_queue_id)<=1
 FROM net.http_request_queue q
 CROSS JOIN LATERAL(SELECT CASE WHEN q.body IS NULL OR octet_length(q.body)>65536 THEN NULL::jsonb
   WHEN pg_catalog.pg_input_is_valid(convert_from(q.body,'UTF8'),'jsonb')
   THEN convert_from(q.body,'UTF8')::jsonb ELSE NULL::jsonb END queue_body)parsed)
)
 ),false))
$function$;

CREATE OR REPLACE FUNCTION combat_consumer_private.scene_redeliver_v2(p_tick_token text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE w10_claim combat_consumer_private.recovery_claims_v1%ROWTYPE; item record; a combat_consumer_private.scene_attempts_v2%ROWTYPE;
  c combat_consumer_private.narrative_claims%ROWTYPE; endpoint text; request_id bigint;
BEGIN
  IF nullif(p_tick_token,'') IS NULL THEN RETURN; END IF;
  SELECT narrative_edge_url INTO endpoint FROM combat_consumer_private.runtime_config
    WHERE singleton AND ((enabled AND provider_enabled) OR (staff_test_enabled AND staff_test_provider_enabled));
  IF endpoint IS NULL THEN RETURN; END IF;
  FOR item IN SELECT pending.claim_id,pending.round_id FROM combat_consumer_private.scene_attempts_v2 pending
    JOIN combat_consumer_private.narrative_claims claim ON claim.id=pending.claim_id
    WHERE pending.state IN('claimed','generated') AND pending.redelivery_at IS NULL
      AND coalesce(pending.result_at,pending.created_at)<statement_timestamp()-interval '55 seconds'
      AND (pending.state='generated' OR (pending.permit_at IS NULL AND claim.expires_at>clock_timestamp()+interval '13 seconds'))
      AND combat_consumer_private.scene_current_v2(pending.claim_id)
    ORDER BY pending.created_at LIMIT 4
  LOOP
    PERFORM public.combat_v2_lock_round(item.round_id);
    SELECT * INTO c FROM combat_consumer_private.narrative_claims WHERE id=item.claim_id;
    PERFORM 1 FROM combat_consumer_private.activities WHERE session_id=c.session_id FOR UPDATE;
    PERFORM 1 FROM combat_consumer_private.narrative_authorities WHERE session_id=c.session_id FOR UPDATE;
    SELECT * INTO c FROM combat_consumer_private.narrative_claims WHERE id=item.claim_id FOR UPDATE;
    SELECT * INTO a FROM combat_consumer_private.scene_attempts_v2 WHERE claim_id=item.claim_id FOR UPDATE;
    IF a.state NOT IN('claimed','generated') OR a.redelivery_at IS NOT NULL
      OR (a.state='claimed' AND (a.permit_at IS NOT NULL OR c.expires_at<=clock_timestamp()+interval '13 seconds'))
      OR NOT combat_consumer_private.scene_current_v2(a.claim_id) THEN CONTINUE; END IF;
    -- Un solo diritto di ridispatch per tentativo, consumato sotto lock PRIMA di pg_net.
    UPDATE combat_consumer_private.scene_attempts_v2 SET redelivery_at=clock_timestamp(),redelivery_state='reserved' WHERE claim_id=a.claim_id;
    BEGIN
      request_id:=net.http_post(url:=endpoint,headers:=jsonb_build_object('Content-Type','application/json',
        'x-tick-token',p_tick_token,'x-combat-ordinary','1'),
        body:=jsonb_build_object('ordinary_round_id',a.round_id,'report_sha256',c.report_sha256,'request_key',a.request_key),
        timeout_milliseconds:=55000);
      UPDATE combat_consumer_private.scene_attempts_v2 SET redelivery_state='queued',redelivery_request_id=request_id WHERE claim_id=a.claim_id;
    EXCEPTION WHEN OTHERS THEN
      UPDATE combat_consumer_private.scene_attempts_v2 SET redelivery_state='failed' WHERE claim_id=a.claim_id;
    END;
  END LOOP;
  -- Explicit final admission, one native recovery for the authoritative NEVER_SENT parent only.
  IF combat_consumer_private.tactics_w9_never_sent_v1('7828af22-05b3-4bc0-b697-cd3bec9eea25'::uuid)AND EXISTS(
    SELECT 1 FROM combat_consumer_private.recovery_approvals_v1 WHERE parent_claim_id='7828af22-05b3-4bc0-b697-cd3bec9eea25'::uuid AND is_active
    AND evidence_reference='S22-W9-NEVER_SENT:READY')THEN
    PERFORM public.combat_v2_lock_round('cfd45e3e-2ea1-494c-a1fd-f5c02102cc76'::uuid);
    PERFORM 1 FROM combat_consumer_private.recovery_approvals_v1 WHERE parent_claim_id='7828af22-05b3-4bc0-b697-cd3bec9eea25'::uuid FOR UPDATE;
    IF combat_consumer_private.tactics_w9_never_sent_v1('7828af22-05b3-4bc0-b697-cd3bec9eea25'::uuid)AND EXISTS(
      SELECT 1 FROM combat_consumer_private.recovery_approvals_v1 WHERE parent_claim_id='7828af22-05b3-4bc0-b697-cd3bec9eea25'::uuid AND is_active
      AND evidence_reference='S22-W9-NEVER_SENT:READY')THEN
      SELECT * INTO STRICT c FROM combat_consumer_private.narrative_claims WHERE id='7828af22-05b3-4bc0-b697-cd3bec9eea25'::uuid FOR UPDATE;
      UPDATE combat_consumer_private.recovery_approvals_v1 SET evidence_reference='S22-W9-NEVER_SENT:QUEUE_RESERVED'WHERE parent_claim_id=c.id;
      BEGIN
        request_id:=net.http_post(url:=endpoint,headers:=jsonb_build_object('Content-Type','application/json',
          'x-tick-token',p_tick_token,'x-combat-ordinary','1'),
          body:=jsonb_build_object('ordinary_round_id',c.round_id,'report_sha256',c.report_sha256,
            'request_key',extensions.uuid_generate_v5(c.id,'S22-W9-NEVER-SENT-RECOVERY'),'recovery',true),timeout_milliseconds:=55000);
        UPDATE combat_consumer_private.recovery_approvals_v1 SET evidence_reference='S22-W9-NEVER_SENT:QUEUED:'||request_id::text WHERE parent_claim_id=c.id;
      EXCEPTION WHEN OTHERS THEN
        UPDATE combat_consumer_private.recovery_approvals_v1 SET is_active=false,evidence_reference='S22-W9-NEVER_SENT:QUEUE_FAILED'WHERE parent_claim_id=c.id;
      END;
    END IF;
  END IF;
  -- One new admission, same NEVER_SENT claim and request; no gameplay replay.
  IF clock_timestamp()<'2026-11-08T21:50:39Z'::timestamptz-interval '60 seconds'
    AND combat_consumer_private.tactics_w9_never_sent_v1('8461c789-8998-4493-bd7c-729b54d82e49'::uuid)AND EXISTS(
      SELECT 1 FROM combat_consumer_private.recovery_approvals_v1 ap WHERE ap.parent_claim_id='7828af22-05b3-4bc0-b697-cd3bec9eea25'::uuid AND ap.is_active AND ap.evidence_reference='S22-W10-NEVER_SENT:TTL_READY')THEN
    PERFORM public.combat_v2_lock_round('cfd45e3e-2ea1-494c-a1fd-f5c02102cc76'::uuid);
    PERFORM 1 FROM combat_consumer_private.activities WHERE session_id='0efaeff6-b310-4d37-81cd-f7bdb99ddddc'::uuid FOR UPDATE;
    PERFORM 1 FROM combat_consumer_private.recovery_approvals_v1 WHERE parent_claim_id='7828af22-05b3-4bc0-b697-cd3bec9eea25'::uuid FOR UPDATE;
    IF combat_consumer_private.tactics_w9_never_sent_v1('8461c789-8998-4493-bd7c-729b54d82e49'::uuid)AND EXISTS(
      SELECT 1 FROM combat_consumer_private.recovery_approvals_v1 ap WHERE ap.parent_claim_id='7828af22-05b3-4bc0-b697-cd3bec9eea25'::uuid AND ap.is_active AND ap.evidence_reference='S22-W10-NEVER_SENT:TTL_READY')THEN
      SELECT * INTO STRICT w10_claim FROM combat_consumer_private.recovery_claims_v1 WHERE id='8461c789-8998-4493-bd7c-729b54d82e49'::uuid FOR UPDATE;
      UPDATE combat_consumer_private.recovery_approvals_v1 SET evidence_reference='S22-W10-NEVER_SENT:TTL_QUEUE_RESERVED'WHERE parent_claim_id=w10_claim.parent_claim_id;
      BEGIN
        request_id:=net.http_post(url:=endpoint,headers:=jsonb_build_object('Content-Type','application/json','x-tick-token',p_tick_token,'x-combat-ordinary','1'),
          body:=jsonb_build_object('ordinary_round_id',w10_claim.round_id,'report_sha256',w10_claim.report_sha256,'request_key',w10_claim.request_key,'recovery',true),timeout_milliseconds:=55000);
        UPDATE combat_consumer_private.recovery_approvals_v1 SET evidence_reference='S22-W10-NEVER_SENT:QUEUED:'||request_id::text WHERE parent_claim_id=w10_claim.parent_claim_id;
      EXCEPTION WHEN OTHERS THEN
        UPDATE combat_consumer_private.recovery_approvals_v1 SET is_active=false,evidence_reference='S22-W10-NEVER_SENT:TTL_QUEUE_FAILED'WHERE parent_claim_id=w10_claim.parent_claim_id;
      END;
    END IF;
  END IF;
END $function$;
