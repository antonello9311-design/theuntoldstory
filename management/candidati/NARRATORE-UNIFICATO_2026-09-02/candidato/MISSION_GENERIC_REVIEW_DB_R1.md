# MISSION-GENERIC-REVIEW-DB-R1 · review indipendente iniziale

Esito: ROSSO · P0/P1/P2 = **0/2/2**. Referto unico per la composizione REV1; nessuna correzione eseguita. Questa è la parte DB/PLAN_WRITER/BOARD/OUTCOME della review aggregata del PM, non una review dei moduli COMBAT/PROGRESS scritti dallo stesso reviewer.

## Baseline congelata

| Candidato | SHA-256 | Byte | Statement analizzati |
|---|---|---:|---:|
| MISSION_GENERIC_DB.sql | 6db7db050ec5ba793a45e01f7934e121754951de635ee2f12a901e43fda90d06 | 37980 | 42 |
| MISSION_GENERIC_PLAN_WRITER.sql | 4a4fd396b22322d4f3febfa266178177f09baaa0c9045ad566c18e209f30a980 | 18683 | 26 |
| MISSION_GENERIC_BOARD.sql | f247b359b30c2f54334e70a8cb5e6813c6fe3af6577fed73c89344bc77b4b49b | 34028 | 41 |
| MISSION_GENERIC_OUTCOME.sql | 9499078940ba0e779c50a2f3d07c57139e727d9e1a909b567c0622a7a49884db | 16100 | 11 |

Percorso comune: `management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/`. Lavoro registrato `MISSION-GENERIC-REVIEW-DB-R1`, owner `QA-GENERIC-DB`; budget massimo 30 minuti, zero chiamate provider e zero gameplay.

## Finding

### DB-R1-01 · P1 · Il roster di prova non viene validato contro il perimetro Staff prima dell'avvio

**Evidenza:** `MISSION_GENERIC_BOARD.sql:333` autentica lo staff ma accetta `p_roster`; `:366` passa quell'array a prepare_start. In `:192-221` prepare_start controlla forma, dimensione, esistenza, archiviazione e impegni dei PG; i requisiti ordinari sono saltati quando simulation=true. Manca il controllo dei principal del roster con la policy Staff nativa prima di inserire partecipanti, reservation e work di incipit (`:239-272`). La prova transazionale di start riguarda l'utente staff che esegue la chiamata, non l'intero array dei PG.

**Conseguenza:** un utente staff incluso nella policy può indicare un PG reale libero che non appartiene ai due principal autorizzati alla Staff Test Room. Board crea comunque una partecipazione e una prenotazione attiva per quel PG, e accoda un incipit basato su quel roster. La successiva verifica Combat può fermare lo scontro, ma arriva dopo l'apertura della prova e non copre una missione solo narrativa. Il trigger nativo su master_v2_participants verifica gli impegni meccanici, non l'ammissione Staff.

**Fonte viva:** `combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean)`, MD5 `80434afefcecbc48e190999830389cee`, richiede luogo Staff configurato, principal inclusi nella lista ammessa, cardinalità 1..2 e assenza di esami aperti. Il controllo deve riguardare gli user_id effettivi dei PG del roster sotto i lock già acquisiti, con risultato strettamente true; non basta il flag is_test né il solo caller.

**Correzione richiesta all'owner:** applicare la policy nativa al roster completo nella transazione di prepare_start, prima delle mutazioni di sessione/roster e dell'ammissione provider. Lasciare il percorso ordinario e i suoi limiti separati. Verifica pertinente: roster Staff ammesso passa, roster fuori policy viene respinto senza start/reservation/work.

### DB-R1-02 · P1 · Il ciclo booking Generic impedisce la finalizzazione ordinaria della missione

