# Finestra 4 · esito del fix e limiti residui

Il fix delle difese omonime è installato e verificato sulla Staff. Due opzioni server con la stessa etichetta restano entrambe selezionabili; passando dalla prima alla seconda resta una sola selezione. Un unico invio Schivata è stato acquisito e risolto. Il collaudo complessivo è **incompleto** e l’apertura pubblica di Copertura/Diversivo/Facing resta **OFF**.

Versione integrata: Root `e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce`; LAND `0ffbe20a9e1f038c85f6a2e7ef46e229d70b1b94d1b1dd51df07cce3d93c4942`, Admin `62662a0298167652944b6319991c17a1dc418554f32062a789388948c4d47d96`, commit `6fed6dd0d62d8d498f2d6be10794e156fde9dda0`. Edge35/157 e corpi DB invariati. Tre pin LAND e bindings UI/config/Party riallineati con adozione append-only. Review aggregata4 e conversione0/0/0, preflight10/10, Pages42379483826SUCCESS e marker dominio verificati; byte integrali dominio NOT_CAPTURED, blob Git2/2 esatti. Migrazione `combat_coverage_ui_metadata_staff_20261107` installata14:02UTC.

| Caso | Esito osservato |
|---|---|
| S12 · UI difese | PASS: opzioni1di2/2di2 entrambe raggiungibili, selezioni(true,false)→(false,true), cap1 e unico invio |
| S12 · retroIII | PASS circoscritto: ricevuta15410587-bc7c-4e7b-97a1-6707d473e74f, dot−4, rear=true, livello3, deduction1. MAX2 resta separatamente non rappresentato |
| S13 · T4 | Due offensive nello stesso piano. Soffio trova l’originale e riceve difesa normale; formazionefc0758b9 consumed/first_attack. SuccessivoKeita: vanished_copy_out_of_range,0danni, nessuna difesa o protezione ripetuta. PASS nel ramo prima-originale; copia-prima non osservata |
| S14 · T1 | NON qualificato. Dopo movimentoSud2, Copertura correttamente assente: spent_m nonzero impedisce un secondo movimento dell’originale; nessun costoMoltiplicazione |
| S15 · T1 corretto | Nessuna azione/costo/provider. IniziativaRiuji, geometria iniziale senza ritirata legale. Nessuna nuova estrazione per ottenere il primo attore preferito |

S12: un’attivazione III15, upkeep15 nei round2/3, spegnimento0 alla chiusura. Saldo testper50→5. S13: Copertura15 una volta, ritirata5m e Soffio5 una volta; saldiRiuji35→20/testper5→0. Due Fati umani S12 e un Fato umano S13 pubblicati una sola volta. S14 ha un solo Fato IA preliminare, quota dd884614-25bd-4767-9fb0-f35b640597c0 settled,3841input/1509output/0,0011386USD. Nessuna nuova Restore, riattivazione di statoON pagato, rimborso o reset.

Finestra autorizzata14:03:08–15:33:08UTC; conclusa14:37:55. Nuovi45comandi/4scene, tutte proprie chiuse; cumulativi232comandi/15scene/9provider/41743input/9662output/0,0090053USDsu0,10. Tre chiamate residue rispetto al cap12 e10338output residui rispetto20k; ogni request resta vincolata al suo upper9992output. L’assettoS15 richiederebbe almeno quattro ulteriori Fati per cambiare geometria, passare i turni, creare e poi attaccare la Copertura: non ammesso dai tre invii residui. Non si espandono i limiti durante la campagna e non si ripete l’iniziativa per cercare un verde.

Restano T1, ramo copia-escaT2, T3, copia-primaT5, confiniF1, F3MAX2 e ServiceT6–T8. MAX2: Fenice è l’unica tecnica multi pronta individuata ma non è disponibile nei tre PG/preset ammessi. Service: vecchia qualification20koutput/0,3136USD e sorgente specifica non ammettono questa campagna; nessun Event42 o provider Service avviato. Questi limiti non sono sostituiti dal PNG controllato da Master umano o da un PASS statico. Per proseguire servono un piano ordinario rappresentabile con budget finito e le dipendenze native Staff mancanti, prima di nuove prove. Nessun nuovo enable pubblico.

