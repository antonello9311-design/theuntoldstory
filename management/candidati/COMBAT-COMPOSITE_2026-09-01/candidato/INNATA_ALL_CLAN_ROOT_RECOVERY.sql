-- FORWARD RECOVERY SOURCE ONLY; compose with a fresh installed Root/group45 capture.
DO $allc_recovery_not_installable$BEGIN RAISE EXCEPTION 'INNATA_ALL_RECOVERY_FRESH_ROOT_COMPOSITION_REQUIRED';END $allc_recovery_not_installable$;
BEGIN;
CREATE OR REPLACE FUNCTION public.clan_innata_staff_profile_set_v2(p_location uuid,p_master_session uuid,p_profile_key text,p_request_key uuid,p_expected_version bigint) RETURNS jsonb
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.characters;c clan_innata_narrative_private.contexts_v1;d jsonb;fp text;prior jsonb;doc jsonb;outcome jsonb;sc jsonb;ids uuid[];reason text;fact jsonb;
BEGIN
 SELECT * INTO STRICT a FROM public.characters WHERE user_id=auth.uid();
 PERFORM clan_innata_narrative_private.staff_profile_authorize_v1(p_location,p_master_session,a.id);
 IF p_request_key IS NULL OR p_expected_version IS NULL OR p_expected_version<0 THEN RAISE EXCEPTION 'INNATA_PROFILE_INVALID' USING ERRCODE='22023';END IF;
 fp:=public.combat_v2_sha256(jsonb_build_object('api','innata-staff-profile/2','ruleset','innata-all-clan/2:5ab71c326bb0b150ed466bb2e6b76b8e9a83e6bdfe68198777d22ce7b47413b5','character',a.id,'location',p_location,
   'master',p_master_session,'profile',p_profile_key,'expected_version',p_expected_version));
 PERFORM 1 FROM public.locations WHERE id=p_location FOR UPDATE;
 PERFORM pg_advisory_xact_lock(hashtextextended('innata-narrative:'||a.id::text,0));
 SELECT e INTO prior FROM clan_innata_narrative_private.contexts_v1 x CROSS JOIN LATERAL jsonb_array_elements(x.staff_ability_profile->'journal')e
  WHERE x.character_id=a.id AND x.location_id=p_location AND e->>'request_key'=p_request_key::text ORDER BY x.created_at DESC LIMIT 1;
 IF prior IS NOT NULL THEN IF prior->>'fingerprint'IS DISTINCT FROM fp THEN RAISE EXCEPTION 'INNATA_PROFILE_REQUEST_CONFLICT' USING ERRCODE='22023';END IF;
  RETURN(prior->'result')||jsonb_build_object('replayed',true);END IF;
 IF p_profile_key IS NOT NULL AND p_profile_key NOT IN('sabaku-l1','sharingan-l1','byakugan-l1','byakugan-l2','byakugan-l3','byakugan-l4')THEN RAISE EXCEPTION 'INNATA_ALL_NEW_SELECTION_SUSPENDED' USING ERRCODE='55000';END IF;
 IF p_profile_key IS NOT NULL THEN
  d:=clan_innata_narrative_private.profile_definition_v2(p_profile_key);
  IF d->>'availability'<>'ready'THEN RAISE EXCEPTION '%',d->>'reason_code' USING ERRCODE='42501';END IF;
 END IF;
 sc:=clan_innata_narrative_private.scope_v1(p_location,p_master_session,a.id);
 IF sc->>'allowed'IS DISTINCT FROM 'true'THEN RAISE EXCEPTION '%',sc->>'reason' USING ERRCODE='55000';END IF;
 c:=clan_innata_narrative_private.ensure_context_v1(a.id,p_location,p_master_session,NULL);
 IF(c.staff_ability_profile->>'version')::bigint<>p_expected_version THEN RAISE EXCEPTION 'INNATA_PROFILE_STATE_CHANGED' USING ERRCODE='40001';END IF;
 reason:=clan_innata_narrative_private.profile_busy_reason_v2(c.context_id);
 ids:=coalesce(clan_innata_narrative_private.staff_profile_active_ids_v1(c.context_id),'{}'::uuid[]);
 IF reason IS NOT NULL AND NOT(reason='INNATA_PROFILE_ACTIVE'AND p_profile_key IS NOT NULL AND d->>'lifecycle_kind'='maintained'
    AND NOT EXISTS(SELECT 1 FROM unnest(ids)i WHERE i IS DISTINCT FROM(d->>'technique_id')::uuid))
 THEN RAISE EXCEPTION '%',reason USING ERRCODE='55000';END IF;
 doc:=(c.staff_ability_profile-'permission_fact')||jsonb_build_object('version',p_expected_version+1,'profile_key',p_profile_key,'created_by',auth.uid(),'ruleset','innata-all-clan/2:5ab71c326bb0b150ed466bb2e6b76b8e9a83e6bdfe68198777d22ce7b47413b5');
 IF d->>'lifecycle_kind'='passive_permission' THEN
  fact:=jsonb_build_object('schema_version','innata-permission-fact/1','receipt_id',extensions.uuid_generate_v5(p_request_key,'innata-permission-fact/1'),
   'owner_character_id',a.id,'profile_key',p_profile_key,'family',d->'family','tier',d->'level','technique_id',d->'technique_id',
   'profile_version',p_expected_version+1,'source_request',p_request_key,'ruleset','innata-all-clan/2:5ab71c326bb0b150ed466bb2e6b76b8e9a83e6bdfe68198777d22ce7b47413b5','eligible',true,'capabilities_granted',false,'resource_usage_authorized',false,'values_written',false);
  fact:=fact||jsonb_build_object('preimage',fact,'sha256',public.combat_v2_sha256(fact));doc:=doc||jsonb_build_object('permission_fact',fact);
 END IF;
 UPDATE clan_innata_narrative_private.contexts_v1 SET staff_ability_profile=doc WHERE context_id=c.context_id;
 outcome:=clan_innata_narrative_private.profile_state_core_v2(p_location,p_master_session)||jsonb_build_object('schema_version','innata-staff-profile-receipt/2','request_key',p_request_key,'replayed',false);
 doc:=jsonb_set(doc,'{journal}',(doc->'journal')||jsonb_build_array(jsonb_build_object('request_key',p_request_key,'fingerprint',fp,'api_version',2,'ruleset','innata-all-clan/2:5ab71c326bb0b150ed466bb2e6b76b8e9a83e6bdfe68198777d22ce7b47413b5','result',outcome)),false);
 UPDATE clan_innata_narrative_private.contexts_v1 SET staff_ability_profile=doc WHERE context_id=c.context_id;RETURN outcome;
