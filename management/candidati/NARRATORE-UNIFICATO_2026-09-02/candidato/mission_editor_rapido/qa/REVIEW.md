# MISSION-RAPID-REVIEW-002 · review indipendente

Esito: **ROSSO — P0/P1/P2 = 0/3/2**. La candidata `mission-rapid-editor/2026-09-19.review3` non può essere applicata né portata nella Staff Test Room.

## Finding

### P1-01 · Ogni primo salvataggio della bozza viene rifiutato

Il server normalizza sempre `source` aggiungendo `phase_hints`, `png_uploads`, `has_map_image` e `map_notes` (`db/INSTALL.sql:196-209`) e conserva quella forma nella bozza. Il client, invece, inizializza e rimanda soltanto `plot`, `phase_hints` e `has_map_image` (`ui/mission-rapid-editor.mjs:13-19`, `:99-101`); né la risposta di compilazione né `applyCompiled` ripristinano la sorgente normalizzata (`db/INSTALL.sql:316-328`, `ui/mission-rapid-editor.mjs:143-150`). `validate_draft` pretende poi uguaglianza JSON esatta fra il documento inviato e `p_source` (`db/INSTALL.sql:340-346`). Il primo `mission_rapid_draft_save_v1` termina quindi con `MR_DRAFT_SHAPE` anche senza correzioni, impedendo anteprima e pubblicazione.

### P1-02 · Le correzioni editoriali promesse non sono salvabili

L’interfaccia modifica direttamente `state.compiled`: missione, fasi, transizioni, PNG e condizioni (`ui/mission-rapid-editor.mjs:280-311`). Il salvataggio include quel valore modificato (`:99-101`, `:251-260`), ma il server richiede che `p_document.compiled` sia byte-logicamente identico al risultato IA originario `p_compiled` (`db/INSTALL.sql:340-346`). Qualunque correzione richiesta dal contratto viene quindi rifiutata con `MR_DRAFT_SHAPE`. I test UI verificano soltanto la copia del documento (`ui/mission-rapid-editor.test.mjs:26-27`) e non esercitano il contratto server, perciò il 43/43 non copre questo percorso.

### P1-03 · Le condizioni terminali generiche non hanno un consumer runtime

La pubblicazione salva le regole e genera transizioni (`db/INSTALL.sql:619-623`, `:529-539`), mentre la loro applicazione dipende da `mission_rapid_terminal_evaluate_v1` (`:636-675`). Nell’intera candidata e nel sito non esiste alcun chiamante della RPC: la ricerca del simbolo trova solo definizione, recovery e documentazione; Edge e UI non la invocano. Di conseguenza resa, fuga, protezione, posizione e sopravvivenza non possono essere valutate automaticamente nel percorso reale, e il caso 10 del piano Staff non è eseguibile end-to-end.

### P2-01 · Il manifest non congela due runtime distribuiti

`edge/mission_authoring_ai/index.ts` importa `runtime.mjs` (`:2`) e `media/png_media_attest_v1/index.ts` importa `media/runtime.mjs` (`:2`), ma `MANIFEST.json` non include l’hash di nessuno dei due. Verificare i 9/9 hash dichiarati non garantisce quindi che il codice effettivamente distribuito sia quello revisionato.

### P2-02 · Le risposte POST del compilatore non espongono CORS

`edge/mission_authoring_ai/index.ts:4` costruisce tutte le risposte applicative senza `access-control-allow-origin`; l’header compare soltanto nella risposta `OPTIONS` a riga 8. Dal pannello web la risposta della compilazione risulta quindi opaca/bloccata dal browser e forza il percorso di errore/polling anche quando il lavoro è concluso. Non duplica la chiamata provider, ma rende non affidabile la conferma diretta richiesta dal flusso.

## Evidenze verdi, non sufficienti al gate

- 9/9 hash dichiarati nel manifest coincidenti.
- SHA-256 Admin pubblicato ancora `795d6cfd91b82ecfa148917ee5c61d108f2d838a0c0aea0c97c5a838cbb6821c`; candidata `e080eca67975ac034643a1c7b5454106bdfb656613eeb85376831385bc2ac01a`.
- Sorgente UI e asset distribuito byte-identici, SHA-256 `cdfc60ced62df4b0744a4f66045e472063c8cb76140a70ff5c7ef495f06a10ca`.
- Suite pure: compilatore 29/29, media 18/18, UI 43/43, Admin 28/28; totale 118/118.
- SQL candidato: transazione unica; tag bilanciati; nessun `DELETE`, `DROP` o `TRUNCATE`; grant espliciti presenti; recovery conservativa presente.
- Checkpoint live readonly: schema `mission_rapid_owner` assente; preflight MD5 `2bfa56c88e45c52eb4495ee1f7c5d870`; create MD5 `8a512021ec0335f6eddb8b859607b056`; board-open MD5 `7efaab206f6b8f1fab92b72c848d5d72`; due bundle adottati con binding/versione meccanica approvati.
- Nessuna chiamata provider, nessuna mutazione live, nessun Docker.

## Gate

Servono una correzione aggregata e una nuova candidata congelata. La controverifica deve aggiungere almeno un test di contratto client/server che dimostri salvataggio della forma normalizzata, modifica editoriale persistita, invocazione autorevole delle regole terminali e copertura completa degli artefatti distribuiti. Solo un successivo esito indipendente `0/0/0` abilita rilascio riservato e Staff Test Room.
