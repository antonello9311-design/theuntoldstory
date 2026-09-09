---
name: gdr-sql
description: Usa questa skill PRIMA di scrivere o eseguire qualunque SQL sul database Supabase del GDR «The Untold Story» (progetto tyhyxkslteigibktluml) — migrazioni, INSERT di tecniche, modifiche a funzioni SECURITY DEFINER, correzioni di dati, funzioni del motore di combattimento. Contiene la regola del GRANT esplicito senza il quale ogni funzione nuova nasce invisibile al client, la checklist dei vincoli CHECK che rifiutano le righe sbagliate, i nomi di colonna che ingannano, le tabelle del motore, la Test Room, il dollar-quoting per gli apostrofi italiani, la prova con begin/rollback, la prassi che impone di aggiornare admin.html nella stessa sessione e l'obbligo di mostrare il piano e attendere approvazione.
---

# gdr-sql — toccare il database senza rompere niente

**Metodo vigente di progetto:** dalla cartella The Untold Story seguire `AGENTS.md` e `management/coordination/AVVIO_LAVORO.md` per mandato, owner, prenotazioni, budget e consegna. Questa skill conserva i dettagli tecnici del proprio dominio; non assegna file né riapre task o autorizzazioni. Preparare gli output in copia e integrarli con il guard del progetto; i gate di produzione restano distinti.


**Prima di tutto: si chiede.** Nessuna modifica al database senza approvazione di Antonello. Se il cambiamento è sostanziale — una migrazione, una funzione, un `UPDATE` su molte righe — si **mostra il piano e si aspetta**. Un `SELECT` di lettura non richiede approvazione; tutto il resto sì.

**Non si cancella.** Per disattivare qualcosa si usa `is_active = false`, **mai `DELETE`**. Conservare lo storico anche nelle Test Room; chiudere soltanto le prove proprie attraverso i percorsi autorizzati, salvo mandato di mantenerle aperte. Valgono AGENTS e §8.

---

## 0. 🔴 Ogni funzione nuova nasce chiusa — la regola che si dimentica per prima

*(in produzione dal 07/08/2026, migrazione `sicurezza_default_privileges_funzioni_chiuse`)*

**Una funzione creata oggi non è eseguibile né da `anon` né da `authenticated`.** Se è una RPC che il client deve chiamare, il `GRANT` va scritto **nella stessa migrazione**:

```sql
create or replace function public.nome_funzione(p_x uuid)
returns jsonb language plpgsql security definer set search_path = public as $$ … $$;

grant execute on function public.nome_funzione(uuid) to authenticated;
```

Si concede **ai soli ruoli necessari**: `authenticated`, e `anon` **soltanto** se la funzione è davvero pubblica (cioè serve prima del login). `service_role` è già coperto da una default privilege, ma se lo si vuole esplicito lo si scrive.

⚠️ **Chi dimentica il grant non riceve un errore in migrazione.** La migrazione passa, i test SQL passano — perché li si esegue come `postgres`, che è proprietario. Il difetto compare il giorno dopo, nella pagina, come «permission denied», e sembrerà un difetto della funzione.

**Non si concede mai al client un helper interno** — quelli con l'underscore iniziale (`_academy_sistema`, `_combat_round_tick`, `_assegna_xp`…) e le trigger function. Se il client sembra averne bisogno, la risposta è **una RPC pubblica che lo incapsula**, non un grant sull'helper.

### Perché la regola esiste

L'hardening del 17/07 aveva ridotto le funzioni eseguibili senza login da 79 a 8. Il **07/08 erano risalite a 98**, e fra queste tre scrivevano davvero: `_academy_sistema` inseriva un messaggio `kind='sistema'` in **qualunque luogo con qualunque nome d'autore** — riprodotto come `anon`, senza login — `_combat_round_tick` scalava il chakra ai combattenti di una sessione arbitraria, `_combat_nuovo_round` azzerava le azioni già spese. **Nessuno le aveva aperte: nascevano aperte.**

