# E74 — confronto editoriale con E72 ed E70

Le tre coppie Director→Writer sono completate. Gli input narrativi coincidono con E72 ed E70 in tutti i casi. La versione generica E73 riduce il copione scritto dal Director, ma **non raggiunge ancora l’obiettivo editoriale**: ambiente poco funzionale, riepiloghi esplicativi e ritorno su una rettifica già compiuta. La memoria peggiora rispetto a E72. Esito: **PARTIAL_NOT_PASSED**.

Sono tre rami indipendenti dopo lo stesso F2, non tre turni consecutivi né una missione completa. E72 è il confronto principale; E70 quello secondario. Tre campioni non consentono conclusioni statistiche o una causa unica delle differenze. Il successo della preview non qualifica Combat, avanzamento di fase o i percorsi Staff numeric/free.

| Caso | Caratteri E70 / E72 / E74 | Lettura comparata |
|---|---:|---|
|1 — fatti e aggiunte|732 / 619 / 871|Risposta pertinente ma più lunga soprattutto per riepilogo; nessun seguito sostanziale oltre la distinzione richiesta.|
|2 — motivazioni e dissenso|1.337 / 1.044 / 1.030|Scelte personali espresse; proposta di nuova rettifica ai presenti e attesa finale artificiale. Meno ambientazione concreta.|
|3 — seguito pratico|1.180 / 964 / 1.063|Regressione rispetto a E72: il seguito verso altri destinatari diventa di nuovo proposta di rettifica qui, davanti allo stesso pubblico.|

## Parole PG, copione Director e autoripetizioni

Non osservo riprese estese delle domande PG: massimi 2/2, 1/1 e 1/2 token; nessun cinquegramma condiviso con le domande in nessun caso. È una misura consultiva sui soli input presenti, non un filtro né una garanzia generale.

Nel caso3 E72 il Director scriveva due battute finite e il Writer ne riprendeva sequenze di32/28token. E74 non fornisce battute finite: speech_intent descrive contenuto e scopo; le sequenze massime scendono a6/6token. Questo migliora il confine tra le funzioni. Rimane ripetizione tra intent e speech_intent; la ridondanza del piano non coincide con copia delle parole dei PG.

Le autoripetizioni semantiche PNG restano. Nel caso1 il richiamo alle frasi del foglio è pertinente alla domanda; ripetere anche assenza di testimonianza e denaro occupa spazio già coperto da F2. Nel caso2 i due tornano a negare una testimonianza e a proporre di correggere ciò che F2 aveva già corretto pubblicamente. Nel caso3 vengono riproposte le stesse responsabilità, aggiungendo soltanto preferenze sul farlo insieme o separatamente. E72 separava meglio rettifica già fatta e correzione futura ad altri destinatari.

I cinquegrammi ripetuti internamente sono zero nei tre E74; ciò non elimina la ripetizione di significato. Rispetto a F2, le sequenze condivise massime sono8/5/5token nei tre casi. Lunghezza e similarità lessicale non sostituiscono la lettura della funzione della risposta.

## Dove nasce il ritorno sulla rettifica

Il fatto acquisito è esplicito sia nel vero F2 sia in scene_memory.known: «Le ammissioni e la rettifica delle accuse sono già avvenute davanti ai presenti». used contiene inoltre «La rettifica pubblica delle accuse iniziali».

Il Director E74caso2 propone invece che Keita corregga personalmente «davanti a chi ha ascoltato» e che ciascuno corregga le proprie affermazioni «davanti ai presenti». Nel caso3 propone una «correzione rivolta insieme ai presenti». La regressione è quindi già nel piano, prima del Writer.

Il Writer la realizza e aggiunge una chiusa di attesa: caso2 «La proposta resta in attesa di una risposta»; caso3 riepiloga le due proposte e afferma che nessuno le ha ancora attuate. La custodia del foglio è rispettata; non è una nuova azione PG inventata. Tuttavia l’accettazione degli interlocutori non era stata stabilita come requisito per assumersi pubblicamente una responsabilità.

