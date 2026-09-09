# CLAN-RACCORDO-RELEASE-PREP-001 · preparazione consegnata

**Recovery operativa locale PASS; rilascio in attesa di review mirata del recovery e gate nominativo del PM/Antonello.** QA-CLAN, 09/09/2026. Questa consegna prepara il rilascio delle sole tre funzioni del raccordo. La review del candidato di prodotto è già 0/0/0: nessun suo file, caso o referto viene riaperto.

## Scope, contratti e versione

INSTALL immutabile SHA-256 `9dc6fa7fd2f0520e9e3779a600d90587d2151d389ae00a839f85bec0b6619089`.

| Funzione | Prima | Dopo install | Dopo recovery |
|---|---|---|---|
| combat_consumer_private.dispatch_narrative(text) | d9d399ed945714805a0c9d12fb708595 | 24fc74582116842cc0bdc86f5ef2378f | baseline esatta |
| combat_panel_private.narrative_ordinary_context(uuid) | 943c604e222c9e0e3a662249ee743f96 | ec6a66b6599cdfb3d80aea6c12c9dd43 | baseline esatta |
| combat_consumer_private.narrative_declaration_supported(uuid) | assente | 5d92acb102cf08fb6407c25efb6032b0 | 7ab7828cb47141e34a020b31ce9bd11d, sempre false |

Le impronte in tabella sono MD5 di pg_get_functiondef, non SHA dei file. Owner postgres, SECURITY DEFINER, search_path vuoto; ACL `{postgres=X/postgres}`. Nessun nuovo accesso anon, authenticated o service_role. Le nove funzioni esistenti fotografate in produzione alle 15:24:47 UTC corrispondono alle tre baseline documentali, comprese le dipendenze di fatti, autorizzazione, offerta e dedicati. La nuova helper è assente. I tre corpi installati sono stati acquisiti sul PostgreSQL reale locale, non dedotti dai nomi dei file.

## Esito e differenze dell'ambiente

Quattro submission Docker su quattro disponibili: lettura/install annullata sul banco sorgente; creazione copia sintetica separata; INSTALL COMMIT seguito da RECOVERY COMMIT sulla copia; postflight in nuova connessione su entrambi i DB. Tre submission readonly produzione su tre; la seconda conteneva due SELECT e il risultato runtime non è stato restituito, quindi la terza lo acquisisce insieme al RLS. Nessuna chiamata provider, token, gameplay, browser, deploy o produzione mutante. L'intera preparazione rimane nella finestra di 15 minuti.

Copia conservata: `tus_clan_release_recovery_001` nel container `tus_ordinary_compose_qa_db`; nessun reset o cancellazione. Banco sorgente `tus_clan_continuation_qa` immutato e con helper assente. Copia dopo recovery: due definizioni originali ripristinate esattamente, tutte le funzioni preesistenti/ACL/owner identiche; helper aggiunta, privata, sempre false. Storico sintetico 9 sessioni chiuse e 0 aperte; impronte storico e personaggi identiche prima/dopo. Il digest delle funzioni esclude intenzionalmente solo la helper nuova, controllata a parte. Non è un confronto di ogni riga di ogni tabella. SQL modifica soltanto definizioni/permessi delle tre funzioni; nessuna funzione di gioco viene eseguita.

## Rischi Auth, RLS, Edge e decisione ambiente

Auth/API non cambiano: tutte e tre le funzioni restano private a postgres; roster e autorizzazione restano nelle dipendenze esistenti. Cinque tabelle pertinenti hanno RLS acceso in produzione, ma questa lettura non certifica policy complete o login reali. La helper ammette le utility note soltanto nel percorso ordinary con location is_test, policy staff_test_no_persistent_resources_v1, fase resolved e nessun valore persistente scritto; attacco e Passa dedicati restano ai validatori precedenti. Il controllo delle risorse reali nel percorso UI resta una prova live separata.

