"""Bind verified evidence into a frozen Land R2 source or a read-only query."""
import argparse
import hashlib
import json
from pathlib import Path
import re

DIRECTORY = Path(__file__).resolve().parent
CONTRACT_FILE = "LAND_R2_RELEASE_CONTRACT.json"
SOURCE_FILE = "LAND_R2_ROOT_SOURCE.sql"
PREFLIGHT_FILE = "LAND_R2_PREFLIGHT_READONLY.sql"
POSTFLIGHT_FILE = "LAND_R2_POSTFLIGHT_READONLY.sql"
SUBJECT_FILE = "LAND_R2_SOURCE_SUBJECT.json"
SUBJECT_FILES = {CONTRACT_FILE, SOURCE_FILE, PREFLIGHT_FILE, POSTFLIGHT_FILE,
                 "LAND_R2_TRANSITIONS_MODEL_READONLY.sql", Path(__file__).name}
MODES = ("install", "recovery_forward", "publication_abort")
ZERO = {"P0": 0, "P1": 0, "P2": 0}
PUBLICATION_INPUT = {
    "schema_version", "repo", "filename", "git_commit", "git_blob", "sha256",
    "bytes", "build", "pages_run_id", "pages_commit", "pages_conclusion", "deployment_success",
}
DOMAIN_INPUT = {
    "schema_version", "url", "status", "sha256", "bytes", "build", "commit", "body_verified",
    "method", "marker", "pages_run_id", "observed_after_pages",
}
APPLY_RECEIPT = {
    "schema_version", "mode", "binding_sha256", "source_subject_sha256", "projection_sha256",
    "review_ref", "previous_root_sha256", "previous_row_sha256", "parent", "active",
    "client_sha256", "root_bytes", "git_commit", "previous_git_commit", "publication_receipt_sha256",
    "two_mission_admissions", "party_flags_preserved", "e52_common_verme",
    "protected_state_sha256", "runtime_staff", "provider_calls", "aborted_release_sha256", "abort_evidence_sha256",
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    data = path.read_bytes()
    return json.loads(data), sha256(data)


def exact(obj, expected, context):
    require(isinstance(obj, dict) and set(obj) == set(expected), f"Campi non validi per {context}.")


def valid_pin(value, length=64):
    return (isinstance(value, str) and re.fullmatch(rf"[0-9a-f]{{{length}}}", value) is not None
            and len(set(value)) > 1)


def valid_findings(findings):
    return (isinstance(findings, dict) and findings == ZERO
            and all(type(value) is int for value in findings.values()))


def read_subject():
    manifest, manifest_sha = read_json(DIRECTORY / SUBJECT_FILE)
    exact(manifest, {"schema_version", "files"}, "manifest sorgente")
    require(manifest["schema_version"] == "staff-land-r2-root-source-subject/1", "Versione manifest non valida.")
    exact(manifest["files"], SUBJECT_FILES, "file revisionati")
    for name, expected in manifest["files"].items():
        require(sha256((DIRECTORY / name).read_bytes()) == expected, f"Drift nel sorgente {name}.")
    contract, _ = read_json(DIRECTORY / CONTRACT_FILE)
    return contract, manifest_sha


def exact_asset_values(observed, expected):
    return all(observed[key] == expected[key] for key in ("sha256", "git_blob", "bytes", "build"))


def validate_asset(contract, mode, asset_path, git_path, domain_path, review_path):
    expected = contract["assets"][mode]
    asset = asset_path.read_bytes()
    git, git_sha = read_json(git_path)
    domain, domain_sha = read_json(domain_path)
    asset_review, review_sha = read_json(review_path)
    exact(git, PUBLICATION_INPUT, "ricevuta Git e Pages")
    exact(domain, DOMAIN_INPUT, "ricevuta del dominio")
    exact(asset_review, {"schema_version", "mode", "asset_sha256", "git_blob", "build",
                         "freeze_sha256", "findings"}, "review asset")
    require(git["schema_version"] == "staff-land-git-pages-observation/1"
            and git["repo"] == contract["repo"] and git["filename"] == contract["filename"]
            and valid_pin(git["git_commit"], 40) and git["git_commit"] != contract["origin_git_commit"]
            and git["git_commit"] == git["pages_commit"] and git["pages_conclusion"] == "success"
            and git["deployment_success"] is True
            and type(git["pages_run_id"]) is int and 0 < git["pages_run_id"] < 10**20
            and type(git["bytes"]) is int
            and exact_asset_values(git, expected),
            "Ricevuta Git/Pages assente, senza successo o non coincidente con l'asset congelato.")
    require(domain["schema_version"] == "staff-land-domain-observation/1"
            and domain["url"] == contract["domain_url"]
            and domain["commit"] == git["git_commit"] and domain["build"] == git["build"]
            and domain["marker"] == expected["marker"] and domain["pages_run_id"] == git["pages_run_id"]
            and domain["observed_after_pages"] is True,
            "Il marcatore osservato sul dominio non è legato al commit pubblicato da Pages.")
    exact_body = (domain["method"] == "response_body_sha256" and domain["body_verified"] is True
                  and domain["status"] == 200 and type(domain["status"]) is int and type(domain["bytes"]) is int
                  and (domain["sha256"], domain["bytes"]) == (git["sha256"], git["bytes"]))
    build_binding = (domain["method"] == "git_blob_pages_commit_domain_build" and domain["body_verified"] is False
                     and domain["sha256"] is None and domain["bytes"] is None and domain["status"] in (200, None))
    require(exact_body or build_binding, "Il metodo dichiarato per verificare il dominio non è attestato.")
    marker = f'<meta name="{expected["marker"]}" content="{git["build"]}" />'.encode("ascii")
    blob = hashlib.sha1(f"blob {len(asset)}\0".encode("ascii") + asset).hexdigest()
    require(sha256(asset) == git["sha256"] and len(asset) == git["bytes"]
            and blob == git["git_blob"] and asset.count(marker) == 1,
            "I byte verificati differiscono dal blob pubblicato o dal freeze.")
    require(asset_review["schema_version"] == "staff-land-asset-review/1"
            and asset_review["mode"] == mode and asset_review["asset_sha256"] == expected["sha256"]
            and asset_review["git_blob"] == expected["git_blob"] and asset_review["build"] == expected["build"]
            and asset_review["freeze_sha256"] == contract["r2_freeze_sha256"]
            and valid_findings(asset_review["findings"]),
            "Manca una review 0/0/0 dell'asset del percorso richiesto.")
    return {
        **git,
        "schema_version": "staff-land-published-evidence/1",
        "domain_url": domain["url"], "domain_status": domain["status"], "domain_sha256": domain["sha256"],
        "domain_bytes": domain["bytes"], "domain_build": domain["build"],
        "domain_method": domain["method"], "domain_marker": domain["marker"],
        "domain_body_verified": domain["body_verified"], "domain_after_pages": domain["observed_after_pages"],
        "domain_pages_run_id": domain["pages_run_id"],
        "client_review_sha256": review_sha, "publication_receipt_sha256": git_sha,
        "domain_evidence_sha256": domain_sha,
    }


def validate_apply_receipt(receipt, contract, subject):
    exact(receipt, APPLY_RECEIPT, "ricevuta di apply")
    exact(receipt["parent"], contract["origin"], "tuple genitore nella ricevuta")
    exact(receipt["active"], contract["origin"], "tuple successore nella ricevuta")
    require(receipt["schema_version"] == "staff-land-r2-root-apply-receipt/2"
            and receipt["mode"] in contract["assets"] and receipt["source_subject_sha256"] == subject
            and valid_pin(receipt["git_commit"], 40) and valid_pin(receipt["previous_git_commit"], 40)
            and receipt["git_commit"] != receipt["previous_git_commit"]
            and receipt["previous_root_sha256"] == receipt["parent"]["root_sha256"]
            and receipt["previous_row_sha256"] == receipt["parent"]["row_sha256"]
            and receipt["active"]["root_sha256"] != receipt["parent"]["root_sha256"]
            and receipt["root_bytes"] == contract["assets"][receipt["mode"]]["root_bytes"]
            and receipt["two_mission_admissions"] is True and receipt["party_flags_preserved"] is True
            and receipt["e52_common_verme"] is True and receipt["runtime_staff"] == "NOT_RUN"
            and type(receipt["provider_calls"]) is int and receipt["provider_calls"] == 0
            and re.fullmatch(r"[A-Za-z0-9_.#-]{1,40}", receipt["review_ref"]) is not None
            and all(valid_pin(pin) for pin in (
                receipt["binding_sha256"], receipt["projection_sha256"], receipt["client_sha256"],
                receipt["publication_receipt_sha256"], receipt["protected_state_sha256"],
                *receipt["active"].values(), *receipt["parent"].values())),
            "La ricevuta non conferma l'apply atteso con Missioni, Party e sigilli.")
    abortion_refs = (receipt["aborted_release_sha256"], receipt["abort_evidence_sha256"])
    require(all(valid_pin(pin) for pin in abortion_refs) if receipt["mode"] == "publication_abort"
            else abortion_refs == (None, None), "La ricevuta mescola recovery e publication abort.")


def read_abort_evidence(args, contract, publication):
    previous_files = (args.aborted_asset, args.aborted_git_pages_receipt,
                      args.aborted_domain_evidence, args.aborted_asset_review, args.abort_git_compare)
    if args.mode != "publication_abort":
        require(all(path is None for path in previous_files), "L'attestazione abort è ammessa solo in publication_abort.")
        return None

    require(all(path is not None for path in previous_files), "Publication abort richiede le ricevute della R2 già servita.")
    prior = validate_asset(contract, "install", *previous_files[:4])
    comparison, comparison_sha = read_json(args.abort_git_compare)
    require(isinstance(comparison, dict) and isinstance(comparison.get("merge_base_commit"), dict)
            and comparison.get("repository_full_name") == contract["repo"]
            and comparison.get("base") == prior["git_commit"] and comparison.get("head") == publication["git_commit"]
            and comparison["merge_base_commit"].get("sha") == prior["git_commit"]
            and comparison.get("status") == "ahead"
            and type(comparison.get("ahead_by")) is int and comparison["ahead_by"] > 0
            and type(comparison.get("behind_by")) is int and comparison["behind_by"] == 0
            and prior["git_commit"] != publication["git_commit"] and prior["pages_run_id"] != publication["pages_run_id"],
            "Il commit di ripiego deve avanzare il commit R2 con una seconda pubblicazione Pages.")
    return {
        "published_r2": prior,
        "git_advance": {
            "base": comparison["base"], "head": comparison["head"], "status": comparison["status"],
            "ahead_by": comparison["ahead_by"], "behind_by": comparison["behind_by"],
            "merge_base_commit": comparison["merge_base_commit"]["sha"], "evidence_sha256": comparison_sha,
        },
    }


def parent_for_mode(args, contract, subject, publication):
    if args.mode != "recovery_forward":
        require(args.install_receipt is None, "La ricevuta di apply è ammessa solo nella recovery forward.")
        return contract["origin"], None, contract["origin_git_commit"]
    require(args.install_receipt is not None, "Recovery forward senza ricevuta di installazione confermata.")
    installed, receipt_sha = read_json(args.install_receipt)
    validate_apply_receipt(installed, contract, subject)
    require(installed["mode"] == "install" and installed["parent"] == contract["origin"]
            and installed["previous_git_commit"] == contract["origin_git_commit"]
            and installed["git_commit"] != publication["git_commit"],
            "La recovery richiede identità installata R2 e un nuovo commit pubblicato.")
    return installed["active"], receipt_sha, installed["git_commit"]


def check_source_review(path, subject):
    review, review_sha = read_json(path)
    exact(review, {"schema_version", "subject_sha256", "ref", "modes", "findings"}, "review sorgente aggregata")
    require(review["schema_version"] == "staff-land-r2-root-source-review/2"
            and review["subject_sha256"] == subject and review["modes"] == list(MODES)
            and isinstance(review["ref"], str) and re.fullmatch(r"[A-Za-z0-9_.#-]{1,40}", review["ref"]) is not None
            and valid_findings(review["findings"]),
            "Review sorgente pertinenza/B non confermata 0/0/0.")
    return {"ref": review["ref"], "sha256": review_sha, **ZERO}


def json_text(value):
    return json.dumps(value, ensure_ascii=True, sort_keys=True, separators=(",", ":"))


def as_sql_text(raw):
    delimiter = "$land_r2_bind$"
    require(delimiter not in raw and "$land_r2_root$" not in raw, "Delimitatore non valido nel bind.")
    return delimiter + raw + delimiter


def substitute_once(text, old, new):
    require(text.count(old) == 1, "Il punto di bind sorgente è cambiato.")
    return text.replace(old, new, 1)


def read_projection(args, contract, subject, publication, parent, before_commit, abort_evidence):
    projection, projection_sha = read_json(args.projection)
    exact(projection, {"schema_version", "mode", "subject_sha256", "publication", "parent", "target",
                       "observed_parent_git_head", "parent_client_sha256", "quiescence", "mission_admissions",
                       "party", "seals", "projection_pass", "publication_abort_evidence", "aborted_release_sha256"},
          "proiezione live")
    target = projection["target"]
    exact(target, {"root_sha256", "client_sha256", "root_bytes"}, "identità candidata")
    require(projection["schema_version"] == "staff-land-r2-root-preflight/2"
            and projection["mode"] == args.mode and projection["subject_sha256"] == subject
            and projection["publication"] == publication and projection["parent"] == parent
            and projection["publication_abort_evidence"] == abort_evidence
            and projection["observed_parent_git_head"] == before_commit and projection["projection_pass"] is True
            and valid_pin(projection["parent_client_sha256"]) and valid_pin(target["root_sha256"])
            and valid_pin(target["client_sha256"]) and target["root_sha256"] not in
                (parent["root_sha256"], contract["origin"]["root_sha256"])
            and target["client_sha256"] != projection["parent_client_sha256"]
            and target["root_bytes"] == contract["assets"][args.mode]["root_bytes"],
            "La proiezione live non conferma la pubblicazione e il genitore richiesti.")
    aborted_root = projection["aborted_release_sha256"]
    require(valid_pin(aborted_root) and aborted_root not in (target["root_sha256"], parent["root_sha256"])
            if args.mode == "publication_abort" else aborted_root is None,
            "La proiezione non isola l'identità della R2 annullata.")
    return target, projection_sha, aborted_root


def bind_entry(binding):
    text = (DIRECTORY / SOURCE_FILE).read_text()
    raw = json_text(binding)
    digest = sha256(raw.encode("ascii"))
    bound = substitute_once(text, "bound_text constant text := NULL;", f"bound_text constant text := {as_sql_text(raw)};")
    bound = substitute_once(bound, "bound_sha constant text := NULL;", f"bound_sha constant text := '{digest}';")
    restored = substitute_once(bound, f"bound_text constant text := {as_sql_text(raw)};", "bound_text constant text := NULL;")
    restored = substitute_once(restored, f"bound_sha constant text := '{digest}';", "bound_sha constant text := NULL;")
    require(restored == text, "Le sostituzioni non sono invertibili byte per byte.")
    return bound, digest


def read_args():
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="action", required=True)
    for name in ("projection", "entry"):
        command = subparsers.add_parser(name)
        command.add_argument("--mode", choices=MODES, required=True)
        command.add_argument("--git-pages-receipt", type=Path, required=True)
        command.add_argument("--domain-evidence", type=Path, required=True)
        command.add_argument("--asset", type=Path, required=True, help="Byte verificati del blob Git pubblicato o della risposta integrale del dominio.")
        command.add_argument("--asset-review", type=Path, required=True)
        command.add_argument("--install-receipt", type=Path)
        command.add_argument("--aborted-asset", type=Path)
        command.add_argument("--aborted-git-pages-receipt", type=Path)
        command.add_argument("--aborted-domain-evidence", type=Path)
        command.add_argument("--aborted-asset-review", type=Path)
        command.add_argument("--abort-git-compare", type=Path)
        if name == "entry":
            command.add_argument("--source-review", type=Path, required=True)
            command.add_argument("--projection", type=Path, required=True)
            command.add_argument("--receipt-out", type=Path, required=True)
    postflight = subparsers.add_parser("postflight")
    postflight.add_argument("--apply-receipt", type=Path, required=True)
    return parser.parse_args()


