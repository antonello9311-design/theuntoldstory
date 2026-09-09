// Diagnostica privata: mai serializzare testo, contesto o messaggi liberi.
export type TextInspection = {
  text: string | null;
  normalized: string | null;
  final: string | null;
  codes: string[];
};
export type TextRules = {
  normalize: (s: string) => string;
  violations: (s: string, context: any) => string[];
  truncate: (s: string, max: number) => string;
  contextAllowed: (context: any) => boolean;
  min: number;
  max: number;
};
function violationCode(message: string): string {
  if (message === "contiene cifre") return "digits";
  if (message === "contiene trattini lunghi") return "long_dash";
  if (message === "non è un blocco unico") return "multiple_blocks";
  if (message.startsWith("troppo corto (")) return "normalized_too_short";
  if (message.startsWith("contiene «")) return "forbidden_word";
  if (message.startsWith("copia colpita incompatibile")) return "copy_outcome_conflict";
  return "other_validation_rule";
}
export function inspectText(raw: string, context: any, rules: TextRules): TextInspection {
  if (!rules.contextAllowed(context)) return { text: null, normalized: null, final: null, codes: ["context_rejected"] };
  const normalized = rules.normalize(raw);
  const violations = rules.violations(normalized, context);
  if (violations.length) return { text: null, normalized, final: null, codes: [...new Set(violations.map(violationCode))] };
  const final = rules.truncate(normalized, rules.max);
  const accepted = final.length >= rules.min && final.length <= rules.max;
  return { text: accepted ? final : null, normalized, final,
    codes: accepted ? [] : [final.length < rules.min ? "final_too_short" : "final_too_long"] };
}
const digest = async (s: string) => Array.from(new Uint8Array(
  await crypto.subtle.digest("SHA-256", new TextEncoder().encode(s)),
)).map(n => n.toString(16).padStart(2, "0")).join("");
export async function diagnosticRecord(
  inspection: TextInspection | null,
  provenance: Record<string, boolean>,
  stage: "evaluated" | "validator_exception" | "provider_not_ok",
  validatorRevision: string,
) {
  let normalizedHash: string | null = null, finalHash: string | null = null;
  let hashesAvailable = true;
  try {
    if (inspection?.normalized !== null && inspection?.normalized !== undefined) normalizedHash = await digest(inspection.normalized);
    if (inspection?.final !== null && inspection?.final !== undefined) finalHash = await digest(inspection.final);
  } catch { hashesAvailable = false; }
  return {
    schema_version: "ordinary-diagnostics/1",
    validator_revision: validatorRevision,
    stage,
    text_accepted: inspection === null ? null : Boolean(inspection.text),
    reason_codes: inspection?.codes ?? [stage],
    normalized_chars: inspection?.normalized?.length ?? null,
    final_chars: inspection?.final?.length ?? null,
    normalized_sha256: normalizedHash,
    final_sha256: finalHash,
    hashes_available: hashesAvailable,
    provenance,
  };
}
