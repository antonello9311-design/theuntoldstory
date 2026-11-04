-- SP07 SOURCE ONLY: compose current Root/metadata/recovery and review before apply.
DO $sp07_not_installable$BEGIN RAISE EXCEPTION 'SP07_ROOT_COMPOSITION_REQUIRED';END $sp07_not_installable$;
CREATE OR REPLACE FUNCTION clan_hyuga_private.sedici_common_cost_guard()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE r clan_innata_combat_private.combat_receipts%ROWTYPE; amount integer; base integer;
BEGIN
 IF TG_TABLE_NAME='combat_receipts' THEN
  -- SP07: a native Byakugan base10 is not a legacy base5+Sedici5 cause.
  -- Initial release is limited to the existing, server-proven Staff simulation.
  IF NEW.is_test AND NEW.chakra_spent>0
   AND NEW.technique_id IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,
    '8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,
    'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid)
   AND EXISTS(SELECT 1 FROM public.combat_v2_sessions ss
    JOIN public.combat_v2_actors aa ON aa.session_id=ss.id AND aa.id=NEW.actor_id
    JOIN public.combat_v2_rounds rr ON rr.session_id=ss.id AND rr.id=NEW.round_id
    WHERE ss.id=NEW.session_id AND ss.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
     AND ss.closed_at IS NULL AND NOT public.combat_v2_values_written(ss.id))
   AND (clan_innata_narrative_private.staff_profile_actor_v1(NEW.actor_id)->>'technique_id')::uuid=NEW.technique_id THEN
   IF NEW.operation IS NULL OR NEW.operation NOT IN('activate','upkeep') THEN
    RAISE EXCEPTION 'sedici_common_receipt_cause_required' USING ERRCODE='22023'; END IF;
   SELECT CASE NEW.operation WHEN 'activate' THEN q.activation_cost ELSE q.upkeep_cost END
    INTO STRICT base FROM clan_innata_narrative_private.byakugan_catalog_v1 b
    JOIN clan_innata_narrative_private.config_quotes_v1 q ON q.technique_id=b.technique_id
    WHERE b.technique_id=NEW.technique_id;
   IF base IS NULL OR base<=0 THEN
    RAISE EXCEPTION 'sedici_common_receipt_cause_required' USING ERRCODE='22023'; END IF;
   amount:=clan_hyuga_private.sedici_frozen_cost(NEW.actor_id,
    jsonb_build_object('chakra',base,'technique_cost',NEW.result->'technique_cost'));
   IF amount IS DISTINCT FROM NEW.chakra_spent
    OR NEW.result->'technique_cost' IS DISTINCT FROM clan_hyuga_private.sedici_cost_quote(NEW.actor_id,base) THEN
    RAISE EXCEPTION 'sedici_common_receipt_cause_required' USING ERRCODE='22023'; END IF;
  ELSIF NEW.chakra_spent=10 THEN
   amount:=clan_hyuga_private.sedici_frozen_cost(NEW.actor_id,
    jsonb_build_object('chakra',5,'technique_cost',NEW.result->'technique_cost'));
   IF amount<>10 OR NEW.result#>>'{technique_cost,sedici_delta}' IS DISTINCT FROM '5'
    OR NEW.result->'technique_cost' IS DISTINCT FROM clan_hyuga_private.sedici_cost_quote(NEW.actor_id,5) THEN
    RAISE EXCEPTION 'sedici_common_receipt_cause_required' USING ERRCODE='22023'; END IF;
  END IF;
 ELSE
  SELECT * INTO STRICT r FROM clan_innata_combat_private.combat_receipts WHERE receipt_id=NEW.receipt_id;
  IF NEW.expected_amount IS DISTINCT FROM r.chakra_spent OR NEW.committed_amount IS DISTINCT FROM r.chakra_spent
   OR NEW.is_test IS DISTINCT FROM r.is_test OR NEW.applied_amount IS DISTINCT FROM (CASE WHEN r.is_test THEN 0 ELSE r.chakra_spent END) THEN
   RAISE EXCEPTION 'sedici_common_ledger_receipt_mismatch' USING ERRCODE='22023'; END IF;
 END IF;
 RETURN NEW;
END $function$
