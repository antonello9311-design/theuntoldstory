TASK-ID: `PM-DOCUMENTALE-CANTIERI-DIPENDENZE-001`
Scope toccato: governo documentale del cantiere COMBAT-COMPOSITE e riconciliazione con le schede d'area; nessun candidato, SQL, database, Edge, sito, regola, gate, recovery o sessione.
Contratti usati/modificati: usati Composite R13 LIVE inerte, contratto offline Moltiplicazione R4, offerta server-side della Sostituzione e contratto narrativo dell'adapter; nessun contratto applicativo modificato. La dipendenza operativa è la head LIVE verificata al gate.
Decisioni prese / OPEN: Composite resta LIVE inerte; Moltiplicazione resta offline e va ribasata; Sostituzione resta offer-only finché manca il resolver; adapter dello scambio aperto.
Prove eseguite e risultato: manifesti `moltiplicazione/candidato/SHA256SUMS`, `review/SHA256SUMS` e `PACKAGE_SHA256SUMS` verificati verdi prima e dopo la riconciliazione; baseline LIVE del 03/09 history461/head `20260903111028`; nessuna mutazione LIVE da questa task.
Rischi o regressioni da verificare: drift della head al gate, uso prematuro dell'offerta di Sostituzione, alterazione accidentale del round congelato, confusione fra review verde e applicabilità corrente.
Passaggio richiesto al PM: assegnare il rebase di Moltiplicazione sulla head LIVE fresca; autorizzazioni separate per ogni eventuale fase successiva.
