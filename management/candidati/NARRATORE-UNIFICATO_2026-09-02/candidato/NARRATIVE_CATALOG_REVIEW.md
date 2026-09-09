# Review indipendente · cataloghi narrativi

**VERDETTO: PASS · P0/P1/P2 = 0/0/0.**

NARRATIVE-CATALOG-REVIEW-001 · DB-CORE-REVIEW · 09/09/2026. Unico passaggio iniziale sulla candidata NARRATIVE-CATALOG-ALIGN-CANDIDATE-001. Nessuna correzione necessaria nello scope esaminato. Il verdetto qualifica il pacchetto editoriale e le evidenze locali; non autorizza apply o attesta uno smoke live. La candidata NARRATIVE_TECH già verde non è stata rimessa in revisione.

## Perimetro e integrità

Esaminati i sei file NARRATIVE_CATALOG_INSTALL.sql, RECOVERY.sql, PLAN.md, QA.json, MANIFEST.json e RUNNER.py, con ALIGNMENT.md/JSON come fonti narrative. Sola lettura statica, confronto dei contenuti e delle impronte: nessuna esecuzione del runner, nuova prova, SQL, provider, browser o modifica applicativa. Scritti soltanto referto e manifest tramite guard.

Le cinque voci di output e le due fonti nel manifest coincidono per byte e SHA-256: **7/7**. INSTALL, RECOVERY e RUNNER coincidono con il freeze precedente alla campagna: **3/3**. Le sei stringhe SQL già eseguite sono state ricostruite in memoria dai contenuti congelati per confrontarne le impronte, senza eseguirle: **6/6 SHA-256 coincidono con QA.json**. Le immagini iniziali degli script coincidono con le righe della baseline del runner. I testi prima/dopo coincidono con i campi assegnati nella proposta ALIGNMENT; gli altri campi non cambiano.

Manifest della candidata osservato: SHA-256 `56248d2c33beaada3785e870e5411eae36a9f8d0644b2e06723808dd710b5a84`. Il manifest di questa review fotografa tutti gli otto input e il referto, senza autoreferenza circolare.

## Riscontri statici

- **Scope:** soltanto `clan_techniques.description` del Clone `617484d6-af7b-41c3-a37f-615b22818421` e `jutsu.effect` della Moltiplicazione `c6e31b7b-38fe-4b4f-b3c7-05f3e922d193`. Nessuna nuova funzione, tabella, colonna, ACL o vincolo permanente. Immutati costi, requisiti, formule, flag, `danno_effetto`, `limits` e ogni altra colonna.
- **Preimage completo:** INSTALL e RECOVERY, righe 13–20, rifiutano trigger applicativi non previsti, bloccano entrambe le righe `FOR UPDATE` nell'ordine Clan→jutsu e confrontano entrambe le immagini integrali prima del primo UPDATE. Assenza o drift di una riga fanno fallire il blocco. I lock proteggono dal successivo aggiornamento concorrente ordinario delle stesse righe.
- **Atomicità:** righe 21–30, ciascun UPDATE usa UUID e vecchio testo, modifica soltanto il campo assegnato e richiede `ROW_COUNT=1`; il postflight confronta entrambe le righe intere con i target. Tutto avviene in una transazione, senza intercettazione degli errori nel pacchetto: nessun COMMIT parziale. Timeout di lock e statement limitano l'attesa; nessun force o retry.
- **Recovery:** le immagini complete sono l'inverso esatto dell'installazione. Ripristina solo i due campi quando entrambe le righe corrispondono ancora agli after; un cambiamento intervenuto anche su altra colonna viene rifiutato. Non sovrascrive revisioni successive, snapshot, messaggi, history o dati PG. Secondo apply intenzionalmente rifiutato.
- **Testi:** Clone solido di sabbia e conclusione in granelli; Moltiplicazione illusoria e nuvoletta bianca. Nessuna nuova fine tecnica dedotta dal danno. I cinque metri sono spiegati nella proposta come disposizione delle figure, non nuovo budget di movimento del PG. Il catalogo resta una fonte di dati narrativi, non autorità meccanica o istruzione al modello.

## Quattro gruppi congelati

Owner: PostgreSQL Docker 17.6.1.136, database nuovo `narrative_catalog_alignment_001`; **4/4 gruppi PASS, 6/6 invocazioni SQL, 0,511 secondi, zero provider**. La fixture deriva dalla baseline pubblica delle 18:42:17 UTC: due tabelle, 78 colonne, 14 vincoli e zero trigger applicativi. Nessun attore o dato PG. Una riga prerequisito sintetica soddisfa la FK autoreferente del Clone senza qualificare la sua meccanica.

| Gruppo | Evidenza verificata | Limite |
|---|---|---|
| G1 | Blocco candidato, confronto integrale con entrambi gli after, ROLLBACK | Qualifica i due testi e la preservazione delle altre colonne |
| G2 | Drift sulla seconda riga; richiesta esatta dell'errore `catalog_baseline_drift`; confronto di prima riga originaria e seconda stale; ROLLBACK | L'ordine dei controlli prima delle scritture è verificato anche staticamente |
| G3 | Primo blocco applicato, secondo rifiutato; entrambi gli after conservati; ROLLBACK | Nessuna seconda applicazione silenziosa |
| G4 | INSTALL completo con COMMIT, verifica after; RECOVERY completa con COMMIT, verifica before | Due vere transazioni committate nella stessa connessione psql, non una prova da nuova connessione |

I log G4 mostrano entrambi i COMMIT e le verifiche concluse senza errore. Il recupero non è il semplice ROLLBACK dell'installazione. Nessuna gara fra connessioni è stata collaudata: QA e manifest lo dichiarano. La valutazione del blocco delle righe comprende la lettura statica dei lock.

## Finding, limiti e gate

**Nessun finding P0, P1 o P2 entro il mandato.** Nessuna correzione aggregata richiesta.

PLAN e manifest distinguono correttamente questa integrazione dalla revisione004 completa: la conclusione desiderata in `danno_effetto` del Clone non viene riscritta e Diversivo/Copertura/Assalto004 non sono implementati. Il loro completamento non viene attribuito al verde editoriale.

La baseline live è quella consegnata dall'owner, non una nuova fotografia prodotta dal reviewer. Il banco esegue SQL come postgres e non certifica Auth/RLS via API, Edge, UI, provider, consumer live o qualità narrativa. Riuji e scena esistente sono esclusi; la porta ordinary testperfunzioni+avversario sintetico resta un'estensione distinta e nessuno smoke è attestato.

Il catalogo è condiviso: un futuro aggiornamento dei testi non è un apply inerte riservato allo Staff. Restano i gate previsti dal piano: riconciliare hash, interi preimage e metadata/trigger correnti, acquisire la risorsa di produzione ed escludere DDL concorrente, poi singolo apply nominativamente autorizzato. Il confronto dei dati non equivale a certificare modifiche arbitrarie dello schema o servizi esterni. Anche la recovery conserva il proprio gate. Non sono richiesti nuovi casi o campagne da questa review.

**Consegna al PM:** review iniziale conclusa verde. Procedere soltanto ai passi di rilascio previsti e autorizzati; nessuna modifica al precedente ciclo IA o nuova prova implicita.
