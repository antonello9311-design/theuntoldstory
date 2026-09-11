# MISSION-GENERIC-LIVE-QA-PLAN-001

Stato: piano candidato e ricognizione in sola lettura, non collaudo eseguito. Owner NARRATIVE-QA-PLAN. Mandato: predisporre verifiche live pertinenti della missione generica; zero apply, test, chiamate provider o mutazioni durante questa ricognizione. Data: 11 settembre 2026.

## Preflight vivo rilevato

Sono state lette soltanto colonne di catalogo, identificativi di sessione, presenza dei due PG autorizzati, fase del round, stanze di test e policy non segreta. Nessuna role, messaggio, credenziale o scheda completa è stata estratta.

| Controllo | Risultato vivo |
|---|---|
| testperfunzioni | Presente nello scontro `e4f36e1a-afaf-4d30-a06d-f2f17e6ac391`, aperto |
| Riuji | Presente nello stesso scontro aperto |
| Round attuale osservato | 50, `raccolta_azioni`; il precedente passaggio PM indicava 49, quindi la scena è progredita |
| Contesto scontro | `master_session_id=null`, stanza Test Room con `is_test=true` |
| Master session aperte con questi PG | Nessuna partecipazione corrente restituita dalla lettura dedicata |
| Luoghi con is_test o nome Test/Staff | Una sola riga: Test Room, `0b85f354-9cdb-47e1-baf9-3d266bb7e06b`, attiva e di test |
| Schema generico | Nessuna tabella mission_generic_owner visibile nel catalogo interrogato; candidata non attestata installata |
| Policy narrativa nativa | enabled=false, versione1, Luna/high, input12000, output4096; budget run/day/global NULL |

La scena preesistente non appartiene a questo QA: non chiuderla, sospenderla, resettarla o usarla per la nuova missione. Il dato Sharingan OFF di Riuji proviene dal passaggio PM, non da una nuova verifica di stato in questa ricognizione; non è stato modificato. La sola assenza di una master session non rende liberi PG già impegnati nel Combat.

Ostacoli concreti: entrambi i PG autorizzati sono occupati; non è stata trovata una seconda stanza fisica di test per due chat indipendenti; manca l'installazione generica attestata; policy e quote non sono pronte. La superficie Staff Test Room può essere distinta nell'interfaccia o nel percorso applicativo: il catalogo attuale non autorizza a dichiarare disponibili due location separate. Prima del caso concorrente occorre dimostrarne il contesto effettivo dal sito e dalle ricevute. Non creare nuovi PG, stanze, ruoli o permessi per aggirare questi limiti.

## Prerequisiti immediatamente prima del QA

Il PM congela la composizione e i suoi SHA, registra apply/deploy effettivi e review pertinente. Rileggere versione Edge/build, RPC/gate e disponibilità nelle superfici protette previste; non dedurre la disponibilità da file su GitHub. Registrare policy e admission effettive prima della prima chiamata; un budget NULL non è un consenso a spesa libera. Accedere dal sito con gli utenti realmente autorizzati, senza impersonazioni SQL.

Rileggere disponibilità dei due PG e della stanza, acquisire la superficie di collaudo nel registro, conservare esclusione della scena e4f36e1a. Se resta occupata, il caso dipendente resta non eseguito: nessuna chiusura altrui automatica. La seconda chat richiede roster e location autorizzati e liberi distinti; non duplicare un PG impegnato per produrre un finto risultato concorrente.

Il carrier missione deve essere creato tramite la porta di simulazione prevista, con snapshot/piano approvato, almeno un PNG con profilo autorizzato e due scene con incontri dichiarati. Le mappe vengono dalla configurazione missione, oppure dal ripiego di test esplicito previsto dal prodotto. Non modificare la missione originale già conclusa né riusarne direttamente stato, premi o iscrizioni. Companioni non supportati restano esclusi con errore esplicito: nessuna attestazione generica di tutti i tipi di attore.

Prima/dopo: confrontare impronte o differenze aggregate delle sole risorse/progressione dei PG autorizzati, inventario, XP/valuta/grado, quota mensile missioni e record premi. Non esportare valori di scheda nei referti. Lo stato del test e l'audit possono cambiare; devono restare immutati dati reali e quota ordinaria. `is_test` da solo non dimostra isolamento: confrontare `values_written=false`, fonte delle risorse simulate e assenza di scritture esterne.

## Budget proposto, non ancora attivato

Campagna funzionale minima: massimo 12 chiamate provider e USD2 complessivi, con massimo 20 minuti per ciascun caso live e massimo 40 minuti di esecuzione totale. Il tetto di chiamate comprende incipit, scelte PNG, narrazioni, eventuali errori billable e qualsiasi chiamata automatica prevista; non è 12 per PNG o per chat. Ripartire le admission delle sessioni affinché la loro somma non superi questi limiti, registrando i numeri prima dell'avvio. Review statica della concorrenza: zero chiamate.

Se le quote registrate non consentono il piano completo, eseguire solo il caso autorizzato che vi rientra e consegnare il resto non provato; non aumentare budget in corsa. Fermarsi al primo limite raggiunto, a rischio dati/autorizzazione, o a risposta incerta dopo consumo. Nessun retry per cercare un verde; registrare usage reale, upper_bound se ignota, ID ricevute e stato del work.

