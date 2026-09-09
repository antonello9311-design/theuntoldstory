# Rilascio del raccordo fra tecniche e narratore

**Stato: preparato, in attesa dei gate nominativi; nessun deploy, apply o enable eseguito.** TASK-ID NARRATIVE-TECH-RELEASE-AUTH-001 (riconciliazione del piano NARRATIVE-TECH-RELEASE-PREP-001) · Owner NARRATIVE-AI · 09/09/2026. Candidata fermata al verde della controverifica **2/5**, esito0/0/0 e campagna locale8/8PASS. Questa preparazione non è una nuova aggregata, campagna o controverifica.

## Pacchetto concreto

Il bundle completo è `narrative_tech_release/`,15file,162085byte, entrypoint `index.ts`; nome funzione `combat_narratore_ai`. Unica sostituzione rispetto alla versione viva23: `editorial.mjs`, copia byte-esatta di `NARRATIVE_TECH_EDITORIAL.mjs` qualificato. Gli altri14file sono identici alla produzione. Import map assente e verify_jwt=false sono quelli della baseline e non si modificano. Le due dipendenze JSR dichiarate rimangono quelle esistenti; nessun aggiornamento di libreria o lettura/modifica di chiavi/configurazioni segrete.

L’inventario e le impronte complete sono in `NARRATIVE_TECH_RELEASE_MANIFEST.json`; digest dell’inventario ordinato file/impronta `d8ee2f5d7a1e9e4fe75034381502bc163eb025e6ecb03f031d3d6ee383d39bd5`. Il manifest conserva anche l’editorial precedente: unito ai14file invariati permette di ricostruire esattamente il bundle23, senza dipendere dalla permanenza delle cartelle temporanee.

SQL e recovery sono **riferimenti alle sorgenti già certificate**, non copie da modificare: `NARRATIVE_TECH_PREFLIGHT.sql`, `NARRATIVE_TECH_INSTALL.sql`, `NARRATIVE_TECH_RECOVERY.sql`. INSTALL SHA256 `8e06605ec037da9806d3044170cbdc31b2aa25efd079208ad33eed41a0cc7496`; RECOVERY `7c93adeb41c88e9b9242b904e47d88529b15a81aa5de6f333a1f9225401f2847`. Review valida: `NARRATIVE_TECH_REVIEW_PASS02.md`, non il referto rosso storico FINAL.

## Preflight effettivo e limiti

get_edge_function e list_edge_functions concordano: ACTIVE, versione23, verify_jwt=false, ezbr_sha256 `a5c46fe0392c233a939536ff9ce5438bec5fff6426cd08ee764f33e5bc6ac7ef`. Confronto15/15file remoto/basePM riuscito; l’overlay editoriale è l’unico delta del pacchetto. La versione assegnata a un eventuale deploy futuro va letta dal servizio, non presunta24.

Due sole query readonly, nessun dato PG: la prima conferma12/12corpi/owner/ACL dei preflight e assenza di `combat_consumer_private.narrative_tech_sources_v1(uuid)`; la seconda alle18:15:24UTC conferma `runtime_config.staff_test_enabled=true` e `staff_test_provider_enabled=true`. Timestamp e riscontri per ogni funzione sono nel manifest. Non sono stati letti roster, credenziali, scene/role, chiavi o stato delle richieste pendenti. Nessun test nuovo eseguito.

Il preflight è una fotografia: prima del gate operativo ripetere soltanto i controlli pertinenti di drift e stato in volo, coordinandosi con l’owner Staff. Non avviare nuovi snapshot durante il cambio di versione. Se un pin è variato o la helper esiste, fermare il solo rilascio e riconciliare; non rimuovere né scavalcare i controlli.

## Portata della modifica e gate effettivi

La parte SQL aggiunge la helper privata `combat_consumer_private.narrative_tech_sources_v1(uuid)` e sostituisce `combat_consumer_private.scene_snapshot_v2(uuid)`. Entrambe ownerpostgres, ACL attesa `{postgres=X/postgres}`, SECURITY DEFINER e search_path vuoto. La helper ha REVOKE esplicito da PUBLIC/anon/authenticated/service_role e GRANT EXECUTE a postgres. Il preflight rifiuta permessi estranei; nessuna API nuova, RLS, trigger, catalogo, dato PG o flag modificati. Il pin eccezionale della dipendenza `public.combat_v2_values_written(uuid)` conserva l’EXECUTE service_role già presente.

