# Contratto dei fatti narrativi

Stato: candidato documentale consegnabile, non implementato né ratificato come nuovo formato di produzione · 09/09/2026 · IA-FATTI-CONTRATTO-001 · owner NARRATIVE-AI.

## 1. Mandato e risultato

Il mandato corrente di Antonello e l’assegnazione PM autorizzano due documenti nel cantiere Narratore: questo contratto e `MATRICE_PRODUTTORI_NARRATIVI.json`. Budget: 15 minuti, una verifica strutturale documentale, zero SQL eseguito e zero provider. Nessuna modifica applicativa, nuova campagna, apply DB, deploy, enable o apertura di task.

Obiettivo: ogni narratore riceve gli eventi già decisi, la loro relazione con lo stato corrente e ciò che può raccontare. Il mandato chiarito dal PM comprende una base comune per tutti i narratori, la prima integrazione nel percorso ordinary Staff già collaudato, poi l’estensione multiattore e missioni/PNG con mapping e qualifiche propri. La futura parità dei percorsi non è un prerequisito del collegamento Clone. Non risultano già tutti collegati. Combat, missioni e PNG condividono questi significati senza diventare copie dello stesso racconto. Il testo cinematografico rimane una composizione narrativa; il contratto non impone formule linguistiche, liste di sinonimi o didascalie tecniche al giocatore.

Il percorso prioritario è **collegare le descrizioni e gli effetti già presenti nel catalogo alla tecnica effettivamente usata**, controllarne la completezza e aggiungere soltanto l’informazione dinamica realmente mancante. Nessun secondo archivio, catalogo duplicato o copia canonica delle tecniche. Il significato condiviso non richiede per forza un nuovo schema.

La §4 è una checklist comune sui significati e sui campi autoritativi esistenti, non un nuovo envelope. Un campo aggiuntivo nasce solo per una lacuna dimostrata e con raccordo DB/PM/consumer. Non cambiano regole, costi, permessi o autonomia dei PNG.

## 2. Decisioni già valide e fonti

Riferimenti completi e impronte della lettura locale sono nella matrice, con identificatori S01–S21. Una fonte descrittiva conserva la data della propria evidenza: questo incarico non ha effettuato una nuova verifica live.

- S01, decisione 03/09: controlli deterministici condivisibili; comunicazione tramite ricevute/referti; nessuna memoria libera condivisa o chiamata da un consumer all’altro. Narratori Luna/high; giudice qualitativo Terra/high asincrono offline, privo di autorità su pubblicazione, rigenerazione e meccaniche. Il nuovo percorso SESSION dell’Esame non usa giudice stilistico.
- S02: repertorio canonico 0.3.0 e architettura C. Condivisione durante la generazione del pacchetto, senza dipendenza runtime dal repository; ogni consumer conserva il proprio rilascio e le proprie verifiche. Non promuovere automaticamente `editoriale/common.mjs` al repertorio.
- S03–S06: `combat-scene/1` e `narrative-editorial/1` già candidati. Role complete e attribuite, risultati server, continuità dai Fati precedenti, percezioni certificate con percettore esplicito; nessuna conoscenza o permission trasferita agli altri PG. Le fonti necessarie non vengono troncate per farle entrare nel budget.
- S07–S08: candidati Combat e release documentata hanno evidenze distinte. La campagna configurata finale resta 31 PASS/1 FAIL e review 0/1/0 terminale. Recovery live documentato il 09/09 su Edge 23; non certifica tutte le estensioni architetturali o tutti gli effetti.
- S01, S12–S15: mission_narratore_ai 18, CYCLE006/OPENING004, ultimo rilascio attestato l’08/09; sei persona e ruoli del ciclo già esistenti. Non riaprire la campagna Esame o importare vecchi filtri/rigenerazioni dalle analisi di agosto.
- S16: il PNG possiede identità, scopi, memoria di scena e relazioni; una scelta subottimale resta fra azioni legali. Lo standard progettuale non dimostra che un controller autonomo per tutte le scene libere esista.

