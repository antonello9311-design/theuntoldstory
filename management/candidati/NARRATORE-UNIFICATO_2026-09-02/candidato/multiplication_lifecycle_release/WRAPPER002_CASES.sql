-- Component ONLY: actual frozen QUIET predicate on synthetic native composite records.
-- Not a full wrapper execution with populated native relations; no FK/trigger/Auth claim.
DO $matrix$
DECLARE checked_at timestamptz:=clock_timestamp(); item jsonb; fixture_claim jsonb;
 observed boolean; wanted boolean; base_claim jsonb:=$base${"id":"00000000-0000-0000-0000-000000000040","round_id":"00000000-0000-0000-0000-000000000010","session_id":"00000000-0000-0000-0000-000000000001","state":"claimed","context_payload":{"ordinary":true},"completion_sha256":null,"completion_result":null,"provider_response_id":null,"provider_request_sha256":null,"raw_output_sha256":null}$base$::jsonb;
BEGIN
 FOR item IN SELECT value FROM jsonb_array_elements($cases$[{"id":"G1_legacy_expired_empty","group":"G1","lease_seconds":-60,"claim_delta":{},"attempts":[],"expected_block":false},{"id":"G2_lease_present","group":"G2","lease_seconds":0,"claim_delta":{},"attempts":[],"expected_block":true},{"id":"G2_lease_future","group":"G2","lease_seconds":60,"claim_delta":{},"attempts":[],"expected_block":true},{"id":"G3_attempt_claim_generated","group":"G3","lease_seconds":-60,"claim_delta":{},"attempts":[{"claim_id":"00000000-0000-0000-0000-000000000040","round_id":"00000000-0000-0000-0000-000000000009","state":"generated"}],"expected_block":true},{"id":"G3_attempt_claim_provider_reserved","group":"G3","lease_seconds":-60,"claim_delta":{},"attempts":[{"claim_id":"00000000-0000-0000-0000-000000000040","round_id":"00000000-0000-0000-0000-000000000009","state":"provider_reserved"}],"expected_block":true},{"id":"G3_attempt_round_generated","group":"G3","lease_seconds":-60,"claim_delta":{},"attempts":[{"claim_id":"00000000-0000-0000-0000-000000000041","round_id":"00000000-0000-0000-0000-000000000010","state":"generated"}],"expected_block":true},{"id":"G3_attempt_round_provider_reserved","group":"G3","lease_seconds":-60,"claim_delta":{},"attempts":[{"claim_id":"00000000-0000-0000-0000-000000000041","round_id":"00000000-0000-0000-0000-000000000010","state":"provider_reserved"}],"expected_block":true},{"id":"G4_completion_sha256","group":"G4","lease_seconds":-60,"claim_delta":{"completion_sha256":"0000000000000000000000000000000000000000000000000000000000000000"},"attempts":[],"expected_block":true},{"id":"G4_completion_result","group":"G4","lease_seconds":-60,"claim_delta":{"completion_result":{"synthetic":true}},"attempts":[],"expected_block":true},{"id":"G4_provider_response_id","group":"G4","lease_seconds":-60,"claim_delta":{"provider_response_id":"qa-synthetic-local"},"attempts":[],"expected_block":true},{"id":"G4_provider_request_sha256","group":"G4","lease_seconds":-60,"claim_delta":{"provider_request_sha256":"0000000000000000000000000000000000000000000000000000000000000000"},"attempts":[],"expected_block":true},{"id":"G4_raw_output_sha256","group":"G4","lease_seconds":-60,"claim_delta":{"raw_output_sha256":"0000000000000000000000000000000000000000000000000000000000000000"},"attempts":[],"expected_block":true}]$cases$::jsonb) LOOP
  wanted:=(item->>'expected_block')::boolean;
  BEGIN
   fixture_claim:=base_claim||(item->'claim_delta')||jsonb_build_object('expires_at',checked_at+make_interval(secs=>(item->>'lease_seconds')::int));
   EXECUTE $predicate$WITH qa_claims AS (
 SELECT (jsonb_populate_record(NULL::combat_consumer_private.narrative_claims,$1)).*
), qa_attempts AS (
 SELECT * FROM jsonb_populate_recordset(NULL::combat_consumer_private.scene_attempts_v2,$2)
)
SELECT EXISTS (
  SELECT 1 FROM qa_claims c
  WHERE c.context_payload->>'ordinary'='true'
    AND c.state NOT IN ('completed','failed','expired')
    AND NOT (
      c.state='claimed'
      AND c.expires_at IS NOT NULL AND c.expires_at < checked_at
      AND c.completion_sha256 IS NULL
      AND c.completion_result IS NULL
      AND c.provider_response_id IS NULL
      AND c.provider_request_sha256 IS NULL
      AND c.raw_output_sha256 IS NULL
      AND NOT EXISTS (
        SELECT 1 FROM qa_attempts a
        WHERE a.claim_id=c.id OR a.round_id=c.round_id
      )
    )
 )
FROM (SELECT $3::timestamptz AS checked_at) qa_clock$predicate$ INTO observed USING fixture_claim,item->'attempts',checked_at;
   INSERT INTO qa_lifecycle002.results(case_id,group_id,expected_block,observed_block,passed)
   VALUES(item->>'id',item->>'group',wanted,observed,observed IS NOT DISTINCT FROM wanted);
  EXCEPTION WHEN OTHERS THEN
   INSERT INTO qa_lifecycle002.results(case_id,group_id,expected_block,passed,error_code,error_detail)
   VALUES(item->>'id',item->>'group',wanted,false,SQLSTATE,SQLERRM);
  END;
 END LOOP;
END $matrix$;
SELECT jsonb_build_object('scope','predicate_component_native_composite_records','expected_cases',12,'cases',(SELECT jsonb_agg(to_jsonb(r) ORDER BY case_id) FROM qa_lifecycle002.results r),'all_pass',(SELECT count(*)=12 AND bool_and(passed) FROM qa_lifecycle002.results));
