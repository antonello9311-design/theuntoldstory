# MISSION-GENERIC-REVIEW-UI-R1 · referto indipendente iniziale

Esito della sola superficie UI: **ROSSO — P0/P1/P2 = 0/2/3**. Parte della review aggregata REV1, non una qualifica del backend né autorizzazione di apply. Nessun codice corretto durante la review.

## Perimetro congelato e metodo

- mission-generic-ui.mjs SHA256 `a9ce84cbde71d39fafbe8135ee261e75f746cb628593105081d8c43fe6871537`.
- mission-generic-land.html SHA256 `83bbab408c8df1a476549ac88387bf2771f8a46e5845e5a1cf11a6b4114dc8e8`.
- MISSION_GENERIC_UI_DELTA.json SHA256 `af11f68b7e351a9d9b0d105830fc953dfc80726ec723366e3190472021bc6ad5`.
- MISSION_GENERIC_UI_HANDOFF.md SHA256 `0ea282c1b3269dd383d25470a67b410694f66cde029123b204575e80c547895e`.

Contratti letti: DB `6db7db05…`, PLAN_WRITER `4a4fd396…`, BOARD `f247b359…`, OUTCOME `94990789…`, PROGRESS `2adebee4…`; trasporto HTTP letto soltanto per confrontare envelope tick. Per i due punti d'ingresso vivi sono state lette la definizione di `public.bacheca_missioni()` e le sole colonne pubbliche delle location Test Room. Nessuna role o dato riservato letto.

Controlli statici: syntax check del modulo e dei sei script inline PASS; inversione delle undici sostituzioni con unicità 11/11 PASS e ricostruzione SHA baseline `55f1e21e9b659564af80d5fa6c2578af5f7302466d8062966e433a34bb04b18b`. Il normale eseguibile node non era nel PATH: check ripetuto con runtime bundled disponibile, esito positivo. Nessun codice applicativo eseguito, banco, browser, provider o prova funzionale.

## Finding

### UI-R1-01 · P1 · La Test Room reale è esclusa dall'aggiornamento della missione

**Evidenza:** `mission-generic-land.html:10712` ritorna immediatamente quando `cur.is_exam_room` è vero, senza eccezione Test Room. Lettura viva: la location attiva Test Room `0b85f354-9cdb-47e1-baf9-3d266bb7e06b` ha **is_test=true e is_exam_room=true**. Il consumer Common vicino già distingue la Test Room dall'esame (`land:5177`); BOARD.location_runtime fa altrettanto.

**Effetto:** lo staff può avviare la prova dal dialogo (`mission-generic-ui.mjs:125–128`), ma il normale refresh `loadMasterV2 → missionGenericRoomRefresh` non chiama `updateRoom` nella stanza autorizzata. Non vengono mostrati stato/scelte generici e non parte `tick`, che è chiamato soltanto da `updateRoom` (`mjs:176`). L'incipit appena accodato resta senza consumer UI ordinario; il collaudo richiesto non è percorribile.

**Correzione richiesta:** ammettere le Test Room nel controllo di instradamento coerentemente con il server e preservare l'esclusione dell'esame reale. Non dedurre il percorso dalla sola presenza del flag esame.

### UI-R1-02 · P1 · Il salvataggio ricostruisce e altera parti valide della configurazione non mostrate dall'editor

**Evidenza:** caricamento `mjs:39–43`: actorMap globale conserva l'ultima copia di ciascun actor_key, compreso team, e per l'incontro conserva soltanto encounter_key/pg_team. Salvataggio `mjs:82–89`: riusa la copia globale degli attori in ogni fase, include nell'incontro tutti gli attori meccanici della scena e omette zone_key. Il contratto DB consente team distinti per scena (`DB:180–184`, identità confrontata senza team), encounter.actors sottoinsieme di scene.actors e zone_key opzionale (`DB:127–140`). In più `mjs:37` prende `detail.definitions[0]` invece della definition_id della revisione restituita dal catalogo (`PLAN_WRITER:57`): una diversa definizione sigillata sullo stesso piano può essere caricata al suo posto.

**Effetto concreto:** modificare solo un obiettivo e salvare una revisione con un PNG spettatore meccanico lo rende combattente; uno schieramento diverso fra due fasi viene uniformato all'ultimo; la zona selezionata viene persa. Gli input sono validi per il backend, non rientrano nei due casi che l'editor rifiuta esplicitamente (source_kind specializzati e incontri multipli), quindi la sostituzione è silenziosa. Nessun run storico viene riscritto, ma la nuova revisione selezionabile contiene regole diverse da quelle approvate dall'operatore.

**Correzione richiesta:** caricare la definition_id esatta della revisione; preservare i campi non modificati e le assegnazioni per scena/incontro, oppure rifiutare esplicitamente le configurazioni non rappresentabili prima di consentire il salvataggio. Il read→edit→write non deve normalizzare questi elementi implicitamente.