Le fonti non sono neutre rispetto a questo tema: la domanda del caso3 chiede un passo per correggere quanto detto agli ascoltatori; open iniziale chiede un seguito praticabile. Fasi e schede insistono su rimediare, responsabilità e collaborazione. Possono rendere la rettifica saliente. Ma non impongono di ripeterla: notes dice che un chiarimento acquisito apre una domanda diversa e che gli impegni producono seguito; le schede distinguono possesso iniziale e sviluppi effettivi. Non emerge una regola di fase o scheda che obblighi a una nuova attesa. Gli stessi input hanno prodotto in E72caso3 un seguito più coerente. Non è dimostrata una causa unica nei prompt, nei dati o nel modello.

## Ambiente: meno riciclo, profondità ancora insufficiente

E74 evita l’acquisto riavvolto nella carta che E72caso2 riprendeva da F1. Non riavvia quindi quel particolare consumato. Conserva inoltre foglio aperto, custodia e spazio del gruppo.

Il miglioramento è circoscritto. Nei tre world_reaction_intent il Director prescrive soprattutto che il mercato prosegua e i presenti possano ascoltare, senza una reazione decisiva. Il Writer rende questi contenuti perlopiù in una coda generica. La piazza non incide su una nuova scelta, un destinatario o una conseguenza; la rotazione del foglio verso gli ascoltatori è un piccolo gesto nuovo, oltre all’apertura già narrata in F2, ma non cambia il seguito sostanziale. Le chiuse dei casi1/3 spiegano anche che cosa significano le proposte, anziché lasciare che parole e comportamenti lo mostrino.

Le fonti ambientali esistono: setting descrive lavoro e passaggio; notes lega attenzione, spazio e attività allo scambio. Non manca soltanto una descrizione della mappa. Il piano seleziona da quelle fonti quasi esclusivamente continuità immobile e il Writer la traduce così. Non occorrono una quota ambientale o un evento obbligatorio.

## Memoria: regressione osservabile, causa interna non provata

E72 aveva tre memorie con unità compiute; E74 conserva il nucleo dei fatti ma presenta **sei unità semanticamente incomplete**: un used nel caso1, un known e tre used nel caso2, un used nel caso3.

Gli esempi sono verificabili nelle copie: caso1used termina «senza v»; caso3used «per una»; caso2known termina con `personalmente ciò»,` e alcuni used terminano «attac…», «affermaz…», «proprie…». Il problema è il significato incompiuto e la punteggiatura estranea, non il semplice raggiungimento di90/180caratteri. Alcune unità E70 esattamente al limite erano invece complete. La successiva diagnosi readonly ha confrontato le tre memorie complete nel JSON finale provider con le memorie normalizzate: coincidono integralmente, con hash raw validi. Le sei unità incomplete sono quindi già presenti prima di normalizzazione e deposito; in questi campioni non viene osservato un taglio successivo. Il confronto non prova la causa interna di generazione o decoder: quella resta **non determinata**.

Le tre memorie mantengono la rettifica già pubblica in known. Casi2/3 registrano contemporaneamente una nuova proposta di rettifica in state/open, trasmettendo al turno successivo la contraddizione già presente nel Fato. Nel caso2 open aggiunge l’attesa che gli interlocutori accettino o modifichino la proposta; non deriva da una condizione effettiva stabilita nella scena.

Il caso1 chiude correttamente la distinzione e conserva l’altro punto aperto, ma aggiunge fatti in parte sovrapposti. Il caso3 comprime da sei a quattro known, perdendo da quelle voci luogo e tempo del ritrovamento della busta; tale fonte resta nello snapshot/cronaca, quindi non è dimostrata una perdita definitiva del sistema. used non è ancora un insieme affidabile di etichette complete. Attribuzione di ammissioni e scelte resta perlopiù riconoscibile; la loro categoria e lo stato compiuto/pendente richiedono maggiore precisione. Tre rami isolati non verificano memoria longitudinale.

## Proposte generali, non applicate

