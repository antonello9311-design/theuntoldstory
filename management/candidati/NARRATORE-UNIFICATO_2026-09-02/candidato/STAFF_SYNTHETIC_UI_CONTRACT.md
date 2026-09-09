# Contratto UI congelato · STAFF-SYNTHETIC-UI-001

Approvato dal PM per implementazione candidata nel mandato di Antonello. Le RPC qui descritte non sono ancora rilasciate.

Fonte: management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/STAFF_SYNTHETIC_CONTRACT.md
SHA-256: e65a2be0bab1ae7b23971479aad3ab51e50655f0788f12156e8b5917cde8a9b6
Estratto letterale §5.1; contratto e baseline originali immutabili per gli owner paralleli.

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

