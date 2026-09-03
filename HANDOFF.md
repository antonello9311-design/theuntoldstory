TASK-ID: `PM-DOCUMENTALE-CANTIERI-DIPENDENZE-001`
Scope toccato: governo documentale del cantiere CLAN-L1 e riconciliazione con le schede d'area; nessun candidato, SQL, database, Edge, sito, regola, gate o sessione.
Contratti usati/modificati: usati i contratti già ratificati e la catena LIVE inerte history450–453; nessun contratto applicativo modificato. La dipendenza operativa è la head LIVE verificata al momento del gate, non head453/455.
Decisioni prese / OPEN: exact21 resta aperto (13 voci centrali; Nara, Sabaku e Uchiha da consolidare); runtime verticali non conclusi; Marionettisti da riscrivere sul contratto ratificato; ogni candidato pinzato a head453/455 richiede rebase e nuova review, senza search/replace sui sigilli.
Prove eseguite e risultato: manifesti correnti `editoriale/SHA256SUMS` e `runtime/SHA256SUMS` verificati verdi prima e dopo la riconciliazione; baseline LIVE del 03/09 history461/head `20260903111028`; nessuna mutazione LIVE da questa task.
Rischi o regressioni da verificare: drift della head prima del gate, vecchio runtime Marionettisti, ratifiche sparse non ancora entrate in exact21, confusione fra fondazione inerte e tecnica utilizzabile.
Passaggio richiesto al PM: assegnare la chiusura documentale exact21; solo dopo, autorizzare separatamente il primo rebase runtime sulla head LIVE fresca.
