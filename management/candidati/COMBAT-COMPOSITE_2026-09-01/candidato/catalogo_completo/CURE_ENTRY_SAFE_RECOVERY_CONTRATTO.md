# CureEntry Safe Recovery · fonte separata, mai eseguita

Task `COMBAT-CATALOGO-CURE-SAFE-RECOVERY-20261119`, owner `DB-CORE-CURE-SAFE-RECOVERY`. Mandato PM recovery-only,30min dal claim09:48:44UTC/deadline10:18:44,3casi statici,0provider. Contratto immutabile di sorgente, non attestazione di stato operativo. Nessun DBapply, recovery, gameplay, browser, Git o documento PM modificato.

## Baseline applicata e limite osservato

Il pacchetto attivo resta `c92d6b79e108e73d6194085bacf0bc6cddb4af74b1661e019ee5516ebc6ba0ce`. Migrazione20261119092722, Root21c3e8e6f9aae4b2dbe9e5169a9f6e2c3bced79e32d251c1ff6eaecf2b2a3c66,521923byte, row265efaa5944f652eb1ffa2a7a57472158ff1ec8d97271fa33ef5787c5c16ba01, DBbdac83c40ac174e23ba95ba7aa8d28151ca142848fd5e842ce5c9719c913e1b8. Land38f37e85d07bd0b12c10b0c2819dcfbd202c08b0097a0a61897be9ee1b82c570/build2, UIclientcd76714cb188ea3f69189ac5dd793304acdc2179da724aad852f961d12ab3014, EdgeCombat45 e Generic168 sono preservati. Digest delle due admission21:1a29ce255778f788e967f9ea5360da5c36440777fdd78d254f84f92c6ac33e81.

CURE_ENTRY_INSTALL e tutti gli originali CURE_ENTRY_* restano immutabili. La receipt applicata attesta l'installazione e la readiness osservata dal PM; questa fonte non la riscrive. Nessuna recovery è stata eseguita. Il limite è la declarationc707d5f3… rimasta inviata sotto Combat1c35b28d…/Master52b19e48… annullati e chiusi18nov21:58:20UTC. La chiusura nativa conserva i figli storici: non converte automaticamente ogni declaration in annullata. Il vecchio test di settlement considera invece ogni figlio non terminale come lavoro ancora attivo.

## Unico hunk conservativo

La SQL nuova copia l'intera recovery originale e cambia soltanto il test sulle declaration non terminali. La proposta27fd è raffinata nel medesimo hunk con le invarianti durevoli della preparazione. Nessun campo state esiste su cure_preparations_v1: il collegamento consumato/bound è declaration_id, vincolato univocamente e scritto da cure_bind_v1. Non si inventa x.state.

L'eccezione richiede congiuntamente declaration inviata/utilita/outcomeNULL, ability_source clan e ability_idPalmo; request/round/attore/bersaglio/controllore/versione identici fra prep e declaration; fonte server identica e hash valido; source clan/idPalmo/cure_contract palmo-curativo/1, costo congelato20 e scope noto simulation/persistent; attore e bersaglio appartenenti allo stesso parent; parent annullato con closed_at. Master soltanto human/duello/missionNULL/annullata+closed; ordinary soltanto activityclosed. Ogni activity diversa da closed blocca. Nessun ledger della declaration e nessun report del suo round possono esistere.

Il predicato usa NOT coalesce(proof,false): soltanto una prova interamente TRUE concede l'eccezione. False e NULL mantengono bloccante il figlio non terminale. Non confronta txid_current né il controllore/attore attualmente attivo e non richiama execution_scope/source_valid che richiedono una scena aperta: sono prove di esecuzione diverse dal binding storico.

Il solo positivo reale è c707: tutti i binding e gli hash sono stati letti come booleani veri; outcomeNULL, nessun ledger/report/claim (anche storico), nessun pending dispatch/publish/scene. Combat e Master sono annullati+closed; MasterhumanDuello senza missione. Il suo round conserva raccolta_difese, senza essere più operativo. Nessun valore di risorsa PG è stato letto per correggerlo.

