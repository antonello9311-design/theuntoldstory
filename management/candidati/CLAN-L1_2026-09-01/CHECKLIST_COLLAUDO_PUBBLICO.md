# Checklist del collaudo pubblico

Preparata l’11/09/2026 per Antonello. Le caselle indicano prove ancora da annotare pubblicamente: alcune confermano funzioni già riuscite in Test Room, altre coprono passaggi non ancora osservati. Non significano che ogni funzione sia guasta o mai provata.

**Modalità:** normali role pubbliche, con i costi e gli esiti ordinari del gioco. Usa soltanto tecniche possedute e opzioni offerte dal pannello. Un caso riuscito una volta basta; se emerge un problema, annota il caso e il messaggio preciso prima di riprovarlo. Più caselle possono essere completate nello stesso scontro.

**Diagonali disponibili; regole di movimento esistenti conservate.** Le otto direzioni sono aperte sia nel percorso ordinary sia in Regia. La modifica riguarda le direzioni, senza nuovo pannello a fasi o cambio della turnazione: uno spostamento facoltativo e la normale principale secondo le possibilità già previste. Antonello riferisce che movimento e attacco funzionano insieme nelle modalità già provate, incluso l’Esame Genin; questo esempio non aggiunge una prova dell’Esame al collaudo clan. A1, B2, B8 e B9 verificano le diagonali e la conservazione di questo comportamento nei rispettivi percorsi. La sola offerta autonoma Movimento della Regia non dimostra un difetto del movimento abbinato alla principale. Le altre prove delle tecniche già pubbliche restano utilizzabili; le nuove missioni con PNG IA mantengono una disponibilità separata.

Per ogni prova compila la riga sotto la casella. Esito: **OK / Problema / Non eseguita / Non disponibile**. Nella nota basta indicare cosa ti aspettavi e cosa è successo; non servono termini tecnici.

## Conferme pubbliche delle funzioni già verificate in Test Room

