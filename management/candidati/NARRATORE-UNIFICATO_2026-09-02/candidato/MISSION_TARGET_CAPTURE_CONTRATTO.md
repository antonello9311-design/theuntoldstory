# MISSION-EXAM-TARGET-CAPTURE-001 — candidata non applicata

Mandato: rendere coerente il risultato con l’azione giocata nel goal notturno. Correzione generale di una cattura regex, distinta dalla proiezione delle copie.

Difetto: `_esame_zona_dichiarata` racchiude il prefisso di mira in un gruppo catturante esterno ma ne contiene anche uno interno. Il codice concatena m[1] e m[2] per localizzare prefisso+zona; m[2] contiene invece un secondo prefisso. La posizione risulta zero, e un precedente bersaglio espresso con «dell’altro» prevale indebitamente. Nella fonte reale1545caratteri la gamba prevale sul volto citato dopo. Non è un difetto del modello e non si corregge aggiungendo sinonimi al prompt.

Delta: rendere non catturante il gruppo interno di v_mir, aggiungendo soltanto `?:`. Gli indici tornano quelli attesi: m[1] prefisso, m[2] zona. Dizionario, ordine delle preferenze, classificazione delle zone, lateralità, fallbackRNG e valori di gioco restano identici. Il parser continua a preferire l’ultima mira esplicita: non viene trasformato in un riconoscitore generale delle azioni delle singole copie. Non ripara referti o dati storici.

Stessa firma, IMMUTABLE, owner e ACLpostgres/service_role. Nessuna nuova funzione o vincolo. La zona interpretata in nuove dichiarazioni può cambiare quando prima il bug favoriva una citazione precedente: è l’effetto atteso; non si cambiano danni, tiri o mosse.

Budget: quattro gruppi PostgreSQL locale reale,0provider,20min. Preflight locale con identiche fonti sintetiche sulla baseline, poi matrice candidata: ultima mira esplicita contro possesso precedente, bersaglio unico/lateralità, fallback/non-mira/null, ACL e delta di soli due caratteri. Nessuna role completa o dato PG copiato nel banco. Unico passaggio di review indipendente, eventuale unica correzione aggregata e controverifica finale; nessuna nuova famiglia di esempi durante review. Rilascio dopo gate, insieme all’aggregata prima dei campioni di conferma.