I grant arrivavano da due posti che si sommano, e nessuno dei due si chiude da solo:

| Sorgente | Cosa concedeva | Chiusa con |
|---|---|---|
| default built-in di PostgreSQL | `EXECUTE` a `PUBLIC` su ogni funzione | `alter default privileges for role postgres revoke execute on functions from public` — **senza `IN SCHEMA`** |
| default ACL di Supabase sullo schema | `EXECUTE` nominale ad `anon` e `authenticated` | `alter default privileges for role postgres in schema public revoke execute on functions from anon, authenticated` |

**Su una funzione già esistente la revoca efficace è `revoke execute on function … from public, anon, authenticated`.** Revocare solo da `anon` non basta: il privilegio si eredita da `PUBLIC`.

### Le quattro API pubbliche — non toglier loro `anon`

`land_stats()` (contatore in homepage) · `username_status(text)` (registrazione) · `is_staff()` (**usata da 79 policy RLS**) · `is_clan_leader(uuid,text)`. Chiuderle spegne la homepage, la registrazione o le pagine pubbliche.

**Fotografia storica del 07/08:** i job censiti erano sei, cinque attivi, eseguiti come `postgres`. Questo non descrive la configurazione corrente. Per ruolo di esecuzione, numero, pianificazione e stato consultare PIATTAFORMA e verificare il DB prima di dichiararli attuali. I grant vanno valutati rispetto al ruolo effettivo; nessuna modifica ai job deriva da questa memoria.

---

## 1. La checklist dei vincoli — leggerla prima di scrivere l'INSERT

Questi `CHECK` esistono davvero e rifiutano la riga con un `ERROR: 23514`. Sono la causa numero uno di migrazioni fallite a metà.

```
attivazione        → solo 'istantanea' | 'sigilli'      ('passiva' e 'sguardo' vengono RIFIUTATI)
gittata            → solo 'contatto' | 'corta' | 'media' | 'lunga'
uso                → solo 'principale' | 'rapida' | 'difesa' | 'passiva' | 'fuori_scontro'
                     ← su clan_techniques E su jutsu, dal 02/08. È la colonna che usa il motore.
consumption_type   → solo 'ad_utilizzo' | 'per_turno' | 'passiva'
macro              → solo 'clan' | 'generica' | 'abilita' | 'evocazione' | 'cercoterio'
req_elements_mode  → NULL | 'uno' | 'tutti'
messages.kind      → 'say' | 'roll' | 'whisper' | 'item' | 'combat' | 'sensei' | 'cura' | 'sistema'
                     ← 'sistema' aggiunto il 02/08 per le righe del motore
character_perks.tipo → accetta anche 'punti_caratteristica'
character_abilities.state → solo 'in_addestramento' | 'attiva'
characters.cercoterio → NULL o uno dei nove nomi CON I MACRON:
   Shukaku · Matatabi · Isobu · Son Gokū · Kokuō · Saiken · Chōmei · Gyūki · Kurama
characters.sigillo → NULL, oppure 'Solido' | 'Ordinario' | 'Difettoso' e solo se c'è un cercoterio
emblems.kind → 'village'|'clan'|'rank'|'element'|'corp'|'corpspec'|'corpgrade'|'bijuu'|'evofam'
combat_sessions → un solo scontro aperto per luogo (indice unico parziale)
```

**Convenzione obbligatoria:** una tecnica passiva ha `consumption_type='passiva'` **e** `attivazione='istantanea'`. Nessuna riga usa `attivazione IS NULL`.

**Taglie delle evocazioni:** `baby` · `piccola` · `media` · `grande` · `leggendaria`. Il vincolo rifiuta `minore`/`intermedia`/`superiore`.

**«Senza clan» è la stringa `'Nessuno'`, non `NULL` e non `''`.** Ogni condizione che voglia dire «non ha un clan» si scrive:

```sql
coalesce(nullif(btrim(clan),''),'Nessuno') = 'Nessuno'
```