- [ ] **A1 — 1vs1 automatico: spostamento, principale e turno.** Nello scontro fra due giocatori senza Master, usa lo spostamento facoltativo per una diagonale e dichiara un attacco dalla posizione raggiunta, seguendo il normale pannello. Completa la risposta dell’avversario; in un altro turno utile verifica Passa. **Atteso:** lo spostamento rispetta il budget e viene conteggiato una sola volta; una diagonale di un metro per asse consuma due metri del budget. Puoi svolgere la normale principale nello stesso turno, senza ottenere una seconda offensiva. Il sistema produce l’esito e rende giocabile il turno successivo. Aggiornare il pannello non ripete comandi o costi. Cardinali e diagonali nel percorso Staff sono già riuscite; resta la conferma pubblica del percorso completo.

  **11/09/2026 · prova live parziale:** nella Staff Test Room il server ha offerto le otto direzioni e ha confermato `Alto a destra · 2 m` per testperfunzioni. Mancano ancora dichiarazione testuale, risposta, esito, Pass e turno successivo; A1 resta aperto. Evidenza: `runtime/site_release001/PUBLIC_CHECKLIST_LIVE001_RESULT.json`.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **A2 — Moltiplicazione, solo Assalto.** Esegui un Assalto con una copia e, in un altro turno utile, uno con due copie contro un avversario senza occhi attivi. **Atteso:** l’avversario conserva la normale difesa; l’aiuto delle copie riguarda la possibilità di colpire, non la difesa dell’utilizzatore. Le copie si consumano dopo l’offensiva e svaniscono in nuvolette bianche. Un colpo mancato non è, da solo, un errore.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **A3 — Byakugan contro Assalto.** Con Byakugan attivo e avversario entro 10 metri, ricevi un Assalto con copie illusorie. **Atteso:** prima di scegliere la difesa il pannello indica l’originale riconosciuto; puoi difenderti normalmente. Il riconoscimento elimina l’inganno delle copie, non garantisce di evitare il colpo.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **A4 — Sharingan contro Assalto.** Ripeti il solo riconoscimento con Sharingan attivo, avversario visibile nello scontro frontale ed entro la portata prevista. **Atteso:** originale indicato prima della difesa, risposta normale e copie consumate al termine dell’offensiva. Non usare nascosto, invisibilità o attacchi alle spalle per questa conferma.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **A5 — Etichetta e spegnimento degli occhi.** Nelle prove A3/A4 controlla il nome dell’occhio in fondo alla role; spegnilo quando il pannello lo permette e invia la successiva azione normale. **Atteso:** la nuova role non conserva l’innata spenta; le role precedenti mantengono correttamente l’etichetta. Lo spegnimento è gratuito e una nuova attivazione segue i tempi mostrati nella scheda.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **A6 — Palle di fuoco e Risonanza.** Con un Uchiha che possiede le abilità necessarie, usa in turni distinti la Palla di Fuoco generica e le due modalità della Suprema. **Atteso:** generica contro un bersaglio; Suprema concentrata oppure esplosiva sul punto scelto. Costi e bersagli corrispondono alle opzioni mostrate. La Risonanza aiuta soltanto la Suprema compatibile, senza aumentare il danno, e non si applica alla generica. Annota tecnica, modalità e innata attiva: il controllo del bonus si fa sul risultato della prova, non contando soltanto i colpi riusciti.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **A7 — Controllo e Flussi sul singolo bersaglio.** Attiva Controllo della Sabbia all’inizio del turno e usa i Flussi dall’azione principale: una volta un flusso, in un altro turno tre flussi sullo stesso avversario. **Atteso:** puoi attaccare nello stesso turno dell’attivazione; il pannello distingue sabbia disponibile e impegnata. Ogni flusso costa 5 chakra e 2 sabbia; concentrare più flussi migliora la possibilità di colpire senza moltiplicare il danno. Al tuo turno successivo recuperi 2 sabbia entro la capienza.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **A8 — Trasporto di Sabbia.** Attivalo nel momento consentito e scegli un normale movimento. **Atteso:** fino a 5 metri aggiuntivi per quel turno, 5 unità di sabbia impegnate fino al termine; il movimento resta sul percorso ammesso. Se nel normale percorso è già presente terreno impervio, verifica che non richieda movimento aggiuntivo. Il terreno mancante rende quella sola osservazione non eseguita.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **A9 — Clone di Sabbia e liberazione.** Crea il Clone entro 3 metri con un avversario entro 2 metri dalla figura; l’avversario tenta poi la liberazione nel proprio turno. **Atteso:** presa automatica iniziale senza tiro difensivo e senza danno; il tentativo di liberarsi usa l’azione principale. Restano impegnate 5 sabbia, restituite alla fine. Quando termina, il Clone si sfalda in granelli; non sparisce come una copia illusoria.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **A10 — Marionetta, movimento e attacco.** Con la propria marionetta presente e collegata, impartisci un movimento consentito e poi, quando hai l’azione disponibile, attacca un bersaglio raggiungibile. **Atteso:** posizione e colpo partono dalla marionetta; il controllore paga il costo previsto e l’avversario si difende normalmente. La marionetta non guadagna un turno autonomo e il suo colpo è contundente, senza armi o effetti inventati.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

## Residui pubblici e verifiche nuove da completare

- [ ] **B1 — Sostituzione nel normale scontro.** Quando il pannello la offre contro un attacco compatibile, scegli Sostituzione e completa la risposta. **Atteso:** costo, esito e posizione finale sono quelli indicati dal gioco; il turno prosegue e la narrazione rispetta il risultato. È già rilasciata; qui serve annotare la conferma sul percorso pubblico attuale, senza presupporre che eviti qualsiasi colpo.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **B2 — Duello con Master: spostamento ed esito dopo la valutazione.** Apri un normale duello con Master. Per confrontarlo con A1, puoi riusare i due PG e affidare la Regia a un Master non partecipante: è un suggerimento per la prova, non un requisito universale di ogni scena. Esegui uno spostamento diagonale facoltativo e dichiara la principale nel turno consentito, usando il percorso esistente. **Atteso:** budget, posizione e disponibilità della principale seguono la stessa regola del 1vs1 automatico; il movimento non richiede una principale aggiuntiva e non concede una seconda offensiva. Dopo risposta e valutazione, il Master riceve i risultati e completa l’esito; posizione e turno restano coerenti con quanto realmente accaduto. Annota anche le opzioni effettivamente offerte per abbinare movimento e principale.
  
  Stanza: ___ · Data/ora: ___ · PG e Master: ___ · Esito: ___ · Nota: ___

