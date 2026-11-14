# 01 · STATO ATTUALE — allineamento del 14/11/2026

> Aggiornamento del 14/11/2026 da referti di area, registro pubblicazioni e lettura mirata dei gate Combat. Le fotografie tecniche senza nuove evidenze conservano le date originali.

## Fotografia generale del database

L’ultima fotografia generale completa resta quella del **09/09/2026**: 85 profili, 78 personaggi, 355 tecniche di catalogo, 9 jutsu, 21 missioni, 7 lezioni, 12 abilità dei personaggi, 0 richieste premio e 52 emblemi. I conteggi non sono stati ripetuti in questa chiusura e non misurano utilizzo o qualità.

Le verifiche mirate successive prevalgono per i sistemi modificati. Il readback Supabase del **15/09/2026** attesta `mission_narratore_ai` v30, `mission_generic_ai` v12 e `combat_narratore_ai` v28 ACTIVE. Il registro Pubblicazione attesta LAND e Admin del **15/09**, inclusi mappe generali, binding oggetti e build `LAND-MAP-GENERAL-STAFF-001`. Il rilascio Elementali/Taijutsu del 19/09 è attestato dalla migrazione `elementali_taijutsu_public_batch_20260919_070`, dal postflight e dal regolamento pubblico; lo stato delle altre risorse resta nelle rispettive aree.

## Stato dei prodotti

| Area | Stato corrente | Verifica o seguito necessario |
|---|---|---|
| Combat / Regia | UI comune in Land dal 14/11. Mappa e invio unico collaudati in Staff, anche con Fato IA nel duello nativo. Human H7 e OPEN24 acquisiti. | Riepilogo Master e recupero vista, bozza e ricevuta da completare. Scorta segue il proprio percorso. |
| Sabaku | Pubblici Controllo della Sabbia, Flussi 1–3 sul singolo bersaglio, Trasporto, Clone e Armatura di Sabbia. Armatura è una passiva gestita dal pannello, con consumo e ricomposizione server-side già collaudati. | Flussi multibersaglio restano rinviati. Armatura è pubblica dal 21/09: il ramo sabbia insufficiente usa la stessa autorità condivisa di consumo/interruzione del Controllo della Sabbia già validata; monitoraggio ordinario, nessun blocco aperto. |
| Hyūga | Byakugan, Pugno Gentile, Sedici Chiusure e Rotazione Suprema pubblici. Punto cieco pubblico dal 13/11. | B10 con Master concluso. Una reazione su due origini, laterale e origine marionetta acquisiti. |
| Uchiha | Sharingan, Palle di Fuoco e Risonanza Katon pubblici. | B3 con Master concluso per concentrata ed esplosiva. Punto d’impatto selezionato sulla mappa in Staff. |
| Aburame | Pubblici Insetti Parassiti Distruttivi con Colonia Kikaichū, Liberazione dei Kikaichū e Clone d’Insetti. Staff QA 12 casi, review `0/0/0`, build LAND/Regole pubblicate e gate pubblico `version=2`. | Monitoraggio nel normale uso; nessun blocco aperto. L’ultima correzione narrativa terminale è coperta dalla review statica sul corpo live senza superare il budget provider. |
| Akimichi, Hoki e Nara | Sei tecniche Genin aperte nel perimetro Combat V2 documentato. | PASS Staff conservati. |
| Inuzuka | Gate Staff attivo, pubblico spento. | Offerte e casi meccanici del ninken da qualificare. |
| Moltiplicazione / Sostituzione | Assalto e Sostituzione seguono il resolver condiviso. | Copertura e Diversivo ritirati dalla Land, fuori dai lavori attivi. |
| Esame Genin | Master umano ordinario Konoha/Suna attestato C1235 con H2. Esame IA fermo dal 04/11 annullato il 12/11, storico conservato. | I rilievi del ramo automatico e i premi restano distinti. |
| Narratore IA / C1266 | Discussioni in Centro disponibile dalla Bacheca, con iscrizioni da Konoha e Suna e sede Konoha — Centro. C18 Staff conferma due Ready, un clic e incipit automatico. | Ultimo roster documentato il 12/11: Hime 1/2, Setsu ritirato. Il primo avvio pubblico e il party misto non sono attestati da C18. |
| Innata → Combat | Dal 07/11/2026 sono pubbliche Byakugan I–IV, Sharingan I–IV e Controllo della Sabbia I. Il raccordo narrativa→Scontro è qualificato in ordinario e nelle Quest con Master; la prova Quest IA Staff conferma Sabbia I già attiva, attivazione in ingresso zero e mantenimento nativo regolare. Le Quest IA generali restano riservate alla Staff. | Mandato delle nove mantenute completato; gate pubblico v3, migrazione 20261107065056. Storico e costi precedenti conservati. Ramo passivo distinto; nessuna riapertura del collaudo. |
| Missioni Human / PNG / mappe | Human/UI concluso e accettato il 17/10: QA23 PASS, OPEN24 `20261017083331`, postread 08:34:19 UTC con 17 verifiche positive. Nomi PG/PNG persistenti, Combat dal pannello esplicito, Fato, ritorno narrativo e chiusura; 48 campi protetti invariati, provider zero. Il 15/10 anche il percorso custom Iori in Staff è PASS. | Nessun rifacimento Human. Nuova campagna custom multipuntata, premi reali e nuove geometrie/azioni restano `NOT_RUN`. Editor generale/Source74 e dieci revisioni PNG senza vincoli di brevità restano separati, non qualificati da questi PASS. |
| Elementali / Taijutsu generici | Nove elementali e cinque Taijutsu sono pubblici, con catalogo, motore e regolamento allineati. Le sette tecniche Taijutsu sostituite sono inattive e conservate. | Campagna conclusa nel perimetro osservato; nuovi delta richiederanno soltanto regressioni pertinenti. |

## Processo, pubblicazione e continuità

Punto 1 documentale e punto 2 operativo sono completati. Ogni nuova task o ripresa parte da `management/coordination/AVVIO_LAVORO.md`, usa owner e dipendenze del registro e non riapre automaticamente backlog o chat archiviate. Le tecniche seguono il percorso codice → Test Room reale → correzione mirata → apertura dopo esito positivo.

Il rilascio delle regole è attestato dal commit `71e732ed22d136dd71be34d8661427298fcce67e`; sorgenti ed evidenze del batch sono depositate fino al commit `90b05418b3f1121c8ddbc3aba3595f47ab601063`. Il workspace principale non contiene una directory `.git`; lo stato di pubblicazione si legge in `dossier/aree/PUBBLICAZIONE.md`. Alcuni sorgenti e documenti restano locali o in coda selettiva e non vanno caricati cumulativamente.

Il goal editor rapido è completato. Piani, schede d’area, pubblicazione, audit e guida d’uso sono allineati; questa chat viene archiviata dopo la chiusura del registro locale. Eventuali nuovi requisiti partono da un nuovo mandato e dalla baseline live, senza riaprire le task storiche sospese.

Checkpoint di archiviazione: `management/coordination/HANDOFFS/CHAT-ORGANIZZA-LAVORO-CLOSEOUT.md`.
