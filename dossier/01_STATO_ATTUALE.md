# 01 · STATO ATTUALE — fotografia del 09/09/2026

> Si riscrive in posto. Il diario precedente è in `storico/01_STATO_ATTUALE_diario_fino_20260902.md`. Stato operativo e limiti delle prove restano nelle schede d'area; questa fotografia non certifica tutti i percorsi del gioco.

## Verifica diretta del database
Lettura aggregata di produzione del **09/09/2026, 11:03:23 UTC**: **85 profili, 78 personaggi, 355 tecniche di catalogo, 9 jutsu, 21 missioni, 7 lezioni, 12 abilità dei personaggi, 0 richieste premio e 52 emblemi**. Le righe del catalogo non attestano tecniche abilitate o collaudate; le righe emblema non attestano immagini caricate.

Successiva lettura della piattaforma alle **11:32:43UTC**: **233 tabelle base e805 funzioni in `public`, di cui680 SECURITY DEFINER;495 migrazioni**, ultima `20260909112705`. Edge e cron restano quelli della lettura delle11:03:23UTC: **15 Edge distribuite ACTIVE; 13 cron, 12 attivi**, con `pilot-scadenza` spento. Verificate `combat_narratore_ai` v23, `mission_narratore_ai` v18 ed `exam_genin_ai` v139. Versione distribuita e percorso realmente abilitato sono verifiche distinte. Non è stato rieseguito un audit generale di permessi o sicurezza.

I dati di utilizzo del 01–02/09 sono storici: non stabiliscono quanti giocatori siano attivi oggi né un tasso di abbandono. Esami e sessioni QA vanno separati dall'attività reale prima di misurare conversione e permanenza. Nessuna nuova lettura di role private, prova di gioco o chiamata al narratore è stata eseguita per questa fotografia.

## Stato dei prodotti e prossimi riscontri
| Area | Checkpoint da mantenere | Fonte corrente |
|---|---|---|
| Combat / Regia | Pannelli e percorso Staff rilasciati; recupero narrativo riuscito il 09/09. Il ciclo generale configurato resta rosso e concluso; non è certificato dal recupero singolo. | `aree/COMBAT.md` |
| Clan | Stato per tecnica e percorso, non con un unico «tutto OFF». Caso Marionetta riuscito nella Staff09/09 alle11:12UTC, con movimento, attacco, difesa e Fato; difetti UI residui. Qualifica corretta e rilascio del raccordo Sabaku attestati dall’owner alle11:27UTC, migrazione confermata in sola lettura. Successivo bind/ON attestato PASS alle11:38:54UTC con risorse protette invariate; Trasporto/Clone non ancora certificati. Precedente referto rosso preservato. | `aree/CLAN.md` |
| Narratore | Recupero Staff attestato alle 09:56 UTC: una chiamata, 1.830 token, risorse protette invariate. Successiva tranche ordinaria Passa+attacco attestata dall'owner alle11:12UTC: due chiamate,3.847 token,zero retry; postflight11:12:50 senza differenze sulle12 superfici protette. Audit centrale e chiarezza editoriale dello striscio restano questioni aperte. | `aree/IA_NARRATIVA.md` |
| Esame Genin | Campagna di 20 prove conclusa. Percorso SESSION/CYCLE006/OPENING004 documentato su mission_narratore_ai v18; ultimi riscontri utente indicano ripetizioni e interazione PNG da migliorare. Difesa osservata, prova completa di quattro round e congedo non attestata. Fix REC all'apertura ancora proposto. | `aree/ESAME.md` |
| Missioni / Ninja Book / PNG | Fondazioni, pacchetti editoriali e prove narrative già esistono. PACK004 è ratificato nel solo perimetro canary. Il percorso Esame e i Fato manuali del Nodo non certificano una missione automatica completa. | `aree/MISSIONI_IA.md` |
| Training / Accademia | Conservare i checkpoint datati delle rispettive aree. La ratifica narrativa di un allenamento è un caso singolo, non una convalida automatica della progressione. Nessun nuovo collaudo effettuato in questo allineamento. | `aree/TRAINING.md`, `aree/ACCADEMIA.md` |
| Test Room / UI | La Staff corrente è mantenuta aperta per mandato; Test Room utenti070 rinviata nella tranche Clan. Allineamento permanente delle due superfici resta un obiettivo con residui da verificare. | `aree/TEST_ROOM.md`, `aree/PAGINE.md` |

## Pubblicazione e lavoro
`PUBBLICAZIONE.md` registra i singoli file e le verifiche alle rispettive date. LAND099 è attestata dall'owner; la baseline GitHub dell’allineamento è main `0b83cbd502be8ebba40405949556aaeed3c1cb64`, senza nuovo collaudo del dominio. Non si dichiara che tutta `sito_live/` coincida oggi con il sito sulla base del controllo del 02/09.

Tre cantieri documentali restano aperti: Clan L1, Combat Composite, Narratore unificato. Tutte le altre task del progetto, compresa Clan dopo la consegna, sono archiviate su richiesta Antonello. I monitor delle task sono sospesi; l’anti-stop del Mac è distinto. Rimane il coordinamento del punto 2. La chiusura Clan conserva il checkpoint12:14:04UTC e i residui nelle aree; gli aggiornamenti finali successivi al deposito23263a9 sono locali, non un nuovo rilascio. Dipendenze e prossimi passi sono in `04_LAVORI_APERTI.md`. Il branch QA permanente è stato dismesso su richiesta di Antonello; vale il flusso Docker → rilascio controllato → Test Room di `AGENTS.md`.

La ricognizione delle task aperte e archiviate è in `02_INDICE_DOCUMENTI.md`: **punto1 documentale completo localmente**. Il **punto2 è completato localmente**: guard e otto skill verificati, pianificatore di dipendenze/briefing12/12 e review finale0/0/0 secondo AVVIO_LAVORO. Antonello chiede di rinviare il caricamento al rientro e autorizza la ripresa Clan da questa stessa task dopo punto2. I collaudi del processo non certificano il gioco; nessuna riapertura automatica degli altri prodotti. Campagna pubblicitaria successiva: adulti italofoni, anche nuovi al play-by-chat; budget da definire dopo analisi.
