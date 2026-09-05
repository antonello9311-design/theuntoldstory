# AREA · Pagine HTML — land, scheda, admin, regole — scheda viva
Riscritta il 05/09/2026 · Codex NARRATORE-UNIFICATO/LAND-UI · **LAND007 caricata e byte-exact su GitHub; marcatore sul dominio attestato manualmente da Antonello; verifica strumentale non eseguita**; stato delle altre pagine non riverificato da questo task.

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. Skill `gdr-pagine` — il metodo Python con verifica di unicità, il controllo di sintassi del blocco `<script>`, le **14 classi CSS costruite per concatenazione in JS da non rinominare**.
2. `sito_live/<pagina>.html` — il file da patchare, **dopo** la riconciliazione con la copia pubblicata (`PUBBLICAZIONE.md`). Si localizza con `grep -n` e si legge solo l'intervallo di righe.
3. `management/coordination/HANDOFFS/TASK-LAND-MV2-DEFENSE-STABILITY-001.md` — l'ultimo intervento sul land (polling 9″, DOM non ricostruito su payload identico, campi «Interpretazione» rimossi).
4. `management/coordination/HANDOFFS/TASK-SCHEDA-CORSIVO-LEGGIBILITA-003.md` e la memoria `land_leggibilita_14_001` (pannellino «Aa» a quattro aree), `scontro_ui_001`, `legende_001`.
5. Memoria di progetto per il metodo: `banco_pagina_vera` (Playwright sul monolite), `prova_resa_pagine` (Chromium, non `node --check`), `pulizia_codice_morto_20260826`, `admin_init_parallelo`, `piano_refactor_leggibilita`, `tipografia_pergamena`, `testo_pannelli_larghezza`.
6. `claude/pagina_*.html` — **copie ferme e pesanti** (349 KB la land): solo se serve proprio quella versione storica, mai come base.

## Stato vivo — LAND verificata il 05/09/2026; altre pagine: dati storici 01/09
- `land.html` riconciliata dalla baseline006, poi pubblicata `LAND-ESAME-ANCHOR-OPTION-007`,706117B,SHA256 `c241f571d543214d6ca6c5ea4dbbe7e00fafbf0e431bcb0a5b65bfdd2ce144e5`, commit `445bdd7304af95456f32bcf9e47aaed31b25884d`. File GitHub byte-exact e build007 verificati. Conserva option_id opaco, distingue le ancore e blocca scelte scadute; legacy/Scontro invariati, review0/0/0 e8/8. DB336/337 ed Edgev128 verificati prima upload. Marcatore LAND-ESAME-ANCHOR-OPTION-007 attestato manualmente da Antonello sul dominio pubblico (risposta «presente»); verifica strumentale non eseguita, nessun nuovo esame.
- `scheda.html` 225.491 B (`SCHEDA-JUTSU-VISIBILITA-002`, `SCHEDA-LEGGIBILITA`, Training V2 presente). `admin.html` 347.700 B (`ADMIN-138A`, `ADMIN-DELETE-GUARD-003`). `regole.html` 180.138 B (28/08). `entra.html` 26/08. `guida.html` ferma al 07/08.
- Pulizia del codice morto eseguita su 4 pagine (26/08); `init()` paralleli in admin e scheda (26/08); leggibilità v4 land + v2 scheda (27/08); Regia nella riga del Fato, card Scontro ripulita, legende (27/08); cura ✚ rimossa dalla chat (28/08); fix premio «punti caratteristica» in scheda (29/08).

## Lavori aperti — in ordine
0. ✅ **Pubblicazione LAND007 conclusa** — GitHub byte-exact e marcatore sul dominio attestato manualmente da Antonello; verifica strumentale non eseguita. Nessuna nuova prova funzionale automatica.
1. ✅ **Collaudo del land caricato il 01/09 eseguito il 02/09** (`COMBAT.md` #1): chat libera + pannello solo meccanico, selezione che sopravvive al polling, doppio ruolo Master/PG ok.
2. **[P1] Difetto Assalto/Moltiplicazione** segnalato dal QA di Itsuki (30/08): assegnato a LAND-UI, mandato da scrivere.
2b. ✅ **Etichette del menu azione MV2** (02/09, build `LAND-MV2-AZIONE-ETICHETTE-005`, da caricare): «Utilità» → «Azione non offensiva · nessun effetto meccanico», «Movimento · solo spostamento», «Passa · nessuna azione», più una nota che spiega cosa entra nel calcolo. Solo testo, nessuna logica. Resta aperto: una sessione in «preparazione» senza scontro non ha un pulsante per chiudersi («Chiudi attività» compare solo dopo l'esito di un round) — P3, dopo la riorganizzazione.
3. **[P2] Emblema `evofam`** mancante in `admin.html` (`EMB_EXTRA`); a database il tipo `evofam` **esiste già** (verificato 01/09), quindi manca solo il client.
4. **[P2] `guida.html`** — spiegare il motore scontri 1v1 e la Regia; rimuovere istruzioni superate. Candidato solo dopo approvazione PM.
5. **[P2] Dismissione del calcolatore legacy «Combatti»** in `land.html` — piano di rimozione senza toccare pannello scontri, Regia, dadi.
6. **[P3] Refactor di leggibilità** — approvato il 26/08 ma **solo quando non ci sono altri lavori in corso** sulla pagina; condizioni d'ingresso e ordine per pagina nella memoria `piano_refactor_leggibilita`; decisione aperta sugli helper condivisi.
7. **[P3] Innesco della cura in chat**: nessun comando resta dopo CURA-PALMO; `post_heal` è una RPC viva senza interfaccia (task futuro, con mandato).

## Parcheggiato — non riaprire senza mandato
- UI-005 R3 (pannello Esame) e UI-003 R3 (esito): «pronti e non pubblicati» dal 16/08, ribasati sul vivo di allora — da riverificare contro il land corrente prima di qualunque riuso.
- Restyle della land (`claude/restyle_land_proposta.md`): proposta storica.

## Decisioni chiuse — non ridiscutere
- Pagine **statiche e monolitiche**: `<style>` e `<script>` in linea, niente framework, niente build. Un file, un owner alla volta.
- Le 14 classi CSS costruite per concatenazione non si rinominano. `bijuu.js` assegna `bjmascot` dall'esterno; una factory UMD sembra a zero riferimenti e non lo è.
- Pannellino «Aa» con quattro aree indipendenti (testo chat, laterale+Scontro, tasti, barra alta); in scheda testo proprio + tasti condivisi.
- Le azioni distruttive chiedono conferma dentro la riga col motivo, non con `confirm()`; le azioni su più righe mostrano l'anteprima dal server.
- Terminologia: «coprifronte», «Cercoteri»; nomi delle tecniche in italiano; valori visibili multipli di 5.

## Trappole — lezioni della memoria di progetto che valgono qui
[[banco_pagina_vera]] · [[prova_resa_pagine]] · [[insieme_chiuso_operatore_in]] · [[porto_fra_linguaggi]] · [[testo_pannelli_larghezza]] · [[qa_coordinate_mappa]] · [[ritiro_funzioni_client]] · [[pulizia_codice_morto_20260826]]

## Prossimo passo
LAND007 caricata e verificata su GitHub; marcatore sul dominio attestato manualmente da Antonello (risposta «presente»), verifica strumentale non eseguita. Non avviare Tamako o una nuova prova: la verifica narrativa manuale resta di Antonello. Gli altri interventi restano separati.
