# E65 — analisi, correzioni e tre prove editoriali Staff

**Le tre prove con le nuove istruzioni sono completate. Il risultato editoriale è parziale: non è ancora raggiunto l'obiettivo di risposte ricche, ambiente vivo e avanzamento costante.** Fati pubblicati e missione precedente sono invariati; nessuna missione rigiocata. Totale prudente dell'intera campagna: **1,41130840 USD su 4**, comprese le riserve.

## Cause e correzioni effettive

Le richieste realmente conservate per Director e Writer sono state lette e confrontate con i sorgenti vivi. Quattro request registrate al Count hanno SHA e byte verificati: sono prove degli input congelati, non una cattura di rete. Il vecchio Native riceveva il Fato precedente anche come ambientazione e lo duplicava nella continuità. Scene5 mescolava cronaca, memoria e nuove azioni; le schede erano talvolta duplicate nella ricevuta di assessment. Le direttive anti-ripetizione esistevano già, con adozione diversa fra i percorsi: la sola aggiunta di un altro divieto non spiegava né risolveva il problema.

E65 separa soltanto la proiezione al provider in contesto stabile, acquisito e nuovi input/decisioni. Il vecchio Fato viene riconosciuto come continuità solo dopo identità+SHA+corpo esatti. I profili ricevono riferimenti alla copia integra soltanto dopo uguaglianza strutturale completa. Payload firmati, autorità, conoscenze, fatti server, custodia e consensi non cambiano. La direttiva generale /7 applicata ai rami Staff pertinenti rende centrale la risposta nuova e l'uso del luogo nell'interazione. Nessun minimo di parole, filtro di stile, rigenerazione automatica o nuovo gate narrativo.

L'analisi e le correzioni coprono anche l'istruzione dell'assessment Director; nei test la sua decisione reale resta congelata. Queste tre comparazioni qualificano il Writer sugli input scelti, non nuove decisioni del Director né il percorso missione completo. Schede e fasi delle prove storiche non sono state riscritte.

## Installazione e difetti tecnici incontrati

La porta di anteprima usa il medesimo runtime e provider canonici in Staff, con esiti privati separati dalla chat e contabilità condivisa. Quattro nuove RPC service-only e tre tabelle private RLS isolano fonti ed esiti; i due soli gesti UI sono avvio idempotente e lettura esplicita, senza polling. Il percorso di pubblicazione normale vieta mission_editorial_preview; nessun esito di prova diventa un Fato della missione.

Le estensioni dei CHECK riguardano esclusivamente producer/event_kind mission_editorial_preview e renderer mission-generic-editorial/1, con vincolo di corrispondenza fra evento e renderer. Nessun rilassamento generico di campi, Auth, turni o meccaniche. ACL/grant espliciti, funzioni service-only e baseline245header/8ABI verificati.

Elenco dei vincoli tecnici: dispatch_receipts_event_kind_check aggiunge solo mission_editorial_preview; dispatch_receipts_renderer_version_check aggiunge solo mission-generic-editorial/1; calls_producer_check aggiunge solo mission_editorial_preview. Il nuovo dispatch_receipts_editorial_pair_check impone l'equivalenza evento/renderer. Nelle tre nuove tabelle private: PK su ID e FK a campagna/profilo/work/receipt/call/authorization/run; request_key e receipt_id unici e coppia campagna/caso/variante unica; caso1–3, variantebaseline|canary; policy/details oggetti JSON e source_refs array di tre elementi; SHA a64esadecimali; conteggioinput non negativo; stati enumerati; stato terminale equivalente a finalized_at presente; coppie raw/hash e result/hash entrambe nulle o presenti. Nessun vincolo aggiunto a schedePG, turni o azioni legali. Il DDL integrale è conservato in C1266_EDITORIAL65_RELEASE_CHAIN.json.

Lo storico conserva due rollback prima del DDL durante la composizione dell'installer: confronto OID stringa/numero e collisione fra variabile PL e alias. Poi il primo baseline1 si è fermato nella nuova factory prima di Count/Generation: il canonicalizzatore intero attraversava prezzi decimali0.1/0.5, pur confrontando due JSON uguali. Il fix riusa il confronto strutturale JSON esistente per quella uguaglianza, lasciando invariati hash/permessi; corretta anche la shape della ricevuta start nel catch. Il failed originale è conservato con zero costo e zero HTTP. Non è una campagna riuscita senza problemi al primo tentativo.

