# AGENTS.md — The Untold Story · v3 · avvio uniforme dal 09/09/2026

> Vale per Codex e per Claude (Claude Code lo importa da `CLAUDE.md`; Claude Cowork lo legge dalle istruzioni del progetto e dalle skill `gdr-rotta`/`gdr-contesto`, il cui gemello su disco è `dossier/CONTESTO.md`). Il precedente è in `dossier/storico/AGENTS_v1_2026-08-07.md`.
>
> **Transizione (finché la struttura per cantieri non è completa):** «`lavori/<CANTIERE>/`» si legge «`management/candidati/<CANTIERE>/`» e «`sito/`» si legge «`sito_live/`». I cantieri correnti sono `management/candidati/CLAN-L1_2026-09-01/` e `COMBAT-COMPOSITE_2026-09-01/`.

## Prima di tutto
0. Punto 1 = consolidamento documentale; punto 2 = processo operativo. Per ogni nuovo incarico o ripresa applica `management/coordination/AVVIO_LAVORO.md`. Il PM trasforma l’idea dell’utente in scope, dipendenze, owner e verifica; non riapre automaticamente il backlog o task archiviate. Le analisi restano letture; per scrivere acquisisci file e risorse nel registro condiviso `management/tooling/task_guard.py` con la stessa root canonica per tutte le sessioni. Per incarichi dipendenti usa il piano e i briefing di task_plan.py secondo AVVIO; registra ogni consumer solo quando i suoi input sono pronti. Il processo è coordinamento cooperativo locale, non un permesso di produzione né una garanzia contro editor esterni.
1. Leggi `dossier/00_LEGGIMI.md` (una pagina), `dossier/CONTESTO.md` (i numeri del gioco e del database, a memoria) la fotografia `dossier/01_STATO_ATTUALE.md` e il tabellone `dossier/04_LAVORI_APERTI.md`.
2. Individua l'AREA del task con la tabella in `dossier/aree/00_COME_SI_USA.md` e leggi `dossier/aree/<AREA>.md`. Apri le fonti che elenca, nell'ordine, e SOLO il blocco che serve (`grep -n` + intervallo di righe; mai un file intero).
3. Se il task ha un cantiere, leggi `lavori/<CANTIERE>/SCHEDA.md` e `HANDOFF.md`.
4. Prima di dichiarare lo stato del backend, interroga il database. Il DB vince su ogni documento; il sito pubblicato vince su `sito/`.

## Dove si scrive
- Solo dentro `lavori/<CANTIERE>/` del task assegnato, e nella scheda della sua area (`dossier/aree/<AREA>.md`, sezioni «Stato vivo», «Lavori aperti», «Prossimo passo»).
- Per incarichi PM di solo metodo/coordinamento, autorizzati dall’utente, usare i percorsi assegnati in `management/coordination/`, `management/tooling/`, dossier e istruzioni di avvio; non aprire un quarto cantiere di prodotto. Il registro non cambia gli stati documentali dei cantieri.
- Prima della scrittura: register → claim → check. Preparare gli output in copia e integrarli con `apply` del guard; generatori e contributi da worktree producono candidati isolati. Rilasciare le prenotazioni solo dopo consegna verificata. File/contratti condivisi, browser e rilascio hanno un owner alla volta; nessun furto automatico di prenotazioni scadute. Dettagli e limiti nel documento di avvio.

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