def main():
    args = read_args()
    contract, subject = read_subject()
    if args.action == "postflight":
        receipt, _ = read_json(args.apply_receipt)
        validate_apply_receipt(receipt, contract, subject)
        template = (DIRECTORY / POSTFLIGHT_FILE).read_text()
        query = substitute_once(template, "NULL::jsonb AS evidence", f"{as_sql_text(json_text(receipt))}::jsonb AS evidence")
        print(query, end="")
        return

    publication = validate_asset(contract, args.mode, args.asset, args.git_pages_receipt, args.domain_evidence, args.asset_review)
    abort_evidence = read_abort_evidence(args, contract, publication)
    parent, install_receipt_sha, before_commit = parent_for_mode(args, contract, subject, publication)
    if args.action == "projection":
        params = {"mode": args.mode, "subject_sha256": subject, "publication": publication,
                  "publication_abort_evidence": abort_evidence, "expected_parent": parent}
        template = (DIRECTORY / PREFLIGHT_FILE).read_text()
        query = substitute_once(template, "NULL::jsonb AS binding", f"{as_sql_text(json_text(params))}::jsonb AS binding")
        print(query, end="")
        return

    review = check_source_review(args.source_review, subject)
    target, projection_sha, aborted_root = read_projection(args, contract, subject, publication, parent, before_commit, abort_evidence)
    binding = {
        "schema_version": "staff-land-r2-root-entry/2", "mode": args.mode,
        "r2_freeze_sha256": contract["r2_freeze_sha256"], "source_subject_sha256": subject,
        "independent_review": review, "publication": publication,
        "parent": parent, "target": target, "projection_sha256": projection_sha,
        "install_receipt_sha256": install_receipt_sha,
        "publication_abort_evidence": abort_evidence, "aborted_release_sha256": aborted_root,
    }
    sql, bind_sha = bind_entry(binding)
    receipt = {
        "schema_version": "staff-land-r2-root-materialized-entry/2",
        "state": "ENTRY_NEEDS_INDEPENDENT_REVIEW_BEFORE_APPLY",
        "source_sha256": sha256((DIRECTORY / SOURCE_FILE).read_bytes()),
        "entry_sha256": sha256(sql.encode("utf-8")),
        "entry_bytes": len(sql.encode("utf-8")),
        "binding_sha256": bind_sha, "binding": binding,
        "inverse_exact": True, "apply": "NOT_RUN", "runtime": "NOT_RUN", "provider_calls": 0,
    }
    with args.receipt_out.open("x") as out:
        json.dump(receipt, out, ensure_ascii=True, indent=2)
        out.write("\n")
    print(sql, end="")


if __name__ == "__main__":
    try:
        main()
    except (KeyError, OSError, TypeError, ValueError) as error:
        raise SystemExit(f"Bind rifiutato: {error}") from None
