# 04 · LAVORI APERTI — cantieri, dipendenze e prossimi passi

> Allineamento del 19/09/2026. Al massimo tre cantieri restano «in lavoro»; le task archiviate non vengono riaperte. Le versioni e le prove esatte restano nelle schede d’area e negli handoff dei singoli incarichi.

## I tre cantieri aperti

| Cantiere | Stato reale | Prossimo passo |
|---|---|---|
| `management/candidati/CLAN-L1_2026-09-01/` | Sabaku, Hyūga e Uchiha hanno rilasci pubblici circoscritti. Nove elementali e cinque Taijutsu generici sono collaudati nel perimetro pertinente, approvati editorialmente e pubblici; sette Taijutsu precedenti sono inattivi e conservati. | Collaudare e poi abilitare Armatura; implementare punto cieco; chiudere i casi Master pertinenti degli altri clan. Elementali/Taijutsu generici non hanno arretrato aperto. |
| `management/candidati/COMBAT-COMPOSITE_2026-09-01/` | Common e movimento sono operativi; mappe/binding del 15/09 sono live. Copertura/Diversivo sono stati passati a un lavoro dedicato; il vecchio writer `MULTIPLICATION-RESUME-CORE-006` è stato rilasciato sospeso e non ha modificato i file. | Integrare il bivio della cessione iniziativa, impedire la pubblicazione del Fato prima della sua chiusura e collaudare nei percorsi reali. Comporre i delta sulla baseline corrente, senza riusare installer obsoleti. |
| `management/candidati/NARRATORE-UNIFICATO_2026-09-02/` | Regole comuni, editor/default mappe e pannello Shion live. Scorta Staff 1 PG/3 PNG ha concluso Combat e resa con cleanup verde; runtime OFF. Questi rilasci sono chiusi documentalmente e non vanno riaperti tramite le vecchie task sospese. | Completare la review della recovery resa; in incarichi distinti, configurare accesso pubblico 3/3 e consegna finale della Scorta, ed eventualmente eseguire un nuovo smoke Shion senza riusare l’esame aperto. |

## Funzioni già disponibili da non ricostruire

- Movimento ortogonale e diagonale senza consumo della principale nei percorsi già collegati.
- Marionettisti, Controllo/Flussi singolo/Trasporto/Clone Sabaku, Byakugan/Jūken/Sedici/Rotazione e Sharingan/Palle di Fuoco/Risonanza nei rispettivi perimetri pubblicati.
- Moltiplicazione Assalto con +2/+3, difesa normale e consumo delle copie; Sostituzione nel percorso difensivo.
- Esame Genin automatico su Combat/Common2D; Tamako chiusa definitivamente con storico preservato.
- Strato narrativo comune che legge fatti server, descrizione/effetto e contesto, senza attribuire all’IA valori o decisioni meccaniche.
- Editor mappe generali, oggetti e binding per fase pubblicati il 15/09.

## Lavori e verifiche ancora aperti

| Priorità | Lavoro | Dipendenza o limite |
|---|---|---|
| 1 | Missione Full IA fino alla consegna e accesso 3 PG | Combat/resa 1 PG contro 3 PNG PASS; restano consegna finale, media/configurazione pubblica e normale accesso del team. Le risorse `db:produzione` e Staff Room non sono più trattenute dal collaudo. |
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

I riepiloghi specialistici ESAME, IA_NARRATIVA, COMBAT e CLAN contengono checkpoint più dettagliati fino al 14–15/09. Le prenotazioni registrate di altri owner sui loro file restano intatte. Il goal Elementali/Taijutsu è completato; questa task viene archiviata dopo la consegna. Eventuali heartbeat restano gestiti separatamente. La sua consegna finale è in `management/coordination/HANDOFFS/CHAT-ORGANIZZA-LAVORO-CLOSEOUT.md`.

Il processo uniforme resta `management/coordination/AVVIO_LAVORO.md`. Prima di ogni ripresa: identificare candidato e baseline viva, verificare owner e sessioni, comporre un solo delta integrato, collaudare sul percorso reale previsto e aggiornare SCHEDA/HANDOFF/STORICO dell’incarico. Non usare chat archiviate come fonte operativa quando esiste una scheda viva più recente.
