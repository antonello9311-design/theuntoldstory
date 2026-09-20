# MISSION-RAPID-COUNTERREVIEW-021 · prima controverifica

Esito: **ROSSO — P0/P1/P2 = 0/2/1**.

Verifica indipendente, sola lettura, senza Docker, provider o mutazioni live. Suite rieseguite: compilatore 34/34, UI 50/50, media 18/18, Admin 28/28, contratti 14/14; totale 144/144. I cinque finding della review precedente risultano corretti: source canonica, compiled editoriale salvabile, consumer runtime effettivo, dipendenze runtime nel manifest e CORS coerente.

## P1 · Mappa specifica non pinndata alla versione/catalogo

`db/INSTALL.sql` valida soltanto `spec.template_key`; la spec restituita dalla porta viva non contiene `template_version`. La preview usa la spec contenuta nel documento, ma non confronta la geometria con `mission_map_detail_v1(template_key, template_version)` e non trasforma `valid=false` o `can_fit=false` in errore bloccante. Publish usa invece key/version separate. Una geometria diversa da quella pubblicata può quindi sigillare riferimenti `reach_position`; la capienza può emergere solo più tardi.

## P1 · Condizioni native simultanee bloccano la missione

Schema e UI ammettono più regole sulla stessa fase, mentre `try_native_terminal` solleva `MR_TERMINAL_NATIVE_AMBIGUOUS` quando più di una è vera. Il fixture combina `protect_subject` e `survive_rounds`: a combattimento risolto dopo la soglia, con soggetto e PG vivi, entrambe risultano vere e la progressione resta bloccata prima del terminale Generic. Il contratto non vieta né ordina esplicitamente questa combinazione.

## P2 · Manifest incompleto per la riproducibilità

Il manifest dichiara i conteggi UI e media e usa il contratto DB, ma non hash-pinna `ui/mission-rapid-editor.test.mjs`, `media/TEST.mjs` e `db/CONTRACT.json`.

## Verifiche positive

- `progress_step` usa il pin esatto `0bc40e0ff963c26a63e218f2aa95dd94` e un solo innesto.
- Il ritorno immediato per missioni senza regole rapide avviene prima di leggere incontri, round o stato spaziale.
- La recovery ricostruisce la definizione attesa e rifiuta drift successivi.
- Helper terminale privato; RPC JSON legacy sempre negata e senza grant.
- I 12 hash già presenti nel manifest corrispondono.

Gate: seconda correzione aggregata e seconda controverifica completa. Nessun rilascio autorizzato da questo esito.
