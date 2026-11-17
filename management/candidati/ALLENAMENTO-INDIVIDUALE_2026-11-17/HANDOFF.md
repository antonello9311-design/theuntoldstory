# TRAINING-SCHEDA-STAFF-RELEASE-20261117 · Staff e Land

**Collaudo Staff.** Requisito Terra mancante su Scudo di terra. Saldo simulato 70 → 20 per Turbine della Foglia, una sola ricevuta. Secondo avvio indisponibile nella stessa giornata. Alle 06:00 simulate Riuji ha aperto il duello con la Scheda di testperfunzioni chiusa. Tecnica nello snapshot e autorizzata dal profilo Combat. Alla riapertura la Scheda mostra tecnica appresa e nuova quota. Saldo 20 insufficiente per un’altra tecnica da 50 XP. Scontro e prova chiusi, ricevute conservate. Impronte di schede, tecniche e sessioni reali dei due PG invariate. Nessun attacco e nessuna chiamata IA.

**Ricevute.** Caso `c85e5c01-fa51-4702-bebf-5974fe13b9a5`, allenamento `463a2a26-55d9-431c-9c84-d33c33711046`, duello `e82c39e3-bac8-48af-8220-19c4c20b56f5`. La maturazione è attestata alle 06:00 di Roma. L’accettazione di Riuji ha aperto lo scontro e acquisito la tecnica; nessuna richiesta dalla Scheda di testperfunzioni è intervenuta tra cambio giornata e apertura.

**Versione.** Migrazione Staff `20261117132938` e apertura pubblica `20261117134747`. Raccordo del primo round applicato senza riscrivere i sei produttori Combat. L’opzione in role conserva cooperativa, gruppo, sparring e i percorsi speciali. L’apertura e le guardie sono state verificate sul database. La prova protetta non addebita XP reali e non verifica una spesa volontaria di un giocatore Land.

## Consegna precedente

**Perimetro.** Allineamento documentale del 17/11/2026 sul precedente `TRAINING-SCHEDA-CUTOVER-20261117`. Regolamento Markdown e HTML sincronizzati al §6.1, changelog 105 nel Markdown, Guida collegata alla sezione. Il percorso vigente resta in role.

**Riscontro.** Zero tecniche in addestramento al momento della lettura DB. RPC di avvio e configurazione di rilascio giornaliera assenti. Il percorso in Scheda è nei sorgenti e attende installazione e collaudo protetto. Resta da verificare il raccordo all’apertura Combat.

## Consegna della candidata precedente

**Mandato e chiusura.** Lama di vento di Riuji e Risonanza Katon di Kirei assegnate. Registrato il completamento 1/1 su entrambe le schede. Gli XP disponibili e accumulati sono invariati. Le ricevute amministrative non occupano la giornata di gioco. Ricontrollo dopo la migrazione `20261117103709`. A database zero addestramenti aperti, ricevute `3baacf5c-3bc0-4a3b-8e4f-6075ecddf414` e `5512d9fa-581a-4519-b7e1-d071f1f2b119`. Review indipendente 0/0/0. Gli eventi di role storici restano in archivio.

**Sorgenti.** `candidato/TRAINING_DAILY_STAFF.sql` introduce autorizzazione riservata alla Staff Test Room per il PG di prova, quota giornaliera condivisa tra Scheda e Training giocato, RPC idempotenti e maturazione al cambio di giornata del server. Le prove simulano il saldo in un registro isolato. Il percorso reale riusa `training_eligibility` e `_spendi_xp`. La patch client adegua Scheda e le code Training Admin. `candidato/TRAINING_DAILY_RECOVERY.sql` sospende i nuovi avvii preservando lo storico.

**Decisioni di implementazione.** Il cambio è alle 06:00 di Roma secondo `_training_giornata`. La candidata conserva i percorsi specifici di Innate, leggendarie, evocazioni, Cercoteri e tecniche con guidance attiva. Per le altre tecniche idonee vale un’unica sessione. Confermare eventuali eccezioni nominative prima dell’apertura.

**Qualifica.** Sintassi SQL e PL/pgSQL, pin dei corpi vivi e patch client verificati staticamente. Confine di giornata confermato con una lettura del calendario server ordinario e nei due cambi di ora. Review senza rilievi bloccanti nel perimetro Staff di una sessione semplice. Candidata pronta per l’installazione e il collaudo Staff. Il flusso giornaliero è ancora nei sorgenti.

**Rischio aperto per Land.** Prima di un’apertura in Land va verificata la propagazione delle tecniche maturate ad avvio Combat per tutti gli attori, anche quando un partecipante non ha ancora aperto la Scheda. La qualificazione Staff di una singola sessione usa i requisiti del personaggio di prova e un saldo separato. La maturazione della sessione è letta alla prima richiesta pertinente in Scheda, ingresso Land o apertura del pannello Combat. Evitare polling, nuove prove di clan e consumi reali durante il collaudo.
