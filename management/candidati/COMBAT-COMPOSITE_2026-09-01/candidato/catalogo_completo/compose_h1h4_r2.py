"""Compose H1/H4 TEMP from the frozen components. This script has no DB access."""
from pathlib import Path
import hashlib
import json
import shutil

root = Path(__file__).resolve().parent
meta = json.loads((root / "H1H4_R2_INPUTS.json").read_bytes())
derived = json.loads((root / "H1H4_R2_PROJECTION.json").read_bytes())
h4root = Path(meta["h4_component_dir"])
h1root = Path(meta["h1_component_dir"])
h4 = json.loads((h4root / "NARA_H4_R2_IDENTITY.json").read_bytes())
h1 = json.loads((h1root / "H1_NB_ROSTER_COMMIT_PINS.json").read_bytes())
e52 = meta["e52"]

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def read(path, expected=None):
    raw = path.read_bytes()
    if expected is not None:
        assert digest(raw) == expected, path
    return raw.decode()

def one(s, old, new):
    assert s.count(old) == 1, old[:180]
    return s.replace(old, new, 1)

def jsonb(value, dollar="h14"):
    return "$" + dollar + "$" + json.dumps(value, ensure_ascii=False, separators=(",", ":")) + "$" + dollar + "$::jsonb"

def function_check(signature, oid, volatility, source_hash, ddl_hash, reason):
    return f""" IF NOT EXISTS (
  SELECT 1 FROM pg_proc p WHERE p.oid='{signature}'::regprocedure
   AND p.oid::text='{oid}' AND pg_get_userbyid(p.proowner)='postgres'
   AND p.proacl::text='{{postgres=X/postgres}}' AND p.proconfig=ARRAY['search_path=""']
   AND p.prosecdef AND p.provolatile='{volatility}' AND md5(p.prosrc)='{source_hash}'
   AND encode(extensions.digest(pg_get_functiondef(p.oid),'sha256'),'hex')='{ddl_hash}'
 ) THEN RAISE EXCEPTION '{reason}'; END IF;\n"""

projection = derived["root"]
descriptor = derived["descriptor"]
assert projection["compat_baseline_matches"] and projection["compat_after_matches"]
assert projection["stable_root_matches"] and projection["projected_bytes"] == 523748
assert descriptor["peer6_changes"] == [
    "clan_innata_private.catalogo_eligibility_release_v1()",
    "combat_panel_private.publish_master_declaration(uuid,text)",
]
assert descriptor["compat2_changes"] == ["clan_innata_private.catalogo_eligibility_release_v1()"]

e52_sig = "clan_innata_private.catalogo_eligibility_release_v1()"
e52_before = read(root / "H1H4_E52_BEFORE.ddl.sql", e52["before"]["ddl_sha"])
e52_after = read(root / "H1H4_E52_AFTER.ddl.sql", e52["after"]["target_ddl_sha"])
literal = ('"signature":"' + h1["signature"] + '","source_md5":"' + h1["body_before_md5"]
           + '","security_definer":true')
assert one(e52_before, literal, literal.replace(h1["body_before_md5"], h1["body_after_md5"])) == e52_after

h1_before = read(h1root / "H1_NB_ROSTER_COMMIT_LIVE.ddl.sql", h1["ddl_before_sha256"])
h1_after = read(h1root / "H1_NB_ROSTER_COMMIT_FIXED.ddl.sql", h1["ddl_after_sha256"])
assert one(h1_before, h1["exact_sql_delta"], "") == h1_after

h4_paths = {
    "{db_core,cure_command_amendment,functions_manifest_sha256}", "{config,cure_command_amendment,functions_manifest_sha256}",
    "{db_core,catalogo_families,2}", "{config,catalogo_families}",
    "{db_core,sha256}", "{config,sha256}", "{contract,code_identity_sha256}", "{recovery,semantic_identity_sha256}",
    "{db_core,all_function_headers,235,source_md5}", "{db_core,all_function_headers,235,ddl_md5}",
}
new_paths = [path for path in derived["paths"] if path not in h4_paths]
assert len(new_paths) == 10

