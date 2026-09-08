# MISSION-EXAM-INTERACTION-001 — review indipendente

**VERDE: 0 P0 / 0 P1 / 0 P2.** Unico passaggio indipendente dell’08/09/2026 concluso sul nuovo mandato circoscritto. Nessuna correzione richiesta. Questo referto sostituisce quello REBUILD001, conservato nell’archivio della revisione precedente.

## Perimetro verificato

Confrontati esclusivamente `candidato/mission_edge/src/exam-cycle.mjs` e `exam-opening.mjs` con i corrispondenti file in `_precedenti/2026-09-08_editoriale21_v17/candidato/mission_edge/src/`. Il delta riguarda soltanto il testo delle istruzioni e le versioni CYCLE006 / OPENING004. Il contratto OPENING001 resta invariato. Nessuna modifica funzionale a schema, autorità, ruoli, alternative, autorizzazione, claim, pubblicazione, trasporto, budget o gestione degli errori.

## Riscontri

- L’interpretazione delle istruzioni viene distinta esplicitamente dalla prosa pubblicata: vincoli ed etichette devono diventare eventi percepibili coerenti, senza ripetere il prompt o trasformarlo in spiegazioni al lettore. Questo non attenua l’autorità dei dati server.
- Il contributo della copia resta visivo: nessun effetto fisico, danno, parata o segno, neppure fittizio. Se il server conferma il fallimento dell’inganno, l’effetto scenico si dissolve prima del vantaggio sperato. Il testo vieta esplicitamente di attribuire distrazioni, vantaggi o conseguenze meccaniche non confermati.
- Restano preservate le associazioni documentate fra originale, copia e bersaglio, la distinzione tra inganno e colpo reale e l’obbligo di conservare attaccante, destinatario e conseguenze. La dissoluzione non prova da sola il riconoscimento. La spiegazione attraverso coordinazione/tempismo richiede la causa RNG attestata; la capacità rivelatrice richiede la propria fonte attestata.
- Il dialogo usa la voce del PNG e risponde al senso della role; può svilupparsi in più frasi e momenti senza un limite prestabilito. L’apertura dell’interazione offre un aggancio al giocatore, senza inventarne la replica. Il divieto di linguaggio meccanico nel dialogo non introduce un filtro lessicale o un nuovo validatore.
- Le nuove indicazioni sono editoriali: nessun retry, giudice, regola bloccante o nuova architettura. L’autorità del presente sullo storico e la distinzione tra azioni tentate e risultati confermati restano intatte.

## File congelati

| File | Byte | SHA-256 |
|---|---:|---|
| exam-cycle.mjs | 12818 | `667738fe1e66fbcdd7b8fbfae2c0c758815dd94d249afb456a52e952568693f0` |
| exam-opening.mjs | 9068 | `2e34e0d48d12a8dea3dee9bfc418d27404c1526d7fd6b1f7216f596798766ded` |

Le impronte sono state verificate durante la lettura indipendente. QA riferita dall’owner: **3/3 PASS e 19 controlli di sintassi PASS**. La conferma delle sei persona DB identiche allo stato approvato appartiene al preflight dell’owner e non è una verifica DB del reviewer; le schede e il seed sono fuori dal presente perimetro.

## Conclusione e limiti

Nessun finding nel delta autorizzato: il gate della review è soddisfatto per i due file e le impronte sopra riportati. Nessun impedimento al deploy emerge da questa review, ferma restando la procedura di rilascio e il gate nominativo dell’owner/PM. Nessun deploy, apply, provider, test aggiuntivo o modifica dei sorgenti eseguito dal reviewer. Nessun nuovo campione o riapertura della campagna precedente.

La review statica e le prove locali non certificano la qualità di una futura prosa generata né l’elaborazione interna del modello. Non viene dichiarata risolta alcuna discrepanza meccanica attraverso la sola riscrittura delle istruzioni.
