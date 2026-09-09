---
name: gdr-verifica
description: "Usa questa skill quando serve verificare lo stato attuale del database del GDR The Untold Story; non richiede una scansione generale per task solo documentali o di coordinamento. Contiene cinque interrogazioni brevi che fotografano lo stato reale (conteggi per tabella, tecniche per clan, evocazioni, emblemi bijū, colonne Cercoteri) e la regola che vale sopra tutte: se un documento contraddice il database, ha ragione il database."
---

# gdr-verifica — fotografare lo stato reale

**Metodo vigente di progetto:** dalla cartella The Untold Story seguire `AGENTS.md` e `management/coordination/AVVIO_LAVORO.md` per mandato, owner, prenotazioni, budget e consegna. Questa skill conserva i dettagli tecnici del proprio dominio; non assegna file né riapre task o autorizzazioni. Preparare gli output in copia e integrarli con il guard del progetto; i gate di produzione restano distinti.


**Il principio:** un documento dice cosa era stato deciso; il database dice cosa esiste. Fra i due vince sempre il database. Cinque query costano pochi token e hanno già evitato più di una volta di «completare» qualcosa che non era mai stato eseguito — è così che si è scoperto che `migration_cercoteri.sql` era scritta ma mai lanciata.

Eseguire soltanto le interrogazioni pertinenti usando lo strumento Supabase di sola lettura disponibile nella sessione sul progetto **`tyhyxkslteigibktluml`**. Sono tutte in sola lettura: non richiedono approvazione.

---

## Le cinque interrogazioni

### 1 · Conteggi generali — il polso del progetto

```sql
select 'characters' t, count(*) n from characters
union all select 'clan_techniques', count(*) from clan_techniques
union all select 'jutsu',           count(*) from jutsu
union all select 'missions',        count(*) from missions
union all select 'academy_lessons', count(*) from academy_lessons
union all select 'premio_richieste',count(*) from premio_richieste
union all select 'character_abilities', count(*) from character_abilities
union all select 'emblems',         count(*) from emblems
order by 1;
```

Attesi a fine luglio 2026: ~238 tecniche di clan, 20 missioni, 0 richieste di premio (normale: la land non ha ancora giocatori).

### 2 · Tecniche per clan e per livello — dove ci sono buchi

```sql
select clan, count(*) tot,
       count(*) filter (where is_innata)      innate,
       count(*) filter (where is_leggendaria) leggendarie,
       count(*) filter (where not is_active)  disattivate
from clan_techniques
group by clan
order by clan;
```

I clan sono nove: Aburame, Akimichi, Dokugan, Hyuga, Inuzuka, Marionettisti, Nara, Sabaku, Uchiha. Un clan assente dal risultato è un clan senza tecniche.

### 3 · Evocazioni — la fase 2 è stata eseguita?

```sql
select coalesce(gruppo_esclusivo,'(nessuno)') famiglia,
       count(*) n,
       min(trainings_required) all_min,
       max(trainings_required) all_max
from clan_techniques
where macro = 'evocazione'
group by 1
order by 1;
```

**Zero righe = fase 2 mai eseguita.** Attese a regime: le 5 righe della scala del Richiamo (3+1+1+1+4 = 10 allenamenti) più ~36 tecniche di famiglia su sei famiglie (Rospi, Serpenti, Rapaci, Rettili, Lumache, Scimmie; i canidi sono esclusiva Inuzuka).

### 4 · Emblemi — quanti bijū e quali tipi esistono

```sql
select kind, count(*) n
from emblems
group by kind
order by kind;
```

Attesi **9** con `kind='bijuu'` (Shukaku, Matatabi, Isobu, Son Gokū, Kokuō, Saiken, Chōmei, Gyūki, Kurama). Se ce n'è **1**, è stata applicata solo `cercoteri_fase1_emblems_kind_bijuu`, che aggiunge il tipo ma non gli slot.
Verificare anche se compare **`evofam`**: serve per le sei famiglie di evocazione, e va aggiunto in parallelo a `EMB_EXTRA` in `admin.html`.

### 5 · Cercoteri — le colonne esistono davvero?

```sql
select column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and table_name  = 'characters'
  and (column_name ilike '%bij%' or column_name ilike '%cerc%'
       or column_name ilike '%jinch%' or column_name ilike '%possess%')
order by column_name;
```

**Zero righe = `claude/migration_cercoteri.sql` non è mai stata eseguita**, per quanto il file esista e sia completo. È esattamente il caso rilevato il 29/07.

---

## Verifiche mirate, quando servono

**La migrazione X è passata?**

```sql
select version, name from supabase_migrations.schema_migrations
order by version desc limit 15;
```

**Una funzione RPC esiste e con quale firma?** (utile prima di cambiare una pagina che la chiama)

```sql
select p.proname, pg_get_function_identity_arguments(p.oid) args
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.prokind = 'f'
  and p.proname in ('companion_create','premio_richiedi','training_start','clan_join_open')
order by 1;
```

⚠️ `p.prokind = 'f'` è obbligatorio: senza, `array_agg` fa fallire la query con «is an aggregate function».

**Il bug Sabaku del `req_stat_value`** (soglia irraggiungibile rispetto al tetto di grado):

```sql
select name, req_grade, req_stat, req_stat_value
from clan_techniques
where clan = 'Sabaku' and req_stat_value is not null
order by req_stat_value desc;
```

Tetti da confrontare: Deshi 30 · Genin 45 · Chunin 60 · Jonin 75 · Jonin Sp. 85 · Kage/Sannin 100.

---

## Come si riporta il risultato

In italiano, in poche righe, **con il confronto fra atteso e trovato**, non con il dump della tabella. Esempio:

> Evocazioni: 0 righe con `macro='evocazione'` — la fase 2 non è mai stata eseguita. Emblemi bijū: 1 su 9. Colonne Cercoteri su `characters`: nessuna, quindi `migration_cercoteri.sql` è ancora da lanciare.

Se il risultato contraddice un documento del progetto, dirlo esplicitamente e indicare quale documento è ormai fermo: serve per aggiornare `dossier/01_STATO_ATTUALE.md` a fine sessione (vedi `gdr-chiusura`).