for mode in ("SOURCE", "RECOVERY"):
    recovery = mode == "RECOVERY"
    h4_filename = "NARA_H4_R2_" + mode + ".sql"
    original = read(h4root / h4_filename, h4["sql_files"][h4_filename]["sha256"])
    prefix, publisher, suffix = original.split("$h4_publisher_ddl$")
    shell = prefix + "$merged_batch$" + suffix
    shell = shell.replace("nara-h4-release-parameters/1", "h1h4-release-parameters/1")
    shell = shell.replace("nara-h4-publisher-identity/1", "h1h4-aggregate-identity/1")
    shell = shell.replace("nara_h4_release_", "h1h4_release_").replace("NARA_H4_", "H1H4_")
    shell = one(shell, "__H1H4_PARAMETERS_SHA256__", "__H1H4_PARAMETERS_SHA256__")
    shell = one(shell, "-- Nara H4, revisione del publisher nel duello Staff.",
                "-- H1/H4, roster NinjaBook e publisher Nara nel duello Staff.")
    shell = one(shell, "peer_metadata jsonb;", "peer_metadata jsonb; compat_metadata jsonb;")
    shell = shell.replace(meta["h4_projection"]["stable_root_sha"], projection["stable_root_sha"])
    for key in ("new_db", "new_cfg"):
        assert shell.count(meta["h4_projection"][key]) in (1, 2)
        shell = shell.replace(meta["h4_projection"][key], projection[key])
    shell = shell.replace("32617ddcea37c760c225b9046912de432d66a9eafb6ff9a1606572995bee1a49",
                          descriptor["peer6_after"])
    old_projected = h4["descriptor"]["projected_descriptor"]
    assert shell.count(jsonb(old_projected, "h4_before") if recovery else jsonb(old_projected, "h4_after")) == 1
    shell = shell.replace(jsonb(old_projected, "h4_before") if recovery else jsonb(old_projected, "h4_after"),
                          jsonb(descriptor["descriptor_after"], "h4_before" if recovery else "h4_after"))
    alias_anchor = " #- '{db_core,all_function_headers,235,ddl_md5}'"
    assert shell.count(alias_anchor) == 4
    shell = shell.replace(alias_anchor, alias_anchor + "".join(" #- '" + path + "'" for path in new_paths))

    in_suffix, out_suffix = ("after", "before") if recovery else ("before", "after")
    compat_in = descriptor["compat2_array_" + in_suffix]
    compat_out = descriptor["compat2_array_" + out_suffix]
    e52_src_in = e52["after"]["target_body_md5"] if recovery else e52["before"]["source_md5"]
    e52_src_out = e52["before"]["source_md5"] if recovery else e52["after"]["target_body_md5"]
    e52_sha_in = e52["after"]["target_ddl_sha"] if recovery else e52["before"]["ddl_sha"]
    e52_sha_out = e52["before"]["ddl_sha"] if recovery else e52["after"]["target_ddl_sha"]
    check_before = function_check(h1["signature"], h1["oid"], h1["volatility"],
        h1["body_" + in_suffix + "_md5"], h1["ddl_" + in_suffix + "_sha256"], "H1H4_ROSTER_BEFORE_DRIFT")
    check_before += function_check(e52_sig, e52["before"]["oid"], "s", e52_src_in, e52_sha_in, "H1H4_E52_BEFORE_DRIFT")
    check_before += f""" IF (SELECT md5(prosrc) FROM pg_proc WHERE oid='combat_panel_private.validate_command(jsonb)'::regprocedure)
          IS DISTINCT FROM '{h1["validator_md5"]}'
    OR (SELECT md5(prosrc) FROM pg_proc WHERE oid='public.combat_panel_commit_v1(jsonb)'::regprocedure)
          IS DISTINCT FROM '{h1["wrapper_md5"]}'
    OR before_root#>'{{db_core,catalogo_eligibility_compat,functions}}' IS DISTINCT FROM {jsonb(compat_in, "compat_before")}
    OR before_root#>'{{config,catalogo_eligibility_compat,functions}}' IS DISTINCT FROM {jsonb(compat_in, "compat_before")}
    OR before_root#>>'{{db_core,catalogo_eligibility_compat,functions_manifest_sha256}}'
          IS DISTINCT FROM '{descriptor["compat2_" + in_suffix]}' THEN
   RAISE EXCEPTION 'H1H4_WIRE_OR_COMPAT_BEFORE_DRIFT';
 END IF;
"""
    check_after = function_check(h1["signature"], h1["oid"], h1["volatility"],
        h1["body_" + out_suffix + "_md5"], h1["ddl_" + out_suffix + "_sha256"], "H1H4_ROSTER_AFTER_DRIFT")
    check_after += function_check(e52_sig, e52["before"]["oid"], "s",
        e52_src_out, e52_sha_out, "H1H4_E52_AFTER_DRIFT")
    batch = (" EXECUTE $h1_roster_ddl$" + (h1_before if recovery else h1_after) + "$h1_roster_ddl$;\n"
             + " EXECUTE $h1_e52_ddl$" + (e52_before if recovery else e52_after) + "$h1_e52_ddl$;\n"
             + " EXECUTE $h4_publisher_ddl$" + publisher + "$h4_publisher_ddl$;\n")
    shell = one(shell, " EXECUTE $merged_batch$;\n", check_before + batch + check_after)

    compat = f""" SELECT q.metadata INTO STRICT compat_metadata FROM (
{meta["descriptor_compat_sql"]}
 ) q;
 IF jsonb_array_length(compat_metadata) IS DISTINCT FROM 2
    OR compat_metadata IS DISTINCT FROM {jsonb(compat_out, "compat_after")}
    OR public.combat_v2_sha256(compat_metadata) IS DISTINCT FROM '{descriptor["compat2_" + out_suffix]}' THEN
  RAISE EXCEPTION 'H1H4_COMPAT2_DRIFT';
 END IF;
"""
    shell = one(shell, " IF jsonb_array_length(peer_metadata) IS DISTINCT FROM 6\n",
                compat + " IF jsonb_array_length(peer_metadata) IS DISTINCT FROM 6\n")
    mutations = ""
    for k in ("db_core", "config"):
        mutations += f""" root:=jsonb_set(root,'{{{k},catalogo_eligibility_compat,functions}}',compat_metadata,false);
 root:=jsonb_set(root,'{{{k},catalogo_eligibility_compat,functions_manifest_sha256}}',
  to_jsonb(public.combat_v2_sha256(compat_metadata)),false);
 root:=jsonb_set(root,'{{{k},catalogo_eligibility_compat,helper_source_md5}}',compat_metadata#>'{{0,source_md5}}',false);
 root:=jsonb_set(root,'{{{k},cure_command_amendment,helper_source_md5}}',compat_metadata#>'{{0,source_md5}}',false);
"""
    shell = one(shell, " db_sha:=public.combat_v2_sha256((root->'db_core')-'sha256');\n",
                mutations + " db_sha:=public.combat_v2_sha256((root->'db_core')-'sha256');\n")
    identity_anchor = "  'publisher_ddl_sha256',"
    shell = one(shell, identity_anchor,
                f"  'e52_ddl_sha256','{e52_sha_out}','roster_ddl_sha256','{h1['ddl_' + out_suffix + '_sha256']}',\n" + identity_anchor)
    receipt_anchor = "  'mode',expected_mode,'parent_root_sha256',old_root_sha,"
    shell = one(shell, receipt_anchor,
                (f"  'e52_ddl_sha256','{e52_sha_out}','roster_ddl_sha256',"
                 f"'{h1['ddl_' + out_suffix + '_sha256']}',\n") + receipt_anchor)
    (root / ("H1H4_R2_" + mode + ".sql")).write_text(shell)