### Ratifica narrativa corrente di Antonello — 09/09, trasmessa dal PM

S18: con role soltanto abbozzate si valuta fedeltà ai dati e resa accattivante della **singola mossa**; la valutazione complessiva della scena è rinviata a role complete. Il Clone di Sabbia ha la sagoma dell’evocatore, ma è di sabbia solida: quando il server ne determina la fine o la distruzione perde compattezza e cade infrangendosi al suolo. Le copie di Moltiplicazione sono invece illusioni senza solidità e spariscono in nuvolette bianche. Non si equiparano le tecniche e non si deduce la fine dal solo danno. Il server decide la cessazione; le caratteristiche certificate della tecnica ne determinano la rappresentazione. È una ratifica narrativa: non modifica regole, condizioni di cessazione o runtime.

S20, precisazione successiva e prevalente di Antonello: i dettagli generali non limitano la libertà narrativa del PG. La role è la fonte primaria per gesto, postura, ritmo e forma compatibile; il catalogo colma lacune e previene contraddizioni, il motore decide l’esito e il narratore integra senza sostituire il giocatore. Bastano pochi invarianti di identità, materiale, consistenza e limiti. Nessuna coreografia, frase obbligatoria, lista di ornamenti, copione della conclusione o template imposto al giocatore. Per la Sabbia sono necessari perdita di compattezza e ricaduta al suolo; l’immagine concreta resta libera. Moltiplicazione resta illusoria con nuvolette bianche, senza blocchi solidi. La completezza riguarda natura e comportamento necessario, non ogni dettaglio estetico.

Questa separazione fra caratteristiche statiche e fatti dinamici è la priorità del raccordo corrente. Non applicare genericamente «dissoluzione» a ogni copia, né inventare massa, collisioni, polvere, ostacoli o conseguenze meccaniche dalla sola descrizione del materiale.

### Evidenza live ricevuta dal PM e raccordo minimo prioritario

S19, verifica ROOT del 09/09 alle 16:17:36–38 UTC, non eseguita da questo owner: `combat_narratore_ai` v23. `ordinary_context` (MD5 `ec6a66b6599cdfb3d80aea6c12c9dd43`) costruisce l’etichetta della tecnica con CASE senza leggere descrizione/effetti del catalogo. `scene_snapshot_v2` (MD5 `542eb2b95627522ee8e0f28507fdf29b`) trasporta il context_payload meno quattro campi come resolved_facts e aggiunge setting/role/fato, senza catalogo. Nel caso Clone osservato il payload non conteneva descrizione/effetti; Edge `editorial.mjs` inoltra resolved_facts e fonti al modello. Il collegamento è dunque **mancante nel percorso collaudato**; non estendere questa conclusione a ogni altro consumer.

Sequenza minima:

1. Risolvere l’identità nativa della tecnica realmente usata dalla dichiarazione/ricevuta o dall’effetto persistente, senza dedurla dal nome nella role. Leggere descrizione ed effetti canonici già esistenti. Ulteriore evidenza S19 alle 16:18:31 UTC: per Clone la fonte è `clan_techniques.description` e `clan_techniques.danno_effetto`, ID `617484d6-af7b-41c3-a37f-615b22818421`, attivo. Il riferimento esatto dalla ricevuta a tale ID e l’impronta del contenuto vanno ancora pinzati prima della modifica. Moltiplicazione usa invece `jutsu.effect/limits`, ID identificato in S21; non inserire una seconda copia in clan_techniques.
2. Controllare sui campi esistenti i pochi invarianti necessari: identità, natura/materiale, consistenza e limiti; presenza e conclusione solo per il comportamento indispensabile, senza descrivere esaustivamente la coreografia. È una checklist editoriale sulla fonte: non impone nuove colonne, né un classificatore IA, né una migrazione del catalogo. Campo non applicabile distinto da dettaglio ignoto; eventuali lacune di contenuto tornano all’owner, senza inventare descrizioni.
3. Proiettare al narratore la sola descrizione/effetti autorizzata della tecnica attiva nel fatto, con identità/revisione o impronta della fonte conservata dal server. Lo snapshot transazionale è una copia di consegna, non un nuovo archivio canonico. Non inviare intere schede tecniche private o meccaniche non narrabili.
4. Separatamente collegare lo stato dinamico e, se attestata, la fine dell’effetto con la causa. Per Clone il dato ended va reso disponibile oltre a capture_failed; la rappresentazione viene dalla fonte statica ratificata e resa completa nei campi esistenti. Non estrarre stato corrente dalla descrizione statica.
5. Applicare il medesimo criterio alle tecniche di difesa e alle copie/effetti persistenti pertinenti: la tecnica attaccante non sostituisce quella del difensore e la copia già presente mantiene la propria origine. Un effetto non compare solo perché è nel catalogo o posseduto dal PG. Mappare attori multipli senza perdere attribuzioni.

