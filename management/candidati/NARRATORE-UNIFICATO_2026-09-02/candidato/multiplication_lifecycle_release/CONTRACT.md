# Conclusioni della Moltiplicazione · candidata 002, prima aggregata

## Problema e autorità
Lo smoke006 ha prodotto una ricevuta nativa di consumo della Copertura al primo attacco; il catalogo della Moltiplicazione era già presente nel payload congelato, ma `conclusioni_effetti_server` era vuoto. Il server deve fornire anche la fine certificata. Il modello continua a scegliere la resa scenica usando i campi `effect/limits` esistenti e le role: nessuna nuova lista di sinonimi, seconda descrizione della tecnica o coreografia obbligatoria.

## Ingresso e perimetro invariati
Si estende soltanto `combat_consumer_private.narrative_tech_sources_v1(uuid) RETURNS jsonb`, STABLE SECURITY DEFINER, owner postgres, search_path vuoto, EXECUTE soltanto postgres. Stessi controlli claim/round/ordinary/azione_risolta, Staff protetta, membri e autorizzazione. Nessuna concessione a utenti o PNG e nessun nuovo endpoint. Il caso006 è realmente `azione_risolta`, con reazione `schivata`: non richiede di allargare l’ammissione a un ipotetico genere `confronto`.

## Fonte terminale certificata
Per ogni `multiplication_resolutions` del round esatto: JOIN formazione, target e dichiarazione d’attacco; round/sessione devono coincidere col claim. Il round deve essere risolto e associato al suo report; attacco e target risolti. La ricevuta deve avere schema `combat-multiplication-resolution/1`, identità di formazione/target, modo, scelta ed esito coerenti con le colonne native e hash SHA256 nativo corrispondente. I fatti completi della ricevuta devono comparire nell’outcome del medesimo target, ignorando soltanto la proprietà aggiuntiva `role` della proiezione nativa.

La formazione deve essere `consumed`, con `ended_at` tra creazione della ricevuta e `round.resolved_at`; il trigger nativo ne rende immutabile lo stato dopo la fine. La causa deve coincidere con quella prodotta da `multiplication_attack_finish`: `assault_resolved` se la formazione appartiene all’attacco Assalto corrente, altrimenti `first_attack` se il suo attore è il bersaglio. Membro della stessa scena obbligatorio. Nessun consumo ricavato da danno, KO, testo del giocatore o sola fotografia corrente senza ricevuta. Ricevuta incoerente o fine mancante nel percorso atteso produce errore22023; non si invia al modello un fatto ipotizzato.

La deduplicazione interna è per formazione, dopo avere verificato ogni ricevuta. Un eventuale secondo target dello stesso evento non duplica la conclusione. Il ramo con originale individuato e quello con copia colpita descrivono entrambi la fine della formazione consumata; il fatto del colpo resta al resolver e non viene modificato.

## Uscita ammessa
Si aggiunge all’array esistente un oggetto con esattamente quattro campi:

- `tecnica`: `Moltiplicazione del corpo`.
- `actor_id`: ID dell’attore già ammesso nella scena, mai ID di personaggio originale, account o figura.
- `stato`: `terminato`.
- `causa`: `primo_attacco_risolto` oppure `assalto_risolto`, mappate dalle sole cause native sopra.

Nessun ID di formazione/target/ricevuta, indice originale, seed, commitment RNG, coordinata, statistica, saldo, versione privata o valore di danno nell’oggetto nuovo. Il catalogo esistente spiega la dissoluzione in una nuvoletta bianca; l’evento certifica quando è terminata. La narrazione non deve presentare i codici delle cause ai giocatori.

Tutte le fonti preesistenti e tutte le conclusioni del Clone rimangono byteidentiche fuori dalle due inserzioni nel corpo. Stesse chiavi `fonti_tecniche` e `conclusioni_effetti_server`; nessuna modifica allo snapshot o al suo formato JSON racchiuso in stringa, né a Edge25, prompt, parser, validator o publisher.

## Confini espliciti
Sono coperte le fini collegate alla ricevuta d’attacco corrente. Le scadenze `owner_next_action`, `owner_inoperative`, `combat_end`, `formation_invalid` e gli eventi senza questa ricevuta non vengono inventati o attribuiti al round per vicinanza temporale. Restano futuri raccordi se osservati o assegnati. Nessuna parità universale Master/missioni/utenti viene dichiarata.

