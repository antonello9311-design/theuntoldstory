# NARRATIVE-MULTIPLICATION-LIFECYCLE-QA002-PREP-001 · banco congelato, non eseguito

TASK-ID NARRATIVE-MULTIPLICATION-LIFECYCLE-QA002-PREP-001 · Owner QA-PLAYTEST. Cinque output nuovi WRAPPER002_SETUP.sql, WRAPPER002_CASES.sql, WRAPPER002_RUNNER.py, questo piano e WRAPPER002_MANIFEST.json. Sola costruzione, zero query/SQL/Docker/provider/browser. Review indipendente della002 in corso durante la preparazione; non è assunta verde. Prima di eseguire ROOT deve leggere il verdetto, acquisire scope del risultato e risorsa esclusiva del cluster, e fornire il referto con la sua impronta. Un hash corretto del referto non equivale al verdetto: --authorized-once è riservato al successivo mandato ROOT.

## Due attestazioni distinte, stessa campagna
La prima parte esercita **il vero predicato QUIET002** su record sintetici dei due tipi compositi PostgreSQL nativi. Il predicato viene estratto dal letterale AST di BUILD.py, dal token EXISTS alla parentesi prima di THEN: nessuna copia manuale della logica. Le uniche sostituzioni sono le sorgenti `combat_consumer_private.narrative_claims`→`qa_claims` e `combat_consumer_private.scene_attempts_v2`→`qa_attempts`. Il generatore verifica unicità delle due occorrenze e reversibilità byteesatta. Il manifest conserva gli hash della fonte, del predicato originale e della versione con le sole sorgenti sostituite.

Le due CTE usano jsonb_populate_record e jsonb_populate_recordset con i tipi nativi delle tabelle esistenti. `checked_at` resta il nome originale, fornito come valore timestamptz dalla riga esterna della query. Le dodici osservazioni sono tutte dichiarate e congelate in CASES.sql; il valore corrente del componente viene letto con clock_timestamp una sola volta. Questo **non** misura lock/concorrenza o chiamate API: il posizionamento dopoLOCK del tempo di prodotto è verifica statica di INSTALL/RECOVERY002. Nessun probe di race viene aggiunto.

I record sintetici non vengono inseriti nelle relazioni native e non affermano conformità di FK/trigger/policy: servono a isolare i due lati dell’OR perclaim/perround senza falsificare una storia nativa. Esiti salvati soltanto nella nuova tabella di banco `qa_lifecycle002.results`. Nessun riempimento di claims pubblici, permesso provider, ruolo di utente o risultato di gioco.

La seconda parte esegue **INSTALL002 e RECOVERY002 integrali e byteidentici** sulle46relazioni native vuote, con17funzioni e7shape esatti, COMMIT reali e connessioni distinte. È qualifica dei wrapper su schema vuoto, non una prova del wrapper integrale con un claim materializzato. Nessun risultato componente è presentato come autenticazione, gameplay, pubblicazione, controllo di concorrenza o prova end-to-end con dati vivi. I quattro gruppi narrativi della001 non sono ripetuti.

## Fonti e setup nativo
Il setup deriva da WRAPPER_SETUP.sql001 già qualificato8/8; la sola modifica al suo prefisso è il nome del nuovoDB nel guard. Prima del COMMIT si aggiungono le sei definizioni di BASELINE.quiet_source_functions, verificate per impronta completa e ripristinate con ownerpostgres e ACL esatta postgres/service_role. I corpi vengono registrati con check_function_bodiesOFF soltanto per le dipendenze non invocate, poi ON viene ripristinato prima dei wrapper. Nessun corpo nativo, CHECK, trigger o pin viene inventato o normalizzato. La tabella di risultato del banco non entra nei46oggetti nativi controllati.

Restano i limiti dichiarati del setup001: trigger/policy delle relazioni di supporto non qualificati, sole sette tabelle target confrontate nel contratto, nessuna execution delle porte native claim/permit/complete. Tutte le46relazioni devono restare con zero righe durante ogni confronto. Le27copie precedenti restano intatte; gli output001 non sono riscritti.

