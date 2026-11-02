# Full86 — audit e rifiuto Combat di Tamako

Stato: audit35 e correzione36 installati e verificati; collaudo finale86B sospeso sul controllo di Chrome, stessa prova conservata. Nessuna apertura Land.

La prova diagnostica ha identificato SQLSTATE42702 nel controllo della ricevuta di `combat_panel_private.commit_master_actor(jsonb)`. La variabile locale `result` e la colonna `action_event.result` condividono il nome: il confronto `action_event.result=result` diventa ambiguo quando l’ultimo invio entra nel ramo `REGIA_FATO_PENDING`. La transazione annulla quell’invio; la dichiarazione precedente di Riuji resta acquisita. Il primo rifiuto85 non aveva dettagli diagnostici: la causa è stata osservata nella nuova riproduzione86A, sullo stesso corpo della funzione.

Audit35 è installato (migrazione20261102093538). Registra SQLSTATE e riferimenti funzione/riga nel solo ambito Staff autorizzato, senza testi delle azioni, credenziali o errori SQL integrali. Una lacuna nella raccolta degli errori anteriori all’assegnazione delle variabili è stata trovata e corretta prima dell’installazione, con revisione indipendente conservata. Il nuovo evento privato86A dimostra che la diagnostica funziona nel percorso reale.

La correzione36 installata rinomina19 occorrenze della sola variabile locale in `v_master_actor_result`; conserva la colonna qualificata, le stringhe JSON, le condizioni della ricevuta, firma, permessi e autorità del server. La composizione deve aggiornare entrambi i pin della funzione nella Root viva. Non viene cambiata la politica globale sui nomi PL/pgSQL, né eliminato il controllo che ha segnalato il problema.

La diagnostica86A è stata annullata dal normale comando Staff alle10:07UTC. Conserva3Fati, il solo invio Combat accettato di Riuji, tutte le role narrative, costi e audit; non equivale a missione conclusa. Nessuna azione rifiutata è stata reinviata. Master/run/Combat sono terminali; le cache storiche mantengono riferimenti al turno Combat e non vengono descritte come ritorno narrativo riuscito.

Il confronto iniziale della scheda esterna usava per errore una fotografia85 precedente alla baseline86. La rettifica è conservata; quel confronto non dimostrava una modifica provocata dal collaudo. Su disposizione di Antonello Setsu è escluso da attori e accessi. Le prove usano soltanto Riuji e Tamako.

Il collaudo finale86B deve partire dopo congelamento, review e installazione della candidata integrata: avvio normale → attacco effettivo di Riuji dal pannello → acquisizione dell’ultimo invio di Tamako → conseguenze server e unico Fato completo → cessazione legale → ritorno alla narrazione → conclusione ordinaria. Nessuna correzione durante questa prova può essere riclassificata come successo senza interruzioni.

Budget al termine della diagnostica:264 chiamate HTTP e2,44193910USD prudenti su4USD complessivi. Incremento86A:6HTTP e0,04274250USD; riserve delle chiamate incerte conservate. La campagna86 mantiene il proprio tetto48HTTP/1,50USD aggiuntivi e termine11:57UTC, senza azzerare il pregresso.

L’apertura Land resta condizionata al collaudo completo positivo e all’equivalenza dei consumer pubblici. Il percorso pubblico attuale non è ancora equivalente a Scene5 Staff; non basta attivare un flag o aprire una diversa missione legacy. Nessuna apertura eseguita.

Le evidenze integrali restano nel deposito privato `/private/tmp/tus-c1266-full86-20261102`; questo referto non esporta testi completi di role o Fati.

La correzione36 è stata applicata una sola volta con migrazione20261102103005. Review sorgente65090a9d e materiale c7376861 entrambe0/0/0. Root8604cc14, corpoDDL69b96309/prosrcd8d7e7e5;254header coerenti e253altre funzioni immutate, audit35a91preservato. Nessuna modifica a schema, permessi, vincoli, Edge o client. La preservazione stretta esclude il PG esterno non utilizzato e le cache mutabili contexts/offers delle prove chiuse; non vengono dichiarate immutate per intero.

La nuova prova86B è partita10:32:32UTC dal normale selettore Staff con i soli Riuji e Tamako. Masterd255af26-07c3-40b7-bc66-cf10bb599eba:3Fati pubblicati,4role narrative acquisite una volta, testi esatti rispetto ai file inseriti con il solo prefisso standard del luogo. È stata raggiunta legalmente la fase3 con arena10×10 e i due PNG. Nessun movimento o attacco è stato confermato: il collaudo deve ancora verificare l’ACK dell’ultimo invioCombat, il Fato meccanico, il ritorno e la conclusione.

Durante il controllo di Tamako, l’automazione nativa ha restituito riferimenti di accessibilità obsoleti e nessuna finestra; dopo una normale rilettura la pagina è rimasta bianca. Il collegamento diretto della stessa scheda utente segnala Debugger unattached. Non si attribuisce questa indisponibilità al motore Combat senza ulteriori prove. Non sono state reinviate azioni accettate o eseguite correzioni nella run. La stessa missione resta conservata in attesa di recuperare il normale browser.

Ultimo costo autorevole10:48:38UTC:270HTTP/2,48421930USDsu4; intero86 incldiagnostica12HTTP/0,08502270USD. Le riserve delle chiamate incerte rimangono registrate. I4SQL pubblicabili sono estratti verificati dei corpi, non installer autonomi; installer completi, Root e testi privati restano nel deposito privato. PUBLIC_SOURCE_CHECK c476a580attesta i corpi e il terminatore SQL della recovery35 distinto dal corpo identico.

Il postflight di sospensione delle11:01:53UTC conferma Master, fase3, scena, lavori,3Fati,4role e round identici alla fotografia d’ingresso Combat. Zero dichiarazioni, zero ricevute di commit dal pannello, zero lavori o provider pendenti. Root/fullrow,254header e custodia protetta b1b823 invariati. Budget270HTTP/2,48421930USD, residuo1,51578070USD; quota86 residua36HTTP(18Count+18Generation), termine11:57UTC immutato. La prova resta aperta e riprendibile: non è conclusa né certificata positiva. Due errori42703 nei nomi della sola query diagnostica readonly sono registrati e corretti sul catalogo; non sono errori del gameplay né mutazioni durante il collaudo.

Deposito verificato a808165702b1646f134af01a2cad258c16fcfaa1:16percorsi autorizzati,16blob integralmente riletti identici, confronto senza file estranei/rimozioni, aggiornamento CAS e testa remota verificati. Nessun asset applicativo, Root integrale, testo privato di role/Fati o output provider nel deposito. Questo caricamento non attesta il completamento del collaudo o l’apertura pubblica.
