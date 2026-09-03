# AREA · Pubblicazione — cosa è online, cosa è in coda — scheda viva
Riscritta il 03/09/2026 · da Codex (`PM-DOCUMENTALE-CANTIERI-DIPENDENZE-001`) · **stato dell'area: 13 asset pubblicabili allineati; coda GitHub vuota** (`sito_live/` contiene anche `AGENTS.md`, file locale di governo non contato nella tabella)

> **Regola dell'area.** `sito_live/` **non è ciò che è pubblicato**: è ciò che è pronto per esserlo. La verità è il file su GitHub (`antonello9311-design/theuntoldstory`, branch `main`, cartella root) e il dominio `https://theuntoldstory.it`. Ogni modifica a un file di `sito_live/` aggiunge una riga a questo registro; ogni caricamento la chiude con «caricato il» e «verificato il». Prima di patchare una pagina si riconcilia con la copia pubblicata (memoria: [[sito_live_non_e_pubblicato]], [[riconciliare_con_github]]).

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. **Questo registro.** Poi il dominio (WebFetch della pagina viva: marcatore di build + SHA) — mai la copia locale come prova.
2. `sito_live/REGOLE.md` (changelog numerato, ultima riga **73**) e `sito_live/regole.html` — la coppia che cambia sempre insieme (skill `gdr-regole-sync`).
3. `archivio/2026-08/evidenze/mission_exchange_land_live_postupload_005/VERIFICA_PUBBLICAZIONE.md` — l'ultima verifica byte-exact eseguita (01/09, land R4).
4. `management/coordination/HANDOFFS/TASK-LAND-MV2-DEFENSE-STABILITY-001.md` — l'ultimo handoff che chiede un caricamento (01/09 20:17).
5. Memoria di progetto: `sito_live_non_e_pubblicato`, `riconciliare_con_github`, `handoff_fermo_ma_pubblicato`, `prova_resa_pagine`, `changelog_numero_conteso`.

## Registro — verificato il 02/09/2026, 17:30 (tutti i 13 asset pubblicabili sono in `sito_live/` e confrontati per SHA-256 con le copie scaricate da GitHub da Antonello; il quattordicesimo file della cartella è `AGENTS.md`, locale e fuori registro)
| File | Online (GitHub; verifica 01–02/09) | Locale `sito_live/` | Stato |
|---|---|---|---|
| `land.html` | `LAND-MV2-CHIUDI-SCENA-006` (dominio, 02/09 14:35) | `LAND-MV2-CHIUDI-SCENA-006` · 704.922 B · `60f913e22bbfc462` (02/09 14:15) | ✅ allineato — caricato da Antonello il 02/09 ~14:30; collaudo: «Chiudi scena» ha chiuso la sessione «prova» in Test Room (annullata / chiusa_dal_master, 0 scontri aperti nel luogo). Storico: 005 `2ab920c4…`, 004 `4df86df2…`, 003 `57f495e0…` (mai citata). |
| `scheda.html` | `SCHEDA-JUTSU-VISIBILITA-002` · 225.491 B · `9b8ce06bf7dbdf33` | identico (29/08 04:23) | ✅ allineato (verificato 01/09) |
| `admin.html` | `ADMIN-138A` · 347.700 B · `67bfa832a534dfd1` | identico (30/08 08:52) | ✅ allineato (verificato 01/09) |
| `REGOLE.md` | changelog 73 · 156.975 B · `63d4e3026882615c` | identico (28/08 14:53) | ✅ allineato (verificato 01/09) |
| `guida.html` | 50.494 B · `5c9e64660eeff2cb` | identico (07/08) | ✅ allineato — ma ferma al 07/08: non spiega il motore scontri, cita ancora il pulsante «Combatti» legacy e «la cura da Mente 25» (falso dal 28/08) |
| `regole.html` | 180.138 B · `5daca23b7d69ad87` | identico (28/08 14:53) | ✅ allineato (verificato 01/09 23:20) — coppia con REGOLE.md changelog 73 in pari |
| `entra.html` | 46.937 B · `9f7f3c143636805f` | identico (26/08 23:35) | ✅ allineato (verificato 01/09 23:20) |
| `ambientazione.html` | 63.380 B · `b053f45d287b534b` | identico — depositato in `sito_live/` il 02/09 dalla copia online allegata da Antonello | ✅ allineato (02/09). La copia ferma `claude/pagina_ambientazione.html` (60.610 B) resta più vecchia: non usarla come base. |
| `index.html` | 46.065 B · `ad776e2d34a17d6f` | identico — depositato il 02/09 dalla copia online allegata | ✅ allineato (02/09) |
| `storia.html` | 42.671 B · `4233002c78c42cb8` | identico — depositato il 02/09 | ✅ allineato (02/09) |
| `clan.html` | 33.181 B · `f3c0bd9e981cfa9c` | identico — depositato il 02/09 | ✅ allineato (02/09) |
| `privacy.html` | 10.716 B · `fb4648011473910a` | identico — depositato il 02/09 | ✅ allineato (02/09) |
| `bijuu.js` | 17.988 B · `a998f3a4cc09e058` | identico — depositato il 02/09 (`node --check` ok) | ✅ allineato (02/09). Nota: index.html e storia.html contengono anche una copia in linea dello stesso script: tre copie da tenere allineate |

