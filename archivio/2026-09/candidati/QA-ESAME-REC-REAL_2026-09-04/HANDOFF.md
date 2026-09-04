# HANDOFF · QA-ESAME-REC-REAL-001

**TASK-ID** · `QA-ESAME-REC-REAL-001`

**Scope toccato** · inventario produzione in sola lettura; cantiere QA separato; nessuna modifica al prodotto, al cantiere Narratore 4.7.1, al database o alle Edge.

**Contratti usati/modificati** · usati: REC chiusa (`role_sessions` + `role_messages`), collegamento tramite personaggio/luogo/finestra/ID del messaggio, esclusione Riuji/test/prove aperte. Modificati: nessuno.

**Decisioni prese / OPEN** · budget congelato a 2 Esami, 6 cicli, Luna/high, cap 1.024, zero retry, 60 minuti, $0,12. Il cantiere viene parcheggiato per liberare uno dei tre slot al fix `EXAM-REC-OPEN-001`; `messages_archive` resta fuori fonte.

**Prove eseguite e risultato** · produzione: 6 Esami reali conclusi e oggi Genin, di cui 5 nelle Arena/Aule del perimetro e 1 fuori; una sola catena REC byte-exact valida (`E6`). Un overlap di altro luogo è stato escluso; gli ID storici del perimetro risolvono nell'archivio tecnico. Branch QA: interrogabile, 0 prove aperte, 0 cicli non terminali, corpus sintetico 18 righe. Campagna non avviata: Luna 0/6, costo $0,00.

**Rischi o regressioni da verificare** · usare l'archivio come se fosse una REC violerebbe il perimetro; materializzare una seconda fixture senza fonte genuina renderebbe il confronto non autoritativo. Nessuna regressione introdotta.

**Passaggio richiesto al PM** · approvare e rilasciare `EXAM-REC-OPEN-001`; dopo uno smoke verde, attendere una nuova REC reale e riprendere questa campagna senza cambiare il budget.
