import repertorio from "./repertorio.json" with { type: "json" };

const CONSUMER = "combat_narratore_ai";
export function caricaOrchestra() {
  if (repertorio.consumer !== CONSUMER || !repertorio.prompt || !repertorio.impronta_prompt) throw new Error("repertorio_assente_o_incoerente");
  return Object.freeze(repertorio);
}
export function auditOrchestra(usage: unknown) {
  const r = caricaOrchestra();
  return { modello: r.parametri_modello.modello, versione_funzione: r.versione_funzione, versione_deploy: null, versione_prompt: r.versione_prompt, versione_repertorio: r.versione_repertorio, impronta_prompt: r.impronta_prompt, impronta_repertorio: r.impronta_repertorio, consumer: r.consumer, dominio: r.dominio, parametri_modello: r.parametri_modello, usage_api: usage };
}
export async function registraOrchestra(admin: any, usage: unknown, origine: { tabella?: string; id?: string } = {}) {
  const riga = { ...auditOrchestra(usage), origine_tabella: origine.tabella ?? null, origine_id: origine.id ?? null };
  const { error } = await admin.from("ai_orchestra_audit").insert(riga);
  if (error) throw new Error("audit_orchestra_non_registrato: " + error.message);
}
