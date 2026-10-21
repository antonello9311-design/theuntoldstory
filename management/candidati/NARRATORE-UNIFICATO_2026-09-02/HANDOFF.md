# C1266 · Caricamento chat al rientro

**TASK-ID** · C1266-CHAT-REENTRY-20261021.

**Scope toccato** · LAND: invalidazione della sola cache di rendering al nuovo ingresso e marcatore di build.

**Contratti usati/modificati** · Letture chat esistenti, nessuna firma RPC o shape modificata. Database, Edge, permessi, limiti e stato di prova invariati. Nessun vincolo aggiunto o allentato.

**Decisioni prese / OPEN** · Conservare incipit e prova in corso; nessuna rigenerazione, role, retry o nuova scena. Il ciclo di uscita/rientro è stato richiesto espressamente dall’utente.

**Prove eseguite e risultato** · C1266 · Chat al rientro · 21/10/2026: corretta la cache di rendering LAND. openRoom invalida lastMsgsSig quando ricrea il contenitore dei messaggi; la successiva lettura ridisegna anche gli stessi messaggi o il risultato vuoto. Polling e contratti invariati; nessun nuovo vincolo. Sintassi di sei script PASS e review indipendente 0/0/0. Client c787b108dd514ef40fcb66a3bfc9fd0992221d21, build C1266-CHAT-REENTRY-001, Pages39675631262 riuscito. Verifica reale Chrome: stesso incipit visibile dopo ricarica e dopo uscita alla mappa/rientro nella Staff Room. Postflight identico per scena in corso, work completato, ricevuta, audit, quote e due chiamate storiche; zero nuove chiamate provider, role o prove. Prova lasciata aperta. Questo collaudo riguarda il caricamento della chat, non il successivo turno della Regia.

**Rischi o regressioni da verificare** · Il risultato non qualifica nuove role/Director né risolve gli avvisi separati del pannello rigenerazione. Il normale filtro chat di dodici ore resta invariato.

**Passaggio richiesto al PM** · Correzione UI consegnata; scena lasciata aperta all’utente. Nessun nuovo collaudo o backlog avviato. Fonti e prove in candidato/exam_human_master/C1266_CHAT_REENTRY.json; recupero incipit precedente conservato in C1266_MANUAL_OPENING_RECOVERY.json.
