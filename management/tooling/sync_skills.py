#!/usr/bin/env python3
"""Confronta o allinea le otto skill del metodo GDR a una cache esplicita.

Nessuna scoperta di credenziali o modifica delle impostazioni delle app.
--apply richiede un piano prodotto da --plan e rifiuta il drift.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import sys

NAMES = ("gdr-rotta", "gdr-contesto", "gdr-chiusura", "antigravity-protocol",
         "gdr-verifica", "gdr-sql", "gdr-pagine", "gdr-regole-sync")


def digest(data):
    return hashlib.sha256(data).hexdigest()


def regular(path):
    if any(p.is_symlink() for p in (path, *path.parents)):
        raise ValueError("Percorso simbolico non ammesso: " + str(path))
    if not path.is_file():
        raise ValueError("File mancante: " + str(path))
    return path.read_bytes()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", required=True, type=Path)
    p.add_argument("--installed", required=True, type=Path,
                   help="Cartella skills della cache effettivamente installata")
    mode = p.add_mutually_exclusive_group()
    mode.add_argument("--plan", type=Path, help="Salva baseline delle sole otto skill")
    mode.add_argument("--apply", type=Path, help="Applica solo se il piano è ancora esatto")
    a = p.parse_args()
    root, installed = a.root.absolute(), a.installed.absolute()
    if not (root / "AGENTS.md").is_file():
        raise ValueError("Root del progetto non riconosciuta")
    entries = []
    for name in NAMES:
        src = root / "management/coordination/skills" / (name + ".md")
        dst = installed / name / "SKILL.md"
        desired, current = regular(src), regular(dst)
        header_text = desired.decode("utf-8").replace("\r\n", "\n")
        if not header_text.startswith("---\n") or ("name: " + name + "\n") not in header_text:
            raise ValueError("Nome/frontmatter non valido: " + name)
        entries.append({"name": name, "source_sha256": digest(desired),
                        "installed_sha256": digest(current)})
    plan = {"root": str(root), "installed": str(installed), "entries": entries}
    if a.plan:
        # Un piano nuovo non sostituisce silenziosamente la baseline precedente.
        with a.plan.open("x", encoding="utf-8") as f:
            json.dump(plan, f, indent=2)
    if a.apply:
        saved = json.loads(regular(a.apply))
        if saved != plan:
            raise ValueError("Drift rispetto al piano: nessuna skill applicata")
        backup = root / "management/coordination/runtime/skills-precedenti"
        if any(p.is_symlink() for p in (backup, *backup.parents)):
            raise ValueError("Backup simbolico non ammesso")
        backup.mkdir(parents=True, exist_ok=True)
        for e in entries:
            name = e["name"]
            src = root / "management/coordination/skills" / (name + ".md")
            dst = installed / name / "SKILL.md"
            desired, current = regular(src), regular(dst)
            if digest(desired) != e["source_sha256"] or digest(current) != e["installed_sha256"]:
                raise ValueError("Drift durante applicazione su " + name + "; precedenti conservati")
            if desired == current:
                continue
            old = backup / (name + "-" + digest(current) + ".md")
            if old.exists():
                if regular(old) != current:
                    raise ValueError("Backup non coincidente: " + name)
            else:
                with old.open("xb") as f:
                    f.write(current)
            # La cache non è un registro di lock: verifica immediata, sostituzione
            # singola; un writer esterno concorrente resta un limite dichiarato.
            tmp = dst.with_name(".SKILL.gdr-sync-" + str(os.getpid()))
            with tmp.open("xb") as f:
                f.write(desired)
                f.flush()
                os.fsync(f.fileno())
            os.chmod(tmp, dst.stat().st_mode & 0o777)
            if regular(dst) != current:
                raise ValueError("Drift prima della sostituzione: " + name)
            os.replace(tmp, dst)
            if regular(dst) != desired:
                raise ValueError("Verifica fallita dopo scrittura: " + name)
            print(json.dumps({"skill": name, "stato": "allineata"}, ensure_ascii=False))
    mismatch = []
    for e in entries:
        name = e["name"]
        match = digest(regular(installed / name / "SKILL.md")) == e["source_sha256"]
        if not match:
            mismatch.append(name)
    print(json.dumps({"controllate": len(entries), "da_allineare": mismatch,
                      "impostazioni_app_esterne": "non verificate"}, ensure_ascii=False))
    return 0 if not mismatch or a.plan else 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError) as exc:
        print(json.dumps({"errore": str(exc)}, ensure_ascii=False), file=sys.stderr)
        sys.exit(2)
