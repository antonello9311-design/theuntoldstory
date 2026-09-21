# SABAKU-ARMOR-PUBLIC-RULES-CLAN-UI-20260921

TASK-ID · SABAKU-ARMOR-PUBLIC-RULES-CLAN-UI-20260921

Scope toccato · Apertura pubblica di Armatura di Sabbia; pubblicazione dei cataloghi selettivi `regole.html` e `clan.html`; registrazione del collaudo e del rilascio.

Contratti usati/modificati · `sabaku-armor-view/2`, autorità condivisa del consumo sabbia, pannello Combat V2 ordinario. UI Regole `RULES-TECH-CATALOG-001`; UI Clan `CLAN-TECH-CATALOG-002`. Migrazione `20260921122347 sabaku_armor_public_enable_20260921`.

Decisioni prese / OPEN · Antonello ha ratificato l’equivalenza del ramo sabbia insufficiente con l’interruzione già validata delle tecniche per controllo della sabbia. Armatura è pubblica: Staff ON e pubblico ON. Nessun caso bloccante resta aperto; la precedente perdita di rete è conservata come limite della prova diretta, senza effetti sulle risorse reali.

Prove eseguite e risultato · Review indipendente SQL `0/0/0`; pin delle due migrazioni e delle sette funzioni critiche; postflight gate/catalogo/RLS/ACL/policy/trigger PASS. JavaScript Regole 4/4 e Clan 3/3 valido. Deploy Pages 764 riuscito sul commit `ed2842a7aeec2125f70df53e7c3f94adb74e87df`; dominio verificato: Regole chiuso con una sola card dopo la scelta, Clan Sabaku chiuso con 18 opzioni, Armatura selezionabile e una sola scheda completa.

Rischi o regressioni da verificare · Solo monitoraggio nel normale uso. Recovery conservativa disponibile per riportare `public_enabled=false` lasciando Staff ON.

Passaggio richiesto al PM · Nessuno: rilascio pubblico completato e verificato.
