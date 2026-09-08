# MISSION-EXAM-NIGHT-AGGREGATA-001 — review indipendente

**VERDE tecnico, 0 P0 / 0 P1 / 0 P2.** Unico passaggio aggregato dell'08/09/2026. Nessun finding o correzione richiesti; nessun nuovo esempio, test, provider, mutazione DB o modifica ai sorgenti dell'owner da parte del reviewer.

## Perimetro e pin

Letti contratto, manifest, QA e test dei tre gruppi; confrontati i tre file Edge con `_precedenti/2026-09-08_night_baseline_v15/`. Manifest verificato in lettura **5/5 byte e SHA corrispondenti**. Pin prodotto: exam-cycle 11357 byte `83172d5591f8d9a8f2c47569713c9d2e6c4332c78de76a0527ea9b483ee9b37c`; exam-opening 8085 byte `8277b2bc5eab0b5e54ea4abbd6b53743a07967e6edc4218c55e0ef4486d28a29`; exam-session 3239 byte `8896f486e8c3b033c7436df0fb6b23b420a06912a58431f3f8e88ae3cccee908`.

I due SQL congelati `47a93c7d…` e `753af90a…` conservano le review separate già verdi: non sono stati riaperti, modificati o ritestati in questo passaggio.

## Esito del delta

Il delta di exam-cycle è limitato a CYCLE004 e alle istruzioni. Rende esplicito che png_attacca con esito_precedente produce il racconto pubblico dello scambio completo: parole e azione del PG, tecnica e difesa, conseguenza confermata, reazione del PNG e nuova offensiva ancora tentata. Senza esito_precedente resta la sola offensiva consentita. Le istruzioni conservano ruoli separati, branche selezionate dal server, difesa futura irrisolta e divieto di inventare risultati o azioni del PG.

Le note richiedono interazione riconoscibile, movimento continuo, personalità ed emozione, senza imporre la mossa ottimale o percentuali di errore. Distinguono proprietario delle copie, esito dell'inganno e colpo reale; mantengono incorporeità, causalità dei danni e fonte attestata per capacità rivelatrici. Raccolta separata della chat e dei fatti, confronto e integrazione prima della prosa restano presenti. Il minimo 1000 è soltanto un'istruzione editoriale sul messaggio completo; nessun controllo di lunghezza, filtro o rimozione automatica è introdotto.

In exam-opening la spiegazione del Sensei è richiesta in dialogo diretto fedele alla fonte autorizzata. I campi devono contenere prosa definitiva, senza appunti tecnici. Non sono aggiunti requisiti bloccanti, variazioni allo schema o autorizzazioni a iniziare il combattimento. VERSION mantiene OPENING001; la nuova costante PROMPT_VERSION distingue OPENING002. Il solo import modificato in exam-session registra il metadato corretto nell'esito dell'apertura, preservando validator_version SESSION001 e tutta la gestione di owner, claim, deposito e pubblicazione.

La lettura dei diff conferma assenza di modifiche fuori da istruzioni/versioni e import del metadato. Parametri esiti 10000, apertura 4096, high e timeout 120 secondi restano invariati. Non vengono ripristinate le porte manuali ritirate, introdotti giudice/retry/fallback o ampliati perimetri Auth. La richiesta di prosa definitiva è una direttiva al modello, non un filtro sul risultato.

## Evidenze e limite del verdetto

QA owner: prima esecuzione dei tre gruppi **3/3 PASS**, 414,958334 ms, sintassi 19 moduli, zero provider reali. Il banco letto verifica delta circoscritto, dati e struttura preservati, accettazione strutturale della prosa corta, metadato OPENING002 con SESSION001 e ritiro delle porte manuali. Il reviewer non ha rieseguito né ampliato il banco.

Cinque baseline complete, 15 chiamate, 108311 token e postflight05 invariato sono evidenze operative riferite dall'owner, non nuove letture live del reviewer. Il verde tecnico non certifica miglioramento della prosa o ragionamento interno del modello. Restano necessari gate nominativo, preflight delle fonti e del servizio, rilascio aggregato e campioni di conferma previsti nel budget. Nessuna autorizzazione implicita ad aggiungere campioni, sostituire quelli rossi o aprire globalmente il servizio.
