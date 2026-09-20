# MISSION-RAPID-STORAGE-REVIEW-047 · review indipendente NoSuchKey

Esito: **VERDE — P0/P1/P2 = 0/0/0**.

Review circoscritta ai quattro input registrati, senza DB, browser, provider, apply o deploy.

## Semantica del delta

- `isMissingObject` considera assente un oggetto quando la risposta Storage esterna è `404`, oppure quando è `400` e il corpo contiene uno dei segnali interni ammessi: `code = NoSuchKey`, `error = not_found`, `statusCode = 404` o `httpStatusCode = 404` (`media/runtime.mjs:49-51`). La conversione numerica copre correttamente anche `"404"`.
- Un qualsiasi altro `400` resta falso e quindi fail-closed: il ramo rapido risponde `storage_probe_failed` senza caricare o registrare nulla (`media/png_media_attest_v1/index.ts:27-32`). Anche corpo assente, JSON illeggibile o marker inatteso restano bloccanti.
- Solo una risposta riconosciuta come oggetto assente abilita il `POST` con `x-upsert: false`; un fallimento del caricamento resta bloccante. Una risposta Storage positiva continua invece a richiedere uguaglianza esatta di byte e SHA-256 prima della registrazione.

## Non regressione

- I tre casi nuovi provano `NoSuchKey`, `not_found`/404 interno e un altro `400` bloccante (`media/TEST.mjs:25-27`). Suite media: **21/21 PASS**.
- Il delta è isolato meccanicamente: rimuovendo il solo import/helper, la lettura del corpo errore, la chiamata a `isMissingObject` e i tre test si ricostruiscono esattamente le impronte precedenti di index (`14bb2b…`), runtime (`896742…`) e test (`f5615d…`). Di conseguenza il ramo Scorta (`media/png_media_attest_v1/index.ts:35-50`) e la funzione CORS (`media/png_media_attest_v1/index.ts:13-16,35-43`) sono byte-invariati rispetto alla candidata precedente.
- `RAPID_RELEASE` non cambia; ticket, limiti, ispezione raster, digest, conflitto Storage e registrazione server restano invariati.
- Tutti i **16/16** artefatti dichiarati in `MANIFEST.json` corrispondono ai rispettivi SHA-256; le tre nuove impronte media sono pinndate a `MANIFEST.json:27-29` e il conteggio `media: 21/21` è coerente (`MANIFEST.json:32`).
- `media/runtime.mjs` e `media/TEST.mjs` passano anche `node --check`.

Nessun finding. Il referto non autorizza operazioni live.
