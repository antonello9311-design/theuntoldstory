in lavoro · 17/11/2026 · definizione del prodotto e preparazione del passaggio

# Allenamento individuale in Scheda

## Decisione di prodotto

Il giocatore svolge l’allenamento individuale ordinario direttamente in **Scheda → Tecniche**. Sceglie una tecnica, verifica costo e requisiti, paga gli XP all’avvio e attende il tempo di un allenamento. A tempo maturato la tecnica risulta appresa. Il flusso ordinario richiede una sola sessione e si svolge interamente in Scheda. Solo le tecniche speciali con un percorso esplicito conservano regole individuali di apprendimento diverse.

Resta il limite complessivo di **un allenamento al giorno per personaggio**, secondo la giornata di gioco già in vigore dalle **06:00 alle 05:59, ora di Roma**. Il server verifica il saldo XP e le condizioni di accesso della tecnica, incluse grado, statistiche e prerequisiti applicabili. Costo e requisiti provengono dal catalogo autorizzato.

## Flusso previsto

1. La Scheda mostra le tecniche, il costo in XP, i requisiti soddisfatti o mancanti e l’ora del prossimo allenamento disponibile.
2. Con un solo avvio il server verifica l’idoneità, impegna la giornata e addebita gli XP. Un doppio clic o un reinvio restituiscono la stessa ricevuta.
3. Durante l’attesa la Scheda mostra quando maturerà la sessione. Il tempo trascorre anche a pagina chiusa. Il server determina la maturazione e registra una sola acquisizione. Al ritorno nella Scheda l’esito è visibile senza ripetere l’avvio.
4. Una tecnica speciale mostra il proprio percorso approvato. Il catalogo distingue esplicitamente i casi speciali, così una soglia storica superiore a uno non basta a conservare un vecchio obbligo di role.

## Scelte da chiudere prima dell’implementazione

- **Durata effettiva** del singolo allenamento ordinario.
- **Elenco delle tecniche speciali** e percorso di ciascuna. La modifica riguarda l’apprendimento individuale. Cooperativa, gruppo e sparring restano fuori da questo incarico.
- **Transizione delle tecniche già in addestramento.** Conservare XP già pagati, progressi, decisioni Staff e storico. Definire la riqualificazione a una sessione ordinaria per le sole tecniche con percorso accertato, senza un nuovo acquisto né attribuzioni retroattive automatiche.

## Integrazione e verifica

- Riutilizzare l’eligibilità e i consumi del Training esistente. Lo stato, il tempo e la ricevuta appartengono al server. Verificare che il nuovo percorso e quello giocato non possano entrambi attribuire lo stesso progresso o superare la quota giornaliera.
- Casi Staff da predisporre con risorse simulate e senza provider IA. Avvio idoneo, XP insufficienti e requisiti mancanti, secondo avvio nella stessa giornata anche su un’altra tecnica, doppio clic e riconnessione, confine delle 06:00, timer oltre la chiusura della pagina, acquisizione unica, eccezione speciale e transizione di un avanzamento preesistente.
- L’aggiornamento pubblico di `REGOLE.md` e `regole.html` accompagna l’apertura della funzione collaudata. La sezione 6.1 attuale documenta il percorso in uso.
