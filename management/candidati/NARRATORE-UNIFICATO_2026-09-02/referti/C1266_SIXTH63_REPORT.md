# Sesta prova F — recupero Combat64 e confronto A–E

30/10/2026 · Correzione23 installata e verificata Staff; stessa missione NON COMPLETATA. Nuovo Fato del report non ancora pubblicato. Recupero IA e conclusione attendono rinnovo della finestra autorizzata.

## Continuità e versione

Sessione `c2faf883-5264-44e3-b1a2-bd9a39876942`, piano `848a988d-5705-4304-a9e5-172e4e09c725`, revisione7 e schede PNG V6. Sorgente SHA256 `6f8628df584b20e6360ab0807be22078109fff3a72bbc6b4f0b56cdd52b6b93b`. Nessun riavvio, reinvio delle azioni accettate o riscrittura dei Fati.


## Pubblicazioni e azioni

| Fato | UTC | Parole | SHA256 |
|---|---|---:|---|
| F0 |07:24:23.785869|141|0664cea9fae0153100ab425227417b1327a561a5c93b36555cf84990e6bc1a56|
| F1 |07:25:51.200917|235|9c06d50e74f23351c77b04b72e399fa88e0057fc4d4827b10cf231f591504628|
| F2 |07:26:37.370120|92|2abdf577bc062c9aebf9ca07206673d407786c91cd17c14331e6ba1a08413b51|

La dichiarazione difensiva Keita `a74fdfe9-4974-44c6-b066-cdd7fe04feaa`, SHA `164b5200bc688587f68f55429d71d79adb8618138713bce23d38ca5315d63b85`, è stata esposta prematuramente come Fato alle09:18:41UTC. Non è il Fato conclusivo del round e resta conservata senza modifiche retroattive.

Attacco Riuji `33a37259-a0a8-4419-bb2f-910d97de59fc` e Passa Tamako `2ceab26a-ae00-47ab-8957-c3790bc62106` accettati una volta; la role successiva al vecchio Passa fu respinta dal client e non è stata reinviata. Riuji ha realmente selezionato Keita come bersaglio: non è stato sostituito con Daichi per adattare la storia.

Encounter `b3135a23-78c5-4c45-a730-b1de8257367b`; round1 `dfe85868-7d6b-4018-bacd-49acb5a51e1f` risolto. Report `3a734d4a-6aa9-4ce9-a641-9ef26271df76`, meccaniche SHA `37aba24839765b4588ccb778678225e060c53999d75ceb48ca182301fff9cdc5`, narration_state=attesa, message_id=NULL al checkpoint.

## Cause e correzioni cumulative

- Classificazione Native del dispatch cercava una Unified window che il nuovo percorso Scene non crea.16 ha collegato le ricevute reali senza batch fittizi; stesso evento107 recuperato.
- Primo Writer3cec fallito prima del provider: selezione49152byte confusa con limite richiesta491520.18 ha distinto i contratti e introdotto recovery transitiva, senza cambiare payload o referto.
- UI richiedeva eventStatus anche quando l’evento terminale è proiettato NULL.19 ha esposto il recupero autorevole; click09:59:15UTC ha creato203b, senza reinviare azioni.
- Writer203b fallito prima del provider con MISSION_LIFE_CORE_INVALID: scheda congelataV6 a16campi contro formato Writer a10.23 proietta soltanto il trasporto dopo attestazione, conserva schede e conoscenze originali.
- Publisher rendeva pubbliche mini-dichiarazioni PNG prima del Fato completo.23 conserva le nuove intenzioni private, usa un vero annuncio completo quando è dovuta una risposta PG, e pubblica il report risolto con una sola ricevuta autorevole.
- Review20 ha rilevato prova transitiva incompleta, anticipazione di PV/posizioni/esiti e allargamento involontario Human.21 corregge insieme i tre difetti.
- Review21 ha rilevato la principale PG auto-risolta: publisher rifiutava stato risolta Native e la proiezione pending perdeva una receipt UI valida.23 separa conferma dell’azione e frame pubblico privato. Difesa ordinaria tracciata asincrona e protetta dal lock del round.

Review/apply:15 verde statico ma apply fermato PRE-DDL per SQLNULL/JSONnull, rollback verificato;16 installata Rootc6d9;17 rossa0/1/0 non installata;18 installata Rootacd4;19 installata Root71bb;20 rossa0/2/1 non installata;21 rossa0/1/0 non installata;22 rossa0/1/0 non installata per omissione6ACL;23 source/materiale0/0/0 installata con6permessi esatti ripristinati. Storia e contatori cumulativi: nessun successo al primo tentativo dichiarato.