- [x] **B3 — Katon con Master.** Inserisci una delle azioni A6 nella Regia B2; se il pannello è corretto, usa anche l’altra modalità della Suprema in un turno successivo utile. **Atteso:** il Master vede modalità, bersagli o punto scelto e riceve il risultato coerente dopo la valutazione. Non serve ripetere ogni combinazione di tecniche: interessa questo passaggio ancora non collaudato con Master.
  
  **Staff 13/11/2026 · PASS meccanico.** Round 2 concentrata 36 danni e round 3 esplosiva (8,6) 24 danni. Risonanza I e 10 chakra per lancio. Due Fati pubblicati. Sessione `c1b75166-f6d7-4d70-9a7c-56887d4841cb`.
  
  Stanza: ___ · Data/ora: ___ · PG e Master: ___ · Esito: ___ · Nota: ___

- [ ] **B4 — Mappa della scena e miniature.** Nella nuova Regia B2 controlla la mappa prevista per stanza o zona e, se già assegnata, la miniatura del personaggio. **Atteso:** mappa appropriata, figure leggibili e posizione aggiornata dopo il movimento. La pubblicazione è documentata; l’uso effettivo con personaggi reali merita questa conferma. Non serve caricare nuove immagini per completare la prova.
  
  Stanza: ___ · Data/ora: ___ · PG e Master: ___ · Esito: ___ · Nota: ___

- [ ] **B5 — Narrazione di una scena completa.** Usa uno dei normali scambi precedenti, senza rigenerarlo apposta. **Atteso:** compare un solo esito, coerente con azione, difesa e risultato; distingue materia delle tecniche e copie, non inventa poteri, ferite o movimenti. Annota le frasi troppo tecniche o didascaliche e quelle che limitano senza motivo la scelta narrativa del giocatore. I dati delle otto schede sono già stati verificati; qui si valuta il racconto effettivo.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **B6 — Riallaccio dei Fili in una situazione reale.** Solo quando nel normale gioco il collegamento viene effettivamente interrotto da una capacità adatta, trascorri il turno completo previsto e riallaccia i Fili dall’opzione offerta. **Atteso:** ritorna il controllo della marionetta, costo e attesa corretti; l’eventuale narrazione racconta il riallaccio senza inventare una nuova evocazione o fili visibili a tutti. Questo ramo narrativo non è ancora stato osservato. Se manca una recisione realmente disponibile, segna “Non disponibile”, senza simulare il taglio con una lama ordinaria.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **B7 — Conclusione ordinaria dello scontro.** Al termine di una prova completa, chiudi lo scontro con il normale comando previsto. **Atteso:** la scena conserva i messaggi e gli esiti, non rimane un turno attivo da completare e il pannello torna allo stato coerente con la conclusione. Annota eventuali blocchi o effetti ancora mostrati come attivi.

  **11/09/2026 · PASS UI:** `Chiudi duello` e la conferma server hanno riportato il pannello allo stato non attivo, mantenendo intatta la chat. Postflight DB rinviato per liberare subito Supabase al rilascio Copertura/Diversivo. Evidenza: `runtime/site_release001/PUBLIC_CHECKLIST_LIVE001_RESULT.json`.
  
  Stanza: ___ · Data/ora: ___ · PG / Master se presente: ___ · Esito: ___ · Nota: ___

