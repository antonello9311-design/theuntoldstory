#!/usr/bin/env python3
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent

def load(name):
    return json.loads((ROOT / name).read_text(encoding="utf-8"))

schema = load("SCHEMA.json")
examples = load("ESEMPI_SANITIZZATI.json")
banks = load("BANCHI.json")
contract = (ROOT / "CONTRATTO.md").read_text(encoding="utf-8")

errors = []
case_ids = [row[0] for row in banks["cases"]]
if len(case_ids) != 32 or len(set(case_ids)) != 32:
    errors.append("banchi_non_32_o_duplicati")
if case_ids != [f"P1C-{i:03d}" for i in range(1, 33)]:
    errors.append("banchi_non_continui")

required_contract = [
    "combat_exam_exchange_identity_v1",
    "combat_exam_narrative_spatial_receipt_v1",
    "generic_sostituzione_spatial_v1",
    "before", "impact", "anchor", "after",
    "pending_unresolved", "receipt_request_key_conflict",
    "receipt_distance_band_mismatch"
]
for token in required_contract:
    if token not in contract:
        errors.append(f"contratto_manca:{token}")

for forbidden in ["client decide", "IA calcola", "nearest fallback"]:
    if forbidden in contract:
        errors.append(f"autorita_violata:{forbidden}")

uuid_pattern = re.compile(r"\b[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\b", re.I)
raw_coordinate_keys = {"x", "y", "x_m", "y_m", "coord", "coordinates", "footprint", "segment"}

def walk(value, path="$"):
    if isinstance(value, dict):
        for key, child in value.items():
            if key in raw_coordinate_keys:
                errors.append(f"projection_raw_geometry:{path}.{key}")
            walk(child, f"{path}.{key}")
    elif isinstance(value, list):
        for idx, child in enumerate(value):
            walk(child, f"{path}[{idx}]")
    elif isinstance(value, str) and uuid_pattern.search(value):
        errors.append(f"projection_uuid:{path}")

for name, payload in examples.items():
    walk(payload, f"$.{name}")
    required = schema["required"]
    missing = [key for key in required if key not in payload]
    if missing:
        errors.append(f"example_missing:{name}:{','.join(missing)}")
    if payload.get("outcome") == "substituted":
        if payload.get("continuity") != ["substitution", "reappearance", "opponent_recovery"]:
            errors.append(f"continuity_invalid:{name}")
        if set(payload.get("timeline", {})) != {"before", "impact", "anchor", "after"}:
            errors.append(f"timeline_invalid:{name}")
    for distance in payload.get("relative_distances", []):
        meters = distance["distance_m"]
        expected = "contact" if meters <= 2 else "short" if meters <= 10 else "medium" if meters <= 30 else "long" if meters <= 60 else "out_of_range"
        if distance["range_band"] != expected:
            errors.append(f"distance_band_invalid:{name}")
        if not distance.get("range_profile_version"):
            errors.append(f"distance_profile_missing:{name}")

for forbidden_key in ["actor_id", "body_id", "source_id", "anchor_id", "map_id", "internal_reason_code"]:
    if f'"{forbidden_key}"' in json.dumps(examples, ensure_ascii=False):
        errors.append(f"projection_private_key:{forbidden_key}")

print(json.dumps({
    "profile": "combat_exam_narrative_spatial_receipt_v1",
    "static_cases": len(case_ids),
    "examples": len(examples),
    "errors": errors,
    "result": "GREEN" if not errors else "RED"
}, ensure_ascii=False, indent=2))
sys.exit(1 if errors else 0)
