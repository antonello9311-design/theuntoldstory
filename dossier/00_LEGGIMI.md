# 00 · LEGGIMI — porta d'ingresso al progetto

> **Riscritto il 02/09/2026.** La versione del 24/08 è in `storico/00_LEGGIMI_v_20260824.md`. Questa pagina si riscrive: se dice una cosa superata, si corregge, non si appende.

## Cos'è
«The Untold Story» è un GDR play-by-chat **in italiano**, universo alternativo di Naruto dopo la **Notte della Volpe**: nessun personaggio canonico esiste. Si gioca scrivendo, nel browser; il server fa da arbitro sui numeri, i giocatori e lo staff fanno la narrazione, le IA raccontano. Beta aperta dal 01/08/2026. Sito `https://theuntoldstory.it` (GitHub Pages, deploy **manuale** di Antonello), backend Supabase `tyhyxkslteigibktluml`. Principio: **«l'IA racconta, il server comanda»**.

## Come si entra in una sessione, chiunque tu sia (Claude, Codex, una chat nuova)
1. **`AGENTS.md`** nella radice: le regole (dove si scrive, cosa consegna un task, i limiti, gli invarianti).
2. **`dossier/CONTESTO.md`**: i numeri del gioco e del database, a memoria.
3. **`dossier/01_STATO_ATTUALE.md`** (una pagina): cosa esiste e chi lo usa. **`dossier/04_LAVORI_APERTI.md`** (una pagina): il tabellone e l'ordine «uno alla volta».
4. **La scheda dell'area** del task in `dossier/aree/` (tabella parole → scheda in `aree/00_COME_SI_USA.md`; per Claude la apre da sola la skill `gdr-rotta`). La scheda elenca le **fonti fondamentali** in ordine: si aprono solo quelle, solo nel blocco che serve.
5. Prima di toccare codice o SQL: `05_CONVENZIONI.md`. Prima di riaprire una scelta: `03_CRONOLOGIA_DECISIONI.md` (registro append-only delle decisioni, l'unico file del dossier che cresce in coda). Per cercare una fonte: `02_INDICE_DOCUMENTI.md`. Per capire come si è arrivati qui: `07_ARCHITETTURA.md`. Per provare che una cosa funziona: `08_PIANO_PROVE.md`.

**Le tre fonti di verità, in ordine:** ① il database di produzione; ② `sito_live/REGOLE.md` per il regolamento (changelog numerato solo lì); ③ le specifiche in `claude/` per le intenzioni di design. Se due documenti si contraddicono non vince il più recente: vince la fonte viva.

## Come è organizzata la cartella (02/09/2026, transizione in corso)
- `sito_live/` — ciò che è (o sta per essere) online; registro dei caricamenti in `dossier/aree/PUBBLICAZIONE.md`.
- `dossier/` — lo **stato**: `00` porta, `01` fotografia, `04` tabellone, `CONTESTO`, `aree/` (11 schede), `03` decisioni, `05` convenzioni, `07` architettura, `08` prove, `storico/` (i diari di prima, intatti).
- `management/candidati/<CANTIERE>/` — i cantieri aperti (oggi `CLAN-L1_2026-09-01`, `COMBAT-COMPOSITE_2026-09-01`); le cartelle piatte precedenti sono storia e vanno in `archivio/`.
- `management/coordination/HANDOFFS/` — i referti; `management/repertorio/` — la fonte canonica dell'IA narrativa; `management/analisi/` — studi.
- `supabase/` — copie delle migrazioni e delle Edge; `claude/` — specifiche e copie ferme (pesanti: non si aprono per intero); `archivio/` — chiuso.

## Le regole che non si negoziano (il dettaglio è in `AGENTS.md`)
Italiano, sempre. Nessuna modifica a codice o database senza approvazione; nessuna cancellazione. Quando un lavoro approvato è pronto e verificato, Codex o Claude possono caricare autonomamente su GitHub i soli file del task; vietati force-push, riscritture e file estranei. `REGOLE.md` e `regole.html` cambiano insieme. Ogni vincolo aggiunto **o allentato** si dichiara. Una domanda senza risposta non è una decisione. Un file, un owner alla volta. Nessuna decisione operativa vive solo in un handoff. Non si toccano: l'account Riuji, le 14 classi CSS generate in JS, la §7 di `migration_coerenza.sql`, il job `esame-tick`.

## Il vocabolario minimo
**Deshi** allievo, impara solo i jutsu accademici · **Cercoteri** (mai «bijū») · **Innata** la nona caratteristica · **Premi** acquisti straordinari in XP (max 2 maggiori a vita) · **Ryo** l'unica valuta · **Role** una sessione in chat, salvata come snapshot · **Scontro** l'oggetto del motore V2 · **Regia** la sessione del Master (umano o `ai_service`) · **Test Room** il luogo di prova (`is_test`), con la zona franca · **Coprifronte** (mai «fascia frontale») · **Riuji** l'admin, non si tocca · **mock / testperfunzioni / Tamako** personaggi di prova.

## Se stai riprendendo adesso
Il tappo del progetto non è tecnico: **è l'atterraggio**. Tante fondazioni applicate e inerti, pochi prodotti giocati fino in fondo. Apri `04_LAVORI_APERTI.md` e prendi la prima voce non chiusa. Le cose si provano giocandole (`08_PIANO_PROVE.md`); quello che compare e sparisce si prova aprendo la pagina.