Nessuna correzione del catalogo, codice o funzione viene effettuata da questa consegna. L’owner DB può risolvere il raccordo dentro i campi esistenti applicando la checklist della §4. Il controllo editoriale di completezza non è un nuovo filtro stilistico bloccante sulla prosa.

## 3. Confine di fiducia e responsabilità

Il **produttore del dominio** legge ricevute e stato persistente già autorizzati e determina fatti, ordine e visibilità. Il **proiettore** seleziona i soli fatti narrabili per il destinatario. L’**adattatore del consumer** li presenta insieme a role, ambiente e persona mantenendo l’autorità delle fonti. Il **modello** rende la scena, senza inventare esiti o colmare dati meccanici mancanti. Il **publisher esistente** verifica legame alla scena, versione e idempotenza prima della pubblicazione.

Un hash dimostra integrità, non autorità. Il client non può compilare un fatto con `authority=server` e renderlo valido. La verifica deve partire dall’accesso controllato del produttore alla ricevuta originale; non basta verificare campi autoasseriti. L’input del modello non è mai riscritto nel motore come risultato di gioco.

Separare due responsabilità logiche, senza prescrivere nuovi oggetti persistenti, tabelle o duplicazioni del catalogo: **registro interno dei fatti**, completo per il solo owner autorizzato; **proiezione narrativa**, filtrata prima dell’Edge/provider. Dati privati, risorse numeriche owner-only, segreti, riferimenti interni e fatti esclusi non raggiungono il modello. Il server conserva il collegamento per audit; il modello riceve etichette di scena, eventi e attribuzioni autorizzate, non un dump.

## 4. Checklist implementabile sui campi esistenti

I nomi di contenuto della tabella seguente sono requisiti semantici: non richiedono nuove colonne né un nuovo envelope. L’owner DB mantiene i binding già esistenti (`session_id`, round/ciclo, ricevuta/hash, `control_version`) e definisce il mapping versionato fra evento e tecnica nativa. Il client non può passare una tecnica arbitraria o rendere autorevole una label.

| Contenuto | Obbligo | Fonte e trattamento dell’ignoto |
|---|---|---|
| Identità tecnica usata e soggetto | Obbligatorio per un fatto di tecnica | Dichiarazione/ricevuta/effetto persistente; ID nativo, non matching della role. Se manca, non associare una descrizione per somiglianza. |
| Descrizione canonica | Obbligatoria se necessaria a rappresentare la tecnica | Per Clone: `clan_techniques.description`; versionare il mapping e conservare revisione/impronta della fonte nello snapshot/audit esistente. Nessun catalogo duplicato. |
| Effetti canonici pertinenti | Obbligatori per capire i limiti del fatto | Per Clone: `clan_techniques.danno_effetto`; proiettare il contenuto narrabile senza esporre risorse private né incaricare il modello di risolvere formule. |
| Materiale, consistenza, identità/somiglianza necessaria | Solo invarianti che impediscono contraddizioni | Catalogo per natura e limiti; role primaria per forma compatibile. Non richiedere un inventario estetico. Un dettaglio non attestato resta aperto, senza trasferirlo da una tecnica simile. |
| Manifestazione iniziale | Opzionale, salvo comportamento necessario della tecnica | Role primaria per gesto, postura, ritmo e forma compatibile; catalogo per i soli invarianti. Nessuna coreografia prescritta e nessuna ripetizione obbligatoria della creazione. |
| Natura della conclusione | Necessaria quando distingue tecniche alla fine attestata | Catalogo/ratifica chiariscono il comportamento indispensabile; il narratore compone liberamente l’immagine coerente con la role. Nessuna frase o coreografia obbligatoria. |
| Stato attuale, conclusione e causa | Obbligatori quando pertinenti all’esito | Ricevuta e stato dinamico. Causa ignota non annulla fine nota; danno non implica fine. Per Clone trasmettere `ended` oltre a `capture_failed`. |
| Ordine, attribuzione e origine effetto | Obbligatori per fatti multipli | Ordine e riferimenti nativi del server; attacco, difesa e copie persistenti mantengono tecnica e attore propri. Nessuna causalità dedotta dal modello. |
| Dettagli estetici ulteriori | Opzionali | Solo quelli già autorizzati; assenza significa ignoto e non blocca una mossa altrimenti completa. Nessuna nuova fisica, ferita o conseguenza di gioco. |