## Guardare l’attività effettiva senza riscrivere lo storico
La002 cambia soltanto QUIET e aggiunge sei pin semantici readonly. L’AFTER narrativo, il blocco terminale e tutte le regole di questo documento precedenti sono byteidentici alla001.

INSTALL e RECOVERY acquisiscono entrambi i lock delle tabelle claim/attempt prima di campionare `checked_at:=clock_timestamp()`. Per un claim ordinary non terminale, si ammette soltanto l’esclusione del legacy già esaurito: `state='claimed'`, scadenza nonNULL strettamente precedente a checked_at, `completion_sha256`, `completion_result`, `provider_response_id`, `provider_request_sha256`, `raw_output_sha256` tuttiNULL, nessuna riga scene_attempts_v2 con il suo claim_id **o** round_id. Il predicato completo è congelato in BUILD.QUIET e uguale nei due wrapper.

Una qualunque evidenza di risultato o un qualunque attempt impedisce questa esclusione, compresi generated e provider_reserved scaduti. La consegna v2 di un risultato già generato può continuare dopo la lease; una semplice condizione `expires_at>ora` sarebbe quindi insufficiente. Gli stati terminali restano trattati come nella001; questo delta non li riapre o riclassifica.

La classificazione non esegue UPDATE/DELETE, non rinnova lease o permessi e non invoca la claim_v1 per terminalizzare la riga. `checked_at` non è il tempo iniziale della transazione: le funzioni legacy verificate usano anch’esse clock_timestamp dopo i lock, perciò un’attesa lunga non autorizza un risultato tardivo. L’assenza di righe non certifica l’assenza storica di HTTP: il gate riguarda la possibilità corrente di proseguire tramite quelle porte native.

Le sei funzioni native claim_v1, complete_v1, scene_acquire_v2, scene_permit_v2, scene_save_v2, scene_complete_v2 sono pinzate per definizione completa/owner/ACL nel pre e nel post di entrambi gli script. Non vengono modificate. La verifica live delle sei definizioni e dei booleani del claim è conservata nel BASELINE.revision002 e quiet_source_functions. Il budget002 comprende due readonly già eseguite e nessuna mutazione.

## INSTALL e recovery
INSTALL sostituisce una sola funzione in transazione, verifica i corpi/owner/ACL congelati, forma/vincoli/trigger delle relazioni raccolte e ripete i pin dopo. Nessuna tabella, colonna, dato o grant client nuovo. Claim e snapshot sono bloccati durante il passaggio; i claim ordinary ancora in corso impediscono l’operazione secondo il criterio conservativo sopra. Le sei dipendenze semantiche aggiunte portano i pin a17funzioni e7relazioni. Lock timeout3s e statement timeout30s, ownerpostgres obbligatorio. Non spegne cron o flag.

RECOVERY è esclusivamente prima della prima conclusione nuova persistita in `scene_attempts_v2`. Richiede corpo AFTER esatto e gate nominativo transitorio `tus.multiplication_lifecycle_recovery=Antonello:NARRATIVE-MULTIPLICATION-LIFECYCLE-CANDIDATE-001:before-use`; il gate non costituisce autorizzazione di produzione. Decodifica shape-safe il JSON stringa e blocca se trova una conclusione Moltiplicazione del nuovo contratto, anche se non pubblicata. Nessun claim ordinary in corso. Ripristina soltanto il vecchio helper e ACL, senza eseguire la helper, cancellare dati o riscrivere claim/snapshot/report. Dopo l’uso non si esegue questa recovery: consegna al PM, correzione in avanti mantenendo lettori e storico. Il caso006 non viene rigenerato né alterato.

## Composizione
Flow006 modifica anch’esso questa helper (aggiunge ramo `flow` e allarga l’ammissione al contesto PNG candidato), oltre al suo hook e resolver. I due INSTALL non sono concatenabili: i pin fermano la sovrascrittura. La futura integrazione deve inserire questo stesso blocco prima del ramo `flow`, conservare le fonti Flussi/Clone/Moltiplicazione e rifare le impronte composte. Questa candidata parte dal live effettivo955228bd... e NON assume PNG04 qualificato.

Master001 usa un percorso narrativo distinto e moduli Edge condivisi; non viene modificato. La futura composizione mantiene i suoi adattatori e il medesimo significato del campo di conclusione, senza attribuirgli oggi ricezione di questo evento ordinary. Nessun rebase implicito né review riaperta su quei pacchetti.
