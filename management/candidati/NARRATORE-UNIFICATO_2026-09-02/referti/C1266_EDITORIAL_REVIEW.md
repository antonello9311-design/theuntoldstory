# Review comparata A/B/C della Regia IA

29/10/2026 · La terza scena ha pubblicato il Fato conclusivo C5 alle 18:17:53 UTC. Chiusura amministrativa Staff confermata dal comando ordinario, con ricevuta server conservata. Nessuna quarta prova avviata. I Fati pubblicati non sono stati riscritti.

## Evidenze e limiti del confronto

| Aspetto | Prima prova A | Seconda prova B | Terza prova C |
|---|---|---|---|
| Fati pubblicati | 12 | 9 | 6: incipit e cinque risposte |
| Riprese letterali dei PG | Tre battute nel Fato di uscita: 606/1276 caratteri, 47,5%; corpus Combat non completo | Nessuna battuta PG completa nelle otto risposte | Nessuna battuta PG completa nelle risposte esaminate; nessuna sequenza comune di cinque parole nelle cinque risposte allineate |
| Riprese semantiche | Ripubblicazione di gesti e parlato PG | Finale riepilogativo | C1 riprende una domanda; C3 ripete il non incontro; C4 ricapitola l’ammissione prima di renderla pubblica; C5 ripete la disponibilità, ma accetta l’accompagnamento |
| «brusio» | 11/12 | 9/9 | 0/6 |
| «mascella» | 8/12 | 2/9 | 3/6, tutte nel segmento precedente C0–C3 |
| Ambiente | Sfondo sonoro ripetuto | Poco autonomo, spesso ridotto al brusio | C0–C3: venditori/passaggio/botteghe seriali. C4: il capannello si allenta e una venditrice riprende a servire. C5: riprendono contrattazioni e attraversamenti, ma il gruppo resta ancora pronto a partire |
| Avanzamento | Dialogo, Combat e conclusione | Informazioni nuove B3/B4, stasi B5/B6, conclusione | C3: pagamento e foglio; C4: ritrattazione pubblica; C5: consenso ad accompagnare i PG e fase conclusa |

Le misure testuali servono alla review, non sono nuovi filtri bloccanti. Approcci e versioni differiscono; il confronto non è un esperimento controllato. C0–C3 sono stati prodotti con un contesto legacy concorrente; C4–C5 usano il nuovo percorso narrativo diretto N56. Non è lecito attribuire al nuovo impianto una missione intera senza interruzioni: su questa missione sono state necessarie correzioni e l’apertura sulla versione finale non è stata provata.

## Lettura della terza prova

C1 risponde, ma riprende la formulazione della domanda e tende a ripetere il contesto. C2 espone ancora una precauzione di scrittura attraverso il PNG: «Se provo a riempire questo spazio con un dettaglio, me lo invento». Il limite di conoscenza è legittimo; questo modo di raccontarlo impoverisce il personaggio. C3 porta il vero passo avanti: busta, monete, foglio e motivo della falsa fonte; Keita prende una decisione distinta. Rimangono gesti ricorrenti e un caporale finale superfluo.

C4 risponde alle richieste già accettate senza copiarne le battute: Daichi corregge pubblicamente l’accusa e offre di indicare il luogo; Keita conferma la propria responsabilità. L’ambiente comincia a mostrare una conseguenza sociale, senza reagire unanimemente. Tuttavia il testo ripercorre informazioni già note e chiude con un bilancio del narratore su ciò che può essere riferito e ciò che resta da accertare.

C5 risponde alle nuove azioni una sola volta: entrambi accettano di accompagnare i PG. Le voci rimangono vicine per lessico e impostazione; le formule prudenti continuano a occupare il dialogo. Il congedo è registrato come conclusione, ma la scena mostra ancora persone pronte a seguire, invece dell’effettivo distacco dalla piazza. L’ultima frase ripropone l’elenco delle questioni da verificare. È una risposta coerente, non ancora una chiusura narrativa pienamente riuscita.

## Cause strutturali osservate

Le difficoltà editoriali non dipendono soprattutto dalle regole Combat. Il vecchio percorso interrogava contratti meccanici anche per normali conversazioni. Inoltre un helper sostituiva schede e note frozen di C con un blocco legacy contenente gesti e limiti ripetitivi: modificare soltanto le schede non bastava.

N56 separa la narrazione ordinaria dalla risoluzione Combat: il modello lavora sulle schede e fasi selezionate, sull’ambiente, sulla memoria e sulle azioni acquisite. Autenticazione, isolamento, costi e pubblicazione rimangono server-side. Nel tratto finale sono emersi ulteriori disallineamenti tecnici: colonna di ordinamento role errata, sender pubblico nullo nel normale invio, classificazione SQL che attivava retry automatici, permesso del dispatcher non ancora legato al lavoro, lettore storico incompatibile con l’attestazione nuova. Questi errori sono distinti dalla qualità della prosa e conservati nei referti, senza azzerare i contatori.

Dopo l’aggregata 6, C4 e C5 hanno prodotto ciascuno un Fato con una sola Count e una sola Generation; C5 è partito automaticamente dalle due nuove azioni normali. Nessuna rigenerazione editoriale, nessuna modifica ai Fati precedenti. Il Fato finale è leggibile anche uscendo e rientrando nella Staff Room. Il rientro ha corretto anche una proiezione rimasta in attesa sul browser di Riuji: questo comportamento va risolto, non qualificato come aggiornamento automatico riuscito.

