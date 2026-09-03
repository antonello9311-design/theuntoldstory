# Piano di organizzazione multi-agent — The Untold Story

## Base verificata

- Archivio analizzato: `theuntoldstory_completo_2026-08-03.zip` (133 file, 4,58 MB).
- Frontend: HTML statico monolitico, senza build step; pubblicazione controllata su GitHub Pages da parte dell'agente dopo il gate.
- Backend: Supabase; la fonte di verità resta il database di produzione.
- Il database al 03/08 contiene 16 personaggi, 355 tecniche di clan, 52 emblemi e 20 missioni. Sono presenti 41 record di evocazione, 9 emblemi `bijuu`, 6 `evofam` e la colonna `characters.cercoterio`.
- I dossier non sono totalmente allineati con questi dati: vanno trattati come contesto, non come stato reale.

## Obiettivo

Creare un sistema di lavoro che consenta a più agenti di contribuire senza condividere l'intero archivio, preservando le fonti di verità, il caricamento GitHub verificato e il vincolo «l'IA racconta, il server comanda».

## Modifiche proposte (nessuna ancora eseguita)

- [NEW] `work/theuntoldstory/` — estrazione di sola analisi dell'archivio, separata dai deliverable e senza modificare l'originale.
- [NEW] `outputs/TheUntoldStory_Workflow_MultiAgent.md` — mappa del progetto, architettura, domini, coworker, ownership, contratti, DAG, roadmap, backlog, rischi, refactoring e primi task paralleli.
- [NEW] `outputs/AGENTS.md` — istruzioni operative corte da collocare nella radice del vero workspace: boot sequence, regole di lettura, fonti di verità, confini, protocolli di handoff e verifica.
- [NEW] `outputs/COWORKER_TEMPLATES.md` — prompt compatti per avviare i coworker senza reinviare l'intero dossier.

## Sequenza di esecuzione

1. Estrarre l'archivio in una copia di lavoro e leggere solo le fonti vive e i blocchi mirati necessari per completare la mappa.
2. Formalizzare una tassonomia a livelli: fondazioni/contratti, backend, una pagina monolitica per owner, contenuto-regole, QA e deploy.
3. Assegnare ownership esclusiva ai file HTML monolitici e ownership per contratto alle API Supabase; vietare modifiche concorrenti ai file ad alto conflitto.
4. Scrivere il workflow e i template di handoff, includendo gli aggiornamenti minimi a dossier e changelog dopo ogni integrazione.
5. Fornire i documenti pronti da copiare nel workspace reale. Nessun codice applicativo, database, deploy o file dell'archivio originale verrà modificato.

## Verifica prevista

- Coerenza del DAG: nessun task dipendente viene avviato prima del contratto che usa.
- Ownership: un solo owner per ogni file; al massimo un reviewer.
- Contesto: ogni coworker riceve un briefing di una pagina, più contratti e file autorizzati, mai l'intero archivio.
- Sicurezza: nessun segreto, dump o modifica alla produzione incluso nei deliverable.

## Decisione richiesta

Approvare la produzione dei tre documenti e l'estrazione temporanea dell'archivio in `work/` per l'analisi completa.

---

## Piano candidato — `TASK-COMBAT-V1-CORREZIONI-MOTORE`

### Decisioni già chiuse

- Danno di striscio: un quarto del danno pieno, minimo 1.
- Meccanica visibile: **Slancio**, +3 fino a +9 e azzerato al colpo.
- Una coppia attacco + difesa produce un solo referto e un solo racconto.
- Sostituzione: unica negazione totale, una volta ogni tre turni difensivi.
- `colto in azione`: sospeso nella V1.1.

### File e sistemi da modificare

- [NEW] Migrazioni di produzione e rollback separati per ogni passo che cambia il database: confronto/slancio/striscio, referto della Sostituzione, testi degli esiti, sospensione del recupero, messaggio `combat_join`.
- [MODIFY] `claude/sim_bilanciamento_20260806.py` — stessi semi, confronto prima/dopo e tabelle attese.
- [MODIFY] `claude/combat_narratore_ai.ts` — terzo esito narrativo «sfiorato», senza numeri di gioco.
- [MODIFY] `sito_live/land.html` — visualizzazione dello Slancio nel pannello dello scontro, riconciliata dal file pubblicato prima della modifica.
- [MODIFY] `sito_live/REGOLE.md` e `sito_live/regole.html` — formula, striscio, Slancio, Sostituzione e peso del grado; changelog soltanto nel Markdown.
- [NEW] Banco mirato che estrae le funzioni vere e copre striscio, Slancio, Sostituzione, recupero e testi.

### Sequenza vincolante

1. Fotografare le firme e le definizioni vive delle funzioni coinvolte, poi preparare candidati SQL con rollback gemello e grant espliciti dove servono.
2. Aggiornare simulazione e banco; eseguire le prove deterministiche prima dell'applicazione.
3. Aggiornare Edge Function, pagina e regolamenti in copie candidate; verificare contratti e rendering.
4. Mostrare piano operativo, diff e risultati delle prove ad Antonello; attendere l'approvazione esplicita prima di ogni migrazione o deploy.
5. Dopo l'applicazione: ripetere rollback-transazione, banco sulle funzioni vere e playtest in Test Room con Sostituzione e tre vuoti consecutivi.

### Limiti

- Nessuna modifica a cron, retry, fallback, RLS dei referti o firme RPC pubbliche.
- Il client non decide mai danni, tiri, cooldown o autorizzazioni.
- Nessuna cancellazione; nessun deploy automatico.
