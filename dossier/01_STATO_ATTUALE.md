# 01 · STATO ATTUALE — fotografia consolidata del 10/09/2026

> Si riscrive in posto. Il diario precedente è in `storico/01_STATO_ATTUALE_diario_fino_20260902.md`. Stato operativo e limiti delle prove restano nelle schede d'area; questa fotografia non certifica tutti i percorsi del gioco.

## Ultima fotografia generale del database (09/09, non ripetuta)
Lettura aggregata di produzione del **09/09/2026, 11:03:23 UTC**: **85 profili, 78 personaggi, 355 tecniche di catalogo, 9 jutsu, 21 missioni, 7 lezioni, 12 abilità dei personaggi, 0 richieste premio e 52 emblemi**. Le righe del catalogo non attestano tecniche abilitate o collaudate; le righe emblema non attestano immagini caricate.

Successiva lettura della piattaforma alle **11:32:43UTC**: **233 tabelle base e805 funzioni in `public`, di cui680 SECURITY DEFINER;495 migrazioni**, ultima `20260909112705`. Edge e cron restano quelli della lettura delle11:03:23UTC: **15 Edge distribuite ACTIVE; 13 cron, 12 attivi**, con `pilot-scadenza` spento. Verificate `combat_narratore_ai` v23, `mission_narratore_ai` v18 ed `exam_genin_ai` v139. Versione distribuita e percorso realmente abilitato sono verifiche distinte. Non è stato rieseguito un audit generale di permessi o sicurezza.

I dati di utilizzo del 01–02/09 sono storici: non stabiliscono quanti giocatori siano attivi oggi né un tasso di abbandono. Esami e sessioni QA vanno separati dall'attività reale prima di misurare conversione e permanenza. Questo consolidamento usa le evidenze delle consegne indicate sotto; non aggiunge query, prove o chiamate al narratore.

## Stato dei prodotti e prossimi riscontri
| Area | Checkpoint da mantenere | Fonte corrente |
|---|---|---|
| Combat / Regia | Pannelli e percorso Staff rilasciati; recupero narrativo riuscito il 09/09. Il ciclo generale configurato resta rosso e concluso; non è certificato dal recupero singolo. | `aree/COMBAT.md` |
| Clan | Movimento applicato con migrazione20260909213847; smoke1m e Trasporto PASS con risorse protette invariate. Clone004 e Moltiplicazione Copertura005 attestano i singoli casi; presa riuscita/liberazione, tattiche complete e movimento dopo principale restano aperti. Flussi in copia:15m, fino a3 flussi/bersagli,2sabbia+5chakra ciascuno, recupero2 per proprio turno. Non live. PNG permanente non qualificato, quinto rosso terminale. | `aree/CLAN.md`, HANDOFF Clan |
| Narratore | Hook20260909183721 e combat_narratore_ai v25 rilasciati; verifica15/15 moduli il09/09 alle22:27:09UTC. Descrizione Clone, effetto Moltiplicazione e chiusura effetto Clone applicati. Smoke004/005: fonti e fatti coerenti nei casi osservati, stile ancora da migliorare; nessuna qualifica generale. Contratti Master multi-attore e contesto privato utenti consegnati; implementazione e prove ancora aperte. | `aree/IA_NARRATIVA.md`, HANDOFF Narratore |
| Esame Genin | Campagna di 20 prove conclusa. Percorso SESSION/CYCLE006/OPENING004 documentato su mission_narratore_ai v18; ultimi riscontri utente indicano ripetizioni e interazione PNG da migliorare. Difesa osservata, prova completa di quattro round e congedo non attestata. Fix REC all'apertura ancora proposto. | `aree/ESAME.md` |
| Missioni / Ninja Book / PNG | Fondazioni, pacchetti editoriali e prove narrative già esistono. PACK004 è ratificato nel solo perimetro canary. Il percorso Esame e i Fato manuali del Nodo non certificano una missione automatica completa. | `aree/MISSIONI_IA.md` |
| Training / Accademia | Conservare i checkpoint datati delle rispettive aree. La ratifica narrativa di un allenamento è un caso singolo, non una convalida automatica della progressione. Nessun nuovo collaudo effettuato in questo allineamento. | `aree/TRAINING.md`, `aree/ACCADEMIA.md` |
| Test Room / UI | Staff protetta autorizzata con Riuji e testperfunzioni; scena esistente da conservare aperta. Utenti ancora070, parità Common non implementata. Cleanup storico corretta con migrazione20260910001509: postflight10/09 00:15:17UTC, conserva sessioni/report/dispatch/quote. Contratto privato utenti pronto; non è un rilascio. | `aree/IA_NARRATIVA.md`, `aree/PIATTAFORMA.md`, `testroom_history_release/LIVE_RESULT.json` |


## Pubblicazione e lavoro
`aree/PUBBLICAZIONE.md` registra i singoli file e le verifiche alle rispettive date. Ultimo deposito centrale verificato09/09 22:52UTC: main `2531669fdb4a02ba7a1229921f5bf14d54b436a7`, undici documenti esatti. LAND099 resta la versione attestata; nuovi candidati, referti e questo consolidamento sono locali e attendono deposito selettivo. Non si dichiara l'allineamento dell'intera cartella al dominio senza verifica dei singoli file.

Tre cantieri restano aperti: Clan L1, Combat Composite, Narratore unificato. Le task precedenti sono archiviate; il lavoro continua nella stessa task PM, con incarichi interni e prenotazioni disgiunte. Goal attivo e incompleto, ripresa ogni10min tramite `clan-l1-lavoro-notturno-unico` secondo l'ultima configurazione salvata; gli altri monitor restano distinti. L'anti-stop del Mac è un servizio separato e la sua configurazione non autorizza operazioni di prodotto.

Punto1 documentale e punto2 operativo sono completati e depositati; guard, skill e pianificatore conservano le proprie prove (12/12 e review0/0/0 per il pianificatore). L'architettura operativa è descritta da `management/coordination/AVVIO_LAVORO.md`. Il precedente rinvio del caricamento è superato dal rientro e dal mandato di Antonello: pubblicazione autonoma dei soli file pronti, con riconciliazione e verifica; applicazione DB e apertura generale restano gate distinti.

Il PNG ha raggiunto il quinto rosso: campagna004,63 SQL cumulative, zero provider. Diagnosi completata: avvicinamento PNG incompleto, assert del banco senza comando valido, causa del controllo di concorrenza ancora aperta. È pendente la richiesta di massimo due correzioni aggiuntive; nessuna nuova patch o campagna PNG prima della risposta. Flussi/difese, pannello utenti e contratto Master continuano indipendentemente. Dipendenze e prossimi passi in `04_LAVORI_APERTI.md`; nessun reset di banchi o storico.

Il branch QA permanente è stato dismesso su richiesta di Antonello; vale Docker → rilascio controllato → Test Room di `AGENTS.md`. Campagna pubblicitaria successiva: adulti italofoni, anche nuovi al play-by-chat; budget da definire dopo analisi. Nessuna campagna o spesa pubblicitaria avviata.
