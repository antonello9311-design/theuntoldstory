# Contratto tecnico Staff · profilo permanente e prove PG + PNG

**Proposto · contratto del primo incremento pronto per assegnazione della candidata · STAFF-SYNTHETIC-CONTRACT-GATES-001 · NARRATIVE-AI / COMBAT · 09/09/2026.** Porte critiche di autorizzazione, offerte e terminali riconciliate con i corpi acquisiti. Il §5.1 è un contratto UI stabile proposto, estraibile dal PM dopo questa consegna come input immutabile per LAND; le implementazioni interne restano da costruire e qualificare. Nessuna garanzia di produzione dalla sola analisi. Nessun codice, DDL, permesso, test o dato di gioco modificato.

## 1. Risultato ratificato e primo incremento

Il PNG di collaudo è un **profilo e un’identità permanenti**, richiamabili rapidamente soltanto nelle Test Room. Ogni richiamo genera una nuova istanza con PV, chakra, effetti, geometria e round indipendenti. La chiusura conserva profilo e storico; nessun reset globale, cancellazione o trascinamento di risorse. Non è un nuovo account, un personaggio giocante o un PNG automaticamente presente in ogni scena.

Prima consegna: testperfunzioni e un PNG nativo nella Staff Test Room, controllati esplicitamente dall’operatore autorizzato. Test Room utenti prevista con cataloghi e permessi distinti; non si certifica già disponibile. Richiamo vietato dal server nel GDR ordinario, nelle missioni e nelle quest reali. Riuji è escluso da accessi, letture di dati personali, collaudi e interventi sulla scena precedente. Non occorre una nuova decisione dell’utente su permanenza, isolamento o identità.

Il primo contratto offre al PNG le azioni native che il server può autorizzare: attacco a mani nude, schivata, parata, nessuna difesa e movimento offerto. Il PG deve poter usare il profilo Sabaku di prova e il Clone già rilasciato. Questo è un perimetro iniziale proposto, non una rinuncia futura alle altre tecniche. Non si concedono al PNG abilità nuove, innate di un PG, tattiche non implementate o accesso ai companion. Estensioni successive usano la medesima identità nativa e le medesime porte, dopo il rispettivo raccordo.

## 2. Evidenze e contatori

Fonti precedenti: 09/09 alle 18:54:14, 18:54:42, 18:55:45 e 19:08:12 UTC. La quarta risposta iniziale fu persa prima della conservazione per errore di estrazione: rimane registrata come non acquisita, senza dedurne assenze. L’incarico precedente COMPLETE ha eseguito **6/6 richieste readonly**, tutte salvate prima del parsing, dalle 19:15 alle 19:24 UTC circa; gli istanti esatti sono nel JSON. Il seguito autorizzato ha aggiunto **2/2 richieste**, alle 19:31:18 e 19:31:39 UTC, conservate prima del parsing. Totale cumulativo **13 richieste, 12 risposte acquisite, 1 risposta storica non conservata**. Nessuna riga PG, role, segreto o configurazione di credenziali letta; zero test, provider, browser e mutazioni.

Il JSON conserva le risposte sanitizzate, le impronte originali server, colonne, indici, vincoli e ACL. Le sei letture aggiungono 70 definizioni restituite, comprese ricontrollate; il numero distinto è calcolato nell’inventario. Le linee nuove si riferiscono a pg_get_functiondef, quelle storiche relevant_lines a prosrc. UUID letterali sono omessi nelle copie documentali; non sono sorgenti eseguibili.

Baseline narrativa: Edge24 e migrazione 20260909183721 da evidenza PM; snapshot SQL riconfermata MD5 a417e6a98201a2177cb8c244a736bb3c, helper narrative_tech_sources_v1 riconfermato MD5 955228bdc23c89cdb287198db57231b8. IA verde 2/5 e Movimento verde 3/5 restano cicli chiusi: questa analisi non è una loro revisione né una nuova campagna.

## 3. Identità, profilo persistente e factory

La chiave meccanica comune è **session_id + actor_id**. Il PG mantiene character_id; il PNG usa actor_kind='png', character_id NULL e png_instance_id. Il vincolo combat_v2_actors_identity_chk già ammette questa identità. Si preservano controller_chk, PK e FK nativi; nessun character fittizio, provider_instance o companion usato come scorciatoia.

Proposta: members.character_id diventa nullable soltanto per il PNG appartenente al contesto protetto verificato. Membership e attore devono combaciare per sessione, tipo e character; cardinalità esattamente 1 PG + 1 PNG nel nuovo contesto, 2 PG nel legacy. Gli slot 1/2 identificano attori, non utenti. Controller identico sui due attori è ammesso solo nella prova autorizzata: mai derivare l’attore dal principal o scegliere l’avversario come «altro utente».

Registro privato proposto combat_consumer_private.test_opponent_profiles: profile_id stabile, template_id canonico, revision, etichetta pubblica, superficie ammessa, is_active. Conserva autorizzazione e versione, non un catalogo parallelo di statistiche. La factory legge public.png_templates, congela nome, caratteristiche, vita/chakra massimi e abilita nello snapshot nativo di combat_v2_png_instances e combat_v2_actors. Ogni nuova prova ha id/istanza/stato propri. Template modificato dopo l’apertura non riscrive la prova esistente; nel riferimento congelato sono inclusi id, revisione del profilo e hash del contenuto effettivamente usato.

Il costruttore effettivo è il blocco PNG interno a public.master_v2_encounter_open(uuid,uuid[],jsonb,jsonb,uuid,jsonb), MD5 07e6d8d02ddd7911635fae65d56e2b3b. Controlla template attivo, costruisce snapshot, inserisce combat_v2_png_instances e actor PNG. Non esiste una factory standalone già certificata: si propone estrarre quel blocco in helper privato comune, lasciando invariato il comportamento Master. Non richiamare l’intera RPC Master: prende lock su luogo/PG, apre un incontro Master e può aggiornare lifecycle missione. Le posizioni del nuovo percorso arrivano dagli slot della scena, non da coordinate arbitrarie del client o dal vecchio parametro pos del Master.