- [ ] **B8 — Quest o missione con Master umano.** Dall’ingresso della quest o della missione avvia il combattimento con Master umano. Per un partecipante esegui uno spostamento diagonale facoltativo e una normale principale nello stesso turno, attraverso le opzioni esistenti. **Atteso:** mappa corretta, un solo budget per il movimento e disponibilità della principale come nel 1vs1. Dopo risposta e valutazione del Master, posizione ed esito corrispondono all’azione effettiva e prosegue il turno o la fase previsti. Basta un combattimento pertinente, senza ripetere tutte le tecniche; questa modalità umana è distinta dalle nuove missioni con PNG IA. Annota anche le opzioni effettivamente offerte per abbinare movimento e principale.
  
  Stanza / quest o missione: ___ · Data/ora: ___ · PG e Master: ___ · Esito: ___ · Nota: ___

- [ ] **B9 — Scontro con più attori, PG e PNG comandati dal Master.** In una Regia con più di due combattenti, usa per un PG lo spostamento facoltativo e la normale principale; nel turno consentito di un PNG guidato dal Master verifica lo stesso percorso. Includi una diagonale senza introdurre un secondo spostamento. **Atteso:** ogni attore rispetta il proprio budget con la medesima regola per PG e PNG; posizione, risorse, esito e turno restano attribuiti al combattente corretto. Il movimento accompagna la principale e non concede una seconda offensiva. Annota le opzioni effettivamente offerte e se puoi abbinare lo spostamento alla principale come nei percorsi già provati dall’utente; non dedurre un malfunzionamento dalla sola presenza di un comando Movimento autonomo. Questo caso non certifica le scelte autonome di un PNG IA.
  
  Stanza: ___ · Data/ora: ___ · PG, PNG e Master: ___ · Esito: ___ · Nota: ___

- [x] **B10 — Rotazione Suprema con Master, da analizzare.** In uno scontro con Master, con Byakugan attivo, ricevi un attacco diretto compatibile e scegli Rotazione Suprema come difesa. Seleziona uno dei raggi offerti, 1, 2 oppure 3 metri, annotando quello usato; completa la dichiarazione e la valutazione del Master. **Atteso:** dopo la valutazione il Master riceve il risultato; costo previsto della difesa addebitato una sola volta, danno coerente con l’esito e protezione ottenuta, senza presumere che ogni colpo venga annullato. La spinta avviene dopo il colpo, rispetta raggio e ostacoli e aggiorna la mappa senza infliggere danni aggiuntivi o consumare movimento volontario. La narrazione descrive gli effetti realmente avvenuti in modo scenico, evitando coordinate e spiegazioni didascaliche. I due casi senza Master sono già superati; **la prova con Master è espressamente rinviata da Antonello e non è un PASS**. L’apertura parziale è autorizzata dall’utente; la sua applicazione viene registrata separatamente dal PM.
  
  **Staff 13/11/2026 · PASS meccanico.** Round 1 · raggio 3 m, danno 0, costo 10 chakra, spinta 2 m, Fato pubblicato. Sessione `c1b75166-f6d7-4d70-9a7c-56887d4841cb`.

  Stanza: ___ · Data/ora: ___ · PG e Master: ___ · Attacco / raggio scelto: ___ · Danno / costo / spinta: ___ · Mappa / narrazione: ___ · Esito: ___ · Nota: ___

## Quando l’owner conferma la disponibilità

Questi casi sono preparati per il seguito. Le nuove quest/missioni con PNG IA sono ancora spente per l’utenza. L’adeguamento alle quattro direzioni diagonali è stato distribuito nel servizio IA, ma questo non rende ancora utilizzabili le missioni automatiche. Il nuovo editor di creazione missioni è stato predisposto nel servizio e attende il completamento sul sito: non è ancora una prova da avviare dal pannello. Il file non dichiara accese funzioni che dipendono da un altro rilascio.

