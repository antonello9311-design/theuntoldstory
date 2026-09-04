# Piano P1 Combat per chiusura Esame

Mandato approvato: completare sullo stesso cantiere e sulla stessa revisione integrata i tre verticali necessari al Narratore 4.8, senza apply o enable.

## Contratto condiviso

Una sola identità di scambio lega `combat/exam root`, attacco candidato, difesa Sostituzione, exact anchor, posizioni before/impact/after, esito PNG e iniziativa successiva. Tutti i fatti sono server-authoritative; il Narratore riceve una proiezione semantica e non decide numeri, coordinate, bersagli o iniziativa.

## File e ownership

- `[NEW/MODIFY] sostituzione/candidato/` — DB-CORE: resolver, schema/API, migrazione candidata, rollback e prove.
- `[NEW/MODIFY] adapter/candidato/` — COMBAT-CORE: piano dello scambio, ordinamento delle due azioni e contratto Narratore.
- `[NEW/MODIFY] receipt/candidato/` — COMBAT-CORE: ricevuta point-of-view e proiezione autorizzata.
- `[MODIFY] integrazione/` — owner principale: manifest, suite integrata, budget e sigilli.
- `[MODIFY] review/` — un solo passaggio indipendente; una sola correzione aggregata; una controverifica conclusiva.
- `[MODIFY] SCHEDA.md`, `HANDOFF.md`, `STORICO.md` e schede area — stato e consegna.

## Ordine

1. Fotografia produzione in sola lettura e branch Supabase QA healthy/allineato.
2. Congelamento del contratto condiviso e degli exact input/output/errori.
3. Costruzione parallela dei tre verticali.
4. Suite locale solo unit/fault injection.
5. Suite completa sul branch QA allineato: nominale, bordi, stale, race, replay, ACL/RLS, rollback e leakage.
6. Una review indipendente; una correzione aggregata; controverifica finale.
7. Gate offline nominativo. Nessun apply/enable/deploy/smoke LIVE senza autorizzazione successiva.

## Stop immediati

- branch QA assente, unhealthy o non allineato alla head produzione;
- drift su file già letti o ownership concorrente;
- tentativo di toccare Riuji, prova Esame aperta/congelata, cron o token runtime;
- valore di gioco derivato da client/IA;
- P0, rischio dati/sicurezza o mutazione non prevista.
