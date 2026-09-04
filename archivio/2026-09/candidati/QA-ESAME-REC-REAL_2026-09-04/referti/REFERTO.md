# Referto unico · confronto Esame 4.7.1 da REC reali

## Verdetto
**BLOCCATO prima della materializzazione e del provider.** Il requisito «due Esami reali conclusi con azioni complete provenienti da REC» non è soddisfatto dai dati vivi.

## Budget
2 Esami · massimo 6 cicli · una Luna/high per ciclo · cap 1.024 · zero retry/rigenerazioni · 60 minuti · massimo $0,12. Consumato: **0 chiamate, $0,00**.

## Evidenza sanitizzata
| Pseudonimo | Prova | Collegamento REC | Azioni candidato | Caratteri | SHA-256/16 | Esito |
|---|---|---|---:|---:|---|---|
| `E6` | `333662b8…` | REC `19e59702…`, luogo e finestra coerenti, 12 ID byte-exact | 9 | 14.633 | `bad09259118934a3` | valida |
| `E3` | `2399b1fa…` | REC sovrapposta in altro luogo, 0 turni dell'Esame | 0 | 0 | — | esclusa |
| `E2` | `23d4ccf1…` | nessuna REC sovrapposta | 0 | 0 | — | esclusa |

Gli altri quattro Esami nelle Arena/Aule del perimetro non hanno azioni dell'Esame dentro una REC; un sesto Esame reale concluso è avvenuto in un luogo ordinario ed è escluso dal perimetro. Riuji, account di prova e prove aperte sono esclusi.

Gli ID storici dei turni risultano ancora leggibili in `messages_archive`, ma per quattro dei cinque Esami nel perimetro non coincidono con `role_messages`. L'archivio tecnico è quindi una possibile fonte alternativa, non una REC; non è stato usato per costruire fixture.

## Finding aggregato
Unica causa sistemica: **la registrazione REC non ha coperto quattro dei cinque Esami reali conclusi nelle Arena/Aule del perimetro**. Non è un difetto del Narratore 4.7.1 e non giustifica correzioni del prodotto in questa task.

## Ambiente
Produzione letta soltanto; 0 prove aperte. Branch QA interrogabile, 0 prove aperte, 0 cicli non terminali, 18 snapshot sintetici preesistenti. Nessuna scrittura, apply, deploy, chiamata modello o pubblicazione.

## Raccomandazione
Attendere una seconda REC reale completa oppure ottenere dal PM un mandato esplicito che ammetta `messages_archive` come fonte sostitutiva. Solo allora materializzare sei fixture immutabili e svolgere il confronto vecchio→4.7.1 entro il budget già congelato.
