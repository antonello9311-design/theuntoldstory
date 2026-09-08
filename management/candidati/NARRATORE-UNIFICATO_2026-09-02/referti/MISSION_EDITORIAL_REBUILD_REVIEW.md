# MISSION-EXAM-EDITORIAL-REBUILD-001 — review indipendente

**Controverifica finale VERDE: 0 P0 / 0 P1 / 0 P2.** Unico passaggio aggregato e unica controverifica dell'08/09/2026 completati. Il primo passaggio aveva un solo P2, ora risolto. Nessun test, provider, SQL eseguito, apply/deploy o modifica ai sorgenti dell'owner da parte del reviewer; nessun nuovo esempio o finding aggiunto nella controverifica.

## R1 — P2: il campo appellativo conserva prescrizioni che le nuove schede eliminano

Nel record Hazuki di `candidato/db/MISSION_EXAM_PNG_EDITORIAL.json`, `after.appellativo` conserva «tu, e non ti chiama per nome finché non l'hai sorpresa», mentre `after.voce.se_le_parlano` prescrive esplicitamente di rispondere senza soglie obbligatorie per usare il nome. La nuova scheda contiene quindi entrambe le istruzioni opposte. Lo stesso campo, rimasto escluso dalla riscrittura delle sei schede, conserva gesti prescritti come il cenno prima di cominciare per Kotoha e «dopo un cenno» per Sota.

Il mandato richiede schede prive di limiti di battuta e sequenze obbligatorie, conservando identità e inclinazioni. Riformulare il campo appellativo delle schede interessate come registro di relazione, senza soglie o gesti vincolanti, mantenendo eventuale uso del «tu». Aggiornare insieme JSON e payload SQL corrispondente. Questo è un unico problema di campo residuo: non serve una nuova architettura o un nuovo banco di esempi. Il solo prompt che dichiara le schede non prescrittive non elimina la contraddizione interna richiesta dal mandato.

Controverifica R1: **risolto**. Tutti e sei gli appellativi descrivono ora registro e relazione senza divieti temporali, soglie, cenni o silenzi prescritti. Verificati integralmente JSON/SQL identici per le sei righe e tutti i before uguali alle persona nell'archivio `_precedenti/2026-09-08_editoriale20_v16/png.json`. Nessuna alterazione delle precondizioni rimasta nella candidata finale.

## Perimetro e riscontri senza finding

Letti i due prompt completi, le sei persona prima/dopo, wrapper SQL e test Node aggiornato. I prompt contengono soltanto modifiche testuali/versioni rispetto a `_precedenti/2026-09-08_editoriale20_v16/`, oltre a whitespace finale non funzionale. CYCLE005 conserva fonti separate, autorità server, ruoli e alternative; la role non certifica risultati e lo storico non prevale sul presente. Originale/copie/bersaglio devono essere attestati; riconoscimento non dedotto dalla sola dissoluzione. Non vengono aggiunti filtri, giudice, retry, blocchi di lunghezza o variazioni a JSON, token e trasporto. OPENING003 preserva contratto OPENING001, via del Sensei e iniziativa autorizzata.

Il seed comprende esattamente sei agent_id distinti. JSON rows e JSON incorporato nel SQL corrispondono. Il wrapper aggiorna soltanto ai_agents.persona, con guardie su esami aperti, associazione nome/agent_id al profilo Esame, kind png_trama e confronto before/after sotto lock. Ogni errore annulla l'intero DO; il reapply dello stato after è inerte. Il postflight interno confronta tutte e sei le persona. Nessuna riga eliminata, nessun campo provider/meccanico o ACL modificato dal SQL.

Aspetto, genere, grado, stile, tratti e preferenze distintive rimangono conservati. Bio, voce, reazioni, condotta, firme fisiche e tattica sono riscritte come inclinazioni e non fatti già avvenuti; frasi_tipiche diventa lista vuota. La riservatezza può rimanere tratto del carattere senza imporre una quota di parole. I venti referti e audit esistenti non sono destinatari della migrazione.

## Pin del primo passaggio e gate

- exam-cycle.mjs: 11557 byte, `b35458e4481367604ebb8d8c72d1d087fb6a87b6ff643232e93064863e1df3b6`.
- exam-opening.mjs: 8757 byte, `906712eea8cddc10d9525c1f9adbfa14969fcb6feb8cb4f6e9f76940d30bebd8`.
- PNG_EDITORIAL.json: 76377 byte, `ca00a2cffa57f5d10182acf9a9401bd448134616d72ea3ae2ba87a8ec771ebcf`.
- PNG_EDITORIAL.sql: 67360 byte, `d186a1df82cacc06fdfb3e505e7ef7adabe4d97d7091014d1e1f8a896e943c97`.

Pin finali dei file corretti: PNG_EDITORIAL.json 76599 byte `4963e7672c52b652a938a160400d45fe0276c5a624213a6b250ca0d09d79d278`; PNG_EDITORIAL.sql 67581 byte `57cc9d6716c71a24737c4a435470f2968767f72fcc059f096a05d74f2ac7d353`. I due prompt conservano i pin del primo passaggio sopra indicati.

QA conclusiva riferita dall'owner: PostgreSQL 17 reale nella copia esclusiva tus_exam_editorial_rebuild_001, **4/4 PASS** (sei persona esatte e altre colonne/profili invariati; idempotenza; drift tardivo con rollback integrale; binding profilo errato con rollback integrale); Node **3/3 PASS**, circa 390 ms, sintassi 19 moduli. Nessun provider o verifica dinamica aggiuntiva del reviewer.

Limiti e preparazione dichiarati: il seed sintetico aveva inizialmente somma statistiche 80 anziché 140, corretta prima dei gruppi. Durante il confezionamento una sostituzione JSON aveva toccato before anziché after; il drift locale l'ha intercettata. L'owner ha corretto la serializzazione e confrontato integralmente le sei righe, prima del risultato finale 4/4. La controverifica indipendente conferma ora i before esatti e JSON/SQL concordi. Nessun incidente di produzione o riscrittura dei venti campioni è implicato da questi errori locali.

Il verde tecnico rimuove il finding della review; non sostituisce il gate nominativo né il preflight readonly delle sei righe e delle invarianti prima dell'apply. Nessuna nuova prova provider richiesta: la review dei prompt e i test sintetici non certificano qualità della prosa o elaborazione interna del modello.
