# COMBAT-CATALOGO-SIGILLI-RETIRE-20261118 · ritiro applicato

## Scope toccato

Richiesta esplicita di Antonello: «cancella attivazione sigilli che entra da un'altraparte». Ritirata la sola voce `clan_techniques/29ecdd97-c224-4bca-8bf9-efb17ebe70f3`, Attivazione Sigilli, attraverso `is_active=false`. La riga resta conservata per la storia del catalogo. Inventario e instradamento la escludono dalle nuove integrazioni.

## Contratti usati/modificati

Campo esistente is_active; nessuna nuova colonna, funzione, regola, formula, costo o permesso. Altre361righe della tabella confrontate prima/dopo sotto lock, identiche. Le altre9voci di sigilli restano attive. Ricerca esatta per UUID/nome nei corpi runtime e nel client:0riferimenti diretti. Root7de ed Edge45 non modificati da questo ritiro.

## Decisioni prese / OPEN

La precedente decisione di lasciare Attivazione Sigilli da definire è sostituita da RETIRED_EXPLICITLY. Nessuna descrizione proposta o meccanica nuova va applicata a questa voce. Le sintesi originali dell'analisi337 restano storiche; osservazione corrente336 e ID escluso sono espliciti in INVENTARIO/EDITORIALE. Il lavoro sulle altre tecniche prosegue nel mandato già aperto.

## Prove eseguite e risultato

Review indipendente0/0/0, referto0445ca5902f0dbd88474541c1f7c553f484911484f17c126d848114dddf68201. Source2079byte SHA07b6f9c62d1aa345a10461830ec2b65e7c692cd1141d2ece86a0c9dee07daa3e, recovery2105byte SHA97c733b8d1d3ca135cdfdfc21a43b3b5fec5889481b736c5b04dbf7762bde0c5;3SQL e PL/pgSQL ciascuno passati staticamente. Prima immagine6134750c, dopo b3a9cab1 ricostruita e verificata nativamente; unica differenza is_active.

Apply singolo riuscito: migrazione20261118151920 `catalogo_ritira_attivazione_sigilli_20261118`. Postflight:362righe,336attive,26inattive;0descrizioni mancanti tra le attive. Digest catalogo0f8c69c660ef41009156af9783787599de01aa09032d98dd3686ed28fa7cc59f. Target inattivo e hash b3a9cab178fa9507d1c718bca95c0944c6f80ac9d102fd5de57f8931a1ab0b93. Source e ricevuta integrali in SIGILLI_RETIRE_REVIEW.json. Nessuna prova gameplay o chiamata provider; recovery non eseguita. Verifica dell'esclusione mediante query viva del catalogo attivo; il browser ha soltanto osservato i PG presenti, senza navigare dalla Staff.

## Rischi o regressioni da verificare

Le acquisizioni storiche e le schede non sono state mutate. La recovery riattiva soltanto il flag se l'intera riga corrisponde alla precisa immagine dopo il ritiro; richiede un successivo mandato e non è un collaudo da eseguire. La correzione del comando Palmo è un delta distinto ancora in preparazione sulla stessa Root7de.

## Passaggio richiesto al PM

Conservare fonte, review e ricevuta, pubblicare selettivamente i6artefatti e integrare la decisione nelle sezioni correnti già prenotate dall'unico PM del catalogo. Riprendere Cure senza reintrodurre il doppione. Il ritiro non qualifica o completa le meccaniche del resto del catalogo.
