# MISSION-RAPID-RELEASE · stato di rilascio

Stato: **in uso tecnico — flusso trama + immagine → anteprima → pubblicazione completato e verificato**.

## Versione corrente

- Manifesto `mission-rapid-editor/2026-09-19.review10`, 26/26 artifact verificati.
- Install SQL SHA-256 `6840c4b15d8f0bd93e8b279511935c02c694af9266fa6ff5904dd103777f7525`; test contratto SHA-256 `20f2b28af5dc3f2bbd871593983252082b1511f95249bfc57004b873a58de494`.
- Funzione tecnica live MD5 `66b271669c92a89db12f497fcb4ac098`; preview live MD5 `c988923b347cc600b85bb215ea025663`.
- Client pubblico: commit `f4bb587095b6a2987ddf4c1c2212453345553dd9`.

## Esito end-to-end

- Bozza `e7b9d217-c88d-4b82-9d74-f35574b64200` compilata con cinque chiamate provider complessive; nessuna chiamata dopo la compilazione valida.
- Haruto Sena collegato al precedente approvato Tetsuma Iori e all’immagine attestata `haruto_ritratto.png`.
- Anteprima sigillata: tre fasi, PNG approvato, mappa default 10×10 capienza 16, due condizioni terminali e budget Narratore.
- Pubblicazione idempotente unica: missione `471de6b6-1210-43fe-acb5-830670eff0df`, piano approvato `6ec73695-38e7-455c-917c-425191fc939d`, richiesta `c5dee8cd-b82b-490f-8d91-61cf5b5485ae`.
- Stato `aperta`, board `enrollment_open`, una recovery `mission-rapid-recovery/1`, nessun duplicato.

## QA e compatibilità

- Sette correzioni deterministiche complessive, tutte atomiche, reversibili e con review indipendente `0/0/0`: soglia JSON null, alias del validatore, coordinate mappa, alias attore, concatenazioni JSON, risoluzione della mappa default e priorità terminale non negativa.
- Suite finali: compilatore 43/43, editor 51/51, integrazione Admin 28/28, media 21/21, contratto 29/29. Nessun Docker.
- “Adatta missioni” invariata: preflight `2bfa56c88e45c52eb4495ee1f7c5d870`, create `8a512021ec0335f6eddb8b859607b056`, board `7efaab206f6b8f1fab92b72c848d5d72`; hook rapido unico.
- Catalogo e Staff Test Room verificati. Nessun run avviato: Riuji conserva le iscrizioni della Scorta. Nuova missione con zero booking e zero sessioni; testperfunzioni 105/155 e Riuji 80/105 invariati.

## Residuo non bloccante

Il comportamento narrativo e la resa dopo tre scambi saranno osservati quando un roster libero userà la missione. Non serve una nuova pubblicazione né una nuova chiamata autore.
