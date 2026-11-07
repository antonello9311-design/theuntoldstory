# 04 · LAVORI APERTI — cantieri, dipendenze e prossimi passi

Aggregata1 T3 completata nei soli sorgenti e controreview0/0/0: componente `e163bd59baa530df14764ed361af658f312f171b88a4f1bdd6508c83d7b3de49`, integrata `8054ddb373d95fd4c8e20a82eb163744e660813f20e02765a565f57c0b0bb777`, installer inerte `4fd1312a936264f2463b12e01db421b93955612ce692e7154e70122a237c8d05`, referto `a84bc2b9570c5e9f679c9f5cee22eea0525f3f2a155b225d25d27f7ac1f92698`. Il CHECK usa IN(2,3,10) implicito, coerente con la serializzazione catalogo attesa; guardie, writer e gli altri corpi invariati. Il tentativo precedente resta fallito e atomico, senza retry. Root viva36f invariata; finestra22:17:48UTC scaduta, nessun binding eseguibile o nuova installazione/QA. Il deposito documentale selettivo `d20f082800c58fd3c8bc788e004b288d651c1a29` ha12/12blob verificati e Admin invariato; i WIP estranei locali sono esclusi.

> Aggiornamento mirato Human del17/10/2026: QA23 PASS e OPEN24 verificato; gli altri blocchi conservano le rispettive date. Allineamento del 21/09/2026. Al massimo tre cantieri restano «in lavoro»; le task archiviate non vengono riaperte. Le versioni e le prove esatte restano nelle schede d’area e negli handoff dei singoli incarichi.

## I tre cantieri aperti

| Cantiere | Stato reale | Prossimo passo |
|---|---|---|
| `management/candidati/CLAN-L1_2026-09-01/` | Sabaku, Hyūga e Uchiha hanno rilasci pubblici circoscritti. Nove elementali e cinque Taijutsu generici sono pubblici. Armatura di Sabbia è pubblica; cataloghi selettivi Regole/Clan online. | Implementare punto cieco e chiudere i casi Master pertinenti degli altri clan; osservare Armatura nel normale uso senza riaprire il collaudo concluso. |
| `management/candidati/COMBAT-COMPOSITE_2026-09-01/` | Copertura/Diversivo e punto cieco: Staff parziale, pubblico OFF. S17 chiusa con PASS circoscritti; S18 chiusa per correzione T3, installazione successiva annullata atomicamente. | Root36f invariata; aggregata1 statica in corso. Finestra22:17:48UTC terminata;284comandi/18scene chiuse/16provider/0,0153834USD, nessun costo o ripristino duplicato. |
| `management/candidati/NARRATORE-UNIFICATO_2026-09-02/` | Editor rapido live e collaudato: compilatore, bozze PNG, contesto narrativo, arena separata, anteprima e pubblicazione unica. Missione a due mappe aperta con 2 PG + 3 PNG; `Adatta missioni` invariato. Le task sospese precedenti sono storico.  Human: QA23 PASS e apertura LAND verificata con OPEN24, migrazione20261017083331 e post17/10/2026 08:34:19.624645UTC: tutte17verifiche positive. C12/full112 release `d4cf89c9b77494833a159c2c911ca7c5768124e3fff4f155590c178fa8b057c8`, LAND `8f89a7234ba40cfda902dc4dc507f2581540ee4f464f4beaa7f21ccc590c67a6`, commit `fdaa5759fdcb2b1342141fbc2efc2d5cd16d1837`. Nomi PG/PNG leggibili, selezionabili e riletti; Combat solo dal comando esplicito nel pannello dedicato, mai inline o automatico dalla puntata. Stessa scena27f18 chiusa, due partecipanti finalizzati, risorse protette48 invariate, provider IA0 e WIP conservato; pubblico attivo e riserva Staff disattivata. C9 e prova Staff della seconda puntata restano storici distinti; nuova prova custom multipuntata e premi reali NOT_RUN. Conteggi e fallimenti storici conservati. | Nessun seguito per l’editor rapido. Restano separati soltanto i lavori già nominati su Scorta, qualità narrativa ed Esame; un nuovo requisito dell’editor richiede un nuovo mandato.  Collaudo e apertura Human completati; schermate approvate da Antonello il 17/10/2026; incarico Human/UI concluso. WIP e contatori preservati.|

## Funzioni già disponibili da non ricostruire

- Movimento ortogonale e diagonale senza consumo della principale nei percorsi già collegati.
- Marionettisti, Controllo/Flussi singolo/Trasporto/Clone Sabaku, Byakugan/Jūken/Sedici/Rotazione e Sharingan/Palle di Fuoco/Risonanza nei rispettivi perimetri pubblicati.
- Moltiplicazione Assalto con +2/+3, difesa normale e consumo delle copie; Sostituzione nel percorso difensivo.
- Esame Genin automatico su Combat/Common2D; Tamako chiusa definitivamente con storico preservato.
- Strato narrativo comune che legge fatti server, descrizione/effetto e contesto, senza attribuire all’IA valori o decisioni meccaniche.
- Editor mappe generali, oggetti e binding per fase pubblicati il 15/09.
- Editor rapido missioni `two-maps.4`: trama e fasi, PNG e immagini, contesto narrativo, arena default o specifica, anteprima bloccante e pubblicazione unica.