**Evidenza:** `MISSION_GENERIC_BOARD.sql:103` impone activation.state=enrollment_open prima del ramo di uscita dal booking a `:104`. Il nuovo hook `:123` applica questo controllo a ogni UPDATE di status di una missione Generic. Dopo l'incipit l'activation diventa started (`:322`). La funzione premi nativa aggiorna i booking da iscritto a completata/fallita: questo UPDATE termina con MGB_BOOKING_STATE e fa rollback della chiusura.

**Seconda guardia dello stesso ciclo da correggere nell'aggregata:** il trigger AFTER `mission_ai_board_owner.booking_sync()` cambia in withdrawn l'applicant quando il booking esce da iscritto, ma non azzera ordinal. Board aveva valorizzato ordinal e decision=started (`:246-248`). Il CHECK vivo degli applicants impone `(decision='started') = (ordinal IS NOT NULL)`: spostare soltanto il RETURN prima della guardia di stato non risolve la chiusura, perché il trigger AFTER fallisce a sua volta. La sincronizzazione di un completamento autorizzato non può essere trattata come un ritiro dalla candidatura.

**Fonti vive:** `booking_guard()` MD5 `bc2c23eaa64e0a69bc4cc5c568368364`; `booking_sync()` MD5 `451704552b059dd8bfbcb8585a0e59a5`; `public.missione_esito(uuid,boolean,text)` MD5 `e7e016791a9b24a3962ca6d7e697b699`. Entrambi i trigger sono attivi su mission_bookings. Le colonne/constraint citate sono state lette dal database, senza aggiornarle.

**Correzione richiesta all'owner:** raccordare BEFORE e AFTER al completamento Generic nativo verificato (run/activation/capability/terminale), mantenendo la protezione contro ritiro o nuove iscrizioni durante la missione e preservando il roster storico. Nessun allentamento globale dello stato enrollment_open. Verifica pertinente: conclusione successo e fallimento ordinari attraversano booking e audit una sola volta; simulazione continua a non assegnare premi né completare booking reali.

### DB-R1-03 · P2 · La normale variazione di stato rende inutilizzabile una missione conclusa come sorgente del collaudo

**Evidenza:** `MISSION_GENERIC_PLAN_WRITER.sql:43-44` include status nel fingerprint editoriale. La revisione ordinaria viene sigillata con status=aperta; `MISSION_GENERIC_BOARD.sql:320` lo cambia normalmente in programmata e la chiusura nativa lo porta a completata/fallita. La porta di prova `BOARD.sql:346` richiama selected_plan, che a `PLAN_WRITER.sql:215-218` pretende ancora lo stesso fingerprint completo.

**Conseguenza:** una missione Generic eseguita regolarmente non può essere subito scelta come sorgente storica della prova: MGP_SELECTED_PLAN_DRIFT scatta per la sola progressione di stato, anche se piano, definizione, roster limite e contenuti sono invariati. Per superarlo occorrerebbe una nuova sigillatura editoriale della sorgente conclusa, passaggio estraneo al semplice riuso storico richiesto.

**Correzione richiesta all'owner:** dare alla porta di simulazione una lettura della revisione storica immutabile che distingua avanzamento operativo da drift editoriale, continuando a verificare hash e riferimenti dei contenuti. Non riscrivere revisioni, risultati o status della missione sorgente e non eliminare il controllo rigoroso usato per un nuovo avvio ordinario.

### DB-R1-04 · P2 · Il validator può sigillare incontri che il raccordo non è in grado di aprire

**Evidenza:** `MISSION_GENERIC_OUTCOME.sql:60-75` controlla shape, duplicati e corrispondenza degli attori, ma non richiede almeno un PNG combattente, uno schieramento opposto a pg_team o un unico punto di apertura per lo step. Un actors=[] oppure una lista composta solo da PNG nello stesso team dei PG supera il validator. Più encounters diversi nello stesso step superano a loro volta la sigillatura, benché il contratto finale concordato preveda incontri in fasi/visite distinte e rifiuti un'apertura ambigua.

