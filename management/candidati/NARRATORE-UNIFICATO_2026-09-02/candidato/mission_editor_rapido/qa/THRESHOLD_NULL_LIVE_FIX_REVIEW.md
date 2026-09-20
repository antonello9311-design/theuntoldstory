# MISSION-RAPID-THRESHOLD-REVIEW-041 · review indipendente threshold JSON null

Esito circoscritto: **VERDE — P0/P1/P2 = 0/0/0**.

Review in sola lettura del delta live-fix. Nessun apply, deploy, accesso DB/Edge, provider o altra risorsa live.

## Semantica verificata

In `db/INSTALL.sql:267-282` il validatore separa correttamente presenza SQL e `null` JSON:

- chiave `threshold` assente: `r->'threshold' is not null` è falso, quindi la soglia è assente;
- chiave presente con `"threshold": null`: il valore `jsonb` esiste ma è uguale a `'null'::jsonb`, quindi la soglia è ancora assente;
- qualunque valore JSON non-null: la soglia è presente.

Il confronto `IS DISTINCT FROM` impone quindi la corrispondenza esatta con i soli tipi `surrender_after_exchanges` e `survive_rounds` (`db/INSTALL.sql:278`). Per questi due tipi, assenza o JSON null vengono rifiutati; per tutti gli altri tipi, qualsiasi valore non-null viene rifiutato. Quando la soglia è richiesta, le righe `279-281` rifiutano tipo JSON diverso da `number`, valore frazionario e intero fuori dall'intervallo `1..99`. I valori non numerici non possono raggiungere un'accettazione: vengono respinti dal controllo di tipo o, comunque, dal cast PostgreSQL senza produrre una regola valida.

La tabella di verità indipendente copre: regola senza soglia × chiave assente/null/numero/stringa e regola con soglia × chiave assente/null/numero/stringa. Gli unici casi accettati sono assente/null per i tipi senza soglia e numero valido per i tipi con soglia.

## Regressione e manifest

- Il test 23 fissa la nuova distinzione dal JSON null e vieta il predicato precedente (`qa/CONTRACT.test.mjs:120-123`).
- Restano verdi il test 17 su integralità e il test 22 sul pin/hook `progress_step` con guardia `unified_batches`; il delta non modifica i contratti di «Adatta missioni» (`qa/CONTRACT.test.mjs:92-94,112-119`). Nel SQL restano due soli riferimenti al pin baseline, due occorrenze della guardia unificata old/new e due occorrenze dell'hook old/new.
- Tutti i 16 artefatti dichiarati nel manifest corrispondono agli SHA-256; `db/INSTALL.sql`, runtime/schema/test Edge e test di contratto risultano pinati alle impronte correnti (`MANIFEST.json:20,24-26,30`). I conteggi dichiarati pertinenti sono compilatore 43/43 e contratto 23/23 (`MANIFEST.json:32`).

## Prove

- Suite pertinenti: **66/66 PASS** — compilatore 43/43, contratti statici 23/23.
- Controllo indipendente manifest: **16/16 artefatti PASS**.
- Matrice completa osservata: **162/163**. L'unico rosso è `baseline admin riconciliata`, che confronta intenzionalmente il vecchio SHA `795d…` con `sito_live/admin.html` già composto a `e080…`; è il detector pre-composizione già registrato in `RELEASE.md`, non dipende dal delta threshold e non incide sull'esito circoscritto.

Nessun finding sul live-fix. Il referto non autorizza nuove operazioni live.
