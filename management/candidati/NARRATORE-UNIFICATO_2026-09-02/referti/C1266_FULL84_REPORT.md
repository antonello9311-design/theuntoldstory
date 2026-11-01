# Discussioni in Centro · Full84

**Esito complessivo: FAILED_FULL. Missione non aperta in Land.** Collegamento arena corretto, avvio riuscito e quattro Fati conservati. Il percorso giocato è stato pacifico; Combat e ritorno alla narrazione restano NOT_RUN. La chiusura ufficiale ha richiesto una correzione di recupero dopo il fallimento del collaudo.

| Passaggio | Evidenza |
|---|---|
| Collegamento catalogo arena | Corretto nella revisione9; catalogo/hash nativi coerenti |
| Avvio Staff | PASS, accessi normali Riuji e Tamako |
| Incipit e tre turni successivi | 4 Fati pubblicati, leggibili; 6 azioni acquisite una volta |
| Combat | NOT_RUN: sfida condizionale rifiutata dal PNG; ramo pacifico |
| Ritorno dal Combat alla narrazione | NOT_RUN |
| Chiusura al primo tentativo | Bloccata: history_unreconciled |
| Recupero amministrativo34 | PASS, conclusione normale verificata e archiviata |
| Apertura Land | NON ESEGUITA |

## Correzione arena33

La rappresentazione numerica del catalogo conservato differiva da quella del producer server:10 contro10.00 e0.5 contro0.50, pur con uguaglianza semantica jsonb. Hash dichiarato82fe32eb…; hash del catalogo conservato48cac6be…. Non è provato quale vecchio trasferimento abbia introdotto la differenza; era già presente prima di Editorial67.

Rigenerato integralmente arena_sources attraverso map_source sul server, senza passaggio JSON JavaScript. Nuova revisione9 della stessa missione6d6c216a-222d-4cba-b2fc-f3e0c199c195:4da7191e-689f-5aa1-b377-cfdda0da5278, definizione11bd5367-fc6f-5ec6-bf91-0142b2368824. PlanSHA285d6315d7a011e970610cb192d6bbbd3cc2b8bd40a6e6d2e843287ee0992199; sourceSHAc7b731434f68e0d437d0f2cadcb88d7e7afa55973aeacc3013b31264830f01e1. Documento, fasi, schede e geometria invariati; V8 e tutte le versioni precedenti conservate.16INSERT/3UPDATE/18identità; nessuna funzione/firma/ACL/schema/vincolo/Edge/UI/gate modificati.

Migrazione20261101223944. Sorgente/materiale0/0/0; confronto vivo255header/10ABI/13tabelle/136vincoli senza differenze. Avvio eseguito sulla versione congelata Root3d736201…/Edge148/UIaa6cd604…. L’incipit è arrivato senza ripetere l’avvio.

## Percorso giocato e limite del caso

Masterefb45793-bc28-4f2a-9c43-03f83b175198; carrier59e4640a-9f14-4847-bbbc-10228e71cea7. Entrambe le azioni di sfida scritte dall’assistente erano condizionali: lasciavano ai PNG la possibilità di non accettare. Daichi ha rifiutato e il narratore ha scelto il ramo pacifico dalla fase conclusione alla fase4. Non è un bug meccanico dimostrato dal rifiuto; è una copertura del caso Combat mancata. Nella fase4 arena_phase_key/receipt/encounter sono assenti: l’arena è operativa soltanto nella fase3 saltata. Nessuna fase forzata, azione duplicata o missione riavviata.

| Fato | ID | Caratteri |
|---|---|---:|
| Incipit | a5365777-0e2b-4344-bd26-160e605afad9 |829|
| Risposte alle domande | f0f81dc7-7556-4d07-a1f8-c3f03ca77178 |1359|
| Rifiuto sfida e rettifica pubblica |636fa515-3ace-4055-a9db-8f6071689c98|1078|
| Uscita e impegno a riferire |a3d86287-5a3e-4151-a6c5-82c0f52cf5ea|957|

Sono quattro Writer narrativi; nessun Director eseguito in questo caso, ma il runtime completo conserva passaggi Director/Writer nel Combat. La preview storica solo narratore non è stata presentata come qualifica del percorso completo.

## Chiusura e recupero34

