#!/usr/bin/env python3
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent
contract = (ROOT / "CONTRATTO.md").read_text(encoding="utf-8")
precheck = (ROOT / "PRECHECK_LIVE_READ_ONLY.sql").read_text(encoding="utf-8")
attestation = (ROOT / "MIGRATION_CANDIDATE_NON_APPLICARE.sql").read_text(encoding="utf-8")
profile = json.loads((ROOT / "PROFILE_PIN.json").read_text(encoding="utf-8"))
banks = json.loads((ROOT / "BANCHI.json").read_text(encoding="utf-8"))

errors = []
ids = [row[0] for row in banks["cases"]]
if ids != [f"P1A-{i:03d}" for i in range(1, 37)]:
    errors.append("banks_not_continuous_1_36")
if len(ids) != len(set(ids)):
    errors.append("banks_not_unique")

required = [
    "generic_sostituzione_spatial_v1",
    "combat_exam_exchange_identity_v1",
    "exchange_id", "exchange_version", "root_application_id",
    "attack_application_id", "defense_application_id",
    "substitution_event_id", "resolution_revision",
    "portable_single_use", "consumed_non_substitutable",
    "<25=3m", "25-49=5m", "50-74=10m", ">=75=15m",
    "reaction1 + chakra5", "full-footprint", "bounds", "occupancy",
    "distance_to_attacker_after_m", "range_profile_version",
    "source, anatomy e target evidence", "operation-scoped"
]
for token in required:
    if token not in contract:
        errors.append(f"contract_missing:{token}")

signatures = [
    "combat_spatial.anchor_is_legal(uuid,uuid,text,text,integer)",
    "combat_spatial.substitution_commit(uuid,uuid,uuid)",
    "public.combat_v2_substitution_options_v1(uuid)",
    "public.combat_v2_substitution_select_v1(uuid,uuid)",
    "public.combat_v2_substitution_resolve_internal_v1(uuid,uuid)",
    "public.exam_substitution_options_v1(uuid,uuid)",
    "public.exam_substitution_commit_v1(uuid,uuid,uuid)"
]
for signature in signatures:
    if signature not in precheck or signature not in attestation:
        errors.append(f"signature_unpinned:{signature}")

for forbidden in ["create table", "create schema", "create function", "insert into", "update ", "delete from", "alter table", "grant execute"]:
    if forbidden in attestation.lower():
        errors.append(f"attestation_is_mutative:{forbidden}")

if "begin read only" not in precheck.lower() or "begin read only" not in attestation.lower():
    errors.append("read_only_guard_missing")
if profile.get("profile_id") != "generic_sostituzione_spatial_v1":
    errors.append("profile_id_mismatch")
if profile.get("p1a_delta") != "ATTESTATION_AND_EXAM_BINDING_ONLY":
    errors.append("p1a_delta_mismatch")
if profile.get("mission_profile_is_authority") is not False:
    errors.append("mission_authority_mismatch")
if profile.get("runtime_status") != "RED_EXAM_ADAPTER_NOT_INTEGRATED":
    errors.append("runtime_status_mismatch")

print(json.dumps({
    "task": "P1-A-COMBAT-EXAM-SUBSTITUTION-REBASE-001",
    "banks": len(ids),
    "errors": errors,
    "result": "GREEN" if not errors else "RED"
}, ensure_ascii=False, indent=2))
sys.exit(1 if errors else 0)
