# C1266 · Stabilità Esame Genin inattivo

**TASK-ID** · C1266-EXAM-IDLE-POLL-20261022.

**Scope toccato** · LAND host Esame Human e invocazione periodica.

**Contratti usati/modificati** · Nessuna firma RPC o shape modificata. Flag interno background distingue presentazione delle letture; tutte le guardie e i lock operativi restano. Nessuna modifica DB/Edge o quote.

**Decisioni prese / OPEN** · Nessuna nuova prova, annullamento o generazione; missione aperta conservata.

**Prove eseguite e risultato** · C1266 · Esame Genin inattivo · 22/10/2026: eliminato il lampeggio dei pulsanti causato da refreshing/inflight durante le letture periodiche. Dopo il bootstrap, solo con ingresso chiuso, nessun esame e nessun pending, il refresh in background mantiene stabile la disponibilità visiva; i gesti di navigazione durante la lettura sono accodati e ricontrollati. Tutte le letture, i controlli Auth, le ricevute e le guardie server restano attivi. Bootstrap, errore, scelta aperta, board, prova attiva e pending mantengono il comportamento ordinario. Nessun vincolo aggiunto o allentato. Sintassi6script PASS, review0/0/0; client bdab987c66782f13075ba03d97fdfe6d2131ff81, Pages39738199777 riuscito. Osservazione reale Chrome Staff su più cicli9s: pulsanti stabili e nessun aggiornamento visibile del riquadro invariato. Missione in corso, incipit nel DB, audit, quote e zero annullamenti identici prima/dopo; zero nuove chiamate provider. Esame giocato e avvio di nuove prove NOT_RUN.

**Rischi o regressioni da verificare** · Race, pending e contesti verificati staticamente; nessuna fault injection live. Collaudo limitato al pannello inattivo già rilasciato; non qualifica gameplay Esame.

**Passaggio richiesto al PM** · Correzione consegnata, nessun backlog avviato. Prove e handoff precedente in candidato/exam_human_master/C1266_EXAM_IDLE_POLL.json.
