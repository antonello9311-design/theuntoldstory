#!/usr/bin/env python3
"""Prenotazioni cooperative locali, senza scadenza o autorità di rilascio.

Python 3.9+, sola libreria standard. Ogni comando richiede --root assoluta
e canonica. Nessun servizio, provider o task dell'app viene avviato.
Il registro serializza soltanto gli scrittori che usano questa CLI:
non è una sandbox e non impedisce modifiche esterne fra controllo e scrittura.
"""

import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import sqlite3
import stat
import sys
import time
import uuid


RUNTIME = "management/coordination/runtime"
DATABASE = RUNTIME + "/task_guard.sqlite3"
TOOLS = {"management/tooling/task_guard.py", "management/tooling/test_task_guard.py"}
VERSION = 1
SPEC_KEYS = {"id", "title", "owner", "cantiere", "priority", "depends_on",
             "files", "resources", "inputs", "acceptance", "authorization", "budget"}
IDENTIFIER = re.compile(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,119}\Z")
SENSITIVE = re.compile(
    r"(^|[._-])(env|secret[s]?|credential[s]?|credenziali|password[s]?|"
    r"token[s]?|dump[s]?|chiav[ei]|private[-_]?key|api[-_]?key)([._-]|$)", re.I)


class GuardError(Exception):
    pass


def text_value(value, name):
    if not isinstance(value, str) or not value.strip() or value != value.strip():
        raise GuardError(name + ": stringa non vuota, senza spazi ai margini")
    if len(value) > 4000 or any(ord(char) < 32 for char in value):
        raise GuardError(name + ": testo non valido")
    return value


def identifier(value, name="id"):
    if not isinstance(value, str) or not IDENTIFIER.fullmatch(value):
        raise GuardError(name + ": usare 1–120 lettere, numeri, punti, trattini o underscore")
    return value


def integer(value, name, maximum=None):
    if type(value) is not int or value < 0 or (maximum is not None and value > maximum):
        raise GuardError(name + ": intero fuori intervallo")
    return value


def clean_list(value, name):
    if not isinstance(value, list):
        raise GuardError(name + ": serve una lista")
    result = [text_value(item, name) for item in value]
    if len(set(item.casefold() for item in result)) != len(result):
        raise GuardError(name + ": duplicati non ammessi")
    return result


def no_symlinks(path):
    """Controlla anche gli antenati. Non fornisce isolamento da processi esterni."""
    for item in [path] + list(path.parents):
        if item.is_symlink():
            raise GuardError("Symlink non ammesso nel percorso")


def canonical_root(raw):
    root = Path(raw)
    if not root.is_absolute() or ".." in root.parts:
        raise GuardError("--root deve essere assoluta e canonica")
    no_symlinks(root)
    if not root.is_dir() or str(root.resolve()) != str(root):
        raise GuardError("--root deve essere una cartella esistente, assoluta e canonica")
    return root


def safe_names(parts):
    for part in parts:
        lower = part.casefold()
        if (SENSITIVE.search(lower) or lower in {".ssh", ".aws", ".gnupg", "id_rsa", "id_ed25519"}
                or lower.endswith((".pem", ".key", ".p12", ".pfx", ".kdbx"))
                or lower.startswith("backup_db")):
            raise GuardError("Percorso riservato: segreti, credenziali o dump non ammessi")


def relative_path(root, raw, internal=False):
    text_value(raw, "percorso")
    parts = raw.split("/")
    if (PurePosixPath(raw).is_absolute() or "\\" in raw
            or any(part in {"", ".", ".."} for part in parts)):
        raise GuardError("Serve un percorso relativo esatto, senza traversal o alias")
    if not internal:
        safe_names(parts)
        lower = raw.casefold()
        if (lower == RUNTIME or lower.startswith(RUNTIME + "/") or lower in TOOLS):
            raise GuardError("Registro, backup e strumenti di guardia non sono target ammessi")
    path = root.joinpath(*parts)
    no_symlinks(path)
    if root not in path.parents:
        raise GuardError("Percorso esterno alla root")
    return path


def source_path(raw):
    path = Path(raw)
    if not path.is_absolute() or ".." in path.parts or "\\" in raw:
        raise GuardError("--source/--spec richiede un file assoluto esplicito")
    safe_names(path.parts)
    no_symlinks(path)
    lowered = "/".join(path.parts).casefold()
    if "/" + RUNTIME + "/" in lowered or any(lowered.endswith("/" + name) for name in TOOLS):
        raise GuardError("Registro e strumenti non sono sorgenti ammesse")
    regular_file(path, required=True)
    return path


