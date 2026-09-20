# MISSION-RAPID-ALIAS-REVIEW-043 · review indipendente alias SQLSTATE 42702

Esito circoscritto: **VERDE — P0/P1/P2 = 0/0/0**.

Review in sola lettura del delta alias PL/pgSQL. Nessun apply, deploy, accesso DB/Edge, provider o altra risorsa live.

## Alias e semantica

La funzione `mission_rapid_owner.validate_compiled` dichiara parametro/variabili `p`, `m`, `mp`, `ph`, `a`, `t` e `r` (`db/INSTALL.sql:222-225`). Nel blocco aggregato interessato non resta alcun alias omonimo:

- unicità attori: `actor_item`;
- unicità fasi e controllo chiavi riservate: `phase_item`;
- unicità regole e raggruppamento delle condizioni native: `rule_item`;
- unicità transizioni: `phase_item` con laterale `transition_item` (`db/INSTALL.sql:284-293`).

L'intersezione statica fra parametro/variabili dichiarate e alias delle query aggregate è vuota. La sostituzione è nominale: restano identici array sorgente, chiavi estratte, `GROUP BY`, `HAVING count(*)>1`, controllo delle fasi riservate e insieme dei cinque tipi terminali nativi. Non emerge quindi una variazione di semantica oltre alla rimozione dell'ambiguità che causava SQLSTATE `42702`.

## Invarianti preservate

- Il fix threshold JSON null è ancora presente una sola volta e la forma precedente è assente (`db/INSTALL.sql:278-281`): null/assenza restano ammessi solo per regole senza soglia; tipo numerico, integralità e intervallo `1..99` restano obbligatori per `surrender_after_exchanges` e `survive_rounds`.
- Il test 24 verifica i nuovi alias e vieta le forme confliggenti principali (`qa/CONTRACT.test.mjs:124-129`); i test 16, 17 e 23 preservano unicità native, integralità e JSON null (`qa/CONTRACT.test.mjs:88-94,120-123`).
- I contratti «Adatta missioni» non sono toccati: pin baseline `progress_step` presente nelle due posizioni previste, frammenti old/new con `unified_batches` invariati e hook rapido singolo nella composizione. Il test 22 resta verde (`qa/CONTRACT.test.mjs:112-119`).
- Il manifest pinna le nuove impronte di `db/INSTALL.sql` e del test di contratto (`MANIFEST.json:20,30`); tutti i 16 artefatti dichiarati corrispondono ai rispettivi SHA-256.

## Prove

- Suite pertinenti: **67/67 PASS** — Edge/compilatore 43/43, contratto 24/24.
- Manifest: **16/16 PASS**.
- Controllo statico alias: **0 collisioni** fra `p,m,mp,ph,a,t,r` e `actor_item,phase_item,rule_item,transition_item`.
- Threshold: nuova guardia 1 occorrenza, vecchia guardia 0; pin/hook/guardia «Adatta» conservati.

Nessun finding sul delta alias. Il referto non autorizza nuove operazioni live.
