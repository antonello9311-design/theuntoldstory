# 07 · ARCHITETTURA — valutazione complessiva, cosa manca, come migliorare

> Scritto il 02/09/2026 dopo un mese di beta, sui numeri di `01_STATO_ATTUALE.md`. Si riscrive quando cambia il giudizio, non quando cambia un numero. Non è un elenco di difetti: è la mappa di dove il sistema è più forte di quanto serva e dove è più debole di quanto sembri.

## 1. Il giudizio in tre frasi
Il **motore** è più solido di quasi ogni gioco amatoriale: server-authoritative, RLS ovunque, eventi idempotenti con chiave di richiesta, sigilli e review a tre livelli di gravità, rollback depositati. Il **prodotto** è molto più indietro del motore: in un mese i giocatori hanno usato l'Accademia e la chat, hanno annullato il 62% degli esami, non hanno prenotato nessuna missione, non hanno chiesto nessun premio, e l'attività in chat è scesa da 39 role a settimana a 1. La **complessità** è cresciuta più del gioco: 716 funzioni, 23 schemi privati, 91 tabelle vuote e 1.082 candidati per 73 personaggi.

## 2. Cosa funziona, e va protetto
- **«L'IA racconta, il server comanda»** è rispettato ovunque conta: danni, XP, promozioni, posizioni, esiti sono funzioni del database; le IA ricevono ricevute, non decidono. È il vero vantaggio competitivo del progetto: non va indebolito per fare prima.
- **Idempotenza e concorrenza**: `combat_v2_event_begin` con `request_key`, lock di scope, versioni di controllo, `on conflict` come lock. Le lezioni in memoria (scontrino monouso, guardia su NULL, ancore vive) sono state imparate sul serio.
- **Il metodo dei candidati**: candidato → review indipendente → readiness → apply → postflight con impronte. Ha evitato incidenti seri in un mese di apply quotidiani. Il problema non è il metodo ma il suo volume e la mancanza di un tetto.
- **Le pagine monolitiche** sono brutte da modificare ma semplici da pubblicare: nessuna build, un file, un caricamento. Il caricamento GitHub autonomo non cambia questa scelta; richiede però owner esclusivo, confronto con la testa remota e verifica del dominio.

## 3. Cosa manca, in ordine di danno
1. **L'atterraggio.** Otto programmi «applicati inerti» (Missioni IA, Ninja Book, PNG Builder, Training Sensei, Composite, Innata Common, Eligibility, Surface) e nessuno con un giocatore dentro. Il gioco visibile è quello di fine agosto. Ogni fondazione nuova costa attenzione e non aggiunge nulla finché la precedente non atterra.
2. **L'Esame è l'imbuto, e perde il 62%.** 35 annullamenti su 56 prove. Non sappiamo ancora se annullano i giocatori (noia, blocco), il tick (ripiego), o il monitor. Finché non lo sappiamo, ogni lavoro sul Narratore d'esame è cosmetico.
3. **Le missioni non esistono per i giocatori.** 21 in bacheca, 0 prenotazioni in 30 giorni con 78 profili. O il flusso è rotto, o non si vede, o non si capisce cosa succede dopo. È la funzione con il rapporto più alto fra investimento (dieci programmi IA) e uso (zero).
4. **Tre modelli di PNG che non si parlano**: `png_templates` (formato compatto, letto dalla Regia umana; Rina entra con 10 PV e 0 chakra), i template del Ninja Book (formato ricco, via offerte del servizio), il PNG Builder v17 (fondazione generalizzata, vuota). Il documento di architettura del 02/09 dice che il Builder è la destinazione: allora `png_templates` deve diventare una proiezione del Builder, non una terza fonte.
5. **Due motori di scontro e due Regie**: il legacy (`combat_sessions`, 14 partite, pulsante «Combatti») e il V2 (3 partite). Il legacy va dismesso con una data, o continuerà a ricevere bug e a confondere la guida.
6. **Nessuna suite di regressione eseguibile a comando.** Ogni candidato ha il suo banco PG17 ×2, ma non esiste **un** banco che si lancia prima di ogni apply e dice «il gioco di ieri funziona ancora». Con 104 migrazioni in sei giorni è il rischio più concreto di bug nascosti.
7. **Nessuna metrica di prodotto.** Le domande «quanti giocano, dove si fermano, cosa abbandonano» oggi si rispondono con query a mano. Una vista giornaliera (iscritti, PG attivi, role, lezioni, esami per esito, prenotazioni) cambierebbe le priorità da sola.
8. **Il costo del processo**: 1.082 candidati, 537 review, 419 handoff, referti da 225 KB. Il riordino del 02/09 mette il tetto di tre cantieri e le schede d'area; va fatto rispettare, altrimenti fra due settimane siamo daccapo.
9. **Igiene di piattaforma**: 15 SECURITY DEFINER eseguibili da `anon` non ratificati, `pg_net` in `public`, 91 tabelle vuote senza un proprietario dichiarato, FK senza indice nelle fondazioni.

## 4. Come migliorare — le scelte che consiglio
- **Un tetto e un ordine.** Tre cantieri in lavoro, la sequenza di `04_LAVORI_APERTI.md`, e la regola: nessuna fondazione nuova finché non atterra una fra Missioni IA, Training, Clan. Il PM (umano o agente) rifiuta i mandati fuori sequenza.
- **Misurare prima di costruire.** Una vista `v_funnel_giornaliero` (o una tabella alimentata da cron) con dieci numeri; si legge a inizio sessione con `gdr-verifica`. Le priorità delle prossime settimane devono venire da lì, non dai referti.
- **Chiudere l'imbuto dell'Esame** con i dati dei 35 annullamenti prima di ogni altra cosa narrativa.
- **Un solo modello di PNG.** Decidere che il PNG Builder è la fonte; migrare Rina e i template del Ninja Book dentro il Builder; far leggere alla Regia umana una proiezione del Builder. Finché non è fatto, non aggiungere PNG in nessuna delle tre tabelle.
- **Dismettere il legacy con una data**: motore «Combatti», overlay `png_*` della Regia vecchia, tabelle `_pre012`, `_backup_*`. Disattivare, non cancellare.
- **Un banco di regressione unico** (`management/tooling/`): la replica locale PG17 esiste già; serve un solo script che ricrei lo schema dalla produzione, giochi cinque scenari canonici (registrazione → PG → role → lezione → esame → scontro V2 → training) e dica verde/rosso. Diventa prerequisito di ogni apply.
- **Contenere i privilegi**: ratificare o revocare i 15 `anon`; spostare `pg_net`; un proprietario dichiarato per ogni tabella vuota (cantiere o «da ritirare»).
- **Tenere l'IA per sessione**: il provider si accende per una sessione e si spegne al termine (già così per le missioni); mai un flag globale permanente. Vale anche per il budget.
- **Ridurre l'attrito della land** prima del refactor: il difetto Assalto/Moltiplicazione, la chiusura delle sessioni, la guida del motore. Il refactor di leggibilità resta rinviato: non cambia cosa i giocatori possono fare.

## 5. Cosa NON cambierei
La scelta server-authoritative, le pagine statiche con caricamento GitHub controllato, Supabase come backend unico, il provider IA unico con reasoning alto, il metodo candidato/review/apply (con il tetto), e la regola che le cose si provano giocandole.
