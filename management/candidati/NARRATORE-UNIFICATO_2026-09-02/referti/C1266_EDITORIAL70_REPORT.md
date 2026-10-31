# E70 — confronto delle tre nuove prove con E68

Le tre nuove coppie Director→Writer sono concluse. Tutti i sei stage hanno completato il percorso dai normali comandi Staff, con un solo tentativo per stage, senza blocchi durante le chiamate IA e senza rigenerazioni editoriali. La campagna è chiusa; risultati, memorie, ricevute e costi sono conservati.

La qualità desiderata non è ancora raggiunta. Le risposte restano pertinenti e prive di riprese estese delle domande, ma crescono soprattutto in lunghezza. Ambiente e custodia tornano spesso nella chiusa; alcuni sviluppi ripetono fatti già acquisiti. La memoria contiene ancora unità incomplete.

**Esito tecnico delle tre coppie: positivo. Esito editoriale: PARTIAL_NOT_PASSED. Memoria privata: NOT_PASSED.** Questi esiti sono distinti dalla riuscita di una missione completa, che E70 non ha rigiocato.

## Il confronto è sugli stessi input narrativi

E70 riusa esattamente le domande, la memoria iniziale, la cronaca reale F1/F2, le fasi V8 e le schede V7 di E68. Cambiano le identità tecniche della campagna e dei nuovi run. Il confronto indipendente, dopo inversione di quella mappa di ID, restituisce le stesse fonti narrative; non sono state copiate le memorie difettose generate in E68.

Le istruzioni applicate sono quelle E69 congelate: nuovo orientamento del Director dialogico, WriterScene5 response/9 e memoria semantica. Non sono state ritoccate durante le prove. Per ottenere sei slot nuovi è stata creata una campagna distinta, aggiornando i collegamenti tecnici della porta e la sua ammissione finanziaria a 0,264 USD; letture e risultati E68 sono rimasti separati e disponibili. Nelle richieste effettive sono presenti quelle istruzioni, le domande del caso e il piano nuovo del relativo Director. Le ricevute collegano parent e Writer con run, request, raw e result SHA coerenti; il Director risulta finalizzato prima dell’avvio provider del Writer.

Questa comparabilità è migliore di quella fra E65, E66 ed E68, che usavano momenti o tipi di valutazione differenti. Restano tre campioni, uno per caso: non bastano per attribuire statisticamente ogni differenza ai prompt o dimostrare stabilità in altre scene.

## Che cosa cambia nei testi

| Caso | E68 | E70 | Valutazione |
|---|---:|---:|---|
| 1 — foglio e aggiunte personali | 675 caratteri | 732 caratteri | Distinzione chiara, ma poco seguito nuovo. Il foglio aperto viene ribadito anche nella chiusa. |
| 2 — motivazioni e dissenso | 952 caratteri | 1.337 caratteri | Risposta più articolata e toni più visibili; la fonte inventata viene nuovamente spiegata e ripetuta. Ambiente ancora in coda. |
| 3 — rettifica pratica | 700 caratteri | 1.180 caratteri | Il Director fa compiere subito una rettifica autonoma, ma la rettifica pubblica era già avvenuta in F2. La maggiore attività non equivale quindi a un avanzamento sostanziale nuovo. |

Il dato positivo sulle parole attribuite ai PG si conserva: nessun cinquegramma condiviso con le domande nei tre testi. Le citazioni delle domande nel piano privato del Director sono prove di provenienza, non parlato ricopiato nel Fato. Le misure lessicali restano consultive: non certificano assenza di ripetizione semantica.

Le conoscenze essenziali restano coerenti. Non compaiono un mandante identificato, nuove prove o testimoni informati. Il foglio non viene consegnato senza autorizzazione e i PG non ricevono nuove battute, movimenti o consensi imposti.

Nel caso 2 il parlato distingue più chiaramente la scelta personale di Keita dall’invenzione di Daichi. Tuttavia Daichi torna due volte, nello stesso passaggio, sulla propria falsa fonte. Il testo è più lungo e più esplicito, senza un aumento equivalente del contenuto nuovo.

Nel caso 3 c’è una differenza reale rispetto al rinvio di E68: i PNG prendono la parola e correggono subito le accuse. Il problema è la cronaca. F2 conteneva già ammissioni e rettifica davanti ai presenti. Il nuovo piano tratta un’altra rettifica come seguito, invece di sviluppare la decisione ancora aperta. La memoria stessa distingue una prima e una nuova rettifica. Va quindi riconosciuto il gesto corrente senza scambiarlo per una conseguenza sostanzialmente diversa.

## Il limite è già nella pianificazione

Tutte le sei iniziative PNG scelte dai Director restano speak. Non è necessario imporre gesti o movimento a ogni risposta; il dato mostra però che la maggiore autonomia richiesta non si è tradotta, in questi campioni, in un ventaglio narrativo più ricco.

I tre world_reaction_intent conservano soprattutto mercato in attività, varco libero e ascoltatori ai margini. Il Writer segue questo orientamento e riprende carta, foglio o passaggio nella coda. Il luogo resta riconoscibile, ma entra poco nelle conseguenze dello scambio. Anche la confezione dell’acquisto, già presente in F1 e segnata come dettaglio usato, viene nuovamente descritta in prosecuzione.

Questa evidenza colloca una parte del problema a monte del Writer: il piano non distingue abbastanza ciò che è già esaurito da ciò che può cambiare adesso. Non dimostra che il Writer sia privo di responsabilità: la sua realizzazione continua a ricertificare custodia, disponibilità e confini personali, talvolta esplicitando che una proposta è soltanto una proposta.