## Metodo di avanzamento e QA empirico
- Prima si completa un candidato coerente end-to-end sui requisiti e sulle invarianti conosciute; non si tenta di prevedere per ore ogni possibile difetto narrativo o di interazione.
- Il QA usa prioritariamente casi reali già conclusi e autorizzati — per l'Esame, gli esami già svolti — come corpus sanitizzato e immutabile. Non si copiano nei referti PII o testi completi delle role.
- Su PostgreSQL reale in Docker si esegue l'intera matrice prevista sulla stessa revisione; un branch Supabase temporaneo si usa solo per rischi d'integrazione non verificabili adeguatamente in locale, secondo il Flusso database approvato il 09/09/2026. Budget, review e criteri di esito restano gli stessi; differenze di ambiente e limiti delle prove vanno documentati, senza equiparare mock e runtime reale. Un caso rosso blocca pubblicazione e produzione, ma non interrompe la raccolta degli altri casi, salvo P0, rischio dati/sicurezza, superamento del budget o mutazione non prevista.
- I finding della campagna si raccolgono insieme, si raggruppano per causa sistemica e producono una revisione aggregata per ciascun passaggio di ricertificazione completa, entro il limite cumulativo indicato sotto. Vietati micro-revisioni per singolo campione, liste di sinonimi ad hoc e retry usati per cercare casualmente un risultato verde.
- **Budget di revisione vincolante — aggiornato da Antonello il 09/09/2026:** per ogni candidata sono ammessi un passaggio indipendente iniziale, fino a **cinque correzioni aggregate** dei finding e fino a **cinque controverifiche**. Il conteggio è cumulativo sulla stessa candidata e comprende i passaggi già eseguiti: rinomine, riprese o nuovi incarichi non lo azzerano. Dopo ogni aggregata si congela la revisione, si esegue la matrice completa prevista e si raccoglie un unico referto indipendente; niente micro-correzioni durante il dialogo col reviewer né nuovi esempi esplorativi fuori dalla matrice fissata. Un esito rosso intermedio permette di proseguire autonomamente con l’aggregata successiva entro il limite e il mandato esistente, senza chiedere una conferma per ogni passaggio. Si termina appena la qualifica è verde; se la quinta controverifica è ancora rossa, il ciclo torna al PM senza ulteriori patch o rinomina per ripartire. Budget di casi/chiamate/token/tempo fissati prima di ciascuna campagna, isolamento, stop per P0/rischio dati e gate di produzione restano obbligatori. La modifica del limite non riapre automaticamente task archiviate o cantieri storici fuori dal mandato corrente.
- Prima della campagna dinamica si fissa un budget di casi, chiamate, token e tempo. Raggiunto uno dei limiti si consegnano le evidenze raccolte; non si amplia il banco durante l'esecuzione e non si aggiungono prove avversariali non richieste dal contratto.
- Si correggono contratti, autorità, shape, validatori o architettura; non si addestra il comportamento sul testo specifico della fixture. I fatti meccanici restano server-side e immutabili, mentre il modello lavora soltanto nello spazio narrativo autorizzato.
- Dopo la ricertificazione automatica si esegue una prova reale controllata. I difetti osservati diventano evidenze per il ciclo successivo; le migliorie future si deducono dai casi manifestati, senza riaprire preventivamente il prodotto per ipotesi non osservate.
- Review `0/0/0`, gate locale verde e campagna completa, più verifica sul branch temporaneo quando richiesta dalla valutazione dei rischi, precedono ogni gate di produzione. Il rilascio controllato richiede comunque gate nominativi e smoke utente sul sito prima dell'apertura generale. L'eventuale rigenerazione automatica è ammessa soltanto se prevista dal contratto del prodotto e va misurata separatamente dal successo al primo tentativo.

## Test live diretti in Staff Test Room — autorizzazione permanente 06/09/2026
- Antonello autorizza Codex e Claude a usare **testperfunzioni e Riuji** per testare direttamente le funzioni live nella **Staff Test Room**, tramite i normali accessi e le porte di test esistenti. Non chiedere nuovamente l'autorizzazione ai due PG; non anteporre mock, campagne locali, review o prove intermedie al solo collaudo di una funzione già rilasciata.
- Usare la modalità protetta della stanza: PV/chakra di prova, nessun effetto persistente su risorse reali, premi, progressione o grado. Questa è una condizione di esecuzione, non una certificazione automatica di ogni funzione che riceve `is_test`. Se il percorso noto aggira la protezione, richiede attivazione generale o restituisce un errore di sicurezza, fermare quel test e riferire il difetto concreto; non aggirare guardie né equiparare un ripristino successivo all'isolamento.
- Eseguire direttamente il caso necessario, con chiamate IA limitate allo scopo, senza retry esplorativi; conservare risultati/audit, chiudere la sola prova creata e verificare nel postflight risorse protette e assenza di sessioni residue. Nessuna cancellazione dello storico.
- Questa deroga prevale sui divieti generici relativi a Riuji presenti nelle istruzioni importate e nelle skill, esclusivamente per questi test. Non autorizza modifiche a credenziali/ruoli/account, uso fuori dalla Staff Test Room, accesso ad altri PG, deploy/apply non autorizzati o apertura generale agli utenti. I gate di rilascio del codice restano distinti dal collaudo diretto.

## Allineamento permanente delle due Test Room — 06/09/2026
- **Test Room utenti e Staff Test Room sono gli ambienti live di simulazione del GDR.** Ogni rilascio di Combat, pannelli, tecniche, narratori, chiamate Edge o altra funzione collaudabile deve includerne la disponibilità nelle due stanze, nei rispettivi perimetri autorizzati. Il rilascio non è completo se la funzione aggiornata è presente altrove ma nelle stanze resta assente, inerte o sostituita dal vecchio motore.
- Riusare le stesse versioni e gli stessi percorsi applicativi del prodotto: motore, contratti, consumer e servizi Edge. Cambia il contesto protetto, non una copia divergente della logica. Un mock o un'anteprima separata non attestano il funzionamento del percorso reale. I permessi/cataloghi staff non passano alla Test Room utenti.
- Il collaudo funzionale si esegue direttamente sul sito nelle stanze protette: **nessun ambiente locale né campagna locale obbligatoria per provarvi una funzione live**. Questa regola prevale sul flusso locale/branch per tali collaudi; non autorizza fault injection, migrazioni sperimentali o modifiche non approvate in produzione. I gate di rilascio di codice/schema restano distinti.
- Lo stato simulato è separato dalle schede reali: nessuna modifica persistente a personaggi, PV, chakra, inventario, XP, valuta, grado, progressione o risultati di gioco esterni alla prova. Sono ammessi stato della prova, messaggi della stanza e audit necessari, identificati come test e senza ricadute sul GDR reale. Le chiamate ai provider sono vere, con costi/quote dichiarati e misurati quando disponibili: non diventano gratuite perché la scena è simulata.
- Ogni owner include nel proprio rilascio configurazione e accessibilità delle due superfici, verifica diretta pertinente, evidenze UI se presenti, chiusura della prova e controllo finale dell'isolamento. Niente attivazione pubblica globale implicita. Un difetto concreto di isolamento o un percorso ancora legacy è un difetto da correggere, non una ragione per usare i valori reali e ripristinarli dopo.
- Registrare versioni effettive, prove e limiti nella scheda d'area e nell'handoff esistenti. Una regola documentale non certifica allineamenti non ancora implementati; le parti mancanti restano esplicitamente aperte.

