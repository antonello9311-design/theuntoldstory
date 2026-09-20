# MISSION-RAPID-COUNTERREVIEW-025 · terza controverifica

Esito: **ROSSO — P0/P1/P2 = 0/1/0**.

Verifica indipendente, sola lettura, senza Docker, provider o mutazioni live. Suite pure rieseguite: 151/151. Hash manifest: 17/17.

## P1 · Attori scena e incontro divergono dopo la normalizzazione del team

La terza aggregata trasforma correttamente `alleati` e `civili` in `squadra` dentro `encounter_actors`, ma `scenes[].actors` continua a usare `phase_actors` non normalizzati. Il validatore Mission Generic pinato richiede che ogni attore dell'incontro sia JSON-esattamente presente negli attori della scena; una fase combat con alleato o civile fallisce quindi il preflight con `MG_ENCOUNTER_ACTOR_SCOPE` prima di arrivare al runtime terminale.

Correzione minima: nelle fasi mechanical usare `encounter_actors` anche in `scenes[].actors`, mantenendo `phase_actors` per l'editoriale e il controllo di almeno un avversario. Serve un controllo cross-contract esplicito sull'uguaglianza richiesta da Mission Generic.

## Verifiche positive

- Soglie DB matematicamente intere.
- Sorgente UI e asset pinati e byte-identici.
- Hook, recovery e ritorno immediato per missioni Adatta senza regole rapide invariati e corretti.

Gate: quarta correzione aggregata e quarta controverifica completa. Nessun rilascio autorizzato da questo esito.
