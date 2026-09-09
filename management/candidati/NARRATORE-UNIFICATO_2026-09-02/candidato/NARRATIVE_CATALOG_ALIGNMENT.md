# Allineamento dei testi canonici · Clone di Sabbia e Moltiplicazione

Proposto · NARRATIVE-CATALOG-ALIGN-PREP-001 · NARRATIVE-AI · 09/09/2026. **Due aggiornamenti editoriali preparati, nessuna modifica al database.** Questa consegna conserva la candidata IA verde 2/5 e non è un nuovo ciclo di review o una nuova fonte canonica: il JSON è soltanto il piano di modifica prima/dopo per i cataloghi esistenti.

## Decisione concreta proposta al PM

Aggiornare, dopo i gate pertinenti, **solo `public.clan_techniques.description` del Clone e `public.jutsu.effect` della Moltiplicazione**. Nel primo la descrizione contiene identità e resa visiva, mentre l’effetto meccanico resta completo e byte-invariato. Nel secondo, privo di colonna `description`, natura e comportamento essenziale convivono una sola volta in `effect`; `limits` resta byte-invariato. Non creare campi, tabelle o un secondo catalogo, né duplicare lo stesso testo sotto descrizione ed effetto.

Questa piccola integrazione è coerente nei campi attuali. **Non completa le tre tattiche della revisione004:** la sola prosa non può rendere funzionanti nuovi benefici, riconoscimenti o movimenti dell’avversario. La loro integrazione resta successiva alla riconciliazione del motore, con regole e consumer allineati.

## Fonti verificate e limiti

- `TECHNIQUE_TEXT_PROPOSAL.md`, revisione CLAN-TESTI-NARRATIVI-004: ratifiche narrative e comportamenti tattici da ottenere; hash nel JSON. Il testo di questa integrazione resta una proposta, non una nuova ratifica di Antonello.
- Lettura cataloghi **2026-09-09 18:25:41.381899+00**: due identità esatte, colonne effettive e assenza di trigger applicativi sulle due tabelle. Entrambe le tecniche sono attive. Nessuna riga PG, role o segreto letta.
- Lettura di tre routine **09/09 18:26:10 UTC**, firme e MD5 nel JSON. `multiplication_line_figures(numeric,numeric,integer,integer,numeric,integer)` limita a cinque metri la disposizione relativa delle figure; `multiplication_layout_options_for_figure(...)` conserva quel limite anche quando il corpo resta fermo. I cinque metri **non sono un limite al movimento del PG né autorizzano traiettorie autonome delle copie**. Non si cambiano `gittata` o budget di movimento.
- `multiplication_layout_options_for_figure(...)` e `multiplication_chooser(uuid,uuid)` ammettono `diversivo`, `copertura`, `assalto`: la presenza dei nomi non qualifica gli effetti004. Non sono stati eseguiti test o una ricognizione integrale del motore.
- Il raccordo certificato in `NARRATIVE_TECH_INSTALL.sql` legge `description/danno_effetto` e `effect/limits` tramite gli ID nativi, versione mapping `ordinary-tech/1` e hash del contenuto. Il rilascio resta un gate distinto: questa proposta non dichiara installata la helper.

## Clone di Sabbia · proposta integrabile

Identità immutata: `public.clan_techniques`, UUID `617484d6-af7b-41c3-a37f-615b22818421`.

**`description`, prima:**

Il Sabaku modella la sabbia della propria giara in una sagoma che funge da trappola. Quando un avversario si avvicina, la sabbia scatta per avvolgerlo e trattenerlo. Il Clone può essere ingannato dalle copie create con la Moltiplicazione.

**`description`, dopo proposto:**

La sabbia della propria giara prende la sagoma del Sabaku, formando un corpo compatto che ne richiama l’aspetto. È una figura di sabbia, concreta e riconoscibile nella sua materia. Quando la tecnica si esaurisce, perde coesione: la sagoma si sfalda e ricade al suolo in una massa di granelli.

La trappola e l’inganno da Moltiplicazione vengono spiegati integralmente in `danno_effetto`, evitando la ripetizione nella descrizione. Restano preservati sia «Una copia consuma l’unico innesco senza applicare la presa al proprietario» sia «il fallimento esaurisce il Clone». La conclusione visiva accompagna soltanto una cessazione certificata dal server: il danno o l’immagine narrata non creano una nuova causa di fine. La frase proposta è contenuto del catalogo, non un copione da recitare; la role guida gesti, ritmo e dettagli compatibili.