Il producer distingue esplicitamente dato noto, ignoto e non applicabile nel proprio mapping; non equipara campo assente a stato terminato, zero, invisibile o azione riuscita. Questa distinzione può essere ottenuta con i campi e controlli già presenti. Non si impone una struttura `status/value` generalizzata.

### Due lacune concrete del Clone

S19 alle 16:18:31 UTC: `description` contiene sabbia della giara, sagoma e trappola, avvolgimento/cattura e possibilità di essere ingannato da Moltiplicazione; non esplicita sagoma dell’evocatore, solidità e cedimento/infrangersi finale. `danno_effetto` contiene già fallimento della cattura che esaurisce il Clone, durata di tre turni e cause di rilascio dell’impegno, ma non la resa visiva finale. Le due lacune sono quindi **mancata trasmissione del catalogo al narratore** e **descrizione canonica incompleta rispetto alla ratifica corrente**. Collegare soltanto il testo attuale non basta a soddisfare quest’ultima.

L’integrazione editoriale dei contenuti è gestita separatamente dal PM nel cantiere Clan, perché Antonello vuole leggere descrizione ed effetto di Clone di Sabbia e Moltiplicazione prima della modifica. Questo contratto non contiene una nuova bozza sostitutiva e non autorizza scritture al catalogo. `danno_effetto` e tutte le condizioni meccaniche restano invariati in questa tranche.

S21, ulteriore verifica ROOT alle 16:22:14 UTC: Moltiplicazione è in `jutsu`, ID `c6e31b7b-38fe-4b4f-b3c7-05f3e922d193`, `name_it=Moltiplicazione`, campi `effect` e `limits`, senza colonna `description`. `effect` descrive copie illusorie, riposizionamento e confusione del primo attacco diretto; `limits` riguarda difesa e scadenza e non rappresenta pienamente le tre modalità nelle REGOLE §4.5 vive, secondo il PM. Il mapping è dunque eterogeneo: Clone usa description/danno_effetto, Moltiplicazione effect/limits. Non inventare colonne uniformi, duplicare tecniche o correggere tacitamente le meccaniche per uniformarle. Il limite editoriale/regolamentare è al PM; questa consegna non lo risolve.

Moltiplicazione rimane illusoria e senza solidità, con nuvolette bianche alla fine attestata; il Clone di Sabbia perde compattezza e ricade al suolo. La resa rimane libera entro questi invarianti e la role. Fonte e ID ora identificati non certificano ancora il binding dell’azione/ricevuta alla tecnica o la trasmissione dei suoi campi.

La descrizione statica dice come appare una conclusione; solo il server stabilisce se è accaduta. Nessuna aggiunta di peso, danni da caduta, detriti persistenti, copertura o effetti fisici dalla sola descrizione del materiale.

## 5. Osservabilità, memoria e dati mancanti

