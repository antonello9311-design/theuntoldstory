import type { PayloadV5 } from "./contratto.ts";
import { REGOLE_EDITORIALI, type Piano } from "./piano.ts";

export type GiudizioNarrativo = { verde: boolean; rilievi: string[] };

export const PROMPT_GIUDICE = `Sei il controllo editoriale bloccante dell'Esame Genin. Valuti una bozza narrativa italiana contro un brief autoritativo: non riscrivi il testo e non correggi i fatti. Restituisci soltanto JSON semplice {"verde":true,"rilievi":[]}.

Applica tutti i criteri editoriali del brief ai soli fatti disponibili. Distingui difetto della prosa da fonte mancante; non attribuire la mancanza della scheda tecnica alla persona se la persona è fornita. Mano, lato, gesto e traiettoria descrittiva del PNG sono licenza narrativa plausibile, non campi obbligatori della ricevuta: giudica concretezza, coerenza e varietà contestuale, senza esigere nuovi fatti server. Non consentire invece modifiche di bersaglio meccanico, movimento, costi, danni, esiti o dettagli dichiarati dal PG. Nessuna quota di frasi o battute, nessun nuovo vincolo numerico.

Verifica l'assetto e il passaggio d'iniziativa nell'intera scena, senza esigere la parola «iniziativa» o entrambi i nomi nell'ultima frase. Nel finale la prova è chiusa: non imporre un nuovo attacco o turno. Per ogni tecnica associa preparazione, sigilli e chakra al suo stadio (tecnica già risolta oppure nuova intenzione): i sigilli della prima non appartengono automaticamente alla seconda. Il tipo di azione «reazione/mantenuta/istantanea» non specifica una sequenza di attivazione; non dedurla dal solo tipo. Le licenze redazionali esplicite non cambiano validità, esiti o costi del motore.

Il verdetto è verde soltanto se sono tutti verdi: causalità completa dal gesto del candidato alla lettura/preparazione della difesa, alla tecnica/esito e al nuovo assetto; iniziativa finale identica al server; biomeccanica concreta senza etichette del motore; sfidante presente come persona fisica ed emotiva, con voce o risposta naturale quando il candidato parla; Sostituzione collegata a preparazione, attacco e ancora autorizzata; ambiente subordinato ai corpi; grammatica italiana; scena corrente al presente narrativo, con passato ammesso solo se necessario per antefatti o dialoghi; nessuna formula o immagine ripetuta; nessun fatto inventato. Valuta il tempo verbale nel contesto, non con una blacklist di verbi. Un solo difetto rende verde=false. I rilievi sono brevi e specifici.`;

export const SCHEMA_GIUDIZIO: Record<string, unknown> = {
  type: "object",
  properties: {
    verde: { type: "boolean" },
    rilievi: { type: "array", items: { type: "string" } },
  },
  required: ["verde", "rilievi"],
  additionalProperties: false,
};

export function costruisciPromptGiudice(p: PayloadV5, piano: Piano, uscita: Record<string, unknown>, rilieviDeterministici: string[]): string {
  const intenzione = p.intenzioni.find((x) => x.id === uscita.intenzione_id);
  // Identica proiezione viewer-safe del brief Luna: nessuna fonte aggiuntiva.
  const schede = p.schede_tecniche ?? [];
  const schedaScelta = intenzione?.tecnica_id ? schede.find((x) => x.id === intenzione.tecnica_id) ?? null : null;
  const tecnicaRisoltaId = typeof p.esito_precedente?.tecnica_id === "string" ? p.esito_precedente.tecnica_id : null;
  const schedaRisolta = tecnicaRisoltaId ? schede.find((x) => x.id === tecnicaRisoltaId) ?? null : null;
  const iniziativa = p.ruolo === "png_difende" ? piano.riferimenti.sfidante : p.ruolo === "png_finale" ? "prova chiusa" : piano.riferimenti.candidato;
  return JSON.stringify({
    ruolo: p.ruolo,
    regia: piano.regia,
    criteri_editoriali: REGOLE_EDITORIALI.map(({ id, criterio }) => ({ id, criterio })),
    attori: { candidato: piano.riferimenti.candidato, sfidante: piano.riferimenti.sfidante, sensei: piano.riferimenti.sensei },
    claim_candidato: piano.player_bridge.claims,
    tema_dialogo: piano.riferimenti.player_utterances,
    esito_precedente: p.esito_precedente,
    fatti_del_ciclo: p.fatti_del_ciclo,
    intenzione,
    scheda_tecnica_scelta: schedaScelta,
    scheda_tecnica_esito_precedente: schedaRisolta,
    schede_tecniche_provenienza: p.schede_tecniche_provenienza ?? null,
    spazio_revisionato: p.scena.spazio ?? null,
    iniziativa_finale: iniziativa,
    persona_sfidante: p.dossier,
    memoria_esclusione: piano.riferimenti.memoria_stile,
    bozza: { azione_png: uscita.azione_png, esiti: uscita.esiti },
    rilievi_deterministici: rilieviDeterministici,
  });
}

export function leggiGiudizio(testo: string): GiudizioNarrativo {
  let raw: unknown;
  try { raw = JSON.parse(testo); } catch { return { verde: false, rilievi: ["giudizio Terra non leggibile"] }; }
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) return { verde: false, rilievi: ["giudizio Terra malformato"] };
  const r = raw as Record<string, unknown>;
  if (typeof r.verde !== "boolean" || !Array.isArray(r.rilievi) || r.rilievi.some((x) => typeof x !== "string")) {
    return { verde: false, rilievi: ["giudizio Terra fuori contratto"] };
  }
  const rilievi = (r.rilievi as string[]).map((x) => x.trim()).filter(Boolean).slice(0, 12);
  return { verde: r.verde && rilievi.length === 0, rilievi };
}
