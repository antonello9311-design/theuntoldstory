# MISSION_GENERIC_PROGRESS · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

- Riga 30: `<>case when p_outcome='success' then 'conclusa' else 'fallita' end` → `<>(case when p_outcome='success' then 'conclusa' else 'fallita' end)`.

SQL SHA256 `f15b889b1ba36fd5dc3a6c4dbcae2466e8dd8b19f9bbcb90504f3a84577d9581` · 34704 byte. SHA A1 `74d09ee600af60e3e331b8514d492eeb264fb5c99899c11d77dd08faab596c57`. Controlli statici: 25 statement SQL top-level, 10 funzioni PL/pgSQL dirette e 3 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

# MISSION-GENERIC-PROGRESS-A1

Stato: candidata A1 congelata per controverifica indipendente; non applicata al database, non collaudata sul sito.

## Scope toccato

Raccordo deterministico dalla missione al Combat e ritorno: stato stanza, ingresso tick del servizio con utente già verificato da Edge, apertura dello scontro configurato nella fase, scelte PNG Common, difese native multitarget, valutazione neutra nativa, resolver esistente, accodamento della narrativa completa, chiusura incontro, trigger di esito e chiusura missione. Recovery limitata all'incipit fallito prima della pubblicazione.

SQL: `MISSION_GENERIC_PROGRESS.sql`, SHA-256 `74d09ee600af60e3e331b8514d492eeb264fb5c99899c11d77dd08faab596c57`, 34702 byte. Una tabella privata di ricevute, dodici funzioni nuove (due pubbliche, dieci private comprese due estrazioni native) e un hook aggiuntivo a `combat_panel_private.enroll_master`. Nessun resolver nuovo, nessuna modifica al resolver esistente. Nessun vincolo esistente allentato; vincoli nuovi: PK request_key, FK run binding, risultato hash SHA-256, trigger immutabilità e RLS senza policy sulla tabella privata.

## Contratti usati/modificati

Composizione: DB → PLAN_WRITER → BOARD → COMBAT → PANEL → SOURCES → DISPATCH → PROGRESS. Le funzioni PL/pgSQL possono riferire helper installati più tardi nella composizione; nessuna chiamata applicativa prima del completamento dell'intero pacchetto. BOARD deve esistere prima dell'installazione PROGRESS per i rowtype.

- HTTP `mission-generic-tick/1`: Edge verifica bearer con getUser, passa il vero uid a `public.mission_generic_progress_v1(p_session,p_user,p_request)`, GRANT solo service_role. Il chiamante non sceglie incontro, attore, numeri, esito o facts. Risposta `{schema_version:'mission-generic-progress/1',master_session_id,state,dispatch}`; dispatch è null oppure il descriptor `mission-generic-request/1` già generato da DISPATCH. Un tick prepara al massimo un lavoro; il tick successivo riprende dopo la sua consegna. Replay della stessa richiesta restituisce la medesima ricevuta, anche dopo chiusura.
- `public.mission_generic_room_state_v1(p_location)` GRANT authenticated, sola lettura: null o `{session_id,step_key,objective,choices,choice_context,state,can_tick,request}`. choices è array `{trigger_key,label}`; choice_context contiene master_control_version/run_control_version, step e narration_pending nativi. Partecipante reale ancora presente o staff autorizzato; allo staff non partecipante non vengono offerte scelte PG. Nessun payload narrativo, dati privati PNG o valori arbitrari.
- BOARD `start_claims`: ammissione transazionale owner-only (session/mission/location, actor_user_id reale uguale ad auth.uid, txid/pid, simulation), prima della FK binding. Il nuovo hook restituisce dall'enroll durante tale INSERT; il percorso già consegnato COMBAT effettua l'enroll dopo binding/capability. Solo Staff room nominata per simulazione, senza auth falsificata.
- Predicate terminale: `combat_outcome` opzionale any/pg_win/pg_loss/draw, default any. Derivazione esclusivamente dagli schieramenti attivi nativi contro pg_team congelato. Deve risultare esattamente un trigger; ambiguità/assenza errore esplicito. Dipende dal delta DB/WRITER del relativo validator, concordato con l'owner DB e da congelare nella review aggregata.
- Più incontri sono ammessi in fasi/visite distinte; più punti di apertura nello stesso step senza ordine/trigger specifico sono rifiutati. L'editor attuale configura un incontro per step: nessun ordine arbitrario nascosto.

## Decisioni prese

