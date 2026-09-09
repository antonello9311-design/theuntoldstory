#!/usr/bin/env python3
"""Pianificatore locale in sola lettura: proposte, mai prenotazioni o avvii.

Python 3.9+, libreria standard. --root canonica e --plan JSON assoluto.
Il piano conserva i lavori futuri; --spec emette solo un incarico pronto
da registrare dopo una nuova verifica tramite task_guard.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import sqlite3
import sys
from datetime import datetime, timezone

sys.dont_write_bytecode = True


def load_guard(raw):
    root = Path(raw)
    if not root.is_absolute() or ".." in root.parts or not root.is_dir():
        raise ValueError("--root deve essere assoluta, canonica ed esistente")
    module_path = root / "management/tooling/task_guard.py"
    if any(path.is_symlink() for path in [module_path] + list(module_path.parents)):
        raise ValueError("Symlink non ammessi nella root o nello strumento")
    if str(root.resolve()) != str(root) or not module_path.is_file():
        raise ValueError("Root non canonica o task_guard.py non disponibile")
    spec = importlib.util.spec_from_file_location("_task_plan_guard", str(module_path))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return root, module


def conflict(left, right):
    writes = {name.casefold() for name in left["files"]}
    reads = {name.casefold() for name in left["inputs"]}
    other_writes = {name.casefold() for name in right["files"]}
    other_reads = {name.casefold() for name in right["inputs"]}
    paths = writes & (other_writes | other_reads) | reads & other_writes
    resources = {name.casefold() for name in left["resources"]} & {name.casefold() for name in right["resources"]}
    return {"files_or_inputs": sorted(paths), "resources": sorted(resources)} if paths or resources else None


class Plan:
    def __init__(self, root, data, guard_module):
        self.root, self.data, self.g = root, data, guard_module
        self.guard = self.g.Guard(root)
        self.runtime_error = None
        self.registry = {}
        self.snapshot_at = datetime.now(timezone.utc).isoformat()
        try:
            with self.guard.connection() as connection:
                if connection is None:
                    self.runtime_error = "Registro assente: stato delle prenotazioni non confermato"
                else:
                    self.registry = {task["id"]: task for task in self.guard.tasks(connection)}
        except (self.g.GuardError, OSError, sqlite3.Error, ValueError, KeyError, TypeError):
            self.runtime_error = "Registro non verificabile: riconciliazione PM prima dell'avvio"
        self.validate()

    def validate(self):
        g, data = self.g, self.data
        if not isinstance(data, dict) or set(data) != {"id", "title", "max_parallel", "tasks"}:
            raise g.GuardError("Piano: chiavi richieste id, title, max_parallel, tasks")
        g.identifier(data["id"])
        g.text_value(data["title"], "title")
        g.integer(data["max_parallel"], "max_parallel", 3)
        if data["max_parallel"] < 1 or not isinstance(data["tasks"], list) or not data["tasks"]:
            raise g.GuardError("Piano vuoto o max_parallel non compreso fra 1 e 3")
        self.tasks = {}
        for task in data["tasks"]:
            if not isinstance(task, dict) or set(task) != g.SPEC_KEYS:
                raise g.GuardError("Ogni task deve avere esattamente lo schema di task_guard")
            g.identifier(task["id"])
            g.identifier(task["cantiere"], "cantiere")
            if task["id"].casefold() in {key.casefold() for key in self.tasks}:
                raise g.GuardError("ID duplicato nel piano")
            for key in ("title", "owner", "authorization"):
                g.text_value(task[key], key)
            g.integer(task["priority"], "priority", 3)
            for key in ("depends_on", "files", "resources", "inputs", "acceptance"):
                g.clean_list(task[key], key)
            if not task["acceptance"] or not (task["files"] or task["inputs"] or task["resources"]):
                raise g.GuardError("Task priva di scope o criteri")
            for dep in task["depends_on"]:
                g.identifier(dep)
            if not isinstance(task["budget"], dict) or set(task["budget"]) != {"minutes", "cases", "provider_calls"}:
                raise g.GuardError("Budget non conforme a task_guard")
            for key, value in task["budget"].items():
                g.integer(value, "budget." + key)
            for raw in task["files"] + task["inputs"]:
                g.regular_file(g.relative_path(self.root, raw))
            self.tasks[task["id"]] = task
        self.ancestors, self.order = {}, []

        def visit(task_id, visiting):
            if task_id in visiting:
                raise g.GuardError("Ciclo di dipendenze nel piano: " + task_id)
            if task_id in self.ancestors:
                return self.ancestors[task_id]
            ancestors = set()
            for dependency in self.tasks[task_id]["depends_on"]:
                if dependency not in self.tasks and dependency not in self.registry:
                    raise g.GuardError("Dipendenza ignota: " + dependency)
                ancestors.add(dependency)
                if dependency in self.tasks:
                    ancestors.update(visit(dependency, visiting | {task_id}))
            self.ancestors[task_id] = ancestors
            self.order.append(task_id)
            return ancestors

        for task_id in self.tasks:
            visit(task_id, set())
        for task_id, task in self.tasks.items():
            upstream = [self.tasks.get(dep, self.registry.get(dep, {}).get("spec")) for dep in self.ancestors[task_id]]
            outputs = {raw for item in upstream if item for raw in item["files"]}
            for raw in task["inputs"]:
                if not g.relative_path(self.root, raw).exists() and raw not in outputs:
                    raise g.GuardError("Input assente senza produttore fra i prerequisiti: " + raw)

    def blockers(self, task):
        reasons = []
        if self.runtime_error:
            reasons.append(self.runtime_error)
        existing = self.registry.get(task["id"])
        if existing:
            reasons.append("ID già registrato: " + existing["state"] + "; non registrarlo nuovamente")
            if existing["spec"] != task:
                reasons.append("Specifica diversa dal registro: riconciliazione PM")
        elif task["id"].casefold() in {key.casefold() for key in self.registry}:
            reasons.append("ID già registrato con diversa grafia")
        for dependency in task["depends_on"]:
            stored = self.registry.get(dependency)
            if stored is None or stored["state"] != "consegnato":
                reasons.append("Prerequisito non consegnato: " + dependency)
            elif dependency in self.tasks and stored["spec"] != self.tasks[dependency]:
                reasons.append("Prerequisito diverso dal piano: " + dependency)
        try:
            self.g.validate_spec(self.root, task)
        except (self.g.GuardError, OSError) as error:
            reasons.append("File/input non pronti: " + (str(error) if isinstance(error, self.g.GuardError) else "errore di lettura"))
        active = [item for item in self.registry.values() if item["state"] == "active"]
        if len(active) >= self.data["max_parallel"]:
            reasons.append("Slot simultanei dichiarati già occupati")
        cantieri = {item["spec"]["cantiere"] for item in active if item["spec"]["cantiere"] != "PM-COORDINAMENTO"}
        if task["cantiere"] != "PM-COORDINAMENTO" and task["cantiere"] not in cantieri and len(cantieri) >= 3:
            reasons.append("Tre cantieri già acquisiti")
        for item in active:
            collision = conflict(task, item["spec"])
            if (collision or item["id"] in self.ancestors[task["id"]]) and self.guard.drift(item):
                reasons.append("Drift in una prenotazione pertinente: " + item["id"] + "; riconciliazione PM")
            if collision:
                reasons.append("Conflitto con " + item["id"] + ": " + ", ".join(collision["files_or_inputs"] + collision["resources"]))
        return reasons

    def runtime_warnings(self):
        return ["Drift nella prenotazione " + item["id"] + ": avviso al PM; scope e slot restano occupati, i rami indipendenti possono proseguire"
                for item in self.registry.values() if item["state"] == "active" and self.guard.drift(item)]

    def analyze(self):
        tasks = list(self.tasks.values())
        rows = []
        for task in tasks:
            reasons = self.blockers(task)
            unlocks = sum(task["id"] in other["depends_on"] for other in tasks)
            rows.append({"id": task["id"], "owner_proposto": task["owner"], "priority": task["priority"],
                         "depends_on": task["depends_on"], "ready_to_register": not reasons,
                         "blockers": reasons, "unlocks": unlocks})
        rows.sort(key=lambda row: (row["priority"], -row["unlocks"], row["id"]))
        ready = [row["id"] for row in rows if row["ready_to_register"]]
        collisions = []
        for index, left in enumerate(tasks):
            for right in tasks[index + 1:]:
                detail = conflict(left, right)
                if detail:
                    collisions.append(dict(detail, tasks=[left["id"], right["id"]]))
        active = [item for item in self.registry.values() if item["state"] == "active"]
        slots = max(0, self.data["max_parallel"] - len(active))
        groups = []
        for task_id in ready:
            task = self.tasks[task_id]
            placed = False
            for group in groups:
                cantieri = {item["spec"]["cantiere"] for item in active}
                cantieri.update(self.tasks[item]["cantiere"] for item in group + [task_id])
                cantieri.discard("PM-COORDINAMENTO")
                if len(group) < slots and len(cantieri) <= 3 and all(not conflict(task, self.tasks[item]) for item in group):
                    group.append(task_id)
                    placed = True
                    break
            if not placed and slots:
                groups.append([task_id])
        external = sorted({dep for task in tasks for dep in task["depends_on"] if dep not in self.tasks})
        return {"id": self.data["id"], "title": self.data["title"], "snapshot_at": self.snapshot_at,
                "proposal_only": True, "registry_verified": self.runtime_error is None,
                "topological_order": self.order, "tasks": rows, "conflicts": collisions,
                "external_prerequisites": [{"id": dep, "state": self.registry[dep]["state"]} for dep in external],
                "next_ready": ready, "parallel_groups": groups, "available_slots": slots,
                "warnings": self.runtime_warnings(),
                "limits": "Gruppi alternativi dei lavori pronti ora, non calendario né prenotazione. Ricontrollare register/claim; il PM verifica anche i cantieri documentali, autorizzazioni e gate."}

    def emit_spec(self, task_id):
        if task_id not in self.tasks:
            raise self.g.GuardError("Task assente dal piano")
        reasons = self.blockers(self.tasks[task_id])
        if reasons:
            raise self.g.GuardError("Specifica bloccata: " + "; ".join(reasons))
        return self.tasks[task_id]

    def brief(self, task_id):
        if task_id not in self.tasks:
            raise self.g.GuardError("Task assente dal piano")
        task = self.tasks[task_id]
        reasons = self.blockers(task)
        lines = ["# Briefing proposto · " + task_id, "", "**Proposta da assegnare dal PM, nessuna prenotazione acquisita.**",
                 "", "Stato: " + ("BLOCCATO" if reasons else "pronto per verifica e registrazione"),
                 "", "Risultato: " + task["title"], "Owner proposto: " + task["owner"],
                 "Cantiere: " + task["cantiere"], "Mandato dichiarato, non verificato dallo strumento: " + task["authorization"]]
        for title, items in (("Prerequisiti", task["depends_on"]), ("File da acquisire", task["files"]),
                             ("Contratti da leggere", task["inputs"]), ("Risorse condivise", task["resources"]),
                             ("Criteri di accettazione", task["acceptance"]), ("Blocchi attuali", reasons),
                             ("Avvisi al PM", self.runtime_warnings())):
            lines += ["", "## " + title, ""] + (["- " + item for item in items] if items else ["Nessuno dichiarato."])
        budget = task["budget"]
        lines += ["", "Budget dichiarato: {minutes} minuti, {cases} casi, {provider_calls} chiamate provider.".format(**budget),
                  "", "## Avvio, verifica e consegna", "",
                  "1. Leggere AGENTS.md, management/coordination/AVVIO_LAVORO.md, dossier di ingresso e area; verificare SCHEDA/HANDOFF e mandato con il PM.",
                  "2. Solo dopo la consegna dei prerequisiti, rigenerare --spec e usare register → claim → check nella stessa root canonica. La proposta non sostituisce questi controlli.",
                  "3. Preparare copie isolate e integrare con apply; al drift fermare le scritture e riconciliare. Nessun avvio automatico di agenti o task archiviate.",
                  "4. Verificare la stessa candidata nei criteri e budget; rispettare la review e i gate di AGENTS. Un esito rosso torna al PM.",
                  "5. Consegnare HANDOFF con scope, contratti, decisioni, prove, rischi e prossimo passaggio; aggiornare SCHEDA/STORICO e area tramite owner/integratore.",
                  "6. Release consegnato solo dopo verifica; sospeso conserva il motivo e non sblocca dipendenze. Apply/deploy/enable/apertura utenti mantengono autorizzazioni distinte.",
                  "", "Questa proposta non certifica autorizzazione, test, rilascio, costo o prodotto in uso."]
        return "\n".join(lines) + "\n"


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True, help="root condivisa assoluta e canonica")
    parser.add_argument("--plan", required=True, help="piano JSON assoluto; non viene modificato")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--spec", metavar="TASK-ID", help="emette solo la specifica registrabile ora; altrimenti errore")
    mode.add_argument("--brief", metavar="TASK-ID", help="briefing Markdown proposto, anche se bloccato")
    args = parser.parse_args(argv)
    guard_module = None
    try:
        root, guard_module = load_guard(args.root)
        with guard_module.source_path(args.plan).open(encoding="utf-8") as handle:
            data = json.load(handle, object_pairs_hook=guard_module.json_without_duplicates)
        plan = Plan(root, data, guard_module)
        if args.brief:
            print(plan.brief(args.brief), end="")
        else:
            print(json.dumps(plan.emit_spec(args.spec) if args.spec else plan.analyze(), ensure_ascii=False, indent=2))
        return 0
    except Exception as error:
        expected = isinstance(error, ValueError) or guard_module is not None and isinstance(error, guard_module.GuardError)
        message = str(error) if expected else "Piano o registro non verificabile: " + type(error).__name__
        print(json.dumps({"ok": False, "error": message}, ensure_ascii=False), file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
