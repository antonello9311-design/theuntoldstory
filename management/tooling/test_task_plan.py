#!/usr/bin/env python3
"""12 casi integrati, solo TemporaryDirectory, zero provider o registro reale."""
import contextlib
import hashlib
import io
import json
from pathlib import Path
import shutil
import sqlite3
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
import task_plan as planner


# Dopo integrazione usa il guard accanto al banco; il fallback serve soltanto
# a questa candidata temporanea, prima del deposito nel progetto.
GUARD_SOURCE = Path(__file__).with_name("task_guard.py")
if not GUARD_SOURCE.is_file():
    GUARD_SOURCE = Path("/Users/antonello/Desktop/theuntoldstory/management/tooling/task_guard.py")


class PlannerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="tus-planner-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        (self.root / "management/tooling").mkdir(parents=True)
        shutil.copyfile(str(GUARD_SOURCE), str(self.root / "management/tooling/task_guard.py"))
        (self.root / "work").mkdir()
        for name in ("a.md", "b.md", "contract.md", "handoff.md"):
            (self.root / "work" / name).write_text("Fixture " + name, encoding="utf-8")
        _, self.g = planner.load_guard(str(self.root))
        self.guard = self.g.Guard(self.root)
        self.seed = self.task("SEED", files=[], resources=["fixture:seed"], cantiere="PM-COORDINAMENTO")
        self.guard.register(self.seed)
        self.guard.claim("SEED", "owner-SEED")
        self.guard.release("SEED", "owner-SEED", "consegnato", "work/handoff.md", "Fixture conclusa")

    def task(self, task_id, **changes):
        value = {"id": task_id, "title": "Risultato " + task_id, "owner": "owner-" + task_id,
                 "cantiere": "CANTIERE-A", "priority": 1, "depends_on": [],
                 "files": ["work/" + task_id.lower() + ".md"], "resources": [], "inputs": [],
                 "acceptance": ["Risultato verificabile"], "authorization": "Mandato sintetico del banco",
                 "budget": {"minutes": 5, "cases": 1, "provider_calls": 0}}
        value.update(changes)
        return value

    def data(self, *tasks, **changes):
        value = {"id": "PLAN-TEST", "title": "Proposta isolata", "max_parallel": 3, "tasks": list(tasks)}
        value.update(changes)
        return value

    def plan(self, *tasks, **changes):
        return planner.Plan(self.root, self.data(*tasks, **changes), self.g)

    def activate(self, task):
        self.guard.register(task)
        self.guard.claim(task["id"], task["owner"])

    def test_01_dag_future_contract_and_brief(self):
        a = self.task("A", files=["work/future.md"])
        b = self.task("B", inputs=["work/future.md"], depends_on=["A"])
        c = self.task("C")
        plan = self.plan(a, b, c)
        result = plan.analyze()
        self.assertEqual(result["topological_order"], ["A", "B", "C"])
        self.assertEqual(result["next_ready"], ["A", "C"])
        self.assertEqual(result["parallel_groups"], [["A", "C"]])
        with self.assertRaises(self.g.GuardError):
            plan.emit_spec("B")
        brief = plan.brief("B")
        for term in ("BLOCCATO", "Owner proposto", "AGENTS.md", "HANDOFF", "nessuna prenotazione", "apply/deploy/enable"):
            self.assertIn(term.casefold(), brief.casefold())

    def test_02_consumer_spec_only_after_actual_producer_delivery(self):
        a = self.task("A", files=["work/future.md"])
        b = self.task("B", depends_on=["A"], inputs=["work/future.md"])
        self.activate(a)
        incoming = self.root / "incoming.md"
        incoming.write_text("Contratto consegnato", encoding="utf-8")
        self.guard.apply("A", "owner-A", "work/future.md", str(incoming))
        self.guard.release("A", "owner-A", "consegnato", "work/handoff.md", "Consegna")
        before = self.guard.dbpath.read_bytes()
        emitted = self.plan(a, b).emit_spec("B")
        self.assertEqual(emitted, b)
        self.assertEqual(before, self.guard.dbpath.read_bytes())
        with self.guard.connection() as db:
            self.assertNotIn("B", [item["id"] for item in self.guard.tasks(db)])
        self.guard.register(emitted)
        self.guard.claim("B", "owner-B")

    def test_03_file_resource_and_input_conflicts_limit_groups(self):
        a = self.task("A", files=["work/a.md"], resources=["browser:chrome"])
        b = self.task("B", files=["work/a.md"])
        c = self.task("C", inputs=["work/a.md"])
        d = self.task("D", resources=["BROWSER:CHROME"])
        result = self.plan(a, b, c, d).analyze()
        self.assertEqual(len(result["conflicts"]), 4)
        for group in result["parallel_groups"]:
            for index, left in enumerate(group):
                for right in group[index + 1:]:
                    self.assertIsNone(planner.conflict({t["id"]: t for t in (a, b, c, d)}[left], {t["id"]: t for t in (a, b, c, d)}[right]))

    def test_04_cycles_duplicates_unknown_dependencies_empty_and_shape(self):
        invalid = [self.data(), self.data(self.task("A"), self.task("a")),
                   self.data(self.task("A", depends_on=["B"]), self.task("B", depends_on=["A"])),
                   self.data(self.task("A", depends_on=["UNKNOWN"])),
                   self.data(self.task("A"), max_parallel=0), self.data(self.task("A"), max_parallel=True),
                   self.data(dict(self.task("A"), extra="invalid"))]
        for value in invalid:
            with self.subTest(value=value), self.assertRaises(self.g.GuardError):
                planner.Plan(self.root, value, self.g)

    def test_05_runtime_unknown_remains_blocked_and_readonly(self):
        with tempfile.TemporaryDirectory(prefix="tus-planner-empty-") as directory:
            root = Path(directory).resolve()
            (root / "work").mkdir()
            plan = planner.Plan(root, self.data(self.task("A")), self.g)
            self.assertFalse(plan.analyze()["registry_verified"])
            with self.assertRaises(self.g.GuardError):
                plan.emit_spec("A")
            self.assertFalse((root / "management").exists())
        with self.guard.connection(write=True) as db:
            db.execute("UPDATE metadata SET version=999")
        plan = self.plan(self.task("A"))
        self.assertFalse(plan.analyze()["registry_verified"])
        with self.assertRaises(self.g.GuardError):
            plan.emit_spec("A")

    def test_06_external_prerequisite_delivered_or_suspended(self):
        result = self.plan(self.task("A", depends_on=["SEED"])).analyze()
        self.assertEqual(result["external_prerequisites"], [{"id": "SEED", "state": "consegnato"}])
        self.assertEqual(result["next_ready"], ["A"])
        external = self.task("EXTERNAL")
        self.activate(external)
        self.guard.release("EXTERNAL", "owner-EXTERNAL", "sospeso", "work/handoff.md", "Blocco")
        plan = self.plan(self.task("A", depends_on=["EXTERNAL"]))
        with self.assertRaisesRegex(self.g.GuardError, "Prerequisito non consegnato"):
            plan.emit_spec("A")

    def test_07_relevant_drift_blocks_but_independent_task_gets_warning(self):
        active = self.task("ACTIVE", files=["work/a.md"])
        self.activate(active)
        plan = self.plan(self.task("A", files=["work/a.md"]))
        with self.assertRaisesRegex(self.g.GuardError, "Conflitto"):
            plan.emit_spec("A")
        (self.root / "work/a.md").write_text("External modification", encoding="utf-8")
        independent = self.plan(self.task("B"))
        self.assertEqual(independent.emit_spec("B"), self.task("B"))
        result = independent.analyze()
        self.assertEqual(result["next_ready"], ["B"])
        self.assertEqual(result["available_slots"], 2)
        self.assertTrue(any("ACTIVE" in warning and "PM" in warning for warning in result["warnings"]))
        self.assertIn("Drift nella prenotazione ACTIVE", independent.brief("B"))
        with self.assertRaisesRegex(self.g.GuardError, "Drift"):
            self.plan(self.task("A", files=["work/a.md"])).emit_spec("A")
        with self.assertRaisesRegex(self.g.GuardError, "Drift"):
            self.plan(self.task("B", depends_on=["ACTIVE"])).emit_spec("B")

    def test_08_parallel_slots_cantieri_and_pm_exception(self):
        self.activate(self.task("ACTIVE", cantiere="CANTIERE-A"))
        tasks = [self.task("B", cantiere="CANTIERE-B"), self.task("C", cantiere="CANTIERE-C"),
                 self.task("D", cantiere="CANTIERE-D"), self.task("PM", cantiere="PM-COORDINAMENTO")]
        result = self.plan(*tasks).analyze()
        self.assertEqual(result["available_slots"], 2)
        self.assertTrue(all(len(group) <= 2 for group in result["parallel_groups"]))
        for group in result["parallel_groups"]:
            cantieri = {"CANTIERE-A"} | {t["cantiere"] for t in tasks if t["id"] in group}
            cantieri.discard("PM-COORDINAMENTO")
            self.assertLessEqual(len(cantieri), 3)
        with self.assertRaisesRegex(self.g.GuardError, "Slot"):
            self.plan(self.task("B"), max_parallel=1).emit_spec("B")

    def test_09_future_input_only_from_transitive_upstream(self):
        a = self.task("A", files=["work/future.md"])
        b = self.task("B", depends_on=["A"])
        c = self.task("C", depends_on=["B"], inputs=["work/future.md"])
        self.assertEqual(self.plan(a, b, c).order, ["A", "B", "C"])
        with self.assertRaisesRegex(self.g.GuardError, "senza produttore"):
            self.plan(a, self.task("C", inputs=["work/future.md"]))

    def test_10_sensitive_paths_traversal_and_symlinks_rejected(self):
        (self.root / "work/link.md").symlink_to(self.root / "work/a.md")
        for raw in ("../out.md", "work/.env", "work/dump.sql", "work/link.md", "work/../a.md", self.g.DATABASE):
            with self.subTest(raw=raw), self.assertRaises(self.g.GuardError):
                self.plan(self.task("A", files=[raw]))
        with self.assertRaises(ValueError):
            planner.load_guard(".")

    def test_11_registered_id_blocked_but_delivered_input_can_evolve(self):
        a = self.task("A", files=["work/a.md"])
        self.activate(a)
        self.guard.release("A", "owner-A", "consegnato", "work/handoff.md", "Consegna")
        with self.assertRaisesRegex(self.g.GuardError, "già registrato"):
            self.plan(a).emit_spec("A")
        (self.root / "work/a.md").write_text("External", encoding="utf-8")
        consumer = self.task("B", depends_on=["A"], inputs=["work/a.md"])
        self.assertEqual(self.plan(a, consumer).emit_spec("B"), consumer)
        self.guard.register(consumer)
        self.guard.claim("B", "owner-B")
        self.assertTrue(self.guard.check("B", "owner-B")["clean"])

    def test_12_cli_json_and_brief_do_not_mutate_registry(self):
        path = self.root / "plan.json"
        path.write_text(json.dumps(self.data(self.task("A"))), encoding="utf-8")
        before = hashlib.sha256(self.guard.dbpath.read_bytes()).hexdigest()
        for options in ([], ["--spec", "A"], ["--brief", "A"]):
            stdout = io.StringIO()
            with contextlib.redirect_stdout(stdout):
                self.assertEqual(planner.main(["--root", str(self.root), "--plan", str(path)] + options), 0)
            self.assertTrue(stdout.getvalue())
            if not options or options[0] != "--brief":
                json.loads(stdout.getvalue())
        self.assertEqual(before, hashlib.sha256(self.guard.dbpath.read_bytes()).hexdigest())
        self.assertFalse((self.root / "management/tooling/__pycache__").exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