## Matrice finita, cinque gruppi
- **G1:** legacy claimed scaduto, cinque campiNULL, zero attempt: il componente non blocca.
- **G2:** claimed con scadenza presente (uguale a checked_at) oppure futura: entrambe le osservazioni bloccano. Il confronto del prodotto rimane strettamente minore.
- **G3:** lease trascorsa e attempt collegato tramite claim oppure tramite round; ciascuno nei due stati generated/provider_reserved. Quattro osservazioni, tutte bloccanti. Non si deduce inattività dalla sola lease.
- **G4:** ciascuno dei cinque campi di risultato/provenienza valorizzato separatamente, gli altriNULL. Cinque osservazioni, tutte bloccanti; marcatori dichiaratamente sintetici, nessun identificativo provider reale.
- **G5:** wrapper002 completi primauso, pin17funzioni/7relazioni, recoveryCOMMIT e zero dati nativi conservati. Il blocco UNUSED e il gate nominativo sono quelli del prodotto; il precedente controllo dopo-uso non viene ripetuto.

Totale12osservazioni del predicato nei primi4gruppi, più1gruppo wrapper. Tutti i rossi del componente vengono raccolti nella stessa submission con errore/SQLSTATE perosservazione, senza cambiare la matrice. Una discrepanza di dati, schema o ambiente ferma i passaggi dipendenti; nessun retry o microcorrezione.

## Ambiente, risorse e prerequisiti non assunti
Nuovo DB `narrative_multiplication_wrapper_002`, TEMPLATE template0, nel composeQA esistente e pinzato in QA_ENVIRONMENT.json. Non riusare o resettare001; nessun container/ruolo globale/configurazione viene modificato. Il runner verifica fullID, immagine/digest, reteQA, sola porta127.0.0.1:54322, tutti i metadati dei nove mount e stato running, senza leggere Env o contenuti. Docker e socket sono assoluti, come nel runner001.

Preflight futuro: PostgreSQL17.6; ruoli nominali già presenti; supabase_admin locale superuser perCREATE/setup, postgres perwrapper/casi; nuovo nome DB assente. Assenza o drift è STOP, non autorizza creazione/promozione dei ruoli né modifiche al cluster. Durante questa preparazione non è stata eseguita alcuna ispezione o query.

## Budget complessivo e ordine
Massimo8submission SQL totali,10min,0provider/token, senza nuovo contatore nascosto. Le dodici letture del predicato avvengono dentro la singola submission della matrice; non sono12nuove campagne.

1. Preflight locale ruoli/versione/DBassente.
2. CREATE del solo nuovoDB.
3. Setup nativo piùsei sorgenti e archivio risultati di banco, COMMIT.
4. Pin BEFORE e zero righe native, quindi matrice aggregata del predicato.
5. INSTALL002 completo conCOMMIT.
6. Pin AFTER e zero righe native.
7. Gate nominativo nella sola connessione locale e RECOVERY002 completo conCOMMIT.
8. Postflight separato BEFORE/ACL/vincoli/trigger/zero righe native e riepilogo delle12osservazioni.

Un fallimento di un’osservazione del predicato non impedisce i wrapper sicuri sullo schema vuoto; l’esito finale resta NOT_QUALIFIED. Fallimenti setup/pin interrompono i dipendenti. Un erroreINSTALL ammette soltanto il postflight diagnostico già previsto. Timeoutserver/processo limitati al residuo del budget; container condiviso mai fermato. Banco e risultati conservati.

Il runner richiede --authorized-once, --expected-container-id, --review-manifest, --review-sha256 e --output nuovo. Nessun file risultato esistente viene sovrascritto. Le impronte correnti di prodotto, sorgenti e SQLQA sono controllate prima di Docker. Il manifest del banco registra i quattro output senza includere se stesso né creare cicli di hash.

## Consegna
AST verificato; estrazione/reversibilità del predicato e impronte delle sei definizioni verificate offline. Nessuna esecuzione SQL dichiarata. ROOT deve attendere la review002, verificare questo banco e acquisire l’incarico esecutivo prima dell’unica campagna. Verde della001 e hash di un referto non sono un’autorizzazione automatica per002. Nessun apply o test live è compreso nella consegna.