- Consolidare all’ingresso la distinzione tra stato corrente, fatti compiuti e informazioni iniziali delle schede; presentare la domanda attuale come domanda su quello stato, senza aggiungere altre ricette di scena.
- Separare nel piano l’informazione nuova e la decisione dal solo richiamo a fatti acquisiti. Conservare al Writer la realizzazione verbale, senza duplicare lo stesso contenuto in più campi descrittivi.
- Far derivare il contesto ambientale dalla relazione fra attività del luogo e iniziativa corrente; mantenere la quiete quando coerente, evitando di tradurre la continuità in un riepilogo obbligatorio.
- Rivedere il contratto di uscita e la capienza della memoria per rappresentare unità complete, aggiornando i fatti esistenti e conservando soltanto dipendenze effettive; nessun taglio di parole o proposizioni. Il difetto è localizzato nel JSON finale del provider; va ora valutato il contratto di rappresentazione e capienza della memoria, senza attribuire al solo prompt o al deposito una causa non dimostrata. Non introdurre un nuovo giudice linguistico o un retry automatico.

Sono proposte di intervento sulle fonti e sul passaggio dei dati, senza nuovi filtri editoriali bloccanti o retry per cercare un testo migliore. Nessuna modifica è stata applicata da questa analisi.

## Esecuzione e contabilità

Sei stage completati, tre coppie conservate,12HTTP senza retry della campagna. Incremento prudente0,14141830USD (Count riservate0,13200000 e Generation liquidate0,00941830); cumulativo2,12926070USD su4. L’analisi non ha effettuato chiamate. Installazione, adozione E73, lettura UI e chiusura sono verificate dalle ricevute riportate nelle sezioni seguenti. La riuscita delle sei generazioni non dimostra assenza di ogni possibile difetto nel prodotto.

[Leggi i tre testi originali](/private/tmp/tus-c1266-editorial74-20261031/FATI_E74.md) · [Leggi le memorie originali](/private/tmp/tus-c1266-editorial74-20261031/MEMORIE_E74.md).

Fonti: RESULTS_PRIVATE.json, FINAL_LEDGER_PRIVATE.json, metriche in editorial/E74, risultati E72/E70 conservati. COPY_PROOF.json registra hash dei testi e roundtrip JSON delle memorie; la diagnosi successiva legge esclusivamente il campo scene_memory del JSON finale provider, senza intere risposte grezze, intestazioni o ragionamento nascosto. Fati e risultati precedenti restano intatti.

## Diagnosi del confine della memoria

Una sola query readonly, senza chiamate IA, estrae esclusivamente scene_memory dal JSON finale conservato dei tre Writer e lo confronta con editorial_scene_memory normalizzata. Tre hash raw validi, tre memorie complete identiche e sei unità ai limiti90/180già incomplete prima del deposito. I dati individuano il confine del difetto; la coincidenza con i massimi è un indizio da approfondire sul contratto di output, non prova di un particolare comportamento interno del provider. La query si è fermata qui. Non sono state lette intere risposte o parti di ragionamento.

Diagnosi: /private/tmp/tus-c1266-editorial74-20261031/memory_diagnosis/DIAGNOSIS.json. Le vecchie memorie E70/E72 e le nuove E74 restano originali. Non è stato aumentato o ridotto alcun limite, né applicata una riparazione automatica.

## Installazione, adozione e conservazione

C1266 Editorial74 ·31/10/2026: tre nuove coppie Director→Writer con E73 invariata completate e campagna beabfc88-ae45-53b1-b081-d137cd8eac41 chiusa,6completed/0pending.6Count+6Generation/12HTTP al primo tentativo IA,senza retry editoriale. Nuovo costo prudente0,14141830USD (Count riservate0,13200000+Generation esatte0,00941830),cumulativo230HTTP/2,12926070USD su4; riserve unknown_billable mantenute.