**Conseguenza:** l'editor riceve una revisione approvata e avviabile, l'incipit può essere pubblicato, poi il primo tick meccanico si ferma con la guardia nativa di cardinalità/opposizione oppure con l'errore di punti di apertura ambigui. Non si richiede di allargare il Combat a nuovi casi: il server deve respingere alla sigillatura le configurazioni fuori dal contratto implementato.

**Correzione richiesta all'owner:** allineare il validator alle capacità dichiarate del raccordo: nessun incontro fittizio per la sola narrazione, cardinalità nativa del roster Combat e almeno un team avverso, un punto di apertura per fase finché non viene introdotto un ordine/trigger esplicito. Mantenere 0 PNG nelle fasi puramente narrative.

## Copertura e risultati positivi

- Autorità: porte editoriali/test protette da staff_only nativa; start/choose richiedono uid e proprietà effettiva del PG. Replay Board controlla anche actor_id; la scelta PG controlla membership corrente o ricevuta dello stesso attore per replay. Nessuna evidence numerica o destinazione libera viene accettata dal client.
- Controller: apply_authority riusa mission_internal.transition, CAS di master/run, vincolo su pending outbox, capability server disabilitata inizialmente e ricevute immutabili. Differenza fra source_kind e fact_code verificata sul piano. I due gate restano da attivare separatamente nella release.
- Pin: approvazioni dei template/versioni NB verificate; attach acquisisce lock prima di validare e congelare versioni/hash. Run bindings e revisioni sono immutabili. OUTCOME conserva i corpi originali salvo il delta previsto: i tre pin prosrc del delta corrispondono esattamente ai file congelati.
- Schema: campi di piano, requisiti, capabilities, missioni, eventi, applicants e activation confrontati con colonne/constraint vivi. Registration `mission.generic.trigger.v1` usa valori ammessi. XOR package/generic preserva il percorso legacy. Nessun inserimento posizionale nativo in activations trovato che venga rotto dalla nuova colonna.
- Concorrenza: start serializza la singola missione/activation e il luogo, poi i PG per UUID; run, outbox e ricevute sono identificati per sessione. Sessioni con missioni, stanze e roster distinti non condividono un mutex di gameplay. La sigillatura editoriale conserva il lock globale delle versioni, già richiesto dal trigger nativo delle righe figlie: può serializzare due sigillature, ma non costituisce un limite a 2–3 missioni già avviate. Nessuna prova empirica concorrente è stata svolta.
- Quote: prenotazione prima dell'incipit e consumo soltanto dopo pubblicazione; la simulazione non inserisce weekly_quota. Le nuove activation sono distinte per il carrier; nessuna riscrittura della missione sorgente o di sessioni pregresse nel percorso letto, salvo i difetti di ammissione segnalati sopra.
- Permessi: RLS attiva senza accesso diretto alle nuove tabelle private, schema privato revocato, GRANT espliciti per RPC; gate runtime iniziale off e capability evidence iniziale disabled. Le mutate candidate condivise sono nominate e pinned.
- Statica: pglast ha analizzato 120 statement top-level complessivi; PASS. È controllo di sintassi SQL, non compilazione delle query PL/pgSQL contro gli schemi installati. I percorsi nativi citati sono stati letti dal progetto vivo in sola lettura.

## Limiti e passaggio PM

Nessun database apply, provider, browser, test locale ricreato o gameplay. Nessuna patch del prodotto. Non sono state lette né copiate credenziali, PII o role integrali. COMBAT/PROGRESS sono stati consultati solo per le firme e le condizioni d'ingresso, senza certificare il proprio lavoro come review indipendente.

Il PM deve aggregare questi quattro finding con gli altri referti REV1, decidere un'unica correzione congelata e far eseguire la controverifica prevista. Il rilascio dipendente resta rosso; questa conclusione non estende né riavvia il budget di revisioni.
