import assert from "node:assert/strict";
import test from "node:test";
import { adaptExchange, AdapterError, makeReplayRecord } from "../adapter.mjs";

const identity = {
  exchange_id: "exchange-alpha",
  exchange_version: 1,
  root_application_id: "root-alpha",
  attack_application_id: "attack-alpha",
  defense_application_id: "defense-alpha",
  substitution_event_id: "substitution-alpha",
  resolution_revision: 1,
};

function fixture(overrides = {}) {
  return {
    authority: "server_snapshot",
    request_key: "request-alpha",
    exchange_identity: identity,
    candidate_action: {
      status: "executed",
      actor_handle: "il candidato",
      target_handle: "lo sfidante",
      label: "pugno diretto",
      gesture: "avanza con la guardia raccolta",
      trajectory: "porta il pugno verso il torace",
      limb: "braccio destro",
      target_zone: "torace",
    },
    png_defense_outcome: {
      status: "resolved",
      actor_handle: "lo sfidante",
      target_handle: "il candidato",
      defense_label: "Tecnica della Sostituzione",
      technique_handle: "sostituzione",
      outcome: "sostituito",
      consequence: "il colpo raggiunge il supporto lasciato al punto d'impatto",
      movements: [{ attore_ref: "actor.opponent", direzione: "cede terreno", ampiezza: "due passi" }],
    },
    spatial_receipt: {
      profile_id: "combat_exam_narrative_spatial_receipt_v1",
      exchange_identity: identity,
      narrator_projection: {
        defender_before: "sulla misura del candidato",
        impact_point: "nel punto lasciato allo scambio",
        anchor: "il ceppo presso il bordo",
        defender_after: "accanto al ceppo",
        distance_band_after: "corta",
        continuity: "scambio, impatto sul supporto e riapparizione",
      },
    },
    counterattack: {
      status: "declared_unresolved",
      application_id: "counter-alpha",
      intent_id: "counter-intent-alpha",
      actor_handle: "lo sfidante",
      target_handle: "il candidato",
      label: "calcio circolare",
      genre: "attacco",
      gesture: "ruota il bacino dopo la riapparizione",
      trajectory: "porta il calcio verso la spalla",
      limb: "gamba sinistra",
      target_zone: "spalla",
      possible_outcomes: ["colpito", "sfiorato", "parato", "schivato", "mancato"],
    },
    next_initiative: {
      authority: "server_snapshot",
      phase: "candidate_defense",
      actor_handle: "il candidato",
      initiative_event_id: "initiative-alpha",
      release_after: "narrative_published",
    },
    scene_projection: { luogo: "aula d'esame", luce: "chiara dalle finestre" },
    dossier_projection: { sfidante: "vigile e misurato" },
    style_projection: [],
    technique_cards: [{
      id: "sostituzione",
      nome: "Tecnica della Sostituzione",
      categoria: "Ninjutsu",
      attivazione: "richiede sigilli",
      descrizione: "scambia il corpo con un supporto preparato",
      effetto: "riappare presso l'ancora autorizzata",
      chakra: "richiede chakra",
    }],
    ...overrides,
  };
}

function expectCode(fn, code) {
  assert.throws(fn, (error) => error instanceof AdapterError && error.code === code);
}

test("compone esito candidato, difesa PNG e un solo contrattacco irrisolto", () => {
  const output = adaptExchange(fixture());
  assert.equal(output.state, "plan_frozen");
  assert.equal(output.narrator_payload.ruolo, "png_attacca");
  assert.equal(output.narrator_payload.intenzioni.length, 1);
  assert.equal(output.narrator_payload.intenzioni[0].counterattack_status, "pending_unresolved");
  assert.equal(output.release_directive.phase, "candidate_defense");
  assert.equal(output.release_directive.release_after, "narrative_published");
});

