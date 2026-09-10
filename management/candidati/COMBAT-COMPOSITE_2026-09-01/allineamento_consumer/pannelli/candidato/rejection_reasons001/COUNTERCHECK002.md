# Controverifica finale RR-01 · aggregata002

COMBAT-PANEL-REJECTION-REASONS-COUNTERCHECK-002 · QA-INDEPENDENT · 10/09/2026. **PASS: 0 P0 / 0 P1 / 0 P2. RR-01 chiuso.** Prima correzione aggregata cumulativa1/5; arresto al verde. Sola controverifica del finding originario e dell'integrità, nessuna nuova review generale o campagna.

## RR-01

La frase in `INSTALL.sql:83` e nella stessa voce `BASELINE.mapping` è ora: «Manca una scelta richiesta, sono selezionate troppe opzioni oppure alcune scelte sono incompatibili. Rileggi le opzioni e correggi la selezione.» Copre quantità insufficiente, eccessiva e dipendenze incompatibili della guardia nativa già letta, senza attribuire un ramo preciso o introdurre nuove cause. Il finding originario è risolto.

## Integrità verificata

- Sette prodotti correnti coerenti con MANIFEST `f5809d60bda326e0e167dbb39ac0c11d39daeb3586a9a2149c139787d275d81f`. INSTALL SHA `30ec1184eeadb0c708de330357c606f234108d6ca45ba9d284367b8b0f81963d`; RECOVERY SHA `3f025c45c511c5af2725d8de139beecd63c116dc05d60efcb2bbd4c27cf218b2`.
- Nove predecessori in `_precedenti/rejection-before002` corrispondenti alle impronte originarie. REVIEW e REVIEW_MANIFEST iniziali ancora byteidentici anche nei percorsi correnti; esito0/0/1 originario conservato.
- Una sola voce cambiata tra le40 della mappa; le altre39 identiche. Definizioni BEFORE, configurazione, owner/ACL, fonte combat_v2_fail, provenienza010/011 e budget QA invariati. BUILD.py e QA_PLAN.md byteidentici alla001.
- Differenza INSTALL limitata alla frase RR-01 e al conseguente pin AFTER nel postflight. Differenza RECOVERY limitata allo stesso pin AFTER nel preflight. Nessun cambiamento a transazioni, code/recovery/request_key, dispatch, fallback, rollback, permessi o dati. Corpo recovery ancora BEFORE MD5 `84860632d828931cea773b83c583548e`; nuovo AFTER ricalcolato `0ec7f7f1228b3f1afef03ad6323bf960`, coerente in installazione, recovery e manifest.
- PLAN e metadati BASELINE documentano la prima aggregata e la conservazione dei predecessori; nessun azzeramento del ciclo o nuova capacità runtime dichiarata.

## Limiti e passaggio al PM

Zero query, SQL, test, Docker, browser, provider ed esecuzioni del builder in questa controverifica. Solo confronto di testo e impronte, nessun nuovo esempio/caso. La campagna4gruppi/9sottocasi massimi/9submission/10min resta NOT_RUN e invariata. Il verde statico non qualifica compilazione SQL, handler reale, Auth o runtime e non autorizza apply. Il PM può predisporre il runner e la qualifica della stessa candidata secondo il piano già valutato, mantenendo i gate di produzione distinti. Nessuna ulteriore patch richiesta da questa controverifica.
