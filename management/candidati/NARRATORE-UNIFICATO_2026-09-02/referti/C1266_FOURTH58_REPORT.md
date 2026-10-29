# Quarta prova congelata · esito di avvio

Quarta prova richiesta e tentata il 29/10/2026 alle 21:54:17 UTC: avvio ROSSO SQLSTATE42702, column reference "step" is ambiguous, in scene_initialize_v1 linea37. La variabile PL/pgSQL step collide con l’alias della query di identità delle fasi. Nessuna nuova sessione, Fato, role o chiamata provider; richiesta38c0b037 risolta con rejected_no_commit dal comando ordinario, senza ripeterla. Root5fc77 invariata, nessuna patch durante la prova congelata. ABC27Fati e tutti9hash preservati; totale prudente119HTTP/0,98594310USD entro4USD. Missione non completata e qualità Editorial57 NOT_RUN. Correzione minima proposta fuori dalla versione congelata: alias SQL esplicito diverso dalla variabile; poi review pertinente e nuovo avvio reale, senza dichiarare pulito questo tentativo.

## Evidenza tecnica

L’avvio normale Staff con Riuji e Tamako selezionati ha ricevuto 42702 alle 21:54:17.755 UTC. Il log collega staff_test_start → prepare_start → enqueue_opening → scene_initial_opening → scene_initialize linea37. Il corpo vivo MD5 `19c0713a3cd484d73d26b540abeffdcc` conferma la collisione tra variabile `step jsonb` e alias `jsonb_array_elements(...) step`. È un errore SQL precedente al provider: non dimostra un difetto dei prompt né permette una valutazione del nuovo testo.

L’errore transazionale non ha creato sessione. Il comando ordinario Cambia selezione ha risolto l’avvio come `rejected_no_commit`, con ricevuta server conservata. Non è stata cliccata la ripresa e non è stato inviato un secondo avvio. I due client sono disponibili; prima dello start è servito rientrare nella stanza per aggiornare la lista locale dei presenti. Tale aggiornamento non è classificato come gameplay riuscito.

## Risultati richiesti

| Criterio | Esito |
|---|---|
| Avvio senza blocchi | NOT_PASSED: 42702 |
| Completamento missione | NOT_RUN dopo avvio fallito |
| Risposte articolate | NOT_RUN |
| Ambiente vivo | NOT_RUN |
| Nessuna ripresa delle parole PG | NOT_RUN |
| Fati ABC conservati | PASS:27 e9hash invariati |
| Budget | PASS:0USD nuovi;0,98594310USD cumulativi/4 |

## Passo necessario

Correggere l’ambiguità nel solo inizializzatore, componendo un delta sulla baseline viva con review pertinente e identità aggiornata. Conservare prompt, fasi, schede e storico. Non reinstallare la candidata completa arretrata, non mascherare 42702 con retry né considerare la prova congelata superata dopo una patch. L’apertura iniziale della nuova scena rimane il caso concreto da verificare. Nessuna correzione applicativa applicata in questo incarico di collaudo.