baseline = json.loads((h4root / "NARA_H4_R2_BASELINE.json").read_bytes())
baseline["roster_ddl_sha256"] = h1["ddl_before_sha256"]
baseline["e52_ddl_sha256"] = e52["before"]["ddl_sha"]
(root / "H1H4_R2_BASELINE.json").write_text(json.dumps(baseline, indent=2) + "\n")
preflight = read(h4root / "NARA_H4_R2_PREFLIGHT_READONLY.sql")
preflight_anchor = " 'publisher_ddl_sha256',"
preflight = one(preflight, preflight_anchor, f""" 'roster_ddl_sha256',encode(extensions.digest(pg_get_functiondef('{h1["signature"]}'::regprocedure),'sha256'),'hex'),
 'e52_ddl_sha256',encode(extensions.digest(pg_get_functiondef('{e52_sig}'::regprocedure),'sha256'),'hex'),
""" + preflight_anchor)
(root / "H1H4_R2_PREFLIGHT_READONLY.sql").write_text(preflight)
finalizer = read(h4root / "finalize_h4_r2.py")
finalizer = finalizer.replace("NARA_H4_R2_", "H1H4_R2_").replace("nara_h4_release_", "h1h4_release_")
finalizer = finalizer.replace("NARA_H4_PARAMETERS_SHA256", "H1H4_PARAMETERS_SHA256")
finalizer = finalizer.replace("nara-h4-release-parameters/1", "h1h4-release-parameters/1")
finalizer = one(finalizer, '            and observed["publisher_ddl_sha256"] == identity["publisher_ddl_after"]',
                '''            and observed["publisher_ddl_sha256"] == identity["publisher_ddl_after"]
            and observed["roster_ddl_sha256"] == forward["roster_ddl_sha256"] == identity["roster_ddl_after"]
            and observed["e52_ddl_sha256"] == forward["e52_ddl_sha256"] == identity["e52_ddl_after"]''')
finalizer = one(finalizer, '            and observed["publisher_ddl_sha256"] == identity["publisher_ddl_before"],',
                '''            and observed["publisher_ddl_sha256"] == identity["publisher_ddl_before"]
            and observed["roster_ddl_sha256"] == identity["roster_ddl_before"]
            and observed["e52_ddl_sha256"] == identity["e52_ddl_before"],''')
(root / "finalize_h1h4_r2.py").write_text(finalizer)