def regular_file(path, required=False):
    no_symlinks(path)
    try:
        info = path.stat()
    except FileNotFoundError:
        if required:
            raise GuardError("File richiesto assente")
        return None
    if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1:
        raise GuardError("Serve un file regolare senza hard link")
    return info


def fingerprint(path):
    if regular_file(path) is None:
        return None  # Sentinella esplicita per un nuovo file.
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def json_without_duplicates(pairs):
    value = {}
    for key, item in pairs:
        if key in value:
            raise GuardError("Chiave JSON duplicata: " + key)
        value[key] = item
    return value


def validate_spec(root, spec):
    if not isinstance(spec, dict) or set(spec) != SPEC_KEYS:
        raise GuardError("La specifica deve contenere esattamente: " + ", ".join(sorted(SPEC_KEYS)))
    identifier(spec["id"])
    identifier(spec["cantiere"], "cantiere")
    for name in ("title", "owner", "authorization"):
        text_value(spec[name], name)
    integer(spec["priority"], "priority", 3)
    for name in ("depends_on", "files", "resources", "inputs", "acceptance"):
        clean_list(spec[name], name)
    for dependency in spec["depends_on"]:
        identifier(dependency, "depends_on")
    if not spec["acceptance"]:
        raise GuardError("acceptance deve contenere almeno un criterio")
    if not spec["files"] and not spec["resources"] and not spec["inputs"]:
        raise GuardError("Dichiarare almeno un file, input o risorsa")
    for name in ("files", "inputs"):
        for raw in spec[name]:
            path = relative_path(root, raw)
            if not path.parent.is_dir():
                raise GuardError("La cartella dei file dichiarati deve già esistere")
            regular_file(path, required=(name == "inputs"))
    budget = spec["budget"]
    if not isinstance(budget, dict) or set(budget) != {"minutes", "cases", "provider_calls"}:
        raise GuardError("budget richiede esattamente minutes, cases, provider_calls")
    for name, value in budget.items():
        integer(value, "budget." + name)
    return spec


def encode(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True)


