# QA bounded · confronto di due Esami conclusi

TASK-ID: `QA-BOUNDED-DUE-ESAMI-4.6.1`

## Verdetto

**BLOCCATO prima della generazione, senza consumo del budget.** Il branch QA è inerte e interrogabile, ma il corpus materializzato non consente il contratto richiesto «esattamente due esami × tre cicli» senza estenderlo. Nessuna valutazione qualitativa vecchio/nuovo è quindi dichiarata.

## Budget congelato

- Luna/high: massimo 6 chiamate, una per ciclo, nessun retry o rigenerazione.
- Terra/high: massimo 1 giudizio consolidato soltanto dopo i sei confronti.
- Eseguito: **0 chiamate Luna, 0 chiamate Terra, costo stimato $0,0000**.
- Produzione: sole letture; nessuna prova, sessione, messaggio, apply, deploy o modifica.

## Due esami selezionati

Gli ID sono abbreviati e i partecipanti sono indicati soltanto come candidato e sfidante.

| Esame | Cicli storici | Copertura scelta |
|---|---:|---|
| `2399b1fa…` | 11 | risposta dialogica dello sfidante, continuità del fiato e della postura, Moltiplicazione/originale, finale |
| `23d4ccf1…` | 13 | biomeccanica ravvicinata, conseguenze corporee, cambio di linea e di piano, spazio, finale |

Sono esclusi gli esami di Riuji e gli account di prova.

## Matrice dei sei cicli fissati

| Esame | Ruolo nel confronto | Posizione storica | Ciclo | Ruolo motore | Prosa vecchia: caratteri · SHA-256/16 |
|---|---|---:|---|---|---|
| `2399b1fa…` | difesa PNG | 1/11 | `105ef7c7…` | `png_difende` | 560 · `db57b368ac0a4408` |
| `2399b1fa…` | esito intermedio | 5/11 | `1ac1f148…` | `png_esito` | 286 · `4b7887a997b46335` |
| `2399b1fa…` | finale | 11/11 | `2deb79af…` | `png_finale` | 1.027 · `a9b38419292c19f0` |
| `23d4ccf1…` | difesa PNG | 2/13 | `92150b98…` | `png_difende` | 264 · `7be9d8f3669c0a50` |
| `23d4ccf1…` | esito intermedio | 7/13 | `adb9d304…` | `png_esito` | 789 · `e57c0fb44e2b4c16` |
| `23d4ccf1…` | finale | 13/13 | `bf7b92e2…` | `png_finale` | 967 · `bb467c0eaf767992` |

La selezione è deterministica: prima difesa PNG, `png_esito` più vicino al centro della prova, finale.

## Evidenza del blocco

Fotografia in sola lettura del 04/09/2026:

- branch `qa-exchange-monthly-2026-08-31`: 0 prove aperte e 0 cicli non terminali;
- corpus QA: una sola prova sintetica `90000000…`, 18 snapshot totali — 12 dalla prova di riferimento esclusa perché coinvolge Riuji, poi un solo snapshot per ciascuno degli altri sei esami;
- per `2399b1fa…` e `23d4ccf1…` il branch conserva quindi **1 ciclo su 3 richiesti per esame**;
- nella produzione i sei cicli scelti esistono e le prose storiche sono sigillabili, ma il replay degli esami di agosto espone `contesto_pg` vuoto; anche `pg_message_id` non risolve più un corpo in `messages`. Il testo-azione non è quindi recuperabile byte-exact dal contratto di replay corrente.

Avviare la campagna nelle condizioni attuali richiederebbe almeno una violazione: usare Riuji, mescolare cicli di esami diversi, inventare/ricostruire azioni non byte-exact, oppure modificare il corpus del branch senza un piano e un'autorizzazione espliciti.

## Sblocco richiesto al PM

Serve una delle seguenti fonti autoritative, senza cambiare candidata o produzione:

1. indicare dove sono già depositati gli snapshot sanitizzati byte-exact dei sei cicli sopra; oppure
2. autorizzare un piano separato per materializzare sul branch QA le sei fixture immutabili, con sigilli prima/dopo e senza testi completi nel referto.

Solo dopo lo sblocco si eseguono le sei chiamate Luna/high e, poiché il contratto IA ratifica il giudice offline, una sola valutazione consolidata Terra/high. Qualunque rosso resta un finding e non apre patch.
