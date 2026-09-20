# MISSION-RAPID-LIVE-QA · Staff Test Room

Stato: **PASS PUBBLICAZIONE; RUN NON AVVIATO PER PRESERVARE SCORTA/ADATTA MISSIONI**.

## Perimetro e budget

- Sito pubblico, pannello staff, database live e Staff Test Room; nessun Docker.
- PG autorizzati: `testperfunzioni` e `Riuji`.
- Cinque chiamate provider complessive nel ciclo; la quinta ha prodotto la bozza valida. Zero chiamate durante preview, publish e postflight.

## Caso pubblicato

- `Il Rotolo della Staff Test Room`, grado C, 1–2 partecipanti; briefing, ricognizione e scontro controllato.
- Haruto Sena, team avversari, precedente approvato Tetsuma Iori e ritratto attestato.
- Mappa default 10×10, capienza 16, richiesta 2 PG + 1 PNG, validazione verde.
- Resa dopo tre scambi → successo; sconfitta squadra → fallimento.

## Publish e postflight

- Bozza `e7b9d217-c88d-4b82-9d74-f35574b64200`, sigillo `1fdd9c1501f04a0a97bbc06080f5036cc7e2c74e9d1b88f313cc3cf90c38951c`.
- Missione `471de6b6-1210-43fe-acb5-830670eff0df` aperta; piano approvato `6ec73695-38e7-455c-917c-425191fc939d`, SHA `d5d7658a68fbd619e6e41430d904ff2c9a32a1442a736368e21352815c422fe6`.
- Request `c5dee8cd-b82b-490f-8d91-61cf5b5485ae`; una request publish, una recovery, due regole attive e board `enrollment_open`.
- Preflight `document_graph` e `default_map_ready` verdi.

## Staff Test Room e isolamento

- Il catalogo live mostra titolo, briefing, luogo, ricompense e trama riservata.
- La stanza mostra il banner protetto e la Regia; Riuji è presente con PV 80/80 e CK 105/105.
- Nessun booking e nessuna sessione creati per la nuova missione.
- Il run non è stato avviato perché Riuji conserva due iscrizioni attive, inclusa la Scorta adattata: nessuna interferenza col lavoro parallelo.
- Postflight: `testperfunzioni` 105/155, `Riuji` 80/105; XP, denaro e progressione invariati.

## Correzioni osservate

Il percorso reale ha richiesto sette correzioni minime complessive: soglia JSON null, alias del validatore, coordinate mappa intere, alias attore, concatenazioni JSON, mappa default risolta dal server e priorità terminale non negativa. Ogni delta è fail-closed, reversibile e controverificato `0/0/0`. Corpo tecnico live MD5 `66b271669c92a89db12f497fcb4ac098`; “Adatta missioni” conserva tutti i pin.
