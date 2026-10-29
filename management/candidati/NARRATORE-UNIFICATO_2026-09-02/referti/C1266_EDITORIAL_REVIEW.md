# Review comparata A/B/C della Regia IA

29/10/2026 · C parziale: incipit e tre esiti pubblicati, quarta coppia di azioni accettata ma senza Fato. Missione non conclusa. Nessun Fato pubblicato è stato riscritto.

## Confronto dei testi

| Aspetto | Prima prova A | Seconda prova B | Terza prova C, parziale |
|---|---|---|---|
| Fati conservati per il confronto | 12 | 9 | 4: incipit + 3 risposte |
| Riprese letterali PG | Nel Fato di uscita tre battute PG:606/1276 caratteri,47,5%; roleCombat non tutte nel corpus narrativo | Nessuna battuta PG completa nelle8risposte | Nessuna battuta completa o sequenza comune di5parole nelle3risposte allineate |
| Riprese semantiche | Gesti e parlato dei PG ripubblicati | Finale riassume quanto detto dai PG | C1 riformula una domanda; C3 ribadisce il non incontro prima del nuovo contenuto |
| «brusio» | 11/12 | 9/9 | 0/4 |
| «mascella» | 8/12 | 2/9 | 3/4 |
| Ambiente | Prevalente sfondo sonoro ripetuto | Ripetizione del brusio e poca attività autonoma | Venditori, passaggio e botteghe in4/4: varia la parola, rimane seriale la funzione |
| Avanzamento | Dialogo, Combat, uscita e conclusione | B3/B4 portano informazioni; B5/B6 reiterano; finale riepilogativo | C3 fa emergere pagamento, foglio e motivo della falsa fonte; Keita sceglie autonomamente di smettere |

Il confronto è esplorativo: approcci diversi e modifiche durante B. C0–C3 hanno contesto misto: Edge117 e ambiente aggiornato, ma attori e note di fase provenienti ancora da un blocco legacy. Non sono una prova valida dell’intero nuovo impianto V4. Dopo la correzione del collegamento non è ancora stato pubblicato un nuovo Fato.

In C2 il vincolo entra ancora nella voce del PNG: «Se provo a riempire questo spazio con un dettaglio, me lo invento». La risposta è più lunga, ma spiega una precauzione di scrittura invece di sviluppare interamente il personaggio. C3 migliora: le ammissioni hanno motivazioni e una scelta distinta di Keita; rimane il repertorio di mascella/sguardo/pausa e un caporale finale in più (5aperture/6chiusure).

## Cause individuate

Il problema non deriva principalmente dalle regole di gioco. Il limite di conoscenza rimane corretto; è errata la sua trasformazione in battute o spiegazioni del narratore. Sono emersi anche difetti d’integrazione dimostrati: il precedente helper riconosceva il frozen solo per la fonte B e applicava a C un JSON fisso, comprese mascella e gesti. Il nuovo ambiente passava perché quel blocco non lo sovrascriveva. Il solo aggiornamento delle schede non poteva eliminare questa istruzione concorrente.

Il quarto turno incontra un errore diverso: il producer ammette interpretazioni PG vuote che il consumer rifiuta. Il risultato salvato include inoltre un movimento sostenuto da un frammento che non prova movimento. Non è lecito inventare una nuova interpretazione meccanica per far passare il turno. La prima candidata producer è stata respinta dalla review: guida aggiunta a una variabile sovrascritta e alternative anyOf non compatibili con il provider. Nessuna sua installazione o nuova chiamata.

## Correzioni effettivamente applicate

Tre helper e Root unica a9e35776c3c35cfbbab884e5b5cd01355370bbf8c716e7faf2af79ac85adb8b7: fonte primaria C esatta, fasi e routes dalla revisione immutabile selezionata. Rimossi i rami attivi A/B, le registry43/55 e un metadato source non consumato. Edge117 e client invariati. Review indipendente materiale0/0/0, parsing integrale e postflight corpi/Root esatti. Nessun effetto su budget o dati PG. Il recupero C4 resta aperto: questa installazione non lo certifica.

Sono stati eliminati fisicamente i101messaggi Fato di altre sessioni missione Staff, con i collegamenti di pubblicazione necessari. I25Fati A/B/C sono identici e restano conservati fino al termine effettivo del collaudo, poi Antonello ne ha autorizzato l’eliminazione. Meccaniche, dichiarazioni native, quota e copie tecniche provider/audit/request restano; non si dichiara cancellazione di ogni copia tecnica dei testi. Gli altri254messaggi Fato Staff fuori da quelle missioni non appartenevano ai101autorizzati e sono intatti.

Errori operativi conservati: una transazione cleanup è stata annullata per l’indice parziale di preparazione; corretta usando retired_at, senza togliere l’indice. Una migrazione helper è stata annullata per un hash DDL calcolato sulla forma del file invece che sulla forma canonica PostgreSQL; builder e review corretti, poi installazione verificata. I rollback non vengono qualificati come installazioni riuscite e i conteggi non sono azzerati.

## Cambiamenti per il risultato desiderato

- Una sola fonte di istruzioni effettivamente consegnata a Director e Writer; verificarla sulla richiesta composta, non dal nome di una costante modificata.
- Separare fatti noti e ignoti dalle indicazioni di recitazione. L’ignoranza può produrre un dubbio, un rifiuto o una scelta, senza spiegare il vincolo di scrittura.
- Far decidere al Director risposte, iniziative e conseguenze attuali; il Writer le rende osservabili senza riassumere le role o ripubblicare gesti e parole dei PG.
- Dare continuità alle attività del luogo, alle distanze e alle presenze. L’ambiente può vivere anche senza fornire un indizio o reagire unanimemente al dialogo; evitare un repertorio fisso sostituito a ogni turno da sinonimi.
- Tenere distinti ciò che è già acquisito e ciò che cambia adesso. Accordi, ritrattazioni e congedi devono avere seguito concreto, senza riproporre la medesima disponibilità a ogni risposta.
- Un unico contratto producer/consumer per il formato. Un errore di trasporto si recupera tecnicamente dalle azioni accettate, senza mascherarlo come problema editoriale o autorizzare meccaniche inesistenti.

Non sono proposti numeri fissi di battute, paragrafi o dettagli. I prossimi esiti dovranno dimostrare questi comportamenti sul percorso effettivo, senza rigenerazioni per cercare un testo migliore.

## Contabilità e stato

A+B:97HTTP/0,8007126USD prudenti. C:16HTTP,8Count+8Generation,0,1426447USD prudenti. Totale0,9433573dei4USD. La usage Count sconosciuta rimane riservata economicamente; non viene contata come costo zero. Nessuna chiamata provider in corso. Otto azioni C accettate una volta, quarta coppia senza risposta. QA completo e conclusione C: NON_PASSED. Nuovo impianto frozen dopo a9: NOT_RUN. Nessuna terza missione completa senza blocchi è dichiarata.
