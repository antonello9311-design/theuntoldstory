# 01 · STATO ATTUALE — fotografia verificata a database il 02/09/2026, ore 16:30

> Una pagina, si **riscrive** in posto. La storia è in `storico/01_STATO_ATTUALE_diario_fino_20260902.md`. Il dettaglio per area è nelle schede `aree/*.md`. Se un numero qui contraddice il database, ha ragione il database.

## Chi gioca, e quanto
- **78 profili** (65 iscritti negli ultimi 30 giorni, 6 negli ultimi 7) · **73 personaggi**: 64 Deshi, 9 Genin · 2 personaggi di prova (`testperfunzioni`, `Tamako`) · 2 profili staff.
- **Role in chat:** 129 registrate. Per settimana: 5 (27/07) · 39 (03/08) · 33 · 26 · 25 · **1** (dal 31/08). PG che hanno giocato una role: **9 negli ultimi 7 giorni, 22 negli ultimi 30**. La curva scende.
- **Accademia:** 151 classi, 150 partecipazioni, 433 turni del Sensei IA. È la cosa più usata del gioco.
- **Esame Genin:** 56 prove — **12 concluse (5 vinte, 7 perse), 44 annullate** (35 `cancelled`, 5 `timeout`, 4 senza motivo). Letti uno per uno il 02/09: **41 dei 44 sono QA** (Riuji 36, account di prova 5); i giocatori veri sono 7, con 6 esami conclusi e 1 abbandonato all'uscita (Rei). Il vero problema è un altro: **gli ultimi due esami veri (Tenma 29/08, Itsuki 30/08) sono andati interamente in ripiego** — digest non qualificato il primo, Edge v105 che pretendeva un campo inesistente il secondo. La v106 (31/08) è la correzione, mai provata da un giocatore.
- **Scontri:** 14 sessioni del motore legacy, 3 del V2 (2 annullate, 1 in corso: la quest «Ronda» aperta dal servizio IA il 01/09).
- **Allenamento V2:** 6 sessioni — 1 valida, 2 abbandonate, 1 annullata, 2 legacy. 10 abilità in `character_abilities` (8 attive, 2 in addestramento).
- **Premi:** 0 richieste, 1 perk (punti caratteristica su Ryutama, d'ufficio). **Missioni:** 21 pubblicate, **0 prenotazioni, 0 svolte**. Clan: 6 richieste. 23 luoghi (1 di prova).

## Cosa può fare un giocatore oggi (e cosa no)
| Può | Stato | Non può ancora |
|---|---|---|
| Registrarsi, creare il PG, spendere i 60 punti, giocare role in chat con REC e XP giornalieri | in uso | — |
| Fare le lezioni d'Accademia col Sensei IA | in uso | — |
| Sostenere l'Esame Genin con PNG IA | in uso su LIVE v123/recovery; candidata 4.4 sul solo branch respinta dal gate dinamico | — |
| Scontri V2 con Regia Master, multi-target, distanze, «Chiudi scena» | in uso (staff) | Sostituzione completa, iniziativa manuale, terminare senza KO era impossibile fino al 02/09 |
| Allenare una tecnica (Training V2) | pubblicato, quasi non giocato | Sensei IA dell'allenamento (spento) |
| Chiedere/comprare un premio, entrare in un clan aperto | pubblicato, mai usato | Innate e tecniche di clan Genin (gate OFF) |
| Iscriversi a una missione in bacheca | pubblicato, **mai prenotata** | Missioni con Narratore IA (inerti), PNG del Ninja Book |
| Test Room utenti contro il Manichino | in uso (5 dispatch il 25/08) | — |

## La piattaforma
- **455 migrazioni** (head `20260902110040 master_v2_scene_close_001`); 104 dal 26/08 al 01/09, 7 il 02/09.
- `public`: **230 tabelle, 91 vuote** (fondazioni inerti: Training 24, Ninja Book 23, Missioni 18, Combat 8, Master 5) · **716 funzioni** (605 SECURITY DEFINER; 15 eseguibili da `anon`, da ratificare) · **23 schemi privati** di programma (`combat_*`, `mission_*`, `png_builder_*`, `ninja_book_internal`, `clan_innata_private`…).
- **15 Edge Function** (provider unico `gpt-5.6-luna`, reasoning high) · **13 cron** (12 attivi; `pilot-scadenza` spento, dichiarato) · `pg_net` in `public`.
- Sicurezza: 0 SECDEF senza `search_path`; RLS ovunque; segreti solo nei Secrets delle Edge.

## Il sito
`sito_live/` è completa dal 02/09: tutti i 14 file del sito (land 006, scheda, admin, regole.html, REGOLE.md al changelog 73, entra, guida, ambientazione, index, storia, clan, privacy, bijuu.js, AGENTS.md locale) coincidono con l'online, verificati per SHA. Registro: `aree/PUBBLICAZIONE.md`.

## Le aree, in una riga ciascuna
| Area | Stato | Scheda |
|---|---|---|
| Esame Genin | in uso; Narratore 4.7.1 LIVE; fix REC automatica all'apertura proposto e non applicato | `aree/ESAME.md` |
| Combat e Regia | in uso; Composite R13 live inerte; Sostituzione senza resolver | `aree/COMBAT.md` |
| Missioni IA / Ninja Book / PNG Builder | tutto applicato **inerte**, mai giocato | `aree/MISSIONI_IA.md` |
| Clan L1 e tecniche Genin | in lavoro (catena 450–453 live inerte, gate OFF) | `aree/CLAN.md` |
| Accademia e Audit | in uso | `aree/ACCADEMIA.md` |
| Training V2 | pubblicato, quasi non giocato | `aree/TRAINING.md` |
| Test Room | in uso; zona franca dal 02/09 | `aree/TEST_ROOM.md` |
| IA narrativa | in uso; espressività da costruire | `aree/IA_NARRATIVA.md` |
| Pagine | allineate; refactor rinviato | `aree/PAGINE.md` |
| Pubblicazione | coda vuota | `aree/PUBBLICAZIONE.md` |
| Piattaforma | 455 migrazioni; regola d'ingresso da far rispettare | `aree/PIATTAFORMA.md` |