## Memoria: ora è provato il confine del difetto

Nei nuovi risultati non compare una nota inglese di lavorazione analoga a quella di E68. Rimangono quattro unità incomplete:

- caso 1: una voce used di 90 caratteri termina dentro una parola;
- caso 2: una voce used di 90 e una known di 180 caratteri terminano senza completare il significato;
- caso 3: una voce known di 180 caratteri termina con una parola incompleta e U+00AD.

La nuova verifica ha estratto soltanto scene_memory dal JSON finale conservato dei tre Writer, insieme ai metadati di hash. Tutte e tre le memorie del JSON finale coincidono integralmente con quelle normalizzate e salvate. Lunghezze e hash UTF8 delle quattro unità difettose sono stati ricontrollati indipendentemente.

**I frammenti sono già presenti nel JSON finale ricevuto prima della normalizzazione applicativa e del salvataggio del risultato.** Per queste unità non si osserva un taglio introdotto da quei due passaggi. La coincidenza con i limiti 90/180 resta rilevante, ma non prova da sola se il problema nasca dalla generazione o dal decoder strutturato interno al provider. Quella causa interna rimane non dimostrata. Non sono stati letti ragionamenti nascosti o l’intera risposta provider.

Resta anche un problema semantico: nel caso 2 known conserva soltanto due voci, una incompleta, mentre la custodia attuale del foglio compare in open. Un fatto presente e un seguito ancora da decidere non sono la stessa categoria. La validità del JSON e lo stato completed/ok non attestano completezza, attribuzione o utilità della memoria.

L’outcome precedente, che lasciava sconosciuto l’intero confine raw→normalizzato, è conservato in review/before_raw; la nuova evidenza aggiorna la diagnosi senza riscrivere la sua provenienza. Nessuna memoria o testo originale è stato corretto.

## Percorso, costi e chiusura

Prima dell’ENABLE è emerso un falso negativo nella sola query postflight: una sostituzione globale di STAGE alterava sei riferimenti storici nel letterale Root atteso. Il Root installato era corretto. Il generatore readonly è stato corretto e verificato senza cambiare prompt, codice applicativo o database. Questa anomalia di preparazione resta nel resoconto; è separata dalla pipeline successiva dei sei stage, completata senza blocchi o retry IA.

Sono state effettuate 6 Count e 6 Generation, per 12 HTTP. Le Generation sono liquidate per **0,01122470 USD**; le Count conservano **0,13200000 USD** di riserva unknown_billable. L’incremento prudente è **0,14322470 USD su 0,264 autorizzati**, contro 0,14193490 USD per E68. Il cumulativo è **1,84208020 USD su 4**, con 206 HTTP storici complessivi. Le riserve Count restano contabilizzate e non sono rimborsi o costi liquidati a zero.

L’ultimo stage risulta finalizzato alle 14:26:27.464593 UTC del 31 ottobre, entro la finestra avviata realmente alle 14:20:48.055366 UTC. Le scadenze originarie delle 15:35:48 per nuove chiamate e 15:50:48 per chiusura non sono state rinnovate.

La chiusura ha cambiato soltanto enabled=false della campagna E70. Il postflight conferma zero run pendenti, sei stage conservati, Root invariato e identici dati dei 43 Fati precedenti, sei scope di missione, E65/E66/E68 e contabilità completa dei nuovi risultati. I risultati precedenti restano leggibili; il PM ha verificato anche il caso 3 E70 dal normale comando Staff dopo la chiusura, con testo e ricevuta ancora disponibili. Non è una nuova generazione.

## Proposte per il seguito, ancora da applicare

- Far valutare al Director la differenza fra domanda aperta e fatto già acquisito. Un nuovo atto deve sviluppare quel punto, senza riproporre come avanzamento una conseguenza già pubblicata.
- Dare alle attività disponibili del luogo una funzione nello scambio: spostare attenzione, occupazione dello spazio, ritmo o interesse dei presenti quando la situazione lo consente. Il criterio è la relazione con ciò che accade, senza una quota di dettagli o una coda obbligatoria.
- Lasciare al Writer il compito di rendere osservabili decisioni e modi, evitando ripetizioni di custodia e spiegazioni sull’autonomia che non aggiungono contenuto alla risposta attuale.
- Rivedere il contratto di memoria alla luce del JSON finale: le informazioni devono restare unità compiute e correttamente attribuite. I limiti dei campi e il modo di chiedere la sintesi vanno valutati insieme, senza dedurre che un semplice ulteriore divieto garantisca il risultato.
- Conservare separati fatti acquisiti, dichiarazioni attribuite e sviluppi ancora aperti, dando priorità allo stato utile per il prossimo turno.

Non sono stati introdotti nuovi blocchi stilistici, blacklist o rigenerazioni. Queste indicazioni non sono patch già applicate. Le tre prove private qualificano il collegamento Director→Writer nel perimetro collaudato, non una missione completa, il Combat o l’apertura all’utenza.

Fonti: RESULTS_PRIVATE.json, CHAIN_PROOF.json, FINAL_LEDGER_PRIVATE.json, close/POSTFLIGHT_SUMMARY.json, memory_diagnosis/FINAL_MEMORY_PRIVATE.json e DIAGNOSIS.json, review/OUTCOME_REVIEW.json. I testi integrali e le fonti private restano conservati per la review; non sono riprodotti qui.

[Leggi i tre Fati originali](/private/tmp/tus-c1266-editorial70-20261031/FATI_E70.md) · [Leggi le memorie originali](/private/tmp/tus-c1266-editorial70-20261031/MEMORIE_E70.md). Copie private per la review, non Fati pubblicati nella missione.
