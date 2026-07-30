# Collaudo — il percorso di un nuovo iscritto

*Lista di prova riutilizzabile a ogni rilascio. Si segue nell'ordine: è il percorso vero di chi si iscrive oggi, non un elenco di funzioni.*

**Prima di cominciare:** carica su GitHub `scheda.html`, `admin.html` e `land.html`, poi **Ctrl+F5**. Se una prova fallisce, la prima domanda è sempre «l'ho caricato?».

**Come lavoriamo:** tu giochi dall'altro PC, io resto in ascolto sul database. A ogni passo ti dico **cosa dovrebbe essere successo lato server** — non basta che la pagina non dia errore, deve essere finita una riga nel posto giusto. Scrivimi «fatto il punto 3» e controllo.

---

## 1 · Registrazione e primo accesso

| # | Cosa fai | Cosa deve succedere |
|---|---|---|
| 1.1 | Ti registri con una mail vera che leggi | Arriva l'email di conferma da `no-reply@theuntoldstory.it`, non in spam |
| 1.2 | Provi una password debole (`password1`) | Rifiutata: servono 10 caratteri, maiuscola, minuscola, cifra e speciale |
| 1.3 | Confermi e accedi **col nome del personaggio**, non con la mail | Entri |
| 1.4 | Provi ad accedere con la password sbagliata | Messaggio chiaro, nessun dettaglio che aiuti un attaccante |

> **Io controllo:** la riga in `profiles` con `role='player'`.

---

## 2 · Creazione del personaggio

| # | Cosa fai | Cosa deve succedere |
|---|---|---|
| 2.1 | Crei il PG: nome, età, sesso, villaggio | Parte da **Deshi**, senza clan, senza corporazione |
| 2.2 | Provi un nome già usato | Rifiutato dal server, non solo dalla pagina |
| 2.3 | Lasci l'**Elemento del Chakra** vuoto | Deve essere permesso: è facoltativo |
| 2.4 | Poi scegli un elemento dalla scheda | Si salva. **Riprova a cambiarlo**: dev'essere bloccato, si sceglie una volta sola |
| 2.5 | Guardi il blocco identità | **Non deve comparire** la riga della seconda natura: sei Deshi |

> **Io controllo:** `characters` (rank `Deshi`, clan `Nessuno`, `element2` nullo) e che `character_elementi` restituisca un elemento solo.

---

## 3 · I 60 punti

| # | Cosa fai | Cosa deve succedere |
|---|---|---|
| 3.1 | Assegni i punti a gruppi di 5 | Il totale scala, non puoi sforare |
| 3.2 | Provi a superare **30** in una caratteristica | Rifiutato: è il tetto del Deshi |
| 3.3 | Guardi se c'è la riga **Innata / Kekkei Genkai** | **Non deve esserci**: serve un clan e almeno il Genin |
| 3.4 | Ricarichi la pagina | I punti assegnati sono ancora lì |

> **Io controllo:** che `unspent_points` e le nove caratteristiche tornino, e che la guardia abbia rifiutato ciò che doveva rifiutare.

---

## 4 · L'Accademia — il pezzo più delicato

Non c'è nessun pulsante: **ci si va fisicamente**. Apri la mappa e entra in *Konoha — Accademia Ninja* (o *Suna — Accademia*).

| # | Cosa fai | Cosa deve succedere |
|---|---|---|
| 4.1 | Entri nel luogo | Compare il riquadro dell'accademia. In **qualsiasi altro luogo non deve comparire** |
| 4.2 | Avvii la lezione **L1** | Il sensei del tuo villaggio apre la lezione (Katsuo a Konoha, Ibara a Suna) |
| 4.3 | Scrivi il tuo turno | Il sensei risponde dopo 5-7 minuti. **Non deve rispondere due volte** |
| 4.4 | Vai avanti fino alla fine di L1 | La lezione si chiude e risulta superata |
| 4.5 | Provi a rifare L1 subito | Rifiutata: una lezione ogni ~20 ore |
| 4.6 | Fai **L3** | A fine lezione ti trovi in scheda **quattro** abilità: Controllo del chakra, Uso dei sigilli, Camminata sulle superfici, **Dispersione** |
| 4.7 | Fai L4, L5, L6 | Una tecnica ciascuna: Trasformazione, Clone, Sostituzione |
| 4.8 | Fai l'**Esame Genin** | Diventi **Genin**, +15 punti, e si apre la bacheca missioni |