Postflight14:38UTC: tutte4scene di questa finestra terminali, values_written=false;0Combat/0MasterStaffaperti,0providerpendenti. PG realicca57a1c, Scorta7a3b9f5f/2982dcb e tutti6digestParty invariati. Root/DB23dd/Edge35-157/gate e noveInnatev3pubbliche preservati. Finali simulati Riuji20/OFF, testper0/OFF, Tamako5/OFF. Un’offerta PassaPNG scaduta è stata respinta senza costo e riletta nativamente, nessun duplicato. Il reload dopoaccept ha recuperato Common senza nuova azione; non è stato attestato un bug del routing. Anti-sonno proprio già terminato, monitor invariati.


## Storico delle campagne precedenti

I passaggi seguenti conservano gli esiti e i limiti delle finestre1–3. Per coverage, retroIII e T4 vale lo stato corrente riportato sopra.

# Esecuzione Staff · Copertura/Diversivo e punto cieco

Combat Tactics/Facing · 07/11/2026, consegna finestra3: Root9f7c4d97/Edge35-157/Admin93e3 invariati. QA terminata13:22:57Z entro finestra11:59:55–13:29:55Z:84nuovi comandi/4nuove scene; cumulativi187comandi/11scene tutte proprie chiuse/8provider settled/37902input+8153output/0,0078667USD entro0,10USD. Un solo Restore aggiuntivo autorizzato ed eseguito in S8, evento880d5a12, nessun reset o costo ripetuto. F2retroII−2 conservato; F4retroIV0 PASS, ricevutaad49cd1d/dot−4/orientamento precedente. F1 solo fronteI0; F3 solo fronteIII0, retro e MAX2 non qualificati. CoperturaMaster5m/15/copia/primoattacco/unicoFato positiva nel solo ramo osservato; T4dueoffensive incompleto. Diversivoordinary originale riconosciuto/difesa normale e Mastermisto con due attacchi nello stesso piano: prima estrazione originale, formazione esaurita, seconda offensiva ordinaria; ramo copia/esca NON osservato. UI coverage accorpa attacchi omonimi: proposta isolata cd6ee47b e review SOURCE_ONLY0/0/0, composizione LAND e runtime NOT_RUN. T1/T3 e serviceT6–T8 non provati; porta Generic non ammette il budget della campagna prima di Event42 (20000output/0,3136USD storici, non tetto0,10USD corrente). Pubblici Tactics/FacingOFF, noveInnatev3 pubbliche invariate. Postflight13:25: PG3realicca57a1c, Scorta7a3b9f5f/2982dcb, sei hashParty e gate esatti,0scene proprie aperte. Saldi simulati Riuji35/105 ByakuganIVOFF/PV69, testperfunzioni50/155 ByakuganIIIOFF/PV102, Tamako5/OFF; ON chiusi nativamente a costo0. Fonti TACTICS_FACING_QA e JOURNAL privato; lavoro complessivo incompleto, nessuna apertura nuova.

Le sezioni seguenti conservano matrice e criteri originali, non autorizzano una nuova campagna. Riuji dirige i propri Master e il PNG tramite selettore nativo; testperfunzioni partecipa in IAB. TamakoFirefox preservata. I normali nuovi contesti inizializzano i PV e conservano il chakra; non sono un pulsante Restore. Un selettore profilo locale senza Applica non cambia il server: profiloIV effettivamente applicato solo dopoS10,75chakra conservati.

# Copertura, Diversivo e punto cieco

Matrice proposta del 07/11/2026. Questo documento prepara il lavoro e non esegue DB, browser, gameplay o provider. I casi iniziano tutti NOT_RUN sulla futura versione integrata. Il PM congela prima dell'esecuzione identità, budget e disponibilità della Staff.

## Credito conservato e provenienza