Il 29/07/2026 `premio_assegna` e `premio_decidi` usavano `btrim(clan) <> ''` e rifiutavano il Cercoterio a **chiunque**, perché per loro anche `'Nessuno'` era un clan.

### `characters` ha sei trigger, e due concedono roba

Oltre alle guardie (`characters_guard`, `characters_cercoterio_guard`, `characters_check_name`, `characters_init_pools`, `characters_insert_guard`) c'è **`trg_characters_grant_academy`**, `AFTER UPDATE OF rank`: quando il grado passa da Deshi a Genin o oltre, inserisce in `character_jutsu` **tutte le basi d'Accademia attive** con `source='promozione'` **e concede il pool di punti caratteristica del gradino**.

⚠️ **Un `UPDATE` massivo sui gradi non cambia una colonna: distribuisce tecniche e punti.** Prima di scriverne uno, contare quante righe si stanno per toccare e dire ad Antonello che cosa riceveranno.

⚠️ **`characters.pool_concesso` è un intero cumulato, non un booleano** — 60 alla creazione, 90 da Genin, e via così. Impedisce che retrocedere e ripromuovere coltivi punti all'infinito. **Non azzerarlo mai**, e non «sistemarlo» a mano.

### Unicità e chiavi primarie da rispettare

```
character_abilities  UNIQUE (character_id, technique_id)
character_jutsu      UNIQUE (user_id, jutsu_id)      ← si lega a user_id, NON a character_id
academy_lesson_script PRIMARY KEY (lesson_id, step, village)
lesson_grants        PRIMARY KEY (lesson_id, jutsu_id)
emblems              PRIMARY KEY (kind, name)   ← non esiste una colonna `code`
characters           indice unico parziale su cercoterio: una sola Forza Portante per bestia
```

Un `INSERT` massivo senza `ON CONFLICT DO NOTHING` su queste tabelle fallisce al primo doppione e annulla tutto il blocco. **`clan_techniques` non ha un vincolo di unicità sul nome:** un catalogo rieseguito due volte si duplica in silenzio. Proteggere l'inserimento con una guardia in testa:

```sql
do $guard$
begin
  if exists (select 1 from public.clan_techniques where macro = 'cercoterio') then
    raise exception 'Catalogo gia presente: non reinserisco';
  end if;
end $guard$;
```

---

## 2. Nomi di colonna che ingannano — errori già commessi

