# CLAN-RECOVERY-WINDOW-001 · review indipendente

**Esito complessivo P0/P1/P2: 0/0/1. Codice applicativo esaminato: 0/0/0. Readiness del prerequisito ROSSA per W05 non eseguito oltre la preparazione.** Il solo finding riguarda la fixture già segnalata dall'owner. Nessun esito di questa review qualifica il recupero pubblico o una tecnica Aburame completa.

Reviewer `/root/review_staff94`, 09/09/2026. Sola lettura statica dei sei file elencati in `RECOVERY_WINDOW_REVIEW_SCOPE.json`; nessuna esecuzione SQL, provider, browser o mutazione live. Unico file scritto: questo referto. Nessuna riapertura dei cicli precedenti.

## Integrità

Confermati inizialmente e alla consegna tutti i sei SHA-256 congelati, senza drift. SHA del manifesto: `bcc63a0b2463f86b44e0f2f518a8f281cff06b7cdb2e58c153c35549d9335236`; SHA di `02_RECOVERY_WINDOW.sql`: `93c08770cbae95b5814cc70469f1e9917297955ce38a0cfd4953f1057ffdc285`.

## Finding aggregato

**RW-01 · P2 · La fixture W05 si arresta prima di verificare l'esclusione delle stanze protette.**

Sorgente: `QA_RECOVERY_WINDOW.sql:77`; helper di preparazione alle righe 23–26. Il gruppo crea per primo uno scontro aperto con il PG sintetico, poi tenta di aggiungere lo stesso PG al secondo scontro. La guardia restituisce `personaggio_impegnato`; `pg_temp.window()` e le tre asserzioni successive non vengono raggiunti. Il risultato congelato conferma W05 rosso, non un errore del lettore. Il codice di uscita SQL zero deriva dalla raccolta degli errori per gruppo e non rappresenta otto gruppi verdi.

Nell'unica aggregata prevista va corretto l'ordine/preparazione della medesima fixture W05 conservando le guardie e le sue asserzioni. Nessun bypass dell'impegno, nessun nuovo caso o ampliamento della matrice. La controverifica finale dovrà leggere la ricertificazione degli stessi otto gruppi nei tre submission già previsti.

## Valutazione del codice nel perimetro dichiarato

`02_RECOVERY_WINDOW.sql:8` rifiuta identificativi/estremi mancanti, infinito e finestra invertita; verifica l'esistenza del personaggio. La selezione V2 usa `character_id` e `actor_kind='pg'`, evitando di assimilare PNG e companion controllati dallo stesso utente. Il ramo legacy richiede inoltre il proprietario e il ruolo combattente, coerentemente con la baseline fornita.

Il controllo dell'impegno corrente distingue legacy aperto e V2 attivo/in corso, sospeso o risolto ma non chiuso (`:14`). L'uscita Master attestata consente di non considerare ancora impegnato l'attore rimasto attivo nella riga V2. Le uscite individuali prive di timestamp e lo stato di preparazione vengono segnalati come storia incompleta, con `eligible=false` e `rest_seconds=null` (`:31`, `:74`): non viene inventato un orario di uscita e il chiamante non deve usare `combat_seconds` parziale come se bastasse ad autorizzare recupero.

Gli intervalli chiusi legacy/V2 sono tagliati agli estremi richiesti; per Master si considerano ingresso e uscita attestati. `range_agg` unisce sovrapposizioni prima della somma (`:49–68`), evitando il doppio scomputo. Intervalli vuoti/invertiti dopo il clipping non producono secondi negativi. Le locations marcate `is_test` sono escluse dai tre passaggi — impegno, incompletezza e durata — anche se la prova W05 non ne ha ancora attestato dinamicamente il percorso.

La funzione è STABLE, usa soltanto letture e mantiene `search_path=''`. Schema e funzioni hanno REVOKE espliciti verso PUBLIC/anon/authenticated/service_role e GRANT a postgres. L'assenza di autorizzazione utente interna è coerente con un helper privato non esposto: la futura porta pubblica deve derivare PG e timestamp dal server. Nessuna risorsa, qualifica o flag viene modificato. `01_COLONY_CALCULATION.sql` resta matematica privata; il suo split non è un evento di recupero né un'attestazione di possesso o atomicità.

## Evidenze e limiti

Il referto iniziale registra tre submission, 0,192 secondi, zero provider, sette gruppi PASS su otto e baseline locale invariata. Copre nei limiti della fixture assenza di scontri, legacy chiuso/spettatore, sovrapposizioni legacy/V2, impegno attivo/sospeso, uscita senza timestamp, uscita Master attestata, clipping/input invertito/ACL e controllo PG. Non ho rieseguito questi risultati.

Sono prove del lettore su dati locali sintetici. Non attestano creazione nativa degli scontri, Auth, runtime live, completezza dello storico reale o authority dei timestamp lifecycle; lo stato di preparazione è stato letto staticamente, non risulta esercitato nei gruppi. `currently_busy` esprime l'impegno corrente, non una ricostruzione storica completa dell'occupazione ad un istante arbitrario. Le due RPC della baseline sono solamente fonti lette, non modificate né certificate allo stato attuale della produzione.

Restano correttamente fuori da questo incremento i lock condivisi con ingresso/risoluzione, l'aggiornamento atomico di ledger/risorse/timestamp/ricevuta, lo split pre-cap nel percorso pubblico e il rilascio della tecnica completa. Nessuna raccomandazione di distribuire l'helper isolato.

Finding consegnati insieme: **RW-01 soltanto**. Seguono al massimo l'unica correzione aggregata e l'unica controverifica finale, senza altri esempi o campagne introdotti dal reviewer dopo questa consegna.