**`danno_effetto`, invariato integralmente:**

Con Controllo della Sabbia attivo, crea un solo Clone entro 3 m dall’utilizzatore: consuma l’azione principale e 5 chakra, impegnando 5 unità di sabbia disponibili nella giara. Il Clone si innesca automaticamente quando un PG avversario o una sua figura di Moltiplicazione valida è entro 2 m, anche subito alla creazione. Una copia consuma l’unico innesco senza applicare la presa al proprietario. Contro il PG, la cattura confronta ⌊(Kekkei Genkai + Ninjutsu) / 5⌋ + 2d10 del creatore con ⌊(Velocità + Taijutsu) / 5⌋ + 2d10 del bersaglio; la parità favorisce la cattura. Il successo immobilizza il PG senza infliggere danni; il fallimento esaurisce il Clone. Il bersaglio può tentare di liberarsi con la propria azione principale e senza chakra: ⌊(Forza + Taijutsu) / 5⌋ + 2d10 contro ⌊pool della presa registrato / 5⌋ + 2d10; serve un risultato superiore e si può tentare una sola volta per proprio turno. Se la presa interrompe l’avvicinamento prima della dichiarazione di attacco o Moltiplicazione, il movimento percorso e la presa restano registrati e la principale rimane disponibile. Il Clone dura al massimo 3 turni del creatore, incluso quello di creazione. Termina anche quando la presa viene sciolta, il bersaglio è fuori combattimento, l’utilizzatore è assente o fuori combattimento, Controllo della Sabbia viene spento, la sabbia non è utilizzabile o lo scontro termina. Alla conclusione si libera la quota impegnata, senza creare nuova sabbia né rimborsare chakra. Non ha un mantenimento proprio; i costi dell’Innata restano separati.

Il JSON conserva tutte le altre colonne prima/dopo immutate: 5 chakra, 5 unità impegnate, posa entro3m e innesco entro2m, formule e parità, immobilizzazione senza danno, liberazione una volta per proprio turno, durata massima3turni e cause di fine, quota liberata senza rimborsi, Innata separata; requisiti Sabaku/Genin/KG30/ControlloL1 attivo, 50XP e1addestramento, uso e ricarica. Nessuna correzione di queste regole è implicita nella prosa.

## Moltiplicazione del corpo · proposta integrabile

Identità immutata: `public.jutsu`, UUID `c6e31b7b-38fe-4b4f-b3c7-05f3e922d193`. Il nome reale è «Moltiplicazione del corpo»; non inventare `name` o `description` uniformi al catalogo Clan.

**`effect`, prima:**

Crei copie illusorie mentre ti riposizioni. Le copie possono confondere il primo attacco diretto ricevuto: la difesa usa Mente + Ninjutsu.

**`effect`, dopo proposto:**

Crei copie illusorie del tuo aspetto mentre ti riposizioni. Le immagini non hanno solidità e possono disporsi entro cinque metri da te: non possono afferrare, sostenere un peso o infliggere ferite. Le copie possono confondere il primo attacco diretto ricevuto: la difesa usa Mente + Ninjutsu. Quando una copia viene colpita o il suo effetto termina, svanisce in una nuvoletta bianca.

La prova Mente + Ninjutsu e il comportamento difensivo già descritto restano. La frase sulla copia colpita è condizionata al colpo effettivamente risolto dal server: niente dissoluzione dedotta da una dichiarazione, niente originale rivelato dal narratore. La consistenza illusoria esclude blocchi solidi; la nuvoletta bianca resta l’identità della conclusione richiesta. Nessun copione o template aggiuntivo viene imposto al giocatore.

**`limits`, invariato integralmente:**

Azione principale, una volta per round o scambio. Le copie non si accumulano, si consumano al primo attacco diretto o scadono al tuo turno successivo. Se la copia viene colpita non subisci danno né sfioramento; se l'originale è individuato l'attacco si risolve normalmente.

