# Cure Reaction · turno intero coerente nelle offerte e nelle RPC native

`COMBAT-CATALOGO-CURE-REACTION-20261119` · owner `DB-CORE-CURE-REACTION`. Contratto sorgente immutabile: non attesta installazione o collaudo. Fonte soltanto, review indipendente ancora richiesta. Budget60minuti da08:35UTC, tre casi statici, zero provider. Nessun apply/deploy, browser, gameplay, Git, enable, formula o modifica alle schede.

## Baseline e difetto osservato

Root viva acquisita in sola lettura: `79f17709193ac47f564f18cde1114cceefe099cd2c646b6f0b2306b93d28ca0d`, canonical_preimage522857byte, rowSHA `4bd573ced56a7a55757d78281a091c4352b76717a29fb286971b747c008525ac`, dbSHA `89285a340dc116c6f8cdfc25cbfee135c4ee5811f570f5b66f0dd29bc40ee54d`. Custody integrale in AUDIT.baseline_root.canonical_preimage. Main5ecff769 è il riferimento consegnato dal PM; Land blob4525/SHA47ec e tutti gli asset UI sono quelli della Root. Edge Combat45/EZBR79bdb113 e Generic168/9a688980 restano invariati.

QA del PM: dopo Palmo nel round2 della sessione39de6c7b…, la UI conservava Schivata/Parata/Nessuna difesa ma offriva anche Sostituzione5chakra. Non è stata eseguita. Parata accettata, cura attesa16/capcommitted2/real0, chakra105→85; Fato e scena chiusi nativamente08:28:40. Questi sono fatti riferiti dal PM, non nuovi PASS di questa preparazione.

Le SELECT owning confermano il disallineamento: round_options_authoritative popola substitution_offers senza controllare il turno di cura; master_actor_offers la espone dal blocco spaziale dedicato. Il committer passa al selector nativo, che inserisce difesa/reaction=sostituzione. Il trigger attivo cure_turn_defense_guard_v1, BEFORE INSERT su combat_v2_declarations, già rifiuta42501 cure_turn_has_no_technique_reaction. Non è dimostrato un bypass del commit. Non si sostituisce questa guardia con un filtro UI.

## Cinque corpi, stessa autorità

1. `combat_panel_private.round_options_authoritative(uuid,uuid)`: nella raccolta_difese, con cure_turn_used, non proietta abilities tecniche e restituisce substitution_offers vuoto senza chiamare il materializzatore. Il campo reactions conserva esattamente schivata/parata/nessuna.
2. `public.combat_v2_substitution_options_v1(uuid)`: dopo autenticazione, controllo del difensore e lock/fase del round, restituisce lo schema nativo existing available=false/reason substitution_resource_or_reaction_unavailable prima di creare finestre, link o capability.
3. `public.combat_v2_substitution_round_offers_v1(uuid,uuid)`: per il medesimo attore controllato dello stesso round restituisce[] prima del loop, compreso il ramo Sabaku. Un chiamante non controllore conserva il percorso di autorità precedente: il nuovo early-return richiede actor_principal=current_principal e non maschera i controlli owning a valle.
4. `public.combat_v2_substitution_select_v1(uuid,uuid)`: dopo lock/replay e controlli dell'opzione e del controllore, rifiuta42501 con lo stesso errore del trigger prima della INSERT. Replay e idempotenza precedono il nuovo controllo; nessuna receipt/capability viene forzata o cancellata.
5. `clan_innata_private.catalogo_eligibility_release_v1()`: aggiorna il solo shared coinvolto e il corrispondente pin fra le sette porte owning; conserva le altre sei. Aggiunge tre porte native con corpi e ABI/ACL esatti e il digest delle cinque funzioni effettive, compreso il helper letto dal manifest Root esterno. Nessun literal self-hash o Root futura nel corpo.

Il criterio è sempre cure_turn_used sul round/attore e sulla declaration server sigillata palmo-curativo/1. Non dipende da un flag client, dal testo o dal gate successivamente spento. Vale anche per le fonti già congelate dopo CureOFF. Regola turno intero, costo20 e formula già vigente restano immutati; non vengono offerte nuove tecniche o concessi requisiti/corporazione/acquisizioni.

Trigger, cure_turn_used, commit61532836 e Neutral0f48477b restano identici. Rimangono invariati33shared,66private,12relazioni,10trigger, guard250e, Parata/Schivata/Nessuna, consumer meccanici/narrativi, validator, Edge e client. Nessuna firma, default, volatilità, owner, ACL, GRANT, schema, vincolo o policy viene aggiunta o allentata. Tutte le funzioni esistono già; il driver CAS verifica i cinque preimage prima della prima modifica e tutti i postimage.

## Root forward e manifest attivo

Si revisiona in posto cure_command_amendment, con active_repair_kind cure-reaction-turn/1. Restano le provenienze base825a, compat654f, commandE14 e precedenteNeutral0780; parentRoot79 e la precedente identità normalizzata restano nella nuova identità. Catalogo825a e le sue impronte storiche restano byte-identici come provenienza; l'attuale shared34 viene attestato dall'amendment e dalla compat attiva. Il helper verifica quel manifest attivo esplicito.

