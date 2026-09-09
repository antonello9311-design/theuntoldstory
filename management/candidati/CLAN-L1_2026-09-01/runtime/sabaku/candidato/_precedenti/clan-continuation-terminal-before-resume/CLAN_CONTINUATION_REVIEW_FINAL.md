# CLAN-CONTINUATION · Controverifica finale terminale

**Verdetto terminale: codice statico 0 P0 / 0 P1 / 0 P2; qualifica 0 P0 / 1 P1 / 0 P2 residuo di copertura. Readiness ROSSA; nessun gate di produzione.** Unica aggregata e unica controverifica del ciclo consumate. Non si autorizzano patch, ripetizioni, nuove review o rinomina della medesima candidata. Nessun ciclo precedente viene riaperto.

## Identità controllata

INSTALL corrente 11.695 byte, SHA-256 `9dc6fa7fd2f0520e9e3779a600d90587d2151d389ae00a839f85bec0b6619089`, coincidente con il referto finale. Manifesto owner controllato durante la chiusura: 8/9 file con byte e SHA esatti; la sola PLAN è stata aggiornata contemporaneamente dall’owner con la proposta documentale del futuro mandato, come da suo messaggio. Nessuna fonte eseguibile è cambiata; il manifesto della review registra la PLAN corrente. L’owner aggiornerà il proprio manifesto dopo questa consegna. Le tre definizioni di scope salvate sono state lette e i loro MD5 ricalcolati: narrative_allowed `9ea79b4c6f08a99352413acb88685044`, is_dedicated_scene `85c8f044f8383f4587a1d8175d9a0ec9`, narrative_attack_allowed `2f8aaa28220e6af251144b4b23213272`. Il nuovo install le verifica oltre ai due pin dei corpi modificati.

Reviewer: sole letture statiche di codice, baseline, runner/helper, piano e referto; nessun DB, browser, provider o test aggiuntivo. Il valore zero dei finding applicativi descrive la review statica: **la candidata aggregata non è stata compilata né esercitata nella finale**.

## Finding iniziali dopo l’aggregata

**CC-R1 — correzione statica completa, compilazione non verificata.** Entrambi i CREATE FUNCTION ricostruiti ora terminano con `$function$;`. Il difetto di assemblaggio è corretto nel testo. Il preflight finale si ferma prima di G01, quindi non c’è un PASS di installazione/rollback di questa revisione.

**CC-R2 — raccordo statico corretto; prove non eseguite.** Passa mantiene is_dedicated_scene e rinuncia_enabled. Le utility usano invece il contesto ordinary Staff protetto: activity risolta e round corrispondente, luogo is_test, policy protetta, source_kind ordinary, luogo sessione coerente e values_written=false. La presenza di un compagno non è più richiesta. Roster, accessi e provider restano affidati al narrative_allowed esistente nel dispatch/acquire; nessuna apertura generale o nuovo writer. clone_case usa Moltiplicazione nativa se deve cedere il primo turno, senza assegnazione diretta del turno. G05 ha ora una precondizione positiva e poi il cambio is_test=false. Nuovo helper postgres-only con SECURITY DEFINER/search_path vuoto; nessun finding statico ulteriore nel perimetro esaminato.

**CC-R3 — casi presenti nella matrice, copertura non ottenuta.** G05 costruisce una dichiarazione risolta trasformata in utility sconosciuta come fault sintetico locale, non usa più soltanto un UUID assente. G06 include un colpo a mani nude con attacco/difesa nativi, contesto e pubblicazione; le posizioni adiacenti sono fixture, non attestazione del movimento. G05 e G06 hanno sottocasi mantenendo gli 8 gruppi e il budget 16 submission. Nessuno di questi casi è stato eseguito nella finale.

## Esito finale e P1 residuo

CLAN_CONTINUATION_QA_FINAL.json: **1 submission, 0,154 secondi totali, 0 provider/token**, preflight ROSSO `qa_baseline_not_clean`. La query richiede che combat_v2_sessions sia completamente vuota e che qa_clan_cont non esista. Owner comunica una diagnosi readonly: nove sessioni già chiuse ereditate dal template; nessuna sessione aperta, helper e nuova candidata assenti; history_md5 `ef57aba397ef404bbb42842cdcf9c6fe`. La diagnosi è riportata come evidenza dell’owner; il reviewer non ha interrogato il DB. La condizione SQL esige zero righe totali, quindi le sessioni storiche chiuse sono sufficienti a spiegare il fallimento.

**P1 residuo — l’intera qualifica aggregata resta mancante.** La finale non raggiunge confronto delle baseline aggiuntive, G01, installazione helper, G02–G07, né G08. Non sono provati Clone, liberazione, copie, esclusione utility ignota, regressioni mano/marionetta/Passa, dispatch unico, report invariato o postflight della candidata. I due PASS preparatori iniziali (clone e sette pin) appartengono alla revisione precedente e non certificano questa aggregata. Nessun esito iniziale/finale viene convertito in PASS per inferenza statica.

Owner segnala inoltre un errore di sequenza: un controllo statico ad hoc contava la riga G08 insieme ai nove sottocasi del ciclo e falliva l’asserzione attesa9; il runner è stato comunque avviato. Si registra l’anomalia senza nasconderla o usarla per svalutare l’esito finale: il conteggio ad hoc non dimostra un difetto applicativo, ma l’esecuzione non è stata fermata su quel controllo. L’unico esito SQL della finale resta il preflight rosso. Nessuna correzione o nuova prova successiva è stata eseguita dal reviewer.

## Requisito per un eventuale nuovo mandato di sola qualifica

Serve un **nuovo mandato esplicito** dopo restituzione al PM, mantenendo questo terminale e le sue impronte. Il perimetro minimo è correggere la fixture/qualifica della baseline, non il prodotto: fotografare e preservare le nove sessioni storiche chiuse, esigere assenza di sessioni aperte/residue della campagna, assenza dei nuovi helper/candidato prima dell’installazione e confronto prima/dopo delle righe storiche. La verifica G08 contiene la stessa pretesa di tabella vuota e deve essere coerente con tale baseline, senza cancellare lo storico. Riconciliare il controllo statico del numero di gruppi/sottocasi prima di avviare il runner; poi eseguire l’intera matrice originale sul codice identificato, senza ridurre i requisiti né trattare uno stub HTTP come Edge reale. Questo paragrafo definisce il requisito di un possibile mandato futuro; **non lo autorizza e non riapre il ciclo attuale**.

Anche un eventuale verde locale successivo lascerebbe Auth/API/Edge e smoke live protetto da attestare secondo i gate previsti. Fino ad allora niente apply né invio live del Clone affidato a questo raccordo. Fonti e precedenti congelati nel manifesto finale della review.
