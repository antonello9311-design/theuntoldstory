import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const contract = JSON.parse(readFileSync(new URL("./CONTRACT.json", import.meta.url), "utf8"));
const matrix = JSON.parse(readFileSync(new URL("./BANK_MATRIX.json", import.meta.url), "utf8"));
const source = readFileSync(new URL("./adapter.mjs", import.meta.url), "utf8");
const doc = readFileSync(new URL("./CONTRATTO.md", import.meta.url), "utf8");

assert.equal(contract.profile_id, "combat_exam_exchange_adapter_v1");
assert.equal(contract.identity_profile_id, "combat_exam_exchange_identity_v1");
assert.equal(contract.spatial_receipt_profile_id, "combat_exam_narrative_spatial_receipt_v1");
assert.deepEqual(contract.identity_fields_in_order, [
  "exchange_id", "exchange_version", "root_application_id", "attack_application_id",
  "defense_application_id", "substitution_event_id", "resolution_revision",
]);
assert.equal(matrix.count, 33);
assert.deepEqual(matrix.banks.map((bank) => bank.id), Array.from({ length: 33 }, (_, index) => index + 1));
assert.equal(new Set(matrix.banks.map((bank) => bank.id)).size, 33);
for (const required of [
  "png_attacca", "pending_unresolved", "narrative_published", "exchange_request_key_conflict",
  "combat_exam_narrative_spatial_receipt_v1", "server_snapshot",
]) {
  assert.ok(source.includes(required), `source missing ${required}`);
  assert.ok(doc.includes(required), `doc missing ${required}`);
}
for (const forbidden of ["model_decides", "client_coordinates", "auto_best", "auto_switch"]) {
  assert.ok(!source.includes(forbidden), `forbidden source marker ${forbidden}`);
}
console.log("STATIC=GREEN profiles=1 banks=33 identity_fields=7 open_product=0");