public.png_templates ha nome, grado, statistiche, vita_max, chakra_max, abilita, note e is_active; nessuna colonna di versione è stata inventata. La revisione del registro e l’hash del template risolvono il freeze. Valori di template e geometria non sono stati letti: la scelta di configurazione resta distinta dalla progettazione strutturale.

## 4. Isolamento del contesto e assenza di interferenze

Si propone un contesto esplicito combat_consumer_private.staff_test_contexts con id uguale al session_id nativo, location, operatore, PG autorizzato, profilo/revisione, stato, versione e request_key di apertura. È **una sola prova Staff aggiuntiva per luogo**; non un motore universale di parallelismo. Registro, sessione e binding si creano atomicamente; prima del completamento nessun comando viene offerto.

staff_test_context_id è NULL nel legacy e immutabile nel nuovo percorso. FK e guardie verificano corrispondenza sessione/luogo/operatore e superficie Test Room attiva. Impossibile convertire uno scontro reale in prova o viceversa. I lookup legacy per location escludono i nuovi contesti; le porte nuove richiedono sempre context_id e actor_id. Non selezionano la scena più recente e non toccano la scena precedente.

Partizione necessaria di combat_v2_sessions_unica_luogo_idx, activities_one_open_location e location_claims_one_active_per_location_idx: unicità legacy con contesto NULL e unicità della sola prova Staff con contesto valorizzato. location_claims_one_active_per_owner_idx conserva unicità di tipo/sessione. claim_acquire e v2_claim_trigger propagano e validano il contesto; claim_release continua a rilasciare soltanto l’owner preciso. claims_append_only_guard, ora letto, vieta DELETE/TRUNCATE e ammette solo la transizione di rilascio autorizzata: aggiungere il contesto fra gli attributi immutabili senza disabilitare la guardia.

Il lock breve del registro del luogo per serializzare l’apertura non equivale a bloccare la vecchia sessione o la scheda. Nessuna modifica al luogo o alle sue presenze globali. Non si crea una seconda location: locations_read autentica è oggi pubblica e non risolverebbe il busy globale del PG.

### Lock e writer accertati

| Porta effettiva | Evidenza e modifica necessaria nel solo contesto nuovo |
|---|---|
| combat_gate_private.engagement_insert_guard | Oggi blocca characters e valuta busy; nuovo binding verificato evita impegno reale e lock della scheda. |
| _personaggio_impegnato_meccanicamente | Escludere dal ramo V2 soltanto sessioni sintetiche valide. _attivita_impegno è acquisita: V1/training/esame, nessun V2; resta invariata. |
| combat_v2_lock_round | Lock sessione/round/attori seguito da characters FOR UPDATE: nel contesto nuovo omettere soltanto l’ultimo. |
| combat_v2_round_resolve | Un secondo characters FOR UPDATE esplicito resta nel corpo del resolver: va trattato anche se lock_round è corretto. Ledger e PV/chakra attore restano nativi; characters viene scritto solo con values_written. |
| combat_panel_private.uses_simulated_pools | Oggi dipende da scope Master o marionette Staff; introdurre riconoscimento positivo del nuovo contesto, senza creare sources di companion fittizie. |
| clan_innata_private.combat_state_ensure | Advisory lock oggi basato su character_id + tecnica anche in test. Nel contesto nuovo usare session_id + actor_id + tecnica, conservando la serializzazione reale legacy. |
| clan_innata_private.combat_transition / combat_state_read | Ramo test usa combat_state e snapshot; ramo reale può leggere/scrivere risorse canonicali. combat_scope deve riconoscere il nuovo PG autorizzato prima della scelta del ramo. |
| clan_sabaku_private.reserve_ensure / reserve_for_actor / reserve_identity_guard | La riserva test è già per sessione/actor; reserve_ensure non ricrea una riserva mancante. Il binding è l’unico inizializzatore del campione; mantenere questa invariante. |
| combat_begin_turn / clone_ready / clone_resolve_creation / clone_end_reason | Usano presence globale per controllare il proprietario. Nel nuovo contesto occorre presenza/autorizzazione della prova; non aggiornare public.presence per far passare il controllo. |

La presenza della prova proposta è un lease del contesto autenticato, aggiornato solo dalle nuove porte; non è una finta presenza del PNG. Scadenza o perdita del controller chiude/invalida solo la prova con le transizioni native. Il PNG permanente resta registrato. La durata concreta del lease è una scelta tecnica da fissare nel piano implementativo; non deve introdurre una nuova regola di gioco.

combat_v2_values_written continua a impedire applicazione dei valori reali nel luogo test. Non basta da solo: il resolver chiama anche il ramo companion is_dedicated_scene→settle_round_damage e i trigger elencati in §12. I corpi acquisiti nel seguito chiudono questo punto: is_dedicated_scene richiede un companion_id non nullo nella stessa sessione; il primo contesto vieta companion, quindi il ramo settle_round_damage non viene raggiunto. Non creare sources companion per ottenere simulated_pools. La QA dovrà provare questa esclusione e i trigger, non estendere preventivamente tutte le meccaniche companion. Nessun ripristino successivo sostituisce l’isolamento.

## 5. Porte proposte, comandi e ricevute

Le firme seguenti riassumono il contratto proposto; nomi dei parametri, shape ed errori vincolanti per il consumer sono nel §5.1. Non sono RPC già presenti.