La chiusura amministrativa ha evidenziato un’altra confusione: le Count con costo prudenzialmente riservato sono trattate come richieste ancora in corso anche quando il relativo lavoro è terminato. La correzione finale, review indipendente 0/0/0 e delta di due funzioni, distingue la Count completata con prova autorevole da una generazione realmente incerta; riconosce inoltre il doppio audit della vecchia apertura. Costi e stati della quota rimangono intatti. La review ha individuato anche il tentativo di terminalizzare nuovamente un run già concluso: aggregata7 respinta prima dell’installazione, aggregata8 corretta e verificata 0/0/0. Nessun costo ignoto viene trasformato in zero o dichiarato esatto.

## Cambiamenti proposti prima della quarta

1. **Un’unica composizione del pannello.** Corpo della scena, stato evento, recupero e conclusione devono essere renderizzati insieme. Oggi l’aggiornamento manuale può cancellare il riquadro di recupero; un rientro lo ripristina. Anche lo stato di attesa della seconda role deve dirlo chiaramente, senza annunciare una generazione già in corso. Nessun polling aggiuntivo.
2. **Una sola versione completa e congelata.** Producer, lettore, dispatcher, Count, Generation, salvataggio, pubblicazione e chiusura devono condividere lo stesso contratto. Verificare le forme realmente prodotte dal sito, non assumere che una review statica sostituisca il percorso giocato. Contabilità incerta e lavoro pendente devono avere significati distinti.
3. **Istruzioni generali di conseguenza.** Considerare parole e gesti PG già acquisiti. Iniziare dalla risposta o dalla conseguenza nuova, senza citarli, riformularli o certificarli. La memoria privata conserva il riepilogo; il racconto mostra quello che accade adesso.
4. **Schede con spazio positivo di gioco.** Esplicitare fatti conosciuti, obiettivi, interessi, timori, rapporti e iniziative possibili. Distinguere ignoranza, reticenza e menzogna. Conservare i limiti di conoscenza senza accumulare divieti che diventano battute. Differenziare le voci attraverso atteggiamento e scelte, non imponendo tic o gesti fissi.
5. **Fasi aperte ma produttive.** Descrivere situazione, informazioni disponibili, possibilità d’azione e condizioni di uscita; evitare una sequenza obbligata di domande e confessioni. Rendere disponibili risposte articolate quando motivate. Un accordo o una ritrattazione acquisiti devono produrre un seguito, senza richiedere una nuova conferma identica.
6. **Ambiente con continuità.** Attività, ostacoli, distanze, presenze e reazioni locali possono cambiare il ritmo e le possibilità della scena. Evitare il paragrafo fisso di rumori e passanti sostituiti con sinonimi. Non ogni elemento ambientale deve diventare un indizio.
7. **Conclusioni osservabili.** Mostrare un congedo, uno spostamento o una conseguenza consentita dalle azioni, invece di chiudere con una lista di conoscenze e incognite. Non inventare decisioni ulteriori dei PG. Le questioni investigative aperte possono restare nella memoria senza essere recitate dal narratore a ogni turno.

Nessun minimo obbligatorio di battute, paragrafi o dettagli; nessun nuovo filtro lessicale che blocchi il turno. Le modifiche editoriali proposte non sono state applicate retroattivamente ai sei Fati C.

## Quarta prova: criterio di verifica

Non avviata. Prima del via fissare una sola versione integrata e i casi necessari. Il percorso dovrà partire dall’incipit e terminare con pubblicazione e chiusura Staff senza correzioni durante la stessa esecuzione. Un difetto osservato resta un difetto: non si rinomina la prova per dichiararla pulita.

Separatamente va giocato il percorso di ingresso Combat sulla mappa operativa nel turno legale del PG: meccaniche prima, role dopo, Regia coerente con i fatti server; nessuna azione Combat mutante durante il Fato. Il segmento finale pacifico C4–C5 non prova questa funzionalità. La chiusura ordinaria Staff è confermata alle 18:30:55 UTC: sei passi completati, capacità terminale normale e nessun lavoro, dispatch, fonte o outbox pendente. Nessuna apertura pubblica implicita.

## Contabilità e conservazione

A: 62 HTTP, 0,47600170 USD. B: 37 HTTP, 0,33861150 USD. C: 20 HTTP, 10 Count e 10 Generation, 0,17132990 USD. Totale prudenziale: **119 HTTP e 0,98594310 USD su 4 USD autorizzati**. I valori includono le riserve quando il costo non è liquidato; non sono una fattura definitiva. Il precedente totale 0,9433573 ometteva due chiamate storiche A/B: riconciliate verso l’alto senza nuovi invii né reset.

I campi di gameplay delle due schede protette hanno hash identico al preflight. Il loro hash integrale cambia nei campi esclusi di metadati/presentazione; non viene dichiarata identità integrale delle righe. Nessun premio reale è autorizzato.

Sono conservati 27 Fati A/B/C, le azioni accettate e le ricevute tecniche. I 101 vecchi Fati di altre missioni erano già stati eliminati nel precedente mandato; nessun’altra cancellazione eseguita durante questa chiusura. L’analisi è sanitizzata: nessuna role PG integrale o contenuto privato delle schede PNG nel report pubblico.