END;
$f$;
CREATE OR REPLACE FUNCTION clan_innata_narrative_private.activate_v1(p_location uuid, p_master_session uuid, p_character uuid, p_technique_id uuid, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.characters;scope jsonb;q clan_innata_narrative_private.config_quotes_v1;c clan_innata_narrative_private.contexts_v1;
 old clan_innata_narrative_private.receipts_v1;fp text;st clan_innata_narrative_private.states_v1;sv bigint;act boolean;cost integer:=0;
 authority uuid;receipt uuid;preimage jsonb;h text;native_result jsonb;result jsonb;flag text;
 p_desired_state boolean:=true;p_expected_version bigint;sim_profile jsonb;
BEGIN
 IF auth.uid()IS NULL THEN RAISE EXCEPTION 'INNATA_AUTH_REQUIRED' USING ERRCODE='42501';END IF;
 IF p_location IS NULL OR p_character IS NULL OR p_technique_id IS NULL OR p_request_key IS NULL
 THEN RAISE EXCEPTION 'INNATA_REQUEST_INVALID' USING ERRCODE='22023';END IF;
 SELECT * INTO STRICT a FROM public.characters WHERE id=p_character AND user_id=auth.uid();
 fp:=public.combat_v2_sha256(jsonb_build_object('actor',a.id,'location',p_location,'master',p_master_session,
  'technique',p_technique_id,'desired',p_desired_state));
 IF p_master_session IS NOT NULL AND EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE id=p_master_session AND owner_kind='human')
  THEN PERFORM 1 FROM public.master_v2_sessions WHERE id=p_master_session FOR UPDATE;END IF;
 PERFORM 1 FROM public.locations WHERE id=p_location FOR UPDATE;
 PERFORM pg_advisory_xact_lock(hashtextextended('innata-narrative:'||a.id::text,0));
 SELECT * INTO old FROM clan_innata_narrative_private.receipts_v1 WHERE character_id=a.id AND request_key=p_request_key;
 IF FOUND THEN
  IF old.fingerprint<>fp THEN RAISE EXCEPTION 'INNATA_REQUEST_CONFLICT' USING ERRCODE='22023';END IF;
  RETURN old.result||jsonb_build_object('replayed',true);
 END IF;
 IF p_technique_id IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)THEN RAISE EXCEPTION 'INNATA_ALL_NEW_ACTIVATION_SUSPENDED' USING ERRCODE='55000';END IF;
 scope:=clan_innata_narrative_private.scope_v1(p_location,p_master_session,a.id);
 IF(scope->>'allowed')::boolean IS DISTINCT FROM true THEN RAISE EXCEPTION '%',scope->>'reason' USING ERRCODE='55000';END IF;
 q:=clan_innata_narrative_private.quote_v1(p_technique_id,NOT(scope->>'is_test')::boolean);
 sim_profile:=clan_innata_narrative_private.staff_profile_for_character_v1(p_location,p_master_session,a.id);
 IF(scope->>'is_test')::boolean AND sim_profile IS NOT NULL THEN
  IF sim_profile->>'lifecycle_kind'<>'maintained'THEN RAISE EXCEPTION 'INNATA_PASSIVE_NOT_ACTIVATABLE' USING ERRCODE='42501';END IF;
  IF p_technique_id IS DISTINCT FROM(sim_profile->>'technique_id')::uuid THEN RAISE EXCEPTION 'INNATA_PROFILE_INVALID' USING ERRCODE='42501';END IF;
 ELSE
 IF NOT EXISTS(SELECT 1 FROM public.character_abilities ca JOIN public.clan_techniques t ON t.id=ca.technique_id
  WHERE ca.character_id=a.id AND ca.technique_id=q.technique_id AND ca.state='attiva'AND t.is_active AND t.is_innata AND(t.level=1 OR t.id IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid))
   AND public._grade_rank(a.rank)>=public._grade_rank(t.req_grade))
 THEN RAISE EXCEPTION 'INNATA_NOT_OWNED' USING ERRCODE='42501';END IF;
 IF p_technique_id IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid)AND NOT clan_innata_narrative_private.byakugan_owned_v1(a.id,p_technique_id)
 THEN RAISE EXCEPTION 'BYAKUGAN_NOT_OWNED' USING ERRCODE='42501';END IF;
 END IF;
 PERFORM clan_innata_private.assert_no_combat_authority(a.id,p_technique_id);
 IF(scope->>'is_test')::boolean THEN
  c:=clan_innata_narrative_private.ensure_context_v1(a.id,p_location,p_master_session,NULL);
  IF EXISTS(SELECT 1 FROM clan_innata_narrative_private.byakugan_catalog_v1 WHERE technique_id=p_technique_id)
  AND EXISTS(SELECT 1 FROM clan_innata_narrative_private.states_v1 protected74
   JOIN clan_innata_narrative_private.byakugan_catalog_v1 tier74 ON tier74.technique_id=protected74.technique_id
   WHERE protected74.context_id=c.context_id AND protected74.active AND protected74.technique_id<>p_technique_id)
  THEN RAISE EXCEPTION 'BYAKUGAN_FAMILY_ALREADY_ACTIVE' USING ERRCODE='55000';END IF;
  INSERT INTO clan_innata_narrative_private.states_v1(context_id,technique_id)VALUES(c.context_id,p_technique_id)
   ON CONFLICT(context_id,technique_id)DO NOTHING;
  SELECT * INTO STRICT st FROM clan_innata_narrative_private.states_v1 WHERE context_id=c.context_id AND technique_id=p_technique_id FOR UPDATE;
  p_expected_version:=st.state_version;
  IF st.active IS DISTINCT FROM p_desired_state THEN
   IF p_desired_state THEN cost:=q.activation_cost;END IF;
   IF c.chakra<cost THEN RAISE EXCEPTION 'INNATA_INSUFFICIENT_CHAKRA' USING ERRCODE='22023';END IF;
   UPDATE clan_innata_narrative_private.contexts_v1 SET chakra=chakra-cost WHERE context_id=c.context_id RETURNING * INTO c;
   UPDATE clan_innata_narrative_private.states_v1 SET active=p_desired_state,state_version=state_version+1
    WHERE context_id=c.context_id AND technique_id=p_technique_id RETURNING * INTO st;
  END IF;
  act:=st.active;sv:=st.state_version;receipt:=gen_random_uuid();
 ELSE
  SELECT coalesce((SELECT state_version FROM clan_innata_private.actor_state WHERE actor_id=a.id AND technique_id=p_technique_id),0)INTO p_expected_version;
  authority:=gen_random_uuid();receipt:=gen_random_uuid();
  preimage:=jsonb_build_object('actor_id',a.id,'technique_id',p_technique_id,'session_id',coalesce(p_master_session,p_location),
   'purpose','innata_l1_activation','authority_version',1);h:=public.combat_v2_sha256(preimage);
  INSERT INTO clan_innata_private.narrative_authorities(authority_id,actor_id,technique_id,session_id,purpose,authority_version,canonical_preimage,authority_sha256,active)
   VALUES(authority,a.id,p_technique_id,coalesce(p_master_session,p_location),'innata_l1_activation',1,preimage,h,true);
  INSERT INTO clan_innata_private.narrative_receipts(receipt_id,actor_id,technique_id,session_id,purpose,authority_id,authority_sha256,active)
   VALUES(receipt,a.id,p_technique_id,coalesce(p_master_session,p_location),'innata_l1_activation',authority,h,true);
  flag:=current_setting('app.allow_chakra_delta',true);PERFORM set_config('app.allow_chakra_delta','1',true);
  native_result:=clan_innata_private.state_set_core(a.id,p_technique_id,p_desired_state,p_request_key,p_expected_version,'authorized_narrative',receipt);
  PERFORM set_config('app.allow_chakra_delta',coalesce(flag,''),true);
  UPDATE clan_innata_private.narrative_receipts SET consumed_request_key=p_request_key,consumed_at=coalesce(consumed_at,clock_timestamp()),active=false
   WHERE receipt_id=receipt AND(consumed_request_key IS NULL OR consumed_request_key=p_request_key);
  IF NOT FOUND THEN RAISE EXCEPTION 'INNATA_RECEIPT_CHANGED' USING ERRCODE='40001';END IF;
  UPDATE clan_innata_private.narrative_authorities SET active=false WHERE authority_id=authority;
  act:=(native_result->>'active')::boolean;sv:=(native_result->>'state_version')::bigint;cost:=(native_result->>'chakra_spent')::integer;
  SELECT chakra INTO a.chakra FROM public.characters WHERE id=a.id;
 END IF;
 result:=jsonb_build_object('schema_version','innata-narrative-command/1','request_key',p_request_key,'character_id',a.id,
  'location_id',p_location,'master_session_id',p_master_session,'technique_id',p_technique_id,'active',act,'state_version',sv,
  'chakra_spent',cost,'chakra_balance',CASE WHEN(scope->>'is_test')::boolean THEN c.chakra ELSE a.chakra END,
  'is_test',(scope->>'is_test')::boolean,'values_written',NOT(scope->>'is_test')::boolean AND cost>0,
  'main_action_consumed',false,'source_receipt_id',receipt,'replayed',false);
 INSERT INTO clan_innata_narrative_private.receipts_v1(character_id,request_key,fingerprint,context_id,is_test,result)
  VALUES(a.id,p_request_key,fp,c.context_id,(scope->>'is_test')::boolean,result);
 RETURN result;