| Porta | Input consentito e risultato |
|---|---|
| staff_test_opponent_profiles_v1(location uuid) | Solo profili offerti per luogo e permessi del chiamante; id/revisione/etichetta, senza catalogo Staff alla superficie utenti. |
| staff_test_open_v1(location uuid,opponent_offer uuid,request_key uuid) | Server deriva l’unico PG autorizzato. Ritorna context_id=session_id, i due actor_id e versioni. Nessuna statistica client, account o grant di tecniche reali. |
| staff_test_state_v1(context uuid,command_actor uuid) | Proiezione della sola prova; attore esplicito, anche se il controller è uguale. |
| staff_test_options_v1(context uuid,command_actor uuid,expected_context bigint) | Offerte native con attore, round, context/controller/scene version e impronta fonte. |
| staff_test_commit_v1(command jsonb) | Whitelist esatta al §5.1: schema, context, actor, expected_context, request_key, offer e selezioni offerte; operazione derivata server, testo come dato. Niente esito, costo, valore meccanico o coordinate libere. |

Percorso reale da raccordare: combat_panel_commit_v1→commit_ordinary→consumer_commit_authoritative→prepare_command→commit_exchange/commit_close. Il Clone passa invece da combat_panel_commit_v1→clan_sabaku_private.commit_clone. Intervenire soltanto su consumer_commit non coprirebbe il comando Clone del sito. La nuova porta si aggancia alle stesse operazioni/validazioni Common, senza clonare il resolver.

prepare_command deve separare principal_character_id (operatore PG autentico), actor_id (PG o PNG controllato) e session/context. assert_dispatch verifica dispatch_authorizations per request/round/operation/principal/txid; aggiungere il binding actor/context verificato e consumarlo nella stessa transazione. Il requisito roster_valid 2 PG attuale diventa un ramo tipizzato soltanto nella prova, mantenendo il controllo legacy.

combat_v2_action_declare e combat_v2_defense_declare verificano controller_user e actor nativo; non richiedono intrinsecamente un character per ogni attore. Risoluzione, RNG, ledger, prove e danni restano server. expected_main_count per ordinary è già 1. after_publish sceglie il prossimo member tramite actor_id diverso, non principal diverso: conservare questa alternanza.

Esistono **due registri di ricevute**, da non confondere: consumer.request_receipts PK(principal_character_id,request_key), con evento Common; panel.request_receipts PK(principal_user,request_key), con offerta ed envelope. commit_clone scrive quello panel; commit_exchange quello consumer, poi l’adattatore panel registra il risultato. Ogni fingerprint deve contenere contesto e attore: riuso della stessa chiave su altro attore/prova è conflitto, non secondo effetto. Nessuna FK character viene assegnata al PNG.

panel.contexts già include command_actor_id e activity_id; refresh_context verifica che l’attore sia controllato e nella sessione. L’unicità (location,principal_user,command_actor_id) NULLS NOT DISTINCT distingue i due attori nuovi; un contesto di apertura senza actor non deve sovrascrivere quello legacy. Usare l’offerta di profilo dedicata alla nuova apertura. owned_context verifica principal e versione, ma il comando nuovo deve inoltre confrontare il test_context atteso. location_adapter, access_reason, state_projection, ordinary_projection e normalize_ordinary vanno raccordati alla sessione esplicita; il vecchio lookup per luogo rimane solo sul ramo legacy.

### 5.1 Contratto UI proposto stabile · staff-synthetic/1

Questa sezione può essere congelata dal PM come input separato per LAND dopo il rilascio dei due documenti. **Stabilità della shape non significa che le RPC esistano o siano già funzionanti.** Nessun consumer legge il contratto mentre viene modificato; l’estratto eventualmente creato è un nuovo scope del PM.

Firme SQL definitive proposte, tutte restituiscono jsonb:

- `public.staff_test_opponent_profiles_v1(p_location uuid)`;
- `public.staff_test_open_v1(p_location uuid,p_opponent_offer uuid,p_request_key uuid)`;
- `public.staff_test_state_v1(p_test_context uuid,p_command_actor uuid)`;
- `public.staff_test_options_v1(p_test_context uuid,p_command_actor uuid,p_expected_context bigint)`;
- `public.staff_test_commit_v1(p_command jsonb)`.

Ogni risposta applicativa ha `schema_version:"staff-synthetic/1"`, `ok:boolean`, `request_key:uuid|null`, `data:object|null`, `error:object|null`. Esattamente uno tra data/error è valorizzato. Gli UUID restano stringhe, le versioni interi entro il limite sicuro JavaScript; gli array sono sempre array, mai null. Errori di trasporto/PostgREST restano errori di trasporto e non diventano successi applicativi.

**profiles.data:** `location_id`, `surface:"staff_test"`, `profiles:[{offer_id,profile_id,revision,label,expires_at}]`. Nessun valore meccanico o testo interno nella card. Lista vuota è risultato valido; il client non inventa un profilo. L’offerta lega profilo/versione/superficie/principal e scadenza; mutamento invalida l’offerta.

**open.data:** `test_context_id`, `session_id` uguale al contesto, `location_id`, `state:"active"`, `context_version`, `controlled_actors:[{actor_id,kind:"pg"|"png",label}]` con esattamente due elementi, `selected_actor_id` inizialmente PG e `panel`. `panel` riusa **combat-panel/1** esistente (context/viewer/actors/map/offers/narrative/round_details/receipt), senza wrapper parallelo delle formule. La forma di mappa rimane combat-map/2 del pannello. Il solo renderer nuovo gestisce profilo permanente, scelta attore e contesto; gli altri pannelli continuano a consumare la versione esistente. Il kind PNG viene rappresentato correttamente dal normalizzatore, senza usare companion. Reinvio della stessa apertura/chiave restituisce lo stesso contesto con `replayed:true`; differente offerta con stessa chiave è conflitto.