La vecchia functions array dell'amendment non viene duplicata: il digest copre esattamente i cinque header effettivi, e i tre header nativi completi sono pin-nati nel helper. I due binding config/db_core coincidono. Le quattro alias OID già presenti dei due producer vengono aggiornate con ABI invariata. Le due voci compat helper/guard mantengono header coerenti. Private66 e relazioni/trigger conservano le impronte correnti.

Il footer ricalcola DB/config/code_identity/recovery/Root, conserva UI/Edge e configurazione estranea, effettua CAS della riga Root e party_runtime, porta soltanto le capability missione già qualificate e le due admission. Digest owning delle due righe79: `9fed1c7b430c6418ab1739f5084cd9cf0fc65ca463cf3adfe4afc137d9b43906`. PartyStaff/public true restano tali; CureStaff e ParaStaff true/publicfalse restano invariati. Nuova QA NOT_RUN, staff_pass/publicfalse; nessun PASS è ereditato per le tecniche nuove.

## Recovery conservativa

La recovery è forward e mantiene tutti e cinque i corpi corretti. Richiede operatorepostgres, pin della Root post-apply effettiva, lock condiviso, quiescenza nativa, corpi esatti e chiusura/assestamento delle sole fonti Cure: niente report attesa, claim claimed, scene_attempts non published/failed o dispatch/publish prepared. Non drena, riapre, risolve o modifica snapshot per superare il controllo.

Spegne soltanto CureStaff/public, verifica Para invariata, genera una nuova Root con amendment inert_recovery e disponibilità coerente. Il helper ammette tale stato solo con entrambi i gate CureOFF e continua a verificare gli stessi34+66+3/12/10, lasciando disponibili i percorsi estranei. Le fonti Cure sigillate restano protette. Non reinstalla corpi precedenti, non ripristina la riga Root79, non cancella audit/profili/ledger/receipt/report/sessioni e non cambia Edge45.

## Cap, tre casi e pipeline

Modello offline sulle forme effettive, con review.ref codificata JSON≤256byte: forward massimo521854/margine2434; recovery massimo521976/margine2312; cap524288 invariato. Il footer impone il limite del ref, usa il serializer lineare UTF8, verifica roundtrip e dimensione prima dell'UPDATE. Nessuna Root futura o misura di spazio DB viene inventata.

Tre casi statici: (1) custody79,34header vivi, ABI/corpi, gate/party e helper owning corrente valido; (2) offerte comuni/native, auth/replay, tre reazioni fisiche e guardia commit; (3) cinque patch forward/inverse byte-esatte, SQL e PLpgSQL dell'intera candidata/recovery, manifest e capacità. Nessun body candidato è stato eseguito. Un SELECT metadati aveva n.proname invece di p.proname: non ha restituito dati, è stato corretto una volta senza mutazioni; il risultato errore originale non è stato conservato e42703 è il codice atteso per la colonna errata, non una ricevuta custodita. Il codec capsule non è stato allentato per accettare float della Root.

I cinque artefatti sono SOURCE, RECOVERY, CONTRATTO, AUDIT e MANIFEST. MANIFEST è B e pinza gli altri quattro file; il proprio SHA è consegnato esternamente. AUDIT conserva baseline completa, corpi before/after, patch, metadati, controlli, capacità e script/derivazioni. I generatori Neutral storici restano intatti: si riusano soltanto driver CAS, drain e footer/serializer qualificati, sostituendo esplicitamente baseline e contenuto semantico; nessun corpo07 viene reinstallato.

Ricetta in AUDIT.pipeline: il finalizer locale verifica B/componenti, produce N senza review e il suo SHA in stilePG; il PM ne verifica la controparte native readonly. Solo con il referto R1 reale0/0/0 produce P/F/E, sostituendo i due pin pieni. L'entrypoint aggiunge esclusivamente set_config(P,true) immediatamente dopoBEGIN; l'inversa esatta ricostruisce F. R2 verifica questa equivalenza e i pin. F da solo non imposta i parametri. Le receipt/R1/R2 non sono simulate.

Per la recovery servono expected_current rootSHA/rowSHA/byte/dbSHA e digest delle due admission effettivi post-apply, forniti esternamente; nessun valore futuro è precompilato. Il contratto wholefile è immutabile dopo review; stato operativo e ricevute devono stare nei documenti PM.

## Passaggio al PM

La componente Cure è composta sulla Land baseline4525, invariata. La patch PRESENCE_ENTRY è un consumer distinto: il PM comporrà una sola Root e un solo installer effettivo per UI+reazioni, dopo i rispettivi input recensiti e review della composizione finale. Questo pacchetto non assume l'avvenuto rilascio della nuova UI e non autorizza due apply separati. Le sue condizioni UI/recovery vanno raccordate esplicitamente nel consumer integrato, mantenendo le qualifiche missione già valide e il cap. Nessun collaudo live, installabilità della futura composizione UI, apertura pubblica o prodotto completo è dichiarato da questa fonte.
