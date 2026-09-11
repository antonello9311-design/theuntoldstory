# MISSION-GENERIC-REVIEW-UI-C1 · controverifica indipendente A1

**Esito della superficie UI: VERDE — P0/P1/P2 = 0/0/0.** I finding UI-R1-01..04 risultano corretti nel codice congelato. UI-R1-05 è risolto secondo la decisione di capacità esplicita del PM incorporata in A1: fasi narrative anche senza PNG; ogni incontro missione richiede almeno un PNG avversario, senza introdurre PvP.

Questo è il referto UI della prima controverifica aggregata. Non certifica i moduli DB scritti dallo stesso agente, non sostituisce gli altri referti e non autorizza autonomamente apply/deploy o apertura.

## Congelamento verificato

Manifest integrato A1: `MISSION_GENERIC_INTEGRATED_MANIFEST.json`, SHA256 `9064ed3428975a78135228b57e527b3b957fdbe90111d0c6c750b8d59599bf3b`.

| Superficie | SHA256 | Esito |
|---|---|---|
| mission-generic-ui.mjs | 42dc0b057e0c234059b0a59a934ae1a5343363335f839f9f7f7e5aeffa2bb7b5 | Hash e byte corrispondenti |
| mission-generic-land.html | 8281316af281e08ea43e399ab5fd04b860f954765de23371100f6fc2b93b2851 | Hash e byte corrispondenti |
| MISSION_GENERIC_UI_DELTA.json | 8bda10c388e33f5be0e66695514c154d3fb6b00d37b2cb5a4813d53e70bbfbbd | Hash e byte corrispondenti |

Contratti DB/PLAN_WRITER/BOARD/OUTCOME/PROGRESS A1 consultati solo per interfacce, envelope, autorizzazioni richieste e semantica consumata dalla UI. Nessuna autoreview dei loro interni. Il contratto aggiornato e il mandato dell'aggregata A1 sono stati letti come baseline di scope.

## Controverifica dei finding R1

| Finding | Evidenza della correzione | Esito |
|---|---|---|
| UI-R1-01 — Test Room esclusa | `land:10712` esclude soltanto `is_exam_room && !is_test`. `loadMasterV2` continua a chiamare il refresh generico a `land:5174`. La Test Room con entrambi i flag entra ora in updateRoom; l'esame reale rimane escluso. | Chiuso |
| UI-R1-02 — perdita configurazione | `ui.mjs:40` sceglie la definition_id esatta del catalogo. `:43–46` conserva actor_specs per fase, fighters espliciti, copia completa encounter e transizione. `:94–101` riusa le copie per fase, il sottoinsieme dei combattenti, encounter.zone_key e i campi non modificati; `:95–98` preserva transition_key, event_kind, priority e fact_code. Schieramenti di fase e partecipazione allo scontro sono modifiche esplicite a `:74–77`. | Chiuso |
| UI-R1-03 — revisione salvata irraggiungibile | `:33–40` separa revisione mostrata e base più recente dello stesso piano; `:55` offre scelta delle revisioni salvate, evidenziando quella selezionata per avvio. `:114–118` seleziona la revisione mostrata o appena salvata, senza richiedere una nuova sigillatura. Riaprendo dopo salvataggio non selezionato si trova la revisione disponibile. | Chiuso |
| UI-R1-04 — sorgenti concluse assenti | `:150–158` legge archivio missioni senza filtro di stato, con campi limitati id/title/status e ingresso riservato staff. La sorgente scelta passa ai normali editor/board. `:161` aggiunge il pulsante archivio; `land:10741` esegue decorateBoard anche a bacheca vuota. La sorgente originale non viene riaperta o modificata dal selector. | Chiuso |
| UI-R1-05 — capacità PNG divergente | `:92` espone esplicitamente il requisito di almeno un PNG combattente avversario e consente zero PNG narrativi. La decisione PM A1 è scritta in `MISSION_GENERIC_CONTRACT.md:7` e il catalogo server espone encounter_options coerente. Il vecchio finding non viene risolto estendendo il motore a un nuovo caso PvP. | Chiuso secondo scope A1 |

Per l'accesso all'archivio è stata verificata in sola lettura la policy viva di `public.missions`: SELECT authenticated protetta da `missions_staff_read`, qual `is_staff()`. Non è quindi una protezione affidata soltanto a isStaff nel client. Non sono stati letti record di missioni o contenuti narrativi durante la controverifica.

## Regressioni pertinenti controllate

- I dati variabili dell'editor e dell'archivio sono resi con textContent/elementi DOM; nessuna nuova interpolazione di HTML da contenuti liberi. La scelta della sorgente resta un ID di missione, senza fatti di gioco forniti dal client.
- Catalogo, seal/select, Board join/start, ready/withdraw e choice mantengono nomi parametri, CAS e shape dei contratti A1. I valori meccanici restano fuori dal payload UI. La prova Staff è ancora sottoposta alla porta server autorizzata; il selector non scavalca la whitelist del roster.
- La revisione esatta caricata conserva la propria configurazione per fasi/incontri. Profili cambiati dall'operatore vengono propagati esplicitamente alle relative copie per fase; schieramenti di fase e sottoinsieme combattente restano separati. Configurazioni che l'editor non rappresenta — source_kind specializzati e incontri multipli nella stessa fase — sono respinte prima del salvataggio.
- Il consumer non aggiunge un secondo pannello scontro: i dodici delta modificano agganci, editor/archivio e blocco delle scelte; Common resta il pannello Combat esistente. Nessuna nuova geometria o risorsa personaggio viene calcolata qui.
- Per lo stato invariato, `ui.mjs:187–188` confronta la firma serializzata prima di sostituire i figli del solo blocco missione. Nessun reload di pagina o smontaggio del pannello Common è introdotto. roomBusy impedisce aggiornamenti sovrapposti della stessa istanza; identità, location ed epoch sono ricontrollati dopo gli await (`:180–185`), dispose invalida la stanza (`:203`). Non emerge una causa statica nuova di flickering continuo a stato invariato. La fluidità visiva resta da osservare sul sito.
- Tick mantiene una richiesta attiva per istanza UI, con envelope autenticato; la protezione contro doppio lavoro fra client resta responsabilità del contratto server e del relativo reviewer. Nessuna chiamata provider è stata eseguita per verificarla.

## Statica eseguita e limiti

Syntax check del modulo ES e dei sei script inline con runtime Node bundled: **PASS**. Inversione selettiva dei dodici delta: unicità **12/12**, SHA baseline ricostruito `55f1e21e9b659564af80d5fa6c2578af5f7302466d8062966e433a34bb04b18b` esatto. File di prodotto e candidate non modificati; solo questo referto è scritto tramite guard.

Nessun browser, gameplay, provider, test funzionale locale o ambiente ricreato. Non attestati empiricamente: rendering su 14 pollici, assenza visiva di flicker, Auth/RLS via browser, avvio/incipit e chiusura effettivi, concorrenza di sessioni. Questi rimangono casi pertinenti del collaudo reale sul sito dopo la review integrata.

Budget rispettato: meno di 30 minuti, zero chiamate provider e zero casi gameplay. Controverifica unica C1: nessuna autopatch o microfinding durante il passaggio. Il PM può aggregare questo **0/0/0 UI** agli altri ambiti senza azzerare il budget cumulativo.
