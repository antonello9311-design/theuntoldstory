import { createHash } from "node:crypto";

const OUTCOMES = new Set([
  "copia_colpita", "originale_individuato", "sostituito", "colpito",
  "sfiorato", "parato", "schivato", "mancato",
]);
const NEXT_PHASES = new Set(["candidate_defense", "candidate_action", "exam_terminal"]);
const RAW_KEYS = /^(?:x|y|z|position|position_m|coordinates|raw_coordinates|actor_id|anchor_id|chakra|pv|roll|potenza|damage)$/u;

export class AdapterError extends Error {
  constructor(code, message) {
    super(message);
    this.name = "AdapterError";
    this.code = code;
  }
}

function fail(code, message) {
  throw new AdapterError(code, message);
}

function object(value, code = "adapter_input_invalid") {
  if (!value || typeof value !== "object" || Array.isArray(value)) fail(code, "oggetto richiesto");
  return value;
}

function string(value, code = "adapter_input_invalid") {
  if (typeof value !== "string" || !value.trim()) fail(code, "stringa richiesta");
  return value;
}

function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.keys(value).sort().map((key) => [key, canonical(value[key])]));
  }
  return value;
}

function digest(value) {
  return createHash("sha256").update(JSON.stringify(canonical(value))).digest("hex");
}

function assertNoRawProjection(value, path = "narrator_payload") {
  if (Array.isArray(value)) {
    value.forEach((item, index) => assertNoRawProjection(item, `${path}[${index}]`));
    return;
  }
  if (!value || typeof value !== "object") return;
  for (const [key, item] of Object.entries(value)) {
    const narrativeTechniqueChakra = key === "chakra" && typeof item === "string";
    if (RAW_KEYS.test(key) && !narrativeTechniqueChakra) fail("narrative_projection_leakage", `${path}.${key}`);
    assertNoRawProjection(item, `${path}.${key}`);
  }
}

function validateIdentity(identity) {
  const value = object(identity);
  for (const key of [
    "exchange_id", "root_application_id", "attack_application_id", "defense_application_id",
  ]) string(value[key]);
  if (!Number.isInteger(value.exchange_version) || value.exchange_version < 1) fail("adapter_input_invalid", "exchange_version");
  if (!Number.isInteger(value.resolution_revision) || value.resolution_revision < 1) fail("adapter_input_invalid", "resolution_revision");
  if (value.substitution_event_id !== null && value.substitution_event_id !== undefined) string(value.substitution_event_id);
  return value;
}

function sameIdentity(left, right) {
  return digest(left) === digest(right);
}

function validateSemanticAction(action) {
  const value = object(action);
  if (value.status !== "executed") fail("candidate_action_not_executed", "azione candidata non eseguita");
  for (const key of ["actor_handle", "target_handle", "label", "gesture", "trajectory"]) string(value[key]);
  if (value.limb != null) string(value.limb);
  if (value.target_zone != null) string(value.target_zone);
  if (value.technique_handle != null) string(value.technique_handle);
  return value;
}

function validateResolution(resolution) {
  const value = object(resolution);
  if (value.status !== "resolved") fail("defense_not_resolved", "difesa PNG non risolta");
  for (const key of ["actor_handle", "target_handle", "defense_label", "consequence"]) string(value[key]);
  if (!OUTCOMES.has(value.outcome)) fail("adapter_input_invalid", "outcome fuori vocabolario");
  if (value.technique_handle != null) string(value.technique_handle);
  if (value.movements != null && !Array.isArray(value.movements)) fail("adapter_input_invalid", "movements");
  if (value.final_type != null && !["sfinimento", "quattro_round"].includes(value.final_type)) {
    fail("adapter_input_invalid", "final_type fuori vocabolario");
  }
  return value;
}

function validateCounterattack(counterattack) {
  if (counterattack == null) return null;
  const value = object(counterattack);
  if (value.status !== "declared_unresolved" || "outcome" in value || "damage" in value) {
    fail("counterattack_not_pending", "contrattacco deve restare irrisolto");
  }
  for (const key of [
    "application_id", "intent_id", "actor_handle", "target_handle", "label", "genre", "gesture", "trajectory",
  ]) string(value[key]);
  if (value.limb != null) string(value.limb);
  if (value.target_zone != null) string(value.target_zone);
  if (value.technique_handle != null) string(value.technique_handle);
  if (!Array.isArray(value.possible_outcomes) || value.possible_outcomes.length === 0 || value.possible_outcomes.some((x) => !OUTCOMES.has(x))) {
    fail("counterattack_not_pending", "esiti possibili non validi");
  }
  return value;
}

function validateNext(next) {
  const value = object(next);
  if (value.authority !== "server_snapshot" || !NEXT_PHASES.has(value.phase) || value.release_after !== "narrative_published") {
    fail("next_initiative_not_server_derived", "direttiva iniziativa non autoritativa");
  }
  string(value.actor_handle);
  string(value.initiative_event_id);
  return value;
}

function initiativeLabel(phase) {
  if (phase === "candidate_defense" || phase === "candidate_action") return "passa al candidato";
  return "la prova si chiude";
}

