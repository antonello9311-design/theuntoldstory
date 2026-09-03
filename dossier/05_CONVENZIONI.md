# 05 · CONVENZIONI — come si lavora senza rompere niente

> Questa pagina è il manuale operativo. Sono tutte cose imparate sbagliando: ogni riga qui ha già fatto perdere tempo almeno una volta.

---

## 1. Il metodo di lavoro

**Si chiede prima.** Nessuna modifica al codice applicativo o al database senza approvazione. Quando il cambiamento è sostanziale, si mostra il piano e si aspetta.

**Non si cancella.** Niente file eliminati, comandi distruttivi, reset, force-push, riscritture della storia o modifiche alla configurazione globale. Commit e push sono ammessi soltanto per i file pronti e verificati del task, dopo riconciliazione remota e secondo il gate di pubblicazione; mai includere file estranei. Per disattivare qualcosa si usa `is_active = false`, non `DELETE`. **Unica deroga dichiarata e approvata:** lo svuotamento dei luoghi con `is_test = true` (§16).

**Una chat per file.** Due conversazioni aperte insieme non si accorgono l'una dell'altra: ognuna restituisce il file **intero**, e chi carica per secondo cancella il lavoro del primo. La regola e le eccezioni stanno in **§14**.

**La copia locale non è una fonte.** Prima di modificare una pagina si prende il file vero dal disco di Antonello (`~/Downloads`, via bridge) e si fa il diff. §14 punto 3.

**Si segnala ciò che si è corretto d'iniziativa** — e vale in entrambe le direzioni: un vincolo **aggiunto** va elencato perché Antonello lo verifichi, ma anche un vincolo **allentato**, che è più pericoloso perché non rompe niente subito.

**Una domanda senza risposta non è una decisione presa.** Se una proposta non ha ricevuto un sì, resta proposta.

**Si scrive in italiano.** Documenti, regole, testi di gioco, nomi delle tecniche, risposte in chat.

**Non si abbinano nomi** a divisioni, rami o gradi se non è espressamente richiesto.

**Segreti:** mai leggere o stampare `.env`, chiavi, token, credenziali, dump. **La `ANTHROPIC_API_KEY` non va mai in chat né nel codice**: la imposta Antonello come secret di Supabase. Registrazione, login e password sono compito suo.

**Web:** niente `curl`/`wget`/fetch programmatici. Solo WebFetch/WebSearch o gli strumenti Chrome, e in Chrome **solo la tab che Antonello ha già aperto**.

**Copyright:** dal sito di riferimento si prendono solo idee meccaniche, mai testo. Claude non crea né riproduce simboli o immagini protette.

---

## 2. Una cosa a database esiste solo se si vede dal pannello

*(prassi adottata il 29/07/2026)*

**Ogni volta che si aggiunge una categoria, un tipo o un campo al database, nella stessa sessione si aggiunge la parte corrispondente in `admin.html`.** Non è una rifinitura da fare dopo: una riga che Antonello non può né cercare né correggere dal pannello, per lui non esiste — e la scopre nel momento peggiore, quando serve.

È successo due volte nello stesso giorno. Le 35 righe `macro='cercoterio'` sono entrate a database mentre l'elenco tecniche aveva solo tre linguette — Clan, Generiche, Abilità — quindi erano invisibili. E `req_stat2` è nata senza il suo campo nel modulo, quindi valorizzabile solo da SQL. Entrambe hanno richiesto un secondo giro.

La lista di controllo, quando si tocca il database:

- **Nuovo valore in un `CHECK`** (una macro, un tipo di emblema, un tipo di premio) → la **linguetta** o la **voce di menù** che lo mostra, l'etichetta col conteggio, e il testo di «sezione vuota».
- **Nuova colonna che lo staff deve poter scrivere** → il **campo nel modulo**, e il ciclo completo nei quattro punti: creazione, caricamento in modifica, salvataggio, reset del modulo. Un campo che si salva ma non si ricarica cancella il valore alla prima modifica.
- **Nuova colonna che cambia il senso di una riga** → l'**anteprima nell'elenco**, perché si veda senza aprire il modulo. Il 02/08 `uso` e `difensiva` sono nate con l'anteprima: una riga non classificata si legge «**uso da classificare**» in rosso.
- **Nuova colonna di `characters` non scrivibile dal giocatore** → va pinnata in `characters_guard` (§7).
- **Nuovo tipo di emblema** → la voce in `EMB_EXTRA`.
- **Nuovo automatismo che scatta su un'azione dello staff** → una riga nel pannello che lo dica. Il 02/08 il trigger che concede le otto basi d'Accademia alla promozione a Genin è entrato senza che `admin.html` avvisasse: chi promuove non sa che sta anche consegnando otto tecniche **e un pool di punti caratteristica**.
- **Nuova riga in una tabella che ha un gemello altrove** → si scrive in **entrambe**. Il 02/08 due sensei nuovi, **Nozomi** e **Rentaro**, sono entrati in `ai_agents` e non in `academy_sensei`: conducono lezioni vere, ma la loro `persona` esiste in un posto solo.
- **Nuovo tipo di messaggio in chat** → lo **stile** che lo distingue. Il 02/08 `messages.kind='sistema'` è entrato per le righe del motore: senza `.msg-scontro` in `land.html` sembrerebbero parlato di un personaggio. ⚠️ `.msg-sys` era già presa dai «Messaggi dal sito».

Lo stesso vale per la **scheda**, quando la novità riguarda il giocatore: un dato che il personaggio possiede ma che in scheda non compare, per il giocatore non esiste.

**E vale anche per i permessi, non solo per i dati.** Se una funzione decide chi può fare una cosa, la pagina deve rispecchiare quella decisione: mostrare a tutti un modulo che il server rifiuterà alla maggioranza non è prudenza, è una porta dipinta sul muro.

Vale anche al contrario: se una sezione del pannello promette qualcosa che a database non c'è, si dice subito invece di lasciarla come vetrina. **E se il Tavolo di Aiuto racconta una regola, quella regola deve esistere:** il 02/08 due voci di `help_kb` promettevano «+50 punti a ogni promozione» e soglie sfalsate di un grado, e una terza promette ancora un tetto di 65 danni che nessuna funzione impone.

---

## 3. La regola d'oro del regolamento

**A ogni cambiamento di regole o di sistema si allineano sempre insieme `REGOLE.md` e `regole.html`.** Non uno solo dei due.

- Il **changelog numerato esiste solo in `REGOLE.md`**, in fondo. `regole.html` non ha la tabella del changelog. Ultima riga scritta: **51** *(«Chi non eredita un cognome se lo sceglie», 08/08/2026)*. La prossima libera è la **52**. ⚠️ Se il numero qui non torna, la fonte è il fondo di `REGOLE.md`, non questa pagina.
- ⚠️ **Le righe si scrivono in fila, e va verificato che lo siano.** Il 02/08 la 42 è finita **fra la 40 e la 41**, perché due chat hanno scritto lo stesso file: la 41 arrivava da una conversazione parallela sull'Accademia. Dopo aver aggiunto una riga, un `grep -n "^| 4[0-9] | "` di controllo costa un secondo.
- Prima di modificare `regole.html`, farne un backup in `/tmp/`.
- Dopo la modifica, **verificare il bilanciamento dei tag** (`p`, `ul`, `li`, `div`, `table`, `section`, e anche `tr`/`td`/`th` se si è toccata una tabella): un tag scompensato rompe silenziosamente il rendering.
- Nel patch di `regole.html` le entità HTML vanno scritte come **UTF-8 letterale** (`—`, `·`, `è`, `§`), non come entità nominate.
- **`project_write` riscrive il documento intero**, non sa applicare una modifica parziale. Per toccare due paragrafi di `REGOLE.md` (100 KB) conviene farselo passare da Antonello come file e lavorarlo in locale con `grep` + Python: ridigitare l'intero regolamento rischia di corrompere in silenzio un paragrafo lontano.
- **Una regola cambiata a database non è una regola finché non è scritta.** Il 02/08 il trigger sulla promozione è entrato in produzione la sera e il regolamento l'ha registrata poco dopo: in mezzo, per qualche ora, `REGOLE.md` §5.2 diceva una cosa che il server non faceva più.
- **E una regola scritta non è una regola finché qualcuno non la esegue.** §8.3 prometteva «+50 punti caratteristica a ogni promozione» **dal 17/07**, e nessuna riga di codice li ha mai concessi. È stato scoperto il 02/08, costruendo altro. **Quando si legge una promessa nel regolamento, vale la pena chiedersi chi la mantiene.**

### ⚠️ Quando due documenti del dossier si contraddicono, decide la fonte viva

*(lezione del 02/08/2026, notte)*

Chiudendo una sessione ho ricopiato da `01` e `04` che il **changelog 39 era da scrivere**, mentre `05` — salvato più tardi lo stesso giorno — lo dava già per fatto. Il dossier si aggiorna a pezzi, da chat diverse, e **la data di salvataggio non è una gerarchia**: un file salvato dopo può contenere un paragrafo copiato da prima.

La risposta non si sceglie fra i due documenti: **si guarda la fonte viva.** Per il regolamento è `regole.html` sul sito. Per i dati è il database. Per l'HTML è il file preso dal disco. Nello stesso controllo è emerso che anche i nomi della scala del Richiamo erano già stati corretti («Richiamo · 1…5»), mentre `04` li elencava ancora fra i lavori aperti.

**Prima di ricopiare un difetto da una fotografia vecchia, si verifica che sia ancora un difetto.**

---

## 4. Vincoli del database — da rispettare alla lettera

```
clan_tech_attivazione_chk
  CHECK (attivazione IS NULL OR attivazione = ANY (ARRAY['istantanea','sigilli']))

clan_tech_gittata_chk
  CHECK (gittata IS NULL OR gittata = ANY (ARRAY['contatto','corta','media','lunga']))

clan_tech_uso_chk                        ← dal 02/08, su clan_techniques E su jutsu
  CHECK (uso IS NULL OR uso = ANY (ARRAY['principale','rapida','difesa','passiva','fuori_scontro']))

clan_techniques_consumption_type_check
  CHECK (consumption_type = ANY (ARRAY['ad_utilizzo','per_turno','passiva']))

clan_techniques_macro_chk
  CHECK (macro = ANY (ARRAY['clan','generica','abilita','evocazione','cercoterio']))

clan_tech_req_elements_mode_chk
  CHECK (req_elements_mode IS NULL OR req_elements_mode IN ('uno','tutti'))

messages_kind_chk                        ← esteso il 02/08 con 'sistema'
  CHECK (kind = ANY (ARRAY['say','roll','whisper','item','combat','sensei','cura','sistema']))

character_perks_tipo_check               ← esteso il 02/08 con 'punti_caratteristica'

character_abilities_state_check
  CHECK (state = ANY (ARRAY['in_addestramento','attiva']))

character_abilities_character_id_technique_id_key
  UNIQUE (character_id, technique_id)

characters_cercoterio_check
  CHECK (cercoterio IS NULL OR cercoterio = ANY (ARRAY['Shukaku','Matatabi','Isobu',
         'Son Gokū','Kokuō','Saiken','Chōmei','Gyūki','Kurama']))

characters_sigillo_check      solo con cercoterio valorizzato: 'Solido'|'Ordinario'|'Difettoso'
characters_clan_o_cercoterio  o il clan familiare, o la bestia: mai entrambi
characters_cercoterio_unico   indice unico parziale: una sola Forza Portante per bestia

emblems_kind_check
  CHECK (kind = ANY (ARRAY['village','clan','rank','element','corp','corpspec',
         'corpgrade','bijuu','evofam']))

combat_sessions — un solo scontro aperto per luogo (indice unico parziale, dal 02/08)

academy_lesson_script_pkey        PRIMARY KEY (lesson_id, step, village)
academy_lesson_script_semantic_frame_chk
  semantic_frame è NULL oppure un oggetto con schema_version, frame_id e action;
  con continuity_key richiede phase, substitute oggetto e substitute.stable_identity non vuota
character_jutsu_user_id_jutsu_id_key  UNIQUE (user_id, jutsu_id)
lesson_grants_pkey                PRIMARY KEY (lesson_id, jutsu_id)
emblems_pkey                      PRIMARY KEY (kind, name) — NON esiste una colonna `code`
```

