# E68 — Director dialogico e Writer per nuove domande Staff

Stato: candidata completa, NON installata e NON ancora reviewata. Zero provider, browser, gameplay o SQL mutante eseguiti dal ramo. Aggregata 11, storia precedente conservata. Scope: tre casi editoriali dichiarati da V8/V7, senza role accettate fittizie o modifiche ai Fati.

## Baseline e composizione

Baseline acquisita dal PM: Root c0b1efe3, Edge132, sedici file; runtime SHA a7fd266b1c3228212b817fbfae5fbf0aaa74ea0ffdfe669b1ba0d5337be9c32a. Cambiano soltanto mission-generic-runtime.mjs e mission-staff-editorial-pair.mjs. Gli altri quattordici sorgenti Edge, compresi HTTP/getUser, provider adapter ed executor finanziario, restano byteidentici.

Package integrale SHA 94f9bfe11ab750093d9a9a04f6f827b7273a4cc981d8e4fe6a7eb4d5381f85b5; runtime candidato a7b1e6b771683f4e74f02b3870ee551858e0b5faa337beb0c0b5e9c67675a9eb. Il builder richiede baseline132 e tre baseline UI con SHA verificati, produce i sedici file, tre copie UI, manifest, diff e controlli sintattici. Un secondo build produce package e tre asset UI identici.

## Core condiviso, senza work contraffatto

Le nuove factory sono createStaffDialogueEditorialDirector e createStaffDialogueEditorialWriter. Nessuna costruisce un work, claim, admission, lease o provider contract di gameplay. Sono costruttori e normalizer puri delle richieste: l’autorità finanziaria rimane nel ledger privato e nei callback esistenti.

L’estrazione dal Director reale comprende:

| Funzione condivisa | Riuso |
|---|---|
| providerJsonRequestFromLimits | Stesso assemblaggio modello/reasoning/store/schema/limiti, senza inventare un oggetto work |
| directorInstructionsFromView | Stesse istruzioni ordinarie; variante editoriale esplicita dominio delle domande |
| directorProposalSchemaFromView | Stesso schema Director/1–2; nella preview opportunità nulla e capacità ristrette |
| checkedDirectorSources | Stesse verifiche forma, riferimenti ed evidenze letterali |
| checkedDirectorSelection | Stesse verifiche di opportunità, azione e lato |
| checkedDirectorIntents | Stesse verifiche per attori e capacità; solo speak/gesture nel caso privato |
| narrativeActorPersonaView | Adapter LifeCore16→10 già presente, ora puro e riusato |
| checkedNarrativeSceneSnapshot | Validazione pura dello snapshot a sei campi estratta da Scene5 |

Il Director ordinario continua a passare le proprie autorità, opportunità, feature e fonti di gioco ai medesimi controlli. Le opzioni di default mantengono schema e significato precedenti. La preview passa invece un view-authority di dominio editorial_question, derivato dalla fonte Staff registrata, con attori presenti nella fase e due sole capacità. Non si usa il Director temporale/4 e non si trasforma l’assessore Native cease/accept in planner.

L’adapter LifeCore conserva le verifiche della rappresentazione originaria; la corrispondenza degli oggetti persona/core usa retainedJsonEqual, preservando chiavi e valori anche con decimali. Non usa il canonical integer-only per hash di profili o prezzi. Le schede V7 integrali arrivano dal DB, non da profili legacy inventati; PROFILE_AUDIT e checkedAudit restano quelli correnti.

## Nuove fonti ed evidenze

La fonte Director ha esattamente i quattordici campi del contratto staff-editorial-dialogue-source/1. Snapshot authoring a cinque campi e scene a sei campi sono distinti da cache e firme di gameplay; la memoria conserva origin/premises/value. Actor refs, versioni, fase, domande, destinatari e speaker sono verificati per coerenza. SHA dei corpi domande e Fati è SHA256 dei byte UTF8 effettivi, senza normalizzazione. Il riferimento storico serve soltanto alla provenienza.

Nel protocollo Director/2 i campi legacy source_role_ids e source_evidence.role_id appartengono qui ESCLUSIVAMENTE al dominio editorial_question e possono indicare soltanto i question_id del caso. Non attestano messaggi, role, azioni o consensi di gioco. Il prompt lo dichiara esplicitamente. Le citazioni sono controllate sulle domande attribuite, senza trasferire la loro autorità al piano pubblico.

