# MISSION-RAPID-UI-001 · handoff

## Scope toccato

Modulo ESM isolato `mission-rapid-editor.mjs` e suite Node pura. Nessuna modifica a `admin.html`, `land.html`, database, Edge o sito pubblicato.

## Contratti usati

- `mission-rapid-draft/1`
- `mission-rapid-preview/1`
- RPC `mission_rapid_compile_request_v1`, `mission_rapid_compile_state_v1`, `mission_rapid_catalog_v1`, `mission_rapid_draft_save_v1`, `mission_rapid_preview_v1`, `mission_rapid_publish_v1`
- media soltanto tramite callback attestata `uploadMedia`; nessuna scrittura Storage diretta

## Decisioni prese / OPEN

- Il match automatico delle immagini è nominale e conservativo: un pareggio o più immagini candidate resta da risolvere manualmente.
- Qualunque modifica invalida anteprima e sigillo; il comando di pubblicazione usa una UUID persistente in caso di esito di rete incerto.
- Dopo la creazione della coda il client invoca una sola volta `mission_authoring_ai`; una risposta incerta viene riconciliata leggendo lo stato della stessa request e “Riprendi” non genera una seconda chiamata IA nello stesso editor.
- Il client non invia statistiche, PV, chakra o tecniche: sceglie esclusivamente un bundle adottato approvato.
- Il client propone automaticamente il bundle quando il punteggio su grado, ruolo e tag produce un vincitore univoco; un pareggio resta vuoto. Il riepilogo mostrato deriva da `mechanical_profile` server con grado, PV, chakra e tecniche della versione approvata.
- Il budget arriva da `mission_rapid_catalog_v1.runtime_budget`; l'adapter opzionale `runtimeBudget` serve solo per test puri e non va fissato nella pagina.
- Ogni upload PNG consegna all'adapter `actor_key` e `base_bundle_id`; un caricamento globale viene prima associato nominalmente e un'ambiguità resta bloccante. La mappa specifica passa dall'adapter `chooseMap`, che deve riusare il picker e la Edge `mission-map-upload` esistenti.
- Grado, partecipanti, briefing/retroscena/incipit, campi editoriali dei PNG, obiettivi, note, transizioni e le sette condizioni terminali sono modificabili; i nomi campo seguono byte-logicamente `mission-authoring-output/1`.
- OPEN integrazione: implementare il ramo missione di `png_media_attest_v1`, mantenendo byte-identico il ramo Scorta.

## Prove eseguite e risultato

- Suite pura Node: **51/51 PASS**, zero provider call. Coperti anche source canonica, correzioni editoriali persistenti, caricamento della spec server per le mappe specifiche e blocco di più condizioni native sulla stessa fase.
- Controllo sintattico ESM incluso nell'esecuzione della suite.

## Rischi o regressioni da verificare

- Shape dei campi editoriali compilati e opzioni location devono essere confermati nella composizione congelata.
- Il rendering anteprima usa dati server; capienza, tecniche, media, mappe e budget restano validazioni server.
- Nessun collaudo funzionale locale o Docker: dopo review, prova esclusiva nella Staff Test Room protetta.

## Passaggio richiesto al PM

Comporre budget runtime e adapter media, poi integrare il modulo in una copia riconciliata di `admin.html` senza interferire con la versione consegnata da “Adatta missioni”.