Catena reale verificata3/3: domande nuove come identità tecniche,stessi input narrativi E70/E72,richieste con istruzioni E73 e nuovo piano Director legato al Writer tramite ricevute/hash. Nessun PGecho esteso osservato; Director non fornisce più battute finite come E72C3. Esito editoriale PARTIAL_NOT_PASSED: autoripetizioni, ambiente soprattutto in coda e rettifica già acquisita riproposta nei piani C2/C3, poi attese/riepiloghi del Writer. Memoria NOT_PASSED: sei unità incomplete in tre campioni, già identiche nel JSON finale provider.scene_memory; nessun taglio successivo osservato, causa interna non determinata. Nessun filtro o correzione applicato ai testi.

Integrazione22: Root `5c948df36e4410eed1b5d0af62e91326a5739aded211b558cd92e96493c8cf39`,policy `2da0647a0abcd65bb8662973dfef80244c99e5cf3bbc877a93548d735847358e`,Edge139/EZBRd51e71bf16c85acf7195c23c09b4f7c88929c55c5a2c913402956c102034797a,UIa6c9aa50797dbb1d9af2e63aca72151a47f933ea/Pages41228255501SUCCESS. Review sorgente/materiale/chiusura0/0/0,16fileEdge e3blobUIriletti esatti. INSTALL/ENABLE riusciti,postflight246header/10ABI/5tabelle/68vincoli senza mismatch;vecchi43Fati,sei scope,E65/E66/E68/E70/E72 e tutti risultati/raw/memorie/ledger/audit/protetti conservati,oltre ai nuovi E74. Root262096B/margine48,tutte recovery precedenti mantenute;nessun nuovo vincolo/schema/funzione/GRANT o apertura pubblica. Infrastruttura invariata.

ENABLE reale18:16:29.844157UTC,stopprovider19:31:29 eclose19:46:29UTC; tutte le generazioni concluse entro18:19:45.800622UTC e chiusura verificata nella stessa finestra. Testi E73/V8/V7 invariati; nessuna role inviata o missione rigiocata. Tre rami indipendenti dopoF2 non qualificano una missione completa,Combat,memoria longitudinale o altri percorsi Staff. Fonte: referti/C1266_EDITORIAL74_REPORT.md.

L’adattamento cambia soltanto tre predicati di un’authority esistente, la nuova campagna privata e i collegamenti nelle due componenti Edge e nel pannello. Non cambia le istruzioni E73: la prova inversa ricostruisce integralmente i16file della baseline; le richieste reali contengono Director4,Writerresponse11 e memoria3, oltre ai wrapper effettivi Director2/Writer3. La criticità di questi campioni non viene attribuita a una vecchia versione caricata al posto di E73.

La preparazione ha richiesto un secondo comando del compilatore perché nel primo mancava l’argomento --ui-manifest; quel comando è stato respinto localmente prima di generare materiale o inviare SQL. Non è una generazione fallita né una nuova correzione della sorgente22. Il materiale completo è poi stato ricostruito e recensito prima dell’unico apply riuscito. Nessun retry al modello, patch durante la campagna o rigenerazione editoriale.

Il postflight di chiusura conferma soltanto enabled true→false della nuova E74, con Root,policy,scadenze e hash completi di vecchi e nuovi risultati,richieste,raw,memorie,finanza e audit invariati. La normale lettura Staff ha mostrato tutti i Fati completi; il terzo è stato riletto anche dopo CLOSE con la stessa ricevuta93194693-8b5b-4650-a473-cbba259da474. Vecchio E72C1 riletto dopo INSTALL con ricevuta566cce7f-c41a-48c6-be1a-499ce7294846 invariata.

## Review indipendente e limiti

La lettura indipendente conferma PARTIAL_NOT_PASSED e le precisazioni sul piccolo gesto del foglio e sul confine provider della memoria. Referto privato: /private/tmp/tus-c1266-editorial74-20261031/review/OUTCOME_REVIEW.md; SHA JSON c813285558fec0e81d358f56fb9dc0b44a1b1a744d42f173f2ee0ca25b34e7c3.

Il percorso tecnico delle tre coppie è riuscito senza blocchi di generazione osservati. La qualità desiderata non è raggiunta. Le proposte del report restano proposte: nessun altro test o cambiamento è stato avviato. Le tre prove private non rigiocano la missione e non qualificano i suoi percorsi completi.
