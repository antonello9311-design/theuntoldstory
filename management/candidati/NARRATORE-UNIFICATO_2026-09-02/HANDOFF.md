# C1266 · Incipit della prova in corso leggibile

**TASK-ID** · C1266-INCIPIT-HISTORY-20261022.

**Scope toccato** · LAND loadMsgs, getter readonly mission-generic-ui e pin del modulo.

**Contratti usati/modificati** · Nessuna firma RPC, RLS o shape server modificata. Nuovo getter interno chatPublication (principal/location/session/work/publication/epoch), da processingFor validato. Integrazione chat dopo lettura Generic.

**Decisioni prese / OPEN** · Recuperare il messaggio originale attraverso le RLS esistenti; nessuna nuova prova, annullamento o generazione.

**Prove eseguite e risultato** · C1266 · Incipit oltre finestra chat · 22/10/2026: chat_messages_live limita la lettura alle ultime12h; il messaggio originale della prova resta in messages. LAND ora usa la pubblicazione attestata dal work Generic completato della Staff corrente e recupera il medesimo messaggio tramite RLS e filtri id/luogo/tipo. Getter readonly circoscritto a identità, stanza, sessione, work ed epoch; controllo ripetuto dopo le attese, priorità delle pubblicazioni Human/esplicite invariata. Nessuna modifica DB/Edge/dati, nessuna rigenerazione o riapertura della missione; nessun vincolo aggiunto o allentato. Sintassi8script+modulo PASS, review0/0/0; commit f698e6a9f081628247ab6f089783c592bddc3467, Pages39739328668 riuscito. Chrome Staff: incipit originale leggibile dopo ricaricamento, polling e uscita/rientro. Scena, messaggio, audit e contatori identici prima/dopo; zero nuove chiamate provider. Limite: recupero della pubblicazione attestata dal work corrente, non storico completo della missione; nuovi turni/gameplay NOT_RUN.

**Rischi o regressioni da verificare** · Sessione/Auth, pending, race e duplicati verificati staticamente; nessuna fault injection live. Il work successivo può non attestare più il Fato precedente: storico completo non coperto.

**Passaggio richiesto al PM** · Correzione consegnata, nessun backlog avviato. Prove e handoff precedente in candidato/exam_human_master/C1266_INCIPIT_HISTORY.json.