- Assalto, Sostituzione e le nove Innate hanno già prove e aperture proprie. Non ricertificare il loro lifecycle generale. I loro confini condivisi compaiono soltanto nei casi pertinenti sotto.
- Gli smoke Copertura del 09–10/09 attestano creazione, costo e cessazione nel ramo osservato. Lo smoke 014 con selezione Safari incompleta resta NOT_RUN. Non attestano arretramento 5 m, cessione comune, ramo PNG di servizio o le nuove dipendenze. Le vecchie suite locali rosse rimangono storiche e non diventano il banco della ripresa.
- CORE007 resta 0/1/1, CORE008, dipendenze, pacchetto e rebase conservano i rispettivi 0/0/0. Tattiche001 conserva aggregata prodotto 1/5 e controverifica002. La successiva integrazione current-release del 02/11 conserva review NOT_RUN nel proprio manifest. Non riavviare conteggi con il nuovo nome del piano.
- Il PM ha riferito il confronto DB indipendente del 07/11. Entrambi gli helper tattiche sono già presenti ai posthash del manifest 02/11, con gate v2 Staff=true e ordinary/master/generic=false. La ripresa compone provenienza e disponibilità della stessa implementazione, senza reinstallare CORE008 o presumere che i due helper manchino.
- Facing ha geometria ratificata il 02/11, sorgente `96a3941e…`, quattro resolver modificati, sei helper e tre tabelle private, trigger di completamento e recovery forward. Manifest e contratto dichiarano review e Staff_QA NOT_RUN, 12/12 SELECT autore conservate. Il vecchio limite L1 è una fotografia del 02/11 da riconciliare con le attuali autorità dei livelli, non un permesso di dedurre ON da template/apprendimento.

Manifest e consegne da mantenere nel referto finale [COMBAT_TACTICS_MANIFEST.json](/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_TACTICS_MANIFEST.json), [COMBAT_TACTICS_HANDOFF.md](/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_TACTICS_HANDOFF.md), [FACING_MANIFEST.json](/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/FACING_MANIFEST.json), [FACING_CONTRATTO.json](/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/FACING_CONTRATTO.json).

## Porte UI e identità

Il consumer pubblicato verificato dal PM è il blob LAND `cae4e0da5760bf062e79c6595e5d4ce608d615ca`, main `13daea7169c67791a20924b07490ebfbb6bc95ed`. Gli [estratti](/private/tmp/combat-mosse-plan-20261107/LAND_PUBLISHED_EXCERPTS.txt) riportano le righe originali. La LAND locale ha drift e non è la baseline di rilascio.

| Ruolo proposto | Porta | Uso nel runbook |
|---|---|---|
| Riuji | Scheda Chrome già aperta dell'utente, se disponibile | PG che crea una formazione o attacca una formazione. Soltanto la propria identità. |
| Tamako | Firefox già disponibile, se presente | Secondo PG. Per Facing usa uno stato Byakugan certificato ottenuto dalle normali offerte Staff. |
| testperfunzioni | IAB già disponibile, se presente | Master umano della scena a due PG e PNG nativi. Quando dirige non va contato anche come PG combattente. |
| PNG | Porta Master o servizio nativo della scena autorizzata | Il Master umano prova il controllo umano del PNG. Il caso service-PNG richiede il distinto permit e percorso Generic nativo. |

Disponibilità dei browser e identità non verificate da questo audit. Una tab autenticata per un account non sostituisce quella di un altro. La mancata presenza di IAB lascia in attesa i soli casi che richiedono il terzo conduttore.

Per ordinary, usare la card del duello e il pulsante «Apri scontro», poi il pannello Common scelto dal routing Staff. Nel Common pubblicato la sequenza è «Movimento», «Innata», «Tecniche disponibili», gruppi di scelte ricevuti dal server, «Conferma scelta», quindi normale role e «Invia» dalla chat. «Aggiorna» rilegge, non reinvia. Le righe remote originali 3372–3375 definiscono le offerte, 3623 la lettura, 4096–4181 i passaggi, 4293–4295 la conferma.