Il produttore applica la policy vigente prima dell’Edge: contenuto pubblico già autorizzato, percezione certificata con percettore esplicito, oppure contenuto escluso. Conserva il riferimento alla policy nella verifica/audit esistente; un flag scritto dal client o un hash non autorizzano la lettura.

Il contenuto escluso non viene serializzato per il modello, nemmeno come fatto censurato con identificatori rivelatori. Il fatto pubblico non attesta automaticamente che tutti i PG lo abbiano visto o possano bersagliarlo. Una percezione narrabile può essere attribuita solo al percettore autorizzato: non rivela originali di copie, coordinate segrete o bersagli agli altri. Nessuna permission di gioco nasce dalla pubblicazione di una frase.

Ordine di autorità: ricevuta/stato corrente per i fatti del momento → eventi storici certificati per ciò che è già avvenuto → role e parlato attribuiti come tentativi o dichiarazioni → Fato precedente come continuità narrativa. La cessazione attuale non cancella il ricordo di un fatto osservato; la memoria non riattiva l’effetto. Perdita di LOS o di capacità conserva solo quanto già percepito: niente aggiornamenti ulteriori senza una nuova osservazione certificata.

Se due fonti server discordano, il produttore risolve contro la revisione/ricevuta autorevole oppure restituisce errore tecnico prima del provider; il modello non arbitra. Lo stesso evento nativo non può avere due contenuti contraddittori nello stesso snapshot. Fra snapshot si rispettano revisione e semantica del dominio, senza riusare una claim vecchia con dati nuovi.

Dato opzionale ignoto: omesso dalla proiezione narrativa o indicato come non attestato, senza inventare il dettaglio. Fatto meccanico necessario ignoto, identità ambigua o binding invalido: niente nuova chiamata provider attraverso questo adattatore; usare lo stato di errore tecnico del percorso esistente, senza silenziosa retrocessione al legacy e senza nuovo filtro stilistico. Un dettaglio estetico assente non è un errore d’integrità, non impone blocchi o rigenerazioni: resta libero entro gli invarianti e la role. Un errore di integrità non è un giudizio sulla prosa. Il contratto non autorizza nuove soglie di lunghezza, retry o fallback.

## 6. Compatibilità con ciò che esiste

### Combat

S09 `scene_snapshot_v2` costruisce già `resolved_facts` dal `context_payload`, rimuove alcuni campi interni e lo serializza come testo. S03 `scene.mjs` ammette chiavi esatte e richiede quella stringa; S05 `scenePrompts` usa lo snapshot verificato. **Non aggiungere un campo JSON al livello superiore di `combat-scene/1`: il formato attuale lo rifiuta.** Non modificare il candidato terminale per farlo accettare.

Prima integrazione proposta: il produttore DB collega descrizione/effetti canonici e stato dinamico alla tecnica effettivamente usata e un proiettore deterministico genera la rappresentazione autorizzata dentro l’esistente `resolved_facts`. La checklist della §4 verifica la completezza senza costruire un nuovo registro. Non ricostruire i fatti meccanici interpretando il testo legacy. Se si rende necessario trasportare dati strutturati oltre quel confine, serve una nuova versione esplicita dell’involucro, con tutti i consumer aggiornati insieme.

Non alterare `scene_lock_v2`, `scene_current_v2`, acquire/permit/status/save/complete, riconsegna tecnica e `dispatch_narrative` per effetto di questo contratto. Restano binding alla ricevuta, permesso monouso, riconsegna ammessa solo negli stati già autorizzati, controllo della revisione al completamento e conservazione esatta del risultato. Nessuna seconda macchina ON/OFF o rigenerazione per ottenere una prosa diversa.

La sola serializzazione degli effetti non certifica tutti i percorsi Clan, percezioni Uchiha/Inuzuka, combattimenti con più attori o PNG. Il producer candidato S09 richiede attualmente due membri PG e tre generi ordinari: non è già un producer universale della Regia.

### Missioni ed Esame