**state.data / options.data / commit.data:** stesso blocco contesto/attori/panel di open, `state:"active"|"closed"`, `replayed:boolean`. state può mostrare una prova chiusa e il suo storico autorizzato; options/commit rifiutano una prova chiusa. `context_version` è esattamente panel.context.version, non una seconda versione UI. Cambio attore produce un pannello dell’attore selezionato: il client non riusa offerte del precedente. `panel.status` conserva ready/blocked e reason_code; una risposta di lettura riuscita può contenere un pannello bloccato senza autorizzare comandi.

**commit.p_command:** oggetto con soli `schema_version:"staff-synthetic-command/1"`, `test_context_id`, `actor_id`, `expected_context`, `request_key`, `offer_id`, `selections` e `narrative_text`. Tutti obbligatori; selections è oggetto (anche vuoto), narrative_text stringa o null. L’operazione è derivata dall’offerta, non un ulteriore comando libero del client. I campi selections sono soltanto identificativi/scelte presenti nell’offerta nativa; schema sconosciuto o chiave meccanica viene rifiutata. Il backend converte la shape in comando panel Common server-side, mantenendo la medesima offerta e il medesimo fingerprint. La chiusura è un’offerta di amministrazione del contesto; nessuna sesta RPC o chiusura per location implicita. Per azione PG il testo è obbligatorio dove l’offerta lo richiede; per PNG è dato opzionale, senza rappresentarlo come role di altro PG.

**error:** `{code,message,refresh_required}`. Codici stabili: `authentication_required`, `staff_scope_not_allowed`, `test_room_only`, `context_not_owned`, `actor_not_controlled`, `profile_unavailable`, `offer_expired`, `context_stale`, `offer_not_valid`, `request_key_conflict`, `test_already_active`, `context_closed`, `invalid_command`, `release_not_enabled`, `internal_error`. message è italiano, non espone SQL/stack/id altrui. refresh_required=true solo per contesto/offerta stale o scaduti; la UI rilegge stato/offerte ma **non reinvia automaticamente un comando**. internal_error mantiene request_key per audit; nessun retry alla ricerca di un verde. Vincoli imprevisti e errori di sicurezza fanno fallire atomicamente l’operazione e vengono registrati, senza essere trasformati in successo.

La UI conserva il test_context_id selezionato in memoria della prova e lo invia sempre; non lo ricostruisce dalla location. Nuova apertura non sposta presence globale né chiude una scena. I messaggi contestuali sono letti attraverso le policy autorizzate e filtrati per test_context_id; i dettagli del trasporto Realtime non modificano la shape RPC. Un mock locale può sviluppare questa interfaccia, ma non attesta il percorso live.

## 6. Geometria e Clone: correzioni necessarie, formule invariate

claim_scene è stato letto: crea scene_claims, arena_instances e object_states usando scene_profile, versione del template e fingerprint; non richiede un secondo motore. place_fighters invece esige due PG e slot PG. Nel nuovo contesto deve collocare i due attori tipizzati sugli slot della stessa geometria certificata. actor_states già supporta PG/PNG; projection_subject_id proposto uguale ad actor_id per entrambi nella nuova prova, legacy invariato. Reader e maschere devono distinguere quel subject dall’id di un character.

movement_commit lavora su instance/actor, capability, versioni e percorso validato, scrivendo actor_states e ricevute spaziali. shared_movement_scope riconosce già una activity ordinary. Non cambiare griglia, costi o intercetti per rendere verde un caso. movement_block_reason e template_errors sono acquisiti; le differenze geometriche concrete e i reader si verificano nel candidato locale (§12), senza dedurre sicurezza dalla sola forma della capability.

Due esclusioni PNG sono accertate nel Clone: **clone_nearby_candidates** filtra actor_kind='pg'; **clone_movement_intercept** ritorna subito per actor_kind diverso da pg. Quindi il PNG nativo oggi verrebbe ignorato sia in prossimità sia durante il movimento. Proposta minima: ammettere in entrambi esclusivamente il PNG fisico della prova con binding server valido, conservando squadre, corpo attivo, distanza 2 m, selezione deterministica del contatto, tiro e risultato. Non è una nuova immunità o una revisione delle formule. L’eventuale estensione agli altri PNG di gioco richiede il proprio raccordo successivo.

clone_trigger_nearby e clone_movement_intercept invocano la stessa clone_capture_result sui valori dello snapshot e sui dadi server. clone_apply_immobilization lega effetto a sessione/attori/cattura; clone_release libera soltanto l’impegno e conserva audit, senza rimborso chakra o incremento della sabbia corrente. I motivi di cessazione, compreso capture_failed, restano autoritativi. Le caratteristiche narrative del Clone non decidono da sole che un colpo lo abbia distrutto.

## 7. Messaggi, fonti e narratore

**post_message non è una porta sicura da riusare integralmente per la nuova prova.** Legge il combattimento legacy del luogo, può interpretare comandi, contiene scritture di risorse reali e aggiorna public.presence. Il trigger trg_role_autojoin può agganciare una REC esistente e aggiornare partecipanti anche quando la Test Room impedisce di aprirne una nuova. Occorre un writer contestualizzato che riusi la validazione testuale pertinente e inserisca soltanto messaggio/audit della prova; non chiamare il vecchio parser/presence e non impersonare altri personaggi.

Proposta: public.messages.staff_test_context_id con FK al contesto e autorizzazione server; ramo NULL legacy invariato. trg_role_autojoin deve riconoscere il nuovo contesto protetto **prima** dei lookup/aggiornamenti REC, come controllo autonomo di sicurezza. messages_read attuale non isola questa prova: aggiungere policy contestuale per il nuovo ramo, preservando i casi whisper/motore legacy. Accesso dal sito e Realtime richiedono una verifica successiva reale: una colonna non certifica la UI.

