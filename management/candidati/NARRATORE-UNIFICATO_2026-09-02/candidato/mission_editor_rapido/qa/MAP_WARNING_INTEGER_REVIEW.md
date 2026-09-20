# MISSION-RAPID-MAP-WARNING-REVIEW-051 · review indipendente coordinate mappa

Esito: **VERDE — P0/P1/P2 = 0/0/0**.

Review eseguita sui file della spec registrata, senza DB, browser, provider, apply o deploy. I pin live sono verificati rispetto alle evidenze readonly documentate, non tramite nuova interrogazione live.

## Delta e pin

- Il corpo `preview_for` presente in `db/INSTALL.sql` produce esattamente MD5 `c988923b347cc600b85bb215ea025663`. Sostituendo il solo frammento nuovo con quello precedente si ricostruisce esattamente MD5 `f53d1a36873ee8a82c8c8d149e96fe79`.
- `MAP_WARNING_INTEGER_FIX.sql` accetta soltanto la baseline documentata `f53d1a…`, ammette come replay il solo risultato `c988923…`, richiede una sola occorrenza dell'anchor e verifica il nuovo MD5 dopo l'esecuzione (`db/MAP_WARNING_INTEGER_FIX.sql:15-29`).
- La funzione condivisa `mission_creation_owner.general_spec_warnings(jsonb)` è soltanto letta e pinndata a `f5f2d08f0cccc141632c982890073d8d`; il delta non contiene `CREATE`, `ALTER` o sostituzioni sulla funzione (`db/MAP_WARNING_INTEGER_FIX.sql:21-24`).

## Semantica e recovery

- La normalizzazione conserva ogni oggetto di `suggested_entries`, sovrascrive soltanto `x_m` e `y_m` con valori JSON numerici interi e mantiene l'ordine tramite `WITH ORDINALITY` (`db/MAP_WARNING_INTEGER_FIX.sql:11-13`; `db/INSTALL.sql:455-456`). La preview riceve quindi la stessa spec e gli stessi attori/capienza, con la sola rappresentazione integrale delle coordinate già validate.
- Valori mancanti o non numerici falliscono chiusi nel blocco di validazione mappa già esistente, senza produrre una preview pubblicabile.
- La recovery è speculare: richiede `c988923…`, una sola occorrenza del frammento nuovo, lo stesso pin condiviso, ripristina il frammento precedente e verifica `f53d1a…`; il replay è ammesso soltanto quando il vecchio MD5 è già presente (`db/MAP_WARNING_INTEGER_RECOVERY.sql:15-29`).
- Apply e recovery sono ciascuno in una sola transazione, non contengono `DELETE`, `DROP` o `TRUNCATE` e rifiutano drift prima di eseguire la definizione sostitutiva.

## Non interferenza e prove

- Nessuna interferenza con «Adatta missioni»: il delta riguarda esclusivamente `mission_rapid_owner.preview_for`; pin `progress_step`, guardia `unified_batches` e hook rapido restano nelle quantità attese. Il test contrattuale 22 resta verde (`qa/CONTRACT.test.mjs:112-119`).
- Il test 25 verifica che la normalizzazione preceda `mission_map_preview_v1` (`qa/CONTRACT.test.mjs:130-133`). Restano verdi anche i controlli su catalogo vivo, uguaglianza della spec, validità e capienza.
- Suite pertinenti: **53/53 PASS** — contratto 25/25 e integrazione Admin 28/28.
- Manifest: **18/18 PASS**. `INSTALL.sql`, fix, recovery e test contrattuale sono pinndati alle impronte correnti (`MANIFEST.json:20-23,32`); i conteggi dichiarati 25/25 e 28/28 coincidono con l'esecuzione.

Nessun finding. Il referto non autorizza operazioni live.
