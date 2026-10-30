# Sesta prova F — checkpoint e confronto con A–E

30/10/2026 · NON COMPLETATA: ingresso Combat raggiunto, dispatch PNG bloccato prima del provider. Ritorno alla narrazione e conclusione NOT_RUN. Nessuna modifica applicativa, SQL o Edge eseguita durante la prova.

## Versione e ricevute

Sessione `c2faf883-5264-44e3-b1a2-bd9a39876942`, aperta 07:23:56.011546 UTC. Editorial62 congelata: Root `939c725a672fe53eafa33616195ee4f593b2b7a13b98c9bbc017b929283d77e7`, Edge121/EZBR `ed665f6bd431db02934f9f7a5c6c9408ce3e958b94056d4accf243fa17acf876`, UI `C1266-EDITORIAL62-UI1` verificata in entrambi i browser. Revisione7, piano `848a988d-5705-4304-a9e5-172e4e09c725`, schede PNG V6. Sorgente viva e copia di avvio hanno lo stesso SHA `6f8628df584b20e6360ab0807be22078109fff3a72bbc6b4f0b56cdd52b6b93b`.

Tre Fati reali, non rigenerati:

| Fato | Pubblicazione UTC | Parole | SHA256 |
|---|---|---:|---|
| F0 | 07:24:23.785869 | 141 | 0664cea9fae0153100ab425227417b1327a561a5c93b36555cf84990e6bc1a56 |
| F1 | 07:25:51.200917 | 235 | 9c06d50e74f23351c77b04b72e399fa88e0057fc4d4827b10cf231f591504628 |
| F2 | 07:26:37.370120 | 92 | 2abdf577bc062c9aebf9ca07206673d407786c91cd17c14331e6ba1a08413b51 |

Quattro role narrative accettate una volta. Nel Combat: Passa di Tamako `2ceab26a-ae00-47ab-8957-c3790bc62106` e attacco di Riuji `33a37259-a0a8-4419-bb2f-910d97de59fc` accettati una volta; role di attacco pubblicata. Il tentativo di role dopo il Passa è stato fermato dal client, non accettato e non reinviato. Nessuna duplicazione delle dichiarazioni.

## Percorso realmente osservato

F0 apre il primo incontro; F1 risponde a domande e contestazioni e passa a `conclusione`; F2 risponde alla scelta esplicita dei PG di cercare lo scontro e apre `combat:fase_3`. Daichi accetta, Keita si dissocia. Incontro `b3135a23-78c5-4c45-a730-b1de8257367b`, round `dfe85868-7d6b-4018-bacd-49acb5a51e1f`. Mappa operativa e pannello comune accessibili; Riuji selezionato esplicitamente dal suo account, nessun subentro come Master o impersonazione.

Il round è in raccolta_difese, con difesa PNG ancora da fornire. Sessione in corso, scena combat/fase_3, tre lavori narrativi completed. Nessuna nuova lavorazione IA Combat persistita: la transazione di dispatch si interrompe prima del provider.

## Difetti tecnici osservati e causa

**Dispatch Combat bloccante.** Alle 07:30:13.263 UTC i log Edge riportano RPC `mission_generic_event_next_v1`, SQLSTATE P0001, guard `MRS_V4_DISPATCH_LEGACY_KIND`. Evento `3afb10f0-839e-f571-c075-9f501528b1f9` versione107, source_id pari alla dichiarazione Riuji, stato uncertain; nessun work_id o canonical_request. Non è un timeout del provider né un testo rifiutato.

Il corpo vivo di `role_dispatch_assert_v4` (MD5 `6ec976f8bbc3b613722f3692b403a39d`) delega la classificazione Combat a `role_native_combat_work_class_v4`. Per choice quest'ultimo richiede un collegamento a unified_round_windows/unified_batches. L'apertura del nuovo percorso narrativo ha invece una ricevuta autorevole in scene_sources_v1. In questa sessione esiste l'encounter e la ricevuta di apertura pubblicata, ma non esistono round_windows/batches; la choice non viene riconosciuta e ricade nel rifiuto legacy. La selezione corrente fallisce nella medesima transazione: non va ricreata reinviando la role.