PG: testo role autentico del PG. PNG: testo dell’operatore o breve fatto descrittivo dell’azione offerta, sempre attribuito al PNG e legato a dichiarazione/attore/controller, non inventato dal motore come esito. declaration_messages viene tipizzata per pg_role/staff_png_action con fonte e hash verificabili. **Ordine proposto per evitare un ciclo di FK:** inserire la dichiarazione nativa, scrivere messaggio contestuale e collegarlo alla dichiarazione/evento/attore già esistenti, poi completare ricevute consumer/panel. Non fare dipendere la fonte della snapshot da una ricevuta finale non ancora scritta; questa corregge la precedente proposta di FK obbligatoria immediata al receipt finale. Il principal resta l’operatore, l’autore scenico resta l’attore. L’audit delle due ricevute collega a posteriori la medesima operazione nella stessa transazione.

record_message oggi pretende message.character_id=actor.character_id e controller autenticato; la nuova diramazione verifica il tipo PG/PNG, la stessa prova, la dichiarazione e l’autorizzazione. scene_snapshot_v2 oggi costruisce due PG con JOIN characters e conta fonti role: deve risolvere nome/tipo pubblico dallo snapshot nativo e accettare fonti azione PNG tipizzate. Narrative_context, narrative_ordinary_context, display_label, recovery_snapshot e narrative_tech_sources mantengono identità/versioni/fonti della stessa prova; niente lookup per ultimo luogo e niente catalogo duplicato.

Il publisher reale acquisito è combat_v2_narrative_store: inserisce Fato in public.messages e chiama after_publish. La ripubblicazione combat_v2_round_narrate_ai_apply inserisce autonomamente un altro messaggio. Entrambi devono propagare il contesto della sessione; il messaggio Fato senza character evita REC, ma senza filtro finirebbe comunque nel flusso condiviso del luogo. before_publish è ora acquisita: exige contesto resolved, autorità, request/round/txid, hash del testo e versioni coerenti; i rami umano, ai_auto, ai_review e recovery mantengono le proprie guardie. public.combat_consumer_scene_complete_v2 e combat_consumer_narrative_complete_v1 preparano l’autorizzazione nella stessa transazione e usano narrative_store, poi la consumano. Non allentare o sostituire questa autorità per fare funzionare il nuovo attore.

Edge24 e il lifecycle provider restano il percorso da riusare; narrative_allowed oggi pretende due controller PG e deve avere il ramo del contesto autorizzato. Nessuna chiamata IA all’apertura. Catalogo e profilo sono dati, non istruzioni o eventi; il server decide risultati e cessazioni, la role resta libera, il narratore integra senza rivelare originale delle copie o coordinate nascoste. La prima prova qualitativa valuta la singola mossa quando le role sono abbozzate, non l’intera scena.

## 8. Chiusura e conservazione

commit_close autentica il principal, verifica can_close e chiama close_session. Quest’ultima blocca e chiude la sola sessione/activity, revoca le sue offerte e chiude la sua arena; conserva round, dichiarazioni, referti e risorse. close_narrative_control invalida soltanto claim narrativi della sessione e chiude l’eventuale autorità narrativa associata, senza creare un secondo scontro. no_second_encounter impedisce già che quell’autorità diventi un incontro Master.

Il nuovo contesto va marcato chiuso nella medesima transazione, il relativo lease invalidato e le offerte panel di quella prova revocate; profilo permanente intatto. Trigger Clone e immobilizzazione acquisiti lavorano per sessione/attore. clone_reconcile usa la stessa sessione e le transizioni native; il ramo public.presence di clone_lifecycle_trigger può invece scandire le sessioni dello stesso controller: il nuovo contesto usa il proprio lease e va escluso da quella scansione globale, affinché una presenza reale non condizioni una prova. I trigger Master risolvono in sync_master_scene, che termina senza una arena panel_master; assert_master_ready ed ensure_actor_turn escono senza un incontro Master registrato. start_command_window esce senza dedicated_scene/companion. Le condizioni sono osservate nel codice, da mantenere e coprire nella QA. Non chiudere scene precedenti, non cancellare audit e non eseguire recuperi globali.

## 9. Inventario dei consumer effettivamente dipendenti

L’elenco completo **dei31riferimenti diretti osservati** è il seguente; pin/owner/ACL e righe nel JSON; questi estratti storici non equivalgono ai corpi completi. Non tutti vanno riscritti: quelli fuori dal profilo iniziale restano esclusi mediante porte reali verificate, senza presumere che un ritornoanticipato esista.