### UI-R1-03 · P2 · Dopo una revisione salvata ma non selezionata, l'editor resta bloccato sulla base precedente

**Evidenza:** `mjs:33–36` preferisce sempre la revisione selezionata anche quando il catalogo contiene una revisione più recente; questa diventa `base_plan_version_id` (`mjs:91`). Il writer rifiuta una base che non sia l'ultima versione del medesimo piano con `MGP_BASE_VERSION_STALE` (`PLAN_WRITER:103–109`). Non esiste selettore revisioni nel dialogo; `Usa per i prossimi avvii` è disabilitato quando selected===base (`mjs:106`).

**Riproduzione logica:** versione 1 selezionata; salva versione 2; chiudi senza selezionarla (oppure risposta di salvataggio persa). Riaprendo viene caricata la 1. Non si può selezionare la 2 dalla UI e ogni ulteriore salvataggio usa la base 1 ormai obsoleta. L'istruzione di riaprire per recuperare un salvataggio incerto (`mjs:100`) non risolve il caso.

**Correzione richiesta:** distinguere revisione selezionata per avvio e ultima revisione disponibile per modifica, offrendo selezione/rilettura delle versioni già sigillate senza un secondo salvataggio.

### UI-R1-04 · P2 · La missione storica conclusa non ha un ingresso UI per la prova protetta

**Evidenza:** i soli agganci che chiamano editor e board sono aggiunti alle schede `renderMissBacheca` (`land:10739,10754,10831–10832`). La funzione viva `public.bacheca_missioni()` filtra `m.status in ('aperta','programmata')`, anche per staff. La tab “mie” usa un renderer diverso senza questi agganci (`land:10768` e seguenti). Il dialogo staff avvia soltanto il `mission` ricevuto dalla scheda (`mjs:127`), senza catalogo/selettore delle sorgenti concluse.

**Effetto:** il raccordo backend di test accetta una missione originale conclusa, ma l'operatore non può scegliere dal sito la missione storica da riusare, compreso il caso Nodo richiesto per il collaudo. Riaprire o cambiare lo stato della missione originale sarebbe contrario alla conservazione dello storico e non è una soluzione.

**Correzione richiesta:** aggiungere un ingresso staff per selezionare una sorgente storica autorizzata e configurata, conservando i filtri della bacheca utenti e lo stato originale.

### UI-R1-05 · P2 · Il consumer impone un PNG combattente dove il contratto ammette roster senza PNG

**Evidenza:** `mjs:80` rifiuta ogni fase mechanical che non includa almeno un actor con mechanical_binding_id; il controllo non considera il numero dei PG. Il contratto congelato (`MISSION_GENERIC_CONTRACT.md:7`) ammette 0..N PNG per fase; il validator DB non richiede encounter.actors non vuoto (`DB:127–140`). Il limite aggiunto esiste soltanto nel consumer.

**Effetto:** una missione con due PG e un incontro senza PNG, oppure una configurazione valida importata con tale incontro, non può essere salvata dall'editor. Il consumer restringe la generalizzazione già prevista senza esporre il limite come configurazione server.

**Correzione richiesta:** demandare la legalità del numero complessivo dei combattenti al contratto server e distinguere chiaramente una fase narrativa senza incontro da un incontro fra PG. Se il relativo percorso Combat non è ancora supportato, dichiararlo e bloccarlo tramite capability condivisa anziché un controllo UI implicito sui soli PNG.

## Copertura positiva e limiti del referto

RPC missione/ready/withdraw/choice: nomi, parametri e CAS coerenti con le candidate lette. I pulsanti staff sono limitati in UI e le RPC sensibili hanno verifiche server; la UI non invia valori meccanici. Uso prevalente di textContent per contenuto variabile, nessuna interpolazione HTML nuova di testi liberi nel modulo. La stanza rilegge identità e location dopo gli await; dispose invalida epoch e chiude il dialogo. Il tick utilizza envelope e endpoint previsti, una richiesta attiva per istanza UI; l'idempotenza effettiva resta lato server da qualificare nella review backend.

Il delta non introduce un secondo pannello Combat: aggiunge editor, bacheca e scelte narrative, lasciando Common come consumer scontro. Le configurazioni con source_kind specializzati o più incontri nella stessa fase vengono rifiutate esplicitamente. Questi aspetti positivi non compensano i finding sopra.

Non valutati funzionalmente: aspetto a schermo, realtime, RPC su Auth reale, concorrenza, provider e isolamento risorse. Nessuna scena preesistente modificata o chiusa. Budget rispettato: meno di 30 minuti, 0 provider, 0 casi funzionali. Dopo correzione aggregata occorre la controverifica pertinente della revisione congelata; questo referto non consente apply/deploy da solo.