**Ingresso UI ambiguo.** In Combat già aperto sono esposti sia Apri scontro sia Scegli l'azione nel pannello Scontro. Il primo passa ancora da prepareEntry e crea un journal locale; prepare_v1 instrada verso scene_player_entry_prepare_v1 mentre state_v1 usa il ramo Combat. L'helper scene, non potendo preparare un secondo ingresso, restituisce lo stato senza creare una nuova ricevuta. Il reader della richiesta risponde not_found e il client blocca il proprio bottone con “Ricevuta assente”. Una sola ripetizione della stessa apertura non risolve. Il pannello comune ordinario ha consentito di proseguire legittimamente dopo ricarica e selezione del PG; nessuna protezione è stata rimossa. È un recupero operativo, non un PASS del pulsante iniziale.

**Passa e role.** Il Passa viene registrato immediatamente dal pannello, senza la role. Un successivo invio narrativo viene respinto dal client con la richiesta di scegliere prima un'azione, pur essendo la scelta già confermata. Questo va chiarito e raccordato nel percorso comune; non va aggirato con una seconda dichiarazione.

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

## Correzione proposta, non applicata

1. Integrare il classificatore del dispatch con la ricevuta di apertura del percorso scene, verificando identità sessione/round/encounter, autorevolezza e hash del Fato, finestra corrente, attore PNG, capacità/offerte legali e payload. Conservare il ramo unified precedente per le sole risorse pertinenti; nessuna accettazione generica di kind o campi e nessuna rimozione di guardie.
2. Allineare state/prepare/receipt del pannello: quando Combat è già pubblicato e aperto si apre il pannello esistente, senza preparare un nuovo ingresso. Il recupero della richiesta locale deve avere un esito autorevole, senza cancellare journal alla cieca.
3. Collegare coerentemente Passa e role, con un solo invio autorevole e messaggi UI che distinguano scelta già registrata da role mancante.
4. Dopo candidata integrata, baseline e review indipendente pertinente 0/0/0, installare il delta riservato Staff e recuperare l'evento107 dalle due dichiarazioni esistenti. Provare difesa PNG, fatti server, Fato unico, ritorno alla narrazione e chiusura della stessa missione, entro il residuo di budget. Nessuna rigenerazione di F0–F2.
5. Per la prosa: ridurre ricapitolazioni interne dei fatti già ammessi; usare oggetti, lavoro e reazioni locali come conseguenze disponibili, senza quote, eventi obbligatori o filtri bloccanti. Non modificare prompt o schede durante questa prova per cercare un esito migliore.

## Costi e conservazione

Sei nuove HTTP: tre coppie Count/Generation. Costo prudente F 0,04296710 USD, totale campagna 141 HTTP / **1,14547460 USD su 4 USD**. Tre Generation settled: 0,00576710 USD; tre Count unknown_billable mantengono le riserve complessive 0,0372 USD. Non sono costi certi pari a zero. Nessuna chiamata IA Combat dopo il blocco.

I 35 Fati A–E e tutti gli otto SHA256 di conservazione più conteggio sono identici al preflight. I tre Fati F portano il totale a38. Campi delle schede PG protetti invariati secondo il perimetro dichiarato nella query; Combat lesiva=false, simulated_pools=true, values_written=false. Small invariato. Nessuna apertura pubblica. La sessione F resta aperta per il recupero; missione conclusa e assenza di residui NON dichiarate.

Corpus integrali, role e screenshot conservati soltanto in /private/tmp/tus-c1266-sixth63-20261030/. Questo referto contiene metadati e analisi sanitizzata, non i testi integrali.