- [ ] **C1 — PNG IA in quest o missione.** Dopo la conferma dell’attivazione, avvia una missione consentita con un combattimento e lascia agire il PNG IA. Quando sceglie di muoversi, osserva spostamento e principale; se sceglie una diagonale, annotala. **Atteso:** usa lo stesso percorso e lo stesso budget dei PG, senza consumare una principale aggiuntiva per il movimento e senza ottenere una seconda offensiva. Posizione, esito e turno restano coerenti; la missione prosegue conservando ciò che è accaduto. Non ripetere la scena per obbligarlo a scegliere una diagonale: se non la usa, annota quel dettaglio come non eseguito. Il servizio aggiornato non equivale a questo collaudo completo.
  
  Stanza / missione: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

- [ ] **C2 — Esame pubblico, solo percorso autorizzato.** Concorda la disponibilità con il responsabile dell’Esame e completa un esame normale. **Atteso:** avvio, turni, esito e congedo seguono il percorso previsto; eventuali premi spettanti compaiono una sola volta. Nel combattimento sono ammesse solo Moltiplicazione e Sostituzione oltre ai colpi fisici previsti: nessuna tecnica di clan. È una verifica dell’Esame, non un confronto richiesto per chiudere i clan.
  
  Stanza: ___ · Data/ora: ___ · PG: ___ · Esito: ___ · Nota: ___

## Rinviato: non è una prova pubblica da eseguire adesso

- **Copertura e Diversivo:** inerti, in riprogettazione. Anche il movimento libero persistente delle copie è rinviato.
- **Flussi multibersaglio contro copie persistenti:** prova rinviata al ritorno delle modalità che lasciano copie sul terreno. Le prove A7 riguardano il singolo bersaglio.
- **Punto cieco Byakugan e orientamento automatico:** regola approvata, ancora da implementare; nessun malus alle spalle da verificare ora.
- **Armatura di Sabbia, Pugno Gentile/Sedici Chiusure e altri clan non ancora aperti:** attendere il rispettivo rilascio; non considerarli disponibili perché il nome compare nel catalogo.
- **Scudo o difesa del controllore tramite marionetta, nuovi PNG permanenti di prova e parità della Test Room utenti:** disponibilità da attestare nei rispettivi incarichi; non aggiungere questi casi allo scontro pubblico corrente.

## Come usare gli esiti

**Interruzione del movimento, soltanto se si presenta:** se durante una prova una condizione effettiva impedisce di completare il percorso, annota punto raggiunto, causa mostrata e disponibilità della principale. Confronta il risultato con la regola della condizione realmente applicata; non introdurre una tecnica o un ostacolo fittizio per creare il caso. Segnare “Non eseguita” se l’interruzione non si presenta.

Una prova già verde in Test Room e riuscita anche pubblicamente si chiude. Per un problema conserva ora, nomi dei PG, scelta effettuata e messaggio comparso: bastano la nota qui e, se utile, un’immagine del pannello. I risultati numerici casuali non sono difetti da correggere finché rispettano le regole. Le note di stile della narrazione si raccolgono senza ripetere il tiro.

**Fonti di preparazione:** checkpoint Clan/Combat e relativi HANDOFF; referti Sharingan, Katon, Sabaku e Marionettisti; PG_DIAGONAL_MOVEMENT001_QA; EYES_CATALOG_FIELDS001_LIVE e PRESENTAZIONE_UI_READ; aree IA_NARRATIVA e TEST_ROOM; HANDOFF dell’owner Missioni. Diagonali Staff20260911104821, apertura Regia20260911111804 e apertura ordinary20260911115213 pg_movement_public002 documentate dal PM; per quest’ultima postflight due hash e proprietà conforme. Nessun nuovo codice003, pannello o cambio di turnazione. Il comando autonomo Movimento rilevato nel codice non certifica un difetto del movimento abbinato: si conserva l’evidenza riferita dall’utente sulle modalità già provate. Stato Missioni comunicato dall’owner dopo le11:21UTC: servizio IA versione2 distribuito con quattro diagonali, funzioni IA ancora spente; preparazione editor completata nel servizio, pagina allora ancora da pubblicare. Nessuna nuova prova di gioco o chiamata IA per questi rilasci documentati: restano le due prove Staff già riuscite. Nessuna nuova interrogazione del database eseguita da questo owner documentale.