S13 `cycleContext` usa payload versione 5, ricevuta, ruolo del ciclo, fatti, esito precedente, condizioni, segni, storia e spazio. Tiene separate intenzioni ed esito chiuso. S14 `openingContext` e S15 `runSession` conservano il proprio percorso. Applicare la checklist ai campi autorevoli esistenti senza cambiare versione, fasi o autorizzazioni implicitamente; un eventuale nuovo schema richiede compatibilità esplicita.

Le alternative di una fase ancora aperta non sono fatti compiuti. Il modello non può scegliere un esito non risolto fingendo che provenga dal nuovo contratto. Persona, reazione emotiva e dialogo del PNG restano nel profilo autorizzato; non diventano nuove azioni di gioco o progressione persistente. Il ruolo tecnico di assistenza/audit resta distinto dal Fato cinematografico.

### PNG nelle scene libere e allenamento

Lo standard S16 e il repertorio forniscono base progettuale/editoriale. Non è stata identificata in questa ricognizione una ricevuta universale che autorizzi presenza, turni autonomi, memoria persistente e azioni dei PNG nelle scene libere. La matrice registra il raccordo come mancante, non una funzione inventata. Prima dell’adattatore servono mappa del controller reale, autorità sulle azioni legali e policy della scena. Frequenza e iniziativa autonoma o mutazioni delle relazioni, se non già ratificate altrove, restano decisioni di prodotto aperte; non sono imposte da questi documenti.

## 7. Caso reale e criteri di accettazione previsti

Il finding S17 `CLONE-NARRATIVE-END-001` P2 osserva: motore `ended/capture_failed`, contesto con solo `capture_failed`, Fato senza conclusione esplicita. La parola «dissoluzione» nel referto storico non sostituisce le ratifiche S18–S20: per il Clone di Sabbia l’invariante è perdita di compattezza e ricaduta al suolo, con immagine libera e senza frase obbligatoria. L’adattatore deve collegare stato terminato e causa dinamici al profilo statico certificato del Clone di Sabbia, preservando il controllo server. Non riscrivere il Fato storico. Per Moltiplicazione usare invece illusioni senza solidità e nuvolette bianche alla cessazione attestata, senza trasferire materiale o conseguenze del Clone di Sabbia.

Criteri per la successiva implementazione, **non prove eseguite e non nuova campagna autorizzata**:

| Criterio | Esito richiesto |
|---|---|
| Clone osservato | Stato finale e causa distinti; Clone di Sabbia termina con perdita di compattezza e ricaduta al suolo, resa liberamente in coerenza con la role, solo se cessazione server e osservabilità lo autorizzano. |
| Tecniche distinte | Moltiplicazione resta illusione senza solidità, con nuvolette bianche alla fine attestata; il danno da solo non implica fine né trasferisce la conclusione di un’altra tecnica. |
| Qualità singola mossa | Con role abbozzate valutare fedeltà dei fatti e resa accattivante della mossa; nessun verdetto sulla qualità dell’intera scena. Con role complete si potrà valutare la scena complessiva. |
| Effetto persistente | Stato corrente e transizione non sono confusi; nessuna riattivazione derivata dalla role o dal Fato precedente. |
| Percezione certificata | Attribuzione al percettore, nessuna concessione di conoscenza/bersaglio, nessun aggiornamento dopo perdita del requisito osservativo. |
| Ciclo missione | Alternative legali restano alternative finché il server non risolve; risultato definitivo concorda con la ricevuta. |
| PNG | Persona e dialogo autorizzati, nessun parlato o scelta PG inventati; nessuna azione fuori dal controller del dominio. |
| Ignoto e integrità | Un dato opzionale non viene inventato; un fatto necessario o binding mancante impedisce la chiamata dipendente. |
| Compatibilità | Snapshot e protocollo persistente esistenti preservati; fonte necessaria integra, nessuna perdita per troncamento silenzioso. |

## 8. Sequenza implementativa e dipendenze

