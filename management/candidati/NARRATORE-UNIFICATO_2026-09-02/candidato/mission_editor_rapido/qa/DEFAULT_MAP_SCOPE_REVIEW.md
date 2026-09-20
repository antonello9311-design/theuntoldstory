# MISSION-RAPID-DEFAULT-MAP-REVIEW-058

## Esito

**P0/P1/P2: 0/0/0 — VERDE.** Il delta separa correttamente la mappa globale `default10` dal binding esplicito `specific`, con installazione e recovery fail-closed. Nessuna operazione DB, browser o provider è stata eseguita.

## Evidenze

- `db/INSTALL.sql:565-568`: `arenas` viene popolato soltanto quando `configuration.map.mode='specific'`; in quel ramo conserva `step_key`, `zone_key='arena'`, `template_key` e `template_version` espliciti. Per `default10` non viene emesso alcun binding di arena, quindi resta applicabile la risoluzione globale del preflight.
- `db/INSTALL.sql:648-671`: la pubblicazione passa il documento tecnico a `mission_creation_preflight_v2` prima di `mission_create_complete_v1`; `db/DEFAULT_MAP_SCOPE_FIX.sql:22-25` vincola queste dipendenze rispettivamente agli MD5 `2bfa56c88e45c52eb4495ee1f7c5d870` e `8a512021ec0335f6eddb8b859607b056`. Il delta non replica né sostituisce la risoluzione globale.
- `db/INSTALL.sql:443-460`: l'anteprima continua a validare `default10` contro la mappa catalogo prevista e `specific` contro chiave/versione e spec vive; validità e capienza restano bloccanti. L'MD5 estratto di `preview_for` è ancora `c988923b347cc600b85bb215ea025663`.
- `db/DEFAULT_MAP_SCOPE_FIX.sql:8-30`: la sostituzione del frammento precedente compare esattamente una volta, richiede baseline `11c649ab270b192571d268b05404849e` e verifica risultato `30a9523e58702a14aca5f7d8d4a05eae`. L'estrazione statica esatta del `prosrc` candidato produce `30a9523e58702a14aca5f7d8d4a05eae`.
- `db/DEFAULT_MAP_SCOPE_RECOVERY.sql:8-30`: recovery esattamente inversa, con unicità del frammento nuovo, pin iniziale `30a9523e58702a14aca5f7d8d4a05eae` e risultato `11c649ab270b192571d268b05404849e`. L'inversione statica della sola sostituzione ricostruisce tale MD5. Apply e recovery sono transazionali e non contengono `DELETE`, `DROP` o `TRUNCATE`.
- `db/INSTALL.sql:993-1022`: il contratto Adatta missioni resta invariato. Il pin `0bc40e0ff963c26a63e218f2aa95dd94`, la guardia `mission_generic_owner.unified_batches ub` e l'hook `mission_rapid_owner.try_native_terminal(p_session)` conservano le due occorrenze attese.
- `qa/CONTRACT.test.mjs:144-148`: il test 28 vincola il solo ramo `specific` e vieta il precedente `CASE` che produceva un'arena anche per `default10`. Suite eseguita con Node workspace: **28/28 PASS**, 0 fail.
- `MANIFEST.json:20,28-29,38-40`: pin di `INSTALL.sql`, fix, recovery e suite coerenti. Verifica SHA-256 indipendente: **24/24 artifact corrispondenti**; JSON valido; conteggio contract dichiarato `28/28` coerente con l'esecuzione.

## Verdetto

Il delta può superare il gate di review indipendente. Restano distinti e non eseguiti apply e collaudo live.
