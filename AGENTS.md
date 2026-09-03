# AGENTS.md — The Untold Story  ·  v2 (attivo dal 02/09/2026)

> Vale per Codex e per Claude (Claude Code lo importa da `CLAUDE.md`; Claude Cowork lo legge dalle istruzioni del progetto e dalle skill `gdr-rotta`/`gdr-contesto`, il cui gemello su disco è `dossier/CONTESTO.md`). Il precedente è in `dossier/storico/AGENTS_v1_2026-08-07.md`.
>
> **Transizione (finché la struttura per cantieri non è completa):** «`lavori/<CANTIERE>/`» si legge «`management/candidati/<CANTIERE>/`» e «`sito/`» si legge «`sito_live/`». I cantieri correnti sono `management/candidati/CLAN-L1_2026-09-01/` e `COMBAT-COMPOSITE_2026-09-01/`.

## Prima di tutto
1. Leggi `dossier/00_LEGGIMI.md` (una pagina), `dossier/CONTESTO.md` (i numeri del gioco e del database, a memoria) e il tabellone `dossier/04_LAVORI_APERTI.md` (una pagina).
2. Individua l'AREA del task con la tabella in `dossier/aree/00_COME_SI_USA.md` e leggi `dossier/aree/<AREA>.md`. Apri le fonti che elenca, nell'ordine, e SOLO il blocco che serve (`grep -n` + intervallo di righe; mai un file intero).
3. Se il task ha un cantiere, leggi `lavori/<CANTIERE>/SCHEDA.md` e `HANDOFF.md`.
4. Prima di dichiarare lo stato del backend, interroga il database. Il DB vince su ogni documento; il sito pubblicato vince su `sito/`.

## Dove si scrive
- Solo dentro `lavori/<CANTIERE>/` del task assegnato, e nella scheda della sua area (`dossier/aree/<AREA>.md`, sezioni «Stato vivo», «Lavori aperti», «Prossimo passo»).
- Mai creare cartelle di primo livello. Mai aprire un cantiere senza mandato del PM.
- Mai creare una cartella `_r2`, `_r3`, `_offline`, `_review` accanto a un'altra: la revisione SOSTITUISCE `candidato/` e `referti/`; la precedente va in `_precedenti/<data>_<rev>/` dentro lo stesso cantiere.
- `sito/` si tocca solo dopo aver riconciliato il file con la copia pubblicata su GitHub, e ogni modifica aggiorna la riga del file in `dossier/aree/PUBBLICAZIONE.md` (build, byte, SHA-256, «da caricare»).
- Il dossier si RISCRIVE in posto. Vietati: file datati (`STATO_*`, `handoff_*`, `TODO_*`), sezioni «Rettifica del…», appendici in coda, la lettura per intero delle copie pesanti in `claude/`.

## Cosa consegna ogni task
- `SCHEDA.md` del cantiere aggiornata; stato nella prima riga: proposto / in lavoro / applicato inerte / in uso / chiuso / parcheggiato.
- `HANDOFF.md` sovrascritto nel formato: TASK-ID · Scope toccato · Contratti usati/modificati · Decisioni prese / OPEN · Prove eseguite e risultato · Rischi o regressioni da verificare · Passaggio richiesto al PM.
- Una riga in `STORICO.md`: data · revisione · una frase · esito.
- Se ha cambiato lo stato operativo (cron acceso/spento, flag, gate, versione Edge, migrazione a registro): la riga corrispondente in `dossier/aree/<AREA>.md` §Stato vivo e, per le migrazioni, in `dossier/aree/PIATTAFORMA.md`. Una decisione scritta solo nell'handoff non esiste.

## Limiti
- Al massimo TRE cantieri «in lavoro». Se sono tre, il task nuovo non parte: si segnala al PM.
- «In uso» lo dichiara solo Antonello. «Chiuso» e «parcheggiato» spostano la cartella intera in `archivio/`. Un cantiere «applicato inerte» da più di sette giorni senza una data di prova diventa «parcheggiato» nel tabellone.
- Un file, un owner alla volta. Se un file che stai per scrivere è cambiato da quando l'hai letto, fermati: c'è un'altra sessione.
- Nessun apply a database finché la review indipendente non è `0/0/0` e senza l'autorizzazione nominata di Antonello. L'apply DB non autorizza consumer, Edge, enable, dati, sessioni o canary.