Il nuovo hook SQL richiede ordinary=true, genere azione_risolta, attività resolved sul round effettivo, policy `staff_test_no_persistent_resources_v1`, sessione ordinary/luogo coincidente e is_test, values_written=false e `staff_test_allowed` sul roster/controller. La stessa guardia è interna alla helper. Fuori scope lo snapshot conserva la logica precedente. La helper usa staff_test_allowed con provider=false perché legge dati: il dispatch mantiene il controllo provider separato.

**Non c’è un nuovo interruttore di attivazione.** Poiché i due flag Staff sono giàtrue, l’apply SQL autorizzato renderebbe il raccordo effettivo per i nuovi snapshot Staff idonei; non va presentato come installazione inerte. L’apply non genera da solo una chiamata IA. Snapshot già congelati non vengono ricostruiti retroattivamente.

**Il modulo Edge è condiviso.** L’overlay aggiunge l’istruzione sul catalogo e `fonti_tecniche_catalogo` anche alle chiamate sceneOrdinary con snapshotlegacy, dove la lista è vuota e la rappresentazione dei fatti rimane quella precedente. Il confine Staff appartiene alla nuova lettura SQL: non limita da solo la portata del prompt Edge. La compatibilità legacy è verificata localmente nel perimetro dichiarato; assenza di qualsiasi variazione qualitativa su tutte le scene non è attestata.

## Sequenza di rilascio e prova già autorizzata

1. **Gate Edge nominativo.** Confermare inventario/file e baseline23, owner delle risorse e assenza di cambio concorrente. Distribuire i15file del bundle nella stessa funzione con entrypoint/import map/verify_jwt invariati. Ricontrollare metadati e byte dei15file dopo deploy, registrando la versione effettiva. Nessuna chiamata provider richiesta per il solo confronto. Se questa verifica fallisce, non eseguire SQL.
2. **Gate SQL Staff nominativo.** Prima assicurare una finestra coordinata senza nuove acquisizioni e verificare lo stato delle richieste in volo con l’owner autorizzato. Riconfermare pin/ACL/assenzahelper. Eseguire una volta l’INSTALL certificato, con transazione e lock_timeout locale3s già previsti. Non applicare cataloghi o abilitazioni ulteriori.
3. **Postflight readonly del rilascio.** Confermare helper MD5 `955228bdc23c89cdb287198db57231b8`, snapshot MD5 `a417e6a98201a2177cb8c244a736bb3c`, entrambi owner/ACL esatti; metadati Edge immutati dal deploy appena verificato. Registrare l’eventuale identificativo di migrazione reale secondo il gate, senza inventare history o sovrascrivere pin. STOP al drift o a un effetto inatteso.
4. **Smoke distinto, coperto dall’autorizzazione permanente Staff del 06/09 in AGENTS.md.** Dopo rilascio e postflight positivi, eseguire una sola azione pertinente attraverso il sito e le porte native della Staff protetta, poi audit/postflight. Non chiedere nuovamente autorizzazione per testperfunzioni e Riuji. Restano necessari isolamento e precondizioni sicure; i soli gate nominativi ancora mancanti sono deploy Edge e apply SQL. Il suo esito decide il seguito, non riapre una campagna locale verde.

Non distribuire prima SQL e poi Edge: una nuova fonte tecnica nel vecchio prompt potrebbe essere trattata insieme ai fatti. Nessun deploy delle missioni o dell’Esame appartiene al bundle.

## Recupero: ordine e limiti

- **Problema prima dell’apply SQL:** il DB resta invariato. Si può mantenere l’Edge compatibile oppure, con gate di recovery nominato, ricostruire il bundle23 dai14file invariati più `rollback.editorial_before.content` del manifest; verificare tutte le15impronte baseline prima del deploy di recupero.
- **Problema dopo l’apply SQL:** coordinare l’assenza di nuove acquisizioni e lo stato in volo. Applicare prima `NARRATIVE_TECH_RECOVERY.sql` certificato. Esige pin esatti di entrambe le funzioni; ripristina snapshot MD5 `542eb2b95627522ee8e0f28507fdf29b`, lascia la helper privata e verifica owner/ACL. Nessun DROP o DELETE.
- **Dopo recovery SQL conservare l’adattatore Edge compatibile** finché esistono snapshot con nuove fonti potenzialmente riconsumabili. Il rollback non riscrive Fati/snapshot, non annulla chiamate provider in volo e non autorizza rigenerazioni. Tornare alla vecchia Edge solo dopo prova autorizzata che quei payload non raggiungano il vecchio modulo, senza cancellare storico. Se manca tale prova, la parte Edge compatibile resta.
- L’INSTALL originario richiede helper assente: dopo recovery la helper rimane, quindi un riapply necessita un percorso distinto esplicitamente preparato/autorizzato. Non cancellarla per far passare il preflight. I casi di drift fermano il recupero dipendente per riconciliazione.

