# 08 · PIANO DELLE PROVE — catalogo e criteri di esecuzione

> Allineato il 09/09/2026. Gli ID 1–29 conservano il catalogo avviato il 02/09; non sono una lista di prove ancora da fare né un mandato a eseguirle tutte. Revisione, stato e programma corrente si leggono nella scheda d'area e nella SCHEDA/HANDOFF del cantiere. Questo aggiornamento documentale non esegue né ricertifica prove.

## 0. Scegliere la prova e l'ambiente
Una prova del server verifica regole e transazioni; una prova nel browser verifica anche accesso, aggiornamento della pagina e comprensibilità del percorso. Prima di eseguire si dichiarano requisito, revisione, ambiente, casi, esiti attesi e budget di chiamate, token e tempo. Si riusano i banchi e le evidenze pertinenti già disponibili; non si ripete l'intero catalogo a ogni build.

**Docker è il banco ordinario:** PostgreSQL reale per migrazioni, integrazioni rappresentabili, concorrenza, fault injection e recovery. Schema, vincoli e cataloghi devono corrispondere alla baseline pertinente; fixture sintetiche o sanitizzate, differenze documentate. Un mock o un'identità simulata non certificano Auth, API o servizi Supabase reali. Per un rischio significativo non coperto in locale né da un collaudo live realmente isolato si propone un branch temporaneo, con costo, durata e creazione autorizzati. Nessun branch QA permanente è richiesto.

**Il collaudo di una funzione già rilasciata si svolge direttamente sul sito protetto:** Antonello ha autorizzato Codex e Claude a usare testperfunzioni e Riuji nella Staff Test Room, tramite accessi e porte normali. Non si chiede di nuovo il permesso per quei due PG e non si impone prima una campagna locale. Il browser può essere usato dall'agente nel perimetro autorizzato; una prova utente finale resta distinta quando richiesta dal rilascio.

La Test Room condivide il DB di produzione: `is_test` da solo non garantisce isolamento. Sono vietate impersonazioni SQL di PG reali, transazioni mutanti fuori dai percorsi protetti anche se annullate, fault injection e migrazioni sperimentali in produzione. Se il percorso scrive sulle risorse reali o incontra un errore di sicurezza, fermare la prova e registrare il difetto; ripristinare dopo non equivale a isolare. Prima/dopo si confrontano risorse, progressione e assenza di effetti esterni; si conservano audit e storico. Provider reali comportano chiamate e costi reali, da misurare quando disponibili.

**Campagna corrente:** rispettare il mandato di mantenere la stessa scena Staff aperta, senza reset né reinviti. Il collaudo della Test Room utenti 070 e il relativo lavoro tester sono differiti per questa tranche; l'allineamento delle due superfici resta il requisito generale, non un risultato già ottenuto. I 20 campioni Esame, le prove 096 e le controverifiche terminali conservano i loro esiti: non si rilanciano per effetto di questo catalogo. Un seguito richiede il mandato pertinente e non può mascherare la ripetizione dello stesso ciclo esaurito.

Le tabelle seguenti conservano temi, ID e fonti utili. Numeri e versioni esplicitamente storici descrivono il caso originario; prima di un eventuale riuso, gli attesi si ricavano dal contratto e dalle regole correnti. Nessuna riga autorizza acquisti, progressione o modifiche di account reali.

## 1. Catalogo dei percorsi di prodotto
| # | Cosa | Come, se incluso nella campagna autorizzata | Esito e fonte |
|---|---|---|---|
| 1 | **Esame e narrazione** | Il caso originario riguardava v106: l'audit 02/09 distingueva 41 annullamenti QA su 44. Non ripetere i 20 campioni già conclusi; osservare i soli seguiti previsti da `aree/ESAME.md` | pubblicazione, tempi, ripiego e chiusura secondo il contratto della revisione provata; `esame_ia_tentativi`, `esame_narrazione_cicli`, `esame_monitor_eventi`. Un vecchio `model=null` o un conteggio QA non misura l'abbandono |
| 2 | **Missione umana completa** | bacheca → prenotazione → conferma → Regia con `mission_id` → scontro → chiusura con esito, nel contesto di prova autorizzato | prenotazione e stato coerenti, ricompensa una volta sola secondo le regole; `mission_bookings`, `missions.status`, ledger e progressione simulata nel banco |
| 3 | **Test Room utenti 070** | catalogo differito nella tranche attuale; caso storico: due non staff, quota di 5 dispatch e sesto, KO/ripristino Manichino, confine 06:00 | quota vigente e messaggi corretti, zero effetti su risorse/progressione reali; `test_room_user_*`. Permessi e cataloghi staff non passano agli utenti |
| 4 | **Training V2** | individuale, cooperativo e gruppo fino al completamento; abbandono, nei casi pertinenti | progresso atomico, notifiche, slot e costi secondo il contratto; `training_sessions`, `character_abilities`, `slot_tecniche` |
| 5 | **Premi acquistati e richiesti** | caso originario: `punti_caratteristica` Genin e `tecnica_personale`, con approvazione/rifiuto; banco isolato per gli effetti sulla progressione | accredito e addebito una volta sola; il +15 era l'atteso della fixture originaria, da confrontare con regole correnti; `character_perks`, `premio_richieste`, `characters.exp/unspent_points` |
| 6 | **Scontro V2 e Regia** | percorso umano o IA previsto dal mandato; posizioni e portata note, opzioni offerte, selezioni durante il polling e chiusura. In Staff valgono i due PG autorizzati; la scena corrente resta aperta | server rifiuta l'azione illegale, pagina conserva selezioni e mostra il risultato, lifecycle coerente; `combat_v2_*` e browser. Sostituzione è offerta solo se legale nel contratto corrente, non vietata in assoluto |