| Routine | Intervento o invariante da verificare |
|---|---|
| `clan_marionettisti_private.actor_visible(uuid,uuid,uuid)` | companion: verificare esclusione del ramo nel primo profilo; preservare percorso esistente |
| `clan_marionettisti_private.assert_source(uuid)` | companion: verificare esclusione del ramo nel primo profilo; preservare percorso esistente |
| `clan_marionettisti_private.consumer_defense_options(jsonb)` | companion: verificare esclusione del ramo nel primo profilo; preservare percorso esistente |
| `clan_marionettisti_private.consumer_options(jsonb)` | companion: verificare esclusione del ramo nel primo profilo; preservare percorso esistente |
| `clan_marionettisti_private.consumer_projection(jsonb)` | companion: verificare esclusione del ramo nel primo profilo; preservare percorso esistente |
| `clan_marionettisti_private.ordinary_body_bind(uuid,uuid,jsonb)` | companion: verificare esclusione del ramo nel primo profilo; preservare percorso esistente |
| `clan_marionettisti_private.roster_valid(uuid)` | companion: verificare esclusione del ramo nel primo profilo; preservare percorso esistente |
| `clan_marionettisti_private.staff_profile_bind(uuid,jsonb)` | companion: verificare esclusione del ramo nel primo profilo; preservare percorso esistente |
| `clan_sabaku_private.consumer_options(jsonb)` | Sabaku Staff: guard2PG/2principal da adattare esclusivamente al nuovo contesto |
| `combat_consumer_private.accept_invitation(uuid,uuid)` | legacyPG+PG: preservare invito e consenso; nuova porta distinta |
| `combat_consumer_private.after_publish(uuid,uuid)` | turno: selezione altroactor per sessione, mai altroprincipal |
| `combat_consumer_private.approach_capabilities(uuid,uuid,uuid)` | geometria/capacità: identitàactor e controller scoped |
| `combat_consumer_private.assert_dispatch(uuid,uuid,text)` | consumer/auth/offerte: contesto e actor espliciti |
| `combat_consumer_private.attach_movement(jsonb,jsonb,uuid,uuid)` | geometria/capacità: identitàactor e controller scoped |
| `combat_consumer_private.can_close(uuid)` | consumer/auth/offerte: contesto e actor espliciti |
| `combat_consumer_private.display_label(uuid,uuid,uuid,bigint)` | identità/fonti/pubblicazione: bindingactor e fontePG/PNG tipizzata |
| `combat_consumer_private.exchange_options(jsonb)` | consumer/auth/offerte: contesto e actor espliciti |
| `combat_consumer_private.narrative_allowed(uuid)` | identità/fonti/pubblicazione: bindingactor e fontePG/PNG tipizzata |
| `combat_consumer_private.narrative_context(uuid)` | identità/fonti/pubblicazione: bindingactor e fontePG/PNG tipizzata |
| `combat_consumer_private.narrative_tech_sources_v1(uuid)` | identità/fonti/pubblicazione: bindingactor e fontePG/PNG tipizzata |
| `combat_consumer_private.offer_exchange(uuid,uuid,uuid,integer,text,text,jsonb)` | consumer/auth/offerte: contesto e actor espliciti |
| `combat_consumer_private.place_fighters(uuid)` | geometria/capacità: identitàactor e controller scoped |
| `combat_consumer_private.prepare_command(jsonb)` | consumer/auth/offerte: contesto e actor espliciti |
| `combat_consumer_private.recovery_snapshot_v1(uuid)` | identità/fonti/pubblicazione: bindingactor e fontePG/PNG tipizzata |
| `combat_consumer_private.scene_snapshot_v2(uuid)` | identità/fonti/pubblicazione: bindingactor e fontePG/PNG tipizzata |
| `combat_consumer_private.state_projection(uuid)` | consumer/auth/offerte: contesto e actor espliciti |
| `combat_panel_private.multiplication_approach_capabilities(uuid,uuid,uuid,uuid,bigint,integer)` | geometria/capacità: identitàactor e controller scoped |
| `combat_panel_private.multiplication_register_defense_selections(uuid,uuid,uuid,jsonb,uuid,uuid)` | geometria/capacità: identitàactor e controller scoped |
| `combat_panel_private.narrative_clone_facts(uuid)` | identità/fonti/pubblicazione: bindingactor e fontePG/PNG tipizzata |
| `combat_panel_private.narrative_ordinary_context(uuid)` | identità/fonti/pubblicazione: bindingactor e fontePG/PNG tipizzata |
| `combat_sabaku_staff_profile_bind_v1(uuid,bigint,uuid)` | Sabaku Staff: guard2PG/2principal da adattare esclusivamente al nuovo contesto |

## 10. Delta di vincoli e ACL da includere nella candidata

| Oggetto | Delta proposto o invariante |
|---|---|
| members.character_id e membership | Nullable solo PNG protetto; FK character conservata. FK composita session/actor, guardia tipizzata e cardinalità protetta; PK e unicità slot/character conservati. |
| actors identity/controller | Conservare i check esistenti; nativo png_instance_id, controller esplicito; nessun character o companion fittizio. |
| sessions / activities / location_claims | staff_test_context_id nullable legacy, FK coerenti, immutabilità; partizione dei tre indici per luogo e conservazione dell’unicità owner del claim. |
| activities policy | Conservare staff_test_no_persistent_resources_v1; nessun nuovo permesso di scrivere valori reali. |
| scene_claims / arena_instances / actor_states | Conservare fonte ordinary e relativo claim/FK; placement PG/PNG e subject tipizzato; vincoli di geometria/versione conservati. |
| reserves | Conservare UNIQUE test(session,actor) distinta dalla riserva reale; guardia verificata, unico inizializzatore tramite bind. |
| dispatch_authorizations | PK(request,round,operation), FK principal_character e round conservate. Aggiungere/validare actor e contesto autenticato senza usare il character del PNG. |
| panel.contexts / offers / receipts | Nessun nuovo tipo activity richiesto: ordinary_v2 resta valido. Le offerte devono corrispondere ad actor/context/version e principal; stesso request riusato altrove rifiutato. Guardia offer_context_guard acquisita: verifica principal, attore, context/scene version e source fingerprint; preservarla e costruire il nuovo contesto coerentemente. |
| declaration_messages / messages | Fonte tipizzata, contesto, FK dichiarazione/messaggio/evento/attore coerenti e hash immutabile; record_message e trigger REC adeguati. La receipt finale non precede la dichiarazione. |
| registri privati proposti | Profili permanenti e contesti per prova; FK template, superficie ammessa, stato/versioni, request idempotente, vincoli che vietano conversione in gioco reale. |

Owner postgres. Helper interni SECURITY DEFINER con search_path vuoto, REVOKE esplicito PUBLIC/anon/authenticated e soli permessi interni necessari. Nuove RPC: GRANT EXECUTE authenticated esplicito, autenticazione/Staff/allowlist/perimetro verificati dentro la porta; anon escluso. Registri privati senza accesso diretto anon/authenticated, RLS appropriata; nessun GRANT generale allo schema. L’helper booleano della policy messages_read può avere EXECUTE authenticated limitato al controllo del chiamante, senza esporre il registro. Service_role mantiene solo i permessi necessari alle porte narrative già autorizzate.

