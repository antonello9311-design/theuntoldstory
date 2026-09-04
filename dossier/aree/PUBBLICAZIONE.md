# AREA · Pubblicazione — cosa è online, cosa è in coda — scheda viva
Riscritta il 04/09/2026 · da Codex (`NARRATORE-UNIFICATO-COMPACT-4.7.1`) · **stato dell'area: 13 asset sito allineati; nessun file `sito_live/` modificato; sorgenti, test, referti e documenti 4.7.1 caricati e verificati su `main`** (`sito_live/` contiene anche `AGENTS.md`, file locale di governo non contato nella tabella)

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
1. ✅ `land.html` 006 caricato, verificato sul dominio e collaudato (02/09). Nessun file `sito_live/` è stato toccato dal rilascio Narratore 4.7.1. La Edge è già distribuita e verificata su Supabase; i 30 file di rilascio — candidata, test, referti, schede del cantiere e dossier — sono stati caricati su `main` via Chrome nella serie `5ca9dd8d7c08c58baee607a72915f34a51427e3d` → `7b5f6f360975304a4d88188b8bc4a6b800737007`. Questo registro è il 31° file di chiusura.
2. **[P2] Chiarire chi ha prodotto la build online `LAND-MV2-VIEWER-DISTANCE-003`** (nessun handoff o candidato la cita) e da quale sessione è stata caricata.
3. **[P2] Registro a regime**: ogni sessione che tocca `sito_live/` aggiunge/aggiorna la riga del file *prima* di chiudere. Niente SHA negli handoff senza la riga qui.
4. **[P2] Immagini attese da Antonello**: 5 generiche (Tanto, Pillola militare, Razioni militari, Konoha-Altri Luoghi, Suna-Altri Luoghi) · 2 emblemi medici (in stand-by) · 6 emblemi `evofam` · 9 emblemi bijū · avatar mancanti dei PNG · **6 ritratti degli sfidanti d'esame** (Kotoha, Sota, Tatsuma, Hazuki, Isamu, Kazane — brief «aspetto» in `management/SCHEDE_SFIDANTI_ESAME.md`, stesso taglio dei 4 Sensei nel bucket `avatars/`; deposito: cantiere NARRATORE-UNIFICATO passo 3b) · **tavole di riferimento per l'IA** (non per la land) — **serie completa (02/09)**: sei sfidanti in `management/sfidanti_esame/riferimenti/` e due aule in `management/arene/`; i tre di Suna (Hazuki, Isamu, Kazane) sono conformi a R7, i tre di Konoha (Kotoha, Sota, Tatsuma) mostrano un coprifronte e la trascrizione lo esclude: rigenerarli è facoltativo, la Edge legge solo la trascrizione.

## Decisioni chiuse — non ridiscutere
- **Narratore 4.7.1 caricato il 04/09/2026**: 30 file di candidata, test, referti e dossier pubblicati su `main` nella serie `5ca9dd8d7c08c58baee607a72915f34a51427e3d` → `7b5f6f360975304a4d88188b8bc4a6b800737007`; verifica browser dell'albero remoto positiva. Esclusi deliberatamente cache/configurazione temporanea `edge/supabase/.temp/linked-project.json`, revisioni storiche e file estranei. Il caricamento delle sorgenti SQL/Edge non costituisce un nuovo apply o deploy.
- **Dossier Test Room caricato il 04/09/2026**: `dossier/aree/TEST_ROOM.md` creato su `main` con commit `ff0dec673c5f55dc2075ac9df5523c311d3ca581`; `dossier/03_CRONOLOGIA_DECISIONI.md` e `dossier/04_LAVORI_APERTI.md` aggiornati con commit `d804fd0eed4e1b5c49a0cf67097e20d5372a4641`. Verifica browser sulla `main`: tutti e tre contengono il marcatore `TEST-ROOM-TESTER-AVANZATO-RINVIO-001` o la decisione di rinvio attesa. SHA-256 locali: `7584840e86f9694e`, `8e318083a6b6bb7b`, `2d4db5c8819c16cf`.
- **Caricamento GitHub autonomo dal 03/09/2026**: quando un lavoro approvato è pronto e verificato, Codex o Claude caricano i soli file del task su `main`, salvo scope `offline-only`/`no deploy`. Prima riconciliano la testa remota; dopo registrano commit, SHA e verifica. Vietati force-push, riscritture, cancellazioni e commit cumulativi. Senza accesso autenticato si ferma soltanto il caricamento e si consegna la lista esatta.
- **Adozione pubblicata e verificata**: regola comune `4792c32fc6bd02eb40bc781762da536b5ebdcf90`; dossier condiviso `d4abf684f487d790eea5b2a826d4269e8052d9ac`; architettura e workflow `10469d2b07d9859483ea5b0ba1f839656f5751c1`. I tre commit sono su `main`; nessun file del sito, SQL o Edge è stato distribuito con questa serie.
- I candidati HTML si scrivono direttamente in `sito_live/` e si pubblicano nella root GitHub con lo stesso nome. `dossier/` e `management/` mantengono il percorso relativo. Le sorgenti Edge e il SQL **non** stanno in `sito_live/` e il loro caricamento su GitHub non autorizza apply o deploy Supabase.
- Prima di patchare un HTML si riconcilia con la copia realmente pubblicata; se GitHub non è leggibile, Antonello allega il file vivo scaricato.
- Prima di dichiarare rotto qualcosa sul sito: verificare che il file sia stato caricato.

## Trappole — lezioni della memoria di progetto che valgono qui
[[sito_live_non_e_pubblicato]] · [[riconciliare_con_github]] · [[handoff_fermo_ma_pubblicato]] · [[prova_resa_pagine]] · [[changelog_numero_conteso]] · [[recuperare_revisioni_perse]]

## Prossimo passo
Mantenere il registro a regime: al prossimo cambiamento di `sito_live/`, riconciliare prima la copia pubblicata e aggiornare qui build, byte, SHA-256 e stato di caricamento.