## Lavori e verifiche ancora aperti

Copertura/Diversivo e punto cieco · stato Staff. Root viva `36f27609e45c322d2850477574e553cec49a7421d1c1b1fda99b05f62dcafc60`, migrazione difese `20261107214321`; Admin pubblicato nel commit `2b84650f06ec40d966667f3507b9852c70bf4fd0`, Pages e DOM verificati. S17 chiusa: MAX2/primario e retro III PASS circoscritti; due origini nello stesso round non rappresentabili con i profili attuali. T1/T2/T4 conservano gli esiti registrati.

S18 chiusa il 07/11 alle22:07:12UTC, `values_written=false`: T3 non superato per23514 (Soffio canonico10m contro CHECK2/3), formazione15 pagata una volta e attacco respinto senza costo5. Il fix range10 riservato Staff ha superato la review sorgente ma l'unica installazione è stata annullata atomicamente da `TACTICS_INTEGRATED_PROJECTED_ROOT`. Postflight12/12 conferma Root, CHECK, gate, PG reali, Scorta e Party invariati. Correzione della serializzazione del CHECK in aggregata1 statica; nessun secondo apply.

Cumulativi284comandi/18scene proprie tutte chiuse/16provider,71319input+16503output e0,0153834USD su0,10. Finestra7 terminata22:17:48UTC;38comandi/3scene/5invii sono contatori conservati, non tempo autorizzato. Nessun ripristino o costo duplicato. Restano T3/T5/F1 e ServiceT6–T8; Service non avviato, Count/ammissione4096 da qualificare e42HTTP della proposta oltre i5residui. Copertura/Diversivo e Facing pubblici OFF; nove Innate mantenute già pubbliche intatte. Review, installazione e collaudo restano distinti.


| Priorità | Lavoro | Dipendenza o limite |
|---|---|---|
| 1 | Regia Human — conclusa e accettata | QA23 PASS e OPEN24 verificato; schermate approvate da Antonello il 17/10/2026; incarico concluso, WIP e prove conservati. C1266 resta un lavoro distinto; nuova prova custom multipuntata e premi reali NOT_RUN. |
| 1 | Primo run giocato della Scorta già pubblicata | È distinto dall’editor rapido, che è concluso. Eseguirlo solo quando il roster previsto è libero e senza riaprire le task di sviluppo dell’editor. |
| 1 | Copertura e Diversivo | Integrare cessione iniziativa, difesa successiva e pubblicazione unica del Fato. Nessun esito IA prima della chiusura del bivio. |
| 2 | Armatura di Sabbia | Pubblicata il 21/09 dopo review 0/0/0 e apertura del gate; nessun caso bloccante residuo. |
| 2 | Punto cieco Byakugan | Regola decisa; mancano facing/origine attacco e geometria posteriore autorevoli. |
| 2 | Casi Master pertinenti | Rotazione, Katon e interazioni indicate nelle checklist; non ripetere i casi ordinary già verdi. |
| 3 | Qualità Narratore | Osservare il prossimo Fato PNG v30 e casi completi di scontro/missione; registrare note editoriali specifiche. |
| 3 | Immagini PNG sulla mappa | Trasformare i ritratti dell’annuario in ritagli coerenti con Tamako; requisito già annotato, implementazione non conclusa. |
| 4 | Nuova utenza | Analisi mirata ad adulti italofoni, anche nuovi al play-by-chat e interessati a GDR/anime/manga; budget ancora da definire, nessuna spesa avviata. |

## Stato Esame e IA da preservare

Tamako non deve essere ripresa: l’esame è annullato/chiuso dal 14/09 e tutte le risorse sono state liberate. Una registrazione storica `TAMAKO-PAUSED-RECOVERY-20260913` risulta ancora `registered` nel task guard e contraddice lo stato vivo; va riconciliata dal suo owner, non eseguita. La prova Shion appartiene a un altro incarico e non va chiusa o modificata da task nuove.

`mission_narratore_ai` v30 applica le regole comuni anche alla narrazione della scelta PNG dell’Esame. La ripetizione osservata il 13/09 precede questa versione. Il prossimo campione deve distinguere due casi: stessa tecnica meccanica consentita dal server e ripetizione stilistica della coreografia. Solo il secondo, se ancora presente, richiede un intervento editoriale.

## Coordinamento e archiviazione

I riepiloghi specialistici ESAME, IA_NARRATIVA, COMBAT e CLAN restano fonti dei rispettivi lavori. Le prenotazioni registrate di altri owner sui loro file restano intatte. Il goal dell’editor rapido è completato e la relativa chat viene archiviata dopo la consegna documentale `MISSION-RAPID-DOCS-ARCHIVE-093`. Non risultano prenotazioni attive della task conclusiva; la vecchia QA 091 resta sospesa soltanto come storico superato dalla chiusura 092. Eventuali heartbeat restano gestiti separatamente.

Il processo uniforme resta `management/coordination/AVVIO_LAVORO.md`. Prima di ogni ripresa: identificare candidato e baseline viva, verificare owner e sessioni, comporre un solo delta integrato, collaudare sul percorso reale previsto e aggiornare SCHEDA/HANDOFF/STORICO dell’incarico. Non usare chat archiviate come fonte operativa quando esiste una scheda viva più recente.