class Guard:
    def __init__(self, root):
        self.root = canonical_root(str(root))
        self.dbpath = relative_path(self.root, DATABASE, internal=True)

    @contextmanager
    def connection(self, write=False, create=False):
        no_symlinks(self.dbpath)
        for suffix in ("-journal", "-wal", "-shm"):
            sidecar = Path(str(self.dbpath) + suffix)
            no_symlinks(sidecar)
            if sidecar.exists():
                regular_file(sidecar, required=True)
        if not self.dbpath.exists() and not create:
            yield None
            return
        if create:
            self.dbpath.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
            no_symlinks(self.dbpath)
        if self.dbpath.exists():
            regular_file(self.dbpath, required=True)
        uri = self.dbpath.as_uri() + ("?mode=rwc" if create else "?mode=rw" if write else "?mode=ro")
        connection = sqlite3.connect(uri, uri=True, timeout=10, isolation_level=None)
        connection.row_factory = sqlite3.Row
        try:
            connection.execute("BEGIN IMMEDIATE" if write else "BEGIN")
            if create:
                connection.execute("CREATE TABLE IF NOT EXISTS metadata (version INTEGER NOT NULL, root TEXT NOT NULL)")
                meta = connection.execute("SELECT * FROM metadata").fetchall()
                if not meta:
                    connection.execute("INSERT INTO metadata VALUES (?, ?)", (VERSION, str(self.root)))
                    connection.execute("CREATE TABLE tasks (id TEXT PRIMARY KEY, spec TEXT NOT NULL, state TEXT NOT NULL, hashes TEXT NOT NULL, registered REAL NOT NULL, claimed REAL, updated REAL NOT NULL)")
                    connection.execute("CREATE TABLE events (seq INTEGER PRIMARY KEY AUTOINCREMENT, task_id TEXT NOT NULL, at REAL NOT NULL, action TEXT NOT NULL, details TEXT NOT NULL)")
            meta = connection.execute("SELECT * FROM metadata").fetchall()
            if len(meta) != 1 or meta[0]["version"] != VERSION or meta[0]["root"] != str(self.root):
                raise GuardError("Registro incompatibile o appartenente a un'altra root: riconciliazione PM")
            yield connection
            connection.commit()
        except BaseException:
            connection.rollback()
            raise
        finally:
            connection.close()

    def tasks(self, connection):
        if connection is None:
            return []
        result = []
        for row in connection.execute("SELECT * FROM tasks ORDER BY id"):
            task = dict(row)
            task["spec"] = json.loads(task["spec"])
            task["hashes"] = json.loads(task["hashes"])
            result.append(task)
        return result

    def task(self, connection, task_id, owner=None, active=False):
        identifier(task_id)
        task = next((item for item in self.tasks(connection) if item["id"] == task_id), None)
        if task is None:
            raise GuardError("Task non registrata")
        if owner is not None and task["spec"]["owner"] != text_value(owner, "owner"):
            raise GuardError("Owner diverso da quello assegnato; nessun trasferimento automatico")
        if active and task["state"] != "active":
            raise GuardError("Task priva di prenotazione attiva")
        return task

    def event(self, connection, task_id, action, details):
        connection.execute("INSERT INTO events (task_id, at, action, details) VALUES (?, ?, ?, ?)",
                           (task_id, time.time(), action, encode(details)))

    def drift(self, task):
        changed = []
        for raw, expected in task["hashes"].items():
            try:
                current = fingerprint(relative_path(self.root, raw))
                if current != expected:
                    changed.append(raw)
            except (GuardError, OSError):
                changed.append(raw)
        return changed

    def assert_clean(self, task):
        changed = self.drift(task)
        if changed:
            raise GuardError("Drift: " + ", ".join(changed) + "; fermarsi e riconciliare con il PM")

    def blockers(self, task, tasks):
        spec = task["spec"]
        reasons = []
        if task["state"] not in {"registered", "sospeso"}:
            reasons.append("stato " + task["state"])
        by_id = {item["id"]: item for item in tasks}
        for dependency in spec["depends_on"]:
            if dependency not in by_id or by_id[dependency]["state"] != "consegnato":
                reasons.append("dipendenza non consegnata: " + dependency)
        writers = {name.casefold() for name in spec["files"]}
        readers = {name.casefold() for name in spec["inputs"]}
        resources = {name.casefold() for name in spec["resources"]}
        active = [item for item in tasks if item["state"] == "active" and item["id"] != task["id"]]
        for other in active:
            other_spec = other["spec"]
            other_writers = {name.casefold() for name in other_spec["files"]}
            other_readers = {name.casefold() for name in other_spec["inputs"]}
            conflict = writers & (other_writers | other_readers) | readers & other_writers
            shared_resources = resources & {name.casefold() for name in other_spec["resources"]}
            if conflict or shared_resources:
                reasons.append("prenotazione " + other["id"] + ": " + ", ".join(sorted(conflict | shared_resources)))
        cantieri = {item["spec"]["cantiere"] for item in active if item["spec"]["cantiere"] != "PM-COORDINAMENTO"}
        if spec["cantiere"] != "PM-COORDINAMENTO" and spec["cantiere"] not in cantieri and len(cantieri) >= 3:
            reasons.append("massimo tre cantieri acquisiti; coordinare con il PM")
        changed = self.drift(task) if task["state"] != "consegnato" else []
        if changed:
            reasons.append("baseline cambiata: " + ", ".join(changed) + "; riconciliazione PM")
        return reasons

    def register(self, spec):
        validate_spec(self.root, spec)
        with self.connection(write=True, create=True) as connection:
            tasks = self.tasks(connection)
            ids = {item["id"].casefold() for item in tasks}
            if spec["id"].casefold() in ids:
                raise GuardError("ID già registrato: non si sovrascrive lo storico")
            # Dipendenze solo preesistenti e ID immutabili: il grafo resta aciclico.
            if any(dep not in {item["id"] for item in tasks} for dep in spec["depends_on"]):
                raise GuardError("Dipendenza inesistente o ciclica; registrare prima gli incarichi a monte")
            hashes = {raw: fingerprint(relative_path(self.root, raw)) for raw in set(spec["files"] + spec["inputs"])}
            now = time.time()
            connection.execute("INSERT INTO tasks VALUES (?, ?, ?, ?, ?, ?, ?)",
                               (spec["id"], encode(spec), "registered", encode(hashes), now, None, now))
            self.event(connection, spec["id"], "register", {"authorization": spec["authorization"], "hashes": hashes})
        return {"id": spec["id"], "state": "registered", "authorization": "dichiarata, non verificata dal registro"}

    def status(self, ready_only=False):
        with self.connection() as connection:
            tasks = self.tasks(connection)
            now = time.time()
            rows = []
            for task in tasks:
                reasons = self.blockers(task, tasks)
                spec = task["spec"]
                unlocks = sum(1 for other in tasks if other["state"] in {"registered", "sospeso"}
                              and task["id"] in other["spec"]["depends_on"]
                              and all(dep == task["id"] or any(candidate["id"] == dep and candidate["state"] == "consegnato" for candidate in tasks)
                                      for dep in other["spec"]["depends_on"]))
                age_minutes = max(0, int((now - task["claimed"]) / 60)) if task["claimed"] else None
                warning = None
                if task["state"] == "active":
                    warning = "Prenotazione senza scadenza: nessun riavvio o furto automatico"
                    if age_minutes is not None and age_minutes >= max(1, spec["budget"]["minutes"]):
                        warning = "Prenotazione oltre il budget dichiarato: riconciliare umanamente; non liberata"
                rows.append({"id": task["id"], "title": spec["title"], "owner": spec["owner"],
                             "cantiere": spec["cantiere"], "state": task["state"], "priority": spec["priority"],
                             "unlocks": unlocks, "ready": not reasons, "blockers": reasons,
                             "files": spec["files"], "inputs": spec["inputs"], "resources": spec["resources"],
                             "claimed_age_minutes": age_minutes, "warning": warning})
            rows.sort(key=lambda item: (item["priority"], -item["unlocks"], item["id"]))
            return {"root": str(self.root), "registry_exists": connection is not None,
                    "tasks": [row for row in rows if row["ready"]] if ready_only else rows,
                    "limits": "Registro cooperativo locale: non certifica autorizzazioni, test o rilascio; non blocca scritture esterne"}

    def claim(self, task_id, owner):
        with self.connection(write=True) as connection:
            task = self.task(connection, task_id, owner)
            reasons = self.blockers(task, self.tasks(connection))
            if reasons:
                raise GuardError("; ".join(reasons))
            now = time.time()
            connection.execute("UPDATE tasks SET state='active', claimed=?, updated=? WHERE id=?", (now, now, task_id))
            self.event(connection, task_id, "claim", {"owner": owner})
        return {"id": task_id, "state": "active", "owner": owner}

    def check(self, task_id, owner):
        with self.connection() as connection:
            task = self.task(connection, task_id, owner, active=True)
            self.assert_clean(task)
        return {"id": task_id, "clean": True, "scope": "file e contratti dichiarati"}

    def apply(self, task_id, owner, raw, source):
        target = relative_path(self.root, raw)
        incoming = source_path(source)
        if target == incoming:
            raise GuardError("La sorgente deve essere distinta dal target")
        with self.connection(write=True) as connection:
            task = self.task(connection, task_id, owner, active=True)
            if raw not in task["spec"]["files"]:
                raise GuardError("File non assegnato alla task")
            self.assert_clean(task)
            payload = incoming.read_bytes()
            previous = target.read_bytes() if regular_file(target) is not None else None
            if (hashlib.sha256(previous).hexdigest() if previous is not None else None) != task["hashes"][raw]:
                raise GuardError("Drift durante la lettura: riconciliazione PM")
            token = uuid.uuid4().hex
            backup_dir = relative_path(self.root, RUNTIME + "/backups/" + task_id, internal=True)
            backup_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
            backup = None
            if previous is not None:
                backup = backup_dir / (token + ".before")
                with backup.open("xb") as handle:
                    handle.write(previous)
                    handle.flush()
                    os.fsync(handle.fileno())
            staging = backup_dir / (token + ".pending")
            with staging.open("xb") as handle:
                handle.write(payload)
                handle.flush()
                os.fsync(handle.fileno())
            mode = stat.S_IMODE(target.stat().st_mode) if previous is not None else 0o644
            staging.chmod(mode)
            # Ultima verifica prima della sostituzione. Processi estranei restano fuori dal protocollo.
            self.assert_clean(task)
            if not target.parent.is_dir():
                raise GuardError("Cartella target non disponibile")
            os.replace(str(staging), str(target))
            new_hash = hashlib.sha256(payload).hexdigest()
            task["hashes"][raw] = new_hash
            # Se il commit fallisce, la vecchia baseline resta: il prossimo check segnala drift.
            connection.execute("UPDATE tasks SET hashes=?, updated=? WHERE id=?", (encode(task["hashes"]), time.time(), task_id))
            self.event(connection, task_id, "apply", {"path": raw, "sha256": new_hash,
                                                     "backup": str(backup.relative_to(self.root)) if backup else None})
        return {"id": task_id, "path": raw, "sha256": new_hash,
                "backup": str(backup.relative_to(self.root)) if backup else None}

    def release(self, task_id, owner, outcome, handoff, note):
        """Sospendere con drift conserva le evidenze senza riscrivere file.

        Usare un handoff già esistente e descrivere il blocco in --note:
        non serve creare o aggiornare l'handoff aggirando apply. Baseline,
        osservazioni e motivo restano nell'evento; solo il PM riconcilia.
        """
        if outcome not in {"consegnato", "sospeso"}:
            raise GuardError("Esito ammesso: consegnato o sospeso")
        text_value(note, "note")
        path = relative_path(self.root, handoff)
        regular_file(path, required=True)
        with self.connection(write=True) as connection:
            task = self.task(connection, task_id, owner, active=True)
            observed = {}
            changed = []
            for raw, expected in task["hashes"].items():
                try:
                    current = fingerprint(relative_path(self.root, raw))
                    observed[raw] = {"state": "absent" if current is None else "file", "sha256": current}
                    if current != expected:
                        changed.append(raw)
                except (GuardError, OSError) as error:
                    # Non seguire symlink o percorsi diventati non sicuri per ottenere un'impronta.
                    observed[raw] = {"state": "unreadable", "error": type(error).__name__}
                    changed.append(raw)
            if outcome == "consegnato" and changed:
                raise GuardError("Drift: " + ", ".join(changed) + "; fermarsi e riconciliare con il PM")
            regular_file(path, required=True)
            self.event(connection, task_id, "release", {"owner": owner, "outcome": outcome,
                                                       "handoff": handoff, "handoff_sha256": fingerprint(path), "note": note,
                                                       "baseline": task["hashes"], "observed": observed,
                                                       "drift": changed, "reconciliation_required": bool(changed)})
            connection.execute("UPDATE tasks SET state=?, updated=? WHERE id=?", (outcome, time.time(), task_id))
        return {"id": task_id, "state": outcome, "drift": changed, "reconciliation_required": bool(changed),
                "meaning": "Esito dell'incarico, non prodotto in uso"}