Legenda: ⬜ da fare · ❓ da confermare · ✅ fatto (con data).

## Lavori aperti — in ordine
1. ✅ `land.html` 006 caricato, verificato sul dominio e collaudato (02/09). **Coda GitHub vuota.**
2. **[P2] Chiarire chi ha prodotto la build online `LAND-MV2-VIEWER-DISTANCE-003`** (nessun handoff o candidato la cita) e da quale sessione è stata caricata.
3. **[P2] Registro a regime**: ogni sessione che tocca `sito_live/` aggiunge/aggiorna la riga del file *prima* di chiudere. Niente SHA negli handoff senza la riga qui.
4. **[P2] Immagini attese da Antonello**: 5 generiche (Tanto, Pillola militare, Razioni militari, Konoha-Altri Luoghi, Suna-Altri Luoghi) · 2 emblemi medici (in stand-by) · 6 emblemi `evofam` · 9 emblemi bijū · avatar mancanti dei PNG · **6 ritratti degli sfidanti d'esame** (Kotoha, Sota, Tatsuma, Hazuki, Isamu, Kazane — brief «aspetto» in `management/SCHEDE_SFIDANTI_ESAME.md`, stesso taglio dei 4 Sensei nel bucket `avatars/`; deposito: cantiere NARRATORE-UNIFICATO passo 3b) · **tavole di riferimento per l'IA** (non per la land) — **serie completa (02/09)**: sei sfidanti in `management/sfidanti_esame/riferimenti/` e due aule in `management/arene/`; i tre di Suna (Hazuki, Isamu, Kazane) sono conformi a R7, i tre di Konoha (Kotoha, Sota, Tatsuma) mostrano un coprifronte e la trascrizione lo esclude: rigenerarli è facoltativo, la Edge legge solo la trascrizione.

## Decisioni chiuse — non ridiscutere
- Deploy **manuale, sempre**: Antonello carica dall'interfaccia web di GitHub e fa Ctrl+F5. Nessun commit/push da qui.
- I candidati HTML si scrivono direttamente in `sito_live/` (percorso assoluto, data/ora, byte, SHA nell'handoff); Antonello carica solo quella copia. Le sorgenti Edge e il SQL **non** stanno in `sito_live/`.
- Prima di patchare un HTML si riconcilia con la copia realmente pubblicata; se GitHub non è leggibile, Antonello allega il file vivo scaricato.
- Prima di dichiarare rotto qualcosa sul sito: verificare che il file sia stato caricato.

## Trappole — lezioni della memoria di progetto che valgono qui
[[sito_live_non_e_pubblicato]] · [[riconciliare_con_github]] · [[handoff_fermo_ma_pubblicato]] · [[prova_resa_pagine]] · [[changelog_numero_conteso]] · [[recuperare_revisioni_perse]]

## Prossimo passo
Mantenere il registro a regime: al prossimo cambiamento di `sito_live/`, riconciliare prima la copia pubblicata e aggiornare qui build, byte, SHA-256 e stato di caricamento.
