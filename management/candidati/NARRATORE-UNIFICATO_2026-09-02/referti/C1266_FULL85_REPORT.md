# Discussioni in Centro · Full85

**Esito complessivo: FAILED_FULL. Land non aperta.** La nuova prova ha raggiunto la fase Combat con mappa operativa, ma il primo comando di Tamako è stato rifiutato dal server. Non sono state applicate correzioni durante il collaudo, né reinviate dichiarazioni già accettate.

| Passaggio | Esito osservato |
|---|---|
| Avvio protetto con Riuji e Tamako | PASS |
| Incipit e due Fati successivi | Tre Fati pubblicati, quattro role narrative acquisite una volta |
| Transizione alla mappa scontro | PASS: fase_3, arena operativa, pannello normale |
| Preparazione tecnica e movimento Riuji | Ricevute confermate; sola simulazione, values_written=false |
| Prima dichiarazione Riuji | Passa con role, acquisita una volta; avvicinamento, nessun attacco ancora eseguito |
| Prima dichiarazione Tamako | FAIL: operation_rejected dal commit server; role conservata dal client, dichiarazione assente |
| Attacco esplicito Riuji | NOT_RUN: il round si è fermato prima del secondo turno utile |
| Fato da esiti Combat, ritorno narrativo e chiusura ordinaria | NOT_RUN |
| Apertura Land | NON ESEGUITA |

## Versione e percorso

Congelata la versione già installata: Root aa3b5c1bfbf3abdfefa559437cf380869fc2607ef2aca3818ab3198f52f704be; Edge mission_generic_ai148, UI aa6cd6040342fd018e98d5656af075f12a8e2b2f; missione6d6c216a-222d-4cba-b2fc-f3e0c199c195, pianoV9 4da7191e-689f-5aa1-b377-cfdda0da5278. Nessuna patch, migrazione, cambio prompt, configurazione o riavvio della missione durante Full85.

Master d4fe44b6-7d08-4af1-8571-ea33900ae3f0, creato02/11/2026 08:23:04UTC. Inizio → confronto → combat:fase_3 ottenuto attraverso le normali role, con iniziativa inequivoca dei PG. Il rifiuto condizionale dei PNG osservato in84 non si è ripetuto: la mappa è stata collegata e lo scontro aperto. Encounter cf0aaaf6-4841-4537-9054-8b8a77d54045, round1 37ce7bdb-75f5-4117-9396-6e54557ea68a.

Riuji ha aperto il normale pannello Scontro, selezionato il proprio personaggio, preparato Spazzata della Foglia ed Entrata dinamica attraverso le opzioni protette e confermato un movimento diagonale di2m. Le tecniche offensive non risultavano offerte a quella distanza. Il movimento non permette concatenazioni nel medesimo passo UI; è stato quindi confermato Passa e inviata una sola role di avvicinamento, senza attribuire colpi risolti. La preparazione tecnica e il movimento non vengono conteggiati come attacco riuscito. Dichiarazione70584078… presente, actor_turn declared, narrativa collegata e conservata.

Tamako ha scelto Nessun movimento → Passa → Conferma scelta → role → Invia nel proprio normale accesso Chrome. Il comando è arrivato a combat_panel_commit_v1 alle08:38:49.383UTC e ha ricevuto HTTP200 con errore applicativo operation_rejected. L’interfaccia ha conservato il testo e mostrato Rivedi le scelte. La rilettura richiesta dal pannello è stata eseguita; nessun secondo invio o nuova dichiarazione è stato tentato.


| Fato | ID | Caratteri |
|---|---|---:|
| 1 | ea8b913f-397e-4a98-84ef-c4c48c8fd401 | 668 |
| 2 | 0cf707b8-5d4d-4b4d-b320-960d6af05848 | 1505 |
| 3 | e3340c70-6562-46f3-88fa-9e3a086d24c0 | 1021 |

## Causa osservata e limite della diagnosi

Il blocco è nel commit delle scelte Combat, prima del salvataggio della dichiarazione Tamako; non è un blocco del Writer né un Fato incompleto pubblicato. Mancano request_receipt e combat_v2_event del comando rifiutato, coerentemente con il rollback interno. Non è stato osservato un errore PostgreSQL nei log pertinenti.

Il corpo vivo cattura le eccezioni e restituisce operation_rejected. La diagnostica dettagliata è limitata a uno scontro storico diverso, quindi per Full85 non conserva SQLSTATE o stack della causa originale. **La guardia o istruzione SQL che ha fallito resta NON IDENTIFICATA.** Non è provato che sia una semplice scelta scaduta: il ramo context_changed/40001 è distinto. Nessun retry casuale è stato usato per cercare un verde.

Il prossimo intervento necessario è rendere osservabile questa eccezione nel percorso corrente, conservando nel solo audit privato request ID, attore, operazione, versione e SQLSTATE/contesto tecnico sanitizzato. Occorre poi correggere la causa effettivamente rilevata e ricomporre la stessa versione DB/Edge/UI prima di ripetere il caso. Non servono nuovi controlli narrativi, riscritture dei Fati o un cambio editoriale per questo errore. Questa proposta non è stata installata da Full85.

## Qualità e limiti

Tre Fati narrativi leggibili: risposte articolate dei due PNG e passaggio concreto dallo scambio allo scontro. Foglio mantenuto nelle mani di Daichi. L’ambiente reagisce all’iniziativa (curiosi arretrano, venditrice richiama un garzone), ma il secondo Fato riprende elementi già usati nell’apertura e riassume ammissioni già espresse nello stesso testo. Giudizio editoriale parziale, senza nuove generazioni. Reazioni ai colpi, battute durante l’attacco e contrattacco non valutabili: nessun attacco è stato risolto.

## Budget, conservazione e rilascio

Nuova prova:3Count+3Generation=6HTTP,0,04349390USD prudenti. Totale258HTTP/2,39919660USDsu4, residuo1,60080340USD. Le riserve Count unknown_billable restano comprese, senza azzeramento o rimborso simulato. Nessun nuovo costo provider dopo il terzo Fato.

La prenotazione reale di Setsu nella missione sorgente è estranea al collaudo e va conservata integralmente, insieme a prima/seconda/altre prove, Full84 chiusa, risorse reali e audit.

Chiusura conservativa normale verificata: Master annullata alle08:44:17UTC, run annullata/version4, encounter annullato/closed. Ricevuta887f67bd… committed, resources_protected=true; nessun provider pendente. Tre Fati e dichiarazione Riuji conservati identici. OldcorpusSHA647c9a26…, custodia84, V9, prenotazione/Setsu e Rootaa3b invariati;246header senza drift. La cache scena resta modecombat/turncombat e il round storico raccolta_azioni: stato terminale di Master/Combat verificato, cache non riconciliata, nessuna chiusura ordinaria o missione completata attestata. Archivio normale consultabile; la sua etichetta «prova conclusa» indica l’archiviazione anche dell’annullamento, non un collaudo positivo.

La Land resta chiusa per questa versione: il collaudo completo non è passato. Inoltre i consumer pubblici Scene5 non sono ancora equivalenti a quelli Staff; nessun percorso legacy differente viene aperto come sostituto.

Evidenze originali private: /private/tmp/tus-c1266-full85-20261102. Nessun testo integrale di Fati/role, dump o credenziale incluso nel deposito Git.
