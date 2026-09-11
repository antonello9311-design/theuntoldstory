# MISSION-GENERIC-ROOT-A1 · UI

Scope: UI-R1-01..05, unica aggregata A1. Candidato non pubblicato. Common pannello e polling UI021 preservati. Nuova build LAND-MISSION-GENERIC-UI-002; modulo mission-generic-ui/1.1.

Test Room ammessa anche se is_exam_room=true. Archivio missioni staff raggiungibile dalla bacheca anche vuota, legge solo id/title/status attraverso la policy viva missions_staff_read; non riscrive lo stato storico. Configurazione e prova sono pulsanti distinti. Selezione PG della prova resta sottoposta alla whitelist server corretta da DBowner.

Editor apre la revisione salvata più recente, mostra un selettore e distingue quella usata ai prossimi avvii. Carica la definition_id esatta. Salvare da una revisione precedente crea una nuova revisione sulla testa del medesimo piano, con i contenuti visualizzati; CAS/pin missione rilevano drift concorrente. Schieramenti per fase preservati e modificabili; combattenti espliciti distinti dagli spettatori; zona della mappa conservata. Profile actor_key resta condiviso come impone il contratto, ma nessuna uniformazione implicita dei team. Trigger conserva chiave/event_kind/priorità/fact_code; outcome opzionale e zona omessa restano tali. Configurazioni non supportate bloccate prima della modifica. Nuovi scontri richiedono almeno un PNG avversario, scene narrative anche zero PNG.

Verifica statica: 12 sostituzioni esatte applicate in sequenza sulla baseline UI021 SHA55f1e21e9b659564af80d5fa6c2578af5f7302466d8062966e433a34bb04b18b. Node sintassi modulo e 6script inline PASS. Nessun test locale ricreato, browser, apply o deploy. Controverifica indipendente richiesta dopo freeze A1 completo.

- mission-generic-ui.mjs: `42dc0b057e0c234059b0a59a934ae1a5343363335f839f9f7f7e5aeffa2bb7b5`
- mission-generic-land.html: `8281316af281e08ea43e399ab5fd04b860f954765de23371100f6fc2b93b2851`
- MISSION_GENERIC_UI_DELTA.json: `8bda10c388e33f5be0e66695514c154d3fb6b00d37b2cb5a4813d53e70bbfbbd`
