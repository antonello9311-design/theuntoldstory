# QA-MULTIPLICATION-PROJECTION-AGGREGATE-002 · consegnato

**PASS componente: 6/6 gruppi, una sola esecuzione dell’aggregata 1/5.** La controverifica indipendente ROOT di PP-01 e integrità resta il passaggio successivo.

## Correzione e conservazione
Il referto iniziale REVIEW.md ha identificato un solo finding PP-01 (0/0/1): entrambi i precedenti vettori G2 erano entro cinque metri euclidei e non distinguevano il filtro rimosso. La prima campagna 001 e i quattro output originali sono conservati byte per byte in `_precedenti/qa-before002/`; il suo 6/6 non viene ricertificato retroattivamente.

È cambiato esclusivamente il secondo vettore già previsto di G2: da [(2,2),(4,6)] a [(2,2),(8,2)], più la relativa descrizione del risultato. Coordinate finite e dentro i bounds della fixture: distanza L1=6, distanza euclidea²=36>25. Il primo vettore resta [(2,2),(4,5)] al confine L1=5. Nessun gruppo, esempio o variante aggiunti; prodotto e altri cinque gruppi invariati. Il renderer conserva esattamente coordinate e DTO, senza clamp o snap. Questo attesta la delega della geometria al server, **non la legalità meccanica del secondo vettore**.

## Freeze e campagna
Runner congelato e comunicato al PM prima del run: `0cbded5093ed5bbf13872644111af33678e8d5c614dd06a253a23d15af50beff`. Sintassi Node verificata senza campagna, poi un solo run il 10/09/2026 dalle 04:57:00.457 alle 04:57:00.475 UTC; ciclo misurato 13,44725 ms. Sei gruppi raccolti, nessun retry o patch dopo il run.

Il banco estrae il Common dal vero LAND candidato ed espone in VM quattro funzioni interne già esistenti; compila inoltre quattro script inline. DOM minimo e RPC in memoria sono fixture dichiarate, non un browser o backend. I pin dei 8 artefatti della candidata e 15 sorgenti risultano identici prima/dopo; drift vuoto. MANIFEST autore `84ae057cac775185b61fd7d85c779c802b907584f291896ec4f6befb325b41df`; LAND `803026fd27d2a9dde67c6bca95e59e51474c8d02387ee2f531c565a5c094c824`.

| Gruppo | Esito |
|---|---|
| G1 | PASS: indici coincidenti distinti, marker/legenda, coordinate, DTO e ID conservati. |
| G2 | PASS: confine L1=5 e vettore euclideo oltre 5 rappresentati senza clamp né mutazione DTO. |
| G3 | PASS: tutte le nove varianti di shape invalida già previste respinte; vecchia mappa rimossa. |
| G4 | PASS: privacy neutra e tre fughe respinte; evidenziato soltanto l’indice originale autorizzato. |
| G5 | PASS: marker focusabili e accessibili strutturalmente; due ID selezionabili separatamente, prepare canonico, zero commit. |
| G6 | PASS: inversi dei due blocchi e marker ricostruiscono LAND precedente byte identica; terreno, Clone e mappa senza Moltiplicazione conservati. |

## Limiti e handoff
Zero SQL, API, Docker, browser e provider. Nessun test di Auth/RLS, visibilità reale, lettore di schermo, motore, efficacia Assalto o legalità delle disposizioni; UI privata 003 non eseguita. Nessuna modifica a DB, PNG, feedback o altre fonti. Due campagne cumulative (001 e aggregata 002), una correzione aggregata consumata su cinque; zero retry nella revisione.

Il task_id nel JSON grezzo resta QA-MULTIPLICATION-PROJECTION-001, identificatore della matrice originaria mantenuto dal runner; questo report e il manifesto attribuiscono inequivocabilmente il run alla correzione AGGREGATE-002 mediante hash e timestamp. Output congelati per la sola controverifica PP-01 e integrità ROOT, senza nuovi casi. Guard canonico utilizzato per integrazione e consegna; nessun rilascio live implicito.