Il raccordo riusa dispatch, payload HTTP, provider ed Edge esistenti; nessuna migrazione RLS, Auth o servizio gestito. Docker ha coperto instradamento e contenuti contrattuali, con adapter HTTP senza rete. Non ha provato risposta effettiva dell'Edge, autenticazione, costo provider, resa cinematografica o UI delle due Test Room. Questi rischi d'integrazione possono essere verificati solo nel percorso Staff protetto già autorizzato, con audit e risorse simulate. Per il solo raccordo, il rischio residuo di integrazione è coperto dallo smoke autentico e protetto nella Staff corrente: una creazione Clone nativa e una pubblicazione del Fato sul percorso ordinario, senza presa garantita né retry. Non richiede branch temporaneo, nuove RPC pubbliche, modifiche RLS o Edge. Questa valutazione presuppone il percorso protetto attestato dal PM e non estende il risultato a ogni esito di liberazione o a una qualità narrativa universale. Se emerge un difetto concreto di isolamento o accessibilità, stop dello smoke; non si usa produzione per fault injection.

## Gate operativo prima dell'apply

1. Review indipendente mirata di RECOVERY.sql, piano e prove: separata dalla review del raccordo già conclusa. Nessun finding inventato sui casi congelati.
2. PM riconferma preflight readonly immediatamente prima del rilascio: le nove impronte e ACL, helper assente, runtime/gate e assenza di drift; identifica eventuali scene/report Staff pendenti che il nuovo criterio potrebbe rendere eleggibili, senza leggerne testi privati né cancellare storico. Drift = stop.
3. Gate nominativo per il singolo apply di INSTALL, con recovery identificata e finestra Staff concordata. Alle 15:25:57 UTC enabled, provider_enabled, staff_test_enabled e staff_test_provider_enabled risultano tutti true: **l'apply non è inerte**. Il nuovo criterio potrebbe attivare anche utility già in attesa. Non cambiare flag implicitamente; un'eventuale sospensione richiede un mandato separato e controllo dell'impatto sulle altre funzioni.
4. Postflight readonly delle tre impronte candidate/ACL. Smoke nominativo sul sito in Staff Test Room protetta: una creazione Clone e una pubblicazione del Fato sul percorso ordinario, nessuna presa garantita e nessun retry; budget provider e chiamate definito dal PM, audit, chiusura della sola prova creata e controllo risorse/assenza residui. Le capacità della Test Room utenti devono essere dichiarate secondo il suo perimetro: questa candidata abilita utility nel percorso Staff e non certifica parità o disponibilità utenti.
5. Nessuna apertura generale implicita. Smoke positivo e gate separato prima di dichiarare qualsiasi ampliamento. “In uso” resta dichiarazione di Antonello.

## Recovery operativo e limite concreto

Con mandato di recovery e accertato che l'install candidata è quella attiva, eseguire una sola volta CLAN_CONTINUATION_RECOVERY.sql. Il file controlla impronte/owner/ACL candidate prima di ogni mutazione; timeout lock 5 secondi e statement 20 secondi, transazione unica. Ripristina i due corpi dalle baseline esistenti e rende la nuova helper sempre false, senza DROP; revoca esplicitamente i quattro ruoli non autorizzati e concede solo postgres. Le verifiche di corpi originali, ACL e helper inerte precedono COMMIT. Errore o drift: stop, niente forzature. Dopo COMMIT una lettura in nuova connessione confronta i valori attesi della tabella e le risorse pertinenti al collaudo.

Recovery torna alla selezione/contenuto precedente per le nuove esecuzioni; non annulla richieste HTTP già accodate, narratori in corso, messaggi o storico. Non promette il ritiro di effetti già prodotti: il PM deve valutare audit e richieste pendenti senza cancellazioni e gestire l'eventuale fermo con autorizzazione distinta. La helper resta presente e inerte: INSTALL originale rifiuta la riapplicazione perché la sua guardia richiede assenza; un successivo rilascio richiede una migrazione avanti distinta e approvata, non un DROP per aggirare la guardia.

## Passaggio richiesto al PM

Cinque nuovi file congelati; contratti di prodotto e referti QA precedenti immutati. Review mirata recovery, poi scelta esplicita del gate sopra. Preparazione riuscita, nessun apply/deploy/enable effettuato. La review di prodotto 0/0/0 e il PASS locale del raccordo non vengono estesi a Clone/liberazione in ogni esito o alla qualità del narratore live.