Restano byte-identici tutti gli altri controlli: operatore, parametri/review, Root/hash/CAS/lock, quiescenza, chiusura parent delle fonti Cure, reportattesa, claimclaimed, scene nonterminali, dispatch/publish prepared, funzioni/helper, gate e footer. Le declaration terminali mantengono il comportamento precedente. Una prep non bound non usa la nuova eccezione; il suo precedente trattamento nei join e nei guard di sessione non viene esteso o ricertificato.

## Autorità nativa e recovery forward

Le fonti owning custodite dimostrano che assert_operational respinge annullato/annullata anche allow_resolved=true. Round_resolve lo chiama prima di evento/costi. La claim narrativa richiede activityresolved e reportattesa; scene_complete verifica claim/current/resultgenerated prima di pubblicare e porta publishprepared→consumed, claimcompleted e scenepublished nella stessa transazione. Narrative_store richiama assert_operational(true). Non si invocano queste porte per testare il rifiuto.

La recovery mantiene tutti i corpi corretti e la UI attuale. Richiede il postflight21 esatto, assestamento nativo e review pertinente; spegne soltanto CureStaff/public, conserva Para invariata e genera una nuova Root inert_recovery. Il helper già installato ammette inert solo con entrambi i gate CureOFF e continua a verificare gli stessi manifest/corpi. Profili, receipt, ledger, eventi, report, scene, snapshot e storico non sono cancellati o modificati per passare i guard.

Il nuovo B Safe è soltanto la provenienza della recovery. N/P lo passano in source_bundle_sha256; il footer lo registra esclusivamente come recovery_source_bundle_sha256. Il source_bundle_sha256 attivo dell'amendment e il binding compat continuano a puntare all'originalec92d. Nessun nuovo runtime, sourceB attivo, helper, sigillo, formula, permesso, vincolo o dato di gioco viene creato o modificato da questa preparazione.

## Capacità e tre casi

Modello offline sul raw21 esatto: futura Root recovery522045byte, margine2243 sul cap524288. I soli hash nuovi sono a larghezza fissa; hunk e corpi non vengono copiati nella Root. UI, grafi e manifest delle funzioni restano quelli applicati. Il serializer lineare, roundtrip e controllo524288 prima dell'UPDATE sono invariati. Nessuna SHA Root futura o spazio libero DB è inventato.

I tre casi statici sono: (1) custodia B/install/Root21 e positivo c707, binding/colonne reali; (2) unico hunk, SQL+PLpgSQL, inversa byte-esatta e porte owning; (3) obblighi negativi false/NULL e capacità. Per ogni figlio non terminale già joined, stato/tipo/fonte/binding errati, parent attivo o incompleto, ledger/report e code pendenti restano bloccanti. Sono prove di sorgente e letture bounded, senza fixture, DBlocale, fault injection o esecuzione della candidata. Readiness di un predicato osservato non equivale a esecuzione della recovery.

## Cinque artefatti e finalizzazione

SQL, CONTRATTO, AUDIT, PARAMS.template e MANIFEST sono standalone. MANIFEST è B e pinza gli altri quattro file; il suo hash è consegnato esternamente. AUDIT conserva rawRoot21, pin originali, hunk/diff, fonti owning, booleani durabili, controlli, modello byte e script. Gli originali e i generatori storici non cambiano.

PARAMS.template usa lo schema runtime originale cure-entry-recovery-parameters/1 e app.cure_entry_parameters, con reviewnull e un segnaposto B: non c'è ciclo B→N→B. Il finalizer TEMP verifica tutti i componenti, sostituisce soltanto B e rimuove review per costruire N. Il riferimento e l'hash del contratto sono già fissati nel template. N contiene gli input postflight reali21/row/bytes/DB/dueadmissioni. Il PM può confrontarne il solo hash tramite SELECT readonly.

Solo un R1 reale0/0/0 consente al finalizer di produrre P/F/E. F sostituisce soltanto i due pin completi della SQL. L'entrypoint aggiunge esclusivamente set_config(P,true) dopoBEGIN; la sua rimozione ricostruisce F. R2 verifica equivalenza e pin. Nessun P, referto, futuro postflight o PASS viene simulato. La recipe è in AUDIT e i file eseguibili restano soltanto TEMP; nessuno di essi esegue SQL o usa rete.

Se gli input applicati o i file originali cambiano, STOP: non rigenerare semplicemente i pin. Un eventuale uso richiede review e mandato operativo distinti; questo task consegna una fonte pronta da recensire, con recovery_executed=false.