## 2. Catalogo del percorso giocatore e della UI
Scegliere le righe interessate dalla modifica e dalle sue dipendenze. Un cambiamento grafico circoscritto non richiede automaticamente registrazione, esame e progressione completi.

| # | Cosa | Esito e limiti |
|---|---|---|
| 7 | Registrazione, nomi consentiti, conferma email, login, «Ricordami», reset password | messaggi comprensibili e sessioni gestite secondo il contratto; solo account di prova autorizzati, nessuna modifica alle credenziali dei due PG Staff |
| 8 | Creazione PG: età, villaggio, elemento, distribuzione punti | validazione server e UI coerenti con le regole vigenti. Fixture originaria: 60 punti, passi di 5, tetto 30; PV = 50 + Resistenza, chakra = 30 + (Ninjutsu + Mente) × 1,2. Questi dati storici non prevalgono su `REGOLE.md` e stato verificato |
| 9 | Registrazione role e accredito giornaliero | `role_sessions` e `role_session_participants.xp_assegnato`, nessun doppio accredito. Caso originario: role di 500 caratteri e 20 XP Deshi; non è una regola editoriale del narratore e non autorizza premi reali di prova |
| 10 | Lezione L1, L2 con compagno e ingresso uditore | attestato una volta, giornata e avanzamento coerenti, niente ripetizioni improprie del Sensei; orario storico 06:00–05:59 da confrontare con il contratto vigente |
| 11 | Chat: parlato, nomi, sussurro, dado e segnalazione staff | formattazione e legenda coerenti, riservatezza rispettata; nessun accesso ai messaggi privati altrui per costruire la fixture |
| 12 | Mobile 390×844: land, scheda, Regia e pannellino «Aa» | nessuno scorrimento orizzontale involontario, testi lunghi leggibili, azioni accessibili; ampliare dispositivi o pagine solo se previsto dal rischio e dal budget |

## 3. Catalogo delle verifiche tecniche
In produzione si leggono soltanto dati e metadati necessari, senza segreti né contenuti privati nei referti. Le verifiche effettive dei permessi tramite API richiedono il contesto autorizzato; una lettura del catalogo RLS non le sostituisce.

| # | Cosa | Come ed esito atteso |
|---|---|---|
| 13 | Pool e progressione | confrontare PV/chakra e massimi, saldi e provenienza dei punti con formule e acquisizioni vigenti, inclusi premi e modificatori; riportare anomalie aggregate. La vecchia uguaglianza «60 + promozioni» non copre da sola ogni provenienza |
| 14 | Slot | confrontare `slot_tecniche` e abilità attive/in addestramento, applicando le esclusioni correnti per innate e leggendarie |
| 15 | Promozioni | verificare la traccia prevista per esame vinto o promozione manuale; distinguere fixture e PG reali |
| 16 | Cron | confrontare pianificazione, esecuzioni ed errori con la finestra e il contratto del job; un job non dovuto non è guasto. Eventi critici da qualificare, nessuna modifica di cron o token |
| 17 | Edge | versione e configurazione coerenti con il rilascio; test di risposta solo per endpoint e budget autorizzati. Gli esiti anonimi 401/405 non sono l'atteso universale di tutte le Edge |
| 18 | RLS | verificare policy, permessi e accessi del proprio contesto; prove negative su fixture isolate per dati privati e scritture XP. Nessuna impersonazione SQL di PG reali |
| 19 | GRANT | confrontare le funzioni `SECURITY DEFINER` eseguibili da `anon` con le eccezioni approvate; il vecchio conteggio di 15 non è una verifica corrente |
| 20 | Registro e recovery | per il rilascio pertinente, sorgenti coerenti con migrazioni applicate, autorizzazione e piano di recovery verificato; nessuna falsificazione della history né rollback universale presunto sicuro |
| 21 | Pubblicazione | confrontare i file del rilascio con remoto, SHA, build e dominio secondo `aree/PUBBLICAZIONE.md`; dichiarare la coda residua senza presumere un numero fisso di file |
| 22 | Fondazioni e proprietari | raccordare componenti e tabelle al cantiere, alle dipendenze e allo stato dichiarato; una tabella vuota non dimostra da sola inutilità o difetto |
| 23 | Funzioni e ingressi legacy | cercare chiamanti in pagine, Edge, SQL e contratti, inclusi gli ingressi dinamici; una ricerca testuale senza risultati non autorizza ritiro o cancellazione |