1. PM/DB/consumer riconciliano la proposta con le ricevute concrete elencate nella matrice; chiudono mapping e policy mancanti, senza riaprire decisioni ratificate. Questa consegna non è un gate di rilascio.
2. Owner DB collega prima descrizione/effetti esistenti e identità native, verifica la checklist editoriale sulle fonti e aggiunge solo i fatti dinamici mancanti; prepara quindi un candidato coerente per il percorso ordinary Staff già collaudato: identità nativa della tecnica, campi canonici e cessazione decisa dal server. Il contratto comune resta riusabile. La successiva estensione multiattore richiede mapping del roster, ricevute e qualificazione propri; non basta rimuovere la guardia a due PG. Tale estensione e la futura parità non bloccano il primo collegamento Clone nel percorso ordinary Staff. Priorità al P2 osservato e alla separazione fra profili statici certificati di tecnica ed eventi dinamici, mantenendo semantica generalizzabile degli effetti. La qualità della singola mossa resta distinta da quella di una scena con role complete. Il PM assegna nuovi file/revisione nei percorsi consentiti preservando le campagne terminali e i loro manifesti; i vecchi candidati non si patchano retroattivamente.
3. Owner narrativo prepara l’adattatore della rappresentazione e il profilo comune; in parallelo un owner di altro dominio può mappare missioni soltanto su contratto ormai stabile e file disgiunti. PNG liberi/allenamento avanzano dopo identificazione delle proprie autorità, non per analogia con Combat.
4. Integrare e congelare il candidato completo. QA fissa budget e matrice sulla stessa revisione, review unica, eventuale correzione aggregata e sola controverifica finale. Non ripetere campagne terminali Esame/Combat né ampliare il banco qui.
5. Gate applicativi/DB/Edge distinti, recovery e valutazione rischi; poi collaudo pertinente nelle due Test Room con isolamento e budget espliciti. Uno standard documentale o un esempio ben scritto non certifica il funzionamento live.

## 9. Consegna e delta PM

TASK-ID: IA-FATTI-CONTRATTO-001; unica correzione aggregata IA-FATTI-CONTRATTO-FIX-001 dopo review documentale 0/0/1 P2. Correzione limitata alla priorità ordinary Staff prima del multiattore; controverifica finale del solo P2 affidata al reviewer. Scope: soli due documenti candidati. Contratti usati: combat-scene/1, narrative-editorial/1, repertorio 0.3.0, payload ciclo Esame v5; nessuno di questi è stato modificato. Nuova proposta: raccordo minimo ai campi canonici esistenti, completezza semantica, lifecycle dinamico distinto e mappa produttori; nessun nuovo archivio o envelope universale. Nuova ratifica narrativa utente S18 recepita: Clone di Sabbia e Moltiplicazione distinti, fine solo server, giudizio qualitativo limitato alla singola mossa con role abbozzate.

Completo: percorso minimo fondato sui campi esistenti, evidenza S19 del raccordo mancante, checklist minima con obbligatori/opzionali/ignoto e libertà narrativa PG S20; distinzione autorità/osservabilità/memoria; mapping datato dei moduli riscontrati; lacune e sequenza implementativa. Incompleto per scelta di scope: codice, producer mancanti, prova della nuova proiezione, review indipendente e rilascio. Nessuna approvazione prodotto inventata. Nessuna fonte unica rimossa.

Verifica prevista per questa consegna: un controllo documentale aggregato di JSON, riferimenti locali, ID fonte, impronte dei contratti prenotati, sezioni obbligatorie e soli due output. Il risultato effettivo e le impronte sono consegnati al PM, senza scrivere un terzo referto condiviso. Zero SQL/provider/test runtime.

Delta da integrare esclusivamente dal PM: SCHEDA — «Contratto fatti narrativi e matrice produttori consegnati come proposta tecnica documentale, nessun rilascio»; HANDOFF — questo TASK-ID, due file, verifica e limiti; IA_NARRATIVA — nuovo passo preparatorio sul raccordo fatti/stato/cessazione/osservabilità, con P2 Clone come evidenza osservata, ratifiche S18–S20, libertà narrativa PG, caratteristiche statiche/cessazione e criterio di qualità della singola mossa; campagne terminali preservate. Stato del cantiere e delle funzioni live invariato da questo incarico. File locali: deposito selettivo e promozione del contratto restano all’integratore.