Run conclusa e scena closed dopo il quarto Fato, ma Master ancora aperto: scene_finish_proof rifiutava history_unreconciled. Tutti quattro gli output provider erano conservati, con receipt/attempt success e costi exact. Il predicato combinato respingeva i primi tre; il ramo retained isolato li accettava. L’AST non evidenzia parentesi o correlazioni diverse: la causa ultima della diversa valutazione SQL resta NON PROVATA.

Dopo l’arresto del collaudo è stato applicato un recupero tecnico circoscritto: CASE valuta prima la prova retained e solo in assenza ricorre al fallback storico. Identici i sette predicati receipt/attempt, le tre condizioni retained e il fallback completo. Nessuna prova inventata o audit allentato; zero nuove chiamate IA. Matrice readonly su4work moderni e6storici reali; non qualifica nuovi percorsi legacy.

Aggregata34, migrazione20261101225602: un solo corpo funzione modificato e relativa identità Root. Firme, permessi, schema, vincoli, Edge, UI e V9 invariati. Review iniziale0/0/1 (attestazione metadataRoot), unica correzione prima dell’apply; sorgente/materiale/postflight finali0/0/0. Precedenti e finding conservati, senza azzerare i conteggi1–34.

Lo stato normale ha poi esposto Concludi la prova. Un solo comando ha chiuso il Master alle22:56:16UTC; finishcompleted/nonreplayed, quattro history_items, receiptSHAe46732037e709ebaf4a36aabbb5dfa6cd7147c3e7b66ae8f0c00a16d12e4698b. Nessuna pendenza o Combat residuo. Archivio normale: Prova · Discussioni in Centro · prova conclusa.

## Conservazione e spesa

Oldcorpus/PG/vecchieversioniSHA647c9a2644580b0989fa3ac56335f83d7d7d34c03940cbfa40fd0cc79faa5221 identico. Tutti quattro Fati, work, role, raw, output, dispatch, tentativi, audit e calls identici prima/dopo recupero e chiusura; cambiano soltanto Master e capability per la conclusione normale. Nessun premio o modifica alle risorse reali. Stato finale Rootaa3b5c1bfbf3abdfefa559437cf380869fc2607ef2aca3818ab3198f52f704be/fullrow64846222849dc0555a4a7771cfe7338411145ecea60ebca6d884d116656e850a; Edge148/UIaa6cd invariati.

Nuova prova:4Count+4Generation=8HTTP,0,05878460USD prudenti;0providercleanup. Totale252HTTP/2,35570270USDsu4, residuo1,64429730USD. Quattro riserve Count unknown_billable conservate, non azzerate né trattate come costo zero.

## Qualità osservata e seguito

Risposte più articolate e avanzamento concreto: confessione, rettifica pubblica, decisione di riferire e uscita. Continuità del foglio e delle monete conservata. Restano autoripetizioni nella rettifica e nell’ultima riattestazione di conoscenze/custodia; ambiente spesso in coda e ripetuto attraverso ceste, teli, banchi e passanti. Nessuna ripresa estesa delle parolePG osservata nelFato2 con input disponibile; il confronto lessicale indipendente deiFati3–4 è limitato dagli input forniti. Reazioni ai colpi e dialogo nel contrattacco non valutabili: nessun Combat eseguito.

Il successivo caso necessario deve scegliere inequivocabilmente il ramo Combat attraverso il normale flusso, senza subordinare l’iniziativa dei PG all’accettazione della sfida da parte del PNG. Da verificare ingresso legale, risoluzione server, Fato completo, cessazione e ritorno narrativo, poi chiusura sulla nuova versione congelata. Non avviato da questo incarico.

La Land non usa ancora gli stessi consumer Scene5 della Staff: init/eventi/role e chiusura pubblici richiedono un’integrazione sostanziale, non un flag o il cambio del vecchio pin587. Nessuna apertura legacy usata come sostituto del percorso collaudato.

Originali privati: /private/tmp/tus-c1266-full84-20261101, inclusi FINAL_CLOSE_PROOF.json (SHA899c10ce…), review sorgente/materiale/post, EDITORIAL84.md e QA_ARCHIVED.png. Nessun testo integrale dei Fati o delle role viene pubblicato nel report Git.