| Si tende a scrivere | La colonna vera è | Errore che si ottiene |
|---|---|---|
| `clan_techniques.descr` | **`description`** | `42703: column "descr" does not exist` |
| `missions.rank` | **non esiste** | `42703` |
| `locations.village` | **non esiste** (c'è `region`) | `42703` |
| `academy_lessons.ord` | **`ordinal`** | `42703` |
| `emblems.code` | **non esiste** (chiave `kind` + `name`) | `42703` |
| `combat_sessions.stato` | **`state`** | `42703` |
| `jutsu.name` | **`name_it`** | `42703` |
| `characters.nome` / `grado` / `villaggio` | **`name`** · **`rank`** · **`village`** | `42703` |

⚠️ **Su `clan_techniques` ci sono DUE colonne di distanza e DUE di classificazione**, e sceglierne una a caso significa scrivere in un campo che il motore non legge:

| Colonna | Che cos'è |
|---|---|
| **`gittata`** | elenco chiuso, `contatto`/`corta`/`media`/`lunga`. **È quella che usa il motore.** |
| `portata` | testo vecchio, «Corto»/«Medio»/«Sé stesso». Informativa. |
| **`uso`** | elenco chiuso di cinque valori. **È quella che usa il motore.** |
| `tipo_azione` | testo libero, 74 valori scritti a mano. Informativa. |
| **`difensiva`** | booleano: se la tecnica può comparire nel **menù della difesa**. |

**Le basi d'Accademia non stanno in `clan_techniques`:** stanno nella tabella **`jutsu`**, che ha un vocabolario suo (`name_it`, `rank`, `action_type`) e che dal 02/08 ha anch'essa `uso`, `difensiva` e `gittata`. Il menù della difesa pesca da **tutte e due** le tabelle.

**Gli elementi di un personaggio sono quattro sorgenti, non una.** Base in `characters.element`, **seconda natura in `characters.element2`** (gratuita al Jonin), elementi dell'innata in `clans.elementi_innati`, premio «Le cinque nature» in `character_perks`. **`character_elementi(uuid)` è la sola fonte di verità.**

**La Sintonia non è una colonna nuova:** è `characters.kekkei_genkai`, che per una Forza Portante cambia solo etichetta. `_stat_valore` accetta `'sintonia'` come sinonimo.

---

## 3. Scrivere il SQL

**Apostrofi italiani → dollar-quoting.** Ogni «dell'», «l'», «un'» rompe una stringa fra apici singoli. Si usa `$$…$$`:

```sql
insert into clan_techniques (name, description) values
  ('Liberazione dei Kikaichū', $$L'insetto si nutre del chakra dell'avversario.$$);
```

**Cambiare la firma di una funzione richiede `DROP` + `CREATE`**, non `CREATE OR REPLACE`. ⚠️ Se la funzione è chiamata dal frontend (`companion_create`, `premio_richiedi`, `training_start`…), **la nuova firma va rilasciata insieme alla pagina aggiornata**, altrimenti la scheda si rompe fra il deploy SQL e il caricamento dell'HTML. Va detto esplicitamente ad Antonello. ⚠️ E dopo il `DROP` **il grant se ne va con la vecchia funzione**: la nuova va riconcessa (§0).

**I default dei parametri fanno parte della firma.** Un `CREATE OR REPLACE` che li omette fallisce con «cannot remove parameter defaults from existing function». Prima di riscrivere una funzione, leggerne l'intestazione vera:

```sql
select split_part(pg_get_functiondef(p.oid), E'\n', 1)
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname='public' and p.proname = '…';
```

**Anche la volatilità fa parte della definizione:** una funzione `stable` riscritta senza quella parola torna `volatile` in silenzio. Controllare `provolatile` prima di sostituirla.

**Per una modifica piccola a una funzione lunga non la si ridigita:** si prende `pg_get_functiondef`, si fa `replace` sul frammento e si `execute` il risultato, verificando prima che il frammento compaia **una volta sola**.

**Scansioni su `pg_proc`:** aggiungere `p.prokind = 'f'`, altrimenti `pg_get_functiondef` fallisce sugli aggregati.

**`characters_guard` pinna colonna per colonna.** La policy `characters_update_own` lascia il giocatore aggiornare la propria riga: **ogni colonna nuova di `characters` che non deve essere sua va aggiunta esplicitamente alla guardia**, altrimenti passa. Una colonna aggiunta senza toccare la guardia è una falla, non una svista.

**Tutti i valori di gioco sono multipli di 5** — costi chakra, danni, soglie, XP. Un 37 in un `INSERT` è quasi sempre un errore. **Fanno eccezione l'esito di un tiro e i modificatori ai dadi**, che seguono la scala dei margini 0/3/6/10.

### Tre trappole che hanno fatto perdere tempo

1. **`now()` è costante dentro una transazione.** Righe scritte in sequenza da funzioni diverse ricevono lo stesso `created_at` e in chat escono nell'ordine sbagliato: «— Round 2 —» compariva prima della risoluzione del round 1. **Per ordinare eventi dentro una transazione si usa `clock_timestamp()`.**
2. **`array || 'testo'` è ambiguo.** Postgres lo legge come `array || array` e fallisce. **Si usa `array_append(col, 'testo')`.**
3. **`min(uuid)` non esiste.** Serve `order by … limit 1`.

### 🔴 La domanda da farsi su ogni funzione nuova: chi decide il numero?

*(lezione del 02/08/2026, pagata con una falla di sicurezza)*

`combat_dichiara_attacco` accettava un parametro `p_base` fino a **120, da qualunque client**. Chiunque sapesse chiamare la funzione poteva dichiarare il danno che voleva. **È esattamente il difetto che l'audit del 17/07 aveva chiuso in `post_combat`**, riaperto scrivendo il motore da zero, perché il parametro sembrava comodo per le prove.

La regola del progetto è una riga — *«l'IA racconta, il server comanda»* — e si traduce in una domanda operativa: **per ogni parametro numerico che una funzione accetta dal client, chi lo decide davvero?** Se la risposta è «il client», o si toglie il parametro, o lo si limita allo staff.

Il correttivo: colpo a mano = 10, tecnica = il suo `danno_base`, e solo lo staff può fissare altro.

---

## 4. Le tabelle del motore di combattimento

*(a database dal 02/08, in chat dal 03/08, contratti e referto rifatti fra il 04 e il 06/08)*

Lo scontro è un oggetto, distribuito su cinque tabelle. **RLS in lettura, nessuna scrittura diretta: si passa sempre dalle funzioni.**

| Tabella | Cosa tiene |
|---|---|
| `combat_sessions` | `location_id`, `kind`, `round`, `fase`, `turno_di`, **`state`**, `distanza_ingaggio` |
| `combat_participants` | iniziativa, **posizione in metri**, cosa ha speso nel round, se è fuori |
| `combat_pending` | il colpo dichiarato e non ancora risolto |
| `character_active` | cosa è acceso: tecnica, livello, costo per round |
| `combat_effects` | gli effetti a durata — la fase 2, ancora da costruire |

Il turno è **una coppia**: A dichiara il colpo e non si risolve, B dichiara la difesa, poi il motore risolve e si inverte. Le distanze sono **reali in metri**, il movimento vale ⌊Velocità÷10⌋×5, la gittata la impone il server. Le innate si accendono dentro lo scontro, il mantenimento si paga a ogni round (5/10/15/20 chakra dal livello 1 al 4), a secco cadono, a scontro chiuso si spengono tutte.

I comandi stanno **tutti fra parentesi quadre** dentro il testo dell'azione — `[bersaglio X]`, `[sposta ±N]`, `[schivata]` `[parata]` `[contrasto]`, `[guardia]` — e il parser è `_combat_leggi_comandi`, agganciato a `post_message`. ⚠️ **Due giocatori usano già `[Fine]`** di loro iniziativa: prima di aggiungere un comando nuovo si guarda cosa scrivono davvero.

---

## 5. Provare prima di applicare

Per sviluppo e prove mutanti usare PostgreSQL reale in Docker secondo AGENTS. L’esempio seguente vale esclusivamente in un ambiente isolato con identità sintetiche: mai impersonare utenti reali in produzione, nemmeno con ROLLBACK. Per il solo collaudo di funzioni già pubblicate usare i percorsi protetti delle Test Room, con l’autorizzazione permanente e i limiti previsti. Branch temporaneo solo per rischio motivato e costo autorizzato.

```sql
begin;
  select set_config('request.jwt.claims',
    json_build_object('sub','<uuid-utente>','role','authenticated')::text, true);

  -- ⚠️ i flag app.allow_* sono GUC LOCALI ALLA TRANSAZIONE e restano impostati
  -- per tutta la transazione: azzerarli PRIMA di testare la guardia,
  -- o il test passa per il motivo sbagliato.
  select set_config('app.allow_exp_delta',    '', true);
  select set_config('app.allow_vita_delta',   '', true);
  select set_config('app.allow_chakra_delta', '', true);
  select set_config('app.allow_points_delta', '', true);

  select * from premio_richiedi(...);   -- deve fallire o riuscire come previsto
rollback;
```

> ⚠️ **Il `rollback` va scritto davvero, e la prova deve stare dentro `begin; … rollback;`.**
> Un blocco `do $$ … $$;` mandato da solo **si autocommitta**: non è una prova, è una modifica.
> Il 29/07/2026 un test scritto così ha lasciato a database un premio `jinchuriki` finto su un personaggio vero.

**Per provare un privilegio si assume il ruolo:** `set local role anon;` … `reset role;`, con le chiamate dentro un blocco `exception when insufficient_privilege`, altrimenti il primo errore aborta la transazione e nasconde i test successivi.

Dopo un `INSERT` massivo, prima del `commit`: contare le righe inserite e verificare che i valori chiave siano quelli attesi.

### ⚠️ Tre cose che una prova in transazione NON dimostra

1. **Che il gioco funzioni.** Il motore di combattimento passava **tutte** le prove in rollback e aveva sei difetti, uno dei quali era una falla di sicurezza. L'SQL prova le funzioni una alla volta; il gioco le usa in sequenza, dentro un'interfaccia, con un giocatore che guarda. **Quando un sistema nuovo è pronto, la prova successiva è giocarci.**
2. **Che i default privilege siano cambiati.** Una funzione creata nella stessa transazione dell'`alter default privileges` non racconta la verità: la verifica si fa creando una funzione di prova **in una transazione diversa** — e quella sì si annulla col rollback.
3. **Che il client possa chiamare la funzione.** I test SQL girano come `postgres`, proprietario: passano anche senza il `GRANT` del §0. L'unico controllo che conta è `has_function_privilege('authenticated', 'public.f(tipi)', 'EXECUTE')`.

---

## 6. La prassi: una cosa a database esiste solo se si vede dal pannello

**Ogni volta che una migrazione aggiunge una categoria, un tipo o un campo, nella stessa sessione si aggiorna `admin.html`.** Non è una rifinitura da rimandare: una riga che Antonello non può né cercare né correggere dal pannello, per lui non esiste — e se ne accorge nel momento peggiore.

È successo due volte nello stesso giorno: le 35 righe `macro='cercoterio'` sono entrate mentre l'elenco tecniche aveva solo tre linguette, quindi erano invisibili; e `req_stat2` è nata senza il suo campo nel modulo, quindi valorizzabile solo da SQL. Entrambe hanno richiesto un secondo giro.

La lista di controllo, da scorrere **mentre si scrive la migrazione**:

| Cosa tocca la migrazione | Cosa serve |
|---|---|
| **Una funzione nuova chiamata dal client** | il **`GRANT EXECUTE`** nella stessa migrazione (§0) |
| Nuovo valore in un `CHECK` (macro, tipo di emblema, tipo di premio) | la **linguetta** o la **voce di menù**, l'etichetta col conteggio, il testo di «sezione vuota» |
| Nuova colonna che lo staff deve poter scrivere | il **campo nel modulo**, e il ciclo completo nei **quattro punti**: creazione · caricamento in modifica · salvataggio · reset. Un campo che si salva ma non si ricarica **cancella il valore alla prima modifica** |
| Nuova colonna che cambia il senso di una riga | l'**anteprima nell'elenco**, perché si veda senza aprire il modulo |
| Nuova colonna di `characters` non scrivibile dal giocatore | va pinnata in **`characters_guard`** (§3) |
| Nuovo tipo di emblema | la voce in **`EMB_EXTRA`** |
| Nuovo tipo di messaggio in chat | lo **stile** che lo distingue. ⚠️ `.msg-sys` è già presa: il motore usa `.msg-scontro` |
| Nuovo automatismo su un'azione dello staff | una **riga nel pannello** che lo dica: chi promuove deve sapere che sta anche consegnando tecniche e punti |

Vale anche al contrario: se una sezione del pannello promette qualcosa che a database non c'è, **si dice subito** invece di lasciarla come vetrina. **E se il Tavolo di Aiuto racconta una regola, quella regola deve esistere:** `help_kb` ha promesso per giorni «+50 punti a ogni promozione» e un tetto di 65 danni che nessuna funzione impone.

Per il metodo con cui si modifica la pagina — Python con `assert s.count(old) == 1`, controllo di sintassi sui blocchi `<script>`, bilanciamento dei tag — vedi la skill **`gdr-pagine`**.

---

## 7. Divieti specifici di questo progetto

- **Non si promuovono tecniche a leggendarie per soglia automatica.** La §7 di `migration_coerenza.sql` faceva questo su `req_stat_value >= 95`, ha promosso tre righe live per sbaglio ed è stata annullata: `[ANNULLATO IL 28/07/2026 — NON RIESEGUIRE]`. Le leggendarie sono **premi unici assegnati a mano**.
- **L'account `Riuji` non si tocca**: è l'admin.
- I warning dell'advisor «authenticated can execute SECURITY DEFINER» sono l'architettura del gioco (*l'IA racconta, il server comanda*), **non un difetto da correggere**. ⚠️ Dal 07/08 il conteggio è sceso, perché gli helper interni non sono più eseguibili dal client: quelli che restano riguardano le API vere.
- **Le quattro API pubbliche** del §0 non vanno private di `anon`.
- Le tecniche innate di clan e le leggendarie **non occupano slot**: se una query calcola slot occupati, deve escluderle.
- **Il regolamento non si piega al catalogo.** Se una migrazione scritta giorni prima contraddice `REGOLE.md`, la migrazione è vecchia: si corregge il catalogo, non le regole. Il 29/07 una bozza del 28 rimetteva a pagamento in XP 550 XP di code che §8.9 aveva deciso di far pagare in Sintonia.
- **`characters.pool_concesso` non si azzera** (§1).

---

## 8. Test Room utenti e Staff: percorsi reali, stato protetto

Le due stanze usano i percorsi applicativi del prodotto, nei rispettivi perimetri autorizzati. `is_test` da solo non garantisce isolamento e non autorizza cancellazioni, scritture sulle risorse reali o accessi staff nella stanza utenti. Non copiare la logica in un motore divergente; verificare il ramo effettivamente chiamato dalla funzione.

Conservare storico, messaggi e audit necessari. Il collaudo pertinente deve confrontare prima/dopo risorse, progressione ed effetti esterni; chiudere soltanto la propria prova salvo mandato di mantenerla aperta. Se una funzione scrive sulle risorse reali o aggira la protezione, fermare quel test e documentare il difetto: ripristinare dopo non equivale a isolamento.

Per sviluppo SQL e fault injection usare il banco PostgreSQL Docker con fixture sintetiche/sanitizzate. Per funzioni già pubblicate valgono direttamente le autorizzazioni protette di AGENTS, inclusi i due PG Staff e i limiti distinti dei provider. Nessun apply, deploy, enable o apertura generale è autorizzato dalla sola presenza di una stanza di prova.

---

## 9. La forma della risposta

Quando si propone un lavoro SQL, la risposta ad Antonello ha sempre queste parti:

1. **Cosa cambia**, in italiano, in poche righe — non il dump del SQL.
2. **Quante righe** tocca e in quali tabelle.
3. **Chi potrà eseguire** le funzioni nuove o modificate, e il `GRANT` che lo rende vero (§0).
4. **Se cambia una firma** chiamata dal frontend, e quindi quale pagina va rilasciata insieme.
5. **Quale parte di `admin.html`** serve perché la novità sia visibile e correggibile (§6).
6. **Se ho aggiunto — o allentato — di mia iniziativa un vincolo**, elencato a parte perché lui lo controlli. È una richiesta esplicita e permanente, e vale in entrambe le direzioni.
7. **Gate nominativo prima dell’esecuzione**: verificare l’autorizzazione pertinente già ricevuta; chiederla solo se manca o il perimetro cambia.

E alla fine, dopo l'esecuzione: cosa è andato a buon fine, cosa no, e **quali file vanno caricati su GitHub** perché il sito rifletta il cambiamento.

---

## 10. Le fonti, quando questa skill non basta

**Se un documento contraddice il database, ha ragione il database.** Questa skill è una memoria compatta e invecchia: i conteggi e gli elenchi vanno riverificati con la skill `gdr-verifica`.

La fonte completa e aggiornata dei vincoli, delle colonne e delle convenzioni è **`dossier/05_CONVENZIONI.md`**, §4 (vincoli), §5 (nomi che ingannano), §6 (colonne), §7 (SQL e grant), §16 (Test Room).
