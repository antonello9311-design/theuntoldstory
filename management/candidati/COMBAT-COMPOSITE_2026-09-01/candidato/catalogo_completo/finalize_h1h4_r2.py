"""Materializza un Entry H4 soltanto con referto indipendente e P verificato."""
from argparse import ArgumentParser
from pathlib import Path
import hashlib
import json
import re

directory = Path(__file__).resolve().parent
marker = b"__H1H4_PARAMETERS_SHA256__"
delimiter = "$h4_parameters$"

def sha(data):
    return hashlib.sha256(data).hexdigest()

def read(path):
    return json.loads(path.read_bytes())

def require(condition, description):
    if not condition:
        raise ValueError(description)

def reference(path, limit):
    require(re.fullmatch(r"[A-Za-z0-9_.#-]{1," + str(limit) + r"}", path.name), "Ref non valida")
    return path.name

def pg_jsonb(value):
    if isinstance(value, dict):
        keys = sorted(value, key=lambda k: (len(k.encode()), k.encode()))
        return "{" + ", ".join(pg_jsonb(k) + ": " + pg_jsonb(value[k]) for k in keys) + "}"
    if isinstance(value, list):
        return "[" + ", ".join(pg_jsonb(item) for item in value) + "]"
    return json.dumps(value, ensure_ascii=False, allow_nan=False)

args = ArgumentParser(description=__doc__)
args.add_argument("--review", type=Path, required=True)
args.add_argument("--preflight", type=Path, required=True)
args.add_argument("--out", type=Path, required=True)
args.add_argument("--forward-receipt", type=Path)
args.add_argument("--server-p-sha")
cli = args.parse_args()
require(Path("/private/tmp") in cli.out.resolve().parents, "Uscita richiesta sotto /private/tmp")

identity_bytes = (directory / "H1H4_R2_IDENTITY.json").read_bytes()
bundle = sha(identity_bytes)
identity = json.loads(identity_bytes)
for filename, digest in identity["auxiliary_files"].items():
    require(Path(filename).name == filename and sha((directory / filename).read_bytes()) == digest,
            "Artefatto ausiliario divergente da B")
baseline = read(directory / "H1H4_R2_BASELINE.json")
review = read(cli.review)
require(review.get("B") == bundle and review.get("counts") == {"P0": 0, "P1": 0, "P2": 0}
        and review.get("findings") == [], "Serve il referto 0/0/0 vincolato a B")
compatibility = directory / "H1H4_R2_COMPATIBILITY.md"
observed = read(cli.preflight)
if "preflight" in observed:
    observed = observed["preflight"]
current = observed["expected_current"]
require(observed["qualified"] is True and observed["qualified_contents"] == 2
        and observed["open_master"] == observed["open_combat"] == observed["pending_staff"] == 0,
        "Baseline qualificata e attività chiuse richieste")
keys = (
    "expected_mission_qualification_sha256", "expected_attestation_sha256",
    "expected_release_admission_sha256", "expected_mission_capabilities_sha256",
    "expected_content_admission_rows_sha256", "expected_profile_rows_sha256",
)
for field in keys:
    require(re.fullmatch(r"[a-f0-9]{64}", observed[field]), "Preflight incompleto")

if cli.forward_receipt:
    mode = "recovery"
    forward = read(cli.forward_receipt)
    if "release_receipt" in forward:
        forward = forward["release_receipt"]
    require(forward["mode"] == "source" and forward["source_bundle_sha256"] == bundle
            and forward["parent_root_sha256"] == identity["baseline_root_sha256"]
            and forward["root_sha256"] == current["root_sha256"]
            and forward["code_identity_sha256"] == observed["code_identity_sha256"]
            and current["root_bytes"] == 523748
            and current["db_sha256"] == identity["projection"]["new_db"]
            and current["config_sha256"] == identity["projection"]["new_cfg"]
            and observed["publisher_ddl_sha256"] == identity["publisher_ddl_after"]
            and observed["roster_ddl_sha256"] == forward["roster_ddl_sha256"] == identity["roster_ddl_after"]
            and observed["e52_ddl_sha256"] == forward["e52_ddl_sha256"] == identity["e52_ddl_after"]
            and observed["expected_mission_capabilities_sha256"] == baseline["expected_mission_capabilities_sha256"],
            "Serve ricevuta H4 effettivamente installata e preflight corrispondente")
else:
    mode = "source"
    require(current == baseline["expected_current"]
            and all(observed[field] == baseline[field] for field in keys)
            and observed["publisher_ddl_sha256"] == identity["publisher_ddl_before"]
            and observed["roster_ddl_sha256"] == identity["roster_ddl_before"]
            and observed["e52_ddl_sha256"] == identity["e52_ddl_before"],
            "Preflight source divergente da R2")

params = {
    "schema_version": "h1h4-release-parameters/1",
    "mode": mode,
    "source_bundle_sha256": bundle,
    "expected_current": current,
    "review": {"ref": reference(cli.review, 40), "sha256": sha(cli.review.read_bytes()), **review["counts"]},
    "compatibility": {"ref": reference(compatibility, 64), "sha256": sha(compatibility.read_bytes())},
    **{field: observed[field] for field in keys},
}
if cli.forward_receipt:
    params["forward_root_receipt_sha256"] = forward["root_sha256"]
p_sha = sha(pg_jsonb(params).encode())
preimage = json.dumps(params, ensure_ascii=False, separators=(",", ":"))
require(delimiter not in preimage, "Delimitatore presente nei parametri")
literal = delimiter + preimage + delimiter
cli.out.mkdir(parents=True, exist_ok=True)
stem = "H1H4_R2_ENTRY" if mode == "source" else "H1H4_R2_RECOVERY_ENTRY"
(cli.out / (stem + "_P.json")).write_text(json.dumps(params, ensure_ascii=False, indent=2) + "\n")
(cli.out / (stem + "_P_SHA_READONLY.sql")).write_text(
    "SELECT public.combat_v2_sha256(" + literal + "::jsonb) AS parameters_sha256;\n")
if not cli.server_p_sha:
    print(json.dumps({"B": bundle, "mode": mode, "local_p_sha256": p_sha, "status": "PENDING_SERVER_HASH"}))
else:
    require(cli.server_p_sha == p_sha, "L'impronta server dei parametri non coincide")
    name = "H1H4_R2_" + mode.upper() + ".sql"
    template = (directory / name).read_bytes()
    require(sha(template) == identity["sql_files"][name]["sha256"], "Template divergente")
    header = b"\nBEGIN;\n"
    require(template.count(header) == template.count(marker) == 1, "Ancore non uniche")
    binding = ("SELECT pg_catalog.set_config('app.h1h4_release_parameters'," + literal + ",true);\n").encode()
    entry = template.replace(header, header + binding, 1).replace(marker, p_sha.encode(), 1)
    anchor = b"expected_parameters_sha256 constant text:='" + p_sha.encode() + b"'"
    inverse = entry.replace(header + binding, header, 1).replace(
        anchor, b"expected_parameters_sha256 constant text:='" + marker + b"'", 1)
    require(inverse == template, "Inversa Entry divergente")
    (cli.out / (stem + ".sql")).write_bytes(entry)
    print(json.dumps({"B": bundle, "mode": mode, "entry_sha256": sha(entry),
                      "parameters_sha256": p_sha, "status": "ENTRY_REVIEW_REQUIRED"}))