## Smoke autorizzato e disponibilità

Budget fissato per questa prova, coperta dall’autorizzazione permanente della Staff Test Room (AGENTS.md, 06/09): **1 caso, massimo 1 chiamata provider, 0 retry, massimo 10 minuti e 12000 token complessivi quando misurabili**. Esecuzione subordinata al rilascio autorizzato e al postflight sicuro, nella sola Staff protetta, usando un nuovo uso legale di Clone di Sabbia e un nuovo claim, se il contesto effettivo lo permette. Osservare identità/campi catalogo congelati, role e fatti server separati, prosa della singola mossa e audit. La conclusione visiva si valuta soltanto se il motore registra davvero la cessazione; nessun RNG forzato o ripetizione per cercare la cattura fallita. Se il ramo non si verifica, quel dettaglio resta non osservato.

I limiti runtime esistenti sono49152byte di snapshot in ingresso,65536byte di richiesta,9992token output e5000caratteri di trasporto; non si confondono byte con token né li si modifica per questa prova. La chiamata è reale e ha costo: misurare token/uso effettivi dall’audit e rispettare i limiti del provider/servizio. Nessun costo viene sostenuto da questa preparazione. Applicare il tetto di 12000 token complessivi quando il percorso consente di misurarli; registrare eventuale consumo o limite di misura senza dichiarare un contenimento non verificato. Non modificare la configurazione runtime per questa prova. Al limite di tempo o budget consegnare le sole evidenze raccolte, senza ulteriori chiamate o retry.

Controllare prima/dopo risorse simulate e superfici persistenti protette, nessuna progressione/premio/grado modificata; preservare lo storico e lo stato della scena già mantenuta aperta su mandato, senza reset o riapertura. Casi bloccati da isolamento, sicurezza o precondizioni non si aggirano.

**Staff:** raccordo disponibile soltanto dopo i gate sopra e nel contesto nativo ammesso; smoke ancora non svolto. **Test Room utenti:** estensione rinviata, nuovo hook non disponibile per effetto di questo rilascio Staff e accessibilità corrente non riverificata. **Pubblico/Master/multiattore:** nessuna nuova apertura o qualifica. L’allineamento permanente delle due Test Room rimane un lavoro aperto: questa tranche non dichiara completato l’intero requisito.

Lo smoke verifica il primo aggancio alle fonti e non completa la fedeltà dei testi canonici. Catalogo Clone ancora incompleto rispetto alla ratifica narrativa, modalità Moltiplicazione e lifecycle diversi dalla cattura negativa restano dipendenze separate. La review8/8 non certifica Deno hosted, Auth/RLSviaAPI, concorrenza del lifecycle completo, resa cinematografica o tutte le tecniche. Il rischio hosted residuo riguarda il deploy di un singolo modulo con14dipendenze invariate, da riscontrare nel gate e nello smoke protetto; nessuna replica completa Supabase dedotta dalla prova locale.

## Consegna al PM

Due documenti e15file assegnati, fonte iniziale conservata nel manifest, input certificati invariati. Verifiche di questa preparazione: byte remoto/base15/15; overlay unico e impronta certificata; riferimenti import locali tutti risolti nel bundle;12pinSQL e assenzahelper, lettura dei soli flag Staff; nessuna nuovaQA. Conteggio due aggregate/due controverifiche fermo al verde. Il PM integra riepiloghi e richiede soltanto i gate nominativi di deploy/apply ancora mancanti. Lo smoke Staff è già autorizzato nei limiti qui fissati e resta subordinato al rilascio e alla sicurezza. Questa riconciliazione documentale non modifica la candidata, non aggiunge una aggregata o una controverifica e non esegue il collaudo.
