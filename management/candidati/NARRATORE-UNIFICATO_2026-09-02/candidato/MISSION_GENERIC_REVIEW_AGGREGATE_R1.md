# MISSION-GENERIC — review aggregata R1

Stato ROSSO. Prima review indipendente terminata. Referti: REVIEW_UI_R1, REVIEW_DB_R1, REVIEW_SOURCES_R1, REVIEW_RUNTIME_R1 nella directory corrente. Somma dei finding dei referti **0P0/7P1/5P2**; UI-R1-05 e DB-R1-04 condividono lo stesso raccordo di capacità e vengono corretti insieme.

## Correzione aggregata A1 — mandato congelato

1. DB-CORE / mission_contracts: DB-R1-01..04, in DB/PLAN_WRITER/BOARD/OUTCOME. Whitelist roster prima di mutazioni, finalizzazione booking verificata con BEFORE/AFTER coerenti, sorgente storica senza drift dovuto al solo status, validator che respinge configurazioni Combat non supportate. Scelta PM: fasi narrative 0..N PNG; incontri di missione con almeno un PNG avversario e un punto di apertura per fase/visita, più incontri in fasi distinte. Non implementare PvP missione né una seconda sequenza interna allo step. Conservare limiti nativi del catalogo.
2. COMBAT-CORE / ui_polling_diagnosis: RT-R1-01 in PROGRESS; fase difese nativa prima di selezionare difensori PNG, azioni PNG dopo barriera PG, nessuna auto-offensiva/difesa fittizia.
3. NARRATIVE-AI / mission_narrative: RT-R1-02 in Dispatch/runtime/HTTP/ProviderGate/package. Fallimento certo prima provider e rifiuto applicativo dopo provider registrati; conservare receipt, costi e incertezza. Aggiornare pin dei delta dipendenti sul proprio modulo e manifest Edge finale. Nessuna modifica ai moduli degli altri owner.
4. LAND-UI / root: UI-R1-01..04 e UI-R1-05 coerente con decisione1. Test Room ammessa, round-trip editor senza perdita, revisioni salvate/selezionate distinte, sorgenti storiche staff raggiungibili. Common pannello invariato.
5. COMBAT-PANEL / root: MG-SRC-R1-01; due helper offerte supportano permesso per-attore Generic mantenendo sicurezza, rami umani ed Esame; delta condivisi esattamente pinned, nessun taglio indiscriminato tecniche.

Root aggiorna contratto/capacità, install order e manifest integrato. I consumer modificano soltanto file prenotati; input cross-owner disponibili solo dopo consegna. Si congela tutta A1 prima della controverifica unica degli stessi ambiti, affidata agli stessi reviewer indipendenti. Nessun ciclo di microfinding. Budget cumulativo: iniziale1/1; correzioni aggregate completate1/5, controverifiche1/5. Nessuna esecuzione provider in A1; 45min per owner per codice/revisione statica, eventuale superamento da riferire senza campagne aggiuntive.

## Rilascio e prova

Nessun modulo Mission Generic applicato o Edge distribuita a questa data. Gate/runtime/provider OFF. Rilascio dipendente resta fermo fino a review pertinente0/0/0, baseline e pin ricontrollati. UI021 separata già pubblicata e verificata.

Collaudo soltanto sul sito protetto. Testperfunzioni e Riuji risultano occupati nello scontro preesistente e4f36e1a; non chiuderlo. Disponibilità chiesta ad Antonello, risposta pendente. Una sola stanza fisica is_test disponibile in preflight: non dichiarare provata concorrenza 2–3chat senza il caso reale. Conclusioni di capacità architetturale separate dalla verifica empirica.

## Freeze A1 e controverifica C1

Tutti gli owner hanno consegnato e rilasciato le prenotazioni. Hash, ordine installazione e revisori in MISSION_GENERIC_INTEGRATED_MANIFEST.json. Nuovo CLAN_OPTIONS include il solo delta proprietà dei due helper Shared; contract esplicita le capacità correnti. C1 unica per tutta la composizione, massimo30min per ambito, zero provider/gameplay, nessuna patch fino al referto aggregato.
