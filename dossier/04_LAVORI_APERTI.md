# 04 · LAVORI APERTI — il tabellone, e l'ordine «uno alla volta»

> Una pagina, si **riscrive** in posto: niente sezioni datate. Il diario fino al 02/09 è in `storico/04_LAVORI_APERTI_diario_fino_20260902.md`. Il dettaglio di ogni voce è nella scheda d'area. **Regola d'ingresso: al massimo tre cantieri «in lavoro»**; un cantiere nuovo si apre solo quando uno passa «in uso» o viene parcheggiato per iscritto. «In uso» lo dichiara solo Antonello.

Riscritto il 03/09/2026 · task `PM-DOCUMENTALE-CANTIERI-DIPENDENZE-001`.

## Il tabellone
| Area | Stato | Cantiere | Prossimo passo | Chi |
|---|---|---|---|---|
| Documentale | **completato 03/09** | — | AGENTS v2 adottato nei tre cantieri; rinomini strutturali restano fuori scope | PM |
| Clan L1 | **in lavoro** | `management/candidati/CLAN-L1_2026-09-01/` | consolidamento editoriale exact21 (solo documenti) | RULES-LORE + Antonello |
| Combat V2 | **in lavoro** | `management/candidati/COMBAT-COMPOSITE_2026-09-01/` | Moltiplicazione: rebase sulla head LIVE verificata al gate | COMBAT-CORE/DB-CORE |
| Esame Genin | in uso; Narratore LIVE v119/prompt21, smoke misto chiuso e ripulito, qualità non certificata | — | monitor falso positivo; prova orfana all'interruzione; round che avanza prima dell'esito narrato | DB-CORE + LAND-UI |
| Narratore unificato (Esame ← modello Ronda) | **in lavoro**: passi 1–5 e 7 rilasciati/chiusi; resta passo 6 | `management/candidati/NARRATORE-UNIFICATO_2026-09-02/` | sincronizzare `REGOLE.md` + `regole.html`; poi Antonello decide lo stato | RULES-LORE + Antonello |
| Test Room | in uso | — | QA 070 con due account (mezz'ora) | Antonello |
| Missioni (umane) | pubblicato, mai usato | — | scoprire perché 0 prenotazioni: prova del flusso bacheca → prenotazione → Regia → esito | Antonello + LAND-UI |
| Training V2 | pubblicato, quasi non giocato | — | leggere le sessioni abbandonate; un allenamento completo | QA + Antonello |
| Missioni IA / Ninja Book / PNG Builder | applicato inerte | **parcheggiato** fino al canary | data del canary «Nodo Azzurro» | Antonello |
| IA narrativa | in uso; follow-up separati dal rilascio | — | player bridge, ampiezza manovre, memoria anti-ripetizione, validazione qualitativa v119 | NARRATIVE-AI |
| Accademia | in uso | — | le sette caselle di §1b (20 minuti) | Antonello |
| Pagine | allineate | — | difetto Assalto/Moltiplicazione (mandato LAND-UI) | LAND-UI |
| Pubblicazione | coda vuota; 13 asset pubblicabili allineati (`AGENTS.md` locale è il 14° file della cartella) | — | registro a regime | — |
| Piattaforma | history461; igiene arretrata | — | deposito della migrazione461; ratifica dei 15 `anon` + `pg_net` | Antonello + DB-CORE |

## L'ordine, uno alla volta
Ogni voce si chiude prima di aprire la successiva. Le voci con ✋ chiedono qualcosa ad Antonello; le altre le può fare un agente su mandato.

1. ✅ **Documentale** — AGENTS v2 adottato: i tre cantieri hanno SCHEDA/HANDOFF/STORICO, schede d'area e dipendenze sono riconciliate; nessun candidato sigillato modificato. I rinomini strutturali restano fuori scope e si fanno solo a cartella ferma.
2. **Narratore unificato — passo 6**: rilasciati passi 1–5 con migrazioni 457–461 ed Edge v119/prompt21; smoke Staff/Test Room chiuso autoritativamente (zero prove aperte, 2/2 cicli risolti), non certificante. Resta la coppia `REGOLE.md` + `regole.html`.
3. ✋ **Test Room utenti** — QA 070 completa: secondo account, sesto dispatch respinto, KO/ripristino del Manichino. Chiude una voce aperta dal 23/08.
4. ✋ **Missioni umane: perché nessuno prenota** — 21 missioni in bacheca, 0 prenotazioni in un mese. Prova del flusso completo da giocatore (bacheca → iscrizione → conferma → Regia con Master umano → esito → ricompense). Se il flusso funziona, è comunicazione; se no, è un bug che vale più di qualunque fondazione IA.
5. ✋ **Training V2** — le tre sessioni abbandonate/annullate in sola lettura, poi un allenamento completo nelle tre modalità.
6. **Clan: consolidamento exact21** — Nara, Sabaku, Uchiha nel registro centrale; indice, validatori, manifesto. Solo documenti.
7. **Combat: Moltiplicazione** — rebase sulla head LIVE verificata al gate, readiness e nuova review; nessun apply o caricamento implicito.
8. **Combat: Sostituzione completa** — resolver server-authoritative (ancore, range 3/5/10/15, cooldown R1→R4, consumo 5, collisione fail-closed, commit e ricevuta). Finché manca, l'offerta non si usa.
9. **Clan: runtime Marionettisti** (sul contratto ratificato) e poi **Hyūga** (ribasato su 455), uno alla volta, con suite PG17 ×2 e review 0/0/0.
10. **IA narrativa, follow-up separati** — player bridge strutturato, ampiezza manovre, memoria anti-ripetizione, validazione qualitativa v119; poi adapter dello scambio Combat.
11. ✋ **Missioni IA: il canary «Nodo Azzurro»** — con `testperfunzioni` + Tamako, budget 0,14, otto fasi. Poi il secondo run. Solo dopo i due run le Missioni full IA si dichiarano pronte.
12. **PNG Builder: uso ordinario** — Admin collegato al Builder, owner object popolati, prime identità con gate nominativo, binding di fase nell'avvio missione.
13. **Clan: verticali rimanenti** (Sabaku → Nara → Aburame/Hoki → Akimichi → Inuzuka → Uchiha), poi elementali Genin sul Combat comune, Staff Room, pubblicazione coordinata.
14. **Sviluppo rinviato** (decisione del 02/09): iniziativa manuale del Master, resolver per le azioni non offensive, PNG del Ninja Book nel menu della Regia umana, refactor di leggibilità, `guida.html` del motore, dismissione di «Combatti» legacy.
15. **Piattaforma** — ratifica 15 `anon` e `pg_net`; mappa delle 91 tabelle vuote per cantiere; FK senza indice dopo il traffico; 66 archivi C (programma 096).

## Parcheggiati per iscritto (non si riaprono senza mandato)
Ninja Book G11-* e 127D finché il canary non è giocato · voce narrativa 066/067 · proposte P2–P8 dell'analisi narrativa · TACTIC-015, 016, integrazione 040+042 (superate) · UI-005/UI-003 dell'Esame (da riverificare sul vivo prima di qualunque riuso) · Sensei IA dell'allenamento (finché V2 non è in uso) · `TASK-AI-ITALIANO-COMUNE-001`.

## Le tre liste con cui si chiude ogni sessione
**Da caricare su GitHub:** vedi `aree/PUBBLICAZIONE.md` (oggi: nulla). **Immagini attese da Antonello:** 5 generiche (Tanto, Pillola militare, Razioni militari, Konoha-Altri Luoghi, Suna-Altri Luoghi), 2 emblemi medici (in stand-by), 6 emblemi `evofam`, 9 emblemi Cercoteri, avatar mancanti dei PNG. **Decisioni che aspettano Antonello:** stato del Narratore dopo il regolamento · data del canary · consolidamento exact21 · ratifica `anon`/`pg_net`.
