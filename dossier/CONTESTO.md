# CONTESTO — la memoria compatta del progetto (gemello su disco della skill `gdr-contesto` v2 · 01/09/2026)

> Questo file è la copia su disco della skill Claude `gdr-contesto`, così che anche Codex parta dagli stessi numeri. **Regola: una skill si aggiorna in due posti** — nell'account Claude e qui — e chi la cambia lo scrive nel referto. Se il database contraddice questa pagina, vince il database e questa pagina va corretta. Per lo STATO dei lavori non basta: si apre la scheda d'area in `dossier/aree/` (tabella in `dossier/aree/00_COME_SI_USA.md`).

---

## 1. Cos'è il progetto, in dieci righe

«The Untold Story»: GDR play-by-chat **in italiano**, ambientazione Naruto alternativa. Punto di divergenza: la **Notte della Volpe**, dodici anni fa. Nessun personaggio canonico esiste nel presente. Beta aperta dal **01.08.2026**; al 01/09: 78 profili, 73 personaggi.

Frontend: pagine **HTML statiche e monolitiche**, `<style>` e `<script>` in linea, nessun framework, nessun build step. Hosting GitHub Pages — repo `antonello9311-design/theuntoldstory`, branch `main`, cartella `/(root)`. Dominio `https://theuntoldstory.it`.

Backend Supabase (`tyhyxkslteigibktluml`, EU-Frankfurt) via MCP: PostgreSQL con RLS, al 01/09 **230 tabelle** in `public` (93 vuote: fondazioni inerti di Training, Ninja Book, Missioni, Combat V2), **705 funzioni** di cui 594 `SECURITY DEFINER` usate come API, **15 Edge Function**, **13 job `pg_cron`**. Registro migrazioni: vedi `dossier/aree/PIATTAFORMA.md` (455 al 02/09).

Principio architetturale: **«l'IA racconta, il server comanda»** — nessun valore di gioco è deciso dal client o dall'IA.

**Caricamento GitHub autonomo dopo il gate.** Quando un lavoro approvato è pronto e verificato, Codex o Claude caricano i soli file del task su `antonello9311-design/theuntoldstory`, branch `main`, salvo scope `offline-only` o `no deploy`. Prima riconciliano la testa remota; dopo registrano commit, SHA e verifica del dominio. Vietati force-push, riscritture e commit cumulativi. Se manca l'accesso autenticato, si ferma soltanto il caricamento e si consegna la lista esatta. `sito_live/` **non è ciò che è pubblicato**: il registro resta `dossier/aree/PUBBLICAZIONE.md`.

---

## 2. I numeri del motore

### Creazione del personaggio (§3)
Otto caratteristiche: **Mente, Forza, Velocità, Resistenza, Ninjutsu, Genjutsu, Taijutsu, Fuuinjutsu**, più **Kekkei Genkai / Innata**. Base 10 ciascuna + **60 punti** da distribuire **a gruppi di 5**. Tetto a Deshi: **30**. Chi non eredita un cognome se lo sceglie (changelog 51).

### Tetti per grado (§8.4)
Deshi **30** · Genin **45** · Chunin **60** · Jonin **75** · Jonin Speciale **85** · Kage/Sannin **100**.

### Promozioni (§8.5-8.6)
XP di carriera: **2.500** → Genin · **9.000** → Chunin · **18.000** → Jonin. Ogni promozione dà **+50 punti caratteristica**. Deshi → Genin passa dall'**Esame Genin** (aperto agli utenti dal 23/08/2026).

### XP giornaliera degressiva (dal 28/07)
0–2.499 → **20** · 2.500–8.999 → **14** · 9.000–17.999 → **10** · 18.000+ → **7**.

### Il turno (§4.2)
Un movimento + un'azione principale + un'azione rapida + una reazione difensiva. Nel motore V2 un round è una coppia attacco/difesa con un solo racconto. Tipi di dichiarazione principale: `attacco`, `movimento` (±15 m), `utilita` (azione non offensiva, nessun effetto meccanico), `passa`.

### Distanze (§4.5-4.6)
Contatto **0–2 m** · Corta **3–10** · Media **10–30** · Lunga **30–60** · Fuori portata **>60**. Movimento = `⌊Velocità ÷ 10⌋ × 5` metri. Posizioni iniziali negli scontri: 0–60 m a passi di 5.

### Doppia chiave d'accesso alle tecniche (§5.2)
Servono **entrambe**: grado minimo **e** soglia di disciplina. D 10/50 XP · C 25/100 · B 40/150 · A 60/200 · S 80/250.
Chakra per grado: D **5** · C **10** · B **20** · A **30** · S **40**. Danno base per grado: **10 / 15 / 20 / 25 / 35 / 45** — **cap 65 per azione**. Il **grado E non fa danno**.