Wire Director: schema Director/2 con i nove campi del piano più profile_audit. opportunity_id=null, action_kind=context, entry_side=null; npc_intents usa gli stessi quattro campi actor_key/intent/entry_kind/speech_intent e le sole capacità speak/gesture. Nessuna simmetria obbligatoria, quota di battute o filtro editoriale.

Normalized Director, elenco esatto: ok, origin='editorial_question', decision, profile_audit, text=null, command=null, failure_codes, advisories. decision è il piano a nove campi senza profile_audit. Il parent_result_sha256 lega l’intero wrapper; **chain.decision è esattamente parent.result.decision**. Non è il wrapper completo né un risultato storico.

## Writer Scene5, stessa redazione e nuova autorità

Il Writer riusa narrativeSceneRequestFromView, projectSceneEditorialInput e checkedNarrativeSceneOutput. mission-editorial-response/8 e mission-editorial-input-reading/2 sono byteidentiche alla baseline. Marker specifico di composizione: staff-editorial-dialogue-writer/1; marker Director: staff-editorial-dialogue-director/1.

La fonte Writer ha tre campi schema_version/source/chain_receipt; la chain ha esattamente le dieci chiavi concordate. Parent run, ricevuta e SHA request/raw/result sono quelli della coppia appena completata, vincolati nel DB prima della preparazione del child. I relativi hash canonici SQL sono opachi per il renderer, non vengono ricalcolati con un encoder diverso o sostituiti da hash JSON.stringify.

Il piano ricevuto viene verificato nuovamente con gli stessi controlli puri del Director/2, senza fabbricare un profile_audit mancante: quello del parent è già trattenuto e legato dalla receipt server. Nella vista provider le domande sono nuovi_input.editorial_questions, mai accepted_roles. Le premesse rimangono etichettate con la propria origine; il piano è nuovo e attuale. Il builder omette l’autorità di scelta diretta senza Director soltanto in questa nuova composizione. La normale narrazione diretta non riceve alcun Director aggiuntivo.

next_step privato è solo stay. Il normalizer restituisce ok/origin/text/editorial_next_step/editorial_scene_memory/failure_codes/advisories, senza scene_update o command. Nessun applyAuthority, enqueue, wake, movimento meccanico, pubblicazione o modifica alla missione. La brevità resta advisory come prima; nessun nuovo blocco di qualità.

## HTTP e UI

Il medesimo branch staff-editorial-pair-request/1, dopo getUser esistente, usa whitelist distinta delle campagne E66 ed E68. E66 conserva work/2 e le factory storiche; E68 richiede work/3 e le due nuove source schema. I read sono owner-bound e validati per campagna; la nuova istanza UI non adotta ricevute E66.

Stesso executor Count/Generation, quota, retention prima del normalize, finalize/settle/unknown, deadline condivisa e continuazione del solo Writer non consumato. Un Director non completato non prepara il Writer; non esistono retry automatici o rigenerazioni per migliorare il testo. Nessuna nuova route, RPC o funzione DB viene creata dal ramo Edge/UI.

Tre asset UI in copia: mission-editorial-staff.mjs parametrizza esclusivamente titolo/descrizione/etichette/build con default E66 invariati; mission-generic-ui monta una terza istanza per la campagna E68; land cambia solo il pin d’importazione. E65 e i default E66 rimangono leggibili. Journal separati per utente/campagna/caso, nonce prima della POST, root/child IDs conservati, read manuale e nessun polling o fetch su mount. Le etichette distinguono i tre casi; i corpi delle domande arrivano soltanto dalla sorgente server congelata e non sono inviati dal browser.

## Verifiche e limiti

Quindici controlli sintattici Edge e otto UI positivi; package e tre asset UI riprodotti identici. Il report statico verifica blocchi e costanti storiche conservati. Nessun jsdom, mock, fixture giocata, provider o modello locale. I controlli sono sorgente/sintassi/rebuild; non sono una prova delle risposte o del percorso live.

Le quattro fonti Edge e il manifest UI sono pronte per guard nei percorsi canonici assegnati. Le tre pagine/moduli UI applicativi restano copie fino alla review e all’apply del PM. La candidata va composta con i quattro corpi RPC/seed del DB e sottoposta a un’unica review aggregata11 prima dell’installazione. Qualità e nuove coppie: NOT_RUN. Le precedenti prove, Fati, costi e riserve non sono modificate.
