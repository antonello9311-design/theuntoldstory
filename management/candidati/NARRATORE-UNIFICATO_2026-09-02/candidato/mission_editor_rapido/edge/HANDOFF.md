# MISSION-RAPID-AUTHORING-001 · handoff

TASK-ID · `MISSION-RAPID-AUTHORING-001`

Scope toccato · Nuova Edge isolata `mission_authoring_ai`: schema JSON stretto, validatore puro, prompt editoriale, ciclo claim/provider/complete/reject a singola chiamata e ingresso HTTP autenticato. Nessun file o runtime di `mission_generic_ai` modificato.

Contratti usati/modificati · Input `mission-authoring-request/1`; output `mission-authoring-output/1`; telemetria `mission-authoring-telemetry/1`; revisione `mission-authoring-ai/2026-09-19.mvp2`. L'output IA contiene contenuto editoriale, schieramento chiuso (`alleati`, `avversari`, `civili`) e richieste semantiche, mai statistiche, PV, chakra, danni, costi o tecniche.

Decisioni prese / OPEN · La sorgente autorevole arriva dal claim DB, non dal corpo Edge. Un solo tentativo provider; output strutturato strict; budget modello/output fornito dalla policy server. OPEN: le RPC service-role `mission_rapid_compile_claim_v1`, `mission_rapid_compile_complete_v1` e `mission_rapid_compile_reject_v1` saranno realizzate dal componente DB. Nessun deploy o chiamata provider eseguiti.

Prove eseguite e risultato · Suite Node pura: **35/35 PASS** su input, schema, schieramento, riferimenti, separazione pubblico/privato, esclusione meccanica, map mode, condizioni terminali, idempotenza, assenza retry e CORS exact-origin. Il compilatore impone vittoria→successo, sconfitta→fallimento, fase combat per ogni condizione, al massimo una condizione nativa non standard per fase, soggetto stabile per fuga/protezione/posizione e soglia intera 1–99 per resa/sopravvivenza. `node --check` PASS su schema/runtime; parse TypeScript con `node --experimental-strip-types --check` PASS sull'entrypoint. Zero chiamate provider. Limite: non certifica Deno hosted, Auth, rete, DB o qualità narrativa reale; Deno non è installato sulla macchina.

Rischi o regressioni da verificare · Validare il bundle Deno dopo la composizione con le RPC; il modello configurato deve esistere nella policy privata. Il deploy resta gate separato.

Passaggio richiesto al PM · Collegare le tre RPC worker e includere questa Edge nella matrice integrata solo dopo il componente DB.
