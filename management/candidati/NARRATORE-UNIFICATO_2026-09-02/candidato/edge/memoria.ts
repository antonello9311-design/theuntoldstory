// Memoria stilistica: deriva esclusivamente da prosa precedente e non diventa
// mai fonte di fatti. Serve a escludere ripetizioni, non a proseguire eventi.

export type MemoriaStile = {
  versione: "memoria_stile/1.0";
  autoritativa: false;
  battute: string[];
  chiusure: string[];
  formule: string[];
  immagini: string[];
  frasi: string[];
};

const RE_IMMAGINE = /\b(?:fiato|respiro|polvere|luce|ombra|stoffa|pelle|sangue|sudore|legno|tatami|parete|finestr\w*|occhi|sguardo|mano|piede|spalla|braccio|gamba|ginocchi\w*|busto|peso|appoggio)\b/iu;

export function frasiNarrative(t: string): string[] {
  const out: string[] = [];
  let corrente = "";
  let inBattuta = false;
  for (const ch of String(t ?? "")) {
    corrente += ch;
    if (ch === "«") inBattuta = true;
    if (ch === "»") inBattuta = false;
    if (!inBattuta && /[.!?…]/u.test(ch)) {
      const f = corrente.trim();
      if (f) out.push(f);
      corrente = "";
    }
  }
  if (corrente.trim()) out.push(corrente.trim());
  return out;
}

export function normalizzaStile(t: string): string {
  return String(t ?? "")
    .toLocaleLowerCase("it")
    .normalize("NFKD")
    .replace(/\p{M}/gu, "")
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function uniche(xs: string[], max: number): string[] {
  return [...new Set(xs.map(normalizzaStile).filter((x) => x.length >= 12))].slice(-max);
}

export function costruisciMemoriaStile(stile: Array<{ voce: string; testo: string }>): MemoriaStile {
  const testi = stile.filter((e) => e.voce === "narratore").map((e) => String(e.testo ?? "")).filter(Boolean);
  const frasi = testi.flatMap(frasiNarrative);
  const chiusure = testi.map((t) => frasiNarrative(t).at(-1) ?? "");
  const battute = testi.flatMap((t) => [...t.matchAll(/«([^»]+)»/gu)].map((m) => m[1]));
  const immagini = frasi.filter((f) => RE_IMMAGINE.test(f));
  const formule = frasi.flatMap((f) => {
    const parole = normalizzaStile(f).split(" ").filter(Boolean);
    if (parole.length < 7) return [];
    return [parole.slice(0, 7).join(" "), parole.slice(-7).join(" ")];
  });
  return {
    versione: "memoria_stile/1.0",
    autoritativa: false,
    battute: uniche(battute, 24),
    chiusure: uniche(chiusure, 12),
    formule: uniche(formule, 32),
    immagini: uniche(immagini, 18),
    frasi: uniche(frasi, 48),
  };
}

export function similaritaStile(a: string, b: string): number {
  const aa = new Set(normalizzaStile(a).split(" ").filter((x) => x.length > 2));
  const bb = new Set(normalizzaStile(b).split(" ").filter((x) => x.length > 2));
  if (!aa.size || !bb.size) return 0;
  let comuni = 0;
  for (const x of aa) if (bb.has(x)) comuni++;
  return comuni / (aa.size + bb.size - comuni);
}