Restano invariati tutti gli altri campi, inclusi 10 chakra, requisito base Accademia, gradoE, uso principale, natura di diversivo, `defense_hint`, gittata contatto e flag. Conservare i valori esistenti non attesta che ogni loro frase descriva tutte le modalità operative: il testo attuale è ancora centrato sulla risposta al primo attacco e sulla scadenza successiva. Questa limitazione resta esplicita e non viene mascherata con tre effetti tattici promessi ma non ancora qualificati.

## Tre tattiche ratificate: cosa resta da costruire

| Modalità | Risultato richiesto004 | Raccordo necessario prima del testo completo |
|---|---|---|
| Diversivo | Rinunciare all’attacco; condurre altrove l’avversario che non riconosce l’originale | Scelta e distanza del punto legale, prova di riconoscimento, movimento registrato dal server, immobilizzazione/terreno/pericoli. Nessuna coordinata scelta dall’IA. |
| Copertura | Arretrare e aumentare le possibilità difensive | Quantificazione già valida o decisione tecnica/prodotto realmente mancante, consumo e ricevuta. Nessun bonus aggiunto da questa proposta. |
| Assalto | Avanzare senza arretrare, aumentare possibilità di colpire senza successo garantito | Riconciliare beneficio, scelta della figura, reazione consumata una sola volta e colpo reale, fine copie. La descrizione004 resta obiettivo, non prova runtime. |

I testi delle tre modalità restano nella proposta004 esistente. **Non copiarli ora nei campi live** come capacità disponibili. Dopo l’allineamento del motore, riscrivere `effect` e `limits` nello stesso catalogo: `effect` ospita natura e modalità, `limits` costi d’azione, scadenze ed esclusioni pertinenti, senza doppioni. L’eventuale presentazione separata in UI è lavoro del consumer, non ragione per aggiungere una colonna narrativa. Se il PM richiede una scheda già completa delle tre tattiche, rinviare il loro aggiornamento fino al relativo rilascio; l’identità narrativa minima può avanzare separatamente.

## Sequenza di implementazione e recovery da predisporre

1. Il PM verifica questi due testi rispetto alle ratifiche; l’eventuale aggiornamento dati richiede il suo gate nominativo e il gate DB previsto dal progetto. Nessuna richiesta aggiuntiva ai giocatori deriva da questa preparazione.
2. L’owner DB prepara successivamente un aggiornamento selettivo dei due UUID e dei due soli campi, con confronto esatto dei valori `before`, conteggio atteso due righe e arresto al drift. Anche la recovery ripristina soltanto quei due campi e solo se corrispondono agli `after`; nessuna sovrascrittura di revisioni intervenute. Non cambiare privilegi, requisiti, stato attivo o altre colonne. Gli eventuali trigger vanno riconfermati al rilascio.
3. Raccordo SQL/Edge e catalogo mantengono gate distinti. Il catalogo è condiviso: il testo può essere letto anche da schede o consumer preesistenti, mentre il nuovo narratore lo riceve soltanto dopo il proprio rilascio. Verificare le superfici interessate senza attribuire al dato un’attivazione di nuove tattiche.
4. Dopo rilascio autorizzato, un nuovo snapshot congela il contenuto pertinente e il relativo hash; quelli già congelati conservano la versione precedente. Nessuna rigenerazione o cancellazione dello storico. Il catalogo descrive possibilità generali; il server certifica ciò che è realmente accaduto.
5. La prova protetta del primo aggancio mantiene il budget già fissato nel piano di rilascio. Non certifica da sola tutte le cessazioni, le tre tattiche, la fedeltà dell’intera scena o la disponibilità nella Test Room utenti. Non avviare un nuovo ciclo sulla candidata verde per questa sola proposta.

## Consegna al PM

Scope: questi due documenti nuovi. Contratti: cataloghi eterogenei esistenti, proposta004 e mapping certificato; nessuno modificato. Decisione proposta: separare completamento editoriale minimo e implementazione tattica. OPEN effettivi: parametri e ricevute delle nuove tattiche, qualificazione consumer e gate applicativi. Verifiche: struttura JSON, due UUID/campi effettivi, tutte le colonne non assegnate preservate, clausole meccaniche mantenute, fonti con hash;2queryreadonly/0test/0provider/0mutazioni. Nessun file condiviso o sorgente IA ritoccato.
