# NARRATIVE-MULTIPLICATION-LIFECYCLE-COUNTERCHECK-002

**Controverifica statica finale: PASS · P0/P1/P2 = 0/0/0.** Prima correzione aggregata lifecycle, candidata002; nessun azzeramento e nessuna riapertura del ciclo PNG. Il verde riguarda soltanto la correzione congelata e non attesta compilazione SQL, qualifica dei wrapper002 o funzionamento live.

## Scope e fonti
Owner reviewer QA-PLAYTEST; mandato PM, massimo10min, zero query/SQL/Docker/provider/browser o esecuzioni del prodotto. Spec `/private/tmp/lifecycle-counter002/spec.json`. Letti gli otto prodotti, il precedente001, la sua review e il LIVE_RESULT pertinente. Manifest002 SHA256 `666f345fd973603c44cb9c7197babea2563db017a95237b70a0a4d1906d74c9f`; tutti i sette artefatti elencati corrispondono a byte e SHA. Le quattro impronte assegnate dal PM coincidono.

I 27 predecessori corrispondono alle impronte conservate; anche il manifest001 e i suoi artefatti di prodotto coincidono. I referti storici ancora correnti sono byteidentici ai rispettivi predecessori. Nessun referto001 è riscritto per attribuire una qualifica alla002.

## Difetto osservato e correzione
LIVE_RESULT001 registra18/18pin corrispondenti e un claim ordinary ancora claimed oltre la scadenza, con apply non eseguito. BASELINE.revision002 conserva la lettura tecnica del10/09/2026 alle02:19:02UTC: cinque evidenze NULL, nessun attempt perclaim né perround, lease strettamente scaduta. La review legge questa evidenza congelata senza interrogare produzione o acquisire dati di gioco.

INSTALL.sql e RECOVERY.sql righe6–8 acquisiscono insieme i lock SHARE ROW EXCLUSIVE su narrative_claims e scene_attempts_v2 e solo dopo campionano una volta `clock_timestamp()` nel DO. Il tempo non è inizializzato prima dell’attesa dei lock e non usa il timestamp di inizio transazione. Un campionamento antecedente ai controlli dei pin può soltanto lasciare bloccante una lease che scade durante quei controlli: non ammette un claim ancora valido al campionamento.

Il predicato identico nei due script, righe187–208 e BUILD.py122–145, esclude soltanto claimed con scadenza nonNULL strettamente precedente a checked_at, cinque colonne completion_sha256/completion_result/provider_response_id/provider_request_sha256/raw_output_sha256 NULL e zero attempt correlati tramite **claim_id oppure round_id**. Un attempt di qualsiasi stato resta bloccante per il claim non terminale, incluso generated/provider_reserved scaduto. I terminali restano classificati come nella001. Stato/id/round/scadenza sono NOT NULL nello schema pinzato; il confronto della scadenza ha comunque la guardia esplicita. Nessuna UPDATE, terminalizzazione, rinnovo, nuovo permesso o cancellazione viene aggiunta.

## Semantica nativa e pin
Le sei definizioni raccolte alle02:18:48UTC corrispondono ai propri MD5/SHA256; ownerpostgres e ACL esclusiva postgres/service_role verificati. Per ogni funzione sono presenti due confronti completi definizione/owner/ACL in ciascuno script: preflight e postflight. Nessuna delle sei funzioni è sostituita.

Nella definizione congelata di narrative_claim_v1, righe13–21 acquisiscono i lock prima del confronto di scadenza a riga26; un claim esistente restituisce should_call_provider=false. In narrative_complete_v1, righe17–21 precedono il controllo con clock_timestamp a31: senza completion preesistente il legacy scaduto restituisce not_published. Il ramo idempotente completion preesistente è compatibile col diniego QUIET, che richiede tutti e cinque i campiNULL.

Scene_acquire_v2 righe17–18 rifiuta il legacy senza attempt; permit/save richiedono un attempt nativo e controllano la lease. Scene_complete_v2 righe10–15 ammette la consegna di un risultato giàgenerated dopo la lease, purché il contesto sia corrente. Pertanto l’assenza di attempt, verificata sia perclaim sia perround, è essenziale: la002 non sostituisce questo criterio con la sola scadenza. Nessuna affermazione sull’assenza storica di richieste HTTP viene dedotta dall’assenza di righe.

## Delta, permessi e recovery
Confronto statico esatto: rimuovendo esclusivamente i sei blocchi di pin aggiunti nel pre e nel post, ripristinando il DO senza checked_at e il vecchio QUIET, entrambi gli script tornano byteidentici001. Non ci sono altri delta SQL.

La definizione helperAFTER coincide byte per byte con001, SHA256 `59d25d1a527958bd63e4cb3ebf8ad68665fdc301c13f76edc175d2e4625af9a7`. Anche il corpo BEFORE restituito da RECOVERY, i segmenti funzione+owner/REVOKE/GRANT, BUILD.BLOCK e BUILD.UNUSED coincidono. Le funzioni/tabelle/metadata originali del BASELINE sono intatte. Restano17funzioni/7relazioni pinzate; nessuna tabella, colonna, endpoint, vincolo o grant client nuovo. La helper resta privata: INSTALL378–380, RECOVERY330–332.

RECOVERY210–225 conserva il gate nominativo primauso e il controllo UNUSED della001: dopo una conclusione nuova persistita resta vietata. Nessun claim o snapshot viene riscritto per rendere possibile il ripristino. Catalogo, conclusioni Clone/Moltiplicazione, privacy, autorità, Edge, Flussi, Master e PNG non vengono modificati da questa aggregata.

## QA proporzionata e limiti
QA_PLAN002 congela esclusivamente i cinque gruppi già nominati: legacy scaduto vuoto, claim futuro, attempt scaduto, cinque evidenze valorizzate separatamente, wrapper/recovery/pin. Budget futuro8submission SQL/10min/0provider, banco nuovo distinto. Nessun nuovo caso o estensione proposto da questa controverifica.

Il piano distingue esplicitamente l’esercizio del predicato con tipi nativi dalla prova degli script integrali e vieta stub o trigger eliminati per far passare il banco. Il costruttore deve fissare quelle due coperture prima del run. Il verde della helper4/4 e wrapper0018/8 resta storico: non certifica la guardia002. Nessun nuovo test narrativo o rigenerazione dello smoke006 richiesti.

## Consegna al PM
Finding residui della correzione: **nessuno,0/0/0**. Eseguite soltanto lettura, confronto byte/impronte e ispezione statica delle costanti Python, senza avviare BUILD, runner o SQL. Consegna congelata per la qualifica002 separatamente assegnata e i successivi gate nominativi. Nessun apply/deploy/enable o apertura utenti autorizzato da questo referto; nessuna patch del prodotto eseguita.