## Invarianti (non negoziabili)
- Italiano, sempre. «L'IA racconta, il server comanda»: nessun valore di gioco dal client o dall'IA.
- Accesso web: niente curl/wget/fetch da terminale; usare gli strumenti web o browser disponibili. In Chrome usare soltanto una tab già aperta da Antonello.
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

## Flusso database: Docker → rilascio controllato → Test Room
- **Procedura permanente approvata da Antonello il 09/09/2026:** sostituisce l'obbligo generale del branch QA e l'eccezione temporanea del 05/09. Nessun branch a pagamento mantenuto per sola procedura. Il branch `qa-exchange-monthly-2026-08-31` è stato eliminato su richiesta esplicita; produzione esclusa dall'operazione. Questa autorizzazione specifica non allenta il divieto di cancellare dati di gioco.
- **Docker è l'ambiente ordinario:** PostgreSQL reale per sviluppo, migrazioni, test integrati rappresentabili, rollback/recovery, concorrenza e fault injection. Prima del banco verificare codice, schema, vincoli e cataloghi rispetto alla baseline pertinente di produzione; usare fixture sintetiche o sanitizzate. Registrare versione, copertura e differenze: mock, stub e identità simulate non certificano Auth o servizi Supabase reali. Nessuna copia di segreti o dati privati dei PG, nessuna falsificazione della history.
- **Valutazione prima del rilascio:** owner e reviewer indicano quali rischi sono coperti in locale e quali restano (Auth reale, RLS via API, Storage, Realtime, Edge e configurazioni gestite). Se un rischio significativo non è verificabile in locale né con un collaudo live realmente isolato, STOP del rilascio dipendente e proposta di branch temporaneo; non si usa la produzione per scoprire se una migrazione è sicura.
- **Branch solo temporaneo e motivato:** richiede autorizzazione esplicita alla creazione e al costo, obiettivo, budget e termine di dismissione. Verificarne servizi effettivi e allineamento, senza dedurli dalla sola etichetta del workflow; `MIGRATIONS_FAILED` va documentato e valutato con le evidenze e l'indicazione del supporto. Usare sessione/workdir isolati senza alterare il link di produzione. Conservare sorgenti/referti e verificare assenza di materiale unico prima della cancellazione autorizzata; nessuna ricreazione automatica.
- **Gate di produzione invariati:** stessa matrice e budget, review indipendente `0/0/0` e campagna completa della revisione finale entro il budget cumulativo di cinque aggregate e cinque controverifiche; preflight produzione readonly, piano di recovery verificato e singolo apply/deploy nominativamente autorizzato. Disponibilità iniziale inerte o riservata allo staff dove prevista e tecnicamente isolabile; apply, deploy, enable e apertura generale restano autorizzazioni distinte. Una modifica a schema, permessi o funzioni condivise può incidere sulla produzione anche con il gate della novità spento.
- **Collaudo sul sito:** usare i percorsi reali nelle Test Room protette, con risorse simulate, budget provider esplicito, audit e confronto prima/dopo su risorse, progressione e assenza di effetti esterni. Chiudere solo le prove create per quel collaudo, salvo mandato di mantenerle aperte; preservare storico e scene altrui. Per funzioni già pubblicate non è obbligatoria una nuova campagna locale prima del solo test funzionale. Apertura generale soltanto dopo smoke positivo e gate autorizzato.
- **La Test Room non è un database separato:** `is_test` da solo non garantisce isolamento. Vietati fault injection, migrazioni sperimentali, impersonazioni SQL di utenti reali e prove mutanti fuori dai percorsi protetti autorizzati in produzione, anche con `ROLLBACK`. Se emerge una scrittura su risorse reali, un bypass o un errore di sicurezza, fermare la prova e registrare il difetto: ripristinare dopo non equivale a isolare.
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

## Istruzioni condivise con Claude

`CLAUDE.md` importa questo file per Claude Code. Il testo per le impostazioni esterne è in `dossier/06_ISTRUZIONI_PROGETTO.md`; la procedura operativa resta `management/coordination/AVVIO_LAVORO.md`. Le skill di avvio, contesto e chiusura rimandano alle stesse fonti; copie manutenute in `management/coordination/skills/`. Salvare qui non modifica automaticamente le impostazioni di un’app esterna. Ogni installazione va verificata e le copie arretrate non prevalgono sulle istruzioni vigenti e sul mandato dell’utente.