def parser():
    result = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    result.add_argument("--root", required=True, help="cartella di progetto assoluta, canonica, esistente; mai dedotta dal cwd")
    commands = result.add_subparsers(dest="command", required=True)
    commands.add_parser("status", help="sola lettura: task, blocchi e prenotazioni da riconciliare; non crea il runtime")
    commands.add_parser("ready", help="sola lettura: task acquisibili, priorità 0 prima di 3, poi dipendenti sbloccabili")
    register = commands.add_parser("register", help="registra un incarico e le baseline; attesta l'autorizzazione dichiarata senza verificarla")
    register.add_argument("--spec", required=True, help="file JSON assoluto; chiavi: " + ", ".join(sorted(SPEC_KEYS)))
    for command, help_text in (("claim", "acquisisce atomicamente; nessuna scadenza o presa forzata"),
                               ("check", "verifica owner, prenotazione e baseline di file/contratti"),
                               ("apply", "sostituisce un file assegnato dopo i controlli, conservando il precedente"),
                               ("release", "libera con handoff: consegnato richiede baseline integra; sospeso conserva anche il drift")):
        child = commands.add_parser(command, help=help_text)
        child.add_argument("id", help="ID già registrato")
        child.add_argument("--owner", required=True, help="owner esattamente uguale alla specifica")
        if command == "apply":
            child.add_argument("--path", required=True, help="file relativo esatto assegnato")
            child.add_argument("--source", required=True, help="sorgente regolare assoluta e distinta; niente segreti/symlink")
        elif command == "release":
            child.add_argument("--outcome", required=True, choices=("consegnato", "sospeso"))
            child.add_argument("--handoff", required=True, help="consegna esistente, percorso relativo; con drift usare quella già presente senza riscriverla")
            child.add_argument("--note", required=True, help="risultato o motivo obbligatorio della sospensione; conservato con baseline e impronte osservate")
    return result


def main(argv=None):
    arguments = parser().parse_args(argv)
    try:
        guard = Guard(arguments.root)
        if arguments.command == "register":
            with source_path(arguments.spec).open(encoding="utf-8") as handle:
                spec = json.load(handle, object_pairs_hook=json_without_duplicates)
            result = guard.register(spec)
        elif arguments.command in {"status", "ready"}:
            result = guard.status(ready_only=arguments.command == "ready")
        elif arguments.command == "apply":
            result = guard.apply(arguments.id, arguments.owner, arguments.path, arguments.source)
        elif arguments.command == "release":
            result = guard.release(arguments.id, arguments.owner, arguments.outcome, arguments.handoff, arguments.note)
        else:
            result = getattr(guard, arguments.command)(arguments.id, arguments.owner)
        print(encode({"ok": True, "result": result}))
        return 0
    except (GuardError, OSError, sqlite3.Error, ValueError) as error:
        # I contenuti dei file non vengono mai inclusi nei messaggi d'errore.
        message = str(error) if isinstance(error, GuardError) else "Operazione fallita (" + type(error).__name__ + "); nessun recupero automatico, verificare stato e baseline"
        print(encode({"ok": False, "error": message}), file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