### Pool
```
PV     = 50 + Resistenza + bonus_grado        bonus: 0 / 10 / 25 / 45 / 60 / 80
Chakra = 30 + (Ninjutsu + Mente) × 1.2 + bonus_grado   bonus: 0 / 15 / 30 / 50 / 65 / 85
```

### Combattimento
```
atk_tot = somma_off/10 + 1d20 + mod + q
bonus di margine: 0 / 3 / 6 / 10
dmg = max(1, base + off/4 + mb − resistenza/red_div)
red_div = 20 (fisico) · 40 (ninjutsu)
contrasto = Velocità + Mente
danno fisico: usa max(Forza, Taijutsu)
tenuta = ⌊Resistenza ÷ 20⌋ + 1
```
V1.1 in produzione: striscio = ¼ del danno pieno (min 1); Slancio +3 fino a +9; Sostituzione ogni tre difese. Dal 01/09: Dispersione solo contro Genjutsu; Sostituzione solo da offerte spaziali server-side; Trasformazione è tecnica **solo di scena**; Moltiplicazione = Diversivo con copie difensive, 10 chakra + 5 per copia. Ordine di risoluzione: Velocità decrescente, poi estrazione casuale sigillata (il Master non lo governa).

### Regia Master V2 (§4.8)
Il Master di una sessione **non può essere anche attore PG** del proprio scontro — **salvo zona franca**: staff in luogo `is_test` (dal 02/09). I PNG di regia umana vengono da `png_templates` attivi; i PNG del Ninja Book da offerte del servizio missioni. Un luogo ammette un solo scontro aperto. «Chiudi scena» (dal 02/09) chiude senza KO; le missioni con `mission_id` si chiudono solo con «Chiudi attività» e un esito.

### Cura (§6.2, dal 28/08)
Solo un medico che ha **appreso** il Palmo Curativo (grado C, 100 XP): nessun pulsante in chat, nessuna soglia di Mente. (Mente + Ninjutsu) ÷ 3, contatto, 20 chakra, turno consumato.

### Slot tecniche
Base per grado: Deshi/Genin **5** · Chunin **7** · Jonin **9** · Jonin Speciale **11**. Bonus `+⌊Mente/20⌋` (max +5). Acquistabili fino a **4** slot a **200 / 350 / 500 / 650** XP. **Innate di clan e leggendarie non occupano slot; una tecnica in addestramento riserva lo slot.**

### Allenamento (§6.1, Training V2 dal 26/08)
Si impara una tecnica in una role: una riga per personaggio (mai di coppia); individuale, cooperativa, gruppo; giornata 06:00–05:59; l'abbandono non rimborsa; sparring non letale ma PV e chakra spesi restano; **l'IA non decide**.

### Missioni
XP: D **40** · C **60** · B **90** · A **130** · S **180**. Ryo: D **50** · C **100** · B **150** · A **250** · S **400**. **Il Ryo è l'unica valuta.**

### Altro
Allineamento (§8.7): tre assi 0–100. **«Una sola corporazione per personaggio»** (§8.8). Forze Portanti e Cercoteri: §8.9.

---

## 3. I premi — listino verificato a database (tabella `premi`, 01/09/2026)

La divisione **non è il prezzo, è chi scrive il contenuto**.

**Strada dell'acquisto** (`valutazione: false`): `evocazione` **600** (**300** via corporazione) · `punti_caratteristica` per gradino: Genin **200** · Chunin **400** · Jonin **600** · Jonin Speciale **800** · Kage/Sannin **1000** (+15 punti, concessi SOLO dal trigger `trg_perk_punti_caratteristica`; il gradino va passato a `premio_acquista`).

