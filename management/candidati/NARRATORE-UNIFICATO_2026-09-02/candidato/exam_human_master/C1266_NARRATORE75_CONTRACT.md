# C1266 Narratore75 — contratto di attuazione

Flusso deciso dall’utente, non riaperto: azioni accettate → selezione privata delle opzioni legali per i PNG quando serve → server e attesa delle risposte dovute → esiti meccanici completi → unico Fato completo → prossimo turno. In narrazione ordinaria il narratore usa direttamente missione, fase, mappa, mondo, schede, memoria e azioni ricevute. Non esiste un autore intermedio che scrive un piano o battute da far rielaborare.

La selezione privata è un’operazione del narratore: sceglie fra le opzioni offerte, non determina valori o risultati. Se il server attende un giocatore, non si produce un Fato per sbloccarlo. Il pannello mostra le sole dichiarazioni/risposte legalmente disponibili; durante l’attesa del Fato non concede un nuovo turno libero. Il Fato Combat riceve soltanto conseguenze autorevoli complete per lo scambio corrente, senza annunciare nuove offensive irrisolte.

## Cambiamenti necessari

Le fonti vive139/34 mostrano una dipendenza del percorso missione dal Fato intermedio prima delle difese. Va rimossa in modo coordinato fra gate server, avanzamento, proiezione capacità, UI e fonte del narratore. Non basta cancellare la chiamata Director lasciando il relativo blocco. I vecchi risultati e recuperi restano leggibili, ma non diventano input operativi del nuovo narratore. Non si rimuovono autenticazione, isolamento, autorità meccanica, idempotenza, audit o rendicontazione.

Il nuovo narratore riceve informazioni nelle rispettive fonti autorevoli. Le istruzioni rimangono generali: usare gli elementi della missione/mappa e gli sviluppi coerenti col mondo; rispondere alle azioni attraverso PNG, ambiente e conseguenze disponibili, senza riprendere le parole dei PG o esporre i vincoli nel racconto. Nessuna ricetta specifica della scena, filtro stilistico bloccante o rigenerazione per cercare un testo migliore.

## Vincolo tecnico modificato esplicitamente

Si sostituisce soltanto `editorial_campaigns_v1_source_refs_check1`, mantenendo invariati nome e conteggio dei68vincoli: le vecchie policy richiedono3fonti; la nuova `staff-combat-report-policy/1` richiede1fonte. Espressione: `(jsonb_array_length(source_refs)=3 AND policy->>'schema_version' IS DISTINCT FROM 'staff-combat-report-policy/1') OR (jsonb_array_length(source_refs)=1 AND COALESCE(policy->>'schema_version','')='staff-combat-report-policy/1')`. Nessun altro vincolo, firma, ACL o autorità viene allentato. La precedente INSTALL23 è stata respinta da questoCHECK, con rollback verificato e0provider. Il recupero conserva fonti e risultati della nuova policy: non ripristina un vincolo che renderebbe invalido lo storico appena creato.

## Verifica immediata del trattamento degli esiti

Un nuovo esito privato dal report reale concluso della sesta prova mostra come il narratore tratta da solo le conseguenze già risolte. Il corpus resta immutabile e non vengono eseguite di nuovo azioni o meccaniche. Non contiene il piano di un Director né invoca un Director. Il risultato avrà ricevuta e rendicontazione proprie; nessun Fato pubblicato verrà sostituito. Questa verifica copre la scrittura dagli esiti, non qualifica da sola l’intero raccordo selezione/attesa/difesa/risoluzione.

Limiti della singola verifica:1caso,1Count+1Generation/2HTTP,120000token input e20000output massimi,0,044USD aggiuntivi entro4USD totali. Finestra20minprovider+10minchiusura dal veroenable,nessunretry. Stato iniziale230HTTP/2,12926070USD prudente con tutte riserve precedenti. Nessun cambiamento aSmall o apertura agli utenti.

Review aggregata25 in continuità1–24;source23/24,fallimenti e correzioni conservati. Confronto baseline, candidata integrata e review indipendente prima diapply/deployStaff. Non si dichiara eliminato il Director nel gioco completo sulla sola base dell’anteprima.

## Correzione25 del confine dati e recupero tecnico

La proiezione di trasporto canonica `narrativeActorPersonaView` viene applicata dopo la verifica della scena sigillata,prima di validateKnowledge e dell’input al narratore. Non cambia snapshot,hash,fatti,limiti di conoscenza o validatore. Il precedente avvio5e338b9a si è fermato prima di Count/Generation: tutti gli identificativi request/receipt/authorization/count/generation e request/raw eranoNULL,con audit preprovider_rejected e0calls.

La normale portaStaff può recuperare soltanto questo stesso avvio,source e policy invariati,entro le deadline originali e senza tentativo provider precedente. Prima dell’avanzamento viene conservata in audit autorevole la fotografia integrale della riga fallita,il testo canonico eSHAserver47f123ee26d98e0008e638506adede3d240b54a34e7a23260e9c7692823aae9d,con causa,risultato e vecchiofinalized_at. La nuova fase attiva richiede state=ready e finalized_at=NULL per ilCHECKesistente; gli altri campi originali restano conservati e il successivo lifecycle resta auditato. Non si allenta alcunCHECK per il recupero e non si azzerano chiamate,costi,contatori o storico. Il vecchiofallimento rimane attestato.

NessunENABLE25: provider_deadline22:27:48.837532UTC/close22:37:48.837532UTC rimangono quelli dell’avvio22:07:48.837532UTC. Budget1Count1Generation/2HTTP/.044entro4invariato.
