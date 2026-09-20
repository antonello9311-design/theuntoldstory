# 04 · LAVORI APERTI — cantieri, dipendenze e prossimi passi

> Allineamento del 20/09/2026. Al massimo tre cantieri restano «in lavoro»; le task archiviate non vengono riaperte. Le versioni e le prove esatte restano nelle schede d’area e negli handoff dei singoli incarichi.

## I tre cantieri aperti

| Cantiere | Stato reale | Prossimo passo |
|---|---|---|
| `management/candidati/CLAN-L1_2026-09-01/` | Sabaku, Hyūga e Uchiha hanno rilasci pubblici circoscritti. Nove elementali e cinque Taijutsu generici sono collaudati nel perimetro pertinente, approvati editorialmente e pubblici; sette Taijutsu precedenti sono inattivi e conservati. | Collaudare e poi abilitare Armatura; implementare punto cieco; chiudere i casi Master pertinenti degli altri clan. Elementali/Taijutsu generici non hanno arretrato aperto. |
| `management/candidati/COMBAT-COMPOSITE_2026-09-01/` | Common e movimento sono operativi; mappe/binding del 15/09 sono live. Copertura/Diversivo sono stati passati a un lavoro dedicato; il vecchio writer `MULTIPLICATION-RESUME-CORE-006` è stato rilasciato sospeso e non ha modificato i file. | Integrare il bivio della cessione iniziativa, impedire la pubblicazione del Fato prima della sua chiusura e collaudare nei percorsi reali. Comporre i delta sulla baseline corrente, senza riusare installer obsoleti. |
| `management/candidati/NARRATORE-UNIFICATO_2026-09-02/` | Editor rapido live e collaudato: compilatore, bozze PNG, contesto narrativo, arena separata, anteprima e pubblicazione unica. Missione a due mappe aperta con 2 PG + 3 PNG; `Adatta missioni` invariato. Le task sospese precedenti sono storico. | Nessun seguito per l’editor rapido. Restano separati soltanto i lavori già nominati su Scorta, qualità narrativa ed Esame; un nuovo requisito dell’editor richiede un nuovo mandato. |

## Funzioni già disponibili da non ricostruire

- Movimento ortogonale e diagonale senza consumo della principale nei percorsi già collegati.
- Marionettisti, Controllo/Flussi singolo/Trasporto/Clone Sabaku, Byakugan/Jūken/Sedici/Rotazione e Sharingan/Palle di Fuoco/Risonanza nei rispettivi perimetri pubblicati.
- Moltiplicazione Assalto con +2/+3, difesa normale e consumo delle copie; Sostituzione nel percorso difensivo.
- Esame Genin automatico su Combat/Common2D; Tamako chiusa definitivamente con storico preservato.
- Strato narrativo comune che legge fatti server, descrizione/effetto e contesto, senza attribuire all’IA valori o decisioni meccaniche.
- Editor mappe generali, oggetti e binding per fase pubblicati il 15/09.
- Editor rapido missioni `two-maps.4`: trama e fasi, PNG e immagini, contesto narrativo, arena default o specifica, anteprima bloccante e pubblicazione unica.

## Lavori e verifiche ancora aperti

| Priorità | Lavoro | Dipendenza o limite |
|---|---|---|
| 1 | Primo run giocato della Scorta già pubblicata | È distinto dall’editor rapido, che è concluso. Eseguirlo solo quando il roster previsto è libero e senza riaprire le task di sviluppo dell’editor. |
| 1 | Copertura e Diversivo | Integrare cessione iniziativa, difesa successiva e pubblicazione unica del Fato. Nessun esito IA prima della chiusura del bivio. |
| 2 | Armatura di Sabbia | Installata inerte: enable, Staff Test Room, correzioni chiare e apertura al positivo. |
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