Metadata appena acquisiti: dispatch_authorizations RLS forzata; panel contexts/offers/receipts RLS attiva non forzata, ACL postgres-only. png_templates ha ACL ampie con RLS attiva: la disponibilità di un template non autorizza il suo richiamo nella prova, che passa dal registro privato. Non modificare gli ACL di tutto il catalogo per aggiungere il profilo. L’elenco è concreto per gli oggetti noti, ma il manifest applicativo completo resta subordinato ai corpi mancanti sotto.

## 11. Dieci gruppi di verifica proposti, non eseguiti

| Gruppo | Criterio osservabile | Submission proposte |
|---|---|---:|
| G1 Apertura/profilo | Profilo permanente, nuovaistanzaPGPNG, due prove successive senza trascinamento, nessun characters nuovo | 2 |
| G2 Permessi | SoloPGautorizzato; Riuji/estranei rifiutati, richiamo fuoriTestRoom vietato; Staff e utenti separati | 2 |
| G3 Azioni/difesa | Medesimo operatore comanda actor distinti solo con offerte native; risoluzione server e reazione unica | 2 |
| G4 Movimento/tecniche | SlotPGPNG, distanze e lifecycle reali, Cloneattribuito correttamente, nessun campo meccanico client | 2 |
| G5 Fonti | RolePG e azionePNG autenticata, identità/versioni, catalogo come dato, nessuna informazione nascosta | 1 |
| G6 Isolamento | Prova con scena legacy sintetica giàaperta sul medesimo luogo ePG; nessuna variazione di quelle risorse o attese sul loro lock | 2 |
| G7 Concorrenza/idempotenza | Dueconnessioni, stesso request_key, actor/versione stale; un solo effetto e una sola nuova prova | 3 |
| G8 Snapshot/replay | Hash/fonti congelati e vecchio payload compatibile, nessun lookup ultima scena | 1 |
| G9 Chiusura | Solo prova corrente chiusa, profilo e storico conservati, comandi successivi rifiutati | 1 |
| G10 Installazione/recovery | COMMITinstall/recovery da nuova connessione, baselinecorpi/ACL/vincoli; scenelegacy e prove preservate | 4 |

Totale gruppi: 20 submission +bootstrap/preflight/install3 +postflightfinale1 = **24 massime**,45min,20000token orchestrazione,0provider. È un budget proposto: prima dell’esecuzione owner ePM congelano la candidata intera e i vettori, verificando che bastino; niente incremento durante il banco. Le identitàPGlegacy di G6 sono fixturelocali sintetiche, mai accesso a Riuji. Le tredici richieste cumulative di analisi non sono quella campagna.

Dopo review e gate: testperfunzioni con PNGnativo nella Staff, una sola prova, massimo1chiamata narrativa,0retry,10min/12000token quando misurabili. Le nuoveporte non devono generare IAall’apertura. Login autorizzato e isolamento sono prerequisiti reali; mocklocale nonattestaAuth/Edge/Realtime/UI. Nessuno smoke viene avviato da questo contratto.

## 12. Closure tecnica e rischi da verificare nel candidato

**Nessun ulteriore inventario generale è prerequisito per partire con la candidata coerente del primo incremento.** La baseline contiene ora i corpi di before_publish, offer_context_guard, i due completamenti del servizio, i dieci trigger rimasti e i loro terminali essenziali osservati. Le firme e i pin sono nel JSON; le lacune precedenti restano nel record storico della consegna, non nello stato corrente.

| Punto chiuso | Evidenza e conseguenza |
|---|---|
| Autorità della pubblicazione | before_publish + public.combat_consumer_scene_complete_v2 + public.combat_consumer_narrative_complete_v1: stesso claim/report/context, autorizzazione per txid e hash, stesso narrative_store. Conservare il lifecycle e le revisioni; adattare solo identità/fonti e messaggio contestuale. |
| Offerte | offer_context_guard controlla corrispondenza principal/actor/context/scene/fingerprint; il nuovo wrapper non scavalca questa guardia. |
| Companion | is_dedicated_scene esige un companion nella sessione. Il primo contesto vieta companion e sources fittizie; settle_round_damage, che altrimenti contiene lock characters, resta escluso per condizione effettiva. |
| Trigger Master | assert_master_ready ed ensure_actor_turn escono senza incontro Master registrato; sync_master_scene esce senza arena panel_master. Ordinary nuovo non deve creare questi binding. |
| Clone e immobilizzazione | clone_reconcile e release sono scoped; trigger fine attore/sessione degli effetti sono scoped. Eccezione da adattare: ramo presence globale del Clone, da separare dal lease della prova. |
| Movimento | movement_block_reason legge attore, immobilizzazione e mobility dello snapshot, senza writer PG. template_errors valida geometria pubblica, non autentica un attore. |

**Rischi e lavoro di implementazione, non nuove decisioni teoriche:**

