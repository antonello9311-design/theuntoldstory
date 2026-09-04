#!/usr/bin/env python3
import hashlib
import json
import re
from pathlib import Path

here = Path(__file__).resolve().parent
root = here.parents[1]
manifest = json.loads((here / "MANIFESTO.json").read_text())
banks = json.loads((here / "BANCHI.json").read_text())
sub_pin = json.loads((root / "sostituzione/candidato/PROFILE_PIN.json").read_text())
adapter = json.loads((root / "adapter/candidato/CONTRACT.json").read_text())
receipt_schema = json.loads((root / "receipt/candidato/SCHEMA.json").read_text())
receipt_contract = (root / "receipt/candidato/CONTRATTO.md").read_text()
sub_contract = (root / "sostituzione/candidato/CONTRATTO.md").read_text()
adapter_contract = (root / "adapter/candidato/CONTRATTO.md").read_text()
migration_attestation = (root / "sostituzione/candidato/MIGRATION_CANDIDATE_NON_APPLICARE.sql").read_text()

errors = []
identity = [
    "exchange_id", "exchange_version", "root_application_id",
    "attack_application_id", "defense_application_id",
    "substitution_event_id", "resolution_revision"
]

def check(ok, code):
    if not ok:
        errors.append(code)

check(manifest["shared_identity"] == "combat_exam_exchange_identity_v1", "identity_manifest")
check(sub_pin["exchange_identity"] == manifest["shared_identity"], "identity_substitution")
check(adapter["identity_profile_id"] == manifest["shared_identity"], "identity_adapter")
check(adapter["identity_fields_in_order"] == identity, "identity_field_order")
check(all(x in receipt_contract for x in identity), "identity_receipt")
check("exact `substitution_event_id`" in sub_contract, "substitution_event_source")
check(sub_pin["mission_profile_is_authority"] is False, "mission_authority")
check(adapter["spatial_receipt_profile_id"] == "combat_exam_narrative_spatial_receipt_v1", "receipt_profile")
check("pending_unresolved" in adapter_contract and "pending_unresolved" in receipt_contract, "counterattack_pending")
check("server" in adapter_contract.lower() and "next_initiative" in json.dumps(receipt_schema), "initiative_authority")
schema_text = json.dumps(receipt_schema).lower()
check(not re.search(r'"(x|y|x_m|y_m|coordinates?)"\s*:', schema_text), "raw_coordinate_schema")
check("additionalProperties\": false" in json.dumps(receipt_schema), "closed_schema")
check(len(banks["cases"]) == 24 and banks["count"] == 24, "integration_banks")
check(manifest["component_banks"] == 101 and manifest["total_banks"] == 125, "total_banks")
check(manifest["gate"] == "STOP_BRANCH_QA_NOT_ALIGNED", "branch_stop")
check(manifest["qa_branch"]["aligned"] is False, "branch_alignment")
check(manifest["live_baseline"]["open_exam_policy"] == "frozen_untouched", "open_exam_policy")
check(all(manifest[k] is False for k in ("live_mutation", "apply_authorized", "enable_authorized", "smoke_authorized")), "no_authority")
check(not re.search(r'(?im)^\s*(create|alter|drop|insert|update|delete|truncate|grant|revoke)\b', migration_attestation), "attestation_mutates")

for component in manifest["components"].values():
    sums = (here / component["path"] / "SHA256SUMS").resolve()
    check(sums.exists(), "component_seal_missing")
    if sums.exists():
        digest = hashlib.sha256(sums.read_bytes()).hexdigest()
        check(digest == component["sha256sums_seal"], "component_seal_drift")

print(json.dumps({
    "candidate": manifest["candidate_id"],
    "component_banks": manifest["component_banks"],
    "integration_banks": banks["count"],
    "total_banks": manifest["total_banks"],
    "errors": errors,
    "result": "GREEN_STATIC_STOP_BRANCH" if not errors else "RED"
}, indent=2))
raise SystemExit(1 if errors else 0)
