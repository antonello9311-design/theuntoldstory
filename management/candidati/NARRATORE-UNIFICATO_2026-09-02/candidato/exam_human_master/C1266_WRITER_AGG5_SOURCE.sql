CREATE OR REPLACE FUNCTION mission_generic_owner.unified_batch_payload(p_batch uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare ub mission_generic_owner.unified_batches;uw mission_generic_owner.unified_source_windows;
 source jsonb:='[]';ctx jsonb;srcctx jsonb;part jsonb;parts jsonb:='[]';pending jsonb:='[]';windows jsonb:='[]';receipts jsonb;result jsonb;c1266_roles boolean:=false;
begin
 select * into strict ub from mission_generic_owner.unified_batches where id=p_batch;
 if ub.state not in('preparing','ready') then raise exception 'MUF_BATCH_STATE';end if;
 IF ub.decision->>'schema_version'='mission-director-proposal/4' THEN
  IF NOT mission_generic_owner.c1266_role_scope_v2(ub.master_session_id,false) OR ub.decision#>>'{role_interpretation,schema_version}' IS DISTINCT FROM 'mission-role-interpretation/2' OR ub.decision#>>'{role_disposition,schema_version}' IS DISTINCT FROM 'mission-role-disposition/2' THEN RAISE EXCEPTION 'C1266_TEMPORAL_BATCH_SCOPE';END IF;
  c1266_roles:=true;
 ELSE
  c1266_roles:=ub.decision->>'schema_version'='mission-director-proposal/3';
 END IF;
 IF c1266_roles AND NOT mission_generic_owner.c1266_role_scope_v1(ub.master_session_id,false) THEN RAISE EXCEPTION 'C1266_ROLE_BATCH_SCOPE' USING ERRCODE='42501';END IF;
 receipts:=jsonb_build_array(ub.id);ctx:=ub.context;
 if ctx is not null then ctx:=jsonb_set(ctx,'{authority_receipt_id}',to_jsonb(ub.id));end if;
 if ub.source_window_id is not null then
  select * into strict uw from mission_generic_owner.unified_source_windows where id=ub.source_window_id;
  if ctx is not null then
   ctx:=jsonb_set(ctx,'{sources}',(select coalesce(jsonb_agg(ss),'[]') from jsonb_array_elements(ctx->'sources') ss where ss->>'kind'<>'role'));
  end if;
  srcctx:=uw.context;
  windows:=jsonb_build_array(jsonb_build_object('source_window_id',uw.id,'through',uw.through_at,'role_ids',to_jsonb(uw.role_ids),'source_sha256',uw.source_sha256));
 end if;
 if ub.source_report_id is not null then
  source:=jsonb_build_array(mission_generic_owner.combat_narrative_source(ub.master_session_id,ub.source_report_id)->'payload');
  receipts:=receipts||jsonb_build_array(ub.source_report_id);
 end if;
 if ub.secondary_report_id is not null then
  source:=source||jsonb_build_array(mission_generic_owner.combat_narrative_source(ub.master_session_id,ub.secondary_report_id)->'payload');
  receipts:=receipts||jsonb_build_array(ub.secondary_report_id);
 end if;
 for part in select value from jsonb_array_elements(source) loop
  if jsonb_array_length(coalesce(part->'roleless_declarations','[]'))>0 then
   receipts:=receipts||(select jsonb_agg(rd->'receipt_id') from jsonb_array_elements(part->'roleless_declarations') rd);
   part:=jsonb_build_object('schema_version','mission-unified-mechanical-report/1',
    'native_scene',part-'roleless_declarations','roleless_declarations',part->'roleless_declarations');
  end if;
  parts:=parts||jsonb_build_array(part);
 end loop;
 source:=parts;
 if ub.next_round_id is not null and ub.entry_side='png' then
  pending:=mission_generic_owner.unified_pending(ub.next_round_id);
  receipts:=receipts||(select coalesce(jsonb_agg(pp->'receipt_id'),'[]') from jsonb_array_elements(pending) pp)
   ||(select coalesce(jsonb_agg(pp#>'{roleless_receipt,receipt_id}'),'[]') from jsonb_array_elements(pending) pp where pp ? 'roleless_receipt');
 end if;
 if ctx is not null and ub.source_window_id is null then
  -- Combat continuation context is deliberately free of a second chat-role window.
  ctx:=jsonb_set(ctx,'{sources}',(select coalesce(jsonb_agg(ss),'[]') from jsonb_array_elements(ctx->'sources') ss where ss->>'kind'<>'role'));
 end if;
 select jsonb_agg(distinct ri) into receipts from jsonb_array_elements(receipts) ri;
 -- C1266 temporal writer: role metadata belongs only to the attested source_context.
 -- Preserve all destination/current narrative sources, facts and continuity fields.
 IF c1266_roles AND ub.decision->>'schema_version'='mission-director-proposal/4'
   AND ctx IS NOT NULL AND srcctx IS NOT NULL THEN
  ctx:=ctx-'public_destination_sources'-'role_progression_basis';
 END IF;
 result:=jsonb_build_object('schema_version','mission-generic-narration/3','mode','unified','batch_id',ub.id,
 'composition_kind',ub.composition_kind,'director_proposal',ub.decision,'resolved_scenes',source,'mission_context',ctx,'source_context',srcctx,'pending_offensives',pending,
 'preparation_receipt_id',ub.id,'publication_barrier',jsonb_build_object('closed',true,'required_receipt_ids',receipts,'receipt_ids',receipts),
 'source_windows',windows,'next_state_receipt_id',ub.id);

 if ub.source_window_id is not null
   and mission_generic_owner.flow_scope_enabled(ub.master_session_id)
   and exists(select 1 from mission_generic_owner.role_window_cursors c
     where c.master_session_id=ub.master_session_id) then
   if coalesce(uw.context->>'source_revision','') !~ '^[0-9a-f]{64}$'
     or (ub.decision->>'schema_version'<>'mission-director-proposal/2' AND NOT c1266_roles)
     or ub.next_round_id is not null or jsonb_array_length(pending)<>0
   then raise exception 'MRS_V4_PAYLOAD_BINDING' using errcode='40001';end if;
   if exists(select 1 from jsonb_array_elements(ub.decision->'npc_intents') ni
       where ni->>'entry_kind'='offense'
         and (ni->>'actor_key' !~ '^[a-z][a-z0-9_]{0,63}$'))
     or (select count(*) from jsonb_array_elements(ub.decision->'npc_intents') ni
           where ni->>'entry_kind'='offense')
        <> (select count(distinct ni->>'actor_key') from jsonb_array_elements(ub.decision->'npc_intents') ni
           where ni->>'entry_kind'='offense')
   then raise exception 'MRS_V4_SLOT_KEYS';end if;
   if ub.composition_kind='entry_png' then
     if coalesce(ub.selected_actor_keys,'{}'::text[]) is distinct from
       coalesce((select array_agg(ni->>'actor_key' order by ni->>'actor_key')
          from jsonb_array_elements(ub.decision->'npc_intents') ni
          where ni->>'entry_kind'='offense'),'{}'::text[])
       or cardinality(ub.selected_actor_keys)=0
     then raise exception 'MRS_V4_ENTRY_COHORT';end if;
   elsif exists(select 1 from jsonb_array_elements(ub.decision->'npc_intents') ni
       where ni->>'entry_kind'='offense')
   then raise exception 'MRS_V4_OFFENSE_WITHOUT_ENTRY';end if;
   result:=result||jsonb_build_object(
     'source_revision',uw.context->>'source_revision',
     'offense_slots',coalesce((select jsonb_agg(jsonb_build_object(
       'slot_id',ni->>'actor_key','actor_key',ni->>'actor_key') order by ni->>'actor_key')
       from jsonb_array_elements(ub.decision->'npc_intents') ni
       where ni->>'entry_kind'='offense'),'[]'::jsonb),
     'pending_offensives','[]'::jsonb);
   result:=jsonb_set(result,'{schema_version}',to_jsonb('mission-generic-narration/4'::text));
 end if;
 IF c1266_roles THEN
  IF (ub.decision->>'schema_version'='mission-director-proposal/4' AND (NOT mission_generic_owner.c1266_role_keys_v1(ub.decision->'role_disposition',ARRAY['schema_version','source_window_id','source_revision','decision_work_id','proposed_opportunity_id','effective_opportunity_id','status','reason','interpretation_sha256','temporal_contract_sha256','current_projection_sha256']) OR ub.decision#>>'{role_disposition,temporal_contract_sha256}' IS DISTINCT FROM '64adc5a2eec27bc4ac02ffa3d9f8afd485f3a1f9ea4879b9ccfe1c3bb5b32cc2' OR ub.decision#>>'{role_disposition,current_projection_sha256}' IS DISTINCT FROM public.combat_v2_sha256(mission_generic_owner.c1266_role_current_projection_v2(ub.decision_work_id,ub.decision->'role_interpretation')))) OR (ub.decision->>'schema_version'='mission-director-proposal/3' AND NOT mission_generic_owner.c1266_role_keys_v1(ub.decision->'role_disposition',ARRAY['schema_version','source_window_id','source_revision','decision_work_id','proposed_opportunity_id','effective_opportunity_id','status','reason','interpretation_sha256']))
   OR ub.decision#>>'{role_disposition,decision_work_id}' IS DISTINCT FROM ub.decision_work_id::text
   OR ub.decision#>>'{role_disposition,interpretation_sha256}' IS DISTINCT FROM public.combat_v2_sha256(ub.decision->'role_interpretation')
   OR ub.decision#>'{role_disposition,effective_opportunity_id}' IS DISTINCT FROM ub.decision->'opportunity_id'
  THEN RAISE EXCEPTION 'C1266_ROLE_DISPOSITION_BINDING' USING ERRCODE='40001';END IF;
  result:=jsonb_set(result,'{director_proposal}',ub.decision-'role_disposition')||jsonb_build_object(
   'role_interpretation',ub.decision->'role_interpretation','role_disposition',ub.decision->'role_disposition');
 END IF;
 if octet_length(result::text)>(mission_generic_owner.capacity()->>'input_capacity_bytes')::integer then raise exception 'MUF_CONTEXT_OVERFLOW' using errcode='54000';end if;
 return mission_factory_owner.quest_step_payload_v1(ub.master_session_id,ub.id,result);
end $function$
