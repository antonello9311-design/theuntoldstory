# NARRATIVE-MULTIPLICATION-LIFECYCLE-WRAPPER-PREP-001 · costruito, non eseguito

TASK-ID NARRATIVE-MULTIPLICATION-LIFECYCLE-WRAPPER-PREP-001 · Owner QA-PLAYTEST. Scope: WRAPPER_SETUP.sql, WRAPPER_RUNNER.py, questo piano e WRAPPER_MANIFEST.json. Sola costruzione: zero SQL, query, Docker, browser, provider o nuove fixture. Il risultato componente 4/4 verde resta immutato; non vengono ripetuti G1–G4 della proiezione. INSTALL.sql, RECOVERY.sql, BASELINE e review del prodotto restano byteidentici.

## Contratto e ricostruzione
Si verifica soltanto la percorribilità dei due wrapper completi su PostgreSQL17.6, con COMMIT reali e confronti nativi prima/dopo: undici funzioni e sette relazioni. La proiezione e il diniego della recovery dopo uso sono già stati verificati nel banco componente. Questo banco contiene zero dati nativi e non invoca motore, trigger o guardie storiche di rilascio per fingere gameplay.

Gli otto corpi precedentemente assenti sono recuperati da HYUGA_RUNTIME_METADATA.json e coincidono per SHA-256 e MD5 con BASELINE. Le tre definizioni rimanenti provengono direttamente da BASELINE. Le cinque tabelle meccaniche e le due narrative hanno colonne/tipi/not-null coincidenti con il corpus nativo. DDL, default, chiavi, CHECK, indici e configurazione RLS provengono dal bootstrap congelato e dai relativi metadati, senza normalizzare i pin.

Le FK richiedono una chiusura di 46 relazioni vuote, 689 colonne: non una fixture PG. Vengono riprodotti i 485 vincoli p/u/c/f del sottoinsieme e i 62 indici nativi non già coperti da vincoli. La voce di tipo `t` training_nonlethal_resource_guard sulle characters appartiene ai trigger delle relazioni di supporto e non è dichiarata riprodotta: non si eseguono scritture sulle characters. I 15 trigger delle sette tabelle pinzate sono presenti con definizioni e stato nativi. Sono registrati 25 corpi autentici necessari (oltre le tre funzioni pure del prefisso nativo per le colonne generate). Nessuno stub, modifica di CHECK, history finta, seed o dato di account.

Per registrare i corpi nativi che il wrapper confronta senza invocarli, il setup usa check_function_bodies OFF esclusivamente durante quella registrazione. Le firme reali e i corpi non cambiano; poi torna ON prima dell’INSTALL integrale, che compila la helper modificata. Questa fase non certifica l’esecuzione dei trigger o delle dipendenze di gioco. Il prefisso del bootstrap originale è riusato con il solo guard del nome DB adattato al nuovo banco; non importa la riga di preparazione Hyūga né dati delle sue prove.

Owner e ACL delle funzioni sono ripristinati dalle voci native, e le ACL delle tabelle rispettano ordine, privilegi, grantor e grant option. Le relazioni di supporto sono presenti per la chiusura FK; non ne vengono attestati trigger/policy o parità funzionale. Le sette relazioni controllate vengono confrontate esattamente come INSTALL/RECOVERY richiedono, incluse RLS, force RLS, ACL, vincoli e trigger previsti dal contratto.

## Ambiente e prerequisiti reali ancora da verificare
Nuovo database esclusivo `narrative_multiplication_wrapper_001`, TEMPLATE template0, nel container QA esistente nominato in QA_ENVIRONMENT.json. Il runner confronta integralmente ID/nome/immagine/digest/rete/porta loopback/mount metadata/stato con quel documento congelato. Non assume che qualunque Docker sia equivalente. Nessuna lettura Env o dei contenuti dei mount; nessuna modifica di rete, porte, configurazione, ruoli globali, vecchi DB o banco001 componente.