- Geometria: template_errors contiene una variante neutral con slot etichettati PG e coordinate frazionarie. Non alterare un template/versione già in uso né ricopiare coordinate incompatibili con il motore a griglia corrente. Preparare configurazione di scena test versionata dagli strumenti/cataloghi esistenti; la candidata congela valori, hash e mapping tipizzato PG/PNG, e G4/G10 verifica placement, griglia e recovery. La scelta concreta di template/profilo è configurazione da completare prima del banco.
- Percezioni: multiplication_view filtra per luogo e attori visibili, e mostra original_index al controller. Il nuovo contesto deve filtrare anche per sessione; poiché l’operatore controlla due attori, autorizzazione amministrativa e percezione dell’attore restano distinte. Il payload narrativo e quello della decisione PNG non ricevono originale nascosto o coordinate non osservabili. Nel primo profilo senza Moltiplicazione PNG il ramo non viene inventato; prima di offrire ulteriori tattiche/tecniche si verifica il rispettivo raccordo.
- Factory/profilo: valori del campione, template e disponibilità non sono stati letti né creati. Il prossimo scope prepara una configurazione concreta da catalogo pubblico canonico, senza PG privati, account o grant reali. Versione/hash congelati alla creazione dell’istanza.
- Completeness interna: il manifest deve enumerare tutte le funzioni/constraint/ACL effettivamente modificate e i corpi necessari alla fixture. Valutare l’intera matrice sulla stessa candidata; non serve continuare a espandere ogni callee puro prima di scrivere. Un writer, permesso o lookup nuovo emerso nel montaggio deve essere risolto nel candidato prima della campagna, senza dichiararlo sicuro per supposizione.
- Auth, RLS via API, Realtime, UI e Edge reali non sono dimostrati da questi metadati o da Docker. Restano rischi nominati del rilascio controllato e dello smoke protetto, con STOP se l’isolamento manca. Nessuna produzione usata per scoprire la sicurezza della migrazione.

## 13. Sequenza implementativa dopo il gate del contratto

1. PM adotta il contratto e deposita un estratto immutabile del §5.1 per LAND. Owner DB costruisce context resolver, autorizzazione, writer messaggi, fonte PNG e placement con i pin disponibili; completa la sola configurazione pubblica del campione nel candidato. Non è richiesta un’altra ricognizione generale.
2. Owner DB/Combat prepara una candidata coerente: persistenza profilo/contesto, partizione claim, factory comune, membership, isolamento writer/lease/lock, controller/offerte, placement e target Clone. Riusare formule Common e sorgenti catalogo; integrare tutti i trigger raggiunti, senza patch per singolo caso.
3. Sul contratto congelato, contributi consumer/UI e narrativa possono procedere in parallelo su file distinti: richiamo profilo e scelta attore; proiezione/fonti/pubblicazione nel contesto. Il PM mantiene i file condivisi e integra una sola revisione end-to-end. Nessuna task visibile aggiuntiva implicita.
4. Candidata unica congelata, matrice proposta G1–G10 in PostgreSQL reale isolato, review indipendente e contatori del nuovo lavoro dichiarati. Recovery selettivo con dati/storico conservati: disattiva nuovi richiami, non cancella i profili o le prove e non ripristina un vincolo legacy incompatibile finché esistono contesti attivi.
5. Gate nominativi apply/deploy/enable distinti. Dopo rilascio protetto, collaudo diretto testperfunzioni + PNG nativo entro budget provider; verifica UI e isolamento. Disponibilità Test Room utenti resta una consegna esplicita successiva con i suoi permessi. Solo dopo questa evidenza si considera l’estensione multiattore/missioni, senza usare il profilo di collaudo nelle scene reali.

## 14. File candidati proposti e responsabilità

Nel medesimo candidato Narratore: STAFF_SYNTHETIC_INSTALL.sql (DDL, helper, RPC e innesti Common sopra nominati), STAFF_SYNTHETIC_RECOVERY.sql (ripristino selettivo vincoli/corpi/ACL con stop se dati attivi incompatibili), STAFF_SYNTHETIC_FIXTURE.sql (cataloghi pubblici e PG/scene locali sintetici), STAFF_SYNTHETIC_RUNNER.py, STAFF_SYNTHETIC_QA.json, STAFF_SYNTHETIC_MANIFEST.json e STAFF_SYNTHETIC_PLAN.md. Sono nomi proposti per il prossimo scope, non file già creati o prenotati. Gli innesti narrativi SQL appartengono alla stessa INSTALL: scene_snapshot_v2, narrative_tech_sources_v1, narrative_allowed, record_message, narrative_store e ripubblicazione; nessuna seconda funzione Edge prevista salvo gap di contratto effettivamente osservato.

UI: candidata isolata STAFF_SYNTHETIC_LAND.html, derivata soltanto dopo riconciliazione del vero sito_live/land.html con la versione remota; owner LAND-UI. Consuma le cinque RPC proposte, espone richiamo del profilo permanente e selezione PG/PNG, filtra messaggi e pannello per context_id, non modifica la presenza globale per autenticare il test. Nessuna scrittura al sito_live da questo incarico. Se il controller attuale richiede pannelli ulteriori, il PM modifica lo scope prima di implementare; admin/scheda e regole non sono inclusi implicitamente.

Backend prima: schema, autorizzazione/context e RPC shape congelati. Poi frontend e narrativa procedono in parallelo sui rispettivi output, integrando una candidata completa prima della matrice. La lista nominale delle funzioni da modificare è nei §§3–10 e la baseline conserva i pin; la migrazione deve elencare ogni funzione/vincolo/ACL effettivamente toccato senza GRANT indiscriminati.

## Handoff al PM

Due documenti consegnati, nessun codice o test. Il seguito GATES ha acquisito 2/2 risposte readonly alle 19:31:18 e 19:31:39 UTC; totale cumulativo 13 richieste/12 risposte conservate, una perdita storica dichiarata. Raw conservate prima del parsing. Autorità del publisher, guardia offerte e terminali essenziali sono riconciliati; rischi di implementazione e QA nel §12, senza ulteriori blocchi analitici generici. §5.1 pronto come contratto consumer stabile proposto: PM può congelarne un estratto immutabile per LAND e avviare backend/frontend in parallelo sugli scope assegnati. Il resto è candidato da costruire/qualificare, non produzione pronta. IA verde e movimento verde restano immutati. Permanenza test-only e Riuji escluso invariati. Nessuna riga PG, provider, browser, mutazione o test.
