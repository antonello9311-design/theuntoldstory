Stato: **in lavoro**

# Cantiere · COMBAT-COMPOSITE

## Scopo

Completare la catena Combat Composite senza confondere componenti già LIVE inerti, candidati offline e funzioni ancora mancanti.

## Stato operativo

- **Composite R13** è LIVE inerte a history451: consumer movimento + azione applicato, ma nessuna attivazione pubblica è implicita.
- **Moltiplicazione R4** è un candidato offline con review 0/0/0 e sigilli integri, ma la catena arriva a history453: richiede rebase sulla head LIVE verificata al momento del gate, nuova readiness e nuova review. Migration, rollback, checksum e review correnti non si alterano.
- **Sostituzione** è offer-only: LIVE esiste l'offerta server-side, non il resolver completo. Finché mancano ancore/range/cooldown/consumo/collisione/commit/ricevuta, non va usata in gioco.
- **Adapter dello scambio** è ancora aperto: ricevuta autoritativa → piano → Luna → validatore → approvazione, senza delegare meccaniche all'IA.
- La baseline LIVE verificata il 03/09/2026 è history461, head `20260903111028 esame_narratore_unificato_005_bersaglio_dichiarato`; non è un pin permanente.

## Ordine corrente

1. Ribasare Moltiplicazione sulla head LIVE fresca, senza mutare il candidato sigillato: la revisione successiva lo sostituisce e la precedente va in `_precedenti/`.
2. Eseguire readiness, suite e review indipendente 0/0/0.
3. Completare Sostituzione come resolver server-authoritative.
4. Completare l'adapter dello scambio e poi il QA integrato.

## Vincoli

Nessun apply, recovery, enable, sessione, canary o caricamento LAND è autorizzato da questa scheda. Il round congelato di prova resta intatto.