> **Io controllo:** `academy_class_sessions` (stato e passi), `academy_class_participants`, `character_jutsu` dopo L3-L6, e il salto di `rank` dopo l'esame.
>
> ⚠️ Se il sensei non risponde entro 10 minuti, fermati e dimmelo: è il cron `academy-tick`, e voglio guardare i log prima che tu riprovi.

---

## 5 · Il primo giorno in land

| # | Cosa fai | Cosa deve succedere |
|---|---|---|
| 5.1 | Entri in un luogo e scrivi meno di 500 caratteri | Il contatore te lo dice |
| 5.2 | Scrivi un turno vero, oltre 500 | Il messaggio compare, con avatar e nome |
| 5.3 | Chiudi la role | **+20 XP**, una volta sola |
| 5.4 | Chiudi una seconda role lo stesso giorno | **Nessun XP**: è una volta al giorno |
| 5.5 | Provi un messaggio di 6.000 caratteri | Rifiutato dal server: il tetto è 5.000 |
| 5.6 | Guardi chi c'è online e chi entra ed esce | I nomi sono quelli giusti |

> **Io controllo:** `messages`, `role_sessions` e il registro XP — che i +20 siano una riga sola.

---

## 6 · Combattimento

| # | Cosa fai | Cosa deve succedere |
|---|---|---|
| 6.1 | Apri il **⚔** e lanci una tecnica che conosci | L'esito appare in chat, il chakra scala da solo |
| 6.2 | Lanci una tecnica senza avere chakra | La tecnica **non parte** |
| 6.3 | Guardi i danni | Sono multipli di 5 e non superano mai **65** per azione |
| 6.4 | Provi la **Dispersione** su un genjutsu | Riesce se la tua Mente ≥ potenza dell'illusione |

---

## 7 · I premi — mai provati con un click

**È la parte che ho riscritto stamattina e che nessuno ha ancora premuto.** Se qualcosa si rompe stasera, con ogni probabilità è qui.

| # | Cosa fai | Cosa deve succedere |
|---|---|---|
| 7.1 | Apri i Premi in scheda | Due gruppi nel menù: **«Si compra subito»** e **«Lo valuta lo staff»** |
| 7.2 | Scegli il **Contratto di evocazione** | Il titolo diventa «Compra un premio», il bottone dice **Acquista**, e sotto si legge l'effetto |
| 7.3 | Premi Acquista senza avere 600 XP | Rifiutato: saldo insufficiente |
| 7.4 | (Con XP a sufficienza) Acquisti | **XP scalato subito**, il premio compare fra i tuoi |
| 7.5 | Scegli un premio maggiore (es. **Sigillo maledetto**) | Il bottone dice **Invia allo staff**, e la riga del costo avverte che l'XP si scala all'approvazione |
| 7.6 | Invii con meno di 60 caratteri | Rifiutato |
| 7.7 | Invii una richiesta vera | Compare fra le richieste in attesa; **l'XP non è ancora stato scalato** |
| 7.8 | Dal pannello admin la approvi | **Ora** l'XP si scala e il premio entra in scheda |
| 7.9 | Provi a chiedere **Le cinque nature** da Genin | Rifiutato: serve Jonin Speciale |

> **Io controllo:** `character_perks`, `premio_richieste` e il registro XP — che l'addebito avvenga nel momento giusto e **una volta sola**.

---

## 8 · Il catalogo delle tecniche