## Casi live minimi

| Caso | Percorso reale e osservazione | Criterio di riuscita | Stato attuale |
|---|---|---|---|
| L1: un PG e un PNG, due incontri | Avvio Board della simulazione; incipit; scelta legale PG; decisione PNG; difesa; resolver/esito; chiusura del primo incontro; trigger/nuova visita e secondo incontro | Opening pubblicato una volta prima di attivare run; nessun testo di esito prima dei fatti completi; pannello aggiornato; due encounter distinti con step/control_version/snapshot corretti; nessun residuo del round precedente | Non eseguito: roster occupato, candidata non installata |
| L2: due chat indipendenti | Due sessioni protette con roster disponibili distinti; alternare i normali tick del sito e una normale azione per ciascuna; mantenere un lavoro pending nella prima mentre la seconda avanza | Actor/room/message/claim/costo appartengono sempre alla sessione corretta; assenza di attesa sul provider altrui; nessuna pubblicazione incrociata; restituzione pending idempotente senza seconda chiamata | Non eseguito: seconda location/roster non attestati; non avviare tre scene per sostituirlo |

L1 verifica la nuova infrastruttura; le tecniche già collaudate non richiedono una nuova campagna completa. Se il piano scelto include moltiplicazione/sostituzione, usare soltanto le normali opzioni legalmente offerte e controllarne ricevuta, risorse simulate e prosa coerente, senza aggiungere nuove casistiche dopo il limite.

La terza missione simultanea è coperta qui da review delle invarianti, non da una dichiarazione di prestazioni live. Due sessioni sequenziali nella stessa chat non valgono come prova di due chat concorrenti. Una nuova visita dello stesso step deve avere control_version diverso e non riusare l'incontro precedente; includerla in L1 solo se già prevista dal piano approvato, altrimenti segnare questa variante come non esercitata.

## Matrice della review pertinente, zero provider

| Invariante | Fonti/controllo da raccogliere sulla composizione finale | Fallimento che blocca il percorso |
|---|---|---|
| Tre missioni, isolamento | Tutte le letture/scritture del producer, Panel, resolver, source e publication legano sessione/incontro/attore/visita; nessuno stato globale in memoria del worker | Join privo di sessione, actor non appartenente, testo o quote trasferibili fra sessioni |
| Lock | Ordine sessione→work→contabilità; lock di policy solo durante breve transazione; nessuna transazione DB aperta durante chiamata HTTP provider; review delle nuove porte Progress/Board | Inversione di lock tra moduli o lock globale trattenuto fino al provider |
| Dedup e replay | Request/authority/event/visit vincolati da univocità; claim unico, consume una volta; tick ripetuto osserva lo stesso lavoro, finale incerta solo status | Replay che ricrea work, secondo consume, doppia chat publication |
| Visite e incontri multipli | Chiavi step+control_version+snapshot; encounter mapping distinto per visita; chiusura attestata da report prima del trigger | Riciclo di report/incontro di una visita vecchia o trigger non autorizzato |
| Autorità e testo | Scelte solo da offerte server; prosa dopo barrier completa; combat_publish rilegge report/binding; opening usa bind reale; pubblicazione nativa prima outbox published | Testo anticipato, receipt non verificata, output IA trasformato in valore meccanico |
| Isolamento protetto | Board simulation source, risorse Combat simulate, values_written false, no premio/XP/quota ordinaria; guardie server prima delle scritture | Qualsiasi effetto reale o possibilità di aggirare le guardie con is_test client |
| Quote e fallimenti | Admission per sessione e limite globale registrati; costi exact/upper_bound conservati; work fallito non rigenerato automaticamente | Consumo non contabilizzato, budget NULL illimitato, retry incerto |

Questa matrice è una lista di controlli da svolgere nella review indipendente della candidata composta, non un referto verde già emesso. La lettura del codice non certifica throughput o assenza empirica di deadlock sotto carico; se manca roster autorizzato, dichiarare il limite e non simulare tre provider call come prova.

## Chiusura e consegna evidenze

Alla fine chiudere soltanto le nuove prove create per questo piano attraverso il normale sito, preservando messaggi e audit. Verificare assenza di nuove sessioni residue, confronto risorse reali/progressione/quota senza differenze e assenza di modifiche alla scena preesistente e4f36e1a. Rileggere che eventuale attività concorrente altrui non venga attribuita alla prova.

Referto minimo: build/SHA effettivi, sessioni di prova, passi riusciti/non eseguiti, ricevute/report/publication e stato round, chiamate/costo/tempo, differenze aggregate delle risorse e screenshot del solo pannello se pertinente. Non includere testi completi delle role o segreti. Distinguere chiaramente review superata, percorso collaudato sul sito e comportamento concorrente ancora non esercitato.

Passaggio al PM: piano pronto; esecuzione oggi non avviabile sui due PG finché sono nella scena preesistente. Nessun nuovo consenso richiesto per le letture; nessuna mutazione effettuata. Il PM coordina disponibilità, composizione, quote e superfici reali nel mandato già acquisito.