## Qualità comparata

| Aspetto | Quinta E | Sesta F, solo segmento disponibile |
|---|---|---|
| Copia delle parole PG | 0 battute complete / 0 sequenze di 5 parole nelle 3 risposte | 0 / 0 nelle 2 risposte allineate |
| Risposta e avanzamento | Ammissione, consegna, luogo e partenza | Ammissione articolata, poi decisioni diverse dei PNG e ingresso Combat |
| Autonomia PNG | Cooperazione simile dei due | Keita rifiuta la sfida; Daichi accetta |
| Ambiente | Domande del pubblico in E1, poi code generiche | Carta/cesta nell'apertura; persone si scostano per lo scontro, venditore richiama cliente |
| Ripetizioni residue | Rassicurazioni e ricapitolazioni | F1 ribadisce ignoranza, pagamento e fonte inventata anche nello stesso turno |
| Finale | Pubblicato | Non disponibile; non valutabile |
| UI nuova pubblicazione | Due difetti di lettura/toast | F0–F2 arrivati su IAB e Chrome senza aggiornamento manuale o rientro; ingresso Combat ancora difettoso |

A copiava battute PG nel finale; B–E hanno progressivamente eliminato quel difetto letterale. F mantiene il miglioramento sulle due risposte osservate. La verifica manuale non trova una parafrasi sostanziale delle role: F1 apre tuttavia nominando la richiesta di un nome, anziché direttamente con una risposta nuova. Le metriche non provano da sole assenza di eco semantiche.

L'ambiente di F2 ha una conseguenza pertinente alla tensione; il campione è breve e non prova varietà sostenuta nell'intera missione. F1 è ricco, F2 è breve ma compie una transizione concreta; non serve un minimo artificiale di parole. La conclusione di F non può essere confrontata con E finché non esiste. Approcci e versioni differenti: nessuna attribuzione causale certa a una singola modifica.

## Verifica della consegna23

C1266 Combat64 · 30/10/2026: aggregata23 installata nella sola Staff dopo review sorgenti e materiale0/0/0, migrazione20261030125227 c1266_combat64_complete_fato_writer_staff. Root c377a3b8b7653a947098b46bca25c58f85efcfdcbbc94f1388940e0981518386 / semantic9133e31533b60ef4362a223c841507760c0842ad1560a93278d397cc43ae0792;236header vivi esatti,16target/ABI esatti,3helper privati service-only e2CHECK validati per combat_intent. Edge123/EZBR1aaca3c2f4cdf7e2af47ec25d9db8838ab30d0168eea5fb3763cf5ac705e1415,14file riletti esatti; LAND UI5 commit49a9059843868c5cbdb330833455002a49559a78/Pages41058214827SUCCESS, build e pin osservati sul dominio. Profilo PNG proiettato solo nel trasporto attestato; future intenzioni private sino al Fato completo, ricevuta del commit PG distinta dal frame pending.39messaggi invariati UTF8,2failed e receipt immutati, meccaniche del report intatte, risorse PG protette. Stessa sesta aperta: nuovo Fato NONPUBBLICATO, ritorno/conclusione NOT_RUN.143HTTP/1,15878290USD prudenti su4,0nuovi provider; finestra QA scaduta11:13/11:19UTC, rinnovo richiesto, nessun reset. Small invariato, nessuna apertura pubblica.

La nuova generazione non è stata avviata dopo la scadenza della finestra. Il confronto ausiliario fra digest JSONB e SHA UTF8 del postflight era errato; la conservazione dei39testi è provata separatamente dagli SHA UTF8 esatti. Nessun testo pubblico è stato modificato.

## Costi, conservazione e limiti

Checkpoint:143HTTP e1,15878290USD prudenti su4USD; sesta8HTTP/0,05627540USD. Due Writer falliti prima del provider:0chiamate/0costo, senza azzerare le riserveCount unknown_billable. Scopeoperativo: stop nuove chiamate11:13UTC, chiusura11:19UTC, stessa finestra originaria.

39messaggi preesistenti (35A–E, F0–F2 e dichiarazioneKeita) verificati invariati al preflight22. Failedwork/receipt storici conservati, report meccanico immutato. PG protetti confrontati nel perimetro dichiarato, non sull’intera riga volatile. Combat lesiva=false, simulated_pools=true, values_written=false; Small invariato, nessun supporto esterno o apertura pubblica.

Le prove statiche non qualificano la nuova generazione, il ritorno narrativo, il finale o la nuova barriera durante un turno reale: esiti da registrare dopo pubblicazione. Corpus integrali e role solo in /private/tmp, mai nel referto pubblicato.