test("senza contrattacco produce ciclo chiuso e iniziativa candidata", () => {
  const input = fixture({
    counterattack: null,
    next_initiative: {
      authority: "server_snapshot",
      phase: "candidate_action",
      actor_handle: "il candidato",
      initiative_event_id: "initiative-beta",
      release_after: "narrative_published",
    },
  });
  const output = adaptExchange(input);
  assert.equal(output.narrator_payload.ruolo, "png_esito");
  assert.deepEqual(output.narrator_payload.intenzioni[0].esiti_possibili, []);
});

test("lega la ricevuta spaziale alla stessa exchange identity", () => {
  const input = fixture();
  input.spatial_receipt = { ...input.spatial_receipt, exchange_identity: { ...identity, resolution_revision: 2 } };
  expectCode(() => adaptExchange(input), "exchange_identity_mismatch");
});

test("rifiuta difesa non risolta", () => {
  const input = fixture();
  input.png_defense_outcome = { ...input.png_defense_outcome, status: "pending" };
  expectCode(() => adaptExchange(input), "defense_not_resolved");
});

test("rifiuta contrattacco con esito anticipato", () => {
  const input = fixture();
  input.counterattack = { ...input.counterattack, outcome: "colpito" };
  expectCode(() => adaptExchange(input), "counterattack_not_pending");
});

test("rifiuta iniziativa non server-derived", () => {
  const input = fixture();
  input.next_initiative = { ...input.next_initiative, authority: "model" };
  expectCode(() => adaptExchange(input), "next_initiative_not_server_derived");
});

test("rifiuta coordinate raw nella proiezione Narratore", () => {
  const input = fixture();
  input.spatial_receipt = {
    ...input.spatial_receipt,
    narrator_projection: { ...input.spatial_receipt.narrator_projection, raw_coordinates: [1, 2] },
  };
  expectCode(() => adaptExchange(input), "narrative_projection_leakage");
});

test("retry identico restituisce lo stesso piano", () => {
  const input = fixture();
  const first = adaptExchange(input);
  const replay = adaptExchange(input, makeReplayRecord(input, first));
  assert.deepEqual(replay, first);
});

test("stessa request key con payload diverso produce conflitto", () => {
  const input = fixture();
  const first = adaptExchange(input);
  const changed = fixture({ player_context: "testo differente" });
  expectCode(() => adaptExchange(changed, makeReplayRecord(input, first)), "exchange_request_key_conflict");
});

test("substitution_event_id nullo è valido per difese ordinarie", () => {
  const ordinaryIdentity = { ...identity, substitution_event_id: null };
  const input = fixture({
    exchange_identity: ordinaryIdentity,
    spatial_receipt: {
      profile_id: "combat_exam_narrative_spatial_receipt_v1",
      exchange_identity: ordinaryIdentity,
      narrator_projection: {
        defender_before: "sulla misura",
        impact_point: "davanti alla guardia",
        defender_after: "sulla stessa misura",
        distance_band_after: "contatto",
        continuity: "attacco, difesa e assestamento",
      },
    },
    png_defense_outcome: {
      status: "resolved",
      actor_handle: "lo sfidante",
      target_handle: "il candidato",
      defense_label: "parata",
      outcome: "parato",
      consequence: "la guardia devia il pugno e conserva l'equilibrio",
      movements: [],
    },
  });
  const output = adaptExchange(input);
  assert.equal(output.audit_binding.exchange_identity.substitution_event_id, null);
});

test("terminale usa png_finale con causa e Sensei già server-side", () => {
  const input = fixture({
    counterattack: null,
    png_defense_outcome: {
      status: "resolved",
      actor_handle: "lo sfidante",
      target_handle: "il candidato",
      defense_label: "parata",
      outcome: "parato",
      consequence: "la prova raggiunge il proprio termine",
      final_type: "quattro_round",
      movements: [],
    },
    sensei_projection: { nome: "il Sensei" },
    next_initiative: {
      authority: "server_snapshot",
      phase: "exam_terminal",
      actor_handle: "il Sensei",
      initiative_event_id: "initiative-final",
      release_after: "narrative_published",
    },
  });
  const output = adaptExchange(input);
  assert.equal(output.narrator_payload.ruolo, "png_finale");
  assert.equal(output.narrator_payload.esito_precedente.iniziativa, "la prova si chiude");
});
