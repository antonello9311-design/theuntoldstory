# MISSION-RAPID-COUNTERREVIEW-023 · seconda controverifica

Esito: **ROSSO — P0/P1/P2 = 0/1/2**.

Verifica indipendente, sola lettura, senza Docker, provider o mutazioni live. Suite rieseguite: compilatore 35/35, UI 51/51, media 18/18, Admin 28/28, contratti 16/16; totale 148/148. Le correzioni della seconda aggregata risultano presenti: la mappa viene riletta dal catalogo vivo e confrontata esattamente; validità e capienza sono bloccanti; Edge, DB e UI vietano più condizioni native non standard nella stessa fase; il manifest include contratto DB e suite UI/media.

## P1 · PNG alleati o civili non disponibili al runtime terminale

`protect_subject` ed `escape` accettano riferimenti a PNG alleati o civili presenti nella fase. La costruzione del documento tecnico inserisce però nell'incontro soltanto gli attori con `team=avversari`. L'`actor_map` runtime deriva dagli attori dell'incontro: il soggetto alleato o civile non viene trovato e la valutazione terminale solleva errore invece di concludere la fase. Occorre includere questi PNG nell'incontro, mappando gli alleati sulla squadra PG, oppure bloccare esplicitamente tali riferimenti.

## P2 · Modulo UI sorgente non pinato

La suite `ui/mission-rapid-editor.test.mjs` importa `ui/mission-rapid-editor.mjs`, ma il manifest pinna soltanto l'asset deploy `ui/mission-rapid-editor.asset.v1.mjs`. La riproducibilità non copre quindi il modulo realmente esercitato dalla suite; va aggiunto al manifest e va attestata l'uguaglianza esatta tra sorgente e asset.

## P2 · Soglie decimali accettate e convertite

La validazione DB verifica che `threshold` sia numerico, poi lo converte direttamente a `integer`. Valori come `1.5` possono quindi superare la validazione ed essere sigillati con semantica diversa da quella dichiarata. La validazione deve richiedere un numero matematicamente intero prima del cast.

## Verifiche positive

- Pin e controllo vivo della mappa specifica verificati.
- Unicità della regola nativa non standard per fase verificata in Edge, DB e UI.
- Hook terminale, recovery conservativa, CORS e ritorno immediato per missioni non rapide verificati.
- I 15 hash dichiarati nel manifest corrispondono.

Gate: terza correzione aggregata e terza controverifica completa. Nessun rilascio autorizzato da questo esito.