| # | Cosa fai | Cosa deve succedere |
|---|---|---|
| 8.1 | Apri il catalogo | Vedi le generiche, le abilità e — **solo se sei di un clan** — quelle del tuo clan |
| 8.2 | Cerchi «Manto» o «Richiamo» | **Non devono comparire**: non sei una Forza Portante e non hai un contratto |
| 8.3 | Avvii un allenamento su una tecnica che puoi | Parte, e il contatore dice «in addestramento 1/3» |
| 8.4 | Provi una tecnica fuori dal tuo rango | Rifiutata **con il motivo scritto**, non con un errore secco |
| 8.5 | Provi due allenamenti nello stesso giorno | Il secondo è rifiutato |
| 8.6 | Guardi la barra degli slot | I numeri tornano con il tuo grado |

---

## 9 · Il resto della land

| # | Cosa fai | Cosa deve succedere |
|---|---|---|
| 9.1 | Apri il **calendario** e aggiungi un impegno | Il **+** si preme davvero: la ✕ di chiusura non deve più coprirlo |
| 9.2 | Apri la bacheca del villaggio | I post ci sono |
| 9.3 | Apri le **missioni** | Da Genin vedi le missioni D e C |
| 9.4 | Mandi un messaggio privato a un altro account | Arriva |
| 9.5 | Premi la **⚑** su un messaggio | La segnalazione parte e non è visibile agli altri |
| 9.6 | Apri **Cercoteri** dal menù Mondo | La scala del Manto mostra **due acquisti**, non cinque gradini, e la soglia di lucidità è quella nuova |
| 9.7 | Guardi il sito da telefono | Le pagine reggono |

---

## 10 · Le cose nuove di questi due giorni

Un account appena iscritto non ci arriva: **servi tu dal pannello admin**, su un secondo personaggio di prova.

| # | Cosa fai (da admin) | Cosa deve succedere |
|---|---|---|
| 10.1 | Porti un PG a **Jonin** | In scheda compare il selettore della **seconda natura**, con l'elemento base disabilitato |
| 10.2 | Il giocatore la sceglie | Si salva, **senza costare XP**, e la riga sparisce: la scelta è definitiva |
| 10.3 | Da admin la cambi e poi la **rimuovi** | Da staff si può; il bottone chiede conferma due volte |
| 10.4 | Assegni un **Cercoterio** a un PG **con un clan** | Rifiutato con un messaggio leggibile: prima si toglie il clan |
| 10.5 | Lo assegni a un PG senza clan | Entra. Ora la riga Innata si chiama **Sintonia** e cresce anche senza clan |
| 10.6 | Il giocatore cerca le tecniche della **sua** bestia | Le vede. Quelle delle altre otto **no** |
| 10.7 | Provi a far entrare in un clan una Forza Portante | Rifiutato con un messaggio, non con un errore Postgres |
| 10.8 | Il giocatore crea un'**evocazione** senza aver imparato il Richiamo | Rifiutato: «il contratto non basta» |
| 10.9 | Dopo i tre addestramenti, la crea scegliendo la famiglia | Entra, e la famiglia non si può più cambiare |
| 10.10 | Nel **Listino dei premi** cambi il costo dell'evocazione da 600 a 500 | Cambia **insieme** in scheda, nel listino e nei controlli del server |
| 10.11 | Carichi i 6 emblemi `evofam` | Ora si salvano (il vincolo è stato corretto il 30/07) |

---

## 11 · Cosa ti chiedo se qualcosa va storto

Non serve che indaghi: **copiami il messaggio d'errore esatto** e dimmi il numero del punto. Se non c'è nessun messaggio ma «non succede niente», dimmi cosa hai premuto e cosa ti aspettavi — quasi sempre significa che il server ha rifiutato in silenzio, e a database si vede.

Le tre cose che considero più fragili, in ordine: **i premi** (§7, riscritti stamattina e mai premuti), **la creazione dell'evocazione** (§10.8-10.9, catena lunga fra contratto, addestramento e famiglia), e **il sensei dell'accademia** (§4.3, dipende da un cron e da un modello esterno).