## Invarianti (non negoziabili)
- Italiano, sempre. «L'IA racconta, il server comanda»: nessun valore di gioco dal client o dall'IA.
- Nessuna modifica a codice applicativo o database senza approvazione esplicita; per i cambiamenti sostanziali prima il piano.
- Nessuna cancellazione: `is_active=false`, mai DELETE. Vietati reset, force-push, riscritture della storia e commit che includano file estranei. **Il caricamento GitHub è autonomo quando il lavoro è pronto**: l'approvazione del lavoro copre commit e push dei soli file verificati, salvo scope `offline-only`, `no deploy` o divieto esplicito. Prima del push si riconcilia la testa remota, si controllano owner e drift e si escludono segreti; dopo il push si registra commit e verifica del dominio. Se manca un canale GitHub autenticato, si ferma solo il caricamento e si consegna la lista esatta.
- `REGOLE.md` e `regole.html` cambiano insieme, con changelog numerato solo nel markdown; il numero libero si legge nel file vivo, non da una skill.
- Mai leggere o stampare `.env`, chiavi, token, dump, credenziali. Non toccare l'account Riuji, le 14 classi CSS generate per concatenazione in JS, la §7 di `migration_coerenza.sql`, la protezione password di Supabase (spenta per scelta).
- Per fermare l'IA dell'Esame si svuota `academy_ai_runtime.tick_token`; MAI spegnere il job cron `esame-tick` (spegne anche ripiego, secondo tentativo e chiuditore).
- Ogni funzione nuova ha il GRANT esplicito o resta invisibile al client. Ogni vincolo aggiunto o allentato va elencato esplicitamente.

## Flusso GitHub: pronto → verifica → caricamento
- Repository: `antonello9311-design/theuntoldstory`, branch `main`. Nessun force-push e nessun caricamento cumulativo indiscriminato.
- I file di `sito_live/` si pubblicano nella **root** del repository con lo stesso nome; `dossier/`, `management/` e le altre sorgenti mantengono il percorso relativo. SQL ed Edge caricati su GitHub restano solo sorgenti: non autorizzano apply o deploy Supabase.
- Prima del caricamento: verifica di test/review richiesta dal cantiere, confronto con la versione remota, controllo che il file non sia cambiato dall'ultima lettura e staging dei soli percorsi appartenenti al task.
- Dopo il caricamento: registrare commit/link e SHA in `dossier/aree/PUBBLICAZIONE.md`; per i file del sito verificare il dominio e il marcatore di build. Conflitto, drift o autenticazione assente = STOP del solo caricamento, senza sovrascrivere.

## Flusso database: locale → branch Supabase → produzione
- PostgreSQL locale serve solo per unit test, controlli statici e fault injection non rappresentabile sul branch; non sostituisce il gate integrato.
- Un branch QA Supabase **attivo, healthy e allineato alla head di produzione** è obbligatorio per migrazioni, integrazione, rollback/recovery, race e advisor. Si usa con sessione/workdir isolati: il link o la configurazione CLI principale della produzione non si altera.
- Se il data-plane del branch è assente, unhealthy o non allineato, **STOP**: prima si riallinea il branch. Un'anomalia del solo control plane (`MIGRATIONS_FAILED` stale a prove complete) richiede un'eccezione PM esplicita e documentata per quel rilascio; non vale come precedente. Non si ripiega su prove mutanti in produzione, neppure dentro transazioni con `ROLLBACK`.
- Review indipendente `0/0/0` e prove branch verdi precedono il gate produzione. In produzione sono ammessi soltanto preflight in sola lettura, un singolo apply/deploy esplicitamente autorizzato e postflight/smoke minimo.
- Nessun secret, password, token, chiave o URL credenziale va letto, stampato o depositato nei file.

## Owner e reviewer
| Scope | Owner | Reviewer |
|---|---|---|
| `land.html` | LAND-UI | COMBAT-CORE / QA |
| `scheda.html` | SCHEDA-UI | DB-CORE / QA-PLAYTEST |
| `admin.html` | ADMIN-CONTENT | DB-CORE |
| `REGOLE.md`, `regole.html`, guida, dossier | RULES-LORE | PM |
| database, RLS, RPC, trigger, cron | DB-CORE | PM |
| combattimento e parser | COMBAT-CORE | DB-CORE |
| Accademia IA, narratori, Edge Function | ACADEMY-AI / NARRATIVE-AI | DB-CORE |
| accesso, privacy, email | ACCOUNT-PRIVACY | DB-CORE |
| banchi, sonde e playtest | QA-PLAYTEST | owner del dominio |