**Strada della valutazione** (`valutazione: true`, XP addebitati all'approvazione): `tecnica_personale` D **115** / C **225** / B **340** / A **450** / S **565** · `tecnica_segreta` **375** · `sigillo_maledetto` **750** · `tecnica_proibita` **900** · `evocazione_leggendaria` **1200** · `cinque_nature` **1500** · `jinchuriki` **1800** · `tecnica_leggendaria` **0** · `sharingan_eterno` **0** (solo staff, Jonin Speciale, solo a un Uchiha).

⚠️ **`seconda_natura` NON è un premio**: la seconda natura è gratuita al Jonin. Tetto: **2 premi maggiori a vita**; il **Jinchūriki occupa entrambi** ed **esclude il clan**. Le leggendarie sono premi unici, svincolati dalla progressione XP.

---

## 4. I nove clan

**Aburame · Akimichi · Dokugan · Hyuga · Inuzuka · Marionettisti · Nara · Sabaku · Uchiha.** Innate di livello 1-4 alle soglie KG **30 / 50 / 70 / 80**. Chiusi, assegnati dallo staff: **Hyuga, Uchiha, Sabaku**; gli altri via `clan_join_open`.

Programma Clan L1 (gate OFF): l'Innata L1 ha un controllo server-side Attiva/Spegni che **non consuma l'azione principale**; Byakugan attivazione/upkeep 5, spegnimento gratuito, raggio 10 m, Jūken e 16 Chiusure separati; Sabaku Innata separata da Scudo/Clone/Trasporto. Le 36 righe innate sono un modello unico.

**Uchiha**: livello 4 sblocca **una sola** variante S (Susanoo, Amaterasu, Kamui, Tsukuyomi). Le tecniche segrete richiedono lo **Sharingan Eterno** (ottenuto in gioco; cancella il malus di cecità; sblocca Susanoo Perfetto o Kotoamatsukami).

---

## 5. Evocazioni

Cinque taglie obbligatorie: `baby` → `piccola` → `media` → `grande` → `leggendaria` (il DB rifiuta `minore`/`intermedia`/`superiore`). Richiamo: 3+1+1+1+4 = **10 allenamenti**. Sei famiglie: **Rospi, Serpenti, Rapaci, Rettili, Lumache, Scimmie**; **canidi esclusiva Inuzuka**. Si evoca col jutsu del Richiamo dopo un contratto.

---

## 6. Vincoli del database — alla lettera

```
clan_tech_attivazione_chk        CHECK (attivazione IS NULL OR attivazione IN ('istantanea','sigilli'))
clan_tech_gittata_chk            CHECK (gittata IS NULL OR gittata IN ('contatto','corta','media','lunga'))
clan_techniques_consumption_type_check  CHECK (consumption_type IN ('ad_utilizzo','per_turno','passiva'))
clan_techniques_macro_chk        CHECK (macro IN ('clan','generica','abilita','evocazione'))
character_abilities_state_check  CHECK (state IN ('in_addestramento','attiva'))
character_abilities_character_id_technique_id_key   UNIQUE (character_id, technique_id)
academy_lesson_script_pkey       PRIMARY KEY (lesson_id, step, village)
character_jutsu_user_id_jutsu_id_key                UNIQUE (user_id, jutsu_id)
lesson_grants_pkey               PRIMARY KEY (lesson_id, jutsu_id)
master_v2_sessions.stato         IN ('preparazione','in_corso','sospesa','chiusura','chiusa','annullata')
combat_v2_sessions.state         IN ('preparazione','in_corso','sospeso','risolto','chiuso','annullato')
combat_v2_rounds.state/phase     IN ('raccolta_azioni','raccolta_difese','congelato','valutazione','risoluzione','risolto','narrazione','narrato')
```
Passive: `consumption_type='passiva'` con `attivazione='istantanea'`; `'sguardo'` e `'passiva'` per `attivazione` vengono rifiutati. `messages.kind` vale `say`, `fato`, `sistema`.

### Nomi di colonna che ingannano
`clan_techniques.descr` → **`description`** · `missions.rank` → **non esiste** · `locations.village` → **non esiste** (c'è `region`) · `academy_lessons.ord` → **`ordinal`** · `premi.costo_xp` → **`costo`** · `emblems.type` → **`kind`**.

### Colonne di `clan_techniques` (355 righe)
`id, clan, name, level, category, description, requirements, consumption_type, chakra_cost, is_active, sort, created_at, grado, portata, bersaglio, tipo_azione, durata, ricarica, danno_effetto, xp_cost, trainings_required, req_grade, req_stat, req_stat_value, danno_base, is_innata, macro, req_elements, potenza, disciplina, gittata, attivazione, req_corp, req_ramo, is_leggendaria, gruppo_esclusivo, ramo_esclusivo, req_perk, req_tecnica, req_cercoterio, req_stat2, req_stat2_value, req_elements_mode, req_famiglia, req_taglia, uso, difensiva, di_scena, colpisce_formazione, rivela_originale` — `uso`, `difensiva`, `di_scena` decidono come una tecnica entra nel combattimento.

### Tipi di emblema (`emblems.kind`)
`bijuu, clan, corp, corpgrade, corpspec, element, evofam, rank, village` — `evofam` esiste a database; manca solo in `EMB_EXTRA` di `admin.html`.

---

## 7. Costanti lato client

`SB_URL = 'https://tyhyxkslteigibktluml.supabase.co'`, `SB_KEY = 'sb_publishable_…'`. `admin.html`: `EMB_EXTRA = {village, clan, rank, element, corp, corpspec, corpgrade, bijuu}` (manca `evofam`). `BIJUU = ['Shukaku','Matatabi','Isobu','Son Gokū','Kokuō','Saiken','Chōmei','Gyūki','Kurama']`. `CORP_SPEC_OPTS = { anbu:[infiltrazione, pedinamento, assassinio, sensoriale], medici:[chirurgia, tossicologia, cura-campo, combattimento] }`.

Edge Function vive (02/09): `login-name` · `delete-account` · `academy_sensei_ai` · `academy_audit_ai` · `land_help_ai` · `combat_narratore_ai` · `exam_genin_ai` · `test_room_ai` · `exam_live_qa_worker_131q` · `ninja_book_test_room_canary` · `training_sensei_ai` (spenta) · `mission_narratore_ai` · `nodo_azzurro_canary_coordinator` · `png_media_attest_v1` · `mission_ai_board_opening`. Provider unico `gpt-5.6-luna`, reasoning high. Cron: elenco in `dossier/aree/PIATTAFORMA.md`.

⚠️ **Per fermare l'IA dell'Esame si svuota `academy_ai_runtime.tick_token`, MAI il job `esame-tick`** (fa anche ripiego a 3′, secondo tentativo a 90″, chiuditore a 3 h).

---

## 8. Convenzioni di contenuto

Tutti i valori visibili sono **multipli di 5**. Nomi delle tecniche **in italiano**, romaji nel campo apposito. Tecniche vere e personali partono da grado D e grado minimo Genin. **I Deshi imparano solo i jutsu accademici, tramite lezioni.** «**coprifronte**», mai «fascia frontale»; «**Cercoteri**», mai «bijū» nei testi di gioco. «Personalizzazioni» non è un jutsu. I tag ✦ nelle missioni sono solo per lo staff; le «Note per lo sviluppo» non si pubblicano. Non si abbinano nomi a divisioni/rami/gradi se non richiesto.

---

## 9. Dove sta la verità, e come si leggono i file pesanti

① il **database di produzione**; ② **`sito_live/REGOLE.md`** per il regolamento (changelog numerato solo lì; ultima riga **73**; **il numero libero si legge nel file vivo**); ③ le schede d'area `dossier/aree/*.md` per lo stato; ④ le specifiche in `claude/…` per le intenzioni di design (possono essere superate).

**Da dove si parte:** `AGENTS.md` → `dossier/00_LEGGIMI.md` → `dossier/aree/00_COME_SI_USA.md` → la scheda dell'area. `01_STATO_ATTUALE`, `03_CRONOLOGIA` e `04_LAVORI_APERTI` sono diari da 2.500 righe: solo con `grep` o per l'ultima sezione. `05_CONVENZIONI.md` prima di scrivere codice o SQL.

📖 **Non si legge mai un file intero se non è strettamente necessario.** In particolare: `claude/backup_db_ultimo.json` (529 KB), `claude/pagina_*.html` (fino a 349 KB), i pack PM in `management/coordination/` (fino a 519 KB), `REFERTO-2026-09-01-CODEX.md` (224 KB). Si localizza con `grep -n` e si legge solo l'intervallo.

---

## 10. Regole non negoziabili

- Nessuna modifica a codice o database **senza approvazione**; per i cambiamenti sostanziali prima il piano.
- **Nessuna cancellazione.** Nessun comando distruttivo, reset, force-push o riscrittura della storia. Commit e push sono ammessi solo per i file verificati del task secondo il gate GitHub; per disattivare: `is_active = false`.
- Mai leggere o stampare `.env`, chiavi, token, credenziali, dump. `ANTHROPIC_API_KEY` e `OPENAI_API_KEY` mai in chat né nel codice.
- `REGOLE.md` e `regole.html` cambiano **sempre insieme** (skill `gdr-regole-sync`).
- Ogni vincolo aggiunto **o allentato** va segnalato esplicitamente.
- **Una domanda senza risposta non è una decisione presa.**
- Niente `curl`/`wget`/fetch programmatici: solo WebFetch/WebSearch o gli strumenti browser, e in Chrome solo la tab già aperta da Antonello.
- **Copyright:** dal sito di riferimento solo idee meccaniche, mai testo; emblemi e illustrazioni li genera e carica Antonello.
- **Un file, un owner alla volta.** Se un file è cambiato da quando l'hai letto, c'è un'altra sessione: fermati.
- **Nessuna decisione operativa vive solo in un handoff**: cron, flag, gate, versioni vanno nella scheda d'area.

### Da non toccare, mai
L'account **`Riuji`** · le **14 classi CSS** costruite per concatenazione in JS · la **§7 di `migration_coerenza.sql`** · la protezione password compromesse di Supabase (spenta per scelta) · i **~139 warning** advisor su `SECURITY DEFINER` (sono l'architettura) · il job `esame-tick`.

---

## 11. Le skill Claude (invisibili a Codex: questo file e `AGENTS.md` sono il ponte)
`gdr-rotta` (scheda d'area giusta, per prima) · `gdr-contesto` (questo testo) · `gdr-regole-sync` · `gdr-sql` · `gdr-pagine` · `gdr-verifica` · `gdr-chiusura` (riscrive la scheda d'area, mai appende).
