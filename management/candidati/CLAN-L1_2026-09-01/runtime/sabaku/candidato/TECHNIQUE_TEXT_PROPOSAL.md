# Clone di Sabbia e Moltiplicazione del corpo · proposta editoriale

Proposto · CLAN-TESTI-NARRATIVI-004 · 09/09/2026 · da leggere e valutare con Antonello. Nessun testo del catalogo, regolamento, codice o database sostituito.

La bozza riguarda la resa narrativa di descrizione ed effetto. Non sostituisce da sola la scheda meccanica completa: costi, requisiti, distanze, prove, durata e cause di cessazione conservano le fonti attuali. La successiva integrazione deve preservarle, evitando che una riscrittura stilistica elimini informazioni operative. Le immagini sono riferimenti generali: gesti, postura, ritmo e dettagli compatibili spettano alla role del giocatore; l’esito concreto viene sempre dal motore.

## Clone di Sabbia

### Descrizione proposta
La sabbia della giara prende la sagoma del Sabaku, formando un corpo compatto che ne richiama l’aspetto. È una figura di sabbia, concreta e riconoscibile nella sua materia. Quando la tecnica si esaurisce, perde coesione: la sagoma si sfalda e ricade al suolo in una massa di granelli.

### Effetto proposto
Il Clone è una trappola. Quando un avversario si avvicina abbastanza, la sabbia tenta di avvolgerlo e trattenerlo, senza ferirlo. Se la presa riesce, il bersaglio resta immobilizzato finché riesce a liberarsi o l’effetto termina. Se la cattura fallisce, il Clone si esaurisce e la sua forma cede. Anche una copia illusoria può ingannarlo e consumarne l’innesco.

## Moltiplicazione del corpo

### Descrizione proposta
L’utilizzatore fa comparire copie illusorie del proprio aspetto. Le copie possono spostarsi fino a cinque metri da lui. Le immagini non hanno solidità: non possono afferrare, sostenere un peso o infliggere ferite. Quando una copia viene colpita o il suo effetto termina, svanisce in una nuvoletta bianca.

### Effetto proposto
Le copie possono creare un diversivo, coprire un riposizionamento o accompagnare l’assalto del corpo reale.

- **Diversivo:** l’utilizzatore rinuncia ad attaccare e sfrutta le copie per indurre l’avversario a seguire la figura sbagliata. Se questi non riconosce l’originale, l’inganno lo porta a spostarsi verso un punto diverso, modificando la disposizione del confronto.
- **Copertura:** le copie accompagnano l’arretramento dell’utilizzatore e rendono più difficile distinguerlo dalle illusioni. Questo gli permette di guadagnare distanza e aumenta le sue possibilità di difendersi dal colpo avversario.
- **Assalto:** l’originale avanza con le copie e porta un proprio colpo fisico, senza poter usare la manovra per arretrare. Le figure illusorie confondono la difesa avversaria e aumentano le possibilità che il suo colpo vada a segno, senza garantirne la riuscita. Se l’avversario reagisce contro una figura illusoria, consuma su di essa la difesa e il colpo reale prosegue senza una seconda reazione. Se riconosce l’originale, può difendersi contro di lui. Al termine dell’assalto le copie si esauriscono.

## Fonti e limiti della proposta

- Ratifiche di Antonello nella taskPM09/09: sabbia compatta/sagoma evocatore/cedimento al suolo; Moltiplicazione illusoria/nuvole bianche; libertà della role; valutazione della singola mossa con testi abbozzati.
- Lettura DB09/09 16:18:31UTC: Clone `public.clan_techniques` id617484d6-af7b-41c3-a37f-615b22818421, campi `description` e `danno_effetto`. Il testo attuale contiene già natura di trappola, confronto di cattura e cause di fine; non rende esplicita la conclusione visiva.
- Lettura DB09/09 16:22:14UTC: Moltiplicazione `public.jutsu` idc6e31b7b-38fe-4b4f-b3c7-05f3e922d193, campi `effect` e `limits`, nessuna colonna `description`. Il testo attuale è concentrato sulla difesa; il mapping futuro non può fingere uno schema uniforme dei due cataloghi.
- REGOLE.md §4.5: Diversivo/Copertura/Assalto, copie senza danno, colpo dell’originale e consumi distinti. Il testo proposto non qualifica l’intero runtime delle tre modalità. Il limite di cinque metri delle copie rispetto all’originale, richiesto nella revisione002, è già presente nelle fonti locali: 89_INTEGER_MOVEMENT.sql:331, multiplication_line_figures usa least(5,p_extent); non è un limite allo spostamento del PG. Questa è verifica statica, non nuovo collaudo della geometria live.
- Una descrizione di cedimento non crea una nuova vulnerabilità al danno: il motore resta l’unica autorità sulla conclusione del Clone. Non si aggiungono movimento autonomo, difese fisiche delle illusioni, copie combattenti o effetti ambientali.
- Per ora sono due coppie editoriali da revisionare. Non applicare il testo breve dell’effetto al posto dell’intero campo meccanico senza preservare tutte le informazioni esistenti e verificare il raccordo del consumer.

## Decisione tattica corrente e raccordo ancora necessario

La revisione004 recepisce la precisazione successiva di Antonello: Copertura consente arretramento e maggiori possibilità difensive; Assalto non arretra e aumenta le possibilità di colpire; Diversivo rinuncia all’attacco e sposta l’avversario se non riconosce l’originale. Supera la revisione002 che distingueva soltanto l’intento narrativo. È comportamento da ottenere, non un’attestazione del runtime: nei raccordi locali letti Diversivo/Copertura condividevano layout, durata e risoluzione. Il catalogo live è ancora invariato.

Prima della candidata meccanica restano da riconciliare con i contratti già validi: misura della maggiore difesa di Copertura; scelta e distanza del punto verso cui Diversivo può condurre il bersaglio; prova di riconoscimento; interazioni con immobilizzazione, terreno e pericoli. Non inventare bonus o metri, non permettere all’IA di decidere coordinate o riconoscimento. Un punto o un esito non certificati dal server non diventano movimento narrato. La prima consegna resta la bozza da valutare da Antonello.
