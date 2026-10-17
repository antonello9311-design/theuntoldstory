"""Static JSON Schema inspection only: no provider, database or gameplay execution."""
import hashlib
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
output = Path(sys.argv[2])
raw = source.read_bytes()
duplicates = []
def ordered(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            duplicates.append(key)
        result[key] = value
    return result
schema = json.loads(raw, object_pairs_hook=ordered)
metrics = {"schema_sha256": hashlib.sha256(raw).hexdigest(),
           "duplicate_json_members": duplicates, "properties": 0,
           "enum_values_stored": 0, "references": 0,
           "structural_violations": [], "object_anyof_first_keys": []}
def inspect(node, path):
    if isinstance(node, list):
        for index, value in enumerate(node):
            inspect(value, path + [index])
    elif isinstance(node, dict):
        props = node.get("properties")
        if isinstance(props, dict):
            metrics["properties"] += len(props)
            if node.get("type") != "object" or node.get("additionalProperties") is not False:
                metrics["structural_violations"].append({"path": path, "kind": "OBJECT_CLOSURE"})
            required = node.get("required", [])
            if len(required) != len(set(required)) or set(required) != set(props):
                metrics["structural_violations"].append({"path": path, "kind": "REQUIRED_SET"})
        if "enum" in node:
            values = node["enum"]
            if not isinstance(values, list) or not values:
                metrics["structural_violations"].append({"path": path, "kind": "ENUM_EMPTY"})
            else:
                metrics["enum_values_stored"] += len(values)
                if len(set(json.dumps(v, sort_keys=True) for v in values)) != len(values):
                    metrics["structural_violations"].append({"path": path, "kind": "ENUM_DUPLICATE"})
        if "$ref" in node:
            metrics["references"] += 1
            ref = node["$ref"]
            if not isinstance(ref, str) or not ref.startswith("#/$defs/") or ref[8:] not in schema.get("$defs", {}):
                metrics["structural_violations"].append({"path": path, "kind": "REFERENCE"})
        if isinstance(node.get("anyOf"), list):
            keys = [next(iter(n.get("properties", {})), None) for n in node["anyOf"]]
            if keys and all(k is not None for k in keys):
                metrics["object_anyof_first_keys"].append({"path": path, "keys": keys,
                    "provider_causality": "NOT_PROVEN"})
        for key, value in node.items():
            if key not in ("enum", "const", "description", "title", "examples"):
                inspect(value, path + [key])
inspect(schema, [])

def sanitized(node, literal=False):
    if isinstance(node, str) and literal:
        return "literal_sha256:" + hashlib.sha256(node.encode()).hexdigest()
    if isinstance(node, list):
        return [sanitized(value, literal) for value in node]
    if isinstance(node, dict):
        return {key: sanitized(value, literal or key in ("enum", "const"))
                for key, value in node.items()}
    return node

output.mkdir(parents=True, exist_ok=True)
(output / "STRUCTURAL_SCHEMA.json").write_text(json.dumps({
    "classification": "SANITIZED_STATIC_ONLY_NOT_A_PROVIDER_REQUEST",
    "source_schema_sha256": metrics["schema_sha256"],
    "literal_policy": "All enum and const strings replaced by SHA256 tokens; original lengths in independent metrics.",
    "schema": sanitized(schema)}, ensure_ascii=False, indent=2) + "\n")
(output / "STATIC_METRICS.json").write_text(json.dumps(metrics, ensure_ascii=False, indent=2) + "\n")
print(json.dumps({key: value for key, value in metrics.items()
                  if key not in ("object_anyof_first_keys", "structural_violations")}))