1. Il tick riusa `enqueue_choice(session,encounter,actor)`, quindi ogni PNG ha il suo principal, persona e offerte Common. Difese PNG selezionate solo con phase/state raccolta_difese; principali PNG solo con phase/state raccolta_azioni, dopo la barriera di tutte le principali PG e solo se il PNG non ha già dichiarato. La narrazione viene accodata solo quando il resolver ha un referto completo: nessun testo anticipato.
2. `combat_v2_round_resolve` è invocato direttamente. Per evaluation_mode=neutra è il resolver a registrare zero e fonte neutralita_sistema; non si aggiunge valutazione qualitativa IA. Per una modalità diversa e voti umani mancanti si restituisce waiting_quality. Sostituzione, moltiplicazione e altre tecniche seguono i resolver già pubblicati; errori nativi non vengono aggirati.
3. `combat_narrative_source`/`enqueue_combat` usano il report_id nativo. Il publisher nativo apre il round successivo oppure marca lo scontro risolto. PROGRESS non lo duplica.
4. Il terminale Combat verifica incontro/visita/step, tutti i round narrati, stato nativo, close event completata, capability e hash della ricevuta. `apply_authority` è chiamato nella stessa transazione della chiusura. Nessun avanzamento dalla prosa.
5. La chiusura missione deriva da run_plan_settings.terminal_steps, dopo la pubblicazione del testo della visita terminale, nessun lavoro pending/failed e nessun incontro aperto. Inserisce i sei passi di chiusura nativi se assenti. Usa un clone precisamente delimitato del close core e uno di missione_esito per il servizio Generic; i percorsi originali rimangono identici. Per ricompense ordinarie resta la stessa assegnazione server, previo controllo del roster congelato. Nessuna impersonazione staff.
6. Simulazione: board_starts.simulation, mapping carrier immutabile, luogo Staff esatto, roster autorizzato, snapshot/hash e policy risorse Common. Salta esplicitamente missione_esito e role_finalize: niente premi, booking reali, PG/risorse/progressione/REC preesistenti. Non modifica mission_id o quest_kind. La chiusura libera solo prenotazioni della propria activation e revoca la propria capability.
7. Incipit fallito: abort automatico soltanto per unico work opening definitivamente failed, nessun messaggio pubblicato, nessun incontro e run ancora preparazione. I lavori provider_started/uncerti restano pending e non vengono abortiti. Riusa sync_lifecycle annullata; libera reservations e quote solo reserved della propria activation, conserva outbox non pubblicata e audit senza marcarli falsamente pubblicati.

## Correzione aggregata A1 · RT-R1-01

Due predicate aggiunte alle selezioni PNG, senza cambiare dichiarazioni, fasi native, resolver, testo o ordine dei comandi Common. In raccolta_azioni, il target scoperto del primo PG non produce una richiesta di difesa: finché manca la principale del secondo PG si restituisce waiting_player. Le principali PNG sono offerte soltanto dopo tutte le principali PG; un PNG che ha già dichiarato resta escluso. La funzione nativa combat_v2_action_declare passa atomicamente a raccolta_difese quando il numero di principali raggiunge expected_main_count. Solo da quel momento un target senza coverage abilita la selezione PNG per la difesa.

Fonti vive lette per A1: round phase/state CHECK; master_projection(uuid,uuid) MD5 f7064f267d9379af6d257ebc109f9228, che mappa raccolta_azioni→action e raccolta_difese→defense e calcola defense_due soltanto in defense; master_options(uuid,uuid,bigint) MD5 21035f617facadc874ceaaed8a9e4452, che usa tale proiezione. Corpo pertinente di combat_v2_action_declare letto readonly per la transizione dopo tutte le principali. Nessuna nuova esplorazione o autoreview del pacchetto; fix limitata al finding assegnato.

## Prove eseguite e risultato

Sola lettura del database vivo: firme, corpo e metadata di resolver/chiusura/premi; vincoli event/status, capability e closure_steps; native lifecycle; guardie di arena/enroll; campi e vincoli Board. Dati PG e testi role non copiati. Baseline e hash nativi nel manifest.

Statica: pglast con parser PostgreSQL, 25 statement top-level PASS; 10 ancore uniche di estrazione dei due core PASS. SQL dei DO con hash/ancore interrompe l'installazione su drift. Non equivale alla compilazione PL/pgSQL contro gli schemi installati: il parser locale non risolve i rowtype privati. Nessun ambiente ricreato, gameplay locale, provider, apply/deploy o modifica di dati effettuata. Guard check clean.

## Rischi o regressioni da verificare

Controverifica indipendente A1 ancora richiesta, con il resto dell’aggregata congelato: ordine installazione con nuovo delta outcome, body compilation reale, pin post-COMBAT dell'enroll, callback della UI dopo delivery, barrier shared-scene e permessi reali. Il collaudo funzionale resta sul sito, tramite nuova sessione protetta autorizzata: incipit → scelte → almeno due round → terminale incontro → fase narrativa → secondo incontro, ramo pacifico, replay e chiusura. Le nuove funzionalità non sono dichiarate live o collaudate.

Recupero conservativo: fermare nuovi dispatch/ammissioni prima di una rimozione di funzioni; conservare ricevute, report, snapshot, claims, outbox e cap terminali. Non togliere gli hook di protezione mentre ci sono incontri Generic attivi. mode off blocca i tick ordinari: terminare la prova autorizzata prima del gate off oppure consegnarla sospesa; non alterare dati per forzare una chiusura.

## Passaggio richiesto al PM

Integrare con le candidate congelate BOARD/PANEL/SOURCES/DISPATCH e delta outcome, verificare indipendentemente il pacchetto e il raccordo HTTP/UI, quindi rilascio nominato nel mandato. Nessun apply DB da questo incarico. Mantiene invariati Esame, ordinary, Clan, canary e Regia umana salvo il solo hook transazionale Generic dopo la baseline COMBAT verificata.