Per Master, usare la porta Regia multi-attore e il setup di duello/Quest già offerto dal sito, iscrivere i soli PG autorizzati e un PNG del catalogo Staff con squadre e posizioni native, quindi il normale avvio dello Scontro. Il Common espone «Gestione della scena» secondo identità e permessi. Non usare l'Esame aperto o la vecchia Regia PNG fuori dalla scena protetta per sostituire il percorso.

Il form Master pubblicato riconosce `combat-v2-multiplication-offer/1.0`, modalità e numero copie esclusivamente dal server. Se l'offerta manca mostra «Non ancora consegnabile», anche se il selettore contiene nomi di fallback. Quel testo non autorizza un attacco generico. Riferimento remoto originale 7173–7208. Le conferme Master e il Fato devono essere quelli realmente offerti dalla scena. «Pubblica Fato e apri le risposte» è una porta di conduzione esistente, non un comando da usare fuori dal relativo contesto.

Non esiste un comando di rotazione da aggiungere per Facing. L'orientamento segue la propria ultima azione di attacco o difesa completata. Movimento, Passa, preview, invio respinto o annullato e prosa non lo aggiornano.

## Matrice tattiche minima

Otto casi funzionali della matrice CORE008 rivisti per la sola Staff. I casi possono condividere scene e round quando le normali offerte e i profili lo permettono. La divisione in righe non impone otto nuove scene.

| ID | Percorso realmente mancante | Riscontro necessario |
|---|---|---|
| T1 | Ordinary, Copertura PG | Una principale e costo 10+5 per copia una volta, cessione, arretramento esatto 5 m rispetto all'ostile/figura visibile scelti e percorso legale. Nessuna offensiva aggiuntiva. Scelta avversaria nativa di figura, difesa normale soltanto se è risolto l'originale. |
| T2 | Ordinary, Diversivo ravvicinato PG | Una copia selezionata con i normali permessi, movimento dell'attaccante verso l'esca entro il residuo dopo l'avvicinamento, ostacolo/percorso contabilizzati una volta. Il proprietario non viene trascinato. |
| T3 | Ordinary, Diversivo a distanza | Offensiva consumata e formazione conclusa con nessun movimento forzato. Un'eventuale scelta nativa dell'originale mantiene la difesa ordinaria e non viene fatta passare per successo del ramo copia. |
| T4 | Master umano, Copertura, due attacchi pertinenti | Un round con almeno tre combattenti consente di osservare l'ordine nativo. La prima interazione pertinente termina la formazione. La successiva non riceve di nuovo la protezione. Nessun secondo target scelto dopo aver visto il primo esito. |
| T5 | Master umano, Diversivo, attacchi misti | Ravvicinato e distanza nello stesso piano, readiness corretta quando il primo bersaglio è copia, nessuna difesa inventata. Distinguere originale riconosciuto, copie svanite e originale ormai fuori portata dai relativi fatti server. |
| T6 | PNG di servizio usa Copertura nella Staff | Offerta, capability/permit e controller nativi. Stesso costo/cessione del PG, nessuna principale autonoma ulteriore e nessun dato dell'originale inviato al destinatario non autorizzato. |
| T7 | PNG di servizio usa Diversivo nella Staff | Stesse autorità native, movimento residuo, corretta uscita del ramo ravvicinato e nessun ampliamento di scope fuori dalla scena. |
| T8 | PNG di servizio attacca una formazione | Offerte anonime e selezione nativa delle figure. Copia colpita consuma l'offensiva senza richiesta di difesa. Originale trovato segue la normale difesa PG. Il controllo dell'Innata del PG conserva la propria identità. |

T6–T8 non sono coperti dal solo PNG controllato dal Master umano. Se la porta Generic non può rappresentare questi casi senza attivazioni generali o bypass, fermare e riferire il limite di quel ramo. Il nuovo mandato non trasforma l'AI in un attore impersonato via SQL.