Otto aggregate numerate senza reset: source1 0/1/0, source2 0/0/1, source3–8 0/0/0; installazione iniziale5, sole identità diagnostiche6/fix7 e canary8. Source/materiale8 e chiusura hanno review indipendente0/0/0. Root380c0cc56f9e259a81c27bbd22f4140cbd70ca3a0d892b651edf265e1c59f645, semantic32312abb2c804d474852b7863b2d5e1eab0d54e6d4534f0dbef9f7bf5a3bb244, Edge130/15file esatti; UIcommit3020835c1c07dcf00929716d79db25dbf0a34797, Pages41120023887 SUCCESS, dominio verificato.

## Contabilità, conservazione e limiti

Cinque Count e cinque Generation:10HTTP nuovi. Le generazioni sono liquidate per0,01395200USD; cinque Count restano unknown_billable con0,11000000USD di riserva, correttamente mantenuta. Incremento prudente0,12395200USD; storico160HTTP/1,28735640USD invariato; totale170HTTP/1,41130840USD. Nessun budget azzerato o aumentato, Small invariato e nessun supporto esterno.

43Fati precedenti, work, role, scene, sessioni, dati protetti PG e vecchi ledger/receipt/attempt/authorization/audit identici prima e dopo. Hash source/payload/contratto/request/raw/result validi, stessa fonte per ogni coppia baseline/canary. Cinque ricevute hanno una sola generazione con esito autorevole; zero richieste pendenti o uncertain. La campagna editoriale è chiusa enabled=false; tutte le letture restano disponibili, con stesso testo e ricevuta verificati anche dopo ricarica a campagna chiusa. Il finish amministrativo history_unreconciled della sesta resta fuori scope e invariato.

La finestra è19:02:25–20:32:25UTC, stop nuovi provider20:17UTC; massimi12Count+12Generation/24HTTP,1.44Minput/384koutput e2USD aggiuntivi entro4 totali. Tutti i nuovi provider sono conclusi entro20:05:28UTC. Nessun nuovo tentativo per migliorare un testo. I dieci HTTP implicano al massimo1.2Minput e le cinque generazioni100koutput, sotto i tetti; i token effettivi restano nei ledger.

## Confronto editoriale



| Caso | Baseline contemporanea | Canary | Esito osservato |
|---|---|---|---|
| 1 · Domande | failed / nessun testo | 1027 caratteri, 177 parole | Risposte sostanziose e coerenti; confronto possibile soltanto con F1 storico |
| 2 · Proposta | 470 caratteri, 85 parole | 475 caratteri, 79 parole | Assenso e custodia corretti in entrambi; differenza editoriale piccola |
| 3 · Native/ambiente | 322 caratteri, 58 parole | 431 caratteri, 74 parole | Nessuna copia PG evidente; stessa posizione PNG e proposta ancora pendente |

Cinque testi completati, un avvio fallito. Non sono sei testi riusciti e non è una campagna priva di problemi. La somma esatta dei costi prudenti dei sei DTO finali è **0,1239520 USD**: baseline1 0; baseline2 0,0247303; baseline3 0,0251873; canary1 0,0243694; canary2 0,0250965; canary3 0,0245685. Sono importi prudenti del registro ricevuto, che possono includere riserve: non vanno chiamati spesa definitivamente liquidata né confusi con tutto lo storico entro i 4 USD.

Le metriche lessicali indicano zero cinquegrammi PG condivisi in tutti i cinque testi. Le massime sequenze comuni sono di 2–3 token; questo sostiene l’assenza di copie estese, non certifica ogni possibile eco semantico. Le metriche sono consultative e non hanno attivato retry o blocchi.

## Caso 1 — risposte alle domande, confronto soltanto storico

Il canary affronta la provenienza delle accuse: distingue la fonte personale inventata, le istruzioni ricevute e l’assenza di testimonianza diretta. I PNG si assumono separatamente la responsabilità; il foglio viene mostrato, tenuto e poi ripiegato, senza consegna implicita. Le informazioni sono presenti nelle conoscenze approvate: non compaiono identità del mandante, prove nuove sugli attacchi o decisioni attribuite ai PG.

Il tono passa dall’arringa al confronto diretto e i due interlocutori hanno interventi distinti. Lo spostamento verso una zona meno affollata lega il dialogo allo spazio; non equivale però a una piazza realmente attiva, perché lavoro dei presenti e interessi circostanti restano marginali.

Il vecchio F1 era già ricco di risposte e confessioni: 1362 caratteri, 241 parole, senza lunghe copie PG rilevate. Includeva anche una reazione del capannello. Il canary ricombina correttamente materiale simile e riduce alcuni commenti interpretativi, ma non dimostra un miglioramento netto rispetto a quel testo. Mancando il baseline contemporaneo, attribuire il risultato al solo delta E65 sarebbe improprio.

## Caso 2 — proposta accolta, miglioramento limitato

