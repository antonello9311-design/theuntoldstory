# 01 · STATO ATTUALE — fotografia consolidata del 20/09/2026

> Si riscrive in posto. Il diario precedente è in `storico/01_STATO_ATTUALE_diario_fino_20260902.md`. Le schede d’area e i readback vivi restano le fonti di dettaglio; questa pagina distingue ciò che è pubblico, ciò che è riservato alla Staff e ciò che richiede ancora collaudo.

## Fotografia generale del database

L’ultima fotografia generale completa resta quella del **09/09/2026**: 85 profili, 78 personaggi, 355 tecniche di catalogo, 9 jutsu, 21 missioni, 7 lezioni, 12 abilità dei personaggi, 0 richieste premio e 52 emblemi. I conteggi non sono stati ripetuti in questa chiusura e non misurano utilizzo o qualità.

Le verifiche mirate successive prevalgono per i sistemi modificati. Il readback Supabase del **15/09/2026** attesta `mission_narratore_ai` v30, `mission_generic_ai` v12 e `combat_narratore_ai` v28 ACTIVE. Il registro Pubblicazione attesta LAND e Admin del **15/09**, inclusi mappe generali, binding oggetti e build `LAND-MAP-GENERAL-STAFF-001`. Il rilascio Elementali/Taijutsu del 19/09 è attestato dalla migrazione `elementali_taijutsu_public_batch_20260919_070`, dal postflight e dal regolamento pubblico; lo stato delle altre risorse resta nelle rispettive aree.

## Stato dei prodotti

| Area | Stato corrente | Verifica o seguito necessario |
|---|---|---|
| Combat / Regia | Motore Common, pannelli ordinary/Staff e movimento ortogonale/diagonale sono operativi. Mappe 10×10 e collegamenti per fase sono pubblicati; il percorso Full IA Missioni sta ancora componendo funzioni e configurazione condivise. | Completare il collaudo Master e multi-attore sui casi indicati nelle checklist vive. Copertura e Diversivo della Moltiplicazione sono in un lavoro separato: il precedente writer sospeso è stato liberato senza modifiche. |
| Sabaku | Pubblici Controllo della Sabbia, Flussi 1–3 concentrati sul singolo bersaglio, Trasporto e Clone di Sabbia. I casi osservati hanno conservato le risorse reali della Test Room. | Flussi multibersaglio restano rinviati. Armatura di Sabbia è installata inerte, con testo/formula approvati ma senza enable e collaudo. |
| Hyūga | Pubblici Byakugan, Pugno Gentile, Tecnica delle Sedici Chiusure e Rotazione Suprema. Potenza, Danno base e Difesa sono esposti nelle UI previste. Rotazione ha due casi ordinary positivi. | Rotazione con Master resta da provare. Il malus del punto cieco −3/−2/−1/0 è deciso ma non implementato. |
| Uchiha | Pubblici Sharingan, Palla di Fuoco generica, Palla di Fuoco Suprema e Risonanza Katon. La Risonanza vale solo per i Katon Uchiha compatibili e non per la tecnica generica. | Percorso Master e osservazione live pubblica restano da attestare. |
| Moltiplicazione / Sostituzione | Assalto e Sostituzione seguono il resolver condiviso; Assalto usa bonus +2/+3 e difesa ordinaria. La conclusione delle copie è proiettata al Narratore. | Copertura e Diversivo restano fuori dal completamento finché il bivio di cessione iniziativa non viene integrato e collaudato senza anticipare il Fato. |
| Esame Genin | Usa Combat/Common2D, Regia automatica e PNG IA senza Master umano. La prova Tamako è chiusa definitivamente dal 14/09 con storico, bozze e risorse preservati. La prova Shion appartiene a un altro lavoro e va conservata. | Valutare il prossimo attacco PNG prodotto da v30: la correzione comune raggiunge già la scelta narrativa, ma non vieta la stessa tecnica meccanica consecutiva. Il pulsante di chiusura mancante e gli altri rilievi UI restano separati. |
| Narratore IA | Continuità, contesto del giocatore, resa scenica e distinzione fra fatti server e prosa sono condivisi fra Combat, Esame e Regia. Le tre Edge sopra sono vive. | L’architettura è integrata, ma la qualità non è certificata globalmente: raccogliere note editoriali su casi reali, senza aprire una nuova riscrittura preventiva dei prompt. |
| Missioni / PNG / mappe | Editor rapido live: da trama, fasi e immagini produce una bozza correggibile, profili PNG approvati, contesto narrativo e arena separati, anteprima obbligatoria e pubblicazione unica. Collaudo Staff concluso con arena 12×10, 2 PG + 3 PNG e `survive_rounds=3`; client `two-maps.4`, commit `3d251c8`. | Il primo run giocato delle missioni pubblicate resta una scelta operativa distinta. Il ciclo editor rapido è concluso e non va riaperto tramite le vecchie task sospese. |
| Elementali / Taijutsu generici | Nove elementali e cinque Taijutsu sono pubblici, con catalogo, motore e regolamento allineati. Le sette tecniche Taijutsu sostituite sono inattive e conservate. | Campagna conclusa nel perimetro osservato; nuovi delta richiederanno soltanto regressioni pertinenti. |

## Processo, pubblicazione e continuità

Punto 1 documentale e punto 2 operativo sono completati. Ogni nuova task o ripresa parte da `management/coordination/AVVIO_LAVORO.md`, usa owner e dipendenze del registro e non riapre automaticamente backlog o chat archiviate. Le tecniche seguono il percorso codice → Test Room reale → correzione mirata → apertura dopo esito positivo.

Il rilascio delle regole è attestato dal commit `71e732ed22d136dd71be34d8661427298fcce67e`; sorgenti ed evidenze del batch sono depositate fino al commit `90b05418b3f1121c8ddbc3aba3595f47ab601063`. Il workspace principale non contiene una directory `.git`; lo stato di pubblicazione si legge in `dossier/aree/PUBBLICAZIONE.md`. Alcuni sorgenti e documenti restano locali o in coda selettiva e non vanno caricati cumulativamente.

Il goal editor rapido è completato. Piani, schede d’area, pubblicazione, audit e guida d’uso sono allineati; questa chat viene archiviata dopo la chiusura del registro locale. Eventuali nuovi requisiti partono da un nuovo mandato e dalla baseline live, senza riaprire le task storiche sospese.

Checkpoint di archiviazione: `management/coordination/HANDOFFS/CHAT-ORGANIZZA-LAVORO-CLOSEOUT.md`.