Usare «Estrazione del server» o una figura offerta e riconoscibile attraverso i permessi del gioco. È lecito predisporre una selezione deterministica tramite normali offerte e riconoscimento autorizzato. Non usare indici privati letti dall'auditor per guidare il client e non ripetere l'estrazione finché esce il ramo desiderato. Il referto registra il ramo osservato e gli altri rimangono NOT_RUN. Ulteriori casi positivi possono essere predefiniti solo dopo che il PM ha dimostrato una preparazione nativa, nel budget congelato.

## Matrice Facing minima

Quattro contesti di livello bastano per evitare di ripetere il lifecycle delle nove Innate. Per ogni livello serve soltanto un'attivazione legittima se non esiste già lo stato adatto. Non presumere cambio di profilo a Scontro aperto. L1 raccoglie i confini geometrici, L2–L4 le sole differenze di deduzione, mentre i casi Master raccolgono multi-target e origine PNG.

| ID | Contesto | Celle e risultato atteso |
|---|---|---|
| F1 | Ordinary, PG Byakugan L1 certificato | Primo attacco senza orientamento → 0. Dopo propria azione completata, fronte dot>0 → 0, laterale esatto dot=0 → 0, retro dot<0 → −3. Il movimento dell'attaccante non ruota il difensore. Se la difesa termina, il nuovo facing vale solo per il seguito, non per il colpo già calcolato. |
| F2 | Master, PG Byakugan L2 certificato | Un attacco posteriore produce −2 una volta nel totale difensivo. La stessa snapshot documenta che dadi, pool, Potenza e danno base sono quelli nativi. |
| F3 | Master, PG Byakugan L3 certificato e propria azione multi-target legale | Orientamento dal solo bersaglio primario certificato `target_actor_id=ordinal1`, non da ordinamento del client o dall'ultimo child risolto. Attacco alle spalle rispetto a quel vettore → −1. Due origini diverse nello stesso round devono essere valutate sulla rispettiva ricevuta, senza ruotare anticipatamente il difensore. |
| F4 | Master, PG Byakugan L4 certificato e origine PNG/compagno pertinente | Retro → 0 pur con livello attivo e geometria posteriore. Se c'è una marionetta legalmente disponibile, l'origine è il corpo del compagno, non il controllore. Per verificare anche il malus da quella origine, abbinare la prova a un contesto L1–L3 già predisposto. |

Queste sono celle logiche, non una promessa che ogni mossa sarà offerta nella prima scena. Il PM verifica la disponibilità di un attacco multi-target e del compagno attraverso gli strumenti Staff esistenti, senza acquisizioni o modifiche alle schede reali. Se non sono rappresentabili, si conserva il limite preciso di F3 o dell'origine marionetta.

Confini da coprire staticamente nel candidato integrato e con evidenza runtime soltanto se il normale setup li rende legali

- Byakugan OFF o nessuna autorità di stato attivo → nessuna deduzione. Non dedurre livello o ON da catalogo, template o massimo appreso.
- Origine coincidente con il difensore → dot=0 e nessuna deduzione. Non sovrapporre corpi con SQL per costruire il caso se collisioni/setup lo impediscono.
- Origine assente/ambigua, attacco ad area senza origine univoca o copie senza origine certificata → 0. Riconoscere l'originale non decide automaticamente il retro.
- Cambio di istanza/versione della mappa o assenza di facing → 0. Nessuna modifica apposita alla mappa durante uno Scontro per provocare il ramo.
- Ricevuta validata su tx/backend, attacco, attack_target, difensore e snapshotSHA. Dato client o marker di matematica non autorizzano il malus. Verifica per review e audit readonly, senza fault injection live.
- Solo la propria azione completata cambia il facing. Il vettore resta fisso rispetto alla posizione certificata in quel momento, senza inseguire il bersaglio mentre si muove.

La formula attesa è una sola sottrazione di 3/2/1/0 dal totale difensivo prima del margine. Non trasformare il malus in un danno fisso o in una variazione di pool/dado. Per ogni colpo osservato conservare il collegamento al referto con `mod_byakugan_blindspot` e ricevuta privata, rendendo nel Fato soltanto le conseguenze già risolte.

## Figura privata, difese e unico Fato

