# CLAN-UTILITY-QUALIFICA-001 · controverifica indipendente finale

**Verdetto effettivo: 0 P0 / 1 P1 / 1 P2 — QUALIFICA ROSSA TERMINALE.** Reviewer DB-CORE-REVIEW, incarico CLAN-UTILITY-CONTROVERIFICA-001, 09/09/2026. Review iniziale 0 P0 / 2 P1 / 1 P2; unica correzione aggregata e unica controverifica finale consumate. Nessuna ulteriore patch, query diagnostica, campagna, retry o subreview in questo ciclo.

## Mandato e identità

Il PM ha esteso esplicitamente il mandato di qualifica ai soli helper/fixture e diagnostica per l’unica aggregata CQ01/CQ02/CQ03. La controverifica valuta la medesima candidata; non riapre il precedente terminale né avvia un nuovo ciclo. INSTALL resta invariata, SHA-256 9dc6fa7fd2f0520e9e3779a600d90587d2151d389ae00a839f85bec0b6619089. Codice applicativo, produzione, provider, browser e upload esclusi. Autorizzazione ricevuta dal PM e registrata nella specifica CLAN-UTILITY-CONTROVERIFICA-001.

Gli otto originali del terminale antecedente e i quattro originali della qualifica iniziale sono preservati nelle due cartelle _precedenti già indicate dal manifest. I risultati iniziali 14 SQL / 10 PASS / 4 FAIL e il referto iniziale 0/2/1 non sono convertiti in PASS.

## Esito dei finding originali

| Finding | Controverifica | Residuo |
|---|---|---|
| CQ01 · P1 | L’aggregata elimina staticamente la diminuzione tramite greatest. La finale resta però respinta: P0001, characters_guard riga 86, clone_case riga 6; liberazione richiama lo stesso setup. | **APERTO P1:** G02/G03 non raggiungono il comportamento da qualificare. Non attribuire il nuovo errore alla precedente diminuzione né inventare il motivo del RAISE; nessun difetto prodotto dimostrato. |
| CQ02 · P2 | La carenza diagnostica è corretta: SQLSTATE P0002, hand_case riga 10 localizzano il SELECT STRICT dell’offerta «Colpo a mani nude», senza risultati. | **RESIDUO P2 DI COPERTURA:** la regressione mano resta non qualificata. È chiusa la perdita di posizione diagnostica; resta aperta la causa dell’assenza dell’offerta. Nessuna nuova casistica aggiunta. |
| CQ03 · P1 iniziale | URL sintetico conforme al CHECK e adattatore senza rete allineati. G07 PASS con asserzioni su gate, unico trasporto accodato e report meccanico immutato. | **CHIUSO** nel perimetro locale provato; non certifica Edge/provider remoti né i casi Clone/liberazione bloccati. |

Il conteggio finale 0/1/1 esprime i residui della qualifica; non significa che sia stato dimostrato un difetto applicativo live. Una diagnostica corretta non converte un percorso non esercitato in verde.

## Prove e integrità delle evidenze

La campagna finale owner contiene **15 submission SQL, 12 PASS / 3 FAIL, 7,444 secondi di esecuzione complessivi, 0 provider e 0 token**. Include la lettura preparatoria delle 13:34:19 UTC; le altre 14 submission appartengono alla finale avviata alle 13:36:07 UTC. Il tempo di esecuzione riportato non è la durata della finestra di preparazione; le evidenze temporali restano entro il budget dichiarato 16 SQL / 35 minuti.

G01, G04, G05, G07 e G08 PASS; G02/G03 bloccati nel setup; G06 parziale (marionetta e Passa PASS, mano FAIL). Gli otto gruppi e i nove sottocasi restano quelli assegnati; nel runner l’unica modifica al corpo dei sottocasi è l’URL QA di G07.

La controverifica indipendente ha letto differenze di runner/helper, JSON finale e consegna; controllato sintassi Python senza eseguirlo; verificato prima dell’aggiornamento **9/9 file del manifest e 12/12 originali preservati**, dimensioni e SHA coincidenti. Nessun SQL, test dinamico o accesso al database eseguito dal reviewer. Il JSON finale è evidenza prodotta dall’owner: viene controllata, non riprodotta.

Il postflight registrato è positivo: nove sessioni storiche chiuse, zero aperte; impronte storico bcb083549e12d169fc0a9a98d1b5ed57, personaggi 950de62423e9d1fa3f92b0d06d5f043f e funzioni/ACL 125b8b3de9933d39d2d17e82481e5c3f identiche prima/dopo; helper e candidata assenti. Le sequenze possono avanzare con rollback e non sono state resettate.

## Limiti e consegna al PM

Auth locale e pubblicazione sintetiche, trasporto sostituito da coda senza rete; nessuna attestazione di Edge, provider, UI, disponibilità nelle stanze o stato corrente della produzione. Le baseline del 09/09 rimangono datate. Il checkpoint Staff precedente non è aggiornato dalla qualifica e Clone non è stato inviato live da questo ciclo.

**Il ciclo termina ROSSO.** Nessun apply/deploy/enable, pubblicazione o collaudo Clone è autorizzato dai PASS parziali. Il PM recepisce i residui CQ01/CQ02 nei documenti centrali e decide eventuali interventi futuri distinti; questa consegna non assegna ulteriori prove o patch. Possono proseguire solo rami indipendenti già autorizzati. File locali; caricamento rinviato da Antonello.

Il manifest di candidata inventaria fonti, JSON owner, consegna e questo referto, escludendo se stesso e il manifest del reviewer. Il manifest del reviewer include anche il manifest di candidata ed esclude solo se stesso: nessun ciclo di impronte.