**Convenzione:** le tecniche passive (`consumption_type='passiva'`) usano `attivazione='istantanea'`. Nessuna riga usa `attivazione IS NULL`. Non esistono valori `'sguardo'` o `'passiva'` per `attivazione`: il vincolo li rifiuta.

**Etichette di taglia delle evocazioni**, obbligatorie: `baby` → `piccola` → `media` → `grande` → `leggendaria`. Il vincolo rifiuta `minore`/`intermedia`/`superiore`.

**`clan_techniques` non ha unicità sul nome:** un catalogo rieseguito due volte si duplica in silenzio. Proteggere gli inserimenti massivi con una guardia `do $guard$ … raise exception … end $guard$;` in testa.

**«Senza clan» a database è la stringa `'Nessuno'`, non `NULL` e non la stringa vuota.** Ogni controllo che voglia dire «non ha un clan» deve scrivere `coalesce(nullif(btrim(clan),''),'Nessuno') = 'Nessuno'`.

**Gli elementi di un personaggio sono quattro sorgenti, non una.** L'elemento base è `characters.element`, la **seconda natura è la colonna `characters.element2`** (gratuita al Jonin), gli elementi dell'innata di clan stanno in `clans.elementi_innati`, e il premio «Le cinque nature» vive in `character_perks`. La funzione **`character_elementi(uuid)` è la sola fonte di verità**.

**I riferimenti a un emblema dentro un JSON non sono chiavi esterne.** `corporations.gradi` nomina gli emblemi come stringhe `kind:name`: **nessun vincolo controlla che la riga esista** in `emblems`.

**I trigger su `characters` sono sei, e uno concede tecniche.** Oltre alle guardie (`characters_guard`, `characters_cercoterio_guard`, `characters_check_name`, `characters_init_pools`, `characters_insert_guard`) dal 02/08 c'è **`trg_characters_grant_academy`**, `AFTER UPDATE OF rank`: quando il grado passa da Deshi a Genin o oltre, inserisce in `character_jutsu` tutte le basi d'Accademia attive con `source='promozione'` **e concede il pool di punti caratteristica del gradino**. Chi scrive un `UPDATE` massivo sui gradi deve sapere che non sta cambiando solo una colonna.

**`characters.pool_concesso` è un intero cumulato, non un booleano.** Tiene quanti punti caratteristica sono già stati dati a quel personaggio (60 alla creazione, 90 dopo la promozione a Genin, e via così). Serve a impedire che retrocedere e ripromuovere coltivi punti all'infinito. **Non azzerarlo mai.**

---

### character_perks.grado_tecnica — anche i gradini di carriera (dal 29/08)

Il CHECK ammette `D|C|B|A|S` **e** `Genin|Chunin|Jonin|Jonin Speciale|Kage / Sannin`:
per il premio `punti_caratteristica` la colonna registra il GRADINO acquistato,
e «Hai già questo premio» vale per gradino, non per tipo. I +15 punti li concede
solo il trigger `trg_perk_punti_caratteristica`.

### master_v2_sessions — tipo, missione e tipologia (dal 27/08)

```
tipo        → solo 'duello' | 'quest'
quest_kind  → NULL | 'one_shot' | 'trama'
missione_chk: duello → né missione né tipologia;
              quest  → missione collegata OPPURE quest_kind, mai entrambe.
```

`master_v2_session_open` ha 6 argomenti (l'ultimo è `p_quest_kind`, default
NULL) e `master_v2_encounter_open` ne ha 6 (l'ultimo è `p_positions` jsonb:
`{character_id: metri}`, più il campo `pos` dentro `p_png_specs`; il server
valida 0–60 a passi di 5, default 0). Le firme a 5 argomenti sono state
DROPpate il 27/08: **land.html e database vanno rilasciati insieme**.

## 5. Nomi di colonna che ingannano

Sono errori già commessi. Vale la pena rileggerli prima di scrivere una query.

