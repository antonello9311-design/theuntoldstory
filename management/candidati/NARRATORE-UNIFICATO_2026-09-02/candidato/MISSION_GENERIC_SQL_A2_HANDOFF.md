# MISSION-GENERIC · A2 sintassi installazione · consegna unica

Task MISSION-GENERIC-A2-SYNTAX. La correzione resta nella seconda aggregata cumulativa; il primo guard registrato senza claim a causa del lock del manifest non è un'altra revisione. Root conserva ownership di INSTALL, INTEGRATED_MANIFEST e RELEASE: nessuno di quei file modificato.

## Delta congelato
Sei coppie di parentesi racchiudono espressioni CASE usate come operandi di confronto nelle condizioni PL/pgSQL. Tre file SQL cambiano: BOARD (1), PROVIDER_GATE (4), PROGRESS (1). Quattro funzioni coinvolte: booking_terminal_assert, provider_permit, provider_native_assert, finish_scope. Nessuna condizione, valore, ordine delle operazioni, autorizzazione, vincolo, dato o gate è cambiato. Gli altri nove SQL sono identici ad A1. Il confronto testuale ricostruito dalle sole sei sostituzioni coincide byte per byte con ogni candidato A2.

- MISSION_GENERIC_BOARD.sql:119 · `<>case when outcome='success' then 'conclusa' else 'fallita' end` → `<>(case when outcome='success' then 'conclusa' else 'fallita' end)`.
- MISSION_GENERIC_PROVIDER_GATE.sql:54 · `<>case p_stage when 'authorize' then 'claimed' else 'authorized' end` → `<>(case p_stage when 'authorize' then 'claimed' else 'authorized' end)`.
- MISSION_GENERIC_PROVIDER_GATE.sql:77 · `<>case p_stage when 'consume' then 'consume' else 'authorize' end` → `<>(case p_stage when 'consume' then 'consume' else 'authorize' end)`.
- MISSION_GENERIC_PROVIDER_GATE.sql:79 · `<>case p_stage when 'consume' then 'authorized' else 'claimed' end` → `<>(case p_stage when 'consume' then 'authorized' else 'claimed' end)`.
- MISSION_GENERIC_PROVIDER_GATE.sql:80 · `<>case p_stage when 'reserve' then 'claimed' when 'authorize' then 'reserved' else 'authorized' end` → `<>(case p_stage when 'reserve' then 'claimed' when 'authorize' then 'reserved' else 'authorized' end)`.
- MISSION_GENERIC_PROGRESS.sql:30 · `<>case when p_outcome='success' then 'conclusa' else 'fallita' end` → `<>(case when p_outcome='success' then 'conclusa' else 'fallita' end)`.

## Pin, statica e limiti
Le quattro funzioni modificate non sono destinatarie di pin prosrc nei moduli dipendenti: nessun pin di DDL deve cambiare. Sette pin prosrc interni ricalcolati sulla composizione candidata: PASS (3 OUTCOME, 1 CHOICE_SOURCES, 3 PROVIDER_GATE). Native baseline e relativi pin invariati: restano soggetti al preflight di rilascio del PM.

272 statement top-level accettati dal parser SQL. 79 funzioni PL/pgSQL dirette e 24 blocchi DO accettati dal parser della grammatica dopo erasure dei soli tipi compositi a RECORD nella copia temporanea. Il parser raw è usato per i trigger perché il suo serializer JSON non produce un AST valido: nessun ParseError restituito, AST non usato. Le sorgenti consegnate mantengono tutti i tipi reali. Il caso minimo del difetto senza parentesi fallisce nel parser PL/pgSQL; con CASE parenthesized passa.

Censiti anche i testi dinamici in Progress/ProviderGate: i CASE nelle chiamate sono già dentro le parentesi degli argomenti, e non richiedono modifica. Il parser del blocco DO non materializza le funzioni clonate: questa statica non certifica esecuzione dei DDL dinamici, nomi colonna, tipi installati o dipendenze runtime. Non è un database locale, un ambiente ricreato né una prova funzionale. Nessun apply, provider o gameplay eseguito.

I manifest e gli handoff singoli riportano A2 e hash correnti; quelli privi di manifest ne ricevono uno. Sono riallineati i riferimenti SQL di composizione, senza toccare i manifest integrati o Edge posseduti da root.

## Hash SQL per la composizione PM

| Modulo | Byte | SHA256 | Delta |
|---|---:|---|---|
| MISSION_GENERIC_DB.sql | 38596 | b7e42ea5a6b78d50d5289a356d7be96b550d30cdb305e99b02145cf53fc732ff | 0 CASE |
| MISSION_GENERIC_PLAN_WRITER.sql | 20832 | 2e7a81af83224fb7a6f98d83a3836f4b53ddbee1c61574ab41c3f344795e53ae | 0 CASE |
| MISSION_GENERIC_OUTCOME.sql | 16843 | da8c285402f54f37c49261e79069069669f907de5f4177790c6d0e5fb562e2c7 | 0 CASE |
| MISSION_GENERIC_COMBAT.sql | 58263 | cb80d82231f59473d4aa13584d3e9e7a3360ff0b90e2cf0d09e5b53310431b5a | 0 CASE |
| MISSION_GENERIC_PANEL.sql | 25769 | 03ee8476754f4c231a0b5142f57bfb8d86c7b46f7432dc57bf966ff87242d2f9 | 0 CASE |
| MISSION_GENERIC_CLAN_OPTIONS.sql | 2454 | 1af3ee0aaf385591b0af05bcb9d112878982f06483b38fcf68d3b355fcd225c4 | 0 CASE |
| MISSION_GENERIC_BOARD.sql | 38907 | f0827febfea3f6f86e20b745d69ac5b33102b8f2a5ec9250c14ca290637a1774 | 1 CASE |
| MISSION_GENERIC_DISPATCH.sql | 48514 | 03d6d4c5158e7a72fe11e0721ccb97023e4de3c4ae2073070eb2efea4d0a7aa0 | 0 CASE |
| MISSION_GENERIC_SOURCES.sql | 16779 | b00cb739df02342f218575ef7f2b5359a439495ccb2fbfb65500165b50876152 | 0 CASE |
| MISSION_GENERIC_CHOICE_SOURCES.sql | 7943 | f9f7135332725e49a29946b58c1bfa0b96ed20e6b724823346a4744a67f71102 | 0 CASE |
| MISSION_GENERIC_PROVIDER_GATE.sql | 16370 | 08a6bc63f598c5c8768d9640a4a8e0782dced24fc82db8a96d9fbb4ff2feb44d | 4 CASE |
| MISSION_GENERIC_PROGRESS.sql | 34704 | f15b889b1ba36fd5dc3a6c4dbcae2466e8dd8b19f9bbcb90504f3a84577d9581 | 1 CASE |

## Passaggio richiesto
Congelare INSTALL/manifest integrato sulla presente lista e affidare al reviewer la controverifica A2 pertinente. Non dichiarare qualifica indipendente dalla statica dell'owner. Il rollback A1 e lo stato live sono evidenze del PM, non di questa modifica. Nessuna nuova autorizzazione o esecuzione di rilascio da parte dell'owner A2.