Entrambi i testi rendono la nuova decisione privata attestata: i due PNG accettano l’accompagnamento e conservano responsabilità distinte. Non ripubblicano la proposta PG e non inventano un consenso mancante. Foglio e quote di monete restano con i rispettivi possessori; futura collaborazione o deposizione non diventa consegna già eseguita.

Il canary accorpa meglio lo scambio e riduce l’assicurazione esplicita di Daichi di non parlare al posto dell’altro. Keita specifica ciò che potrà raccontare. È una variazione utile, ma rimane molto vicina alla baseline: al centro restano il venire con i PG e il raccontare la propria parte. Il motivo dell’autonomia continua a occupare spazio già sfruttato nella cronaca.

L’ambiente viene usato per collocare lo spostamento al margine e liberare il passaggio. È un collegamento allo spazio, non ancora una maggiore profondità del luogo: nessuna attività circostante modifica ritmo, interlocuzione o attenzione. Non emerge una coda ornamentale ripetuta, ma l’obiettivo di un ambiente vivo resta parziale.

## Caso 3 — persiste il problema di avanzamento locale

Il canary non riprende i dialoghi PG del F4 storico; anche la baseline contemporanea aveva già eliminato quel difetto. Non è quindi un beneficio esclusivo del nuovo proiettore. In entrambi tornano autonomia di Keita, disponibilità di Daichi e oggetti mantenuti in vista.

Il nuovo testo finisce dichiarando che la proposta rimane pendente. La formula non mostra una risposta più ricca e sostituisce parte dello scambio con un bilancio narrativo. È il limite più evidente della variante su questo caso: cambia la formulazione, ma non il rapporto o la situazione osservabile.

Va rispettato il confine della prova: la finestra Native congelata contiene intenzioni PNG e report, non la successiva decisione peaceful che autorizzò F5. Un’accettazione o una chiusura inventata sarebbe errata. Il problema non si risolve ordinando al Writer di far avanzare comunque la scena: prima deve esserci una decisione nuova pertinente nel producer; poi il Writer deve darle corpo senza riusare le posizioni note. Queste prove tengono quel producer congelato.

Custodia e limiti di conoscenza restano coerenti. Il luogo invece scompare quasi interamente: oggetti nelle mani non sostituiscono attività, materiali, distanze e persone del contesto. La maggiore lunghezza rispetto alla baseline non produce maggiore profondità.

## Cosa è dimostrato e cosa resta aperto

È osservato: cinque output disponibili; tre canary senza rigenerazioni editoriali; nessuna copia estesa delle role PG nei campioni; risposte coerenti con le conoscenze; nessuna consegna o cessazione inventata; proiezioni utilizzabili nei casi completati.

Non è dimostrato: assenza di problemi del percorso completo, miglioramento causale su tutti i casi, ambiente vivo stabile, dialoghi sempre più ricchi, scomparsa delle autoripetizioni. Il fallimento del baseline1 resta nello storico. Questa prova di redazione privata non certifica una nuova missione completa né sostituisce la qualifica tecnica delle installazioni.

## Correzioni generali da proporre dopo il confronto

1. **Rendere centrale il cambiamento, non aggiungere altri divieti.** La decisione corrente del producer deve distinguersi dalle ammissioni e posizioni ormai acquisite. Una domanda o proposta nuova va valutata per ciò che cambia ora, con alternative coerenti; non va tradotta automaticamente in una nuova assicurazione identitaria. Il Writer non può supplire a una decisione mancante inventandola.
2. **Usare la memoria come stato, non come repertorio di battute.** Custodia, ammissioni, promesse e limiti restano dati acquisiti. Tornano nel parlato quando il nuovo interlocutore o una conseguenza ne cambiano la funzione. Non introdurre blacklist, soglie o rigenerazioni per controllarlo.
3. **Dare continuità alle attività del luogo già autorizzate.** La fonte dovrebbe rendere distinguibili ciò che prosegue, ciò che è terminato e ciò che è cambiato intorno agli interlocutori. Il Writer può intrecciare questo stato con lo scambio; non occorre inventare complicazioni né imporre un paragrafo ambientale. Una semplice lista di arredi o l’ordine di aggiungere ambiente non basta.
4. **Valutare il seguito nel suo contesto.** Nel futuro controllo pertinente misurare risposta, conseguenza osservabile, uso del luogo e continuità su una vera finestra successiva, conservando tutti gli esiti. Questi tre confronti non giustificano altre chiamate per cercare un testo migliore adesso.

Nessuna correzione è stata applicata durante o dopo i tre canary da questo ramo. Esito finale della lettura: **EDITORIAL_PARTIAL_NOT_PASSED**, con progresso sulla ricopiatura PG ma qualità complessiva ancora discontinua.