| Si tende a scrivere | La colonna vera è |
|---|---|
| `clan_techniques.descr` | **`description`** |
| `missions.rank` | **non esiste** |
| `locations.village` | **non esiste** (c'è `region`) |
| `academy_lessons.ord` | **`ordinal`** |
| `emblems.code` | **non esiste** (la chiave è `kind` + `name`) |
| `characters.nome` | **`name`** — e il grado è **`rank`**, il villaggio **`village`** |
| `combat_sessions.stato` | **`state`** |
| `jutsu.name` | **`name_it`** (la tabella `jutsu` ha un vocabolario tutto suo) |

⚠️ **Su `clan_techniques` ci sono due colonne di distanza e due di classificazione, e servono a cose diverse:**

| Colonna | Che cos'è |
|---|---|
| **`gittata`** | elenco chiuso — `contatto`/`corta`/`media`/`lunga`. **È quella che usa il motore.** |
| `portata` | testo vecchio, «Corto», «Medio», «Sé stesso». Informativa, non si legge dal codice. |
| **`uso`** | elenco chiuso di cinque valori. **È quella che usa il motore.** |
| `tipo_azione` | testo libero, 74 valori scritti a mano. Informativa. |
| **`difensiva`** | booleano: se la tecnica può comparire nel **menù della difesa**. |

**Le basi d'Accademia non stanno in `clan_techniques`:** stanno nella tabella **`jutsu`**, che dal 02/08 ha anch'essa `uso`, `difensiva` e `gittata`. Il menù della difesa pesca da tutte e due le tabelle.

---

## 6. Colonne delle tabelle più usate

**`clan_techniques`** — `id`, `clan`, `name`, `level`, `category`, `description`, `requirements`, `consumption_type`, `chakra_cost`, `is_active`, `sort`, `created_at`, `grado`, `portata`, `bersaglio`, `tipo_azione`, `durata`, `ricarica`, `danno_effetto`, `xp_cost`, `trainings_required`, `req_grade`, `req_stat`, `req_stat_value`, `req_stat2`, `req_stat2_value`, `danno_base`, `is_innata`, `macro`, `req_elements`, `req_elements_mode`, `potenza`, `disciplina`, **`gittata`**, `attivazione`, `req_corp`, `req_ramo`, `is_leggendaria`, `gruppo_esclusivo`, `ramo_esclusivo`, `req_perk`, `req_cercoterio`, `req_tecnica`, `req_famiglia`, `req_taglia`, **`uso`**, **`difensiva`**

**`characters`** — oltre alle caratteristiche e ai campi anagrafici: `name`, `rank`, `village`, `element` (elemento base), **`element2`** (seconda natura, dal Jonin), `cercoterio`, `sigillo`, **`pool_concesso`** (intero cumulato, §4). **La Sintonia non è una colonna nuova:** è `kekkei_genkai`, che per una Forza Portante cambia solo etichetta.

**`messages`** — `id`, `location_id`, `character_id`, `author_name`, `body`, `created_at`, **`kind`**, `sender_user`, `recipient_user`, `recipient_name`, `dice_sides`, `dice_result`, `companion_id`, `companion_body`. Valori di `kind`: `say` (azione in scena), `roll`, `whisper` (sussurro, mai negli snapshot), `item`, `combat`, `sensei` (l'IA d'Accademia, con `character_id` nullo), `cura`, **`sistema`** (le righe del motore di combattimento, dal 02/08). ⚠️ Il `body` è **esattamente quello che il giocatore ha battuto**, virgolette tipografiche comprese: la normalizzazione avviene in visualizzazione (§11).

**Le cinque tabelle del motore** (dal 02/08) — **`combat_sessions`** (`location_id`, `kind`, `round`, `fase`, `turno_di`, `state`, `distanza_ingaggio`), **`combat_participants`** (iniziativa, **posizione in metri**, cosa ha speso nel round, se è fuori), **`combat_pending`** (il colpo dichiarato e non ancora risolto), **`character_active`** (cosa è acceso: tecnica, livello, costo per round), **`combat_effects`** (pronta per la fase 2, ancora vuota). RLS in lettura, nessuna scrittura diretta: si passa dalle funzioni.

**`corporations`** — `key`, `nome`, `scope`, `is_secret`, `descrizione`, `requisiti`, `sort`, **`statuto`**, **`gradi`**.

**`character_perks`** — `id`, `character_id`, `tipo`, `dettaglio`, `costo`, `granted_by`, `created_at`, `grado_tecnica`. ⚠️ In lettura è visibile **solo al proprietario e allo staff**. Dal 02/08 `tipo` accetta anche `punti_caratteristica`.

**`character_abilities`** — `id`, `character_id`, `technique_id`, `state`, `sessions_done`, `trained_by`, `approved_by`, `started_at`, `activated_at`

**`character_companions`** — `id`, `character_id`, `kind` (`marionetta`/`cane_ninja`/`evocazione`), `grado` (la taglia), `name`, `avatar_url`, `descr`, `famiglia`, `is_active`, `created_at`.

**`premio_richieste`** — `id`, `character_id`, `tipo`, `grado_tecnica`, `dettaglio`, `costo`, `status`, `nota_staff`, `decided_by`, `decided_at`, `created_at`

**`jutsu`** — `id`, **`name_it`**, `name_romaji`, `origin`, `category`, `nature`, `rank`, `power`, `requirements`, `chakra_cost`, `action_type`, `atk_natural`, `atk_discipline`, `defense_hint`, `damage_base`, `effect`, `limits`, `is_active`, `sort`, `created_at`, `kind`, **`uso`**, **`difensiva`**, **`gittata`**. Nove righe, **otto attive**: *Camminata sulle superfici* è disattivata.

**`character_jutsu`** — `id`, `user_id`, `jutsu_id`, `source`, `learned_at`. ⚠️ La chiave è **`user_id`, non `character_id`**. Valori di `source`: `academy` e **`promozione`**.

**`academy_class_sessions`** — `id`, `location_id`, `village`, `lesson_id`, `lesson_code`, `lesson_title`, `sensei_name`, `total_steps`, `started_by`, `starter_name`, `state`, `step`, `entry_at`, `created_at`, `closed_at`, `close_reason`, `step_at`, `ai_fired_at`, `sensei_agent_id`, `force_next`. Una lezione andata a buon fine ha `close_reason='done'` e `step = total_steps`.
**`academy_class_participants`** — `session_id`, `user_id`, `character_id`, `character_name`, `kind`, **`reward`** (`'ok'` quando la ricompensa è stata assegnata), `enrolled_at`.
**`academy_lesson_script`** — `lesson_id`, `step`, `body`, `village`,
**`semantic_frame`** (`jsonb` nullable). Il frame descrive soltanto i passi
meccanici inventariati e **non duplica `jutsu.action_type`**, che va letto da
`lesson_grants -> jutsu`. Se una dimostrazione attraversa più passi, preparazione
ed esecuzione condividono `continuity_key` e una
`substitute.stable_identity` stabile; il confronto deve verificare entrambe.
**`lesson_grants`** — `lesson_id`, `jutsu_id`. Sei righe su otto jutsu: *Occultamento* e *Liberazione dalle corde* arrivano solo con la promozione.

**Tipi di emblema** presenti, tutti con immagine: `bijuu` (9), `clan` (9), `corp` (3), `corpgrade` (4), `corpspec` (6), `element` (5), **`evofam` (6)**, `rank` (8), `village` (2). Totale **52**.

---

## 7. Convenzioni SQL

**Cambiare la firma di una funzione richiede `DROP` + `CREATE`**, non un `CREATE OR REPLACE`. Se la funzione è chiamata dal frontend, la nuova firma va rilasciata **insieme** alla pagina aggiornata.

**I default dei parametri fanno parte della firma.** Prima di riscrivere una funzione, leggerne l'intestazione vera: `split_part(pg_get_functiondef(oid), E'\n', 1)`.

**Anche la volatilità fa parte della definizione:** una funzione `stable` riscritta senza la parola `stable` torna `volatile` in silenzio.

**Per una modifica piccola a una funzione lunga, non la si ridigita:** si prende `pg_get_functiondef`, si fa `replace` sul frammento e si `execute` il risultato, verificando prima che il frammento compaia una volta sola.

**Apostrofi italiani nelle stringhe:** usare il dollar-quoting (`$$…$$`).

**Provare prima di applicare:** `begin; … rollback;` con `request.jwt.claims` impostato per simulare l'utente. ⚠️ **Il `rollback` va scritto davvero:** un blocco `do $$ … $$;` mandato da solo si autocommitta.

**Un trigger si prova come si prova una funzione:** dentro `begin; … rollback;`, creandolo, provocando l'evento su una riga vera e leggendo l'effetto prima di annullare tutto.

**Flag transazionali:** `app.allow_exp_delta`, `app.allow_vita_delta`, `app.allow_chakra_delta`, `app.allow_academy`, **`app.allow_points_delta`** sono GUC locali alla transazione. ⚠️ Di norma **restano impostati per tutta la transazione**, cioè un permesso aperto una volta vale per ogni scrittura successiva: `app.allow_points_delta` dal 02/08 **si richiude dopo l'uso**, perché il pool va concesso una volta sola. Quando si aggiunge un flag nuovo, decidere esplicitamente quale dei due comportamenti serve.

### 🔒 La verifica obbligatoria di fine migrazione — RLS e privilegi

*(convenzione adottata il 06/08/2026, dopo che lo stesso difetto è comparso tre volte)*

**Una tabella nuova nello schema `public` nasce aperta a chiunque.** Supabase applica dei default privileges che concedono ad `anon` e `authenticated` **tutti** i privilegi — `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, `TRIGGER`, `REFERENCES` — e RLS parte **disattivata**. Chi crea la tabella e non revoca lascia una porta aperta senza accorgersene: non serve un errore, basta non fare niente.

**Quindi ogni migrazione che crea una tabella si chiude con due righe e una verifica:**

```sql
alter table public.<nuova> enable row level security;
revoke all privileges on public.<nuova> from public, anon, authenticated;
```

⚠️ **La revoca va fatta anche a `PUBLIC`**, non solo ai due ruoli: è da lì che ereditano.
⚠️ **Se la tabella deve restare leggibile all'automazione**, il `grant` a `service_role` va dato **esplicitamente**: le revoche da `PUBLIC` tolgono anche a lui il privilegio ereditato, e le Edge Function smettono di funzionare al primo tick.

**E la verifica si fa sul catalogo, non sulla tabella appena creata.** Controllare solo quella che si è appena scritta è come rileggere la propria frase: il difetto che sfugge è sempre quello di un'altra migrazione. Le due query da eseguire alla fine di ogni migrazione sono queste, e **devono restituire zero righe**:

```sql
-- tabelle pubbliche senza RLS
select tablename from pg_tables
 where schemaname = 'public' and not rowsecurity;

-- tabelle pubbliche raggiungibili dal browser
select t.tablename, string_agg(r || ':' || p, ', ') as privilegi
  from pg_tables t
  cross join unnest(array['anon','authenticated']) r
  cross join unnest(array['SELECT','INSERT','UPDATE','DELETE','TRUNCATE']) p
 where t.schemaname = 'public'
   and has_table_privilege(r, 'public.' || t.tablename, p)
 group by t.tablename;
```

**Perché esiste questa regola.** Il 05/08 e il 06/08 sono state trovate **tre** tabelle nate così, tutte backup di migrazioni: `narratore_backup_20260805` e `pilot_backup_20260805` avevano **tutti e sette i privilegi** aperti ad `anon` — cioè un `TRUNCATE` da parte di chiunque, senza login. Nessuna conteneva credenziali, ma contenevano il **sorgente delle funzioni del motore**: `_combat_risolvi`, `_combat_dice`, `combat_dichiara_attacco`. In un gioco dove il server comanda e il giocatore non deve conoscere le soglie, è un problema di equità prima ancora che di sicurezza.

Le tabelle di backup sono le più esposte proprio perché sembrano innocue: si creano di fretta, «tanto è solo una copia», e restano.

### 🔒 RLS attiva non vuol dire tabella chiusa

*(convenzione adottata il 07/08/2026, dopo `SECURITY-NARRATORE-BACKUP-001`)*

**Le funzioni e le tabelle non si chiudono con lo stesso gesto, e confonderle costa una porta aperta.**

| | Le **funzioni** | Le **tabelle** |
|---|---|---|
| Come nascono | **chiuse**, dal 07/08 (`sicurezza_default_privileges_funzioni_chiuse`) | **aperte**, ancora oggi |
| Cosa serve | un `GRANT EXECUTE` esplicito per aprirle | `enable row level security` **e** `revoke all` per chiuderle |
| Chi scavalca | nessuno: `EXECUTE` o c'è o non c'è | `service_role` e `postgres` hanno **`rolbypassrls = true`** |

**La regola: RLS attiva non equivale a tabella chiusa.** `service_role` scavalca la RLS per **attributo di ruolo**, non per policy — quindi RLS attiva con **zero policy** non lo ferma affatto, e una `GET /rest/v1/<tabella>` con la chiave di servizio restituisce tutte le righe. **Per ogni tabella interna o di backup si legge `relacl` e si prova l'accesso col ruolo effettivo**, senza fermarsi a `relrowsecurity`.

```sql
-- cosa dice davvero il catalogo su una tabella
select coalesce(array_to_string(relacl,' | '),'(nullo)') as acl,
       relrowsecurity, pg_get_userbyid(relowner)
  from pg_class where oid = 'public.<tabella>'::regclass;
```

E la prova che conta non è `has_table_privilege`, che dice cosa pensa il catalogo: è **assumere il ruolo** con `set local role <ruolo>` dentro un blocco `exception when insufficient_privilege`, altrimenti il primo errore aborta la transazione e nasconde i controlli successivi.

⚠️ **La seconda query di verifica qui sopra controlla solo `anon` e `authenticated`: va estesa a `service_role`.** È esattamente il buco che per sei giorni ha fatto passare `narratore_backup_20260805` per «chiusa» quando chiunque avesse la chiave di servizio poteva leggerne le quindici righe.

**Le tabelle nuove ereditano ancora privilegi nominali.** Letto su `pg_default_acl` il 07/08: nello schema `public`, **sia `postgres` sia `supabase_admin`** concedono `arwdDxtm` ad `anon`, `authenticated` e `service_role` su ogni tabella nuova, e `rwU` agli stessi tre sulle sequenze. **Il controllo di questo default è un lavoro aperto** (`04`), non una cosa già fatta: non si applica una revoca globale senza aver prima mappato RPC, Edge Function e accessi diretti.

⚠️ **E anche sulle funzioni la chiusura del 07/08 non è totale:** `postgres` non concede più a `anon` e `authenticated`, ma **`supabase_admin` sì**, ancora oggi. In pratica non morde, perché le migrazioni girano come `postgres` — ma una funzione creata da `supabase_admin` in `public` nascerebbe aperta.

### 🔒 `characters_guard` pinna colonna per colonna — e le trigger function girano come chi scrive

*(convenzione adottata il 07/08/2026, dopo `SECURITY-CHARACTERS-GUARD-002`)*

**Due cose distinte, imparate lo stesso giorno.**

#### 1 · Una trigger function non `SECURITY DEFINER` gira coi privilegi di chi scrive

`characters_guard()` è `SECURITY INVOKER`. Quando un giocatore aggiorna la propria riga, tutto ciò che la guardia chiama viene eseguito **come `authenticated`**. Il 07/08 la revoca da `PUBLIC` gli ha tolto `EXECUTE` su `public._grade_rank(text)`, che la guardia chiama nel ramo non-staff: risultato, **ogni giocatore che toccava la propria scheda riceveva «permission denied for function _grade_rank»**, per sei ore, senza che nessuna migrazione avesse toccato la scheda.

**How to apply:** prima di revocare un helper, cercare chi lo chiama **da dentro un trigger non-DEFINER**. Se lo fa, il ruolo che scrive ha bisogno di `EXECUTE`:

```sql
select p.proname, p.prosecdef
  from pg_proc p join pg_trigger t on t.tgfoid = p.oid
 where pg_get_functiondef(p.oid) ilike '%<helper>%' and not p.prosecdef;
```

⚠️ È l'unica deroga ammessa alla regola «mai un helper con underscore al client» (§0 di `gdr-sql`): **il client non lo chiama, lo attraversa**. La deroga si dichiara nella migrazione, non si dà per scontata. L'alternativa — rendere la guardia `SECURITY DEFINER` — cambierebbe il contesto di esecuzione di tutto il resto: più superficie, non meno.

#### 2 · Ogni colonna che non è del giocatore va pinnata a mano

La policy `characters_update_own` lascia al giocatore l'`UPDATE` della propria riga. **Ciò che lo ferma non è la policy, è la guardia**, che ripristina da `OLD` colonna per colonna. Una colonna che non compare in quell'elenco **passa**.

Il 07/08 ne sono state trovate **sette** mai pinnate: `pool_concesso`, `last_regen_at`, `is_test`, `corp_role`, `corp_spec`, `corp_since`, `corp_anon`. Le prime due erano sfruttabili — pool di punti coltivabile, recupero arbitrario.

**How to apply — la rassegna, e come si fa senza mancare pezzi.** Provare a scrivere OGNI colonna come il giocatore proprietario, in transazione, e guardare quali restano cambiate:

```sql
-- ⚠️ NIENTE filtro sul tipo di dato: la prima passata del 07/08 filtrava
-- numeri, testo e booleani e si perse corp_since e last_regen_at, che sono
-- timestamptz. Fu il PM ad accorgersene.
for r in select column_name, data_type from information_schema.columns
          where table_schema='public' and table_name='characters'
            and column_name not in ('id','user_id','created_at','updated_at')
            and is_generated='NEVER'
```

**La regola:** una colonna nuova di `characters` si aggiunge alla guardia **nella stessa migrazione** che la crea. Non è una rifinitura: una colonna aggiunta senza toccare la guardia è una falla, non una svista.

#### 3 · Le deroghe si fanno con un flag DEDICATO

Quando una colonna pinnata deve restare scrivibile a un percorso legittimo, si apre un GUC **suo**, non se ne riusa uno esistente.

`app.allow_vita_delta` è aperto da **undici** funzioni — `_combat_risolvi`, `_pilot_chiudi_interno`, `applica_recupero`, `characters_guard`, `pilot_prepara_ko`, `png_attacca_pg`, `post_combat`, `post_combat_png`, `post_heal`, `post_item_use`, `staff_ripristina`. Usarlo anche per `last_regen_at` avrebbe reso quella data scrivibile **ogni volta che qualcosa tocca i PV**. Da qui `app.allow_regen_at`, che apre solo `applica_recupero()`.

⚠️ **E il flag si richiude.** `applica_recupero()` apre `allow_regen_at` subito prima della propria `UPDATE` e lo chiude subito dopo. Gli altri due flag della stessa funzione **non lo fanno** e restano aperti per il resto della transazione: è preesistente, confinato alla singola richiesta, e registrato come **audit separato sul ciclo di vita di tutti i GUC `app.allow_*`**. Un flag nuovo, però, nasce con la chiusura.

⚠️ **La deroga a flag non è prudenza, a volte è obbligatoria:** `characters_grant_pool()` è un trigger **AFTER** che alla promozione fa una propria `UPDATE` su `characters`, e quella **rientra dalla guardia**. Senza `app.allow_points_delta` la promozione smetterebbe di aggiornare il cumulativo, in silenzio e senza errori.

### ⚠️ Tre trappole che hanno fatto perdere tempo il 02/08

1. **`now()` è costante dentro una transazione.** Righe scritte in sequenza da funzioni diverse ricevono tutte lo stesso `created_at`, e in chat escono nell'ordine sbagliato: «— Round 2 —» compariva prima della risoluzione del round 1. **Per ordinare eventi dentro una transazione si usa `clock_timestamp()`.**
2. **`array || 'testo'` è ambiguo.** Postgres lo legge come `array || array` e fallisce. **Si usa `array_append(col, 'testo')`.**
3. **`pg_get_functiondef` fallisce sugli aggregati.** Ogni scansione su `pg_proc` va filtrata con `p.prokind = 'f'`.

**Revoca efficace:** `revoke … from public, anon, authenticated`.

**`characters_guard` pinna colonna per colonna.** Ogni colonna nuova di `characters` che non deve essere scrivibile dal giocatore va aggiunta esplicitamente alla guardia.

**Il regolamento non si piega al catalogo.** Se una migrazione scritta giorni prima contraddice `REGOLE.md`, la migrazione è vecchia.

**⚠️ Un copione di lezione non si tocca mentre una classe di quella lezione è aperta.** `academy_class_start` fotografa `total_steps` da `max(step)` del copione al momento dell'avvio e lo scrive nella sessione. Aggiungere un passo mentre qualcuno sta giocando significa che quella classe chiuderà sul vecchio ultimo passo — che intanto è diventato un altro testo — senza mai vedere quello nuovo. **La migrazione deve avere la guardia che rifiuta**, e si aspetta: il 06/08 notte l'aggiunta del settimo passo alla L2 è rimasta ferma un'ora, fino alla chiusura dell'ultima classe. Vale per qualunque colonna che una sessione «fotografa» all'apertura.

**Non si promuovono tecniche per soglia automatica.** La §7 di `migration_coerenza.sql` è marcata `[ANNULLATO IL 28/07/2026 — NON RIESEGUIRE]`.

### 🔴 La domanda da farsi su ogni funzione nuova: chi decide il numero?

*(lezione del 02/08/2026, pagata con una falla di sicurezza)*

`combat_dichiara_attacco` accettava un parametro `p_base` fino a **120, da qualunque client**. Chiunque sapesse chiamare la funzione poteva dichiarare il danno che voleva. **È esattamente il difetto che l'audit del 17/07 aveva chiuso in `post_combat`**, riaperto scrivendo il motore da zero — perché il parametro sembrava comodo per le prove.

La regola del progetto è una riga sola — *«l'IA racconta, il server comanda»* — e si traduce in una domanda operativa: **per ogni parametro numerico che una funzione accetta dal client, chi lo decide davvero?** Se la risposta è «il client», o si toglie il parametro, o lo si limita allo staff.

Il correttivo applicato: colpo a mano = 10, tecnica = il suo `danno_base`, e solo lo staff può fissare altro. **Prima di scrivere una funzione di combattimento nuova vale la pena rileggere `claude/audit_2026-07-17.md`.**

### 🔴 La domanda gemella, per i prompt: chi gli sta dando questo dato?

*(lezione del 06/08/2026, pagata con un segreto di scheda detto a un giocatore)*

Il prompt del sensei vietava di nominare l'elemento degli allievi da tre versioni, con tre righe diverse e maiuscole di rinforzo. Il 06/08 sera Katsuo ha comunque detto a Rei «Tu hai il Fuoco». Il dato gli arrivava in ogni lezione, e su un numero abbastanza grande di turni **un divieto scritto perde sempre**.

La correzione che ha tenuto non aggiunge una regola: **toglie il dato**. L'elemento entra nel contesto solo quando il materiale del passo mette in scena la carta da chakra; in tutte le altre lezioni il modello non ce l'ha e non può lasciarselo sfuggire.

Da qui la domanda da farsi su ogni prompt che tocca dati di gioco: **questa informazione gli serve adesso, in questo passo?** Se la risposta è no, non è materia da divieto, è materia da non consegnare. E quando il filtro dipende da una parola nel testo del copione — qui `foglio|fogli|carta da chakra` — **quella parola diventa un contratto**: va scritta accanto al filtro, perché un copione futuro che la usa per altro riapre il rubinetto senza che nessuno se ne accorga.

### Come si rilascia una Edge Function da qui, senza rompere il banco

1. Si porta il sorgente in locale con `device_stage_files` e si **confrontano i byte dichiarati con quelli arrivati** (§10).
2. Le modifiche si applicano con uno script Python e `assert s.count(old) == 1` per ogni sostituzione, mai a mano: il file è lungo e le stringhe si somigliano.
3. Si aggiorna `_prompt_core.js`, che tiene l'elenco dei **candidati in ordine di recenza**: se il file nuovo non è in testa, il banco continua a provare la versione vecchia e passa per il motivo sbagliato.
4. Si lancia il banco **sulla macchina di Antonello** con `device_bash` (`cd C:\theuntoldstory\claude && node banco_prova_sensei.js`), non nel container: lì potrebbe esistere una copia che sul suo disco non c'è.
5. Solo allora si pubblica, e si controlla il numero di versione nella risposta.
6. **`PROMPT_VERSION` cambia solo se cambia il prompt** — è la chiave con cui l'audit conta le ricorrenze — mentre `FUNCTION_VERSION` cambia a ogni build.

---

## 8. Convenzioni di contenuto

**Tutti i valori visibili in scheda o in una tecnica sono multipli di 5.** Vale per costi chakra, danni, soglie, punti caratteristica, allineamento. **L'esito di un tiro no**, e nemmeno i modificatori ai dadi, che seguono la scala dei margini 0/3/6/10.

**Le scale numeriche si prendono dal regolamento, mai inventate per comodità di esempio.** *(Ribadito il 02/08.)*

**I numeri di scheda sono privati e non si rivelano mai** — né in chat, né nei referti del motore, né nella voce narrante.

**I nomi delle tecniche sono in italiano.** Il romaji, dove serve, va nel campo apposito.

**Il grado E non fa danno.** Le tecniche accademiche stanno lì.

**Tecniche ninja vere e tecniche personali partono da grado D e grado minimo Genin.**

**«Personalizzazioni» non è un jutsu**: è lo slot in cui il giocatore mette il proprio jutsu di clan personale.

**I tag ✦ nelle missioni sono visibili solo allo staff.**

**Le sezioni «Note per lo sviluppo» non si pubblicano mai.**

**Terminologia:** «coprifronte», mai «fascia frontale». «Cercoteri», mai «bijū» nei testi di gioco. I nomi delle nove bestie si scrivono **con i macron**: Son Gokū, Kokuō, Chōmei, Gyūki.

**Elementi:** una tecnica che ne elenca più d'uno con «o» ne richiede **uno**; con «+» li richiede **tutti**. È `req_elements_mode`.

### Come si segna il parlato in chat

Il giocatore ha tre modi, tutti equivalenti: `"virgolette dritte"`, `«caporali»`, `<angolari>`. Diventano rosse (`.sp-say`). Gli `*asterischi*` fanno il corsivo (`.sp-act`), `[figura:nome]` inserisce una tavola. **Dal 02/08 valgono anche le virgolette curve `“…”`** di Word e LibreOffice, normalizzate prima del rendering (§11). Gli apostrofi curvi `’` **non si toccano**: stanno dentro le parole.

### I comandi del motore — sintassi decisa il 02/08, non ancora in linea

I comandi di combattimento stanno **tutti fra parentesi quadre**, dentro il testo dell'azione: `[bersaglio Aoi]` · `[sposta +10]` / `[sposta -10]` · `[schivata]` `[parata]` `[contrasto]` · `[guardia]` `[mira]` `[lancio]`. Il parser è `_combat_leggi_comandi(p_body)`, già a database e **non ancora agganciato a `post_message`**.

⚠️ **Due giocatori usano già `[Fine]`** di loro iniziativa per dire «ho finito il turno»: il parser la riconosce e non la scambia per un comando. Se in futuro si aggiunge un comando nuovo, si guarda prima cosa scrivono davvero i giocatori.

---

## 9. Immagini

Stile: **inchiostro e acquerello con contorni neri spessi**, non pittorico né semi-realistico. Il verde medico è **teal ~#1a7070**. «Sfondo trasparente» scritto nel prompt funziona.

Lezione operativa: **descrivere la geometria funziona, chiedere una correzione no**. Se il risultato non va, si riscrive il prompt intero.

Le immagini le genera e le carica Antonello.

**Non tutto ciò che manca è un buco.** I luoghi generici restano senza immagine **di proposito**.

**I riquadri dei ritratti sono in proporzione 3:4** (`.m-ava` 52×70, `.acad-portrait` 64×86), con l'immagine **contenuta** e appoggiata in alto: la via per risolvere alla radice è suggerire in guida un ritratto verticale.

---

## 10. Trappole dell'ambiente di lavoro

Sono limiti pratici degli strumenti, non del progetto.

- **Lo strumento `Edit` fallisce sulle righe HTML lunghe e concatenate.** In quei casi si usa Python con `assert s.count(old) == 1` prima di sostituire.
- **Ispezionare un file da shell non soddisfa la precondizione di lettura di `Edit`**: va letto con lo strumento `Read`.
- **`node --check <(sed …)` non funziona**: si estrae il blocco `<script>` in `/tmp/*.js`, lo si avvolge in `(async function(){…})();` e si controlla quel file.
- **`node -e "var CERC=…"` fallisce** sui blocchi dati: usare `eval('(' + src + ')')`.
- **Le stringhe nel sorgente non sempre sono scritte come si leggono.** Molti testi usano gli escape JavaScript (`abilità`): cercarli digitando la lettera accentata non trova niente.
- **Prima di aggiungere un nome in una pagina monolitica, cercarlo.** `admin.html` aveva già `loadAudit()`, `renderAudit()` e `#audit-list`, che sono il **registro dei movimenti dello staff** e non c'entrano nulla con l'audit dell'Accademia. Due cose con lo stesso nome nello stesso file non danno errore: danno confusione silenziosa, mesi dopo. Il pannello nuovo ha preso il prefisso `acc` (07/08).
- **Nel codice, i caratteri che si somigliano si scrivono come escape.** In una regex che distingue `'` da `’`, o `"` da `“`, si scrive `’` e `“`: a occhio nudo, in un file da 400 KB, quei due caratteri sono indistinguibili e una svista non dà errore, dà un comportamento sbagliato.
- Le pagine sono monolitiche: prima di toccarle si salva una copia in `/tmp/`, e alla fine si confrontano le dimensioni.
- **Per modificare una pagina o `REGOLE.md`, farsi passare il file da Antonello** invece di aprire la copia nel progetto: la copia è vecchia e `project_read` non sa restituirne un pezzo.
- **Il sorgente delle pagine non si legge da GitHub raw con `WebFetch`:** la conversione in markdown **scarta i blocchi `<script>`**, quindi il CSS arriva e il JavaScript no. Per vedere il codice serve il file vero.
- 🔴 **E quella lettura è anche troncata, quindi risponde «non c'è» a qualunque cosa: un risultato negativo da una lettura troncata non è un risultato.** L'08/08, cercando `acadErr` nel `land.html` appena pubblicato, la risposta è stata «la stringa *lezione da poco* non compare»: sembrava il rilascio andato storto. Il testo ricevuto si fermava **dentro il CSS**, migliaia di righe prima della funzione. Lo stesso vale per `REGOLE.md`, che si interrompe a §12.3 e non raggiunge mai il changelog in fondo.

  > **Prima di credere a un «non c'è», si rifà la ricerca con una stringa di controllo che esiste di sicuro anche nella versione vecchia.** Se manca pure quella, la lettura non è arrivata fin lì e il negativo non dice niente sul file. Nel caso dell'08/08 le stringhe di controllo erano `Operazione non riuscita` e `Qui non si tengono lezioni`: mancavano entrambe, e il falso allarme è morto lì.

  È parente della trappola del build verde qui sotto, e ha lo stesso esito: **dichiarare rotto ciò che funziona.** Quando la verifica remota non basta, la si passa ad Antonello dicendo esattamente dove guardare — non si conclude al posto suo.
- **Le skill non si modificano da qui:** i file in `~/.claude/skills/` sono una copia in sola lettura. Per aggiornarne una si prepara un `.skill` e si consegna con `SendUserFile`; se Antonello la salva non si può sapere, quindi si dice «consegnata», mai «salvata».

**Deroga esplicita ad `antigravity-protocol`.** Quella skill vieta al punto 1 di usare comandi shell per operare sui file. **Su questo repository quella direttiva non si applica**, perché `Edit` fallisce in modo sistematico sulle righe lunghe concatenate. Qui si usano `grep -n` per localizzare e Python con `assert` per sostituire. La deroga è scritta anche nella skill `gdr-pagine`; tutto il resto di `antigravity-protocol` resta valido.

---

### ⚠️ Il repo dice una cosa, il sito ne dice un'altra — 06/08

Caricati i tre file del gate del narratore, la pagina non cambiava. La tentazione era darne la colpa alla cache del browser, e Ctrl+F5 non risolveva niente.

**Il confronto che ha chiuso la diagnosi in un colpo solo:** leggere lo stesso file su `raw.githubusercontent.com/<utente>/<repo>/main/<file>` e sul dominio. Il primo mostrava la versione nuova, il secondo quella vecchia. Se i due divergono, **il problema non è nei file e non è nel browser**: è la pubblicazione.

La causa era il deploy di GitHub Pages fermo in `deployment_queued` per oltre dieci minuti, con `build` e `report-build-status` **verdi**. Un build verde non vuol dire sito aggiornato: la pubblicazione è un passo separato, ne gira uno per volta, e un deployment precedente rimasto appeso blocca tutti i successivi. Si sblocca cancellando i run rimasti aperti in *Actions*, controllando le regole di protezione dell'ambiente `github-pages`, e in ultima istanza rimettendo *Settings → Pages* su `None` e poi di nuovo su `main` / `(root)`.

⚠️ **E lo strumento con cui si controlla ha una cache sua**: le letture di una URL restano valide un quarto d'ora. Per rileggere davvero, va cambiata l'URL — basta aggiungere `?v=2`.

### ⚠️ Nei redirect di Supabase Auth il punto è un separatore — trovata l'08/08

Nella lista **Redirect URLs** i caratteri `.` **e** `/` contano tutti e due come separatori, e `*` copre **solo sequenze che non ne contengono**. Conseguenza che sorprende:

- `https://theuntoldstory.it/**` copre `entra.html` ✅
- `https://theuntoldstory.it/*` **non** lo copre ❌ — perché `entra.html` contiene un punto

Se l'URL non è coperto, Supabase **non dà errore**: ripiega sul Site URL. Il giocatore atterra sulla home e sembra che la patch non funzioni, mentre il codice è giusto. La documentazione raccomanda, in produzione, di elencare anche il **percorso esatto**: una riga in più che toglie ogni ambiguità.

⚠️ **Un redirect consentito è una precondizione, non un'assunzione.** Va verificato in dashboard *prima* di caricare la pagina che lo usa, altrimenti si debugga il codice sbagliato.

**Cercare una colonna nei corpi delle funzioni: il pattern va qualificato.** Per sapere se una colonna è davvero letta dal server si usa `pg_get_functiondef(oid) ~ ('\.'||colonna||'\M')`, che cattura `t.colonna`, `r.colonna`, `new.colonna`. Il pattern **non** qualificato trova anche le parole italiane dentro i messaggi di gioco: nell'audit dell'11/08 ha dichiarato «letta da quattro funzioni» la colonna `clan_techniques.bersaglio`, che **nessuna** funzione legge — le quattro contenevano `'bersaglio non valido'` nel messaggio d'errore. Stessa trappola su `portata` («fuori portata»), `grado`, `clan`, e la peggiore su `colpito` e `striscio`, che sono **anche prosa**: `'è colpito di striscio'` sta nei testi che il motore scrive in chat. Per un campo jsonb il pattern è `'>>''campo'''`, e i due si sommano quando il valore viaggia in un jsonb prima di finire in colonna, come `mod_slancio`. Poi si separano i **produttori** dai **lettori** — chi scrive non è chi dipende, e solo i lettori vincolano un ritiro — e si guarda **anche il client**, perché una colonna senza lettori server può averne uno in pagina: `colpito` non ha consumer server vivi fuori da Test Room e pilot, ma lo legge la card «Ultimo esito» di `admin.html`.

⚠️ **È parente della trappola della lettura troncata, e ha la stessa forma:** un elenco di nomi plausibili **sembra una diagnosi e non lo è**. Con il pattern ingenuo la mappa dei consumer di `striscio` diceva otto funzioni quando i lettori veri sono **due**, e avrebbe sovrastimato il costo di ritirare quella colonna. Quando si riporta il risultato di un censimento si dice **quale pattern si è usato**: un elenco senza il pattern accanto non è verificabile da chi legge dopo.

## 11. Provare in un browser vero, non a parte

*(prassi adottata il 02/08/2026, dopo un guasto arrivato in produzione)*

**Le funzioni di una pagina si provano dentro la pagina, non ricostruite altrove.** Estrarre un blocco di JavaScript e farlo girare in Node con le dipendenze riscritte a mano dà una risposta che sembra una verifica e non lo è: basta che la copia sia più tollerante dell'originale e il difetto passa. Il 02/08 la linguetta «Abilità» delle Evocazioni è arrivata online muta perché `esc()` riceveva un numero e moriva a metà rendering; la prova in Node non l'aveva visto, perché la `esc()` scritta per la prova convertiva a stringa da sola.

Il modo giusto costa poco: **Chromium senza finestra, la pagina vera aperta da file, e un finto client Supabase installato con `addInitScript`** prima che parta lo script della pagina.

- I banchi già pronti stanno in `claude/banco_prova_land.js`, `claude/banco_prova_scheda.js`, **`claude/banco_prova_scontro.js`** e `claude/sonda_esc.js`. Il primo argomento è il file da provare.
- **Un banco di prova è anche una specifica.** Il 02/08 sera `banco_prova_scheda.js` è servito a **ricostruire** la linguetta Compagno PNG persa in una collisione fra chat.
- **Un test che passa subito va messo alla prova al contrario:** eseguirlo sulla versione *precedente* alla modifica.
- **Quello che sta in uno scope chiuso non si spia dall'esterno.** `esc()` non è su `window`: per osservarla si strumenta il sorgente.
- **Per sapere se una modifica cambia ciò che si vede**, si rende la pagina prima e dopo e si confrontano i due DOM — **escludendo i tag `<script>`**.
- **Prima di dire che un difetto esiste, si misurano i confini veri della funzione che lo conterrebbe.**
- La pagina può reindirizzare prima di mostrarsi: il finto client deve rispondere di conseguenza.

### ⚠️ Una cosa che compare e sparisce si prova aprendo la pagina

*(lezione del 02/08/2026, trovata da Antonello in produzione)*

Il banner della Test Room compariva in **tutte** le chat. Il JavaScript lo nascondeva con l'attributo `hidden`, ma la regola CSS `display:flex` che gli era stata scritta **batte** `[hidden]`, che è solo una regola di default del browser. Sintassi a posto, tag bilanciati, `node --check` verde: mancava aprire la pagina.

**Per ogni elemento che ha uno stato «visibile / nascosto» serve la regola esplicita** — `.classe[hidden]{display:none}` — **e una prova che lo guardi**.

### ⚠️ Una prova SQL in transazione dice che il codice non esplode, non che il gioco funziona

*(lezione del 02/08/2026, pagata con sei difetti)*

Il motore di combattimento passava **tutte** le prove in `begin; … rollback;`. Poi mezz'ora di partita vera ha trovato: un danno base deciso dal client, righe fuori ordine, la distanza d'ingaggio buttata via, una funzione muta, un pannello con le informazioni sbagliate, un menù vuoto. Nessuno di questi era visibile da SQL, perché **l'SQL prova le funzioni una alla volta e il gioco le usa in sequenza, dentro un'interfaccia, con un giocatore che guarda**.

**Quando un sistema nuovo è pronto, la prova successiva non è un'altra query: è giocarci.**

### Il caso in cui la prova a parte va bene lo stesso

Quando la funzione è **pura** — entra una stringa, esce una stringa — e la si copia **verbatim dal file appena modificato**, provarla in Node è legittimo, purché si copino anche le sue dipendenze verbatim. È così che il 02/08 notte è stata verificata `fmtBody` con `normVirg`: sei testi presi dalla chat vera, l'output confrontato riga per riga, più `node --check` sul blocco `<script>`, i tag bilanciati e la differenza di dimensione col backup.

⚠️ Resta il fatto che **`banco_prova_land.js` non copre `fmtBody`**, che è il codice che ogni giocatore vede a ogni messaggio: aggiungerci qualche controllo è un lavoro aperto.

### Un blocco condiviso fra un file sorgente e una pagina si delimita, e si confronta carattere per carattere

*(lezione del 07/08/2026, dal pannello dell'audit)*

Quando le stesse funzioni devono vivere in un file sorgente — per essere caricate con `require()` e provate davvero — **e** dentro una pagina monolitica per girare in produzione, le due copie divergono al primo ritocco, e da quel momento il banco prova una cosa che nessuno esegue. Il modo che regge: delimitare il blocco in pagina con marcatori espliciti (`ACC-PANNELLO INIZIO` / `ACC-PANNELLO FINE`) e far confrontare al banco i due testi **carattere per carattere**, non il comportamento.

⚠️ **Il prezzo è che il blocco innestato non si può abbellire.** Resta al rientro della sorgente — a colonna 0 dentro lo `<script>` — con un commento in pagina che spiega perché. **Un rientro cosmetico rompe la garanzia** e riporta il banco a provare una copia: esattamente il difetto di `banco_prova_scontro.js`, che ricopia `renderCombat` invece di eseguirla.

### ⚠️ `innerText` restituisce il testo COME È RESO — e questo fa passare i controlli negativi per finta

*(lezione del 07/08/2026, trovata scrivendo la prova visiva del pannello dell'audit)*

Il CSS della pagina trasforma in maiuscolo i `summary` e i bottoni. Un controllo scritto come `innerText().indexOf('Nessuna classe bloccata') < 0` risultava **verde** anche quando quella frase c'era davvero: in pagina era resa `NESSUNA CLASSE BLOCCATA`, e la ricerca non la trovava. Il controllo non provava niente e lo diceva col colore giusto.

**Regola:** nelle prove in browser si confronta sempre in minuscolo da entrambe le parti, oppure si guarda l'`innerHTML`, che è il markup e non il rendering. Vale a maggior ragione per i controlli **negativi**, dove un confronto che non trova nulla è indistinguibile da un controllo che funziona.

### Il testo che arriva da fuori non è il testo che si è scritto

*(imparata il 02/08/2026, notte, da un giocatore vero)*

Chi scrive le azioni in **Word o LibreOffice** e poi le incolla si porta dietro le sostituzioni automatiche dell'editor: `"` diventa `“ ”` (U+201C/U+201D), `'` diventa `’` (U+2019), lo spazio a volte diventa insecabile (U+00A0). Sono caratteri **diversi** da quelli che escono dalla tastiera dentro il sito, e una regex che cerca `"` non li vede: il parlato di Jun restava nero mentre nei sussurri, digitati nel campo, funzionava.

**Quando un parser su testo scritto dagli utenti sembra funzionare «a volte»:** prima di guardare il codice, si guardano i **codepoint** di ciò che l'utente ha davvero scritto. Una query che conta i caratteri per `ascii(c)` chiude la diagnosi in un colpo.

⚠️ **Vale anche per le parentesi quadre dei comandi del motore**, quando il parser andrà in linea: un `[schivata]` incollato da un editor può non essere il `[schivata]` che il codice cerca.

**La correzione va nel rendering, non sul campo di scrittura.** Nel rendering copre anche quello che è già stato scritto, e non altera il `body` salvato — che deve restare ciò che il giocatore ha battuto. In `land.html` la funzione è `normVirg(s)`, chiamata come `esc(normVirg(s))` dentro `fmtBody`. La sostituzione è **uno-a-uno**, così la lunghezza del testo non cambia e il minimo di 500 caratteri resta esatto.

---

## 12. Cose da non toccare, mai

- **L'account `Riuji`**: è l'admin.
- **Le 14 classi CSS elencate nel report del 25/07**: sono costruite per concatenazione in JavaScript, e rinominarle rompe la pagina in silenzio.
- **`.msg-sys`**: è già presa dai «Messaggi dal sito». Le righe del motore usano `.msg-scontro`.
- **La struttura di `EMB_EXTRA`, `BIJUU`, `CORP_SPEC_OPTS` in `admin.html`**: si aggiungono voci, non si riorganizza.
- **La §7 di `migration_coerenza.sql`**: annullata, non rieseguire.
- **La protezione password compromesse di Supabase**: è a pagamento, il piano è quello gratuito, la scelta di saltarla è deliberata.
- **I ~139 warning dell'advisor** «authenticated can execute SECURITY DEFINER»: sono l'architettura del gioco.
- **`esc()` non tratta l'apostrofo allo stesso modo su tutte le pagine**: `land.html` sfugge anche `'`, `scheda.html` e `admin.html` no. Allinearle è un lavoro a sé.
- **L'apostrofo curvo `’` nel testo dei giocatori**: non si normalizza. Rappresenta altro, e nessuno apre un dialogo con l'apostrofo. *(Decisione del 02/08.)*
- **`characters.pool_concesso`**: non si azzera e non si «sistema» a mano. È l'unica difesa contro il retrocedi-e-ripromuovi.

---

## 13. Niente file nuovi datati — la regola contro la proliferazione

*(convenzione adottata il 29/07/2026)*

Il progetto ha accumulato **una ventina di documenti datati**. Ognuno è nato a fine di una sessione ed era vero solo quel giorno. Sono tutti marcati **⏸ SUPERATO** in `dossier/02_INDICE_DOCUMENTI.md`; nessuno è stato cancellato.

**Da qui in avanti, a fine sessione non si crea un file nuovo.** Si aggiornano i documenti vivi:

- **`dossier/01_STATO_ATTUALE.md`** si riscrive **sul posto**: è la fotografia del presente. I numeri si prendono dal database (skill `gdr-verifica`), non dalla memoria.
- **`dossier/03_CRONOLOGIA_DECISIONI.md`** riceve **una riga per ogni decisione presa** — non per ogni attività svolta.
- **`dossier/04_LAVORI_APERTI.md`** si allinea: le voci chiuse si tolgono, le nuove entrano nella priorità giusta.

E, quando è cambiato qualcosa che li riguarda: `00_LEGGIMI.md` (numeri d'insieme, changelog, stato della beta), `02_INDICE_DOCUMENTI.md` (se sono nati documenti), `05_CONVENZIONI.md` (se è emersa una trappola nuova), `06_ISTRUZIONI_PROGETTO.md` (se è cambiato qualcosa di strutturale — e in quel caso **si ricorda ad Antonello di ricopiare il testo** nel campo Istruzioni).

**L'unica eccezione** è una *specifica di design duratura*: può diventare un file in `claude/…`, con un nome **senza data**, registrato in `02_INDICE_DOCUMENTI.md`.

⚠️ **Il dossier lo aggiorna Claude, non Antonello.** Se una sessione si chiude senza toccarlo, quel lavoro non esiste per la sessione successiva.

La procedura completa, con le due liste finali, sta nella skill **`gdr-chiusura`**.

---

## 14. Due chat insieme — la regola contro le sovrascritture

*(convenzione adottata il 02/08/2026, e violata tre volte lo stesso giorno)*

Il caricamento ora può essere eseguito direttamente dall'agente, ma GitHub non fonde automaticamente due versioni concorrenti dello stesso **file intero**. Due chat aperte insieme sullo stesso file non si accorgono l'una dell'altra: resta obbligatorio un solo owner e il confronto con la testa remota prima del push.

Lo scenario che fa danno: `land.html` va alla chat A e alla chat B. A lo rimanda col pannello nuovo, Antonello carica. Poi B lo rimanda con la sua modifica — ma B era partita dalla copia di **prima**. Caricandolo **la pagina torna indietro nel tempo**.

**È successo tre volte il 02/08:** su `scheda.html`, su `land.html` (dove il consegnato avrebbe cancellato `normVirg` e riportato il riquadro PNG all'oro) e su `admin.html`. In quest'ultimo caso le due copie divergevano **in entrambe le direzioni**, e la fusione è stata fatta a mano, hunk per hunk, tenendo il lavoro altrui.

Quello che salva è che **GitHub conserva la cronologia**: dal file, «History», si recupera la versione precedente. Il costo vero è accorgersene tardi.

**Le regole, in ordine di efficacia:**

1. **Una chat per file.** È l'unica regola che non chiede disciplina nel momento sbagliato.
2. **Sullo stesso file si va in fila, non in parallelo:** si chiude il giro — file caricato e verificato sul dominio — e solo allora il file *nuovo* passa all'altra chat.
3. **🔴 La copia locale non è una fonte.** Prima di modificare una pagina si prende il file vero **dal disco di Antonello** (`~/Downloads`, con `device_list_dir` e `device_stage_files`) e si fa il diff con la propria copia. Il 02/08 questo passaggio ha salvato lavoro altrui **due volte su due**. Se le due copie divergono in entrambe le direzioni si fonde, non si sovrascrive.
4. **Prima di caricare, si guarda la dimensione.** Se una chat restituisce un file più piccolo di quello online, manca qualcosa. E dopo il caricamento si ricontrolla che sia cresciuto: se la dimensione non cambia, il file non è salito.
5. **A metà giornata, si rilegge il dossier prima di consegnare.**

**Vale anche per i documenti, non solo per le pagine.** Il changelog di `REGOLE.md` si è ritrovato le righe 41 e 42 in ordine invertito perché due chat lo hanno scritto: §3.

**Il database è un rischio diverso.** Due chat non si cancellano le migrazioni a vicenda, ma possono riscrivere la stessa funzione con idee diverse. Prima di toccare una funzione già discussa altrove, rileggerne la definizione con `pg_get_functiondef`.

**Quando il sospetto c'è già**, si fa riscaricare il file dubbio e si cerca dentro il marcatore di ogni modifica attesa — una stringa introdotta da quel lavoro e da nessun altro (`id="evoov"`, `data-p="png"`, `Si compra subito`, `normVirg`, `msg-scontro`). Ciò che non si trova non è stato caricato. Lo strumento pronto è `claude/controllo_passaggi.py`. **Sul sito live la stessa verifica si fa con WebFetch**, chiedendo quali di quelle espressioni compaiono nella pagina — con l'avvertenza del §10: dentro un `<script>` non si vede nulla.

---

### ⚠️ Un handoff fra due chat trasporta il testo, non i file

*(lezione del 07/08/2026, dal pannello dell'audit)*

Ogni conversazione lavora in un contenitore suo, **isolato anche dalle altre conversazioni**: quella che ha il ponte alla cartella non vede i file prodotti dall'altra, e nessun handoff, per quanto dettagliato, glieli passa. Il documento di consegna descrive i file; i file vanno **allegati in chat** a chi deve collocarli, oppure riscritti dalla cartella da Antonello.

⚠️ **Il modo in cui questo si nota tardi:** il file viene caricato su GitHub direttamente dai Downloads, il sito è giusto, tutti dichiarano chiuso — e la cartella resta indietro di una versione. Il controllo che lo smaschera in dieci secondi è l'impronta del file su disco confrontata con quella dichiarata nell'handoff. È successo il 07/08 con `admin.html`: sito a 269.573 byte, cartella ferma a 243.518 — **rimessa in pari la sera stessa**, dopo che il confronto delle impronte l'ha fatto vedere.

---

## 14bis. I file finiti si riscrivono nella cartella, sempre

*(convenzione adottata il 05/08/2026, dopo che la cartella è rimasta indietro di due rilasci)*

**La cartella del progetto `theuntoldstory` è la sorgente del caricamento su GitHub.** L'agente carica da lì, mai dalla home, dagli allegati o da `Downloads`. Quindi un file consegnato in chat e non riscritto nella cartella **non esiste** per il deploy: resta in una cartella di passaggio e rischia di lasciare online una versione diversa.

| Dove va | Che cosa |
|---|---|
| `sito_live\` | `land.html` · `REGOLE.md` · `regole.html` · `admin.html` · `guida.html` |
| `dossier\` | i sette documenti del dossier |
| `claude\` | le specifiche durature |

**La regola, in una riga: quando un file è finalizzato, nella stessa sessione lo si riscrive nella cartella e si verifica che i byte siano quelli attesi.** Non «prima o poi», non «te lo consegno e poi vedi tu»: subito, insieme alla consegna in chat.

**Perché esiste questa regola.** Il 05/08/2026 Antonello ha fermato un caricamento accorgendosi che il regolamento nella cartella era datato 03/08. Aveva ragione a fermarsi. Il controllo ha mostrato che **tutta** `sito_live\` era ferma al 03/08 18:33, cioè a **due rilasci** di distanza:

| File | Nella cartella | Vivo sul sito | Scarto |
|---|---:|---:|---:|
| `land.html` | 444.353 | 463.899 | **−19.546** |
| `REGOLE.md` | 99.770 | 109.787 | −10.017 |
| `regole.html` | 145.042 | 154.324 | −9.282 |

Caricare da lì avrebbe riportato indietro **l'intero gate del motore v1**: pannello guidato, suggeritore, breakpoint, §4.7 e §4.8, changelog 43 e 44. Non è la collisione fra due chat di §14 — è la stessa pagina che torna indietro da sola, perché la fonte del deploy non era mai stata aggiornata.

⚠️ **Effetto su §14 punto 3.** Quella regola dice che «la copia locale non è una fonte» e che il file vero si prende da `~/Downloads`. **Vale ancora finché la cartella non è tenuta in pari.** Con questa convenzione rispettata, la fonte torna a essere `sito_live\` — ma la verifica resta obbligatoria: **prima di modificare una pagina si confrontano i byte** della copia in cartella con quelli dell'ultima consegna. Se non coincidono, la cartella è indietro e va riallineata prima di lavorarci.

⚠️ **Due `REGOLE.md` nello stesso progetto.** Ce n'è uno anche nella radice (`C:\theuntoldstory\REGOLE.md`), 81.710 byte, fermo al 03/08 17:58 e diverso da quello di `sito_live\`. **Non è la fonte del deploy** e non va caricato. Finché resta lì è una trappola: due file con lo stesso nome e contenuti diversi.

**Il controllo di chiusura.** Il riepilogo GitHub non è completo se i file non sono nella cartella canonica. La forma giusta è: *file scritto nella sezione corretta, N byte, SHA, commit e verifica*; se il caricamento è bloccato, deve indicare motivo e percorso esatto, non solo *file consegnato*.

---

## 15. Le skill del progetto

Sono la memoria compatta di questo lavoro: servono a non dover rileggere i documenti pesanti a ogni chat.

| Skill | Quando si attiva |
|---|---|
| `gdr-contesto` | **Sempre**, prima di rispondere a qualunque domanda sul gioco. |
| `gdr-verifica` | A inizio sessione, o prima di dichiarare fatto qualcosa: query in sola lettura che fotografano il database reale. |
| `gdr-regole-sync` | Ogni volta che cambia una regola: impone di allineare `REGOLE.md` e `regole.html` insieme. |
| `gdr-sql` | Prima di scrivere qualunque SQL. **E la prassi §2: la sezione dell'admin si fa nella stessa sessione della migrazione.** |
| `gdr-pagine` | Quando si modifica una pagina HTML monolitica. |
| `gdr-chiusura` | A fine sessione: gli aggiornamenti del dossier e le due liste finali, **senza creare file datati**. |
| `interrogami` | Quando Antonello vuole essere grigliato prima di decidere. |

⚠️ **Le skill sono arretrate, e non si aggiornano da sole:**

1. il **numero di changelog** in `gdr-regole-sync` e `gdr-contesto` — la fonte è **§3 di questa pagina**;
2. la riga «Lumache (solo medici)» in `gdr-contesto`: **è falsa**, solo *Palmo trasmesso* e *Cura diffusa* sono riservate al Corpo Medico;
3. **l'elenco dei vincoli in `gdr-sql` non conosce** `uso`, `difensiva`, `messages.kind='sistema'`, `character_perks.tipo='punti_caratteristica'` né `characters.pool_concesso` — la fonte è **§4 e §6 di questa pagina**;
4. **nessuna skill conosce il motore di combattimento**;
5. il conteggio delle funzioni e delle skill, che cambia più in fretta del testo che lo cita.

**Le skill non si modificano da una chat** (§10): si consegnano come file e le salva Antonello.

---

## 16. La Test Room — l'unico posto dove si cancella

*(deroga dichiarata e approvata il 02/08/2026)*

Un luogo con `locations.is_test = true` è una **stanza di prova riservata allo staff**, esclusa dalla mappa. Lì dentro:

- `post_combat` e `post_heal` **tirano, calcolano e raccontano**, ma non toccano vita né chakra; il messaggio finisce con «prova: nessun valore è stato modificato»;
- `post_message` non scala il chakra della tecnica selezionata;
- PNG e oggetti sono **sospesi**: sei funzioni rifiutano con un messaggio esplicito;
- le role non si aprono e `enter_location` non registra entrate né uscite;
- l'ingresso è imposto dal server, non solo nascosto nel pannello;
- messaggi e scontri **si cancellano** — job orario più il pulsante «Svuota la stanza».

**È l'unico punto del progetto dove `DELETE` è ammesso**, ed è circoscritto ai luoghi con `is_test = true`. Una seconda deroga, dichiarata: **lì lo staff può accendere un'arte innata che non possiede**, altrimenti la stanza non servirebbe a provare il mantenimento.

**Prima di aggiungere una funzione che scrive, si controlla se prende `p_location`:** se sì, deve sapere cosa fare in un luogo di prova. Il censimento del 02/08 ne ha trovate 22, di cui 11 da proteggere.

---

## 17. Correggere una regola in un posto solo — la trappola del 06/08

Il 05/08 la finestra temporale del corpus dell'audit tagliava via l'ultimo intervento di ogni lezione. Ho corretto `academy_audit_corpus` — **quello che il modello legge** — e ho chiuso il mandato. Il difetto è tornato il giorno dopo, peggiorato: `academy_audit_salva` — **quello che valida ciò che torna** — aveva la stessa finestra, non toccata. Risultato: il modello vedeva finalmente il passo finale e poteva segnalarlo, e il salvataggio lo buttava via **in silenzio**.

> **Quando una regola vive in due punti — chi produce e chi verifica — si correggono insieme, o non si è corretto niente.** Peggio: correggerne uno solo può rendere il difetto *meno* visibile di prima, perché il dato adesso arriva e sparisce dopo.

Il modo per accorgersene prima è chiedersi, a ogni correzione: **chi altro conosce questa stessa regola?** Nel caso dell'audit erano tre — il corpus, la Edge, il salvataggio.

⚠️ **Terza volta, l'08/08, e stavolta le copie erano quattro.** L'attesa fra due lezioni dell'Accademia era ricalcolata da capo in `_academy_prossima_lezione`, `academy_state`, `academy_complete` e `_academy_grant`. Un mandato scritto «cambia la semantica di `can_today`, `next_at` e del blocco» ne avrebbe toccate tre su quattro, e la superstite era **quella che rilascia l'attestato a fine lezione**: l'allievo avrebbe giocato l'intera lezione per ricevere `cooldown` all'ultimo passo. Le copie non erano nominate da nessuna parte — si trovano solo cercando la costante (`pg_get_functiondef ... like '%20 hours%'`) invece del nome della funzione.

> **Il correttivo non è ricordarsi di aggiornarle tutte: è non averne più di una.** La regola è finita in un helper solo, `_academy_giorno_inizio` + `_academy_prossima_lezione`, e le altre lo interrogano. Dopo una migrazione di questo tipo, la prova che conta è **contare le copie superstiti della costante in tutto lo schema e pretendere zero** — è il controllo che ha scoperto la quarta.

Corollario, dallo stesso giorno: **non domandare al modello ciò che il server sa già.** `session_id`, `village`, `lesson_code`, `sensei_name`, e da ACC-AUDIT-011 anche `source_turn_id` e `step`, sono dati che il server conosce con certezza. Chiederli significa creare un punto in cui il modello può sbagliare senza guadagnare niente: sei findings validi buttati via il 06/08 per una trascrizione sbagliata di un uuid, e cinque attribuiti al passo sbagliato.

---

## 18. L'ordine fra migrazione e Edge, nei due versi

Quando una migrazione e una Edge cambiano insieme il contratto fra loro:

- **All'andata:** prima la migrazione, poi la Edge. La funzione nuova accetta anche il payload vecchio; la Edge nuova con la funzione vecchia no.
- **Al ritorno:** prima il rollback SQL, poi la Edge. Il contrario lascerebbe la Edge nuova a mandare campi che la funzione vecchia **ignora in silenzio** — nessun errore, nessun log, dati che semplicemente non arrivano.

Va scritto in testa a ogni coppia candidata/rollback, perché il rollback si legge di fretta e di solito di notte.

---

## 18bis. Il banco che muore alla riga uno — le guardie delle fixture, 11/08

Un banco in `begin … rollback` comincia sempre creando personaggi finti. **Le guardie che
rifiutano *le fixture* vanno conosciute per prime**, perché fermano tutto prima che una sola
asserzione venga misurata.

🔴 **`characters_check_name` non accetta il nome tipico da banco.** La regola è
`^[A-Za-zÀ-ÿ'’-]{2,15}$`: **2-15 lettere, niente cifre, niente spazi**, piu'
`name_is_blocked`. Quindi `BancoAlfa005` **non passa**, e l'11/08 ha fermato un banco in
produzione al primo `insert`, dopo che in locale era verde da ore. Nomi buoni: `BancoAlfa`,
`InvStaff`. **Il suffisso numerico del task si mette nei luoghi** (`Banco 005 · Uno`), non nei
personaggi. Rinominare **alla sorgente** e sulla stringa intera, cosi' identita', `author_name`,
`starter_name`, `character_name` e le righe di snapshot si muovono insieme.

**Una replica locale vale quanto i vincoli che le si mettono dentro**, e vanno messi in
quest'ordine: prima quelli che rifiutano le fixture, poi il resto. Il correttivo non e'
ricordarsene: e' **una guardia nell'assemblatore** che estrae dai template ogni nome destinato a
`characters.name` e lo passa per la regola vera, con la sua controprova - rimettere il nome
cattivo e verificare che il montaggio muoia.

⚠️ E `characters_guard` e `profiles_guard` tornano `NEW` **quando `auth.uid()` e' nullo**: una
scrittura di servizio dentro un banco va fatta **senza JWT**, non col JWT di un giocatore.

## 18ter. «Verbatim» non si promette: o si sigilla, o si manda da psql — 11/08

Il testo SQL di una chiamata MCP **lo riscrive il modello**: il file depositato e il testo
eseguito non sono lo stesso oggetto. Su 80-90 KB la divergenza piu' pericolosa non e' quella che
rompe la sintassi - e' quella che **indebolisce un `assert`**, e diventa verde per il motivo
sbagliato.

- **Sopra i ~50 KB si manda da `psql`**, con uno script che prende `PGURI` dall'ambiente (mai
  in chat) e si rifiuta di spedire un file che contenga un `commit` eseguibile. Dal disco il
  file parte byte per byte e nessuno lo ricopia.
- **Dove la chiamata e' obbligata, si sigilla**: il corpo va dentro una stringa dollar-quotata e
  il database ne verifica il `sha256` **prima** di eseguirlo. Se una battuta e' diversa, non
  gira niente.
- **E si sigilla anche il risultato**: `pg_get_functiondef` restituisce esattamente il testo
  del file `CREATE OR REPLACE …` depositato, quindi l'impronta della funzione **viva** si puo'
  confrontare col `sha256` del file in `SHA256SUMS`. Va messo sia nel banco sia nel postflight.

⚠️ **Dire com'e' stato eseguito.** Se il testo inviato e' stato riscritto invece di essere lo
stesso file depositato, va scritto: la prova byte per byte del file resta da fare, e non si
dichiara fatta.

### ➕ 13/08 — tre cose imparate sigillando davvero una migrazione

Il sigillo di §18ter è stato usato per la prima volta su una scrittura di produzione
(`TECH-CONTENT-SAFETY-002`). Ha funzionato, e ha mostrato tre dettagli che a tavolino non si
vedono:

1. 🔴 **Il dollar-quoting non mangia il newline dopo il tag di apertura.** La stringa che arriva
   al database è `"\n" + file`, quindi il suo `sha256` **non è** quello in `SHA256SUMS` e il
   confronto fallisce sempre, anche quando il testo è perfetto. Due strade: calcolare in locale
   `sha256("\n" + file)`, oppure — meglio — normalizzare i soli newline di testa e coda da
   entrambe le parti, `sha256(convert_to(btrim(v_sql, e'\n'),'UTF8'))`. Ogni byte interno resta
   vincolato.
2. **Sigillare il corpo non sigilla il file generato.** Se il candidato consegna
   `21_MIGRAZIONE_APPLICA.sql` = intestazione + `begin;` + corpo + `commit;`, ciò che si può
   garantire byte per byte è il **corpo** (`corpo/*.body.sql`): l'involucro lo si riscrive a mano
   attorno. Va detto nell'handoff, invece di lasciar credere che sia stato eseguito il file.
3. **Le impronte attese devono venire dal preflight depositato, non calcolarsi al volo.** Una
   sonda che confronta un valore con sé stesso è verde per costruzione. Su 002 la firma delle
   altre 352 righe (`df5c84de…`) e quella dei testi delle tre (`97d31288…`) erano già sul disco
   dal giorno prima: ritrovarle identiche **dentro** la transazione è ciò che prova che il corpo
   eseguito misurava le cose giuste.

⚠️ **E `EXECUTE` non restituisce il referto al client:** il `select` finale va ripetuto **fuori**
dal blocco sigillato. Le temp table create dentro `EXECUTE` restano visibili nella stessa
transazione, quindi basta rileggerle.

### ➕ 16/08 — trasporto diretto disco → integrazione Supabase

Quando `psql` non e' disponibile, la rete del computer e' instabile o il file supera il testo che
una chat puo' ricopiare, **non si trascrive piu' l'SQL nel messaggio**. La sessione legge il file
dal disco dentro la stessa orchestrazione che chiama l'integrazione Supabase e passa quella stringa
direttamente a `execute_sql`, senza stamparla e senza farla attraversare dal modello.

La procedura obbligatoria e':

1. verificare prima `SHA256SUMS`, dimensione in byte, assenza di `COMMIT` eseguibili e forma della
   transazione;
2. leggere il file programmaticamente e confrontare **nel processo** i byte ricevuti con la misura
   del file; se il conteggio diverge, non chiamare Supabase;
3. fare **una sola** chiamata per un file `BEGIN ... ROLLBACK`: mai spezzarlo e mai mandare i pezzi
   in chiamate diverse;
4. usare `execute_sql`, **mai `apply_migration`**, per una prova destinata ad annullarsi;
5. rieseguire preflight e controllo residui in una chiamata separata dopo il ritorno;
6. dichiarare nel referto «trasporto diretto dal disco», la misura dei byte e l'eventuale assenza
   di un sigillo calcolato dal server. Non chiamarlo `psql -f verbatim` se non lo e'.

**I comandi `psql` non sono SQL.** Un file che contiene righe `\\pset` o `\\echo` non puo' essere
mandato tal quale a `execute_sql`. Per un candidato nuovo si generano dalla stessa sorgente due
involucri: uno `psql` e uno MCP in SQL puro. Su un file storico e' ammessa una variante costruita
in memoria togliendo **soltanto** una allowlist dichiarata di direttive di presentazione
(`\\pset`, `\\echo`); qualunque `\\i`, `\\ir`, `\\include`, `\\copy`, `\\set` o direttiva non
prevista ferma il trasporto. Il referto conserva l'impronta della fonte e dice quali righe non SQL
sono state escluse.

Questa strada non richiede `PGURI`, password o chiavi nella chat: usa il progetto gia'
autenticato dell'integrazione. `psql -f` resta preferibile quando l'ambiente ha una connessione
stabile e il mandato pretende proprio il file client completo; non e' piu' necessario costringere
Antonello a far viaggiare una prova dal suo hotspot quando l'integrazione puo' ricevere il file dal
disco.

## 19. Chi ha davvero giocato una role — e tre trappole trovate l'08/08

### L'identità in una role non si legge dove sembra

Verificato su 16 role reali. **`role_messages.author_name` non identifica nessuno** e
**`role_session_participants` nemmeno**, per tre ragioni indipendenti:

- **l'IA scrive sotto nomi che non appartengono a nessuno.** I messaggi `kind='sensei'` hanno
  `character_id` nullo (168 su 168) e un `author_name` scelto dal motore: oltre a `Ibara` e
  `Katsuo`, compaiono nomi come `Nozomi` e `Rentaro` che non esistono in `characters`, né in
  `png_templates`, né in `png_instances`. I `kind='say'` hanno sempre `character_id` (242 su 242);
- **si è iscritti alla scena senza aver scritto**, perché `role_start` iscrive chiunque risulti in
  `presence` da meno di 8 minuti;
- **la tabella conserva identificativi morti**: nessuna FK su `character_id`, e 5 righe su 29
  puntano a personaggi cancellati. `messages_archive` **non ha nessuna chiave esterna**, mentre
  `messages.character_id` ha `ON DELETE SET NULL`.

**Per misurare cosa ha scritto un personaggio servono sei filtri, non quattro**, su
`messages` ∪ `messages_archive` — l'unione è obbligatoria perché `role_maintenance` archivia a 24 h:

```
character_id  = <il personaggio>
location_id   = role_sessions.location_id                 -- senza, contano i turni scritti altrove
created_at   >= role_sessions.record_from
created_at   <= coalesce(role_sessions.closed_at, now())  -- senza, contano quelli dopo la chiusura
recipient_user is null
coalesce(kind,'say') not in ('whisper','sistema','motore','sensei')
```

⚠️ **Non copiare il filtro di `role_scene`:** applica solo `location_id`, `created_at >= record_from`,
`recipient_user is null` e `kind <> 'whisper'`. Non filtra `character_id` e non esclude `sistema`,
`motore` né `sensei`.

### `ON DELETE SET NULL` e un CHECK sulla stessa colonna si contraddicono

Se una colonna è dichiarata `ON DELETE SET NULL` **e** compare in un `CHECK` che le impone di non
essere nulla in certi casi, cancellare la riga padre non scrive NULL: **fallisce sul CHECK**, con un
`23514` che nomina la tabella figlia invece del vincolo vero. Le due cose vanno decise insieme: o il
CHECK si allenta, o la FK diventa `RESTRICT`. Trovato l'08/08 su `training_sessions`.

### I permessi si scrivono, e si provano dov'è la migrazione

Il `GRANT` del §0 di `gdr-sql` non basta da solo: va accompagnato da
`REVOKE EXECUTE … FROM PUBLIC, anon` **prima** del `GRANT`, perché una `SECURITY DEFINER` esposta ad
`anon` è una porta aperta. E soprattutto: **una prova in `begin; … rollback;` non dimostra i
permessi**, perché gira come `postgres`, proprietario, e passa anche senza un solo grant. L'unica
verifica che conta va messa **dentro la stessa transazione** della migrazione:

```sql
select has_function_privilege('anon',          'public.mia_rpc(uuid)', 'EXECUTE'),  -- atteso false
       has_function_privilege('authenticated', 'public.mia_rpc(uuid)', 'EXECUTE');  -- atteso true
```

### Il pacchetto consegnato è quello provato, byte per byte

Se durante la stesura un file cresce rispetto al testo che è stato davvero eseguito — anche solo di
un campo in più in un JSON — **si allinea il file al testo eseguito** e la differenza torna al PM
come domanda aperta. Consegnare la versione «più ricca ma non provata» è il modo silenzioso di
rompere la prova. Il controllo si fa rimontando i file dal disco e confrontandoli con `diff`.

## 20. Sei regole imparate fra il 14 e il 15/08

Vengono da `ROLE-REC-HISTORICAL-RECOVERY-009`, `ROLE-REC-AUTOSTART-006`, `EXAM-GENIN-DB003-ASSEMBLER-COVERAGE-004`, `EXAM-GENIN-DB003-MESSAGES-PNG-005`, `EXAM-GENIN-UI-005-R2-CAPORALI` e `PROJECT-STATE-ALIGN-007`. Nessuna sostituisce una regola già scritta sopra: dove il tema si tocca — §14 sulle due chat, §14bis sui file finiti, §18ter sul sigillo — queste la completano.

### Le revisioni dello stesso task stanno in sottocartelle distinte, e una sola è canonica

Quando due sessioni lavorano allo stesso candidato nascono due cartelle che si somigliano, e da fuori non si distingue quale sia stata provata. La regola: **ogni revisione ha la sua sottocartella, col numero nel nome**, e la revisione **canonica è dichiarata per iscritto dentro sé stessa** — un `00_REVISIONI_SUPERATE.md` che nomina le altre.

⚠️ **E va detto il limite.** Il cartello sta nella cartella nuova, non in quelle superate: chi arriva da una di quelle **non lo vede**. Scriverlo là dentro significa aprire in scrittura una cartella contesa, e richiede un'autorizzazione esplicita. Finché non c'è, il rischio resta — dichiarato, non risolto.

### Un manifest non può ridurre silenziosamente la copertura

Se l'elenco dei file che l'assemblatore verifica è più corto dell'insieme dei file che compongono il candidato, il montaggio è **verde per costruzione**: quello che non è in elenco non è stato guardato. Da qui tre conseguenze operative:

- il numero di file coperti è **un minimo, non un tetto**: se compare uno strumento nuovo — un banco, uno script di prova — **entra nella copertura**, non resta fuori perché «non è codice di produzione»;
- un manifesto **storico** non è un riferimento: va **marcato come non autorevole**, o qualcuno lo userà credendo di verificare;
- la verifica dell'impronta si fa **da due lati** — l'impronta attesa, e la controprova che rigenerando il pezzo si riottiene il file superstite **byte per byte**. Se una delle due salta, non si monta niente.

### Un file storico e un file vivo non sono intercambiabili

Un verbale — un handoff, un preflight depositato, una fotografia del dossier — dice **com'era il mondo quel giorno**. Un file vivo dice **com'è adesso**. Non si legge l'uno per rispondere alla domanda dell'altro, e soprattutto **non si aggiorna un verbale per farlo somigliare al presente**: si perde la prova di che cosa era stato misurato quando la decisione fu presa.

La regola pratica: **la fotografia si affianca, non si corregge.** Vale sul dossier come sugli handoff. Se una sezione storica è superata, accanto le si mette un riquadro datato che dice che cosa vale oggi, e il testo di prima resta alla lettera.

### Una nota append-only rettifica lo stato senza alterare il verbale

Il modo concreto di applicare la regola qui sopra su un file già consegnato:

- la rettifica va **in coda** al file (o, per una nota di memoria, in un blocco «stato corrente» **in testa** più il campo `description`); il corpo non si tocca;
- che l'aggiunta sia davvero un append **si misura, non si dichiara**: si rilegge il file nuovo dal disco e si ricalcola l'impronta dei **primi N byte**, che deve riprodurre esattamente quella di prima;
- **la rettifica va messa dove la contraddizione si legge.** Se la frase superata compare in tre punti, correggerne uno lascia il documento in contraddizione con sé stesso;
- e la rettifica va **ancorata al fatto giusto**. «Il blocco resta finché X non consegna» invecchia male: se la consegna avviene e il blocco resta, chi rilegge fra un mese lo dà per chiuso. Si ancora all'**applicazione**, non alla consegna.

### Una migrazione applicata e registrata tardi deve dichiarare entrambe le ore

Se i dati entrano in produzione a un'ora e la riga in `schema_migrations` viene scritta a un'altra — perché il candidato non registrava da sé — il verbale deve portare **tutte e due**: l'ora dell'applicazione e l'ora della registrazione.

⛔ **Non si retrodata la riga** per farle coincidere. Le due ore delimitano la finestra in cui la produzione era cambiata senza che il registro lo dicesse, e quella finestra è esattamente ciò che una sessione futura ha bisogno di sapere. Sul recupero delle role storiche del 15/08 sono **~01:28 UTC** (dati) e **01:41:08** (registrazione, `20260815014108`).

### Una UI che dipende da un valore nuovo di un `CHECK` resta bloccata fino all'applicazione server

Una pagina può essere scritta, provata e verde al banco e restare **completamente inerte** in produzione, perché il valore su cui si accende è rifiutato da un vincolo di colonna. È successo con `messages.kind='png'` e `EXAM-GENIN-UI-005 R2`.

Le tre conseguenze:

1. **Non si pubblica la UI prima del server.** Pubblicarla non fa danno visibile, ed è proprio questo il problema.
2. **Chi la collauda verifica prima il `CHECK`.** Senza quel controllo si legge «funziona come prima» e lo si scambia per un verde: la pagina si comporta esattamente come la versione precedente.
3. **A sbloccarla è l'applicazione, non la consegna.** Un candidato pronto che contiene il `CHECK` allargato non cambia niente in produzione. E se il `CHECK` allargato vive **dentro** la migrazione della funzione che lo usa — invece che in una migrazione sua — è una scelta deliberata: una migrazione a sé si applicherebbe prima, allargando un vincolo di produzione per una funzione che ancora non esiste.

---

## 21. Gate diversi non si sostituiscono — lezione del 17/08/2026

Un rilascio IA e interfaccia può avere almeno quattro prove diverse, e nessuna eredita il verde
dell'altra:

1. **Banco deterministico:** prova contratti, rami e inversioni su dati controllati.
2. **Gate reale del modello:** prova il prompt effettivo su tutte le scene prescritte, col modello
   e i tetti dichiarati.
3. **Playtest server/Edge:** prova una partita vera e i passaggi di turno, ma copre soltanto le
   scene realmente incontrate.
4. **Collaudo del file pubblicato:** prova che il browser stia servendo proprio il candidato e che
   il flusso sia visibile all'utente.

Perciò **due turni reali non chiudono un gate da 22 scene**, e un banco verde su `land.html` non
prova la pagina online. L'handoff deve nominare separatamente quale dei quattro è verde, quale è
cieco e quale è rinviato.

### Un mezzo turno nuovo non eredita la spesa del lato precedente

Quando una funzione consuma l'azione e poi passa il turno, deve separare due fatti: la spesa del
lato che ha appena agito e la disponibilità del lato nuovo. Un booleano condiviso senza
attribuzione può rendere il server incoerente: l'elenco pubblico offre una mossa mentre il
costruttore interno la elimina, oppure viceversa.

La prova minima attraversa **entrambi** i sensi del passaggio e controlla il risultato, non solo
l'opzione iniziale: lato A consuma → lato B riceve una principale; lato B consuma → lato A riceve
una principale; la non cumulabilità resta verificata col suo marker di scambio. È la rete che ha
chiuso `EXAM-GENIN-DIVERSIVO-TURN-RESET-034`.