END $function$;
CREATE OR REPLACE FUNCTION clan_innata_private.combat_transition(p_actor uuid, p_technique uuid, p_operation text, p_request uuid, p_expected_state bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; c clan_innata_combat_private.actor_context;
 s clan_innata_combat_private.combat_state%ROWTYPE; previous clan_innata_combat_private.combat_receipts%ROWTYPE;
 scope jsonb; cost_quote jsonb; fp text; amount integer:=0; before_balance integer; real_balance integer;
 receipt uuid; result jsonb; prior_flag text; terminate_reason text;
 t uuid:=p_technique;base_cost integer:=5;replaced jsonb;
BEGIN
 IF t='001f907c-8f32-4758-8a16-ad1730e72c59'::uuid THEN
  RETURN clan_innata_private.combat_transition(p_actor,p_operation,p_request,p_expected_state); END IF;
 IF p_request IS NULL OR p_expected_state IS NULL OR p_operation IS NULL
   OR p_operation NOT IN ('activate','deactivate','upkeep') THEN
   RAISE EXCEPTION 'common_combat_request_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 PERFORM 1 FROM public.combat_v2_sessions WHERE id=a.session_id FOR UPDATE;
 PERFORM 1 FROM combat_consumer_private.activities WHERE session_id=a.session_id FOR UPDATE;
 c:=clan_innata_private.combat_context(a.id);
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 IF p_operation='deactivate'AND a.actor_kind='png'THEN
  scope:=clan_innata_narrative_private.png_drain_scope_v1(a.id,t);
 ELSE scope:=clan_innata_private.combat_scope(p_actor,t);END IF;
 IF t IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid)AND p_operation<>'deactivate'THEN base_cost:=(clan_innata_narrative_private.byakugan_quote_v1(t)).base_cost;END IF;
 IF t IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)AND p_operation<>'deactivate'THEN base_cost:=(clan_innata_narrative_private.quote_v1(t,false)).activation_cost;END IF;
 IF p_operation='activate'AND a.actor_kind='png'THEN
 INSERT INTO clan_innata_narrative_private.png_selections_v1(session_id,actor_id,technique_id,provider_instance_id,mechanical_version_id,source_sha256,snapshot_sha256,selection_request)
 SELECT a.session_id,a.id,t,i.id,i.mechanical_version_ref,i.source_sha256,i.snapshot_sha256,p_request
 FROM public.combat_v2_provider_instances_v1 i WHERE i.id=a.provider_instance_v1_id AND clan_innata_narrative_private.png_profile_valid_v1(a.id,t)
 ON CONFLICT(session_id,actor_id,technique_id)DO NOTHING;
 END IF;
 IF p_operation='activate' AND EXISTS(
   SELECT 1 FROM clan_marionettisti_private.links WHERE owner_actor_id=a.id AND state='connected') THEN
   RAISE EXCEPTION 'common_combat_jutsu_blocked_by_threads' USING ERRCODE='55000'; END IF;
 -- OFF è immediato anche fuori dal turno d'azione; ownership, sessione
 -- e condizioni dello scope restano verificate prima di questa distinzione.
 IF p_operation<>'deactivate' AND (c.phase<>'action' OR c.turn_actor_id<>a.id) THEN
   RAISE EXCEPTION 'common_combat_turn_invalid' USING ERRCODE='55000'; END IF;
 fp:=public.combat_v2_sha256(jsonb_build_object('session',a.session_id,'actor',a.id,
   'round',c.exchange_id,'technique_id',t,'operation',p_operation,'expected_state',p_expected_state));
 SELECT * INTO previous FROM clan_innata_combat_private.combat_receipts
   WHERE session_id=a.session_id AND actor_id=a.id AND request_id=p_request;
 IF FOUND THEN
   IF previous.fingerprint<>fp THEN RAISE EXCEPTION 'common_combat_request_conflict' USING ERRCODE='22023'; END IF;
   RETURN previous.result||jsonb_build_object('replayed',true);
 END IF;
 IF p_operation='activate'AND t IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)THEN RAISE EXCEPTION 'INNATA_ALL_NEW_ACTIVATION_SUSPENDED' USING ERRCODE='55000';END IF;
 IF p_operation='deactivate'AND a.actor_kind='png'THEN
  SELECT * INTO STRICT s FROM clan_innata_combat_private.combat_state WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t FOR UPDATE;
 ELSE s:=clan_innata_private.combat_state_ensure(a.id,t);END IF;
 IF s.state_version<>p_expected_state THEN RAISE EXCEPTION 'common_combat_state_stale' USING ERRCODE='40001'; END IF;

 IF p_operation='activate' AND NOT s.active AND c.activity_kind='ordinary_v2'
   AND NOT clan_innata_private.combat_activation_window(a.id,t) THEN
  RAISE EXCEPTION 'common_activation_window_closed' USING ERRCODE='55000'; END IF;
 IF p_operation='activate' AND NOT s.active THEN amount:=base_cost;
 ELSIF p_operation='upkeep' THEN
   IF NOT s.active THEN RAISE EXCEPTION 'common_combat_innata_inactive' USING ERRCODE='55000'; END IF;
   IF s.activated_round_id IS DISTINCT FROM c.exchange_id AND s.last_upkeep_round_id IS DISTINCT FROM c.exchange_id THEN amount:=base_cost; END IF;
 END IF;
 IF amount>0 THEN
  cost_quote:=clan_hyuga_private.sedici_cost_quote(a.id,amount);
  amount:=(cost_quote->>'total')::integer;
 END IF;
 IF jsonb_typeof(a.mechanics_snapshot->'chakra') IS DISTINCT FROM 'number' THEN
   RAISE EXCEPTION 'common_combat_chakra_snapshot_invalid'; END IF;
 before_balance:=(a.mechanics_snapshot->>'chakra')::integer;
 IF before_balance<amount THEN
   IF p_operation='upkeep' THEN amount:=0; terminate_reason:='insufficient_chakra';
   ELSE RAISE EXCEPTION 'common_combat_insufficient_chakra' USING ERRCODE='22023'; END IF;
 END IF;
 IF amount>0 AND NOT (scope->>'is_test')::boolean AND a.actor_kind='pg' THEN
   SELECT chakra INTO STRICT real_balance FROM public.characters WHERE id=a.character_id FOR UPDATE;
   IF real_balance<amount THEN
     IF p_operation='upkeep' THEN amount:=0; terminate_reason:='insufficient_chakra';
     ELSE RAISE EXCEPTION 'common_combat_insufficient_real_chakra' USING ERRCODE='22023'; END IF;
   END IF;
 END IF;
 IF terminate_reason IS NOT NULL THEN
   UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1,
     last_upkeep_round_id=c.exchange_id
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 ELSIF p_operation='activate' AND NOT s.active THEN
   IF(scope->>'is_test')::boolean AND t IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)THEN
    SELECT coalesce(jsonb_agg(jsonb_build_object('technique_id',x.technique_id,'state_version',x.state_version)ORDER BY x.technique_id),'[]'::jsonb)INTO replaced FROM clan_innata_combat_private.combat_state x WHERE x.session_id=a.session_id AND x.actor_id=a.id AND x.active AND x.technique_id<>t AND x.technique_id IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid);
    UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1 WHERE session_id=a.session_id AND actor_id=a.id AND active AND technique_id<>t AND technique_id IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid);
   END IF;
   UPDATE clan_innata_combat_private.combat_state SET active=true,state_version=state_version+1,
     activated_round_id=c.exchange_id,last_upkeep_round_id=c.exchange_id
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 ELSIF p_operation='deactivate' AND s.active THEN
   UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 ELSIF p_operation='upkeep' AND amount>0 THEN
   UPDATE clan_innata_combat_private.combat_state SET state_version=state_version+1,last_upkeep_round_id=c.exchange_id
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 END IF;
 receipt:=gen_random_uuid();
 result:=jsonb_build_object('contract_version','common-combat-innata/1','receipt_id',receipt,
   'operation',p_operation,'technique_id',t,'active',s.active,'state_version',s.state_version,
   'technique_cost',CASE WHEN amount>0 THEN cost_quote ELSE NULL END,'chakra_spent',amount,'main_action_consumed',false,'is_test',(scope->>'is_test')::boolean,
   'values_written',amount>0 AND NOT (scope->>'is_test')::boolean,'replayed',false,'termination_reason',terminate_reason);
 IF replaced IS NOT NULL THEN result:=result||jsonb_build_object('replaced_family_states',replaced);END IF;
 INSERT INTO clan_innata_combat_private.combat_receipts(receipt_id,session_id,round_id,actor_id,technique_id,
   operation,request_id,fingerprint,chakra_spent,is_test,result)
   VALUES(receipt,a.session_id,c.exchange_id,a.id,
     t,
     p_operation,p_request,fp,amount,(scope->>'is_test')::boolean,result);
 IF amount>0 THEN
   INSERT INTO clan_innata_combat_private.combat_resource_ledger(receipt_id,expected_amount,committed_amount,
     applied_amount,is_test,balance_before,balance_after)
     VALUES(receipt,amount,amount,CASE WHEN (scope->>'is_test')::boolean THEN 0 ELSE amount END,
       (scope->>'is_test')::boolean,before_balance,before_balance-amount);
   UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(mechanics_snapshot,'{chakra}',to_jsonb(before_balance-amount),false)
     WHERE id=a.id;
   IF NOT (scope->>'is_test')::boolean AND a.actor_kind='pg' THEN
     prior_flag:=current_setting('app.allow_chakra_delta',true);
     PERFORM set_config('app.allow_chakra_delta','1',true);
     UPDATE public.characters SET chakra=chakra-amount WHERE id=a.character_id;
     PERFORM set_config('app.allow_chakra_delta',coalesce(prior_flag,''),true);
   END IF;
 END IF;
 RETURN result;
END $function$;
COMMIT;