Per ogni T1–T8 fissare i seguenti checkpoint come letture di audit del futuro esecutore

1. Prima della scelta avversaria, registrare formazione, versione, figure eleggibili e offerte pubbliche dei due punti di vista. L'auditor conserva gli hash privati separati. Il client riceve soltanto identità delle figure e indizi autorizzati.
2. Prima delle difese, la preselezione privata usa ordine/iniziativa/entropia nativi. Non pubblica esiti, non consuma risorse e non svela originale o seed. La lista delle difese deriva dallo stesso piano.
3. Se la scelta cade sulla copia, nessuna dichiarazione difensiva fittizia, readiness soddisfatta per il solo attacco certificato e nessun costo di difesa. Se cade sull'originale, la difesa è offerta normalmente. Facing viene applicato solo dove c'è il confronto pertinente e l'origine certificata.
4. Al commit, un costo principale, un tratto di movimento con la sua ricevuta e una conclusione della formazione. Il round non riceve un secondo effetto dopo le altre azioni del piano. Le azioni successive conservano i propri target e risultati nativi.
5. Report, fatti narrativi e Fato condividono la stessa risoluzione. La narrativa racconta tutti gli attori e distingue copia colpita, originale trovato e figure già svanite, senza indici segreti, coordinate private, nuovi tiri o esiti anticipati.
6. Il recupero dello stesso invio passa dal journal/porta UI esistente soltanto quando vi è esito incerto reale. Non generare apposta un doppio invio per collaudare idempotenza. Dopo l'eventuale verifica non devono comparire costi, azioni, report o Fati duplicati.

## Sequenza e budget da congelare dal PM

Prima di qualunque prova, l'integratore confronta la baseline viva, il consumer pubblicato, i quattro resolver Facing e le funzioni condivise con le tattiche. Una sola composizione, review pertinente e preflight precedono il rilascio Staff. L'installer e le recovery del 13/09 non vengono riutilizzati cambiando soltanto pin.

Eseguire prima i casi PG ordinary e Master con narrazione umana e zero provider. Incorporare F1–F4 nei medesimi setup quando attori, geometria e profili lo consentono. Poi eseguire T6–T8 nella porta nativa di servizio con budget separato. Le otto righe tattiche e quattro righe Facing sono il tetto proposto di casi logici, con nessuna espansione esplorativa durante il run.

Prima di avviare il blocco service, il PM fissa scene, comandi, tempo, chiamate Count/Generation, token e spesa usando la catena reale. Il vecchio tetto di 16 provider/120000 input/20000 output/60 minuti apparteneva alla proposta del 13/09 e non è una finestra attiva. Un solo Fato può richiedere più chiamate interne, tutte contabilizzate. Nessun costo nuovo è impegnato da questo documento.

Preflight e postflight conservano schede reali, inventario, PV/chakra, progressione, Scorta, Party, Esame e storico delle scene precedenti. La prova usa il contesto protetto nativo e non resetta il simulatore per ottenere saldi comodi. Al rosso raccogliere la causa senza cercare un ramo casuale verde. Isolamento/accesso errato fermano il caso dipendente. Alla fine chiudere soltanto le proprie scene con le porte native, conservando audit e ricevute. L'apertura di ciascun perimetro segue i soli percorsi qualificati.

## Fonti mirate

[QA CORE008](/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/allineamento_consumer/pannelli/candidato/multiplication_tactics001/resume_site001/QA_PLAN.md), [contratto CORE008](/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/allineamento_consumer/pannelli/candidato/multiplication_tactics001/resume_site001/CONTRACT_CORE.md), [rebase](/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/allineamento_consumer/pannelli/candidato/multiplication_tactics001/resume_site001/REBASE_HANDOFF.md), [decisioni Facing](/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/FACING_DECISIONI.md), [handoff Facing](/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/FACING_HANDOFF.md), [fonte Facing](/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/FACING_SOURCE.sql:134), [checkpoint storici Clan](/Users/antonello/Desktop/theuntoldstory/dossier/aree/CLAN.md:206).
