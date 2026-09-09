#!/usr/bin/env python3
"""Banco isolato del registro; nessun accesso al runtime del progetto.

Eseguire: python3 management/tooling/test_task_guard.py
Budget: 24 casi iniziali + 3 regressioni del finding 1, due processi
concorrenti per caso pertinente, zero provider.
"""

import contextlib
import hashlib
import io
import json
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

import task_guard as tg


class GuardTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="tus-guard-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        (self.root / "work").mkdir()
        (self.root / "work/a.md").write_text("A", encoding="utf-8")
        (self.root / "work/b.md").write_text("B", encoding="utf-8")
        (self.root / "work/contract.md").write_text("contract", encoding="utf-8")
        (self.root / "work/handoff.md").write_text("Consegna verificata", encoding="utf-8")
        self.guard = tg.Guard(self.root)

    def spec(self, task_id="A", **changes):
        result = {"id": task_id, "title": "Prova " + task_id, "owner": "owner-" + task_id,
                  "cantiere": "CANTIERE-A", "priority": 1, "depends_on": [],
                  "files": ["work/a.md"], "resources": [], "inputs": [],
                  "acceptance": ["Caso isolato superato"], "authorization": "Mandato sintetico del banco",
                  "budget": {"minutes": 5, "cases": 1, "provider_calls": 0}}
        result.update(changes)
        return result

    def register(self, task_id="A", **changes):
        return self.guard.register(self.spec(task_id, **changes))

    def claim(self, task_id="A"):
        return self.guard.claim(task_id, "owner-" + task_id)

    def release(self, task_id="A", outcome="consegnato"):
        return self.guard.release(task_id, "owner-" + task_id, outcome, "work/handoff.md", "Caso concluso")

    def rows(self):
        return {row["id"]: row for row in self.guard.status()["tasks"]}

    def concurrent_claims(self, *task_ids):
        # Processi reali indipendenti, rilasciati insieme dopo l'import del modulo.
        code = (
            "import sys,json; sys.path.insert(0,sys.argv[1]); import task_guard as t; "
            "g=t.Guard(sys.argv[2]); print('ready',flush=True); sys.stdin.readline(); "
            "\ntry:\n print(json.dumps(g.claim(sys.argv[3],sys.argv[4])),flush=True)"
            "\nexcept t.GuardError as e:\n print(str(e),flush=True); sys.exit(2)\n"
        )
        processes = [subprocess.Popen([sys.executable, "-B", "-c", code, str(Path(tg.__file__).parent),
                                       str(self.root), task_id, "owner-" + task_id],
                                      stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                      text=True) for task_id in task_ids]
        try:
            for process in processes:
                self.assertEqual(process.stdout.readline().strip(), "ready")
            for process in processes:
                process.stdin.write("go\n")
                process.stdin.flush()
            results = []
            for process in processes:
                stdout, stderr = process.communicate(timeout=15)
                results.append((process.returncode, stdout, stderr))
            return results
        finally:
            for process in processes:
                if process.poll() is None:
                    process.kill()
                    process.communicate()

    def test_01_status_and_ready_do_not_initialize(self):
        self.assertFalse(self.guard.status()["registry_exists"])
        self.assertEqual(self.guard.status(True)["tasks"], [])
        self.assertFalse((self.root / "management").exists())

    def test_02_two_processes_same_file_only_one_claim(self):
        self.register("A")
        self.register("B")
        results = self.concurrent_claims("A", "B")
        self.assertEqual(sorted(item[0] for item in results), [0, 2], results)
        self.assertEqual(sum(row["state"] == "active" for row in self.rows().values()), 1)

    def test_03_two_processes_independent_files_both_claim(self):
        self.register("A")
        self.register("B", files=["work/b.md"])
        results = self.concurrent_claims("A", "B")
        self.assertEqual([item[0] for item in results], [0, 0], results)

    def test_04_dependencies_release_and_history(self):
        self.register("A")
        self.register("B", files=["work/b.md"], depends_on=["A"])
        with self.assertRaisesRegex(tg.GuardError, "dipendenza"):
            self.claim("B")
        self.claim("A")
        self.release("A")
        self.claim("B")
        self.assertEqual(self.rows()["A"]["state"], "consegnato")
        with self.guard.connection() as db:
            actions = [row[0] for row in db.execute("SELECT action FROM events WHERE task_id='A' ORDER BY seq")]
        self.assertEqual(actions, ["register", "claim", "release"])

    def test_05_three_cantieri_cap_and_pm_exception(self):
        for name in ("A", "B", "C", "D"):
            self.register(name, files=[], resources=["resource:" + name], cantiere="CANTIERE-" + name)
        for name in ("A", "B", "C"):
            self.claim(name)
        with self.assertRaisesRegex(tg.GuardError, "tre cantieri"):
            self.claim("D")
        self.register("PM", files=[], resources=["coordination"], cantiere="PM-COORDINAMENTO")
        self.claim("PM")
        self.register("A2", files=[], resources=["other"], cantiere="CANTIERE-A")
        self.claim("A2")
        self.release("C")
        self.claim("D")

    def test_06_input_writer_conflict_both_directions(self):
        self.register("R", files=[], inputs=["work/contract.md"])
        self.register("W", files=["work/contract.md"])
        self.claim("R")
        with self.assertRaisesRegex(tg.GuardError, "prenotazione"):
            self.claim("W")
        self.release("R", "sospeso")
        self.claim("W")
        with self.assertRaisesRegex(tg.GuardError, "prenotazione"):
            self.claim("R")

    def test_07_shared_inputs_allow_parallel_readers(self):
        self.register("A", inputs=["work/contract.md"])
        self.register("B", files=["work/b.md"], inputs=["work/contract.md"])
        self.claim("A")
        self.claim("B")
        self.assertTrue(self.guard.check("A", "owner-A")["clean"])

    def test_08_drift_before_claim_and_after_claim(self):
        self.register("A")
        (self.root / "work/a.md").write_text("External", encoding="utf-8")
        with self.assertRaisesRegex(tg.GuardError, "baseline cambiata"):
            self.claim("A")
        self.register("B", files=["work/b.md"], inputs=["work/contract.md"])
        self.claim("B")
        (self.root / "work/contract.md").write_text("Changed", encoding="utf-8")
        with self.assertRaisesRegex(tg.GuardError, "Drift"):
            self.guard.check("B", "owner-B")
        with self.assertRaisesRegex(tg.GuardError, "Drift"):
            self.release("B")
        self.assertEqual(self.rows()["B"]["state"], "active")

    def test_09_owner_and_inactive_guards(self):
        self.register()
        with self.assertRaisesRegex(tg.GuardError, "Owner diverso"):
            self.guard.claim("A", "someone")
        with self.assertRaisesRegex(tg.GuardError, "priva"):
            self.guard.check("A", "owner-A")
        self.claim()
        for action in (lambda: self.guard.check("A", "someone"),
                       lambda: self.guard.release("A", "someone", "sospeso", "work/handoff.md", "Stop")):
            with self.assertRaisesRegex(tg.GuardError, "Owner diverso"):
                action()

    def test_10_no_expiry_theft(self):
        self.register("A")
        self.register("B")
        self.claim("A")
        with self.guard.connection(write=True) as db:
            db.execute("UPDATE tasks SET claimed=1 WHERE id='A'")
        self.assertIn("non liberata", self.rows()["A"]["warning"])
        with self.assertRaisesRegex(tg.GuardError, "prenotazione"):
            self.claim("B")
        with self.assertRaisesRegex(tg.GuardError, "stato active"):
            self.claim("A")

    def test_11_invalid_relative_and_secret_paths(self):
        for raw in ("../out", "/absolute", "work/../a.md", "work//a.md", "./work/a.md", "work\\a.md",
                    ".env", "work/.env.local", "work/credentials.json", "work/backup_db_ultimo.json",
                    "work/dump.sql", "work/private-key.pem", tg.DATABASE, "management/tooling/task_guard.py"):
            with self.subTest(path=raw), self.assertRaises(tg.GuardError):
                self.register(files=[raw])
        self.assertFalse(self.guard.dbpath.exists())

    def test_12_symlinks_and_hardlinks_rejected(self):
        (self.root / "work/link.md").symlink_to(self.root / "work/a.md")
        (self.root / "alias").symlink_to(self.root / "work", target_is_directory=True)
        import os
        os.link(str(self.root / "work/b.md"), str(self.root / "work/hard.md"))
        for raw in ("work/link.md", "alias/new.md", "work/hard.md"):
            with self.subTest(path=raw), self.assertRaises(tg.GuardError):
                self.register(files=[raw])

    def test_13_new_file_backup_apply_and_release(self):
        self.register(files=["work/a.md", "work/new.md"])
        self.claim()
        source = self.root / "incoming.md"
        source.write_text("Revision", encoding="utf-8")
        result = self.guard.apply("A", "owner-A", "work/a.md", str(source))
        self.assertEqual((self.root / result["backup"]).read_text(), "A")
        created = self.guard.apply("A", "owner-A", "work/new.md", str(source))
        self.assertIsNone(created["backup"])
        self.assertEqual((self.root / "work/new.md").read_text(), "Revision")
        self.assertTrue(self.guard.check("A", "owner-A")["clean"])
        self.release()
        with self.assertRaisesRegex(tg.GuardError, "stato consegnato"):
            self.claim()

    def test_14_apply_rejects_wrong_scope_owner_source_and_drift(self):
        self.register()
        self.claim()
        source = self.root / "incoming.md"
        source.write_text("Revision", encoding="utf-8")
        secret = self.root / ".env"
        secret.write_text("synthetic", encoding="utf-8")
        link = self.root / "incoming-link.md"
        link.symlink_to(source)
        for action in (lambda: self.guard.apply("A", "owner-A", "work/b.md", str(source)),
                       lambda: self.guard.apply("A", "other", "work/a.md", str(source)),
                       lambda: self.guard.apply("A", "owner-A", "work/a.md", str(secret)),
                       lambda: self.guard.apply("A", "owner-A", "work/a.md", str(link)),
                       lambda: self.guard.apply("A", "owner-A", "work/a.md", "relative.md")):
            with self.assertRaises(tg.GuardError):
                action()
        (self.root / "work/a.md").write_text("External", encoding="utf-8")
        with self.assertRaisesRegex(tg.GuardError, "Drift"):
            self.guard.apply("A", "owner-A", "work/a.md", str(source))
        self.assertEqual((self.root / "work/a.md").read_text(), "External")

    def test_15_failed_commit_after_replace_leaves_detectable_drift(self):
        self.register()
        self.claim()
        source = self.root / "incoming.md"
        source.write_text("Revision", encoding="utf-8")
        with mock.patch.object(self.guard, "event", side_effect=sqlite3.OperationalError("synthetic")):
            with self.assertRaises(sqlite3.OperationalError):
                self.guard.apply("A", "owner-A", "work/a.md", str(source))
        self.assertEqual((self.root / "work/a.md").read_text(), "Revision")
        with self.assertRaisesRegex(tg.GuardError, "Drift"):
            self.guard.check("A", "owner-A")
        self.assertEqual(self.rows()["A"]["state"], "active")
        before = list((self.root / tg.RUNTIME / "backups/A").glob("*.before"))
        self.assertEqual(len(before), 1)
        self.assertEqual(before[0].read_text(), "A")

    def test_16_suspend_does_not_unlock_dependency_and_requires_handoff(self):
        self.register("A")
        self.register("B", files=["work/b.md"], depends_on=["A"])
        self.claim("A")
        with self.assertRaisesRegex(tg.GuardError, "assente"):
            self.guard.release("A", "owner-A", "sospeso", "work/missing.md", "Stop")
        self.release("A", "sospeso")
        with self.assertRaisesRegex(tg.GuardError, "dipendenza"):
            self.claim("B")
        self.claim("A")

    def test_17_ready_order_priority_then_unlocks(self):
        self.register("A", files=[] , resources=["a"], priority=1)
        self.register("B", files=[], resources=["b"], priority=1)
        self.register("C", files=[], resources=["c"], priority=0)
        self.register("D", files=[], resources=["d"], depends_on=["B"])
        self.assertEqual([row["id"] for row in self.guard.status(True)["tasks"]], ["C", "B", "A"])
        self.assertEqual(self.rows()["B"]["unlocks"], 1)

    def test_18_duplicate_ids_unknown_dependencies_and_self_cycles(self):
        self.register("A")
        for task in (self.spec("A"), self.spec("a"), self.spec("B", depends_on=["missing"]),
                     self.spec("B", depends_on=["B"])):
            with self.assertRaises(tg.GuardError):
                self.guard.register(task)
        self.assertEqual(list(self.rows()), ["A"])

    def test_19_strict_schema_and_numbers(self):
        invalid = [self.spec(priority=True), self.spec(priority=4), self.spec(acceptance=[]),
                   self.spec(files=["work/a.md", "work/A.md"]), self.spec(owner=" owner-A"),
                   self.spec(depends_on="A"), self.spec(budget={"minutes": -1, "cases": 0, "provider_calls": 0}),
                   self.spec(budget={"minutes": 0, "cases": 0, "provider_calls": False}),
                   dict(self.spec(), surprise=True)]
        for spec in invalid:
            with self.subTest(spec=spec), self.assertRaises(tg.GuardError):
                self.guard.register(spec)
        self.assertFalse(self.guard.dbpath.exists())

    def test_20_explicit_canonical_root_and_runtime_symlink(self):
        with self.assertRaises(tg.GuardError):
            tg.Guard(".")
        with self.assertRaises(tg.GuardError):
            tg.Guard(self.root / "missing")
        with tempfile.TemporaryDirectory(prefix="tus-guard-link-") as other:
            other_root = Path(other).resolve()
            (other_root / "management/coordination").mkdir(parents=True)
            (other_root / tg.RUNTIME).symlink_to(self.root / "work", target_is_directory=True)
            with self.assertRaises(tg.GuardError):
                tg.Guard(other_root)
        self.register()
        for suffix in ("-journal", "-wal", "-shm"):
            Path(str(self.guard.dbpath) + suffix).symlink_to(self.root / "work/a.md")
        with self.assertRaises(tg.GuardError):
            self.guard.status()

    def test_21_resources_and_case_aliases_conflict(self):
        self.register("A", resources=["browser:chrome"])
        self.register("B", files=["work/b.md"], resources=["BROWSER:CHROME"])
        self.claim("A")
        with self.assertRaisesRegex(tg.GuardError, "prenotazione"):
            self.claim("B")
        self.register("C", files=["work/A.md"])
        with self.assertRaisesRegex(tg.GuardError, "prenotazione"):
            self.claim("C")

    def test_22_cli_json_help_and_required_root(self):
        path = self.root / "spec.json"
        path.write_text(json.dumps(self.spec()), encoding="utf-8")
        capture = io.StringIO()
        with contextlib.redirect_stdout(capture):
            self.assertEqual(tg.main(["--root", str(self.root), "register", "--spec", str(path)]), 0)
        self.assertTrue(json.loads(capture.getvalue())["ok"])
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error:
            tg.main(["status"])
        self.assertEqual(error.exception.code, 2)
        with contextlib.redirect_stdout(io.StringIO()), self.assertRaises(SystemExit) as help_exit:
            tg.main(["--help"])
        self.assertEqual(help_exit.exception.code, 0)
        duplicate = self.root / "duplicate.json"
        duplicate.write_text('{"id":"A","id":"B"}', encoding="utf-8")
        with contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(tg.main(["--root", str(self.root), "register", "--spec", str(duplicate)]), 2)

    def test_23_new_file_appeared_externally_blocks_claim(self):
        self.register(files=["work/new.md"])
        (self.root / "work/new.md").write_text("External", encoding="utf-8")
        with self.assertRaisesRegex(tg.GuardError, "baseline cambiata"):
            self.claim()

    def test_24_missing_input_directory_and_foreign_registry(self):
        for changes in ({"inputs": ["work/missing.md"]}, {"files": ["missing/new.md"]}):
            with self.assertRaises(tg.GuardError):
                self.register(**changes)
        self.register()
        with self.guard.connection(write=True) as db:
            db.execute("UPDATE metadata SET root=?", (str(self.root / "foreign"),))
        with self.assertRaisesRegex(tg.GuardError, "altra root"):
            self.guard.status()

    def test_25_drift_suspension_preserves_evidence_and_frees_only_lease(self):
        self.register("A")
        self.register("DEPENDENT", files=["work/b.md"], depends_on=["A"])
        self.claim("A")
        before_handoff = (self.root / "work/handoff.md").read_bytes()
        (self.root / "work/a.md").write_text("External", encoding="utf-8")
        self.register("NEXT")
        with self.assertRaisesRegex(tg.GuardError, "prenotazione"):
            self.claim("NEXT")
        result = self.guard.release("A", "owner-A", "sospeso", "work/handoff.md", "Drift esterno: riconciliazione PM richiesta")
        self.assertTrue(result["reconciliation_required"])
        self.assertEqual(result["drift"], ["work/a.md"])
        self.assertEqual((self.root / "work/a.md").read_text(), "External")
        self.assertEqual((self.root / "work/handoff.md").read_bytes(), before_handoff)
        with self.guard.connection() as db:
            task = self.guard.task(db, "A")
            event = json.loads(db.execute("SELECT details FROM events WHERE task_id='A' AND action='release'").fetchone()[0])
        original_hash = hashlib.sha256(b"A").hexdigest()
        self.assertEqual(task["hashes"]["work/a.md"], original_hash)
        self.assertEqual(event["baseline"]["work/a.md"], original_hash)
        self.assertEqual(event["observed"]["work/a.md"], {"state": "file", "sha256": hashlib.sha256(b"External").hexdigest()})
        self.assertEqual(event["note"], "Drift esterno: riconciliazione PM richiesta")
        self.claim("NEXT")
        with self.assertRaisesRegex(tg.GuardError, "dipendenza"):
            self.claim("DEPENDENT")
        with self.assertRaisesRegex(tg.GuardError, "baseline cambiata"):
            self.claim("A")

    def test_26_contract_drift_suspend_still_requires_owner_handoff_and_reason(self):
        self.register("A", inputs=["work/contract.md"])
        self.claim("A")
        (self.root / "work/contract.md").write_text("Revised", encoding="utf-8")
        for owner, handoff, note in (("other", "work/handoff.md", "Stop"),
                                     ("owner-A", "work/missing.md", "Stop"),
                                     ("owner-A", "work/handoff.md", "")):
            with self.subTest(owner=owner, handoff=handoff, note=note), self.assertRaises(tg.GuardError):
                self.guard.release("A", owner, "sospeso", handoff, note)
            self.assertEqual(self.rows()["A"]["state"], "active")
        with self.assertRaisesRegex(tg.GuardError, "Drift"):
            self.release("A", "consegnato")
        result = self.release("A", "sospeso")
        self.assertEqual(result["drift"], ["work/contract.md"])
        self.assertEqual(self.rows()["A"]["state"], "sospeso")
        with self.assertRaisesRegex(tg.GuardError, "priva"):
            self.release("A", "sospeso")

    def test_27_unsafe_drift_can_suspend_without_following_symlink(self):
        self.register("A")
        self.claim("A")
        original = self.root / "work/a.md"
        original.rename(self.root / "work/old-a.md")
        original.symlink_to(self.root / "work/b.md")
        result = self.release("A", "sospeso")
        self.assertTrue(result["reconciliation_required"])
        self.assertTrue(original.is_symlink())
        self.assertEqual((self.root / "work/b.md").read_text(), "B")
        with self.guard.connection() as db:
            event = json.loads(db.execute("SELECT details FROM events WHERE task_id='A' AND action='release'").fetchone()[0])
        self.assertEqual(event["observed"]["work/a.md"], {"state": "unreadable", "error": "GuardError"})
        self.assertEqual(event["drift"], ["work/a.md"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