Se il lavoro esce dal tuo scope, fermati e passa una richiesta al PM. Una modifica a un contratto client/server richiede owner DB, PM e consumer interessati.

## Imported Claude Cowork project instructions

Lavori sul GDR «The Untold Story» (theuntoldstory.it, Supabase tyhyxkslteigibktluml). Si scrive e si ragiona in italiano.

All'inizio di ogni conversazione, prima di rispondere: 1) leggi `AGENTS.md` nella radice della cartella (le regole valgono per te come per Codex); 2) leggi `dossier/CONTESTO.md` (i numeri del gioco e del database) e `dossier/01_STATO_ATTUALE.md` + `dossier/04_LAVORI_APERTI.md` (una pagina ciascuno); 3) individua l'area del task con la tabella in `dossier/aree/00_COME_SI_USA.md` e apri la scheda `dossier/aree/<AREA>.md`; poi le fonti che elenca, nell'ordine, solo nel blocco che serve. Le skill `gdr-rotta` e `gdr-contesto` fanno lo stesso: seguile.

Il database di produzione vince su ogni documento; il sito pubblicato vince su `sito_live/` (registro in `dossier/aree/PUBBLICAZIONE.md`). Prima di dichiarare lo stato del backend, interrogalo (skill `gdr-verifica`). Non leggere mai per intero le copie pesanti in `claude/pagina_*.html`, `backup_db_ultimo.json`, i pack PM o i referti da centinaia di KB: `grep -n` e intervallo di righe.

Regole non negoziabili: nessuna modifica a codice applicativo o database senza approvazione esplicita (per i cambiamenti sostanziali prima il piano, poi attendi); nessuna cancellazione di file e nessun comando distruttivo; vietati reset, force-push, riscritture della storia e commit con file estranei; per disattivare `is_active=false`, mai DELETE. Quando il lavoro approvato è pronto e verificato, Codex o Claude caricano autonomamente su GitHub i soli file del task, salvo scope `offline-only`/`no deploy`; prima riconciliano la testa remota e dopo registrano commit, SHA e verifica. Se manca un canale autenticato si ferma solo il caricamento. `REGOLE.md` e `regole.html` cambiano insieme, changelog numerato solo nel markdown, numero libero letto nel file vivo; ogni vincolo aggiunto o allentato va dichiarato; una domanda senza risposta non è una decisione; mai leggere o stampare .env, chiavi, token, dump; non toccare l'account Riuji, le 14 classi CSS generate in JS, la §7 di migration_coerenza.sql, il job cron esame-tick (per fermare l'IA dell'Esame si svuota `academy_ai_runtime.tick_token`). Ogni funzione nuova ha il GRANT esplicito. Niente curl/wget/fetch: solo WebFetch/WebSearch o gli strumenti browser, e in Chrome solo la tab già aperta da Antonello.

Dove si scrive: solo nel cantiere del task (`management/candidati/<CANTIERE>/`, revisioni che sostituiscono, mai cartelle `_r2`/`_offline`/`_review` affiancate) e nella scheda d'area; al massimo tre cantieri in lavoro; nessun cantiere senza mandato. Il dossier si riscrive in posto: vietati file datati e sezioni «Rettifica del…». Ogni decisione operativa (cron, flag, gate, versione Edge, migrazione) va nella scheda d'area §Stato vivo, non solo nell'handoff.

A fine sessione applica `gdr-chiusura`: riscrivi Stato vivo / Lavori aperti / Prossimo passo della scheda toccata, aggiorna `PUBBLICAZIONE.md` con file, SHA, commit e verifica GitHub; la lista finale distingue i file già caricati da quelli bloccati per autenticazione, conflitto o scope. Se una prova fallisce, segnala nella scheda (data, passi, visto/atteso, gravità), non in un file nuovo. Antonello non è un programmatore: spiega cosa fai e perché, in prosa, prima di farlo.
Leggi cartella prima di partire e adopera il sistema indicato per operare