function narrativeFacts(action, resolution, counterattack) {
  return {
    adapter_profile: "combat_exam_exchange_adapter_v1",
    candidate_action: {
      actor: action.actor_handle,
      target: action.target_handle,
      label: action.label,
      gesture: action.gesture,
      trajectory: action.trajectory,
      limb: action.limb ?? null,
      target_zone: action.target_zone ?? null,
      status: "executed",
    },
    png_defense_outcome: {
      actor: resolution.actor_handle,
      target: resolution.target_handle,
      defense: resolution.defense_label,
      outcome: resolution.outcome,
      consequence: resolution.consequence,
      status: "resolved",
    },
    counterattack_status: counterattack ? "pending_unresolved" : "absent",
  };
}

export function adaptExchange(input, replayRecord = null) {
  const source = object(input);
  if (source.authority !== "server_snapshot") fail("adapter_input_invalid", "authority");
  const identity = validateIdentity(source.exchange_identity);
  const spatial = object(source.spatial_receipt);
  if (spatial.profile_id !== "combat_exam_narrative_spatial_receipt_v1" || !sameIdentity(identity, spatial.exchange_identity)) {
    fail("exchange_identity_mismatch", "ricevuta spaziale non legata allo scambio");
  }
  const action = validateSemanticAction(source.candidate_action);
  const resolution = validateResolution(source.png_defense_outcome);
  const counterattack = validateCounterattack(source.counterattack ?? null);
  const next = validateNext(source.next_initiative);
  if ((next.phase === "candidate_defense") !== Boolean(counterattack)) {
    fail("next_initiative_not_server_derived", "fase e contrattacco incoerenti");
  }
  if (next.phase === "exam_terminal" && (!resolution.final_type || !source.sensei_projection)) {
    fail("adapter_input_invalid", "terminale privo di causa o Sensei");
  }
  const requestKey = string(source.request_key);
  const inputDigest = digest(source);
  if (replayRecord != null) {
    const previous = object(replayRecord);
    if (previous.request_key !== requestKey || previous.input_digest !== inputDigest) {
      fail("exchange_request_key_conflict", "request key già usata con payload diverso");
    }
    return previous.output;
  }

  const planId = `exchange-plan-${digest({ identity, inputDigest }).slice(0, 24)}`;
  const techniqueIds = [action.technique_handle, resolution.technique_handle, counterattack?.technique_handle].filter(Boolean);
  const cards = Array.isArray(source.technique_cards) ? source.technique_cards : [];
  for (const id of techniqueIds) {
    if (!cards.some((card) => card?.id === id)) fail("adapter_input_invalid", `scheda tecnica assente: ${id}`);
  }
  const scene = object(source.scene_projection);
  const spatialProjection = object(spatial.narrator_projection);
  assertNoRawProjection(spatialProjection, "spatial_receipt.narrator_projection");

  const intentions = counterattack ? [{
    id: counterattack.intent_id,
    etichetta: counterattack.label,
    genere: counterattack.genre,
    movimento: counterattack.movement ?? null,
    ampiezza: counterattack.amplitude ?? null,
    tecnica_id: counterattack.technique_handle ?? null,
    esiti_possibili: [...counterattack.possible_outcomes],
    counterattack_status: "pending_unresolved",
  }] : [{
    id: "close_exchange",
    etichetta: "chiude lo scambio",
    genere: "esito",
    esiti_possibili: [],
  }];

  const narratorPayload = {
    versione: 5,
    ricevuta_id: planId,
    ruolo: counterattack ? "png_attacca" : next.phase === "exam_terminal" ? "png_finale" : "png_esito",
    contesto_pg: typeof source.player_context === "string" ? source.player_context : "",
    esito_precedente: {
      esito: resolution.outcome,
      conseguenza: resolution.consequence,
      iniziativa: initiativeLabel(next.phase),
      movimenti_autoritativi: resolution.movements ?? [],
      tecnica_id: action.technique_handle ?? undefined,
      finale_tipo: resolution.final_type ?? undefined,
    },
    fatti_del_ciclo: narrativeFacts(action, resolution, counterattack),
    stile_precedente: Array.isArray(source.style_projection) ? source.style_projection : [],
    scena: { ...scene, spazio: spatialProjection },
    dossier: object(source.dossier_projection),
    sensei: source.sensei_projection ?? null,
    intenzioni: intentions,
    schede_tecniche: cards,
  };
  assertNoRawProjection(narratorPayload);

  return {
    profile_id: "combat_exam_exchange_adapter_v1",
    state: "plan_frozen",
    audit_binding: {
      exchange_identity: identity,
      plan_id: planId,
      request_key: requestKey,
      input_digest: inputDigest,
      counterattack_application_id: counterattack?.application_id ?? null,
    },
    narrator_payload: narratorPayload,
    release_directive: {
      phase: next.phase,
      actor_handle: next.actor_handle,
      initiative_event_id: next.initiative_event_id,
      release_after: "narrative_published",
      authority: "server_snapshot",
    },
  };
}

export function makeReplayRecord(input, output) {
  return {
    request_key: input.request_key,
    input_digest: digest(input),
    output,
  };
}
