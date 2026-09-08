# COMMON-ELIGIBILITY-MARIONETTA-019 · review indipendente

08/09/2026, Europe/Rome. **P0/P1/P2 = 0/0/0; nessun finding.** Unico passaggio sul solo predicato di integrità `eligibility_release_assert`. Nessuna review del runtime Sabaku o dei pannelli e nessuna riapertura di altri cicli.

## Perimetro e integrità

Esaminati esclusivamente contratto, candidato, baseline del controllo, prova del successore e validazione indicati dal PM. I cinque file non sono cambiati durante la review. Nessun SQL eseguito, installazione, mutazione, provider, accesso live o nuova campagna del reviewer: soltanto letture, confronto e ricalcolo di hash sulle stringhe sorgenti conservate. Questo è l'unico file scritto; risultava assente all'ingresso e prima della scrittura.

- `candidato/12_ELIGIBILITY_SUCCESSOR.sql`: SHA256 `030e001644278e25ed17600d43b7c103fc0ea0e9805774f5939a5301124bd217`.
- `baseline/clan_innata_private.eligibility_release_assert.sql`: SHA256 `e184778b2cbbac9ef1219181b3637034a242fad0c520526b7c97ef89554760d6`.
- `baseline/ELIGIBILITY_SUCCESSOR.json`: SHA256 `0b6cee023e8d77bb15f58c88d18286060a070583cba8792a26c2b0ca099f9650`.
- `referti/ELIGIBILITY_VALIDATION.json`: SHA256 `e977bc72618cdf74c63da1f48f9f205d1920a3038f19dc5da7eee198de37d7f1`.
- `referti/ELIGIBILITY_CONTRATTO.md`: SHA256 `33a3b346a9356b23357a946a70a70a7a8ed930e47c1a059fe09395fa5d59c45d`.

## Valutazione

**Successore esclusivo.** Le righe 20–26 del candidato cercano qualsiasi riga con nome o versione del rilascio Marionetta: il conteggio deve essere esattamente uno e quella riga deve avere insieme versione `20260907084651`, nome `marionetta_ordinary_staff_001`, un solo statement e SHA256 `3d3b6643c1b513728ee8e2366fbde983aa374cf9d330f0976d71c5f122318f17`. Duplicati, nome/versione discordanti o contenuto diverso non autorizzano il ramo. Con rilascio riconosciuto vengono richiesti esattamente i due hash successori; in sua assenza vengono richiesti gli hash precedenti. Non esiste un'accettazione indiscriminata di entrambe le versioni.

**Guardie conservate.** Il confronto tra baseline e definizione candidata mostra soltanto il riconoscimento del rilascio e i due hash condizionali di snapshot/round_options alle righe 41 e 43. Le altre tre definizioni, ACL, owner, SECURITY DEFINER, search_path delle cinque porte, namespace, registro Eligibility e `character_elementi` restano controllati esattamente come prima. Il preflight rifiuta una definizione installata del controllo diversa dalla baseline. La sostituzione mantiene firma, STABLE, SECURITY DEFINER e search_path della funzione esistente; non contiene GRANT/REVOKE, cambio owner, DML o modifica delle funzioni sorvegliate. Owner e ACL effettivi della funzione sostituita restano oggetto del pre/postflight nominativo già previsto dal contratto.

**Prova di derivazione verificabile.** Ricalcolati gli hash delle due `current_definition` nel JSON: corrispondono agli hash successori richiesti dal candidato. Rimuovendo dalle sole stringhe sorgenti gli innesti Marionetta descritti, gli hash tornano esattamente `323d6dd5…0046f87` per snapshot e `3be90b0d…88f6129` per round_options, uguali ai pin della baseline. La prova non si limita quindi al flag `inverse_matches` del referto. Nessun corpo applicativo è stato modificato o eseguito per questo confronto.

## Evidenze, limiti e passaggio al PM

Il difetto live e i metadati effettivi sono attestati dalle letture del PM conservate nei due JSON. La validazione documenta compilazione PostgreSQL 17 e valutazione nominale del corpo candidato sui metadati reali in `BEGIN READ ONLY`, senza installare la funzione e senza falsificare il registro locale. Queste evidenze, insieme al confronto statico del piccolo delta, sono adeguate a questo solo predicato di metadati. Non attestano gameplay, Auth, runtime Sabaku o percorsi negativi eseguiti sperimentalmente; tali prove non sono state richieste né inventate.

Non emerge un rischio concreto aggiuntivo nel perimetro esaminato. Rimane necessario il preflight già previsto contro eventuale drift successivo delle sorgenti/metadati, seguito dall'eventuale singolo apply nominativamente autorizzato, verifica della definizione e chiamata readonly al parent `runtime_release_assert`. Il parent può continuare a rifiutare altri drift: questo aggiornamento corregge soltanto il successore Eligibility identificato e non li aggira.

**Review conclusa 0/0/0; nessuna correzione aggregata richiesta.** Il reviewer non ha applicato modifiche, attivato gate o aperto sessioni. Il passaggio operativo resta al PM nel mandato esistente.