Ruoli necessari già esistenti: anon, authenticated, dashboard_user, pg_database_owner, postgres, service_role, supabase_admin, supabase_auth_admin. Il preflight deve confermarli e attestare supabase_admin superuser locale. Il setup nativo e il solo CREATE DATABASE vengono eseguiti tramite quel ruolo locale; INSTALL/RECOVERY e confronti come postgres. Nessuna creazione/promozione di ruoli, impersonazione di utenti reali o equivalenza Auth. La disponibilità attuale dei ruoli non è stata interrogata durante la costruzione: se assenti o non idonei il preflight si ferma, senza adattamenti durante il run.

Il nome del DB deve risultare assente prima della creazione e coincidere durante il setup; il database deve essere vuoto. Un DB già esistente, un drift di ambiente, una dipendenza mancante o un deparser diverso è un esito concreto da consegnare; niente reset, normalizzazione dei pin o tentativi per ottenere verde.

## Unica campagna futura · massimo otto SQL, dieci minuti, zero provider
ROOT acquisisce prima scope di esecuzione, risultato e risorsa esclusiva del cluster compose. Questo incarico non avvia la campagna.

1. Preflight versione17.6, ruoli locali già presenti, nome nuovo DB assente.
2. CREATE del solo database nuovo, senza mutare cluster/configurazioni.
3. Setup nativo vuoto con COMMIT, tramite supabase_admin locale.
4. Confronto esatto BEFORE: undici funzioni e sette tabelle, più controllo zero righe nelle 46 relazioni.
5. INSTALL.sql completo byteidentico, con COMMIT.
6. Confronto esatto AFTER e permanenza zero righe.
7. Gate nominativo di recovery impostato soltanto nella connessione locale, seguito da RECOVERY.sql completo byteidentico e COMMIT. Nessun dato aggiunto e nessun percorso dopo-uso da forzare.
8. Postflight su connessione distinta: BEFORE/ACL/vincoli/trigger ripristinati e zero righe conservate.

I confronti usano il medesimo generatore e valori del prodotto, con search_path pubblico `public,extensions`: pg_get_functiondef, pg_get_constraintdef e pg_get_triggerdef restano nativi. Nessuna rimozione di prefissi o comparazione permissiva. Il full INSTALL imposta già questo contesto transazionale; la recovery conserva il suo contesto originale.

Timeout server statement/transaction PG17 e processo sono limitati al residuo dei dieci minuti. Nessuna chiamata retry. Se setup/prepin fallisce, i wrapper dipendenti restano NOT_RUN. Dopo un errore INSTALL si raccoglie il postflight BEFORE ove il setup è integro; una discrepanza AFTER blocca la recovery invece di ripristinare a occhi chiusi. Lo stato effettivo e il banco vengono conservati. Il container condiviso non viene fermato o cancellato.

Il runner richiede `--authorized-once`, l’ID completo assegnato e un output nuovo nel perimetro acquisito da ROOT. Non sovrascrive referti e non esegue nulla all’importazione. Esito WRAPPER_PASS solo se tutte le otto submission e i confronti sono verdi; nessuna equivalenza con gameplay, servizi Auth/API/RLS via client, provider, narrazione live o apertura agli utenti.

## Consegna e limiti
Verificati offline SHA/MD5 degli otto corpi recuperati, coincidenza delle colonne delle sette tabelle e sintassi AST del runner. Nessuna compilazione PostgreSQL o qualifica wrapper ancora dichiarata. Il manifest registra fonti, trasformazioni di solo banco, perimetro e impronte dei tre materiali; non include il proprio hash e non crea autoreferenze.

Passaggio al PM: review del banco congelato e assegnazione della singola esecuzione. Dopo eventuale verde wrapper, resta distinto il gate nominativo di rilascio e il successivo riscontro protetto. Nessuna ripetizione del caso006 o dei quattro gruppi componente autorizzata da questa consegna.
