# MISSION-RAPID-TECHNICAL-JSON-REVIEW-056

## Esito

**P0/P1/P2: 0/0/0 — VERDE.** Il delta è circoscritto, fail-closed e reversibile; non risultano regressioni sui pin condivisi o sul contratto Adatta missioni. Nessuna operazione DB, browser o provider è stata eseguita.

## Evidenze

- `db/TECHNICAL_JSON_CONCAT_FIX.sql:8-11,15-28`: definisce esattamente le due sostituzioni richieste, da `'term_'||rule->>'rule_key'` a `'term_'||(rule->>'rule_key')` e da `'Condizione missione: '||rule->>'rule_key'` a `'Condizione missione: '||(rule->>'rule_key')`. La baseline è vincolata a `6ff11ad4312d7acf2f89f7f3498e47fc`, ogni frammento precedente deve comparire una sola volta, e il risultato deve avere MD5 `11c649ab270b192571d268b05404849e`.
- `db/INSTALL.sql:587-590`: le due espressioni sono presenti una volta ciascuna nella forma parentesizzata; le forme non parentesizzate sono assenti. L'estrazione statica esatta del `prosrc` di `mission_rapid_owner.technical_document` produce MD5 `11c649ab270b192571d268b05404849e`. Sostituendo soltanto i due frammenti nuovi con quelli precedenti si ricostruisce MD5 `6ff11ad4312d7acf2f89f7f3498e47fc`.
- La parentetizzazione forza `rule->>'rule_key'` a produrre testo prima della concatenazione; chiavi trigger ed etichette restano stringhe e il contenitore `jsonb_build_object` non cambia.
- `db/TECHNICAL_JSON_CONCAT_RECOVERY.sql:8-28`: recovery inversa con gli stessi controlli di unicità, pin iniziale `11c649ab270b192571d268b05404849e` e pin finale `6ff11ad4312d7acf2f89f7f3498e47fc`. Apply e recovery sono ciascuno racchiusi in una singola transazione e non contengono `DELETE`, `DROP` o `TRUNCATE`.
- `db/TECHNICAL_JSON_CONCAT_FIX.sql:20-23` e `db/TECHNICAL_JSON_CONCAT_RECOVERY.sql:20-23`: il pin di `preview_for` resta `c988923b347cc600b85bb215ea025663`; restano invariati anche i pin di `mission_creation_preflight_v2` e `mission_create_complete_v1`.
- `db/INSTALL.sql:992-1021`: la composizione Adatta missioni resta invariata. Il pin baseline `0bc40e0ff963c26a63e218f2aa95dd94`, la guardia `mission_generic_owner.unified_batches ub` e l'hook `mission_rapid_owner.try_native_terminal(p_session)` conservano ciascuno le due occorrenze attese.
- `qa/CONTRACT.test.mjs:139-143`: il test 27 vincola entrambe le parentesizzazioni e rifiuta la forma non parentesizzata. Suite eseguita con Node workspace: **27/27 PASS**, 0 fail.
- `MANIFEST.json:20,26-27,36-38`: pin di `INSTALL.sql`, fix, recovery e suite coerenti. Verifica indipendente SHA-256: **22/22 artifact corrispondenti**; JSON valido; conteggio contract dichiarato `27/27` coerente con l'esecuzione.

## Verdetto

Il delta può superare il gate di review indipendente. Restano distinti e non eseguiti gli eventuali gate successivi di apply e collaudo live.