## 4. Robustezza nel banco isolato
Replay artificiali, concorrenza forzata, richieste manipolate e recovery sperimentali si svolgono in Docker o nell'eventuale branch specificamente autorizzato. In live restano le normali azioni protette del collaudo approvato. Nessuna cancellazione dello storico.

| # | Cosa | Esito atteso |
|---|---|---|
| 24 | Doppio invio delle azioni interessate, con la stessa `request_key` | un solo effetto e ricevuta di replay coerente; coprire i confini transazionali del contratto |
| 25 | Due Master aprono nello stesso luogo | rifiuto coerente del secondo ingresso; codice storico `scontro_gia_aperto_nel_luogo`, da confrontare con il contratto corrente |
| 26 | Difesa dopo il congelamento | rifiuto senza effetti; codice storico `fase_non_valida` |
| 27 | Tecnica non posseduta o non offerta, richiesta manipolata nel banco | rifiuto server senza effetti; codice storico `opzione_non_offerta` |
| 28 | Provider indisponibile durante il tick Esame | nel banco simulare l'indisponibilità senza segreti; verificare ripiego e chiusura ai tempi del contratto. I precedenti 3 minuti/3 ore non sono soglie universali. Nessuna modifica live a token o cron autorizzata da questa riga |
| 29 | Recovery della migrazione o funzione interessata | su PostgreSQL reale con versione e baseline dichiarate, ripristino delle invarianti previste e registro coerente; confrontare impronte prima/dopo. Nessuna prova mutante sui PG reali, anche con `ROLLBACK` |

## 5. Budget, esito e riuso delle prove
Per ciascuna candidata valgono **un passaggio indipendente, una correzione aggregata e una controverifica finale**. Casi, chiamate, token e tempo si fissano prima della campagna sulla stessa revisione. Un rosso blocca pubblicazione e produzione dipendenti, ma si raccolgono gli altri casi previsti salvo P0, rischio dati/sicurezza, budget esaurito o mutazione non prevista. Il reviewer non aggiunge esempi dopo il referto; niente micro-patch o retry per cercare casualmente un verde.

La controverifica consegna il verdetto anche rosso: il ciclo termina e torna al PM, senza ulteriori patch, subreview o rinomina della stessa versione. Prima del rilascio servono review `0/0/0`, matrice completa, preflight readonly, recovery verificato e gate nominativo; il branch temporaneo si aggiunge solo quando la valutazione dei rischi lo richiede. Lo smoke controllato sul sito precede l'apertura generale autorizzata. Una rigenerazione IA prevista dal prodotto si misura separatamente dal successo al primo tentativo.

I controlli tecnici pertinenti possono essere automatizzati riusando i banchi esistenti. Non si introduce qui un nuovo file obbligatorio di query, una CI o l'esecuzione dei punti 13–22 a ogni avvio. Dopo verifiche sufficienti per il cambiamento si procede alla consegna; si amplia o ripete il banco solo per nuove modifiche, fallimenti o rischi irrisolti, entro il ciclo autorizzato.

## 6. Registrare un difetto senza perdere la prova
Nella scheda d'area e nei referti del cantiere esistenti: data, revisione, ambiente, ID del caso, passi, visto/atteso, evidenza, gravità, owner e limite di copertura. Distinguere difetto del prodotto, fixture, banco o ambiente; un setup fallito non certifica il caso non eseguito. Conservare il risultato originario e qualificare cosa blocca; non trasformare un PASS parziale in esito complessivo verde.

`SCHEDA.md`, `HANDOFF.md` e `STORICO.md` seguono il formato di `AGENTS.md`. Nessun testo completo delle role, segreto o dato privato nei referti; nessun nuovo documento datato o sezione «Rettifica». Le evidenze già concluse restano disponibili senza diventare automaticamente nuovo lavoro.
