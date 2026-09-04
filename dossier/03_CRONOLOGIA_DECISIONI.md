# 03 · CRONOLOGIA DELLE DECISIONI

> **A cosa serve.** Prima di riaprire una discussione, si guarda qui: c'è la decisione, la data, e soprattutto se è stata **poi ribaltata**. Il progetto ha cambiato idea diverse volte, e alcuni documenti vecchi descrivono ancora la versione superata: questa pagina dice quale versione vince.

---

## 1. Le decisioni ribaltate — da leggere per prime

Sono i punti in cui un documento del progetto dice ancora la cosa sbagliata. **Quando trovi una contraddizione, vince la colonna di destra.**

| Argomento | Prima si era deciso… | …poi si è deciso | Dove sta ancora scritta la versione vecchia |
|---|---|---|---|
| **Uchiha** | clan estinto, non giocabile | **clan chiuso ma giocabile**, Sharingan su 4 livelli | `claude/clan_bozze.md` |
| **Sabaku** | casata regnante senza dominio della sabbia | **kekkei genkai della sabbia** | `claude/clan_bozze.md` |
| **Sistema di risoluzione** | roll-under 1d100, cerchio elementale ±15 | **1d20 con la regola dei 5** | `PROGETTO_v0.2.md` |
| **Caratteristiche** | 6 caratteristiche, pool +40 | **9 caratteristiche, pool 60**, l'Innata è la nona | `PROGETTO_v0.2.md` |
| **Pool PV/Chakra** | `PV = 50 + res×5`, `Chakra = 40 + (nin+mente)×3` | **`PV = 50 + Res + bonus`, `Chakra = 30 + (Nin+Mente)×1,2 + bonus`** | `claude/bilanciamento_analisi_2026-07-14.md` |
| **Chat OOC** | chat fuori personaggio dentro il gioco | **annullata**, sostituita dal server Discord | `claude/chat_roadmap.md` |
| **Stack tecnico** | Next.js + React + TypeScript, server Hetzner | **HTML statico monolitico su GitHub Pages + Supabase** | `claude/PROGETTO_v0.2_ambiente_di_lavoro.md` |
| **Hosting** | Vercel | **GitHub Pages** | `claude/PROGETTO_v0.2_ambiente_di_lavoro.md` |
| **Promozione automatica a leggendaria** | promuovere le tecniche con `req_stat_value ≥ 95` | **revocata** | §7 di `migration_coerenza.sql`, annullata |
| **Rami medici** | rami con titoli aggiunti | **solo i quattro nomi nudi** | corretto il 27/07 |
| **Tempi IA accademia** | grazia 90 s, classi chiuse a 3 h | **grazia 2 min, anti-doppio-scatto 4 min** | `claude/accademia_fase3_IA_spec.md` |
| **Emblemi bijū come tecniche** | — | i bijū sono un premio, **alternativo al clan familiare** | decisione del 28/07 |
| **Scala del Manto** | cinque gradini a pagamento (750 XP) | **due soli acquisti**, poi le code si pagano in Sintonia e Resistenza | `claude/migration_cercoteri.sql` · `claude/cercoteri_spec.md` |
| **Scala delle code** | **assoluta**: la coda *k* chiede Sintonia 35+5k | **relativa alla bestia**: dal colmo si tolgono 5 punti per coda mancante | changelog 22, superato dal 29 |
| **Soglia di lucidità** | `Sintonia ÷ 10`, poi `(Sintonia − 40) ÷ 5` | `(Sintonia − soglia della prima coda della tua bestia) ÷ 5` | changelog 22, superato dal 29 |
| **Modalità Cercoterio** | Sintonia diversa per bestia | **Sintonia 80 e Jonin Speciale per tutte e nove** | §8.9 prima del 29/07 |
| **Seconda natura elementale** | **premio da comprare, 300 XP** dal Jonin | **traguardo gratuito del Jonin**, irrevocabile per il giocatore | changelog 5, superato dal 31 |
| **Listino dei premi** | costi e ranghi **cablati** in cinque funzioni e due pagine | **tabella `premi`**, modificabile dal pannello admin | changelog 19, superato dal 31 |
| **Quanti premi maggiori esistono** | cinque | **sei**: entra «Le cinque nature» | §8.6 prima del 30/07 |
| **Primo gradino del Richiamo** | Deshi · Ninjutsu 10 *oppure* Genin · Ninjutsu 25 | **Genin · Ninjutsu 10** | `claude/evocazioni_spec.md` |
| **I nomi della scala del Richiamo** | cinque nomi diversi: *Richiamo — taglia Piccola*, *Richiamo Maggiore*… | **una sola voce «Richiamo», livelli 1-5**, come il catalogo | `claude/evocazioni_spec.md` · la copia di `REGOLE.md` nel progetto (28/07) |
| **Immagine dei luoghi generici** | erano nell'arretrato delle immagini | **restano senza immagine di proposito** | `04_LAVORI_APERTI.md` prima del 30/07 |
| **Occultamento e Liberazione dalle corde** | **jutsu** di grado E del programma accademico | **abilità**, senza costo e senza rango | `REGOLE.md` §5.2 prima del 31/07 · changelog 37 |
| **Il minimo di 500 caratteri** | regola scritta ma **non imposta** | **rifiuto vero** in `post_message`, con tre eccezioni dichiarate | changelog 38 |
| **I danni multipli di 5** | il collaudo pretendeva che l'esito fosse multiplo di 5 | **no**: multipla di 5 è la **potenza fissa del jutsu**, l'esito del tiro no | §6 di `claude/collaudo_apertura.md` prima del 31/07 |
| **Il «degressivo giornaliero» 20/14/10/7** | descritto come degressivo sulla **giornata** | scala sull'**XP di carriera** | `04_LAVORI_APERTI.md` prima del 31/07 |
| **Jutsu e Abilità nel menù Mondo** | **due pulsanti** che aprivano la stessa cosa | **un pulsante solo**; il posto liberato diventa **Help** | `04_LAVORI_APERTI.md` §2.4 prima del 01/08 |
| **Dove vive la consultazione dei jutsu** | il pannello della land rimandava alla Scheda | **il Codice delle Tecniche è dove si guarda**, la Scheda è dove si impara | `WORLD.jutsu` e `WORLD.abilita`, voci morte |
| **Il menù Mondo → Evocazioni** | **un paragrafo di testo** dal ramo generico del router | **un pannello suo** a quattro linguette | `WORLD.evocazioni`, voce morta |
| **Dove si crea il compagno PNG** | riquadro dentro la linguetta **Accademia**, visibile a tutti | **linguetta «Compagno PNG»**, visibile solo a chi può averne uno | `01_STATO_ATTUALE.md` prima del 02/08 |
| **Le voci multilivello nel Codice** | una card per livello: il Byakugan compariva **quattro volte** | **una voce sola**, i livelli si scorrono nel dettaglio | il conteggio «358 su 358» del 01/08, ora **327** |
| **Dove stanno i Premi speciali in scheda** | in fondo alla pagina **Jutsu e abilità** | **una linguetta propria**, con l'acquisto diretto separato dalle richieste | `01_STATO_ATTUALE.md` prima del 02/08 sera |
| **Dove stanno le Basi d'Accademia in scheda** | un gruppo **dentro il catalogo**, dopo clan e generiche | **una sezione in cima alla pagina**, con lo stato di ciascuna | `01_STATO_ATTUALE.md` prima del 02/08 sera |
| **Quali virgolette fanno il parlato** | solo `"…"` dritte, `«…»` e `<…>` | **anche le curve `"…"`** di Word e LibreOffice, normalizzate in `fmtBody` | la legenda della land prima del 02/08 notte |
| **Chi sceglie come si difende il bersaglio** | **l'attaccante**: il menù «difesa» stava nella sua finestra | **chi si difende**, con un turno suo che il motore aspetta | `post_combat(p_defense)`, che resta per gli scontri fuori dal motore |
| **Che cos'è una tecnica, per il server** | `tipo_azione`, **testo libero** con 74 valori scritti a mano | **`uso`**, elenco chiuso di cinque valori, più il flag **`difensiva`** | le 89 righe che erano vuote, ora riempite a macchina |
| **La Parata** | tecnica **generica di grado D da comprare** con 50 XP | **reazione di base, gratis per chiunque**, come dice §4.2 del regolamento | la riga «Parata» del catalogo, da ripensare |
| **Le distanze** | narrative: la gittata la controllavano i giocatori | **reali, in metri**, imposte dal server | `post_combat`, che non guarda nessuna distanza |
| **I punti caratteristica alla promozione** | «**+50 punti a ogni promozione**», scritto in §8.3 e **mai concesso da nessuna riga di codice** | **pool cumulato legato al tetto** — 60 · 90 · 120 · 150 · 170 · 200 — concesso **una volta sola per gradino** | §8.3 prima del 02/08 sera · changelog **42** |
| **Come si dichiara un'azione di combattimento** | pulsanti e menù: si sceglie la tecnica dalla finestra, poi si scrive | **si scrive il turno**, e i comandi stanno **fra parentesi quadre dentro il testo** | il pulsante «Combatti» della chat e il pannello a destra, entrambi da rifare |
| **Quando parla il motore** | a ogni colpo, riga per riga | **una volta sola, a fine round** | `_combat_risolvi`, che oggi risolve la coppia |
| **Dove si impara la Dispersione** | concessa da **L3**, «Controllo del chakra» | **nella lezione sui genjutsu**, ancora da costruire | `claude/L3_controllo_del_chakra.md` prima del 03/08 |
| **Come si scopre la propria natura del chakra** | il maestro rimandava **alla scheda** — che è un oggetto OFF | **la carta da chakra**, cinque reazioni, raccontate nel descrittivo e mai a voce | il prompt dei sensei prima del 03/08 |
| **Dove si tiene L3** | in aula, fra i banchi | **nel cortile**, all'aperto, con la salita sull'albero | il copione prima del 03/08 |
| **La voce «Parata» del catalogo** | tecnica generica da comprare, poi «da ripensare» | rinominata **«Contromossa»** | la riga «Parata» prima del 03/08 |
| **La Contromossa** | reazione nuova, da definire (03/08) | **non è in vigore nella v1**: in difesa si risponde e basta | `04_LAVORI_APERTI.md` §5 prima del 05/08 |
| **Come si dichiara un'azione** *(secondo ribaltamento)* | si scrive il turno e i comandi stanno **fra parentesi quadre** (02-03/08) | **finestra guidata** e una sola chiamata `combat_azione`; **durante uno scontro le quadre sono testo libero** e il parser resta scorciatoia dello staff | decisioni 73-74 · `claude/turno_scritto_interfaccia.md` |
| **Dove sta il pannello dello scontro** | **fuori dalla colonna destra**, che si sfasava (03/08) | **resta nella colonna**: con l'altezza fissata a 240 px in ogni fase non dà più fastidio | decisione 78 · `04_LAVORI_APERTI.md` §1bis prima del 05/08 |
| **Chi può entrare in uno scontro** | «si apre e chi vuole entra», anche a spettatore | **duello 1v1**: a scontro cominciato **non entra più nessuno**, nemmeno come partecipante | le chiuse del 02/08 sera · `combat_join` prima del 05/08 |
| **Come si chiude la deroga della Test Room** | passando `p_location` a `my_abilities` e `my_defenses` | **marcando lo stato**: le righe della deroga escono come `state = 'catalogo'`, non come `'attiva'` | `04_LAVORI_APERTI.md` §1ter prima del 05/08 |

---

## 2. Le decisioni mai contraddette

I **quattro pilastri**: si gioca prima di tutto; sistema ibrido libero/masterato; conseguenze reali con morte permanente; mondo alternativo vivo.

Il **cast è interamente originale**: nessun personaggio canonico esiste nel presente. La divergenza è la **Notte della Volpe**, dodici anni fa.

**I jutsu si imparano giocando**, mai comprati con XP soltanto. **«L'IA racconta, il server comanda»**: nessun valore di gioco è deciso dal client o dall'IA.

**Il Ryo è l'unica valuta.** **Un account = un personaggio.** **Clan, ruolo di clan e corporazione li assegna solo lo staff.**

**Tutti i valori visibili in scheda o in una tecnica sono multipli di 5.** **Il deploy è manuale**, sempre.

**I numeri di scheda sono privati e non si rivelano mai**, né in chat né nella voce narrante. *(Ribadito il 02/08 notte.)*

**Le scale numeriche si prendono sempre dal regolamento**, mai inventate per comodità di esempio. *(Ribadito il 02/08 notte.)*

**Claude non crea né riproduce simboli o immagini protette.** Il dominio non contiene mai «naruto».

**Il regolamento non si piega al catalogo.** Se una riga a database contraddice `REGOLE.md`, si corregge la riga.

---

## 3. Cronologia, giorno per giorno

### 07/07 — fondazione
Nascono `PROGETTO.md` e `PROGETTO_v0.2.md`: quattro pilastri, cast originale, clan originali di Suna, sistema «Eredità». **Supabase EU confermato, Vercel scartato.**

### 08/07 – 11/07 — le fondamenta e il mondo
Sorgente del lore e convenzione sul copyright. `locations` con coordinate percentuali, `post_message` come unica via di scrittura. **La chat OOC viene annullata** in favore di Discord.

### 12/07 – 14/07 — clan e accademia
**Pacchetto accademia** con «l'IA racconta, il server comanda». **L'Uchiha diventa chiuso ma giocabile**. L'**Innata diventa la nona caratteristica**.

### 15/07 – 17/07 — i numeri e la trama
Si chiudono i numeri del motore. Due contatori `xp_lifetime` e `exp`. Il Kazekage è **Rina, la Dama di Ferro**. Si scopre che **`promuovi` non gestisce Deshi→Genin**.

### 18/07 – 25/07 — sicurezza, corporazioni, esame dello stato
Audit: RLS su tutte le tabelle, superficie non autenticata da 79 a 8 funzioni. Il bug critico era il **combattimento che si fidava del danno deciso dal client**. **Doppia chiave grado + disciplina**.

### 27/07 — corpo medico e immagini
Tecniche mediche appese a **Mente**. Stile delle immagini: inchiostro e acquerello.

### 28/07 — la giornata più densa
Nove decisioni, fra cui: **niente promozioni automatiche a leggendaria**; le leggendarie sono **premi unici**; il **Cercoterio esclude il clan**; nascono le **due strade dei premi**; **il Deshi impara solo in accademia**. **Dodici migrazioni.**

### 29/07 — dossier, skill, Cercoteri in gioco
Nasce il **dossier** e nascono le **sei skill**. **Convenzione contro la proliferazione**: non si creano più file datati. La scala delle code diventa **relativa alla bestia**. **Prassi nuova: una cosa a database esiste solo se si vede dal pannello.** **Sei migrazioni.**

### 30/07 — elementi, premi in tabella, evocazioni, deploy
La **seconda natura esce dai premi**. Il **listino diventa una tabella**. Entrano le **41 righe delle evocazioni**. In serata **i tre file salgono su GitHub**, **l'arretrato delle immagini si chiude** (52 emblemi su 52).

### 31/07 — il collaudo, e il gioco viene giocato

La sessione più lunga del progetto, e la prima in cui **il gioco è stato usato invece che costruito**.

1. **Entrano le 41 tecniche generiche.** *(Changelog 36.)*
2. **L'Acqua di grado B resta l'onda che sposta.**
3. **Parata, Contrattacco e Scatto d'assalto sono azioni normali**, non reazioni.
4. **Il Colpo caricato resta**, primo e unico taijutsu che consuma chakra.
5. **Sette nomi allineati al canone**, fra cui *Muro di terra → Scudo di terra*.
6. **Il catalogo in scheda nasconde** le tecniche fuori portata invece di mostrarle spente.
7. **Le tre tecniche dell'Accademia costano 5 chakra**; **Occultamento e Liberazione dalle corde diventano abilità**. *(Changelog 37.)*
8. **Il minimo di 500 caratteri diventa una regola del server.** *(Changelog 38.)*
9. **La bacheca delle missioni mostra solo il proprio villaggio.**
10. **Le bacheche hanno i non letti**, contati solo sui thread nuovi.
11. **Su telefono la chat prende tutta l'altezza.**
12. **I dati di prova sono stati azzerati**; **Tamako cancellata**.

**Migrazioni:** 41 generiche · `post_message` · `bacheca_missioni` · `board_reads_non_letti` · aggiornamento di `jutsu` · pulizia dei dati di prova.

### 01/08 — apertura: interfacce rifatte e il Tavolo di Aiuto

13. **La sezione Jutsu e Abilità va a linguette per disciplina.**
14. **La riga chiusa mostra nome, grado e un solo numero.**
15. **Il dettaglio tiene tutti i campi, raggruppati in tre blocchi.**
16. **Le sotto-linguette per provenienza valgono in tutte le discipline.**
17. **Il quadrante dei Premi nasce chiuso**, dietro la linguetta «Compra un premio».
18. **Jutsu e Abilità diventano un pulsante solo** nel menù Mondo; il **Codice delle Tecniche prende sette linguette**.
19. **Cercoteri ed Evocazioni entrano nel Codice** anche se hanno un pannello dedicato.
20. **Il Tavolo di Aiuto pesca da una tabella**, non da un testo dentro la Edge Function.
21. **Tetto di 20 domande al giorno per giocatore**, staff escluso, azzerato a mezzanotte italiana.
22. **Il bot è un agente dell'Hub IA** (`ai_agents`, `kind='help'`).
23. **Il pannello dell'Aiuto è una sezione a sé in admin.**
24. **In admin entrano solo le voci e la prova.**
25. **Help è l'ultima voce del menù Mondo.**
26. **Frase promozionale per Gdr online:** 138 caratteri.
27. **L'icona 55×55 è il simbolo TUS esistente.**

**Migrazioni:** `help_land_schema` · `help_land_voci_1` e `help_land_voci_2_e_agente`. **Edge Function nuova:** `land_help_ai` v1.

### 02/08 — il primo giorno con i giocatori dentro

Gli account passano da 3 a **14** nell'arco della giornata, nasce **il primo compagno PNG** (*Chiki*), **la L1 viene portata a termine quattro volte**, e la giornata si divide in quattro: il pomeriggio sull'interfaccia, la sera la prima migrazione più il changelog 39, la notte **il primo difetto trovato da un giocatore vero mentre giocava**, e infine il motore.

28. **Il menù Mondo → Evocazioni diventa un pannello vero**, a quattro linguette.
29. **La taglia Leggendaria non ha abilità proprie: le usa tutte.**
30. **La sezione Abilità si naviga prima per famiglia, poi per taglia.**
31. **Nel Codice le voci multilivello diventano una sola**, con i livelli nel dettaglio.
32. **I contatori delle linguette contano le voci visibili**: totale 358 → **327**.
33. **La scala del Richiamo nel pannello Evocazioni passa da tabella a tag.**
34. **Il riquadro «Compagno PNG» esce da Accademia e diventa una linguetta a sé.**
35. **Chi ha il Contratto ma non ancora il Richiamo vede la linguetta**, con dentro la spiegazione.
36. **La linguetta si chiama «Compagno PNG».**
37. **L'elenco dei clan che concedono un PNG resta una costante in pagina** (`PNG_CLAN`).
38. **`esc()` diventa robusta ai numeri** su tutte le pagine. **L'apostrofo non si allinea.**
39. **Una chat per file** diventa una convenzione scritta (`05_CONVENZIONI.md` §14).
40. **Il testo della chat diventa più leggibile e il sensei si distingue**: riquadro dall'oro all'**azzurro**.

**Dalla seconda chat, in parallelo:**

41. **Il passaggio da Deshi a Genin concede tutte e otto le basi d'Accademia**, per qualunque strada. **Non revoca in retromarcia.** *(Migrazione `promozione_genin_concede_basi_accademia`.)*
42. **Le due voci orfane restano marcate «non ancora insegnata»** per i Deshi in corso.
43. **Le Basi d'Accademia escono dal catalogo e vanno in cima alla pagina Jutsu.**
44. **Per i Deshi il conteggio «Puoi imparare 0» sparisce** e al suo posto compare la spiegazione.
45. **I Premi speciali diventano una linguetta propria.**
46. **I ritratti mostrano la figura intera invece di ritagliarla.**
47. **Il regolamento registra la concessione: changelog 39.** Verificato sul sito live.
48. **I nomi della scala del Richiamo sono stati allineati al catalogo.**

**Dalla terza chat, in notte — il parlato incollato da un editor esterno:**

49. **La correzione delle virgolette curve va nel rendering, dentro `fmtBody`**, non sul campo di scrittura. Nuova `normVirg(s)`.
50. **L'apostrofo curvo `’` non si normalizza.**
51. **`« »` e `< >` restano intatte.**

**Dalla quinta chat, in parallelo — l'Accademia:**

> *(Numerazione fuori sequenza perché la chat è andata avanti da sola: le decisioni sono registrate nel **changelog 41**.)*
>
> **Chi arriva a lezione cominciata entra come allievo, con attestato, finché la lezione è al primo passo**; dal secondo in poi resta uditore come prima. **Ogni villaggio ha una seconda aula**, che compare da sola quando la prima è occupata e si nasconde quando non serve: due lezioni in contemporanea, chat separate e **maestri diversi**. **I sensei si estraggono solo da `ai_agents`**: il ripiego su `academy_sensei` è stato tolto da tutte e tre le funzioni.

### 02/08, sera — la Test Room, il catalogo, il motore

La quarta chat costruisce, nell'ordine: un posto dove provare, un catalogo che il server sappia leggere, e il motore.

**La Test Room:**

52. **Serve una stanza di prova, e i colpi lì dentro calcolano e raccontano ma non applicano niente.** Vita, chakra ed esperienza restano quelli che erano; il messaggio finisce con «prova: nessun valore è stato modificato». Scartato l'azzeramento a posteriori: sporcherebbe comunque i valori per il tempo in cui la scena resta scritta.
53. **Ci entra solo lo staff**, e non per gentilezza del pulsante: lo impone il server, in `enter_location` e in `combat_join`.
54. **I messaggi si cancellano da soli ogni ora**, più un pulsante «svuota la stanza». È una **deroga dichiarata alla regola «mai DELETE»**, circoscritta ai luoghi con `is_test = true`. Poi allargata agli scontri di prova.
55. **Nella stanza non si aprono role** e il mondo non registra chi entra o esce.
56. **PNG e oggetti restano sospesi** invece di essere finti: sei funzioni rifiutano con un messaggio esplicito. Meglio un rifiuto dichiarato di un buco silenzioso.

**Il catalogo:**

57. **`tipo_azione` non è utilizzabile dal server** — 74 valori di testo libero, 89 righe vuote — e viene affiancata da **`uso`**, elenco chiuso, più il flag **`difensiva`**.
58. **Le 89 righe senza classificazione si riempiono con una regola automatica, e si correggono dal pannello** riga per riga. Scartata la classificazione a mano una per una: due sessioni intere per un lavoro che il consumo già suggerisce.
59. **Il menù della difesa mostra solo le tecniche con `difensiva = true`**: una tecnica offensiva non compare nemmeno nell'elenco. Non si para con una Palla di Fuoco.
60. **La `gittata` mancante si deduce**, prima dalla vecchia colonna `portata`, poi dalla disciplina. Le passive e le tecniche fuori scontro restano senza gittata di proposito.

**Il motore:**

61. **Il turno è una coppia: A attacca e non si risolve, B difende, poi il motore risolve.** È la decisione che rende il modello adatto a una chat: nessuno tira al buio e nessuno aspetta l'altro online. Scartate la postura dichiarata in anticipo e la difesa calcolata dalle statistiche.
62. **Uno scontro si apre nel luogo e chi vuole entra**, come una role. Nessuno viene trascinato dentro da un attacco.
63. **Accendere un'arte innata costa l'azione principale del turno.**
64. **A scontro finito le innate si spengono tutte.**
65. **L'innata accesa in scena libera non vale nello scontro**: entrando, tutto si azzera.
66. **Le distanze sono reali, in metri**, e valgono anche per le gittate dei jutsu e per il movimento dalla Velocità. Scartato tenerle narrative.
67. **La distanza d'ingaggio la dichiara chi apre**, oppure la lascia **al fato** (1d20 → 0-50 metri a passi di 5). Non si può sapere a priori da quanto comincia un duello.
68. **Lo spostamento del difensore vale *dopo* la risoluzione** del colpo di A: arretrare non è una scappatoia, è una preparazione per il turno seguente.
69. **Gli elementi contano nel confronto, in bene e in male**: ±2 secondo il ciclo di §5.1, mai due volte, e chi ha due nature prende il confronto migliore per sé.
70. **Due ore senza mosse e lo scontro si conclude**, ma **la scena resta registrata e si riprende**: nasce lo **scongelamento**, per gli scontri e per le role chiuse.
71. **Akimichi e Inuzuka vanno a doppio binario.** Non sono innate da accendere ma **arti segrete**: l'**Arte dell'Espansione** degli Akimichi è la **condizione** per usare i jutsu di clan, e la **Simbiosi coi Ninken** degli Inuzuka vive nel **compagno PNG**, con un **malus se il cane non partecipa** alla tecnica. ⚠️ Nel messaggio originale i due nomi sono scambiati una volta: qui vale cane agli Inuzuka, espansione agli Akimichi. **Da confermare.**
72. **Il terzo personaggio in scena può dichiararsi partecipante**: resta nella turnazione e scrive, ma il motore non lo calcola.

### 02/08, notte — il motore giocato, il modello nuovo del turno, i punti caratteristica

La stessa chat, dopo che il motore è stato **provato a mano in gioco** invece che solo in SQL. La partita ha trovato **sei difetti** (§4, punti 86-95) e ha cambiato il disegno dell'interfaccia.

73. **Il turno si scrive, come sempre.** Non si combatte a pulsanti: si scrive l'azione, e dentro l'azione si mettono i comandi. Il pulsante «Combatti» com'è fatto oggi **non ha più senso** e sparisce.
74. **I comandi stanno tutti fra parentesi quadre**, con una sintassi uguale per tutti: `[bersaglio Aoi]` · `[sposta +10]` / `[sposta -10]` · `[schivata]` `[parata]` `[contrasto]` · `[guardia]` `[mira]` `[lancio]`. Una forma sola da imparare, e la stessa che si legge rileggendo la scena.
75. **Il motore lavora in silenzio e parla una volta sola, a fine round.** Oggi risolve la coppia e scrive subito: la chat si riempie di righe tecniche in mezzo alla scena.
76. **L'azione non viene validata finché le condizioni non sono soddisfatte.** Si scrive prima e si risolve dopo: il server non interrompe chi sta scrivendo per dirgli che è fuori gittata.
77. **In alto compare un avviso: «Round N · stai attaccando»** oppure «stai difendendo». È l'unica cosa che deve essere sempre visibile.
78. **Il pannello Innate / Abilità / Tecniche va sotto la casella di scrittura**, non nella colonna a destra: con tre giocatori e tre PNG quella colonna diventa illeggibile.
79. **La Sostituzione resta una tecnica**, non una reazione da menù: si richiama come le altre e tiene il suo **blocco di due turni**.
80. **Nasce una voce narrante.** Il motore calcola, l'IA racconta con enfasi epica — e **non rivela mai i numeri di scheda**, che restano privati. È «l'IA racconta, il server comanda» applicato al combattimento.
81. **I PNG hanno limiti di conoscenza.** Un PNG che combatte contro un Uchiha **non sa** di avere davanti un Uchiha finché non lo vede. Il campionario dei PNG è costruito prima, come i personaggi; quello che sanno dell'avversario è una cosa a parte.
82. **Il motore vale anche nelle missioni**, non solo nei duelli fra giocatori.
83. **Scartata la risoluzione simultanea.** È elegante ma non regge in chat: due giocatori raramente sono online insieme, e chi scrive per secondo saprebbe già cosa ha fatto il primo.

**I punti caratteristica:**

84. **I punti arrivano interi al passaggio di grado**, e la scala è **legata al tetto** invece che fissa: **60 · 90 · 120 · 150 · 170 · 200** cumulati da Deshi a Kage, cioè **+30** a ogni salto tranne il penultimo. Con quel pool si portano **due caratteristiche al tetto** e restano una ventina di punti da spargere.
85. **La terza specializzazione non è un diritto del grado: si compra.** Nasce il premio **Punti caratteristica**, **+15 per volta**, uno per gradino, a **costo crescente x·n con x = 200** — 200 · 400 · 600 · 800 · 1.000 XP — e **non alza mai il tetto**: dà varietà, non altezza. Scartato il pool più generoso: personaggi con tutto al massimo in tre gradi.
86. **Il pool si concede una volta sola per gradino.** Retrocedere e ripromuovere non lo raddoppia: lo impone la colonna `characters.pool_concesso`, che tiene il cumulato.

**Migrazioni del 02/08, sera e notte — trentadue in tutto.** Il motore: `motore_combattimento_fase1_tabelle_e_turno` · `…difesa_e_risoluzione` · `…innate_mantenimento_e_scongelamento` · `motore_elenchi_per_il_pannello` · `combat_muovi_verso_avversario` · `combat_distanza_ingaggio_conservata` · `combat_muovi_scrive_in_chat` · `combat_attacco_il_danno_non_lo_decide_il_client` · `combat_righe_in_ordine_clock_timestamp` · `my_innate_col_clan` · `staff_ripristina_pv_e_chakra`. I punti: `pool_al_passaggio_di_grado_e_premio_punti` · `character_perks_accetta_punti_caratteristica` · `guardia_punti_coerenza_col_flag` · `flag_punti_si_richiude_dopo_luso` · `pool_concesso_una_volta_sola`. Il parser: `parser_comandi_di_combattimento` · `parser_comandi_correzione_array` · `parser_comandi_avvisi_e_convenzioni`. E `help_kb_e_flash_allineati_al_changelog_42`.

**Job `pg_cron` nuovi:** `test-room-cleanup`, `combat-silenzio`.

**Pagine toccate nella giornata:** `land.html` (otto giri), `scheda.html` (quattro), `admin.html` (tre), `regole.html` e `REGOLE.md` (due).

**Fuori dal gioco:** verifica di proprietà del dominio per **Gdr online** completata — `ORZ304.html` nella root del sito. L'indirizzo va dato **senza `www`**.

### 03/08 — l'Accademia con l'IA, seguita mentre veniva giocata

Giornata su un fronte solo: i maestri. La **L2 «Uso dei sigilli» è stata seguita in diretta**, per la prima volta, mentre quindici allievi la giocavano davvero; poi si è tornati sulle lezioni del giorno prima a cercare gli stessi difetti. **Diciotto difetti catalogati, sedici chiusi.** Nessun valore di gioco è cambiato: sono cambiati il prompt dei maestri, i copioni e una riga di `land.html`.

87. **Il parlato dei maestri cambia ritmo.** Frasi spezzate in quattro parole per tutti facevano parlare Katsuo e Ibara allo stesso modo. Ora: **quando si spiega, una frase intera che scorre**; il periodo corto resta per l'ordine e per il rimprovero. Schietto vuol dire dire lo stretto necessario, non parlare a scatti.
88. **La bio è del maestro, non della classe.** Un sensei può raccontare qualcosa di sé **solo se ha senso nel contesto della lezione**, mai come presentazione.
89. **La scheda è un oggetto OFF, e un PNG non la nomina mai.** Vale per «scheda», «punti», «esperienza», «turno» e per tutto il resto dell'interfaccia: nasce un **glossario delle parole che non esistono nel mondo**.
90. **Il chakra si riconosce con la carta, non guardando l'interfaccia.** Cinque reazioni, e sono la risposta canonica: si inzuppa → Acqua · si taglia netta e **in silenzio**, bordi puliti → Vento · brucia e si consuma → Fuoco · si indurisce e si sbriciola → Terra · si spacca con uno **schiocco secco**, bordi anneriti → Fulmine. Se il foglio non fa niente, la natura non si è ancora decisa.
91. **La carta è una scena, non un oggetto.** Non entra a catalogo, non si compra, non fa niente al server: dice al personaggio quello che il giocatore sa già.
92. **Nasce il terzo canale: `(( … ))`.** Le istruzioni ai giocatori non stanno né nel descrittivo né nel parlato: vanno **in coda all'azione**, dentro doppie parentesi, dichiaratamente fuori dalla finzione.
93. **L3 si svolge all'aperto e si arrampica sull'albero del cortile** (a Suna la parete di roccia), **con un tiro di 1d100 a soglia 50**: cinquanta o meno il piede tiene, sopra si cade. È **puramente narrativo** — non cambia quello che si impara — e **la soglia è pubblica**, scritta nel copione, così il maestro non applica una regola nascosta.
94. **La Dispersione esce da L3** — dal copione e da `lesson_grants` — **e andrà nella lezione sui genjutsu.** Nessuno l'ha persa: l'unico che ce l'ha è Riuji, per promozione.
95. **L3 passa da cinque a sei passi**, per non comprimere in una sola scena la carta e la camminata.
96. **Il riepilogo finale è un messaggio di sistema** (`kind='sistema'`) **e dice perché un attestato manca**: raffreddamento, prerequisito, oppure lezione già fatta.
97. **Il raffreddamento si impone all'apertura**, non a lezione finita. Chi è in raffreddamento non viene respinto: **entra come uditore**.
98. **La forzatura salta il silenzio di due minuti.** Se lo staff forza il passo, il tick non aspetta.
99. **I 15 punti caratteristica di troppo all'esame non si danno più.** Li concedeva già il trigger del passaggio di grado: erano un regalo doppio.

**Migrazioni:** `accademia_ia_2026-08-03` (contesto IA, riepilogo di sistema, raffreddamento all'apertura, forzatura, esame senza punti extra) · rimozione della Dispersione da `lesson_grants` di L3 · riparazione di Tamako · riaccentatura di `help_kb`.
**Edge Function:** `academy_sensei_ai` **da v8 a v15**.
**Pagine:** `land.html`, **una riga sola** in `fmtBody`.

### 03/08, mattina — il motore entra in chat *(registrato in ritardo)*

> Queste decisioni sono del **mattino del 03/08**, prima della giornata sull'Accademia: sono state versate qui il **05/08** e per questo portano numeri più alti di quelle del pomeriggio. **La numerazione segue l'ordine di registrazione, non quello dell'orologio.**

100. **Il parser si aggancia a `post_message`.** La decisione del 02/08 notte (punto 97 di §4) diceva di lasciarlo scollegato finché il modello nuovo non fosse pronto: il 03/08 mattina il modello c'era, e la porta si è aperta. **Da quel momento il turno si gioca scrivendolo.**
101. **Tre marker, e non di più.** Le righe che il motore scrive in chat si distinguono per genere, non per colore inventato caso per caso.
102. **Il genjutsu non toglie punti vita.** Confronto Mente + Genjutsu contro Mente + Genjutsu, e l'effetto è altrove: un'illusione non sanguina.
103. **Gli elementi non entrano nei colpi fisici.** Il ±2 del cerchio elementale vale fra tecniche, non su un pugno.
104. **Nella stanza di prova si prova tutto il catalogo.** Senza la deroga la stanza non serve, perché `character_abilities` è a zero: è circoscritta ai luoghi `is_test` e allo staff.
105. **Nasce `mock`, il personaggio di prova**, con `characters.is_test = true`. Serve un bersaglio che non sia una persona vera.
106. **`[bersaglio]` è facoltativo quando l'avversario è uno solo**, e **fra le azioni rapide resta soltanto `[guardia]`**, che **vale fino al proprio turno successivo** — non fino alla fine del round.
107. **`[Fine]` resta visibile e non diventa un comando.** Due giocatori la usavano già come convenzione loro: il motore la ignora e la lascia scritta in scena. Vale lo stesso per `[ooc]`, `[off]` e `[figura:…]`.
108. **Quattro cose da costruire sull'interfaccia del turno scritto** (`claude/turno_scritto_interfaccia.md` §1-2): i **comandi nascosti in chat** a chi non è staff · un **contatore delle azioni** spese · la **fascia di stato** «ROUND N · ATTACCA» sempre visibile · le **tecniche chiamate per nome** dentro le quadre. ⚠️ **Superate il 04-05/08:** la finestra guidata le rende inutili tre volte su quattro, e la fascia è finita dentro la card dello scontro.
109. **La fase 2 — gli effetti delle tecniche — è il prossimo passo fondamentale.** Confermata come priorità sopra ogni rifinitura. *(Al 05/08 `combat_effects` è ancora vuota.)*

**Migrazioni della mattina:** `parser_comandi_in_post_message_e_marker_genjutsu` · `normalizza_comandi_incollati_da_fuori` · `test_room_catalogo_libero` · `personaggio_di_prova_entra_in_test_room` · `test_room_senza_minimo_caratteri` · `guardia_vale_fino_al_turno_successivo` · `parata_diventa_contromossa` · `contromossa_in_revisione`.

### 04-05/08 — il gate del motore scontri v1

Due giorni su un fronte solo, dal contratto a database fino al regolamento. **Sedici migrazioni `combat_v1_*`**, l'interfaccia guidata costruita e verificata dal vivo, le porte legacy revocate, due righe di changelog. Il metodo è stato lo stesso di sempre: **provare giocando**, e ogni prova ha trovato qualcosa che l'SQL non vedeva.

110. **Il duello è 1v1, e a scontro cominciato non entra più nessuno** — nemmeno come partecipante che assiste. Si entra solo prima del primo colpo, e chi arriva tardi riceve un rifiuto esplicito.
111. **Quando ti difendi rispondi e basta:** niente movimento, niente azioni rapide. **L'unica rapida in vigore è la guardia.**
112. **La Contromossa non è in vigore nella v1.** Il nome resta a catalogo, la meccanica si decide dopo.
113. **L'azione vive nel browser finché non si invia, e parte insieme al testo.** Una sola chiamata: se il server rifiuta l'azione, **il messaggio non viene nemmeno scritto**. Niente più mezze mosse a metà fra pagina e database.
114. **Le arti innate contano come azione principale d'attacco**, non come gesto gratuito da aggiungere a un colpo.
115. **Durante uno scontro le parentesi quadre sono testo libero.** Il parser resta vivo in un posto solo: la **scorciatoia manuale dello staff nella stanza di prova**, dove serve armare le prove in fretta.
116. **A database restano due sole porte:** `combat_azione` per l'interfaccia guidata e `post_message` per le scene libere. **Le quattro chiamate dirette del vecchio pannello sono revocate** ad anon e authenticated — insieme ai tre helper interni e all'azzeratore della stanza di prova.
117. **Gli scenari a dadi fissi valgono per un solo scambio**, e armarne uno **azzera la prova precedente**: una prova nuova richiede una selezione nuova.
118. **L'armamento di una prova spegne le arti innate**, così ogni scenario parte da uno stato neutro.
119. **Il KO nella stanza di prova resta osservabile:** referto e riga in chat, ma la prova **non si chiude da sola**. Si guarda com'è finita.
120. **`my_abilities` marca la deroga come `catalogo`, non come posseduto.** Chi filtra `attiva` — il suggeritore, la calcolatrice, la Regia — vede esattamente ciò che il server accetta; il **Codice delle Tecniche**, che non filtra, continua a mostrare tutto.
121. **Le riduzioni per reazione sono tre, non due:** **÷10** per chi para, **÷20** contro il fisico, **÷40** contro ninjutsu e genjutsu. Il motore si comportava già così; il regolamento non lo diceva.
122. **Il tetto di 65 danni per colpo si impone.** Era promesso dal Tavolo di Aiuto dal primo giorno e nessuna riga lo applicava. *(Chiude la domanda aperta dal 31/07.)*
123. **Il ritratto della Scheda diventa il riferimento unico per la chat:** formato **3:4**, `cover` e inquadratura centrale. Non si ricampiona né si duplica alcuna immagine: Scheda e chat leggono già lo stesso `characters.avatar_url`; si allinea solo la cornice CSS. Scartato il ritaglio IA, inaffidabile sulle illustrazioni e non necessario.

**Le sedici migrazioni:** `combat_v1_blocco1_contratti_rls_referto` · `…blocco1_rifiniture_sicurezza` · `…ui_passo1_contratti` · `…ui_passo1_stato_non_anonimo` · `…ui_correzioni_pm` · `…ui_prefisso_luogo_non_e_un_comando` · `…colpo_avanza_il_motore` · `…trigger_fuori_dal_corpo` · `…trigger_per_posizione` · `…trigger_tecnica_per_nome` · `…join_rifiuta_ingressi_a_duello_avviato` · `…test_room_ciclo_prova` · `…prova_neutra_e_helper_interni` · `…ui_contratti_guidata` · `…my_abilities_stato_onesto` · `…cutover_revoca_rpc_legacy`.

**Pagine:** `land.html`, **26 modifiche verificate** (463.899 byte, md5 `0ac5fa610c57e158cee46dedc6acb71f`) più il ritratto 3:4 (463.795 byte, da caricare). **Regolamento:** `REGOLE.md` e `regole.html`, changelog **43** e **44**. **Nessuna Edge Function toccata.**

### 06/08, sera e notte — l'Accademia riletta mentre i giocatori la giocavano

La sessione è nata da una domanda («mandami l'analisi delle lezioni degli ultimi tre giorni») e si è trasformata in tre rilasci del prompt del sensei, uno per ogni errore trovato leggendo quello che il maestro aveva **davvero** scritto agli allievi. Nessuna regola di gioco è cambiata: `REGOLE.md` e `regole.html` non sono stati toccati, e non c'è niente da caricare su GitHub.

124. **Il congedo è sempre rivolto alla classe, mai a un singolo allievo** — anche quando in aula ha scritto una persona sola. Con un allievo solo cadono anche gli appellativi plurali: si chiama per nome.
125. **La L2 «Il chakra» passa da sei a sette passi.** I dodici sigilli non si dimostrano più per poi congedare nella stessa riga: il passo 6 ordina di **comporli in scena** con una nota fuori scena, il passo 7 osserva, corregge e chiude. Scartata l'alternativa di lasciarli come compito a casa: era il copione a spegnere l'esercizio, non il modello.
126. **Il ciclo degli elementi diventa un dato del prompt**, non solo del copione: Fuoco>Vento>Fulmine>Terra>Acqua>Fuoco, cinque coppie esatte da riportare intere anche nei riepiloghi liberi. Dove il copione lo dettava per esteso il maestro non sbagliava; dove riassumeva a parole sue, sì.
127. **Nel mondo ninja non si spiega niente con la fisica del mondo reale.** Niente conduzione, messa a terra, scariche: la Terra non «scarica» il Fulmine. L'immagine ammessa è quella del copione, «il Fulmine solca la Terra», e ci si ferma lì.
128. **Un dato che il maestro non deve dire non gli si consegna.** L'elemento degli allievi entra nel contesto **solo** quando il materiale del passo mette in scena la carta da chakra. È il rovesciamento del metodo seguito fino a ieri — vietare nel prompt — dopo che tre divieti scritti non avevano impedito «Tu hai il Fuoco».
129. **Il maestro non ipotizza la natura di nessuno**, né dal clan né dal nome né dai ragionamenti dell'allievo: senza la carta non la conosce nemmeno lui.

**Versioni:** `academy_sensei_ai` da **16.2** a **17.0**, **18.0** e **19.0** in una sera (`PROMPT_VERSION` 19; Supabase versione 20). **Copione:** `migration_L2_sette_passi.sql`, due `UPDATE` e due `INSERT` su `academy_lesson_script`, con rollback gemello. **Nessuna firma di funzione cambiata, nessuna pagina toccata.**

### Del 06/08, sera — la catena dell'audit *(registrata il 07/08, a cose fatte)*

Quattro mandati in fila — ACC-AUDIT-009, 010, 011, 012 — nati uno dall'altro: ogni correzione ha reso visibile il difetto successivo, che prima era coperto da quello di prima. Le prime tre sono **applicate**; la quarta è **pronta e non applicata**.

130. **Il `session_id` non si chiede al modello: lo impone la Edge.** Sei findings su sei erano stati buttati via per un errore di trascrizione su un dato che il server conosceva con certezza. La regola che ne esce vale oltre l'audit: *non domandare al modello ciò che il server sa già*.
131. **`academy_audit_salva` accetta un'evidence se e solo se compare nel corpus che `academy_audit_corpus` ha consegnato al modello.** Né più — accetterebbe citazioni di testo mai letto — né meno, che è il difetto trovato: la finestra vecchia tagliava via il passo finale, nato dopo `closed_at` per il solito `clock_timestamp()` contro `now()`. ACC-AUDIT-006 era corretto a metà: avevo allineato ciò che il modello legge, non ciò che valida il ritorno.
132. **Ogni scarto del salvataggio dice perché**, con `raise warning`: motivo, audit, sessione e passo, mai il testo di gioco. Prima il ramo di scarto faceva `continue` in silenzio, e un finding buttato via non lasciava traccia da nessuna parte.
133. **La ricerca dell'evidence filtra `kind` e `recipient_user`.** Prima accettava come prova un tiro di dado, un riepilogo di sistema o un sussurro privato: righe che il corpus non ha mai mostrato al modello. Stretta oltre il difetto segnalato, dichiarata e approvata.
134. **Verifica, poi deriva.** Il `source_turn_id` dichiarato dal modello vale solo se il messaggio di quel turno contiene l'evidence alla lettera; altrimenti il server deriva il turno dal contenimento letterale, e la dichiarazione serve al massimo da spareggio fra candidati già verificati. Scartata l'alternativa «deriva sempre»: la nota fuori scena `(( … ))` è ricopiata per contratto e compare identica in più turni, quindi la derivazione pura non è univoca e renderebbe `fuori_scena` l'unica categoria mai segnalabile.
135. **Un finding v1 cita solo il maestro.** Le righe `say` degli allievi sono contesto, non prove. Conseguenza accettata: la role avvelenata di un giocatore non è più citabile — e non deve esserlo, perché il tentativo dell'allievo non è un difetto del *maestro*. Lo diventa se il maestro obbedisce, e allora la prova sta nella sua risposta.
136. **Il fingerprint si ramifica per famiglia.** Difetti del materiale (`copione`, `coerenza_materiale`, `canone_e_segreti`) → `categoria|villaggio|lezione|passo`. Difetti di scrittura (`formato_role`, `grammatica`, `fuori_scena`, `chiusura_prematura`) → sola categoria, perché la stessa sbavatura in L1, L2 e L3 è **un** problema del prompt. Misurato prima di scegliere: la regola vecchia dava 16 identità su 16 hit, cioè zero ricorrenze; questa ne dà 11, e tutti gli accorpamenti sono difetti realmente ripetuti.
137. **Su conflitto vince la severità peggiore vista finora.** Sbagliare per eccesso fa guardare una cosa non grave; sbagliare per difetto fa non guardare una cosa che lo era.
138. **I testi restano al primo scrittore sul finding, e ogni occorrenza tiene i suoi sul hit.** Tre colonne nuove — `expected`, `proposed_fix`, `regression_case` — nullable, riempite dal backfill copiando i testi *prima* della fusione: è l'unico istante in cui quell'informazione esiste ancora.
139. **La ricorrenza è `count(distinct audit_id)`**, e per questo l'indice unico dei hit deve includere `audit_id`. Senza, tutte le segnalazioni ripetute cadono sullo stesso turno e vengono scartate: avremmo corretto il fingerprint per scoprire le ricorrenze e cancellate un istante dopo. Due formulazioni dentro lo stesso audit e sullo stesso turno restano **una** occorrenza.
140. **La sequenza cambia:** ACC-AUDIT-012 → `ADMIN-AUDIT-001` → cron. Il pannello non si scrive prima che il fingerprint sia deterministico, e il cron non si programma prima del pannello. Motivo: senza soglia utilizzabile il pannello mostrerebbe un «quante volte» che non vuol dire niente.
141. **Il pannello dell'audit tratta quattro stati, non due:** `aperto → approvato → verificato`, oppure `aperto → respinto`. `approvato` vuol dire «lo accolgo», `verificato` vuol dire «il rimedio è nel prompt comune e regge». Fermarsi ad `approvato` farebbe di quello stato un cimitero.

**Versioni:** `academy_audit_ai` da **1.2** a **1.3** (Supabase versione 4). **Migrazioni applicate:** ACC-010 e ACC-011 su `academy_audit_salva`, più il backfill di 5 hit. **Pronta e non applicata:** ACC-012. **Nessuna pagina toccata, nessuna regola di gioco cambiata.**

---

### 07-08/08, notte — il recupero della password, e il ruolo che non esisteva nei documenti

Due filoni distinti in una sera. Il primo è un percorso d'accesso rotto trovato mentre due giocatori ci sbattevano davvero contro; il secondo è un buco di coordinamento emerso di conseguenza.

210. **Il link di recupero atterra su `entra.html`, non sulla home.** `resetPasswordForEmail` passava `redirectTo: window.location.origin`, quindi la mail portava alla radice del dominio, dove non esisteva nulla per reimpostare. Scartata l'alternativa di gestire l'evento sulla home: avrebbe aggiunto un secondo monolite al perimetro e un secondo owner. Un file, un owner.
211. **Il modulo di richiesta non si ricostruisce: esisteva già.** Il referto d'origine diceva «assenza del modulo»; la verifica sul sito ha mostrato che «Password dimenticata?», il campo email e il pulsante d'invio erano in linea e funzionanti. Mancava la **seconda metà** — nessun `PASSWORD_RECOVERY`, nessun `updateUser`. Correggere la parola ha evitato di far riscrivere un pannello vivo.
212. **Dopo il cambio password si chiudono tutte le altre sessioni tranne quella corrente.** Un accesso rubato non deve sopravvivere al cambio password. Costo accettato e scritto in pagina: chi ha «Ricordami» attivo altrove viene disconnesso. Limite noto e non rimediabile lato client: gli access token già emessi restano validi fino a scadenza, perché `scope:'others'` revoca i refresh token, non i JWT vivi.
213. **La regola della password si riusa, non si riscrive.** Vale la sola `passwordError()`, accoppiata alla policy Supabase — minimo 10 caratteri, maiuscola, minuscola, numero, speciale — invocata prima di qualunque scrittura. Due regex che divergono nel tempo sono il modo più facile di rompere questo percorso.
214. **`scheda.html` ha finalmente un owner: SCHEDA-UI**, con **due** revisori su dimensioni distinte — DB-CORE per contratto e sicurezza, QA-PLAYTEST per il flusso visibile. Il ruolo esisteva in `AGENTS.md` ma non nel workflow, che non nominava nemmeno il file.
215. **La regola «un owner, un reviewer al massimo» non è stata riscritta, ma affiancata da un'eccezione dichiarata.** Due revisori che guardano cose diverse non sono responsabilità diffusa; riscrivere la regola generale per un caso l'avrebbe indebolita per tutti. L'eccezione è scritta sotto la tabella, dove si vede.
216. **SCHEDA-UI entra fra i consumatori dei contratti RPC in §5 del workflow.** Non era nell'elenco pur essendo `scheda.html` il maggior consumatore di RPC del progetto: senza quella riga, un cambio di contratto di DB-CORE non avvisa l'owner del file — esattamente il guasto che il registro esiste per evitare.
217. **PM-ORCHESTRATORE resta di proposito senza scheda nei template.** Scrive i briefing, non li riceve. Tutti e dieci gli altri ruoli operativi ora ne hanno una.

**Come si è chiuso.** Il difetto è stato riprodotto da un giocatore vero fra le 23:37 e le 23:43 del 07/08 — token valido, `login` riuscito su `/verify`, poi tre `403 One-time token not found` perché ricliccava un link ormai consumato non trovando dove scrivere; stessa sequenza alle 19:53 su un secondo account. Caricato `entra.html`, la reimpostazione è riuscita alle **23:54:57**, verificata a database. Final Result e nota pubblica in `management/coordination/FINAL_RESULT_ACCOUNT-PRIVACY-PASSWORD-001.md`.

### 10/08 — il pannello delle segnalazioni, e il contratto dell'annullamento

Una giornata di sola progettazione: una pagina candidata scritta e congelata, e un contratto DB
portato a chiusura in quattro giri di decisioni del PM. **Niente è stato applicato e niente è stato
pubblicato.**

220. **`TRAINING-V2-ADMIN-006` si chiude alla R0, e `admin.html` resta congelato.** La sottosezione
     «Sessioni segnalate» è scritta, provata e **non pubblicata**: 282.938 byte, sha256 `6ab3360e…`,
     banco `claude/banco_training_segnalate_006.mjs` con **220 controlli verdi e 5 prove
     d'inversione**. ⛔ **Caricarla su GitHub prima di Training V2 Core è vietato**: le RPC non
     esistono ancora e lo staff vedrebbe un errore a ogni apertura. **È conclusa la progettazione,
     non il flusso pubblico.**
221. **La coda vive dentro la pagina «Allenamenti», non in una ventunesima voce di menù.** Il
     pannello di `all_pending_trainings` resta intatto riga per riga — verificato per impronta dal
     banco, non dichiarato — e la novità gli sta sotto come sottosezione.
222. **Un'azione distruttiva dello staff si conferma dentro la riga, non con `confirm()` né col
     pulsante armato.** Scartate entrambe le forme già presenti in pagina: la finestra modale non può
     contenere il motivo e rende ambiguo il doppio clic; il pulsante armato con timeout trasforma un
     doppio clic veloce in una conferma involontaria. La striscia in riga tiene insieme motivo e
     conferma, ed è innocua per costruzione.
223. **L'annullamento ha due ambiti, non un booleano.** `training_annulla(p_session, p_motivo,
     p_ambito default 'registrazione', p_impronta)`. Scartato `p_anche_compagno boolean` perché
     **ambiguo quando la riga del compagno non esiste ancora**: un booleano che dice «anche il
     compagno» non ha risposta se il compagno non ha registrato. `p_ambito` nomina l'insieme, non il
     secondo elemento. **Il default è quello prudente.**
224. **Con ambito `scena` si annullano anche le dichiarazioni non ancora registrate**, mostrate
     separatamente nell'anteprima e contate a parte nella risposta. Senza, il vincolo «una scena
     annullata non si registra dopo» si aggira in un secondo: A registra, lo staff annulla, B
     registra dalla dichiarazione rimasta aperta.
225. **L'elenco di chi verrà coinvolto si legge dal server, non si compone in pagina.** La coda mostra
     solo le righe `sospetta`, mentre `scena` colpisce anche registrazioni mai segnalate: un elenco
     composto dal client sarebbe incompleto **proprio nel momento della conferma**. Nasce
     `training_annulla_anteprima`, e la conferma resta disabilitata finché non risponde.
226. **L'anteprima restituisce un'impronta, e `training_annulla` la rifiuta se l'insieme è cambiato.**
     Impronta **per ambito** — sull'insieme che verrà annullato, non sull'intera scena — composta da
     **identificativo e stato**, ordinata **per id**. Gli stati servono per il caso insidioso: una
     riga già in elenco come dichiarazione che nel frattempo diventa registrazione, dove l'insieme
     degli id non cambia di una virgola. L'ordinamento per `id` e non per `created_at` evita che
     l'impronta cambi da sola.
227. **Il conflitto torna come dato, con l'anteprima aggiornata dentro la risposta.** Non come
     `raise exception`: la pagina non lo distinguerebbe da un guasto, e resterebbe per un istante con
     l'elenco vecchio sotto un messaggio che dice che è cambiato.
228. **`pg_advisory_xact_lock` sulla scena è obbligatorio in `training_annulla` e in
     `training_role_registra`.** L'impronta chiude la finestra fra anteprima e conferma, che dura
     secondi; resta quella fra la verifica e la scrittura — la stessa corsa già trovata in
     `training_confirm` (DISCOVERY §2.3). Un `for update` non basta: **un lock su righe non impedisce
     un `insert`**. ⚠️ La chiave dev'essere identica alla lettera nelle due funzioni, quindi va
     incapsulata in un helper: due `hashtext` diversi non si vedono e la protezione sparisce **senza
     che niente lo segnali**.
229. **Lo storico mostra tutte le annullate, non solo quelle che erano `sospetta`**, con l'avanzamento
     **congelato al momento dell'annullamento** (`sessions_done_dopo`, `sessions_required_dopo`) e un
     identificativo comune dell'operazione. `character_abilities.sessions_done` viene sovrascritto a
     ogni operazione: senza congelarlo, due annullamenti sulla stessa tecnica e il primo record non sa
     più dire il proprio valore. `sessions_required_dopo` serve perché `trainings_required` si cambia
     dal pannello Tecniche.
230. **Il lavoro DB si sposta su M1, M3 e M5, e diventa `TRAINING-V2-ANNULLAMENTO-007`.** Il lock in
     `training_role_registra` e il controllo «role bruciata» in `training_role_dichiara` entrano in
     **M3**, che il candidato dichiara ancora indipendente da M5 (`00_LEGGIMI` §10): non lo è più.
     **Le 34 prove esistenti vanno rieseguite, non solo integrate**, e `SHA1SUMS` rigenerato. Il Core
     non è applicato, quindi si aggiornano i file **in loco** invece di scrivere una migrazione
     incrementale.
231. **Il rollback ripristina ciò che esisteva davvero, non ciò che si ricorda.** `create or replace`
     con tre parametri **non sostituisce** la funzione a due: nasce un overload e la chiamata attuale
     diventa ambigua (42725). Serve un `drop` esplicito, che porta via i `GRANT`. Ma oggi
     `training_annulla(uuid, text)` a produzione **non esiste**: il rollback la droppa e non la
     ricrea, perché ricreare una firma mai esistita sarebbe inventarsi uno stato. Si fotografa con
     `pg_get_functiondef` **prima** di applicare — la prassi che `00_LEGGIMI` §10 già impone per
     `training_confirm` — e si ripristina solo ciò che c'era.

## 4. Le correzioni prese d'iniziativa — da controllare

Antonello ha chiesto che ogni correzione presa d'iniziativa venga elencata perché possa verificarla, **in entrambe le direzioni**: un vincolo aggiunto, ma anche uno allentato.

### Del 28/07 — tutte reversibili

1. Il malus di cecità del Mangekyō non aveva una meccanica. 2. Il Susanoo Perfetto pretende il Susanoo. 3. Kamui e Fiamme Nere portate a Kekkei Genkai 80. 4. Sharingan Eterno solo a un Uchiha. 5. Dispersione d'ufficio a chi aveva superato L3. 6. Dispersione acquistabile disattivata, non cancellata. 7. `tecnica_leggendaria_assegna` sarebbe esplosa al primo uso.

### Del 29/07

8. `characters_guard` lascia crescere la Sintonia senza clan. 9. `characters_guard` pinna `cercoterio` e `sigillo`. 10. Trigger `trg_characters_cercoterio`. 11. `req_cercoterio` da testo a vincolo. 12. `req_perk = 'jinchuriki'` su otto righe. 13. La Sintonia scritta a database. 14. `clan_join_open` rifiuta con un messaggio leggibile. 15. **⚠️ Vincolo ALLENTATO — ancora da decidere:** in modo `uno` la richiesta di elemento si accontenta anche della seconda natura. 16. Soglia di lucidità dalla prima coda della propria bestia. 17. **Errore mio, sanato:** una prova senza `rollback` aveva lasciato un premio finto su Haru.

### Del 30/07

18. **⚠️ Permesso revocato ad `anon`** su `character_elementi`. 19. Difetto chiuso in `scheda.html`. 20. `giocatore` e `ripetibile` diventano colonne. 21. Il costo dell'evocazione a 300 XP per Medici e ANBU resta cablato. 22. Difetto chiuso in `companion_create`. 23. Difetto chiuso nel catalogo. 24. La scala del Richiamo è `is_innata`. 25. La X del calendario copriva il +. 26. **⚠️ Segnalazione:** due emblemi medici nominati e assenti.

### Del 31/07

27. **⚠️ Il catalogo in scheda applica la soglia di disciplina e il rango minimo.** 28. **⚠️ Il filtro degli elementi usa `character_elementi()`.** 29. **`req_stat2` controllato anche dal client.** 30. **`req_stat` azzerato sulle 41 generiche.** 31. **Categoria di Occultamento e Liberazione allineata ad «Abilità».** 32. **⚠️ Il tag del luogo `【…】` non conta nei 500 caratteri lato client.** 33. **Lo staff è esente dal minimo dei 500** e **vede tutte le missioni**. 34. **Le risposte dentro un thread non riaccendono il badge.** 35. **L'immagine del luogo è sparita solo da mobile.** 36. **⚠️ Cancellando i tre addestramenti di prova di Tamako, i 20 XP spesi non sono tornati indietro.** 37. **Due falsi allarmi miei, chiusi.**

### Del 31/07 — trovate e **non** toccate

38. **Il tetto di 65 danni per azione non è imposto da nessuna parte.** → **riaperta il 02/08:** il Tavolo di Aiuto lo racconta ai giocatori come se ci fosse.
39. **La giornata di gioco cambia alle 02:00, non a mezzanotte.**
40. **Anche lo staff prende l'XP di gioco** se partecipa a una scena.
41. **Chi fa l'Accademia per intero impara sei voci su otto.** → **risolto il 02/08 dalla decisione 41.**

### Del 01/08

42. **⚠️ `req_stat2` scritto nei Requisiti della scheda.** 43. **⚠️ `req_elements_mode='tutti'` dice «servono tutti».** 44. **La categoria è passata dalla riga chiusa al dettaglio.** 45. **⚠️ Guardia nel Codice.** 46. **Aprendo il quadrante dei Premi la pagina ci scorre sopra.** 47. **⚠️ Il contatore del Tavolo di Aiuto si azzera a mezzanotte italiana.** 48. **⚠️ Vincoli aggiunti sul Tavolo di Aiuto.** 49. **⚠️ Segnalazione — doppia fonte sui Cercoteri.** 50. **Le 39 voci di `help_kb` sono senza accenti.** 51. **Le versioni della frase promozionale da 149 e 150 caratteri scartate da me.**

### Del 02/08

52. **⚠️ `loadEmblems()` non caricava `evofam`.** 53. **⚠️ Segnalazione — `REGOLE.md` §6.4 nominava righe del Richiamo inesistenti** → chiusa. 54. **⚠️ Segnalazione — la skill `gdr-contesto` dice «Lumache (solo medici)»: è falso.** 55. **La chiave di raggruppamento del Codice include `req_cercoterio`, `req_famiglia` e `category`.** 56. **Errore mio, arrivato in produzione e sanato:** `esc(o.sort)` passava un numero. 57. **⚠️ Segnalazione — `esc()` disallineata sull'apostrofo, NON corretta.** 58. **⚠️ Segnalazione — `updatePngUI` si rompe con un compagno senza `kind`.** 59. **⚠️ Errore mio nel metodo di verifica, corretto in corsa.** 60. **Il menù «Tipo» del compagno offre solo i tipi consentiti.** 61. **La linguetta Compagno resta visibile a chi ha già un compagno.** 62. **⚠️ La copia locale di `land.html` era indietro di cinque righe rispetto a GitHub.**

### Del 02/08, sera — seconda chat

63. **⚠️ Vincolo aggiunto: il trigger `trg_characters_grant_academy`.** 64. **⚠️ Il trigger non revoca in retromarcia**, di proposito. 65. **⚠️ Segnalazione — la regola non era ancora nel regolamento** → chiusa dal changelog 39. 66. **Il pannello admin non avvisa che promuovendo si concedono le otto basi.** Non fatta. 67. **Falso allarme mio, ritirato:** il doppio gestore sul pulsante «Invia allo staff» non esiste. 68. **⚠️ Collisione fra le due chat su `scheda.html`, sanata.**

### Del 02/08, notte — terza chat

69. **Legenda «Come si scrive» aggiornata di mia iniziativa.** 70. **⚠️ Segnalazione — nel database il `body` conserva le virgolette curve.** 71. **⚠️ Segnalazione — `fmtBody` non è coperta da `banco_prova_land.js`.** 72. **⚠️ Segnalazione — i sensei hanno due fonti.** 73. **⚠️ Errore mio nel dossier, corretto:** fra due documenti del dossier che si contraddicono, decide la **fonte viva**, non il più recente.

### Del 02/08, sera — quarta chat, la Test Room e il catalogo

74. **⚠️ Deroga dichiarata: la Test Room cancella messaggi e scontri con `DELETE`.** È l'unica cosa che fa, ed è circoscritta ai luoghi con `is_test = true`. Approvata prima di scriverla, poi **allargata** agli scontri: l'allargamento è stato dichiarato.
75. **⚠️ Vincolo allentato: nella Test Room lo staff accende un'arte innata che non possiede.** Senza, la stanza non serve a provare il mantenimento, perché `character_abilities` è a zero. Vale **solo** nei luoghi di prova.
76. **⚠️ Vincolo aggiunto: un solo scontro aperto per luogo** (indice unico parziale). Due risse contemporanee nello stesso posto sono illeggibili in chat. Si toglie con una riga.
77. **⚠️ Censimento e chiusura di sei porte sul mondo.** Cercando cosa toccasse `p_location`, ho trovato che **`post_message` scalava il chakra** anche nella stanza di prova e che **`post_item_use` consumava l'oggetto vero**. Chiuse entrambe, la seconda con un rifiuto invece che con una finzione.
78. **⚠️ Vincolo aggiunto: `messages.kind` accetta ora anche `sistema`.** Il motore scrive righe che non sono parlato né tiri. Stile `.msg-scontro` aggiunto in `land.html`: `.msg-sys` era già presa dai «Messaggi dal sito».
79. **Errore mio, trovato da Antonello e corretto:** il banner della Test Room compariva in **tutte** le chat. `display:flex` batte l'attributo `hidden`. Avevo verificato sintassi e tag, non la pagina aperta. **Lezione registrata in `05_CONVENZIONI.md`.**
80. **⚠️ Collisione fra chat su `land.html`, trovata da Antonello.** Avevo costruito la Test Room sulla mia copia locale invece che sul file vero: il consegnato avrebbe cancellato `normVirg` e riportato il riquadro PNG all'oro. Rifatto sopra la copia presa dal disco. **Regola operativa nuova: la copia locale non è una fonte.**
81. **⚠️ Seconda collisione, su `admin.html`, trovata da me applicando la regola nuova.** Le due copie divergevano in tutte e due le direzioni: la mia aveva la pagina Basi Accademia, la sua il campo **Grado** dei sensei e la nota sui sensei attivi. Fuse a mano, hunk per hunk, saltando i quattro che avrebbero cancellato il lavoro altrui.
82. **⚠️ Segnalazione — la Parata non è una base d'Accademia.** Il regolamento la dà a tutti, il catalogo la vende a 50 XP. **Nel motore vale il regolamento**; la voce a catalogo va ripensata. **Non toccata.**
83. **⚠️ Segnalazione — il `defense_hint` della Sostituzione contraddice §4.5** del regolamento. Il motore segue il regolamento; la riga a database **non è stata corretta**.
84. **⚠️ Segnalazione — un `</option>` orfano in `admin.html`.** C'era già nella copia di Antonello. Non toccato.
85. **Scelte prese costruendo, tutte reversibili:** lo spostamento si dichiara **in metri e in verso** e avvicinandosi non si supera l'avversario · **la parata attutisce** dividendo la Resistenza per 10 invece che per 20 · **chi accende un'innata passa il turno** · il fato tira **1d20 → ⌊tiro÷2⌋×5 metri** · il **colto in azione vale −6** e **guardia e mira +3**, in attesa di una decisione vera.

### Del 02/08, notte — quarta chat, il motore giocato

> **I sei difetti qui sotto non li ha trovati una prova SQL: li ha trovati la partita.** Le prove in `begin; … rollback;` erano tutte verdi. Vale la pena tenerne memoria.

86. **⚠️ FALLA DI SICUREZZA MIA, aperta e chiusa in serata.** `combat_dichiara_attacco` accettava un parametro `p_base` fino a **120 da qualunque client**: chiunque sapesse chiamare la funzione poteva dichiarare il danno che voleva. **È esattamente il difetto che l'audit di luglio aveva chiuso in `post_combat`**, riaperto da me scrivendo il motore. Ora il danno lo decide il server: **colpo a mano = 10**, **tecnica = il suo `danno_base`**, e **solo lo staff** può fissare un valore diverso.
87. **⚠️ Le righe uscivano nell'ordine sbagliato.** «— Round 2 —» compariva **prima** della risoluzione del round 1: dentro una transazione `now()` è una costante, quindi tutte le righe avevano lo stesso istante. Corretto con `clock_timestamp()` in `_combat_dice`. **Trappola da ricordare.**
88. **La distanza d'ingaggio veniva buttata via.** Si apriva a 20 metri e il secondo che entrava si ritrovava a 10. Aggiunta la colonna `combat_sessions.distanza_ingaggio`.
89. **`combat_muovi` era muto.** Cinque spostamenti e nessun messaggio: sembrava rotto e invece funzionava. **Segnalato da Antonello.** Ora scrive la riga in chat.
90. **Il pannello dava coordinate assolute.** «Sei a 12 m» non dice niente: serve sapere quanto dista **l'altro**. Rifatto con la distanza **da te** e la fascia di gittata in chiaro.
91. **Il menù delle innate era vuoto.** **Segnalato da Antonello.** `my_innate` veniva chiamata prima che esistesse una sessione e non veniva più richiamata; in più non leggeva il clan. Corretti tutti e due i punti.
92. **Funzione nuova, chiesta da Antonello: `staff_ripristina(p_target_user, p_location)`**, che riporta vita e chakra al massimo. Serviva per provare due round di fila senza rifare il personaggio. **Solo staff.**
93. **⚠️ Vincolo aggiunto: `character_perks_tipo_check` accetta ora `punti_caratteristica`.** Il CHECK rifiutava il tipo nuovo.
94. **⚠️ Vincolo aggiunto: `characters.pool_concesso`.** Senza, retrocedere e ripromuovere un personaggio coltivava punti all'infinito. **Exploit trovato ragionando, non giocando.**
95. **⚠️ Vincolo aggiunto: il flag transazionale `app.allow_points_delta` si richiude dopo l'uso.** Restava aperto per tutta la transazione: il permesso ora vale per **una scrittura sola**.
96. **Due prove mie sbagliate, non difetti del codice:** un movimento letto nel verso opposto e una promozione tentata senza essere staff. Il codice aveva ragione entrambe le volte. **Un test che passa va provato anche al contrario.**
97. **`_combat_leggi_comandi` è scritta ma NON è agganciata a `post_message`.** Dichiarato di proposito: agganciarla cambia il comportamento della chat per tutti i giocatori, e il modello nuovo non è ancora costruito.
98. **⚠️ Segnalazione — due giocatori usano già `[Fine]`** come convenzione propria per chiudere il turno. Su 92 messaggi in chat sono le **uniche due parentesi quadre** esistenti. Il parser la riconosce e non la scambia per un comando. **Da decidere se diventa un comando vero.**
99. **Il Tavolo di Aiuto raccontava due cose false, corrette.** La voce «Promozioni ed esperienza di carriera» prometteva i **«50 punti»** mai concessi **e** aveva le **soglie sfalsate di un grado**. Aggiunta la voce nuova «Il premio dei punti caratteristica». **`flash_news` allineato** al changelog 42.
100. **⚠️ Segnalazione — una terza voce di `help_kb` racconta un tetto di 65 danni che nessuna funzione impone.** **Non toccata:** o si impone il tetto o si toglie dal testo, ed è una decisione di gioco. Vedi punto 38.
101. **Errore mio nel changelog, corretto:** le righe **41 e 42 erano scritte in ordine invertito** in `REGOLE.md` (40, 42, 41), perché due chat hanno scritto lo stesso file. Rimesse in fila.

### Del 03/08 — l'Accademia con l'IA

102. **⚠️ Errore mio evitato per un soffio: stavo per riscrivere le persone dei sensei leggendole dalla tabella morta `academy_sensei`.** La correzione che avevo pronto avrebbe aggiunto a Katsuo una chiave `divisa` fantasma e **cancellato bio e aspetto di Ibara**. Fermata rileggendo la fonte viva, `ai_agents`. Di conseguenza **§2.16 del mio report era un falso allarme**: la persona viva diceva già «coprifronte».
103. **`to_char(…, 'HH24:MI del DD/MM')` stampava «08:44 2el 03/08»**: `d` ed `e` sono codici di formato. Corretto con `"del"` fra virgolette doppie. **Trovato dalla prova in `begin; … rollback;`**, non a occhio.
104. **⚠️ Vincolo aggiunto di mia iniziativa: chi è in raffreddamento si iscrive come uditore** invece di essere respinto. Si toglie con una riga.
105. **Errore mio nella scrittura del prompt: Vento e Fulmine erano descritti quasi allo stesso modo** — «si taglia in due» e «si spacca a metà» — e il modello li ha scambiati in aula. Riscritti per non poter essere confusi, più una riga esplicita che vieta lo scambio.
106. **Il maestro chiudeva la lezione al passo 3 di 6.** C'era la nota per il passo finale e non c'era la simmetrica: aggiunta, e adesso nei passi non finali è vietato congedare la classe.
107. **Il parlato non diventava rosso quando conteneva un apostrofo.** `esc()` trasforma `'` in `&#39;`, e la regex degli angolari vietava `&`. **Una riga cambiata in `land.html`**, verificata sui cinque messaggi veri che fallivano e controprovata sulla versione precedente.
108. **Il tiro di dado non arrivava al maestro.** `academy_ai_context` raccoglieva solo `kind='say'`. Ora i tiri entrano fra le azioni; il conteggio di chi ha scritto resta legato al solo `say`.
109. **L'elemento dell'allievo non arrivava al maestro**, e serviva per descrivere la reazione del foglio. Aggiunto a `students_meta` **e** — dimenticanza mia, trovata dal banco di prova e non dall'ispezione — reso davvero in `descriviAllievo`.
110. **Tamako riparata a mano:** L2 registrata, «Uso dei sigilli» concessa, 15 XP da 35 a 50, e `completed_at` retrodatato alla chiusura vera della lezione perché le venti ore contassero in modo onesto.
111. **Le 43 voci di `help_kb` riaccentate**, in due passate.
112. **⚠️ Le prove si sono fatte nell'aula disattivata «Konoha — Accademia, Aula 2»**, e i messaggi di prova sono stati **spostati nella Test Room** — che si svuota da sola ogni ora — **mai cancellati**.
113. **⚠️ Segnalazione — `academy_sensei` è una tabella morta che inganna.** Non la legge più nessuna funzione, ma contiene persone vecchie e credibili. **Va svuotata o rinominata.** Non toccata.
114. **⚠️ Segnalazione — `lesson_grants` di L3 concede ancora «Camminata sulle superfici», che ha `jutsu.is_active = false`** e quindi non arriva a nessuno. Coerente col copione — «non è una tecnica nuova, è il controllo di prima messo dove serve» — ma è una riga morta. **Non toccata.**
115. **⚠️ Segnalazione — due personaggi su quindici non hanno un elemento a database.** È il motivo per cui il copione della carta ha la riga sul foglio che non reagisce.
116. **⚠️ Il file locale `.ts` aveva gli accenti in forma decomposta** (NFD), per colpa degli heredoc di Bash. **Il database è pulito**: verificato con `normalize(x, nfc)` su copioni, persone, `help_kb`, obiettivi e messaggi — zero occorrenze. File locali normalizzati.
117. **⚠️ La copia di `land.html` presa dal disco era indietro di 4,6 KB** rispetto a quella su GitHub: 70 righe di differenza. `fmtBody` era identica, verificato prima di applicare la modifica. **Terza collisione fra chat in tre giorni.**
118. **Errore mio, corretto da Antonello:** la regola che avevo scritto diceva letteralmente al maestro di mandare gli allievi **a guardare la scheda**. La scheda è OFF. Stessa classe di errore, più tardi: «al prossimo turno».
119. **⚠️ Segnalazione — nell'ultimo giro di prova è scappato un «al prossimo turno».** Aggiunto al glossario delle parole vietate, ma **la verifica vera è la prossima lezione giocata**.
120. **⚠️ Tre giri in aula disattivata dicono che il prompt regge, non che la lezione funziona.** La prova che conta è la prossima L3 giocata dai giocatori.

### Del 03/08 — il motore in chat *(registrato in ritardo)*

121. **⚠️ Vincolo aggiunto: difendersi con una tecnica costa chakra.** Prima la difesa con tecnica era gratis: un giocatore poteva pararsi con la tecnica più cara del catalogo a ogni colpo. Si toglie con una riga.
122. **⚠️ Vincolo aggiunto: nel proprio turno una quadra storpiata ferma il messaggio.** `[schivta]` passava come testo e il turno si perdeva in silenzio. Ora il messaggio viene rifiutato con l'avviso. **Vale solo nel proprio turno**, per non bloccare chi scrive narrativa con delle quadre dentro.
123. **⚠️ `combat_dichiara_attacco` ignorava il tipo passato dal client.** Non era sfruttabile — il tipo lo ricava dalla disciplina — ma il parametro restava nella firma e ingannava chi la leggeva.
124. **`[guardia]` non si applicava mai.** Il flag veniva scritto e poi non letto da nessuno: si spendeva l'azione rapida per niente. **Difetto vero, trovato giocando.**
125. **`[sposta +bla]` passava in silenzio.** Un argomento non numerico non veniva rifiutato: il comando si perdeva senza dire niente.
126. **`min(uuid)` non esiste in PostgreSQL.** Usato per scegliere il bersaglio implicito. Sostituito con un ordinamento esplicito.
127. **⚠️ La pagina schiacciava gli errori del motore.** Qualunque rifiuto del server diventava «Impossibile inviare»: chi giocava non sapeva *perché*. Ora l'avviso vero arriva in chiaro.
128. **⚠️ Segnalazione — la deroga dei menù guarda la presenza, non il luogo.** `_in_test_room()` legge dove sei registrato, non dove stai guardando: fuori dalla stanza di prova si vedevano tutte le tecniche sbloccate. **Non toccata il 03/08**; chiusa il 05/08 per un'altra strada (punto 137).
129. **⚠️ Trappola dell'ambiente: `device_stage_files` può restituire una copia in cache.** Dichiarava 426.155 byte e ne consegnava 425.228. **Dopo ogni stage vanno confrontati i byte dichiarati con quelli arrivati.**
130. **⚠️ Vincolo aggiunto: il clan non è materia su cui il maestro si pronunci.** Un sensei confermava poteri di clan che non esistono. Aggiunto ai divieti del prompt.

### Del 04-05/08 — il gate del motore v1

> **Anche qui, quello che conta l'ha trovato la partita.** Le prove in `begin; … rollback;` erano verdi su tutto: i difetti sotto sono usciti aprendo la pagina e giocando.

131. **⚠️ `combat_join` mandava lo scontro in stallo completo.** Chi entrava come spettatore a duello avviato non «rubava un turno», come avevo scritto: **bloccava tutto**. L'attaccante si sentiva rispondere «hai già speso l'azione principale», il difensore «non è il tuo turno d'attacco», e `_combat_avanza` diventava irraggiungibile. Chiuso con un rifiuto esplicito all'ingresso tardivo.
132. **⚠️ Ritratto quello che avevo detto io.** Avevo scritto che `combat_join` **riassegnava l'iniziativa** e poteva sottrarre il primo turno: rileggendo, il ritorno anticipato fa sì che l'iniziativa **non venga mai sovrascritta**, e che sia l'iniziativa a decidere chi comincia. **La correzione era mia, e l'ho detta sbagliata prima di dirla giusta.**
133. **⚠️ Secondo errore mio ritrattato: il segno dello spostamento.** Avevo scritto ad Antonello che «con `[sposta -5]` chiudi la distanza». È **il contrario**: il positivo avvicina, il negativo allontana. Verificato sul motore, non a memoria, e corretta anche la nota dello scenario 4 della stanza di prova, che portava il segno rovesciato.
134. **⚠️ `test_room_scenario` non allineava la fixture.** Armando uno scenario interattivo, fase, round e `turn_of` restavano quelli di prima: la prova partiva da uno stato che non era quello dichiarato. Ora l'armamento allinea sessione, fase, round, turno, pending, flag e distanza; il completamento e la chiusura azzerano tutto.
135. **⚠️ `_combat_risolvi`, `_combat_avanza` e `_combat_dice` erano eseguibili da chiunque.** Helper interni del motore, raggiungibili da un browser. Revocati, dopo aver verificato che i percorsi server continuassero a funzionare.
136. **⚠️ Revocare non basta se non si revoca a `PUBLIC`.** `anon` e `authenticated` ereditano l'esecuzione da lì: una revoca ai due ruoli soli lascia la porta aperta. **Trappola da ricordare.**
137. **⚠️ La deroga portava 350 tecniche non possedute in una scena libera.** Difetto vero, non teorico: due rifiuti `tecnica non disponibile o non ancora attiva` alle 00:55, perché la pagina carica l'elenco **una volta sola all'avvio** e bastava conservare la presenza in Test Room. Su 358 righe offerte, **350 sarebbero state rifiutate dal server**.
138. **La card dello scontro cambiava altezza fra le fasi** (213,7 px contro 196) e faceva ballare tutta la colonna. Fissata a **240 px stabili** riservando lo spazio alle righe di servizio.
139. **Il suggeritore leggeva il cursore al momento del clic**, e `input.selectionStart` a quel punto non è affidabile: la parola veniva sostituita nel posto sbagliato. Ora la posizione si **congela quando la lista viene disegnata**.
140. **La colonna aveva tre media query non concordi.** Commutava a soglie diverse da topbar e mappa. Portate tutte a **860/861**. ⚠️ **Cambio visibile fra 761 e 860 px**, dichiarato: lì la colonna era in modalità «schermo grande» mentre la stanza era stretta.
141. **⚠️ Segnalazione — la parata pesca da `Forza + Taijutsu` nel motore e da `Velocità + Taijutsu` nel regolamento.** Uno dei due va cambiato. **Non toccata:** è una decisione di gioco, ed è il candidato per la riga **45** del changelog. → **Chiusa in giornata, il 05/08:** ha vinto il regolamento. La migrazione `combat_v1_parata_pesca_da_velocita` porta il ramo `parata` di `_combat_calcola` su `velocita + taijutsu`; provata con due difensori speculari (Forza 40 / Velocità 10 e il contrario), con schivata, tecnica difensiva e genjutsu come controlli invariati, e con un colpo risolto end-to-end nella stanza di prova. Riga **45** del changelog.
142. **⚠️ Segnalazione — il messaggio di `combat_join`** invita ancora a «restare come partecipante» a duello avviato, quando ormai il server rifiuta. **Riga sostitutiva pronta, non applicata per scelta di Antonello.**
143. **⚠️ Segnalazione — `test_room_pulizia` non tocca le sessioni aperte**, e finché una prova resta aperta **non svuota nemmeno i messaggi della stanza**. Si sblocca da sé dopo 24 ore di silenzio. **Non toccata.**
144. **⚠️ Segnalazione — `scheda.html` e `admin.html` non sono mai state ispezionate** contro il nuovo contratto di `my_abilities`.
145. **⚠️ Limite della verifica, dichiarato:** del regolamento caricato il 05/08 **ho potuto leggere dal vivo solo l'80% del file** — lo strumento tronca — e il changelog comincia esattamente lì. **La riga 44 sul sito l'ha vista Antonello, non io.** Quello che ho confermato è la §4.8 viva in `regole.html`.

---

### Del 06/08 — il narratore in scena, il pilot con due persone vere, il bilanciamento

> **La giornata in cui il motore è passato di mano.** Per la prima volta due persone diverse hanno giocato lo stesso scontro, e ogni difetto trovato oggi è stato trovato giocando: nessuno è uscito da una verifica SQL.

146. **Lo spostamento si dichiara prima dell'azione principale**, e la finestra riapre le opzioni che la distanza finale rende raggiungibili. Il motore eseguiva già `combat_muovi` prima di `combat_dichiara_attacco`: il difetto era solo nella valutazione iniziale del client.
147. **Lo sblocco vale solo per la gittata.** «Hai già speso» e il chakra insufficiente restano blocchi. Il chakra si verifica a parte perché il `CASE` di `combat_opzioni` ha precedenza *speso → gittata → chakra* e maschererebbe il secondo motivo.
148. **Il campo dello spostamento parte da `0`**, che è la conferma esplicita di restare fermi e non genera un movimento nel payload.
149. **La proiezione della distanza in ritirata resta nominale.** Chi ha il limite del campo alle spalle resterebbe fermo: `combat_opzioni` non espone `pos_m` e da pagina non è calcolabile. Si dichiara in chiaro invece di fingere precisione.
150. **`combat_state` guadagna un solo booleano, `narrazione_attesa`.** Nessun dato del referto esce verso il browser. L'eleggibilità è copiata dal tick, **senza** i suoi ritardi di 2 e 3 minuti: quelli dicono *quando* parte il racconto, non *se* è dovuto.
151. **L'attesa sopravvive alla chiusura dello scontro.** Il booleano non filtra `combat_sessions.state`: un referto risolto poco prima della chiusura resta segnalato finché il suo racconto o il fallback non arrivano.
152. **In pagina il confronto è `=== true`.** Se `land.html` arriva prima della migrazione la chiave manca, la riga resta nascosta, niente si rompe. Vale come schema per ogni chiave additiva futura.
153. **La riga d'attesa è una resa del client**: sta fuori da `#msgs`, non è un messaggio, non ha un `kind` suo e sparisce cambiando un attributo. Nessuna scrittura a database per farla comparire o sparire.
154. **Il racconto del narratore passa da 500-650 a 500-1.500 caratteri** nel duello 1v1, e il taglio cade **sempre** su una frase chiusa: o si chiude un periodo, o il tentativo conta come fallito. Prima, sotto il 60% del limite, si ripiegava sul taglio a parola.
155. **La coda `〈Nome: −PV〉` resta, ed è l'unico valore di gioco ammesso in scena.** Corrisponde ai Punti Vita davvero scalati, la scrive il server e resta fuori dal conteggio dei caratteri. *(Ribalta la riga di §4.7 che prometteva «i numeri non compaiono mai in chat»: si corregge il testo, non il comportamento.)*
156. **Il regolamento dichiara il motore in playtest chiuso**: Test Room allo staff, e fuori solo pilot temporanei e circoscritti accesi dallo staff. Non è un'apertura generale. *(Supera «per ora solo nella stanza di prova», che era rimasta scritta mentre il pilot girava.)*
157. **Il termine di abilità passa a `⌊pool/5⌋` e il dado a 2d10.** Deciso con i numeri sotto gli occhi: a parità di pool non cambia nulla (52,7% → 53,4%), ma il divario fra gradi si allarga fino a rendere il duello deciso in partenza a due gradini di distanza. **Scelta di mondo dichiarata**, non effetto collaterale.
158. **Nasce lo slancio**: ogni colpo a vuoto dà +3 al proprio prossimo attacco, fino a +9, azzerato quando il colpo va a segno. Porta le serie di tre vuoti dal 10,2% all'1,8% e la serie peggiore da 15 a 5.
159. **Nasce il danno di striscio**: un colpo che manca sfiora comunque. È la sola correzione che azzera gli scambi senza effetto — dal 38,9% a zero. Proposto a un quarto del danno pieno, minimo 1.
160. **La Sostituzione resta l'unica negazione totale**, e per questo va raccontata come ogni altro esito invece di uscire dal motore senza lasciare traccia.

**Correzioni registrate lo stesso giorno:**

161. **⚠️ La Sostituzione non scriveva nessun referto.** `combat_dichiara_difesa` cancellava il colpo in sospeso e saltava `_combat_risolvi`, l'unico posto dove nasce una riga di `combat_referto`. Niente referto, niente racconto, niente attesa — e la riga in chat è `motore`, quindi **per il giocatore quello scambio non era mai avvenuto**. Trovata giocando, il 06/08 alle 12:51.
162. **⚠️ Il testo dell'esito mancato mente.** «Para in pieno e regge — nessun danno» viene scritto quando il colpo ha **mancato**, non quando la parata assorbe. Ha ingannato l'autore stesso del motore, che stava per registrare come difetto una parata che azzerava i danni.
163. **⚠️ I Punti Vita risalgono durante uno scontro aperto.** In un'ora i due combattenti hanno recuperato un punto a testa: fa deriva sulla preparazione del KO, che lo staff imposta a 5.
164. **⚠️ «Colto in azione −6» non può scattare in un duello 1v1**, perché si applica dal secondo colpo in sospeso nello stesso round e il pending è sempre uno solo. Nei sette referti del pilot è sempre 0, insieme a mira, guardia ed elementi: **tutti i modificatori del sistema sono, di fatto, spenti**.
165. **⚠️ Trappola dell'ambiente:** `device_stage_files` ha di nuovo consegnato una copia in cache — dichiarava 470.800 byte e ne consegnava 465.975. Confermata la regola: dopo ogni stage si confronta l'hash, non la dimensione dichiarata.

---

### Del 06/08, sera — l'apertura della land

> **Il motore esce dalla stanza di prova.** Non era una riga da togliere: le tre porte ne avevano due, e la seconda nascondeva un difetto che si sarebbe visto solo al primo clic di un giocatore vero.

166. **Il motore degli scontri si apre a tutte le chat di gioco**, prima della V1.1 e non dopo. La stanza di prova resta riservata allo staff ed è l'unico posto dove i numeri non contano.
167. **Nessuna whitelist.** La corsia del pilot non è più consultata da nessuna funzione; il pilot resta chiuso e il suo controllo automatico spento, ma tabella, funzioni e **1.126 righe di storico** restano dov'erano.
168. **Un duello per volta per personaggio**, e **si combatte dove si è**. `sfida_invia` e `sfida_decidi` lo controllavano già; `combat_open` e `combat_join` no, e con un solo luogo di prova non poteva vedersi.
169. **Chi apre, il master e lo staff chiudono subito.** L'altro combattente può abbandonare **solo se la mossa spetta all'avversario e sono passati dieci minuti di silenzio**: né prigioniero di chi sparisce, né libero di sfilarsi da un colpo in arrivo.
170. **Il silenzio si misura su `last_action_at`, non sulla presenza.** `presence.last_seen` si rinnova da sola ogni sessanta secondi con la pagina aperta: misura «scheda aperta», non «attività». Con quella un avversario connesso ma assente terrebbe l'altro in ostaggio per sempre.
171. **`sfida_decidi` non è stata toccata:** il ricontrollo della presenza di entrambi era già nel suo corpo. Riscrivere una funzione per confermare una riga che c'è già sarebbe stato riaprirla senza motivo.

**Correzioni registrate lo stesso giorno:**

172. **⚠️ Il secondo cancello delle tre porte non guardava il luogo.** `if not _puo_test_room() and not _pilot_ammesso(...)` negava a chiunque non fosse staff, **ovunque**, non solo in Test Room. Era mascherato dal primo cancello, che fermava prima le stesse persone. Togliendo il primo — cioè facendo l'unica cosa ovvia per aprire — **ogni giocatore normale avrebbe ricevuto «La Test Room è riservata allo staff» dentro una chat qualunque**. Riscritto nella forma che `enter_location` usa da settimane.
173. **⚠️ `combat_close` era una porta aperta.** Eseguibile da `PUBLIC`, `anon` e `authenticated`, con una scorciatoia per chiunque passasse il motivo `'silenzio'`: bastava quello per **chiudere il duello di chiunque, in qualsiasi momento**. In Test Room era irrilevante; con la land aperta sarebbe stato il modo più semplice per sfilarsi da un colpo o rovinare la scena di due estranei. La scorciatoia ora vale **solo se il fatto che dichiara è vero**.
174. **⚠️ La card dello scontro si nascondeva fuori dalla Test Room.** Aprire il solo database sarebbe stato invisibile: il server avrebbe accettato e il pulsante non sarebbe comparso a nessuno.
175. **⚠️ Trappola dell'ambiente, seconda volta in un giorno:** repo aggiornato e dominio fermo alla versione vecchia. La diagnosi che chiude la questione in un colpo è leggere lo stesso file su `raw.githubusercontent.com` e sul dominio — se divergono, non sono i file e non è il browser: è la pubblicazione di Pages. Procedura in `05_CONVENZIONI.md` §10.

### Del 06/08, notte — l'Accademia

176. **⚠️ Vincolo aggiunto al validatore:** se il materiale del passo **non** contiene una nota `(( … ))` e l'intervento del maestro ne contiene una, il turno viene scartato e fatto riscrivere. Prima il controllo guardava solo il caso opposto — nota prevista e non ricopiata — e una nota inventata passava indisturbata. **Ha già lavorato in produzione**: alle 00:23 del 07/08 ha fermato il passo 6 di una L3 che si portava dietro la nota del dado a lezione finita.
177. **⚠️ Vincolo aggiunto al contesto, non al prompt:** `descriviAllievo` non riceve più l'elemento se il materiale del passo non parla di fogli o di carta da chakra. È una **riduzione di ciò che il modello sa**, non una regola in più: se un copione futuro userà la parola «foglio» per altro, l'elemento tornerà in contesto senza che nessuno se ne accorga. Va saputo.
178. **Errori d'italiano vietati per nome nel prompt.** Otto forme sbagliate uscite davvero in aula — *si fusionano, ad mano libera, linee storti, sul gessiera, un attesa, aveva sparito, merità*, più «braccia conserte lungo i fianchi» — sono adesso elencate come esempi da non ripetere. È una scelta discutibile e reversibile: un elenco di errori occupa spazio nel prompt e invecchia. Segnalata perché sia controllata.
179. **⚠️ Segnalazione, non correzione:** tre findings dell'audit **non** sono stati recepiti nel prompt. La punteggiatura del copione citato alla lettera (in conflitto con la regola che impone di riformulare le frasi a effetto), il «cancellino di feltro» introdotto dal modello, e il gesso che batte durante la scrittura invece che durante il parlato. Decide Antonello.
180. **⚠️ Trappola nuova, evitata per un soffio:** una migrazione al copione di una lezione **non si applica mentre una sessione di quella lezione è aperta**. `total_steps` viene fotografato in `academy_class_sessions` all'avvio: una classe partita a sei passi avrebbe chiuso sul passo 6 nuovo, cioè su un ordine di esercizio, senza mai vedere il 7. La migrazione ha la guardia che rifiuta, ed è rimasta in attesa un'ora fino alla chiusura dell'ultima L2.
181. **⚠️ Due interventi sbagliati restano pubblicati in chat** e non sono stati toccati: il riepilogo del ciclo riscritto male da Ibara a Suna e il «Tu hai il Fuoco» detto da Katsuo a Rei. Correggerli in scena è una scelta di staff, non mia.

### Del 06/08, sera — la catena dell'audit *(registrata il 07/08)*

182. **⚠️ Ho riscritto un'istruzione del prompt dell'audit, non solo aggiunta.** Il testo diceva al modello che un ordine nascosto nella role di un allievo «è un fatto da segnalare, ed è tu stesso a doverlo trattare come evidence». Con la regola che vieta di citare gli allievi, quelle due parti dello stesso file si contraddicevano. Adesso dice: il tentativo dell'allievo di per sé non è un difetto del maestro; lo diventa se il maestro obbedisce, e allora si cita **la sua risposta**. Approvata, ma resta una mia iniziativa nata dal banco.
183. **Aggiunto `turni_corretti` alla risposta dell'audit**, non richiesto: conta quante volte il server ha dovuto correggere turno o passo dichiarati dal modello. Se quel numero non scende con le versioni del prompt, il prompt non sta funzionando. Da ACC-012 finisce anche in tabella.
184. **⚠️ ACC-012 scatta due tabelle di copia** — `academy_ai_findings_pre012` e `academy_ai_finding_hits_pre012` — perché la migrazione **cancella righe** e senza copia il rollback sarebbe solo delle strutture. Sono chiuse con RLS, nessuna policy e revoca da `PUBLIC`, `anon`, `authenticated` **e `service_role`**: la stessa regola scelta per il backup del narratore. Vanno cancellate a mano quando il rollback non serve più, o resteranno lì per sempre.
185. **`academy_finding_fingerprint` viene revocata da `PUBLIC`, `anon` e `authenticated`** (grant solo a `service_role`). Era aperta per difetto dalla creazione: è una funzione pura che non legge tabelle, quindi non era una fuga di dati, ma contraddiceva la convenzione e sarebbe uscita nei controlli di catalogo.
186. **Difetto del banco, non del codice:** la lezione sintetica di `banco_prova_audit.js` non portava `message_id` sui turni, cosa che il corpus vero fa sempre. Finché nessuno agganciava il turno al messaggio non si vedeva; ACC-011 l'ha fatto emergere di colpo. Corretta la fixture, non il codice.

### Del 07/08, pomeriggio — chiusura delle RPC

187. **Le funzioni nuove nascono chiuse al client.** Il default globale di `postgres` revoca `EXECUTE` a `PUBLIC`; il default per `public` rimuove i grant nominali Supabase a `anon` e `authenticated`. Entrambe le ACL restano con `postgres` e `service_role`: una funzione nata dopo la migrazione è invocabile solo dal secondo. Non è una cache transazionale: le ACL per schema si sommano al default globale.
188. **Le RPC esistenti sono ricostruite per contratto, non per ereditarietà.** I tre buchi e gli helper interni sono revocati da `PUBLIC`, `anon` e `authenticated`; le quattro API davvero pubbliche restano ad `anon`, le API client necessarie ad `authenticated`, e `service_role` mantiene tutte le 232 funzioni per le Edge Function. Nove prove post-applicazione verdi, inclusi cron e chiamate Edge.

### Del 07/08, sera — la tabella creduta chiusa

189. **La RLS attiva non chiude una tabella: `service_role` la scavalca.** `narratore_backup_20260805` risultava «chiusa» dal 05/08 perché aveva RLS attiva e zero policy, ma `service_role` ha `rolbypassrls = true` — come `postgres` — e la leggeva per intero con la chiave di servizio. **La leva vera è il privilegio di tabella**, non la RLS: la migrazione `sicurezza_narratore_backup_chiusura_service_role` (`20260807152407`) gli revoca ogni privilegio **sulla sola tabella**, lasciandogli tutto il resto. ACL finale `postgres=arwdDxtm/postgres`; legge solo il proprietario; RLS, policy, proprietario e 15 righe invariati. **La tabella è chiusa, non rimossa.** Prima di applicare, gate in due tempi: nessun oggetto del database la referenzia, e le **sei Edge Function più le undici RPC che chiamano** sono state lette una per una — nessun accesso diretto, transitivo o dinamico. Banco post-applicazione verde su 13 controlli, lo stesso che prima andava rosso su tre.
190. **Le default ACL delle tabelle restano aperte, e la revoca globale è rimandata apposta.** Nello schema `public`, `postgres` **e** `supabase_admin` concedono ancora `arwdDxtm` ad `anon`, `authenticated` e `service_role` su ogni tabella nuova, e `rwU` sulle sequenze: è lo stesso meccanismo chiuso la mattina del 07/08 **sulle sole funzioni** (decisione 187). **Deciso di non toccarlo adesso:** serve prima mappare RPC, Edge Function e accessi diretti, perché una revoca alla cieca spegnerebbe il gioco al primo tick. Resta come lavoro aperto in `04`, e la regola preventiva è in `05` §7.

### Del 07/08, sera — ACC-AUDIT-012 applicata

191. **L'identità di un difetto la decide il server, e la chiave è ramificata per famiglia.** La chiave era `md5(categoria | expected | regression_case)`: due terzi prosa del modello, che riformula. Misurato: **sedici hit, sedici chiavi, zero ricorrenze riconosciute**, mentre almeno due difetti erano stati trovati da due audit diversi. Adesso i difetti di **materiale** (`copione`, `coerenza_materiale`, `canone_e_segreti`) si identificano con *categoria | villaggio | lezione | passo*, quelli di **scrittura** con la **sola categoria** — la stessa sbavatura in tre lezioni è un problema solo del prompt. ⚠️ **E i quattro ingredienti non arrivano dal payload:** villaggio e lezione dalla sessione, passo dal turno; un payload che li contraddice viene scartato con un motivo che dice il valore vero. Conseguenza accettata (**legacy strict**): un finding legacy senza turno, se è di materiale, viene scartato — il suo passo non è un fatto del server. Oggi non tocca nessuna riga, ma cambierà la resa della prima corsa sullo storico.
192. **La gravità ha un ordine dichiarato, non alfabetico.** `academy_severity_rank` mappa `P0=0 … P3=3` e `999` per l'ignoto, e sostituisce `least()` e `min()` sulle etichette. Funzionavano solo perché l'alfabeto e la gravità coincidono per caso: una severità chiamata «A1» avrebbe scalzato P0 in silenzio. *(Nota emersa provando: `academy_ai_findings` ha già un `CHECK` che impone P0-P3, quindi il rango protegge dal giorno in cui quel CHECK verrà allargato.)*
193. **Un rollback ripristina solo ciò che ha trasformato.** Il candidato di prima faceva `delete from academy_ai_findings` e ricopiava dallo snapshot: qualunque riga nata dopo l'applicazione spariva, e la verifica — che confrontava i conteggi con lo snapshot — **passava muta**. Riprodotto in transazione. Il rollback nuovo è chirurgico e ha due guardie: le righe della fotografia sono tornate tutte, **e** quelle nate dopo sono ancora quante erano. Nella stessa revisione: lo snapshot **fallisce** se le copie esistono già (mai `create table if not exists`), le colonne sono sempre esplicite, e il `drop`+`create` della funzione della chiave riconcede i privilegi che aveva prima.

### Del 07/08, sera — la scheda del giocatore

194. **Una trigger function non `SECURITY DEFINER` gira coi privilegi di chi scrive, e questo ha spento la scheda a tutti.** `characters_guard()` chiama `public._grade_rank(old.rank)` nel ramo non-staff; revocando da `PUBLIC` la mattina del 07/08, `authenticated` ha perso quell'`EXECUTE` e per sei ore ogni giocatore che toccava la propria scheda ha ricevuto «permission denied for function _grade_rank». Chiuso con un `grant execute … to authenticated` su quel solo helper. ⚠️ **Deroga dichiarata** alla regola «mai un helper con underscore al client»: qui il client non lo chiama, lo attraversa un trigger che gira per suo conto. L'alternativa — rendere `characters_guard` `SECURITY DEFINER` — avrebbe cambiato il contesto di esecuzione dell'intera guardia: più superficie, non meno.
195. **`characters_guard` pinna colonna per colonna, e sette colonne non erano pinnate.** `pool_concesso`, `last_regen_at`, `is_test`, `corp_role`, `corp_spec`, `corp_since`, `corp_anon`: un giocatore poteva scriverle sulla propria riga. Le prime due sono le gravi — `pool_concesso` abbassato e una ripromozione rifanno scattare il pool intero; `last_regen_at` retrodatata vale PV e chakra arbitrari. Adesso si ripristinano tutte da `OLD`, con **due sole deroghe a flag**: `app.allow_points_delta` per `characters_grant_pool()`, che è un trigger AFTER la cui `UPDATE` rientra dalla guardia, e `app.allow_regen_at` per `applica_recupero()`. **Restano del giocatore i sei campi personali** — avatar, banner, musica, face claim, background, note OFF.
196. **Il flag del recupero è nuovo apposta, non si riusa `app.allow_vita_delta`.** Quel flag lo aprono **undici** funzioni fra combattimento, cure, oggetti, KO e ripristini: riusarlo avrebbe reso la data del recupero scrivibile ogni volta che qualcosa tocca i PV. `app.allow_regen_at` lo apre solo `applica_recupero()`, subito prima della propria `UPDATE`, e lo **richiude subito dopo**. ⚠️ Resta aperto, e va trattato a parte: gli altri due flag di quella funzione — `allow_vita_delta` e `allow_chakra_delta` — **non si richiudono**, restano impostati per il resto della transazione. È comportamento preesistente e confinato alla singola richiesta; il PM lo ha registrato come **audit separato sul ciclo di vita di tutti i GUC**, non come allargamento di questa correzione.

### Del 07/08, notte — il pannello dell'audit e il passaggio che mancava

> ⚠️ **Le decisioni 218 e 219 stanno qui sotto pur avendo numeri alti.** Sono state scritte l'08/08 mattina ma appartengono a questo lavoro: i numeri 205-217 erano già stati presi nella notte da un'altra chat, mentre questa sessione era aperta sugli stessi file. ⚠️ **La numerazione non è più monotona nell'ordine del file** (le 210-217 stanno molto più in alto): prima di scrivere una riga nuova si cerca il numero più alto **ovunque nel documento**, non l'ultimo che si legge scorrendo.

197. **`ADMIN-AUDIT-001` è chiusa e il pannello è vivo.** `admin.html` espone «Audit Accademia» e «Classi bloccate» dentro la voce IA, con le sole quattro RPC staff previste, nessun token e nessuna chiamata alla Edge dell'audit dal browser. File pubblicato 269.573 byte, md5 `4a7da885…`, verificato byte per byte sul sito e poi visto da Antonello con account staff.
198. **Un'approvazione deve produrre un miglioramento reale, ma non un auto-deploy.** Oggi `academy_finding_decidi` registra la decisione e la nota, e basta. Domani si apre `ACC-AUDIT-013`: dai soli findings approvati deve nascere una patch leggibile sul bersaglio corretto; in conflitto la nota staff prevale sul `proposed_fix` del modello. Restano obbligatori anteprima, approvazione esplicita, applicazione, banco/prova e solo dopo lo stato `verificato`. L'audit non riscrive da solo il maestro: `academy_audit_ai` osserva, `academy_sensei_ai` insegna.
199. **Tutti i nomi del pannello nuovo portano il prefisso `acc`.** `admin.html` aveva già `loadAudit()`, `renderAudit()` e `#audit-list`, che sono il **registro dei movimenti dello staff** e non hanno niente a che vedere con l'audit dell'Accademia. Due cose chiamate «audit» nello stesso file non danno errore: danno confusione silenziosa, mesi dopo. La regola generale — cercare un nome prima di aggiungerlo in una pagina monolitica — è in `05` §10.
200. **Le funzioni di resa vivono in un file sorgente separato e sono innestate alla lettera nella pagina.** `claude/admin_audit_pannello.js` è la sorgente; il blocco dentro `admin.html` è delimitato da `ACC-PANNELLO INIZIO/FINE` e il banco confronta le due copie **carattere per carattere**. Senza quel confronto un banco verde direbbe che funziona il file a parte, non il codice che gira davvero — il difetto che `banco_prova_scontro.js` ha ancora. ⚠️ **Prezzo accettato:** il blocco innestato resta a **colonna 0** invece che rientrato, perché un rientro cosmetico romperebbe la garanzia. Un commento in pagina lo dice.
201. **Il pannello è scritto in ES5, come il resto di `admin.html`.** La pagina non contiene un solo `const`, `let` o arrow function. Restare nello stesso dialetto non è abitudine: è ciò che permette l'innesto letterale e la verifica della decisione 200.
202. **`ultimi_errori` in interfaccia si chiama «errori che hanno bloccato la classe», senza il numero di tentativo.** Il campo contiene gli errori del **primo** tentativo anche sulla riga del secondo (difetto aperto, `01` §3bis). Finché resta così, un'etichetta che nomina il tentativo direbbe una cosa falsa; una che nomina l'effetto è vera in entrambi i casi.
203. **La ricorrenza mostrata è il numero di audit distinti, affiancata dalle occorrenze totali.** Dopo ACC-AUDIT-012 `academy_audit_elenco` conta `count(distinct audit_id)`. Sono due numeri diversi — un difetto visto tre volte dentro lo stesso audit non è ricorrente — e il pannello li dice **entrambi**: mostrarne uno solo è come non mostrarne nessuno.
204. **Quando un file consegnato non è recuperabile, la copia sorvegliata si ricava dalla pagina — e lo dichiara.** I tre file di corredo di `ADMIN-AUDIT-001` non erano scaricabili dalla chat che li aveva prodotti. `admin_audit_pannello.js` è stato **rigenerato estraendo il blocco fra i marcatori da `admin.html`**: dentro i marcatori è identico per costruzione, ed è proprio ciò che il banco verifica. ⚠️ **La coda con `module.exports` è invece ricostruita**, perché nella pagina non esiste, e il file lo dice in testa a sé stesso. La regola che ne esce: una ricostruzione entra nel progetto solo se **dichiara dove finisce la certezza e dove comincia l'ipotesi**. Il banco e la prova visiva non erano ricostruibili allo stesso modo, e infatti non sono stati «recuperati»: sono stati **riscritti** — decisione 219.
218. **L'`</option>` orfano di `admin.html` non esiste, e non è mai esistito.** La decisione **84** lo segnalava come presente nella copia di Antonello, e l'handoff di `ADMIN-AUDIT-001` lo ripeteva contando 173 aperti contro 174 chiusi. **Misurato il 07/08 sera su entrambe le copie — base `64c70ad0…` e file vivo `4a7da885…`: 174 aperti e 174 chiusi, bilanciati.** La decisione 84 resta a verbale perché la cronologia non si riscrive, ma è **superata**: chi la legge non deve andare a cercare un difetto che non c'è. ⚠️ La lezione non è sull'`option`: un difetto «segnalato e non toccato» viaggia da un documento all'altro per mesi senza che nessuno lo rimisuri, e diventa vero per ripetizione.
219. **I due banchi di `ADMIN-AUDIT-001` sono stati riscritti da zero, non recuperati, e portano i loro numeri.** `banco_prova_admin_audit.js` chiude **137/137**, `prova_visiva_acc.js` **32/32** con sette scatti: sono conteggi propri, non gli 80/80 dichiarati dall'originale, e **non si sommano né si confrontano** — misurano insiemi diversi di controlli. Entrambi lo dichiarano in testa. ⚠️ **Regola che ne esce, e che vale per ogni banco del progetto:** una prova negativa è **verde quando rileva il difetto** che le è stato piantato davanti. Non esistono «rossi intenzionali»: un banco che chiude con «58 verdi e 1 rosso voluto» insegna a convivere col rosso, e il giorno che il rosso è vero nessuno se ne accorge. Esito ammesso: verde pieno e uscita 0. Entrambi i banchi sono stati **provati al contrario** — difetti piantati apposta, tutti rilevati.

---

### Dell'08/08, notte — la giornata dell'Accademia

205. **L'Accademia ha una giornata, non un cronometro: dalle 06:00 alle 05:59, ora italiana.** Le venti ore mobili contate dalla fine della lezione precedente facevano **scivolare l'attesa indietro di quattro ore al giorno**, spingendo nella notte chi rientrava appena poteva; e chi chiudeva dopo mezzanotte restava fermo fino a sera del giorno dopo. ⛔ **Scartata la mezzanotte**: avrebbe spezzato in due la serata di chi gioca a notte fonda, liberandolo pochi minuti dopo aver finito. Le **06:00** sono anche l'unico confine sicuro rispetto ai cambi d'ora, perché Europe/Rome scatta fra le 02:00 e le 03:00. Migrazione `acc_reset_0600_giornata_accademia`, applicata alle 00:35 con l'aula vuota. *(Superata la parte «una ogni venti ore» della decisione del 03/08 sul retrodatare `completed_at`: il retrodatare resta valido, il conteggio no.)*
206. **La regola sta in un helper solo, e le funzioni lo interrogano.** Viveva in **quattro copie in linea** — `_academy_prossima_lezione`, `academy_state`, `academy_complete`, `_academy_grant` — e il mandato che parlava solo di «`can_today`, `next_at` e blocco» ne avrebbe toccate tre. La superstite sarebbe stata **quella che rilascia l'attestato**: l'allievo avrebbe giocato l'intera lezione per ricevere `cooldown` all'ultimo passo. ⛔ **Scartato l'aggiornamento parallelo delle quattro:** il correttivo non è ricordarsi di allinearle, è non averne più di una. `academy_class_start` e `academy_class_join` non sono state toccate: chiamavano già l'helper.
207. **Il confine resta secco, senza pausa minima.** Chi chiude alle 05:58 può ricominciare alle 06:00. ⛔ **Scartato un pavimento di sei ore** fra due lezioni, proposto insieme alla giornata: avrebbe chiuso il varco, ma reintrodotto un secondo criterio accanto al primo — e due criteri sono il modo in cui la regola torna a vivere in due posti. Scelta del PM, consapevole.
208. **`academy_state` è stata corretta pur non essendo chiamata da nessuna pagina.** `can_today` e `next_at` sono esposti e letti da nessuno: la land mostra solo l'eccezione di `academy_class_start`. Lasciarla alle venti ore avrebbe significato tenere in produzione una risposta sbagliata in attesa del primo che la usa. Stesso ragionamento per `academy_complete`, che dal 07/08 non è più eseguibile da `authenticated`.
209. **Il messaggio d'attesa lo compone la pagina, non il server.** L'eccezione di `academy_class_start` è senza accenti (`gia`, `un altra`), come tutte le eccezioni SQL del progetto. ⛔ **Scartato il riaccentare il messaggio a database:** avrebbe allargato la migrazione a una quinta funzione per una ragione tipografica. `acadErr()` in `land.html` estrae l'ora dal messaggio e scrive la frase in italiano corretto — la **decisione** resta del server, la **resa** della pagina.

---

### Dell'08/08, notte — il cognome scelto

- **Il cognome esiste, e lo sceglie il giocatore una volta sola.** Marionettisti e personaggi senza clan possono darsi un cognome dalla scheda; dopo la scelta lo corregge solo lo staff. Scartata l'alternativa «modificabile a piacere» che un piano precedente aveva assunto: un cognome che cambia ogni settimana non e un'identita.
- **Ambito allargato ai senza clan.** Il mandato era nato sui soli Marionettisti; a database i personaggi senza cognome erano **27 su 40**, non uno. Gli altri sette clan restano fuori: per loro il cognome e il nome del clan.
- **Formato uguale al nome proprio, 2–15 lettere.** Respinto il limite di 20 caratteri proposto in origine: sarebbe stato piu lungo del nome e avrebbe raddoppiato le regole da mantenere.
- **Il cognome compare anche sui messaggi gia scritti.** Non e una migrazione dello storico: la chat legge la riga viva del personaggio e usa `messages.author_name` solo come ripiego. Per questo `post_message` non e stata toccata.
- **La correzione dello staff avviene dalla scheda, non da `admin.html`.** Un monolite in meno da riconciliare, e lo staff passa gia dal proprio ramo della guardia.
- **Il cognome non si svuota, staff compreso.** Chi puo scrivere `NULL` restituisce al giocatore una seconda prima scelta, e «una volta sola» diventa «finche qualcuno non azzera».
- **La prima assegnazione a un clan-famiglia e vietata anche allo staff.** Resta libera la correzione di un cognome gia presente: serve a chi ha scelto da senza clan ed e poi entrato in un clan.
- **Nell'intestazione della chat il clan non si stampa due volte.** Quando fa da cognome ereditato resta come solo emblema; se l'emblema manca la pastiglia si omette del tutto, perche il clan e gia leggibile dentro al nome. Scartata la prima stesura, che in mancanza di emblema teneva il testo e lasciava passare il duplicato.
- **Il rollback non elimina la colonna e la lascia murata.** La prima stesura faceva il contrario — toglieva il congelamento lasciando la colonna scrivibile da chiunque — ed e stata corretta prima dell'applicazione.

### 08/08 — l'Esame Genin diventa P0 immediato

- **Jun ha completato la sesta lezione regolare alle 10:15 ed è immediatamente idoneo all'esame.** Il controllo della giornata è deliberatamente escluso per `is_exam=true` sia all'avvio sia alla concessione finale; con l'aula di Konoha libera non esiste più margine temporale implicito.
- **Il contenimento deve censire tre porte, non due.** Oltre a `academy_class_start` e `_academy_grant` esiste `academy_complete(p_lesson)`, RPC storica `SECURITY DEFINER` oggi chiusa ad `anon` e `authenticated` per assenza di grant. DB-CORE deve prendere posizione esplicita: mantenerla chiusa o ritirarla, senza riaprirla per errore. Inoltre `academy_class_start` non verifica i prerequisiti dell'esame: può aprirlo chiunque abbia un personaggio, e il rifiuto 6/6 arriva soltanto alla concessione finale.
- **Il +15 scritto dentro `academy_complete` è un difetto separato dal gate.** Se quella RPC promuovesse, `trg_characters_grant_pool` aggiungerebbe anche i 30 corretti: totale +45. Il contenimento non deve trasformarsi in una correzione della promozione legacy.
- **I conteggi vengono dichiarati con il perimetro:** 41 personaggi totali, 39 reali; 39 Deshi totali, 38 reali. “38 Deshi reali” e “39 Deshi su 41” sono entrambi veri, ma non descrivono lo stesso insieme.
- **Le OPEN del Discovery sono quattro:** Accademia o Arena; prova individuale o classe condivisa; criteri server della classificazione; ripresa e timeout.
- **Ownership dell'audit tecniche:** owner COMBAT-CORE, reviewer DB-CORE; RULES-LORE partecipa come consulente tramite PM, non sostituisce il reviewer previsto da `AGENTS.md`.
- **La giornata UTC di `training_confirm` resta alla discovery Allenamento.** Una sola chat possiede la riconciliazione con la giornata 06:00–05:59 di Europe/Rome.

### 08/08 — piano del motore V1.1, decisioni PM prima dei candidati

- **Il nuovo esito si chiama `sfiorato`; la meccanica è lo “sfioramento”.** “Di striscio” resta riservato al colpo riuscito con margine 0–4. Nel testo narrativo il colpo *sfiora*; nei contratti e nei referti l'esito è `sfiorato`.
- **La Edge del narratore precede le migrazioni che possono produrre lo sfioramento.** Finché il narratore non conosce il terzo esito, il server non deve creare referti con `colpito=false` e danno positivo. Ogni fermata intermedia deve restare coerente per il giocatore.
- **La Sostituzione attraversa il risolutore come esito esplicito.** Il gate va cambiato insieme in `combat_dichiara_difesa` e `combat_opzioni`; `_combat_risolvi` deve ammettere `sostituzione` senza degradarla a `schivata`. Resta l'unica negazione totale: referto regolare, `colpito=false`, danno 0, narrazione del tronco.
- **La Sostituzione costa 5 chakra.** È il valore del catalogo e quello già scalato dal server; lo zero è un errore del payload di `combat_opzioni`, non una regola alternativa. Disponibilità e motivo del rifiuto devono usare il costo vero.
- **Una Sostituzione subita concede Slancio all'attaccante.** È già l'ipotesi misurata nella simulazione approvata: il colpo resta a vuoto, quindi +3 fino a +9; la Sostituzione nega il danno, non la pressione maturata.
- **Il tempo trascorso combattendo non vale come recupero.** `applica_recupero` non modifica PV/chakra durante uno scontro aperto; alla chiusura si sposta `last_regen_at` in avanti della durata individuale `closed_at - joined_at`, conservando il tempo maturato prima dell'ingresso e scartando soltanto quello passato nello scontro. Nella Test Room i valori restano comunque non lesivi.
- **La V1.1 congela una sola matematica per il duello guidato: `⌊pool/5⌋ + 2d10`.** Il pulsante legacy “⚔ Combatti” viene rimosso e non si migra. Le funzioni PNG lesive `post_combat_png`/`png_attacca_pg`, ancora su `⌊pool/10⌋ + 1d20`, restano fuori dalla V1.1 e non vanno riusate per Esame o Allenamento; il loro allineamento o ritiro è un task separato dopo il congelamento della V1.1.
- **La prossima riga libera del changelog è la 52.** La 51 sul cognome è già scritta e pubblicata.

✅ Il piano completo è stato acquisito integralmente in `management/coordination/HANDOFFS/TASK-COMBAT-V1.1-PLAN-001.md` l'08/08: dieci passi, recupero con `closed_at - joined_at`, indice su `combat_participants.user_id`, `_test_room_azzera` e ritiro del PvP legacy. La revisione 3 di acquisizione chiude D6: «Azioni di scena» conserva PG → PNG e Dispersione; nessun candidato è autorizzato da questa acquisizione.

**D6 superata nella parte UI dalla decisione sul pannello Attività.** Nessun pulsante «Azioni di scena» resta sotto la chat: Legacy R3 lo ritira insieme all'overlay. `pg_attacca_png` e `post_dispersione` restano vive lato server ma senza consumer fino al pannello unico Scontro/Allenamento/Quest; la V1.1 aggiunge soltanto Slancio e posizione alla card guidata.

### 08/08 — Discovery dell'Esame Genin, Arena e porta reale

- **L'Esame Genin si tiene in un'Arena dedicata**, dentro le tabelle e il pannello Accademia esistenti: una sala madre sempre visibile e una riserva per villaggio, attivata da `overflow_of`.
- **La prova è individuale.** Nessun candidato entra nell'esame di un altro; la classificazione è server-side (`brillante`, `solida`, `con lacune`) e non concede bonus meccanici.
- **L'esame si può ritentare gratuitamente dopo timeout**; timeout duro a tre ore, senza promozione né tentativo consumato.
- **La porta reale della chiusura IA è `academy_ai_apply` → `_academy_grant`.** Con `EXAM.ai_mode=true`, `_academy_advance_do` esce prima del ciclo premi: una guardia scritta soltanto lì sarebbe finta.
- **Il chiuditore attuale è cieco sulle classi IA:** `_academy_post` scrive con `clock_timestamp()` dopo lo `step_at` basato su `now()`, quindi il messaggio del maestro impedisce per sempre la condizione `not exists`. Il timeout dell'esame va costruito sul candidato e sui turni IA riusciti.
- **La prova applicata non viene ridotta definitivamente a narrazione.** Il motore V1 è lesivo e non accetta PNG partecipanti, quindi il simulatore resta bloccato finché il futuro pannello Attività/Scontro non ha un contratto non lesivo approvato.
- **Difetto separato:** `academy_class_start` non confronta il villaggio del personaggio con `locations.region`; il nuovo avvio dell'esame lo controllerà, mentre la correzione generale di L1–L6 resta un task distinto.
- **Contenimento P0 applicato l'08/08/2026:** Antonello ha dato il sì esplicito; la migrazione `20260808125727_exam_genin_000_contenimento` ha impostato `EXAM.is_active=false` e dichiarato il `REVOKE` su `academy_complete`. Verifica successiva: zero classi EXAM aperte, sei lezioni regolari attive, Jun ancora Deshi con valori invariati, 33 progressi, RPC client ancora eseguibili. La voce EXAM sparisce temporaneamente dal picker; la spiegazione vera resta il task LAND-UI `EXAM-GATE-COPY-001` dopo Legacy R3. Nessuna riapertura prima di `ACADEMY-COMPLETE-RETIRE-001` e del nuovo flusso approvato.

### 08/08 — il sensei che si bloccava, e quello che si ripeteva

- **Il tetto in token e quello in caratteri devono essere lo stesso vincolo.** `max_tokens: 1024` contro `MAX_CHARS = 2500` non è una svista di misura: 2.500 caratteri di italiano stanno intorno ai 950-1000 token, quindi l'API tagliava l'intervento **esattamente dove sta la nota fuori scena finale**, e il validatore puniva il maestro per un difetto dell'infrastruttura. Alzato a **1600**, con la ragione scritta nel codice perché nessuno lo riabbassi credendo di risparmiare.
- **La nota `(( … ))` si ripara, non si rigenera.** ⛔ Scartato il terzo tentativo, che era la proposta iniziale: la nota è l'unica parte dell'intervento che **non** è farina del maestro — è una riga del copione da ricopiare — quindi quando arriva accorciata o spostata non c'è niente da far riscrivere al modello, c'è da ricopiarla. Il riparo **non** interviene su un testo troncato per lunghezza, che è monco anche altrove. È l'unico punto in cui la funzione consegna testo non prodotto dal modello, e resta tracciato nel turno.
- **Il maestro ha memoria di tutta la lezione, non dell'ultimo turno.** `academy_ai_context` passava solo `last_sensei`: al passo 5 il maestro non sapeva più che cosa aveva detto al 3. Aggiunto `passi_precedenti` con il materiale dei passi conclusi, dichiarato come materiale chiuso che non si ricapitola.
- **La regola sul ciclo degli elementi è stata allentata, non rafforzata.** Diceva «ogni volta che lo enunci o lo riassumi, usa per intero le cinque coppie»: presa alla lettera trasformava ogni accenno in una recita completa, e in L2 il ciclo torna nei passi 3, 4 e 5 — così usciva per intero tre volte nella stessa lezione. Ora si enuncia **solo se il materiale di quel passo lo chiede**, e mai due volte. *(Supera in parte la decisione della v18.0 del 06/08: le cinque coppie restano intoccabili, l'obbligo di recitarle sempre no.)*
- **Le nature del chakra: il divieto è rivelare quella di un allievo, non parlarne.** La prima correzione, scritta la mattina dell'08/08, vietava al maestro di dire quante nature si possano avere: era **sbagliata nel merito** e contraddiceva la lore. Corretta la sera stessa da Antonello — una di norma, nessuna per alcuni, **due ereditate dalla famiglia**, una seconda **con gli anni**, tutte e cinque in **casi rarissimi** — e il maestro ne parla **solo a domanda**. Restano vietati i gradi, le soglie, la parola «clan» e il nome dei premi: quelli sono di fuori.
- **Il Terzo Hokage si può nominare.** ⛔ Scartato l'esempio senza nomi, che era l'alternativa più prudente. Antonello ha scelto sapendo l'effetto collaterale — dare un nome canonico invita il modello a produrne altri per analogia — e per questo il prompt lo dichiara **unico nome del passato concesso** in quel discorso, subito dopo averlo dato.
- **La regola nuova vive solo nel prompt: nessun copione è stato toccato.** ⛔ Scartato l'inserimento in L2 e in L3. Il maestro risponde quando glielo chiedono e non tira fuori l'argomento da solo, che è esattamente come la cosa è nata con Yra.
- **Il passo 6 di L2 è stato spezzato in due, senza riscrivere una parola.** Era il solo punto del corpus sopra i 1.300 caratteri, in entrambi i villaggi, e chiedeva al maestro di ri-narrare tutto quel materiale più la reazione all'allievo più la nota alla lettera dentro 2.500 caratteri. Il taglio cade su `*Si ferma sulla Tigre…*`, che era già il punto in cui il maestro cambiava argomento. ⛔ Scartata la riscrittura: il testo è di Antonello, il taglio l'ha fatto il database con `position`/`substr` e la migrazione si annullava da sola se i due pezzi non ricomponevano l'originale.
- **`academy-audit-weekly` è stato programmato.** Il gate era «dopo la migrazione e dopo la prova manuale»: entrambe fatte da giorni, e nel frattempo l'audit non girava dal 06/08 mentre un P0 approvato restava aperto e l'errore tornava in aula. Applicato `claude/academy_audit_cron.sql` verbatim, lunedì `0 4 * * 1` UTC.
- **`CAN-001` è passato ad «approvato», non a «verificato».** Verificato lo diventa quando un audit non lo ritrova: dichiararlo chiuso il giorno stesso della patch sarebbe stato dare per fatto ciò che non è stato ancora osservato.

### 08/08 — Allenamento V2: il contratto, e la revisione che l'ha stretto

- **Vince la giornata di gioco 06:00–05:59 di Roma, anche per l'allenamento.** `training_confirm` contava su `created_at::date = current_date`, cioè UTC: d'estate le due regole dissentono fra le 02:00 e le 05:59 di Roma, quattro ore ogni notte. ⛔ Scartato tenere due confini «perché uno è già scritto»: due definizioni di oggi nello stesso prodotto sono una superficie di bug.
- **Gli XP restano spesi da `training_start`, all'avvio.** ⛔ Scartato spostarli al completamento: l'unica riga esistente è già stata pagata sotto la regola vecchia, e pagare alla fine farebbe scoprire all'ultima scena di non poter permettersi la tecnica, dopo che il lavoro narrativo è stato fatto.
- **Nessuna revisione staff bloccante.** Il server misura la scena e decide; resta una segnalazione a valle, non un cancello. Con 41 personaggi e uno staff ristretto, una revisione obbligatoria sposterebbe il collo di bottiglia dal gioco alle persone.
- **La modalità è un intento dichiarato dall'utente, non un esito dedotto dal client.** `training_role_dichiara` riceve `individuale` o `cooperativa`, e alla registrazione il server verifica **quella**: se la cooperativa non regge, **non degrada in silenzio a individuale**.
- **«Almeno un'alternanza» significa almeno 3 blocchi.** `A A B B` è una consegna e non basta; serve un ritorno, come `A A B A`. Deciso dal PM in R1, e comunque parametro (`training_coop_min_blocchi`).
- **Chi aiuta non deve avere un proprio allenamento dichiarato.** Se entrambi vogliono avanzare, entrambi dichiarano e registrano la propria tecnica.
- **L'annullamento ricalcola, non decrementa.** Dopo un annullamento `sessions_done` si riconta dalle sessioni valide rimaste, e lo stato torna `attiva` solo se il totale raggiunge le richieste. ⛔ Scartato `sessions_done - 1`: annullando una sessione intermedia di una tecnica già completata avrebbe spento la tecnica sbagliata.
- **La segnalazione del testo duplicato è deterministica: `md5` del testo normalizzato.** ⛔ Scartato qualunque giudizio di qualità affidato all'IA — una soglia misurabile è contestabile, un giudizio no.
- **`trainings_required` NULL vale 1, temporaneamente, e il catalogo non si tocca.** Restano 21 tecniche acquistabili da 150–250 XP che così si imparano in una scena sola: è contenuto, e la decisione è di RULES-LORE.
- **La FK verso la role è `ON DELETE RESTRICT`, non `SET NULL`.** ⛔ `SET NULL` era incompatibile con il CHECK che impone una scena alle sessioni non-staff: cancellare una role sarebbe fallito con un `23514` su `training_sessions`, cioè con un errore che parla della tabella sbagliata. Finché esiste un allenamento nato da quella scena, la scena non si cancella — coerente con la regola che le role si chiudono, non si cancellano.
- **Lo Scontro ufficiale blocca la persona, non il luogo.** La prima stesura rifiutava l'allenamento se al luogo c'era uno scontro aperto, chiunque lo stesse combattendo. Ora si rifiuta solo se **il dichiarante** è dentro uno scontro aperto, e alla registrazione l'allenamento **non avanza** se il dichiarante o il compagno hanno partecipato al motore dentro la finestra della scena. ⛔ Scartata la semplice segnalazione: il requisito di prodotto è «scena libera, non duello ufficiale».
- **I permessi si scrivono, non si ereditano.** `REVOKE EXECUTE … FROM PUBLIC, anon` prima di ogni `GRANT`, e la verifica con `has_function_privilege` **dentro** la transazione di prova, non rimandata al postflight: i test girano come `postgres`, proprietario, e passerebbero anche senza un solo grant.
- **Il pacchetto consegnato deve essere quello provato.** A fine revisione due funzioni nei file avevano campi in più rispetto al testo realmente eseguito: sono stati tolti dai file invece di essere lasciati non provati, e la differenza è tornata al PM come domanda aperta. ⛔ Scartato consegnare la versione «più ricca ma non eseguita».
- **`_role_finalize`, `missione_iscrivi` e `missione_programma` restano fuori scope**, in `TIME-BOUNDARIES-AUDIT-001`: usano `current_date` UTC e scattano sullo stesso confine sbagliato, ma non bloccano Training V2.

### 08/08, notte — la REC appartiene a chi ha scritto, e la chiude l'ultimo

- **La presenza nel luogo non è partecipazione.** `role_start` inserisceva tutti i presenti negli ultimi otto minuti e quella riga bastava sia per la libreria sia per l'XP. È il motivo per cui Kurohasu vede una REC di Yra nella quale ha scritto zero messaggi. ⛔ Scartato continuare a usare `role_session_participants` come prova del gioco svolto.
- **Il primo messaggio pubblico con `character_id` crea il contributore reale.** Nome visualizzato, presenza e semplice apertura non bastano. La ricostruzione usa `messages` ∪ `messages_archive`, luogo e intervallo della REC, escludendo sussurri e messaggi di sistema, motore e sensei.
- **Ognuno termina se stesso; l'ultimo attivo chiude la REC.** Chi finisce prima non interrompe la scena agli altri. Se scrive di nuovo prima della chiusura torna attivo. «Ultimo» non significa ultimo online: è l'ultimo contributore reale che dichiara di aver terminato.
- **L'opener non è il proprietario dei contenuti degli altri.** Può chiudere una REC rimasta vuota, ma senza un proprio messaggio non entra nella libreria e non riceve XP. Staff e chiusura automatica a 24 ore restano porte di sicurezza.
- **La chiusura è una transazione concorrente.** L'ultimo termine e un nuovo messaggio possono arrivare insieme: il server deve bloccare la sessione e ricontrollare gli attivi, non affidarsi allo stato letto prima.
- **Lo storico si corregge senza cancellare.** Su 20 REC chiuse: 37 righe registrate, 28 contributori reali, 9 passive, zero autori reali mancanti. Le passive restano per audit ma non appartengono alla libreria. Tre hanno già ricevuto +20: Kylar, Riuji e Karasu; nessuno storno automatico, e **Riuji non si tocca**. Il PM deciderà separatamente sugli altri accrediti dopo un manifest nominativo.
- **La sequenza è DB prima, pagina dopo.** `ROLE-REC-PARTICIPANTS-001` congela contratto, backfill, rollback e concorrenza; soltanto dopo parte `ROLE-REC-UI-002`, in un turno esclusivo di `land.html` distinto da Activity Hub.

---

### 11/08 — la REC che si richiude, la giornata di gioco unica, la scheda pubblicata

- **Lo snapshot precedente si sostituisce per intero, non si conserva né si riallinea.** Su REC già chiusa `_role_finalize` torna subito e non tocca niente; su REC scongelata cancella e ricostruisce dalla fonte. ⛔ Scartato accodare: riscriverebbe due volte i turni della prima chiusura.
- **La guardia di non regressione è obbligatoria e bloccante.** Se la ricostruzione producesse meno righe di quelle che il predicato terrebbe da quello vecchio, la REC **non si chiude** e alza. Proposta d'iniziativa, approvata dal PM: resta un `raise exception`, non diventa un avviso.
- **Lo spareggio d'ordinamento su `id` vale solo come criterio secondario**, dopo l'ordine narrativo: `order by created_at asc, id asc`, mai il contrario. Serve perché dentro una transazione `now()` è costante e senza spareggio l'idempotenza non è misurabile.
- **La trascrizione e il turno valido restano due predicati distinti.** Nasce `_role_msg_scena` (esclude sussurri e `motore`); `_role_msg_valido` non si tocca. ⛔ Scartato unirli: la trascrizione deve tenere `sensei` e `sistema`, e fonderli cancellerebbe la voce del maestro dalle librerie già salvate.
- **`my_role_library` entra nello scope della correzione**, perché la Libreria è fra i posti da cui il motore deve stare fuori.
- **La giornata di gioco meccanica è una sola per tutto il progetto: 06:00:00–05:59:59 di Europe/Rome.** L'helper `_giornata_gioco` **non riscrive** il confine: si appoggia a `_academy_giorno_inizio`, che già lo definisce. ⛔ Scartato un offset fisso: sbaglierebbe con l'ora solare.
- **Il +20 XP di Kurohasu dell'08/08 non si storna.** Resta come rilievo separato **R-005-A** in `CENSIMENTO_XP.md`: è il primo doppio accredito reale trovato, ed è quello che il difetto di `current_date` produceva ogni notte fra le 02:00 e le 05:59.
- **Sopra i ~50 KB un banco si esegue da `psql`, non da una chiamata MCP.** Il testo di una chiamata lo riscrive il modello, e una divergenza dentro un `assert` non si vede: si deposita il file e lo si manda intero con `ESEGUI_IN_PRODUZIONE.sh`. Dove la chiamata è obbligata, si sigilla col sha256 del corpo.
- **`TRAINING-CLAN-REQUISITO-001` va in coda dopo Training V2 Core**, e deve proteggere **server-side tutti** i percorsi che incrementano `sessions_done`. ⛔ Scartato inserirlo adesso in una singola RPC scelta a caso.
- **`scheda_jutsu_visibilita_002` R1 è promossa e pubblicata.** La vista personale mostra il **chakra**, il Catalogo continua a mostrare l'**XP**: sono due domande diverse e devono dire cose diverse.
- **La migrazione REC non si applica insieme al banco.** Provata in produzione in `rollback` l'11/08, verificato il ritorno, e fermata lì: l'applicazione parte dal `PREFLIGHT` e richiede un via a parte.

---

### 11/08, sera — gli effetti delle tecniche: quattordici decisioni

Chiuse dal PM su `TECH-EFFECTS-AUDIT-001` in tre giri, dopo un audit in sola lettura del catalogo contro il motore. Referto in `HANDOFFS/TASK-TECH-EFFECTS-AUDIT-001.md`.

- **Gli otto tipi già nel `CHECK` di `combat_effects` sono un'ipotesi tecnica, non il vocabolario definitivo.** Non vincolano `TECH-EFFECTS-VOCAB-002`: vanno riscritti o confermati deliberatamente. La tabella esiste da tempo con quel vincolo e **non è registrata in nessun documento** — la scoperta è dell'audit.
- **Gli effetti vivranno in una tabella `technique_effects`,** non in colonne sparse sul catalogo, perché le tecniche a più effetti esistono già (*Getto Corrosivo* fa danno **e** −20 Resistenza). Con **due FK nullabili** verso `jutsu` e `clan_techniques` e un `CHECK` «esattamente uno valorizzato». ⛔ Scartata la coppia generica `source_type`/`source_id`: priva di integrità referenziale.
- **`durata` e `ricarica` diventano dati strutturati,** e i campi `text` attuali si ritirano **dopo** migrazione e verifica — ritiro in due tempi, così non esiste una finestra in cui la stessa verità sta in due posti senza che si sappia quale conta.
- **Entra `stat_mod`, senza modificare permanentemente le statistiche.** È la promessa più frequente del catalogo e nessuno degli otto tipi la esprime. La strada è quella che V1.1 ha già aperto per lo Slancio: il valore entra nel **jsonb** che `_combat_risolvi` costruisce, l'arità di `_combat_calcola` non cambia, e **mai** un `update` su `characters` — `characters_guard` lo blocca e ha ragione.
- **La ritorsione esiste:** danni in **entrambe le direzioni**, registrati nel referto. **`nega_colpo` si generalizza** e diventa un esito server valido, non un'eccezione della Sostituzione: il vocabolario progetta l'**esito canonico a quattro valori** — `colpito`, `sfiorato`, `negato`, `mancato`.
- **La compatibilità si ritira in due tempi, non in uno.** `colpito` e `striscio` restano inizialmente; **`striscio` va per primo**, dopo backfill e migrazione del narratore, perché ha **un solo lettore vivo** (`combat_narratore_context`) e **nessun consumer client**; **`colpito` resta** finché admin, pilot e Test Room non sono migrati e verificati, perché lo legge la card «Ultimo esito» di `admin.html`. ⛔ Nessuna colonna si elimina dentro `VOCAB-002`, che consegna soltanto il contratto.
- **Un referto per scambio, anche con la ritorsione.** I campi dedicati stanno **nella stessa riga** — almeno danno grezzo, danno applicato, eventuale KO, sorgente dell'effetto. ⛔ Scartata la seconda riga di referto: romperebbe conteggi, ordine, narratore e il rapporto «uno scambio = un referto».
- **Doppio KO = pareggio tecnico.** La ritorsione è **simultanea** al danno principale; se entrambi arrivano a zero nello stesso scambio **entrambi diventano `fuori`**, l'esito è doppio KO **senza vincitore**, e scritture su `pa.id` e `pd.id`, messaggio di sistema e chiusura avvengono **nella stessa transazione**.
- **Tre tecniche si disattivano invece di essere riscritte:** `Contromossa`, `Guardia di ferro` e `Infusione delle Armi`. La loro identità pretende meccaniche che non esistono, e riscriverle significherebbe inventare una tecnica diversa col loro nome. `Contromossa` è la più grave perché **danneggia** chi la gioca: dichiara «prendi metà del danno» e fa incassare **più** di una parata, allo stesso costo di zero chakra.
- **La riga 84 del §4 si riscrive:** *un bonus numerico vale soltanto se applicato e registrato dal server; indicazioni narrative, terreno e posizione non generano automaticamente `+1/+2`*. È la frase che autorizzava il catalogo a promettere, e da cui sono nate 131 promesse.
- **Disturbo dei sigilli (§4.6) e cecità del Mangekyō (§8.6) non si cancellano.** Si marcano come meccaniche **deliberate ma non ancora attive**, si raccolgono nel contratto server, e si rimuovono dalle **regole operative applicabili oggi**. Tre azioni distinte, e servono tutte tre: con la sola marcatura un giocatore le pretende, con la sola rimozione il progetto le perde.
- **La classificazione delle 131 tecniche è il primo prodotto del vocabolario,** e finché non è fatta **nessuna stima di copertura vale come requisito**.
- **Aperto `TECH-XP-LADDER-005`, in sola lettura:** **80 costi XP su 250** acquistabili sono fuori dalla scala del regolamento, che è **normativa** — `REGOLE.md` §5.2 dice D 50 · C 100 · B 150 · A 200 · S 250. ⛔ Nessuna normalizzazione automatica e nessuna modifica ai prezzi nello stesso giro.

⚠️ **Tre cose che la verifica a database ha aggiunto alle decisioni,** e che chi le esegue deve sapere prima di progettare:

- **il KO oggi si scrive solo su chi si difende** — `_combat_risolvi`, `where id = pd.id`, in due rami — quindi la ritorsione mortale non è solo tre colonne di referto;
- **la chiusura del doppio KO scatta già,** perché `_combat_avanza` chiude quando i combattenti in piedi sono `<= 1` e con un doppio KO sono zero, **ma con `closed_reason` falso**: «un solo combattente ancora in piedi» quando in piedi non c'è nessuno. E `closed_reason` **non ha `CHECK`**: è testo libero;
- **`xp_log` non ha un `technique_id`,** quindi il censimento degli acquisti storici è un accostamento **per nome**, ambiguo sulle omonimie. Da segnalare, non da correggere nello stesso giro.

---

### 12–13/08 — il cutover di `admin.html` e la disattivazione delle tre tecniche

Chiuse su `ADMIN-TECH-DELETE-GUARD-003-R1-CUTOVER` (12/08) e `TECH-CONTENT-SAFETY-002` (13/08). Referti in `HANDOFFS/TASK-ADMIN-TECH-DELETE-GUARD-003-R1-CUTOVER.md` e `HANDOFFS/TASK-TECH-CONTENT-SAFETY-002-R2-APPLICATA.md`.

- **Una patch a una pagina si costruisce sulla base pubblicata, non su `sito_live/`.** La copia di lavoro conteneva la R0 non pubblicata di `TRAINING-V2-ADMIN-006`, e pubblicarla avrebbe messo online un pannello che chiama `training_segnalate` e `training_annulla` — **due RPC che in produzione non esistono**. `sito_live/admin.html` è stato quindi **sostituito per intero** col candidato ricostruito sulla base GitHub: 282.938 → **275.272 byte**, cioè la base più i **1.030 byte** della sola guardia «Rimuovi». ⛔ Scartato il patchare in loco: avrebbe spedito online il lavoro non pubblicato di un altro task.
- **Ciò che è online si dimostra con `git hash-object`, non si assume.** GitHub espone lo SHA *blob* (sha1 di `blob <len>\0` + contenuto), non lo sha256 del file: calcolarlo in locale ha provato che il file pubblicato **era** la vecchia copia di lavoro (`c618ea5e…`), e dice che dopo il caricamento `main` deve mostrare `3d151247…`. Il repo non è un checkout git, ma questo confronto non ne ha bisogno.
- **Le tre tecniche si disattivano, non si cancellano — e la disattivazione è stata eseguita il 13/08.** `Contromossa`, `Guardia di ferro`, `Infusione delle Armi`: `is_active = false`, catalogo da **350 a 347 attive** su 355 righe. Zero possessori, zero addestramenti, zero prerequisiti, zero mantenimenti, zero dichiarazioni appese, prima e dopo. ⛔ Nessun `DELETE`: `character_abilities.technique_id` e `training_sessions.technique_id` hanno `ON DELETE CASCADE`, e cancellare porterebbe via possessori e storico.
- **L'ordine imposto dal PM è stato rispettato: prima le porte, poi la pagina, poi il dato.** Guardie RPC di `TECH-INACTIVE-RPC-GUARD-004` applicate → `admin.html` pulito e pubblicato → disattivazione. Invertirlo avrebbe lasciato scoperta la finestra in cui le tre righe sono grigie e ancora cancellabili con un clic, perché la guardia del pulsante vive nella pagina.
- **Il SQL spedito via MCP si sigilla.** Il corpo viaggia dentro la chiamata e lo riscrive il modello: è stato incapsulato in una stringa dollar-quotata e il suo **sha256 ricalcolato dal database prima dell'esecuzione**. Una battuta diversa e il blocco solleva `SIGILLO ROTTO` senza scrivere niente. ⚠️ Sigillato è il **corpo**, non il file generato che lo avvolge: l'involucro `begin`/`commit` è riscritto a mano, e va detto invece di lasciar credere il contrario.
- **Le impronte di controllo devono venire dal preflight depositato, non calcolarsi al volo.** Dentro la transazione, la firma delle altre 352 righe (`df5c84de…`) e quella dei testi delle tre (`97d31288…`) hanno combaciato con i valori scritti sul disco il giorno prima: è questo, non il confronto di un valore con sé stesso, a provare che il corpo eseguito misurava le cose giuste.
- **La disattivazione NON è registrata in `supabase_migrations`,** e il PM ha chiuso il task così. Il conteggio resta **254**, ultima `20260812143900`. Il candidato era uno script transazionale, non una migrazione; se in futuro servirà una riga in `schema_migrations` per un cambiamento di soli dati, va deciso a monte.

---

### 14–15/08 — la catena AutoStart chiusa, l'Esame Genin fermo un passo prima del database

Chiuse su `ROLE-REC-HISTORICAL-RECOVERY-009`, `ROLE-REC-AUTOSTART-006`, `ROLE-REC-AUTOSTART-UI-007`, `LAND-MESSAGGI-COMPOSER-LAYER-004`, `EXAM-GENIN-CONTRACT-ALIGN-003`, `EXAM-GENIN-AI-004`, `EXAM-GENIN-DB003-MESSAGES-PNG-005`, `EXAM-GENIN-DB003-ASSEMBLER-COVERAGE-004` e `PROJECT-STATE-ALIGN-007`. Referti nei rispettivi handoff.

- **Le role storiche si recuperano, e la registrazione arriva dopo — e si dichiarano tutte e due le ore.** `ROLE-REC-HISTORICAL-RECOVERY-009` è **applicata**: **30 REC ricostruite, 30 partecipanti, 325 righe di snapshot, 26 accrediti, 520 XP**, postflight 19/19. I dati sono entrati intorno alle **01:28 UTC** del 15/08; nessun file del candidato scriveva in `schema_migrations`, quindi il libro mastro è stato sanato **dopo**, alle **01:41:08**, con `20260815014108 · role_rec_historical_recovery_009_registrazione_tardiva`. ⛔ Scartato retrodatare la riga: una registrazione tardiva resta tardiva, e le due ore vanno dette entrambe o il verbale mente su quale finestra la produzione era priva di registro.
- **L'avvio automatico della REC va in produzione lato server, e poi in pagina.** `ROLE-REC-AUTOSTART-006` è **applicata e registrata** come `20260815090444 · role_rec_autostart_006`, dalla variante canonica `role_rec_autostart_006_dbcore_r3/`, con `role_start(uuid)` rimossa. Poi `ROLE-REC-AUTOSTART-UI-007` è stata **pubblicata** su `land.html` e **collaudata dal vivo a «Suna — Mura»**: apertura automatica al primo turno pubblico da 500 caratteri, contatore e compositore corretti, chiusura della REC e conteggio dei turni corretti. `LAND-MESSAGGI-COMPOSER-LAYER-004` è **pubblicato insieme**, dentro lo stesso file: il `#dm-overlay z-index 72 → 90` era già nella base viva ed era già stato ratificato nel cutover. **La catena `009` → `006` → `UI-007` è chiusa per intero.** ⚠️ Il collaudo è registrato come **conferma diretta del PM del 15/08**: un referto di banco non esiste, e non ne è stato inventato uno.
- **Il contratto dell'avversario d'esame passa a `R1.3`.** `EXAM-GENIN-CONTRACT-ALIGN-003` porta `EXAM-GENIN-OPPONENT-CONTRACT-002` da R1.2 a **R1.3** e allinea il riferimento in sei punti del documento. Non è una decisione nuova: è la versione viva che smette di essere citata con un numero superato.
- **`EXAM-GENIN-AI-004` è chiuso il 15/08, sulla corsa reale del modello.** Sette cancelli su sette, **18 scene su 18**, 171 token su 512, 207 caratteri su 300, somiglianza massima **0,154** contro la soglia 0,20; impronta del prompt effettivo `fd8c3b179256d95f1d3587c99703a083ca412a2e561cfe5398a9cdd8f4a66ad9`. Con `AI-UI-CONTRACT-ALIGN-006` il **§10.2 di `CONTRATTO_IA.md` è completo da 1 a 9** — le richieste 7, 8 e 9 erano approvate e già implementate, ma non erano mai state scritte — e con `PERSONAS-ALIGN-003` le Personas sono allineate alla fonte, `PROMPT_ESAME_VERSION` fermo a **1**. ⚠️ Chiuso vuol dire chiuso **come candidato**: nessuna Edge Function è stata pubblicata.
- **La battuta del PNG è un `kind` suo: `messages.kind='png'`.** Il `CHECK` `messages_kind_chk` va portato a **dieci valori**, e la scelta di come è altrettanto importante di quella di cosa: il `CHECK` è riscritto **per intero** e vive **dentro la riga di storia del Core** (`20260815160000 · exam_genin_db_003_core`), **senza migrazione autonoma**. ⛔ Scartata la migrazione a sé: si applicherebbe **prima** del Core e allargherebbe un vincolo di produzione per una funzione che ancora non esiste. Il PM ha inoltre confermato che `trg_role_autojoin` non è un blocco: le battute del PNG hanno `character_id IS NULL` e quindi non aprono né alimentano una REC.
- **Il rollback del `CHECK` è condizionale, ed è approvato così.** Al ritorno il vincolo si **riconvalida** se non esiste nessuna riga `png`; se righe storiche ci sono, si rimette `NOT VALID`. ⛔ Scartato cancellare o falsificare messaggi per far tornare il vincolo stretto: un rollback che riscrive la trascrizione è peggio del vincolo largo che si porta dietro.
- **Le revisioni duplicate dello stesso task si isolano, e non si usano più.** Dove due sessioni hanno prodotto due cartelle per la stessa revisione, **nessuna delle preesistenti è canonica**: la canonica è quella nuova, e la marcatura sta **dentro di essa** (`00_REVISIONI_SUPERATE.md`), perché il mandato vieta di scrivere nelle cartelle contese. ⚠️ Conseguenza dichiarata e non risolta: chi arriva da una cartella superata **non vede nessun cartello**; metterlo lì richiede un'autorizzazione esplicita del PM.
- **L'assemblatore di un candidato non può ridurre la copertura in silenzio.** `EXAM-GENIN-DB003-ASSEMBLER-COVERAGE-004` è approvato con due sistemazioni chieste dal PM: **copertura da 26 a 27** file (entra `prove_assembla.py`) e `SHA256SUMS.txt` **marcato come storico e non autorevole**. Il montaggio verifica l'impronta del corpo **da due lati** — l'impronta attesa, e la controprova che rigenerando il pezzo si riottiene il superstite **byte per byte**; se una salta, non monta niente. ⛔ Scartato il manifesto storico come riferimento: un elenco più corto di quello vero rende verde un montaggio incompleto.
- **Il dossier si aggiorna in un task dedicato.** `PROJECT-STATE-ALIGN-007` ha allineato memoria di progetto e handoff con **note append-only** — corpi storici intatti, prefissi provati per impronta — e ha lasciato scritto che le voci del dossier restavano non versate. ⛔ Scartato versarle dalla stessa chat: altre sessioni possono avere i file aperti, e vince l'ultima che salva.

---

## 4bis. Decisione operativa del 16/08 — SQL grande dal disco all'integrazione

**Decisione PM:** nelle sessioni future, quando una prova SQL e' troppo grande per essere
ricopiata o la connessione locale e' instabile, il file passa **direttamente dal disco** alla
chiamata Supabase nella stessa orchestrazione. Non si spezza, non si incolla nel messaggio e non si
chiede ad Antonello di fare da ponte se l'integrazione autenticata e' disponibile.

La decisione nasce dalla prova di `EXAM-GENIN-DB-003`: `20_MIGRAZIONE_PROVA.sql` pesava 127.533
byte, e il tentativo via hotspot non arrivava stabilmente al database. Il trasporto diretto ha
verificato tutti i byte nel processo, ha eseguito il file in una sola chiamata e ha raggiunto il
`ROLLBACK`; il preflight successivo e' tornato verde. I file con direttive `psql` hanno una variante
MCP generata dalla stessa sorgente o, per gli storici, una trasformazione in memoria limitata alle
sole direttive di presentazione dichiarate. Dettagli operativi in `05_CONVENZIONI.md` §18ter.

---

## 18/08/2026 — frame semantico e grammatica del Sensei in osservazione

- **Architettura ibrida approvata e applicata:** frame nel copione →
  `academy_ai_context` → prompt → validatore deterministico → telemetria.
- **`action_type` resta una fonte server:** non si duplica nel frame; si legge
  da `lesson_grants -> jutsu`.
- **La continuità è un contratto cross-step:** una dimostrazione usa la stessa
  `continuity_key` e la stessa `substitute.stable_identity` fra preparazione ed
  esecuzione. F-011 è stato corretto a aula vuota: sgabello a Konoha, sacco di
  sabbia a Suna, nessun'altra riscrittura editoriale.
- **Prima adozione limitata:** 20 passi meccanici popolati, 54 frame null. Non si
  compila il copione alla cieca.
- **La grammatica non comanda:** versione 0.5.0, `sta per raggiunger` e
  `sta per arrivar` con fixture, modalità `observation`; nessun T8, nessun
  blocco P0 e nessuna modifica a `land.html`.
- **Categorie Audit nell'ordine DB → Edge:** il CHECK e Audit v7 ammettono
  `ruolo_azione`, `ordine_azione`, `contratto_tecnica`. Nessuna auto-riscrittura
  o auto-deploy; `ACC-AUDIT-013` resta il workflow manuale separato.
- **Il cron non appartiene a questa chiusura:** il cron fermo resta
  `ACC-AUDIT-CRON-014`.
- **Rilascio:** migrazione `20260818151034 · acc_sensei_action_grammar_001`,
  Sensei v25 (`PROMPT_VERSION 23`, `FUNCTION_VERSION 23.0`) e Audit v7
  (`FUNCTION_VERSION 1.5`). Banco grammatica 18/18, regressioni 9/9, corpus
  386 testi con zero copioni accesi, postflight live verde.

## 5. Domande poste e mai risposte

**Non sono decisioni prese.** Restano aperte finché non arriva un sì o un no.

| Domanda | Da quando | Dove |
|---|---|---|
| **«Camminata sulle superfici» resta in `lesson_grants` di L3** o si toglie, visto che il jutsu è disattivato e non concede niente? | 03/08 | §4 punto 114 |
| **I due personaggi senza elemento**: si riempiono i campi, o resta la riga sul foglio che non reagisce? | 03/08 | §4 punto 115 |
| **`academy_sensei` si svuota o si rinomina?** Finché resta piena inganna chi la legge. | 03/08 | §4 punto 113 |
| **Chi scrive la voce narrante** — agente in `ai_agents` più Edge Function, o si allarga `land_help_ai`? | 02/08 | decisione 80 |
| **Come si rendono stabili `fingerprint` e `code` dell'audit**, visto che il modello riformula e la terza ricorrenza non scatta mai? | 06/08 | §4 punto 179 |
| **I tre findings non recepiti** (punteggiatura del copione citato, cancellino, gesso che batte): entrano nel prompt o si respingono? | 06/08 | §4 punto 179 |
| **I due interventi sbagliati già pubblicati** si correggono in scena con un intervento staff, o si lasciano? | 06/08 | §4 punto 181 |
| **Cosa sa un PNG del suo avversario**, e chi compila l'elenco di quello che è «visibile»? | 02/08 | decisione 81 |
| **Nelle missioni chi apre lo scontro:** il master a mano o la missione stessa? | 02/08 | decisione 82 |
| **Quanto vale il malus dell'Inuzuka senza ninken**, e l'espansione Akimichi ha un costo per round? | 02/08 | decisione 71 |
| **«Colto in azione −6» e «guardia/mira +3» si confermano** dopo aver visto un paio di scontri? | 02/08 | §4 punto 85 |
| **Come si recupera una scena scongelata**: si riportano i messaggi in chat o si riapre e basta? | 02/08 | `claude/motore_combattimento_spec.md` §8 |
| **I valori degli effetti per i nove clan** (fase 2 del motore) | 02/08 | spec §8 |
| **Il personaggio `mock` si disattiva** quando il motore è finito, o resta come bersaglio di prova? | 02/08 | `01_STATO_ATTUALE.md` §13 |
| **Il testo va normalizzato anche in scrittura**, così il database vede le virgolette dritte? Con il parser dei comandi la domanda diventa urgente. | 02/08 | §4 punto 70 |
| **Si aggiunge un controllo su `fmtBody`** al banco di prova della land? | 02/08 | §4 punto 71 |
| **`academy_sensei` va consolidata dentro `ai_agents`?** | 02/08 | §4 punto 72 |
| **Il tetto di 20 domande e la lunghezza della risposta vanno spostati in `persona`?** | 01/08 | §4 punto 47 |
| **La sezione Storia di `help_kb`**: chi scrive la cronaca che manca? | 01/08 | `01_STATO_ATTUALE.md` |
| **Il pannello Cercoteri della land passa al database** o resta su `CERC`? | 01/08 | §4 punto 49 |
| **Il compagno si vede sulla scheda di un altro giocatore?** Oggi no. | 02/08 | `01_STATO_ATTUALE.md` |
| **Si allineano le `esc()` sull'apostrofo** fra le pagine? | 02/08 | §4 punto 57 |
| **Il pannello admin avvisa che promuovendo a Genin si concedono le otto basi?** | 02/08 | §4 punto 66 |
| **La retrocessione a Deshi deve togliere le basi concesse?** Oggi no. | 02/08 | §4 punto 64 |
| **L'Occultamento entra in L4 come quarta tecnica di ninjutsu?** | 31/07 | `claude/accademia_v2_spec.md` §5.3 |
| **La giornata di gioco si allinea all'ora italiana** invece che a UTC? | 31/07 | §4 punto 39 |
| **I master devono accumulare l'XP di gioco?** | 31/07 | §4 punto 40 |
| **Le sette domande dell'Accademia v2** | 31/07 | `claude/accademia_v2_spec.md` §5 |
| **Izanagi e Izanami** vanno spostate sulla strada della richiesta? | 28/07 | handoff 28/07 |
| **La seconda natura deve essere pubblica in scheda?** | 29/07 | `04_LAVORI_APERTI.md` |
| **Il vincolo allentato sugli elementi** (punto 15) si tiene? | 29/07 | questa pagina |
| Il **bivio di stadio finale** va esteso a tutti e nove i clan? | 28/07 | `claude/stadio_finale_clan_proposta.md` |
| **Restyle della land**: Missioni in alto o a sinistra? | 21/07 | `claude/restyle_land_proposta.md` |
| Qual è il **requisito d'ingresso esatto dei Medici**? Fin dove arriva l'**anonimato ANBU**? | 22/07 | `claude/corporazioni_spec.md` |
| **I due emblemi medici mancanti** si fanno? | 30/07 | §4 punto 26 |
| **«Chi governa il villaggio ora?»** | 12/07 | `claude/accademia_L1_pronta.md` |
| Il sistema **«Eredità»**: si fa? | 17/07 | `claude/allineamento_2026-07-17.md` |
| Si aggiungono gli **Yamanaka** come decimo clan? | 12/07 | `claude/clan_bozze.md` |
| Le **tre risorse di clan** mai implementate: si realizzano? | 13/07 | `claude/clan_konoha_5_adattati.md` |
| Si fanno le **caratteristiche acquistabili**? | 28/07 | → **chiusa il 02/08 dalla decisione 85: sì, come premio a +15 per volta.** |
| Il **piano di pulizia** del report 25/07 (§6): quali fasi? | 25/07 | `claude/report_stato_progetto_2026-07-25.md` |
| **Quale clan avrà l'innata composta?** | 30/07 | `04_LAVORI_APERTI.md` |
| **I ninjutsu senza natura propria** — 103 su 118 — continuano a prendere l'elemento di chi li lancia? | 03/08 | `01_STATO_ATTUALE.md` §8 · decisione 103 |
| **Che cosa fa «Contromossa»**, ora che parare è gratis per tutti e la v1 non la usa? | 03/08 | decisione 112 |
| **Il pannello Innate / Abilità / Tecniche serve ancora**, ora che l'azione si compone nella finestra guidata? | 03/08 | decisione 78 |
| **La Dispersione è orfana** finché la lezione sui genjutsu non esiste: si lascia così? | 03/08 | decisione 94 |
| **Quando nasce la lezione sui genjutsu**, e prende il posto di quale? | 03/08 | decisione 94 |
| **La nota fuori scena `(( … ))` merita uno stile suo** in `land.html`, o resta testo semplice? | 03/08 | decisione 92 |
| **Si rende il catalogo di nuovo visibile** alla calcolatrice «Combatti» e alla Regia dentro la Test Room? Oggi filtrano `attiva` e lo perdono. | 05/08 | decisione 120 |
| **Si riallinea la numerazione di §4** fra `REGOLE.md` e `regole.html`, che differisce di uno? | 05/08 | `01_STATO_ATTUALE.md` §9 |
| **Quando si apre il motore fuori dalla stanza di prova**, e con quale coppia di giocatori? | 05/08 | `04_LAVORI_APERTI.md` |

> **Chiuse il 31/07:** «L'Acqua di grado B è un'onda o un muro?» → **onda**. «Parata e Contrattacco sono reazioni?» → **no**. «Il Colpo caricato resta?» → **sì**. «Il minimo di 500 caratteri lo impone il server?» → **sì**. «Il badge conta anche le risposte?» → **no**. «I danni devono essere multipli di 5?» → **no**.
>
> **Chiuse il 01/08:** come si naviga la sezione Jutsu · cosa mostra la riga chiusa · il dettaglio non si accorcia · il chatbot pesca da una tabella · venti domande al giorno · il bot è un agente di `ai_agents` · in admin entrano le voci e la prova.
>
> **Chiuse il 02/08:** le abilità della taglia leggendaria (**ereditate**) · come si divide la sezione Abilità (**famiglia, poi taglie**) · cosa contano i contatori del Codice (**le voci visibili**) · chi ha il contratto senza Richiamo (**vede la linguetta**) · il nome della linguetta (**Compagno PNG**) · dove vivono i clan con PNG (**costante in pagina**).
>
> **Chiuse il 02/08 sera (seconda chat):** le due voci orfane dell'Accademia · il passaggio a Genin · dove stanno i Premi in scheda · i nomi della scala del Richiamo.
>
> **Chiuse il 02/08 notte (terza chat):** dove correggere le virgolette curve (**nel rendering**) · gli apostrofi curvi (**non si toccano**) · `« »` e `< >` (**restano come sono**).
>
> **Chiuse il 02/08 sera (quarta chat):** cosa fa la chat di prova coi valori (**calcola e dice, non applica**) · chi ci entra (**solo staff**) · come si pulisce (**cron ogni ora più un pulsante**) · come si entra in uno scontro (**si apre e chi vuole entra**) · quanto costa accendere l'innata (**l'azione principale**) · cosa succede alle innate a fine scontro (**si spengono tutte**) · come si abbinano i due turni (**A dichiara, B difende, si risolve la coppia**) · cosa può scegliere chi difende (**solo tecniche col tag difensivo**) · gli elementi nel confronto (**±2**) · le scene bloccate (**si registrano e si scongelano**) · lo spostamento del difensore (**vale dopo**) · Akimichi e Inuzuka (**doppio binario**) · il terzo personaggio (**partecipante fuori dai calcoli**) · le distanze (**reali, in metri**) · da che distanza si comincia (**la dichiara chi apre, o il fato**) · le 89 tecniche senza classificazione (**regola automatica, poi si corregge dal pannello**).
>
> **Chiuse il 02/08 notte (quarta chat):** come si dichiara un'azione (**si scrive il turno, comandi fra quadre**) · quando parla il motore (**a fine round, una volta sola**) · quando si valida (**alla fine, non mentre si scrive**) · dove sta il pannello delle tecniche (**sotto la casella di scrittura**) · cosa si vede sempre (**«Round N · stai attaccando»**) · la Sostituzione (**resta una tecnica, col blocco di due turni**) · chi racconta l'esito (**una voce narrante, senza mai i numeri di scheda**) · cosa sa un PNG (**solo quello che vedrebbe**) · la risoluzione simultanea (**scartata**) · quanti punti dà una promozione (**60/90/120/150/170/200 cumulati**) · la terza specializzazione (**si compra, +15 a 200·n XP**) · il pool ripetuto (**una volta sola per gradino**).
>
> **Chiuse il 03/08:** `[Fine]` diventa un comando vero? → **no**, resta una convenzione dei giocatori, ignorata dal motore e **visibile** in scena. La voce «Parata» del catalogo? → **rinominata «Contromossa»**.
>
> **Chiuse il 04-05/08:** i comandi fra quadre restano visibili nel testo? → **la domanda decade**: durante uno scontro le quadre sono **testo libero** e l'azione si compone nella finestra guidata; il parser resta scorciatoia dello staff. Che cosa diventa la Contromossa? → **non è in vigore nella v1**. Si impone il tetto di 65 danni? → **sì**, dal 05/08 lo impone il server.


> **Chiuse l'11/08 (Combat V1.1).** Si applica a meta' duello? → **no**: lo scontro aperto con Riuji e' stato chiuso **dal pannello**, conservando referti e storico, e solo dopo si e' applicato. La colonna `esito` sul referto? → **rinviata**: si conserva `striscio` e l'esito si **deriva in lettura**, finche' tutti gli scrittori — `test_room_scenario` compreso — non potranno essere aggiornati insieme. Quarto parametro di `combat_dichiara_difesa`? → **approvato** `p_posizione integer default null`, con censimento dei due soli chiamanti server-side. In che ordine si rilascia? → **prima la Edge v3 del narratore, poi la migrazione**: con la voce vecchia il narratore avrebbe raccontato «non arriva» su un colpo che toglie PV. Rispettato: v3 in aria alle 09:31:25, migrazione alle 09:32:36. Il ramo PNG si ritira insieme? → **no**: `post_combat` si revoca ad `authenticated`, le RPC PNG restano **congelate e vive** perche' servono a Regia, Esame e Attivita'. Il collaudo live lo fanno due utenti veri? → **in parte**: su indicazione di Antonello e' stato eseguito lato server dalla porta vera `combat_azione` in `rollback`; **il livello browser resta da vedere in pagina**. L'allontanamento della Sostituzione schiacciato al bordo del campo e' un difetto? → **osservazione, non difetto**: `combat_muovi` fa lo stesso da sempre, la V1.1 ci aggiunge solo il costo in chakra. Nessuna correzione preparata.

---

## 17/08/2026 — Guardia ritirata, Moltiplicazione e continuità dell'Esame

Queste decisioni sono già consumate dal server e vengono registrate in ritardo, senza cambiare
le sezioni storiche sopra.

- **La Guardia non è più una meccanica.** La parola resta lecita nella prosa italiana, ma non
  esiste più come scelta o bonus di gioco.
- **Moltiplicazione ha due momenti distinti.** Come Diversivo è un'azione principale senza danno
  che riposiziona; le copie rimaste possono poi essere usate come reazione al primo attacco
  diretto. Il server, non il modello, decide se viene colpita una copia o l'originale.
- **Il lato nuovo riceve il proprio mezzo turno.** La principale spesa dal Diversivo appartiene
  al lato che l'ha usata e non può bloccare quello successivo; la non cumulabilità resta legata
  allo scambio.
- **Uno stato senza principale legale non resta incastrato.** Nell'Esame il server offre
  «Chiudere la misura» soltanto quando nessuna principale può diventare legale dopo il massimo
  avvicinamento e non esiste un Diversivo giocabile. La manovra passa il turno senza attacco,
  danno o falso scambio.
- **Il PNG non decide numeri.** `exam_genin_ai` v2 e `combat_narratore_ai` v5 ricevono etichette
  chiuse; distanza, danno, margine, esito delle copie e autorizzazioni restano al server.
- **La prova giocata vale come gate funzionale, non come gate del modello.** PLAYTEST-029 R3 ha
  osservato entrambe le uscite delle copie e la manovra, con ripristino esatto; il gate reale da
  22 scene resta separato e non risulta eseguito.
- **Il rilascio statico è atomico per dipendenza.** LAND-032, ADMIN-027 e RULES-033 sono pronti,
  ma restano non pubblicati finché il caricamento manuale e il controllo visibile non sono fatti.
- **Il repertorio linguistico condiviso viene dopo.** `AI-LINGUA-NARRAZIONE-CORE-018 R2` non si
  apre nel mezzo di questa chiusura: deve partire dalla superficie ormai stabilizzata.

---

## 20/08/2026 — voce narrativa 066 R2 chiusa come candidato, non come rilascio

- Il candidato canonico è
  `management/candidati/exam_genin_voce_narrativa_066_r2_edge_a1/`; la revisione
  A1 precedente resta storica e non si usa.
- OPEN-067-9 e OPEN-067-10 sono chiusi dal decision pack congelato e verificati
  dai banchi del candidato: `finestre` è ammesso solo quando autorizzato dal
  payload e le misure sono confrontate con i rispettivi campi server-authoritative.
- La review PM del consumer apertura è chiusa sul perimetro isolato. Le due corse
  complete fanno **253/253** ciascuna, senza rossi.
- Il campione editoriale minimo è fissato a otto esempi: quattro aperture sulle
  sale ratificate e quattro cicli — attacco, difesa, spostamento, tecnica. Gli
  esempi depositati sono produzioni Codex isolate, **non** output del modello o
  del runtime reale.
- La chiusura non autorizza produzione: EXAM resta `is_active=false`, con
  `apertura_abilitata=false` e `INCIPIT_ABILITATO=false`. Contratto 067 R2,
  deploy Edge/statico, migrazioni, DB apply, commit e push restano fuori scope.
- Il gate del modello/runtime reale e l'end-to-end Deno/Supabase restano una fase
  futura separata; non riaprono il task 066 R2 appena chiuso.

---

## 20/08/2026 — apertura della Test Room agli utenti, mock e quota IA

- **La Test Room diventa anche una sandbox per gli utenti.** Supera la decisione 53 del 02/08
  soltanto per il nuovo percorso pubblico non lesivo; scorciatoie, catalogo e pulizia globale
  dello staff restano riservati.
- **La prova utente non ha una modalità reale.** Nessun valore, risorsa, progresso, effetto,
  cooldown, role o statistica del personaggio può cambiare.
- **Il bersaglio è il Manichino mock risolto dal server.** Il client non sceglie UUID, statistiche
  o numeri. Due utenti devono poter provare contemporaneamente in sessioni isolate.
- **L'utente prova soltanto tecniche possedute e realmente disponibili.** L'intero catalogo resta
  una deroga staff; una sua eventuale apertura richiede una decisione nuova.
- **La narrazione IA è facoltativa e manuale.** L'esito meccanico esiste anche senza modello e i
  referti `is_test` non entrano automaticamente nel cron.
- **Il limite è cinque dispatch IA per account e giornata di gioco 06:00–05:59 Europe/Rome.**
  Prenotazione atomica server-side, doppio clic idempotente, sesta richiesta rifiutata prima della
  chiamata esterna; un fallimento successivo al dispatch consuma il gettone.
- **I candidati Test Room 001/002 restano congelati e non applicati.** Il nuovo lavoro li audita,
  non li applica per dipendenza e non espone agli utenti la loro modalità “reale”.
- **Il mandato è `TASK-TEST-ROOM-UTENTI-MOCK-AI-068`.** Sono autorizzati discovery e candidati;
  produzione, migrazioni, Edge e pubblicazione richiedono un nuovo via esplicito.

---

## 20/08/2026 — decisioni QA dell'Esame Genin con Riuji

- **La prosa del Narratore deve essere visivamente compatta.** Non basta togliere
  le righe vuote: i ritorni a capo inseriti fra frasi, descrizione, battuta e
  transizione non devono spezzare il testo in righe artificiali. Il testo scorre
  come un paragrafo e va a capo soltanto per la larghezza della colonna; etichette
  e colore del parlato restano marcatori, non spazi verticali. Il candidato 072
  attuale non soddisfa ancora questa resa e non è ratificato per il caricamento.
- **L'Esame dura al massimo quattro round, oppure termina prima per KO.** La
  chiusura automatica al terzo scambio è superata. Non è una prova illimitata.
- **La pulizia automatica rispetta la prova aperta.** È ratificata l'opzione A
  del decision pack 073: nessun messaggio della location viene cancellato
  mentre vi è collegata una `esame_prove.stato='aperta'`; dopo la conclusione o
  l'annullamento riprende la retention ordinaria.
- **Anche lo svuotamento manuale è fail-closed.** Il comando staff non può
  cancellare la sala durante una prova aperta; un'eventuale deroga futura
  richiederà una decisione separata e visibile.
- **Prova aperta oltre 24 ore: solo avviso.** Nessuna chiusura e nessuna
  cancellazione automatica; lo staff interviene tramite il percorso autoritativo.
- **Il payload delle mosse riceverà un motivo strutturato.** Gittata, chakra,
  azione già spesa e vincolo dell'Esame non dovranno più essere distinti dal
  client interpretando la prosa di `motivo_no`.
- **Il rilascio resta chiuso agli utenti.** Nessun deploy o apertura generale
  prima della conferma finale di Antonello dopo il QA completo.

### Applicazione QA autorizzata nello stesso giorno

- `20260820131359 exam_genin_recovery_round4_074`: impedisce al timeout generico
  dell'Accademia di chiudere l'aula mentre la prova è aperta, porta il motore a
  quattro round o KO e recupera la stessa prova di Riuji senza duplicarla.
- `20260820131911 exam_genin_riuji_kazane_cleanup_075`: riallinea la prova
  ancora intatta al profilo ratificato di Kazane, ripristina una sola volta
  l'incipit approvato e protegge la cronologia sia dal cron sia dallo
  svuotamento manuale durante la prova aperta.
- Il recupero lascia Riuji Deshi, Round 1, attacco, distanza cinque metri e zero
  azioni consumate. `EXAM.is_active=false`; nessun deploy statico o Edge.
- **Le tecniche accademiche non seguono una scaletta obbligata di round.** La
  migrazione `exam_genin_tecniche_round1_076`, autorizzata durante il QA, rende
  disponibili dal primo round Moltiplicazione, le principali accademiche e la
  Sostituzione. Trasformazione usa una corsia di scena: consuma azione principale
  e chakra simulato, non infligge danno e passa il turno al PNG.
- **Le copie del Diversivo persistono fino all'azione successiva, salvo essere
  colpite.** Le modalità definitive restano tre — Diversivo, Copertura e Assalto —
  ma il riallineamento completo e la scelta facoltativa della posizione del corpo
  reale sono rinviati; la 076 conserva temporaneamente il Diversivo già vivo.
- **Moltiplicazione è una sola prima scelta.** La migrazione
  `exam_genin_moltiplicazione_modalita_077` e il candidato LAND omonimo aprono
  soltanto dopo le tre modalità Diversivo, Copertura e Assalto, quindi il numero
  di copie; Diversivo chiede anche la direzione. La posizione del reale resta
  rinviata e, nel frattempo, la decide privatamente il server.
- **Possesso e uso in scontro sono due cose diverse.** Occultamento,
  Liberazione dalle corde e Trasformazione restano nella scheda ma non compaiono
  nel pannello combattimento. Dispersione non è un attacco: il server la offre e
  la accetta come reazione soltanto se il pending è un Genjutsu; contro un colpo
  fisico, un ninjutsu o un gruppo misto resta fuori.
- **Moltiplicazione espone un solo costo e un solo controllo dell'originale.** Il
  costo autoritativo è 10 chakra di base + 5 per copia: quando Riuji può creare
  una sola copia, il pannello la assume senza chiedere la quantità e mostra il
  totale 15 una volta sola. Nell'Assalto il giocatore sceglie privatamente
  l'originale con un unico numero da 1 a copie + 1; non esistono più controlli
  separati «Figura 1/Figura 2». La posizione fisica delle figure resta rinviata.
- **La turnazione narrativa dell'Esame è una coppia di battute compiute.** Dopo
  l'offensiva del candidato, una sola azione del Narratore contiene difesa del
  PNG, esito dell'attacco e nuova offensiva del PNG; dopo la difesa del
  candidato, una sola azione racconta il risultato e gli restituisce
  l'iniziativa. Niente etichette `AZIONE/ESITO`, niente frammenti e niente
  seconda descrizione della difesa dentro il turno offensivo del PNG.

### 21/08/2026 — chiusura operativa dello switch Luna del Narratore combat

È stato autorizzato e completato il passaggio controllato del candidato
`AI-NARRATOR-HAIKU-LUNA-046-A2` nella Edge Function `combat_narratore_ai`.
La versione viva verificata è la **8 ACTIVE**, con `index.ts` e
`adattatore.ts`, `verify_jwt=false` invariato, braccio unico
`openai_luna_high`, `gpt-5.6-luna`, `reasoning.effort: "high"` e tetto combat
1800. Antonello ha configurato `OPENAI_API_KEY` nei Secrets della funzione.

Il passaggio non ha richiesto modifiche al database o al frontend. La misura
reale del modello resta un gate separato: nessun `reasoning_tokens`,
`stop_reason`, costo o comportamento osservabile viene dedotto dal proxy a
secco. EXAM resta inattivo e la prova aperta non è stata toccata.


## 23/08/2026 — l'Esame Genin apre agli utenti, e la cartella viene pulita davvero

- **L'Esame Genin è ufficialmente aperto agli utenti.** `EXAM.is_active=true` e `ai_mode=true` sono intenzionali. Il QA reale prosegue **in parallelo** sull'Esame vivo per trovare difetti e migliorare il modello, e **non blocca l'apertura**; il QA qualitativo nemmeno. L'Esame si sospende **solo per difetti critici**: autorizzazioni, promozione/premi, perdita di risorse reali, corruzione dello stato, impossibilità di proseguire o concludere.
- **La prova di Jun è stata annullata dopo il fix** (è fra le 40 righe `annullata` di `esame_prove`; al 23/08 sera i totali sono 40 annullate · 6 concluse · 1 aperta).
- **Pulizia di `_to_delete/` eseguita col mandato `PROJECT-CLEANUP-STATE-ALIGN-001`.** Gruppo E (snapshot pre-modifica di `role_rec_participants_001`, 17 file) conservato in `management/candidati/role_rec_participants_001/_pre_salvataggio/`; gruppi A, B, D e gli 894 duplicati riconfermati via SHA-256 raccolti nel contenitore `_to_delete/theuntoldstory_to_delete_20260823/` (1.122 file), **da trascinare nel Cestino senza svuotarlo** — il ponte non raggiunge il Cestino di macOS e non può cancellare, quindi il trascinamento finale è di Antonello. **Il gruppo C non si elimina:** la verifica completa archivio per archivio ha dato **11 OK e 55 KO su 66** — spesso per un solo file su decine, perché le cartelle estratte sono evolute dopo la consegna — e il mandato imponeva 66/66; resta in `_to_delete/_c_non_verificati/`. Manifesto con decisioni, esiti e referto: `archivio/00_MANIFESTO_ELIMINAZIONE_20260823.md`.
- **Il consolidamento dei candidati resta riservato a `EXAM-GENIN-CANONICAL-CONSOLIDATION-096-A1`**, da eseguire solo dopo il QA completo dell'Esame. La pulizia di oggi non lo anticipa.
- Constatazioni di contorno, verificate: il dominio serve `LAND-108-A1` mentre `sito_live/land.html` è a `LAND-083-A1` (riconciliazione futura); gli handoff sono 337; la cartella non è un repository Git — vale la guardia `mtime` del ponte, non un versionamento.

### Aggiunta del 23/08, pomeriggio — il contenitore è nel Cestino

Antonello ha completato **manualmente** il passaggio finale: il contenitore
`theuntoldstory_to_delete_20260823/` (1.122 file) è stato **spostato nel Cestino
di macOS, senza svuotarlo** — l'eliminazione resta recuperabile. Verificato sul
disco: il contenitore non è più nel workspace; in `_to_delete/` restano soltanto
i **66 archivi del gruppo C** in `_c_non_verificati/` (più il `.DS_Store` che
Finder rigenera da solo, che non appartiene al gruppo C), **rinviati al
programma `EXAM-GENIN-CANONICAL-CONSOLIDATION-096-A1`**. Conferma registrata
anche nel manifesto in `archivio/`.

## 24/08/2026 — il Fato manuale viene separato dal motore Master V2 e va LIVE

- Per rendere subito possibile una giocata narrata da un umano è stato
  rilasciato un verticale editoriale autonomo: il toggle PG/Fato non apre una
  quest, non avvia uno scontro e non calcola esiti.
- L'autorizzazione è server-side tramite `is_staff()`. La chat espone soltanto
  `kind='fato'` e autore `Fato`; l'identità reale resta nell'audit riservato.
  Non si riusa `kind='sistema'`, così narrazione umana e automazioni restano
  distinguibili.
- Il messaggio Fato non apre una REC e non porta valori meccanici dal client.
  Motore multi-attore, PNG, valutazione qualitativa, quest e Master IA restano
  nello sviluppo Master V2 separato.
- `FATO-MANUAL-MVP-007` è LIVE/VERIFIED/COMPLETE. Il dominio e
  `sito_live/land.html` condividono la build
  `LAND-121-A1-FATO-MANUAL-MVP-007`; il deposito sotto `candidati/` è conservato
  come archivio di release.

## 24/08/2026 UTC — fix causale minimo del fallback finale dell'Esame

- Antonello autorizza esplicitamente l'applicazione DB del solo candidato
  `EXAM-GENIN-FALLBACK-FINALE-CAUSALE-121-A1`.
- La migrazione viene applicata e registrata come
  `20260824134438 · exam_genin_fallback_finale_causale_121_a1` dopo il match
  esatto delle tre impronte e del registro.
- La decisione è deliberatamente stretta: estendere il helper alle consegne
  future censite e applicarlo al testo base del solo `png_finale`; nessun cambio
  a resolver, turnazione, danni, risorse, prova, promozione, coprifronte o
  `png_esito`.
- Postflight firme/ACL/definizioni verde; banco live 22/22 e QA offline 12/12;
  impronte aggregate meccaniche identiche. Nessun rollback necessario, nessun
  deploy Edge/statico e nessuna chiamata modello.

## 25/08/2026 — realizzatore di superficie vincolato

- Antonello sceglie l'alternativa **B** dopo il NO-GO qualitativo del QA 131:
  il piano atomico 128 resta autoritativo, ma la resa narrativa può contenere
  prosa libera entro fatti, ancoraggi e permessi offerti dal server.
- Il modello può scrivere soltanto narrazione e voce del PNG. Non può parlare
  per il PG, decidere meccaniche, turni, risorse, finali o promozioni.
- Il campione Jun/Kotoha con reazione fisica, risposta personale e attacco
  descritto per traiettoria e bersaglio viene approvato come qualità-obiettivo.
- Il contratto `AI-NARRATIVE-SURFACE-REALIZER-CONTRACT-131B-A1` viene chiuso
  offline con 26/26 controlli. Implementazione, provider, DB, Edge e canary
  restano passaggi distinti e richiedono i rispettivi gate.

## 25/08/2026 — confine tecnico del Surface Core 131C

- Storico testuale per similarità e componenti deterministiche di turno/finale
  restano input fidati dell'adapter, fuori dal contesto consegnato al modello.
- Nessuna soglia di similarità viene assunta dal runtime: quando lo storico è
  presente la soglia deve essere esplicita e sarà calibrata nel QA 131F.
- Il core 131C è chiuso soltanto come candidato offline; producer, provider,
  DB, Edge e canary conservano gate separati.

## 25/08/2026 — seed autoritativo Exam 131D

- Il producer legge l'azione PG soltanto dal messaggio `say` legato a utente,
  personaggio, luogo e ciclo della prova; non legge background, whisper o
  cronologia generale.
- Il limite di 5.000 caratteri è atomico: il testo entro soglia resta intero,
  quello oltre soglia viene rifiutato e non troncato.
- La persona deriva dai campi strutturati vivi di `ai_agents.persona`; storico,
  mappa intenzione/esiti e componenti deterministiche restano fuori modello.
- Il seed conserva branche eterogenee per intenzione. L'adapter 131E deve
  imporre questa relazione prima del canary; DB e Edge restano non applicati.

## 25/08/2026 — autorità editoriale Ninja Book 027A

- Antonello sceglie l'opzione **B**: `master` e `admin` possono preparare,
  aggiornare e inviare in review le bozze Ninja Book.
- Soltanto il ruolo esatto `admin` può approvare template, pool e atomi,
  ratificare archi e memorie e disattivare o supersedere contenuti già
  approvati o ratificati.
- Il controllo resta server-side e fail-closed; non nasce un nuovo ruolo o
  sistema ACL editoriale. La decisione autorizza la progettazione offline
  027A, non un apply, una pagina o contenuti reali.

## 25/08/2026 — eccezione Advisor per le 11 RPC editoriali 027A

- Dopo l'apply 027A il Security Advisor segnala 11 WARN
  `authenticated_security_definer_function_executable`, uno per RPC editoriale
  intenzionalmente disponibile via Data API.
- Antonello sceglie l'opzione **A** e accetta il rischio come compensato: ogni
  porta verifica staff prima di accedere al Book; le transizioni canoniche sono
  admin-only; `PUBLIC`, `anon` e `service_role` sono revocati; tabelle e helper
  restano chiusi; le prove ruoli sono verdi.
- L'eccezione è nominativa per queste 11 RPC e non autorizza automaticamente
  future funzioni `SECURITY DEFINER`. Nessun rollback; 027B e canary restano
  gate separati.

## 26/08/2026 — Gate 028 positivo differito, apertura 029 offline

- Dopo R10 STOP CLEAN per mancato handoff del marker `LOGIN NOW`, Antonello
  decide di non ripetere il ciclo di promozione Tamako e di passare al gate
  successivo.
- Il canary positivo first/replay resta non eseguito e non viene dichiarato
  verde. Le prove offline, i controlli fail-closed, i cleanup live e il
  postflight sicuro restano acquisiti.
- L'eccezione autorizza soltanto 029 offline: un primo PNG completo e una
  missione test non attiva. Non autorizza caricamento DB, missione reale,
  modello live, modifica Master/Combat V2 o comunicazione anticipata a Master.
- Un futuro caricamento o uso live dovrà registrare esplicitamente il debito
  del canary 028 e ricevere autorizzazione separata.

## 26/08/2026 — identità visiva dinamica dei PNG Ninja Book

- Ogni PNG può avere immagini generate coerenti con il linguaggio visivo della
  Land, ma l'identità resta stabile attraverso un ritratto canonico e invarianti
  visuali approvati.
- La prima versione usa varianti curate e versionate per scena o stato emotivo,
  selezionate senza ripetizioni ravvicinate. Non usa generazione libera a ogni
  messaggio.
- Asset e contenuto narrativo restano separati. Prompt, selezione e immagini
  ricevono soltanto stato autorizzato e non possono anticipare informazioni
  narrative non sbloccate.
- Generazione, caricamento Storage, schema media e integrazione Land restano
  task separate e richiedono review e autorizzazioni proprie.
- Antonello sceglie Adobe Firefly come generatore preferito, usando una
  sessione umana autenticata nel sito via Chrome. Nessuna credenziale viene
  consegnata al progetto e non si presume accesso alle API Firefly Services.
- Miyo resta civile. La resa approvata è una figura intera verticale, non un
  ritratto; i quattro Sensei caricati sono riferimenti primari di composizione
  e linguaggio anime/manga, mentre i profili PG Land sono soltanto controllo di
  compatibilità generale.
- I riferimenti non autorizzano copie di identità, uniformi, simboli o
  personaggi riconoscibili. Gli asset nuovi devono essere originali, senza
  marchi o emblemi di opere terze, pur restando coerenti con il mondo ninja
  illustrato della Land.
- La V1 associa a ogni PNG **una sola immagine canonica** come contesto fisico
  stabile per l'IA. Emozioni, ferite temporanee, pose e condizioni della scena
  restano stato narrativo autorizzato e non producono varianti grafiche.
- Una nuova versione visiva è ammessa soltanto per un PNG persistente di trama
  quando un cambiamento fisico significativo, durevole e ratificato entra
  nella continuità da ricordare. Il vecchio asset resta storico/superseded.

## 26/08/2026 — autorizzazione caricamento live bozza Miyo 029C

- Antonello autorizza il solo caricamento immutabile del canonico Miyo e la
  creazione del template/versione in stato draft e inattivo.
- Restano offline e non autorizzati missione, pool, atomi, condizioni,
  destinatari, scena, memoria e relazioni; restano vietate approvazione,
  attivazione, pubblicazione e collegamenti consumer.
- La task operativa è `NINJA-BOOK-FIRST-NPC-029C-DRAFT-LOAD-LIVE`, thread
  `01a03d98-28e6-7d53-877c-2c311594ca9d`; deve fermarsi prima della review e
  dell'approvazione.
- La 029C termina STOP CLEAN prima dell'upload: Storage restituisce assenza
  come `HTTP 400` con corpo `statusCode=404/NoSuchKey`, non come HTTP 404 puro.
  Il runner non viene adattato né rilanciato; una correzione offline risigillata
  e un successivo retry live richiedono gate e autorizzazioni distinti.
- Antonello autorizza il primo di questi gate: 029D esclusivamente offline per
  correggere la guardia Storage, provarne le inversioni e risigillare. Nessun
  retry live è incluso nell'autorizzazione.
- La 029D chiude verde con guardia stretta, banco 55/55 e manifesto 17/17. Sono
  ammesse soltanto HTTP 404 puro o HTTP 400 con la combinazione completa
  `statusCode=404`, `NoSuchKey`, `not_found` e path esatto; il live resta vuoto.
  Alla chiusura della 029D il retry 029E rimaneva una decisione separata non
  ancora autorizzata.
- Antonello autorizza 029E: un solo retry live byte-esatto del candidato 029D,
  limitato ad asset canonico e template/versione Miyo draft e inattivi. Non
  autorizza contenuto narrativo, approvazione, attivazione o missione.
- La 029E termina STOP CLEAN prima dell'upload perché non viene fornito input
  umano staff; nessun login o runner. Antonello sceglie quindi l'account unico
  `testperfunzioni`, verificato `player` e senza sessioni vive, e autorizza la
  promozione temporanea nominativa a `master` nella task 029F. Il ripristino a
  `player` è obbligatorio dopo il successivo ciclo; login e retry restano gate
  separati.
- La 029F chiude verde: dopo cleanup Auth nominativo autorizzato nella task,
  `testperfunzioni` è l'unico profilo modificato ed è `master`, completamente
  disconnesso. Il prossimo gate deve includere login umano, unico retry Miyo e
  ritorno condizionato a `player`, anche in caso di arresto dopo il login.
- Una nuova esecuzione autorizzata nella task 029E supera il precedente STOP
  CLEAN: asset, template e versione Miyo sono live 1/1 come draft inattivo,
  senza missione, approvazione, consumer o superfici narrative. Il manifesto
  aggiornato è 52/52. La sessione test è chiusa, ma il ruolo
  `testperfunzioni=master` non è stato ripristinato: la demozione nominativa
  resta un cleanup separato da autorizzare prima della review.
- Antonello decide successivamente di mantenere `testperfunzioni` nel ruolo
  `master` come account tecnico di prova. La demozione non è più un gate per la
  review. L'account resta disconnesso; il ruolo non amplia i poteri ratificati:
  può lavorare sulle bozze e inviarle in review, mentre approvazione,
  attivazione e disattivazione canonica restano esclusivamente admin-only.

## 26/08/2026 — Il nodo azzurro diventa missione test multi-PNG 2v2

- Miyo resta un PNG civile: richiedente/testimone e interlocutrice nelle scene
  narrative, mai antagonista o iniziatrice dello scontro.
- La missione deve provare due PG contro due banditi PNG distinti. Servono due
  nuove bozze narrative separate; i banditi possono condividere il medesimo
  template meccanico Genin-base, senza jutsu particolari, ma non memoria,
  identità, voce, stato combattimento o target.
- La vittoria dei PG è obbligatoria perché il run serve a collaudare flusso
  multi-personaggio, IA e regia Master, non il bilanciamento. La garanzia è
  server-side e test-only; niente XP, Ryo, danni o conseguenze persistenti.
- Il modello racconta e propone comportamento entro le opzioni consentite; il
  server decide turni, bersagli, effetti e fail-safe. IA e Master ricevono lo
  stesso stato meccanico autoritativo.
- Restano da decidere in una task offline: nomi/aspetto/voce dei banditi, grado
  formale, luogo/villaggio, motivo e soluzione, soglia di resa/fuga e percorso
  esatto di chiusura. Nessun caricamento o collegamento Master è autorizzato.
- Antonello fissa poi il grado **D** e precisa la funzione del test: la prima
  scena deve valutare qualitativamente dialogo PG↔Miyo, interazione PG↔ambiente
  e lettura della scena da parte dell'IA. Gli indizi non sono consegnati tutti
  insieme; le abilità narrative reali possono sbloccare ritrovamenti semplici,
  ma devono esistere percorsi alternativi tramite ragionamento e azioni
  esplicite. Solo dopo si raggiungono i banditi con la refurtiva e il 2v2.
- La task 029G è autorizzata esclusivamente offline per preparare lo scheletro
  completo e il piano dei gate; nessun DB, missione, consumer o Master live.
- La 029G chiude verde offline con Miyo raffinata, clue graph e due banditi
  distinti proposti: Kado Rensu e Yori Tsuba. L'inventario vivo conferma che
  solo Mente copre percezione/analisi; non esistono skill Investigazione o
  Percezione. Restano decisioni PM su luogo e fail-safe e fondazioni separate
  DB/Combat per lifecycle test-only, resolver Mente e Genin-base.
- Antonello approva il blocco proposto: nomi Kado Rensu e Yori Tsuba, scenario
  simulato in Test Room senza villaggio, `max_rounds=4`, floor non letale a
  1 PV simulato, Kado si arrende al cap e la fuga di Yori risulta già fallita
  meccanicamente prima della narrazione. La decisione non autorizza apply,
  caricamenti, consumer o modifiche Master/Combat.
- La 029H genera in Adobe Firefly e sigilla offline un unico master canonico
  896×1152 per ciascun bandito. Kado conserva massa, posa frontale e palette
  ruggine; Yori conserva silhouette asciutta, posa laterale e palette grigia.
  La verifica PM conferma 8/8 checksum e assenza di leakage; gli asset restano
  `offline_inactive` fino all'approvazione editoriale e a un gate upload/binding
  separato.
- Antonello approva i master canonici 029H di Kado e Yori. L'approvazione è
  editoriale e non autorizza ancora upload, binding, missione o consumer live.
- La 029I si arresta prima di ogni scrittura: tutti i bucket vivi sono pubblici
  e `avatars` non può garantire asset draft non pubblici. La verifica PM
  conferma zero righe e oggetti Kado/Yori. Resta OPEN la scelta fra riuso
  esplicito del bucket pubblico per asset già approvati e nuovo circuito
  privato; nessuna delle due opzioni è assunta senza decisione di Antonello.
- Antonello sceglie il riuso di `avatars` pubblico per Kado e Yori, entrambi
  già approvati editorialmente. La pubblicità dei file è accettata; non cambia
  lo stato draft/inattivo dei record e non autorizza approval, missione o
  consumer. È autorizzato un retry live separato senza overwrite.
- Il retry 029I-A si arresta prima dell'upload: il browser operativo non è
  autenticato su Supabase/GitHub e la CLI disponibile non garantisce il
  vincolo no-upsert. La PM verifica il vivo il 27/08: zero mutazioni e nessun
  deposito finale. Lo stato non può essere dichiarato completo.
- Dopo accesso umano, la 029I-A completa il caricamento e il binding draft:
  due oggetti pubblici, due template e due versioni inattive, nessuna review,
  approval, missione o superficie narrativa. Antonello accetta le deviazioni
  procedurali documentate: upload resumable e rimozione automatica di due soli
  placeholder temporanei. La PM verifica il vivo e il manifesto 7/7.
- Antonello completa dal pannello staff review e approval di Miyo, Kado e Yori.
  La verifica DB read-only conferma tre template e tre versioni correnti
  `approved`, con immagini e checksum preservati. La porta 027A non promuove il
  lifecycle media incorporato: `identity.media` resta `draft`/`active=false`.
  La canonizzazione narrativa è quindi chiusa, mentre l'abilitazione media al
  consumer richiede un gate separato; nessuna missione viene creata da questa
  decisione.
- La 029J chiude la scelta architetturale del lifecycle media: il media non
  viene promosso riscrivendo lo skeleton approvato e non produce una finta
  nuova versione narrativa. Nasce invece un registro separato, append-only e
  versionato, con un solo canonico attivo, disattivazione/supersessione senza
  DELETE e resolver server-only fail-closed. La candidata è approvata offline;
  apply e successive approval dei tre record restano gate espliciti separati.
- Il primo apply 029J-A si arresta senza scritture quando compare in concorrenza
  la fondazione missione 029K. La PM verifica che 029K è approvata ma inattiva,
  senza grant, binding, piano o run, e non collide con il registro media 029J.
  La baseline viene quindi riconciliata, ma l'autorizzazione consumata dallo
  stop non viene estesa automaticamente: il retry richiede un nuovo via libera.
- Dopo il nuovo via libera, 029J-A R2 applica byte-esattamente il lifecycle
  media: tre record nascono in review/inattivi e il resolver resta fail-closed
  su `no_image`. Nessuna approval viene inclusa nell'apply; Antonello dovrà
  autorizzare separatamente le tre transizioni exact-admin. La fondazione
  missione 029K resta approvata ma inattiva e senza binding/run.
- La 029J-B completa tramite porte exact-admin le tre approval media. Miyo,
  Kado e Yori hanno ora un solo canonico `approved+active`, versionato e
  risolto server-side; hash e provenienza non cambiano. Il completamento del
  media non autorizza il binding missione: 029K resta inattiva e priva di run.
- Per la meccanica dei due banditi, la 029L dimostra che `png_templates` è
  legacy Combat V1 e non è una base idonea. Antonello decide il pool Genin-base:
  10 punti iniziali su ciascuna statistica operativa più 90 punti randomizzati
  deterministicamente una sola volta per l'archetipo condiviso bandito
  semplice. Sono ratificati 20/10/20/20/25/20/40/15, Innata 0, PV 100, chakra
  80 e nessun jutsu. Il catalogo resta Ninja Book, versionato e separato;
  Kado/Yori hanno binding distinti e l'adapter Master/Combat resta del suo owner.
- Il rebase 029L R2 sui cinque file `sito_live` aggiornati non riapre la scelta:
  regole, formule, statistiche e candidato SQL R1 risultano equivalenti. Il
  sigillo R2 include i nuovi hash e conferma che Admin/Land dipendono ancora dal
  legacy; perciò apply DB-only inattivo e adapter restano decisioni operative
  separate, non autorizzate dal rebase.
- Il primo apply 029L-A si arresta prima di scrivere: il candidato storico è un
  file psql e contiene `\set ON_ERROR_STOP on`, non trasportabile dalla porta
  SQL ufficiale senza cambiarne i byte. La PM sceglie una revisione offline
  SQL-pura limitata alla rimozione della direttiva, nuova impronta e prova di
  equivalenza; l'autorizzazione consumata dallo stop non copre il retry.
- Con autorizzazione integrativa, 029L-A R3 applica una sola migrazione dalla
  sorgente SQL-pura equivalente. Template/versione Genin-base e binding distinti
  Kado/Yori nascono deliberatamente inattivi; Miyo resta esclusa. Il resolver
  è service-only e nessun consumer viene introdotto. Adapter Master/Combat,
  binding 029K e canary restano gate separati.
- La discovery 031 dimostra che la FK Master V2 `NOT NULL` verso il catalogo
  legacy rende necessaria una scelta di contratto; non si crea una shadow-row
  in `png_templates`. La task si ferma senza SQL finché Antonello non sceglie
  fra estensione JSON della porta corrente e nuova porta versionata, oltre alla
  politica di audit e all'origine server-side delle offer scoped.
- Antonello sceglie **B + L + offer server-side**: nuova RPC versionata per il
  provider Ninja Book e porta legacy invariata; fallimenti come eccezioni
  PostgREST nei log, audit DB solo per operazioni concluse/replay; offer opaca
  emessa esclusivamente dal futuro runtime missione e vincolata 1:1 alla
  sessione Master. Nessuna risoluzione diretta di UUID Ninja Book dal client.
- La 031A traduce la scelta in candidato offline: nuova RPC provider-aware,
  tabelle offer/istanze/audit chiuse e identità provider nullable sul solo ramo
  nuovo di `combat_v2_actors`; la porta legacy non viene ridefinita. Il banco
  dimostra apertura 2v2, replay, inattivazione e doppio consumo concorrenti. La
  review approva il candidato ma non autorizza l'apply né i consumer.
- La 031A viene applicata inerte con una sola migrazione: tabelle e porta
  versionata esistono ma non contengono offer, istanze o audit; la porta legacy
  resta byte/ACL invariata. Il WARN definer della nuova RPC è registrato come
  atteso e non corretto nello stesso gate. Producer Missione e consumer Land
  restano separati e sono necessari prima di qualunque prova live.
- La 031B propone il producer Missione service-only senza inventare un nuovo
  modello cast: Kado/Yori sono derivati dal package sigillato, dal run 1:1 e dai
  binding server-side. La porta crea due offer e audit atomici ma non apre lo
  scontro. Il candidato è approvato offline; apply subordinato alla review
  COMBAT-CORE dell'ordine lock e separato dai lifecycle 029K/029L.
- Antonello richiede un reset di sicurezza della prima review lock 031B. La
  task viene fermata e archiviata senza scritture, RPC o sessioni live e senza
  acquisizione di segreti; il materiale parziale non viene riusato. La review
  riparte isolata su soli pacchetti sigillati e PostgreSQL effimero locale.
- Dopo il secondo stop di sicurezza, Antonello accantona il producer generale
  031B per il primo test. Si adotta un one-shot Test Room nominativo, limitato a
  una sola sessione, al package 029K e alle due offer Kado/Yori, con audit,
  scadenza e disarmo; nessun endpoint riutilizzabile o concorrenza cross-session.
  La decisione autorizza soltanto la progettazione offline del one-shot.
- La 031C realizza offline il percorso ristretto senza endpoint permanente:
  SQL-puro nominativo, lock globale del canary, due sole offer Kado/Yori,
  audit, scadenza e disarmo idempotente. Il one-shot non attiva né aggira 029L
  o 029K; lifecycle, sessione e sigillo concreto restano gate distinti.
- Il lifecycle offline 029K/029L conferma transizioni temporanee e disarmo
  conservativo; gli undici grant usano il contratto canonico
  `none → active → revoked`. La review rileva che 031C usa invece `enabled`:
  errore univoco del consumer da correggere e risigillare prima di ogni apply.
- La 031C R2 corregge esclusivamente quel mismatch: richiede 11/11 segmenti
  `active`, conserva il CHECK `none|active|revoked` e respinge esplicitamente
  `enabled`. Tutte le famiglie R1, concorrenza, disarmo e cleanup restano verdi;
  nessun live è autorizzato dalla correzione.
- La review indipendente delle trigger lifecycle viene interrotta dalla
  piattaforma per sicurezza prima del verdetto. I file parziali non entrano nel
  deposito approvato e non si supplisce alla review con i soli banchi del
  candidato. L'apply resta vietato finché interviene un reviewer umano DB/Combat.

## 26/08/2026 — OPEN-M1 chiusa con identità Mission Run A

- Antonello sceglie l'opzione **A**: `master_v2_sessions.id` è l'unico UUID
  pubblico e autoritativo del Mission Run.
- Non nasce `mission_runs.id`; `mission_id` resta identità del catalogo e può
  ricorrere in più sessioni nel tempo. Ogni nuova sessione Master è un nuovo
  run e il rebind è vietato.
- Lifecycle, sospensione, ripresa, annullamento e chiusura restano posseduti
  dalle porte Master. Solo `master_v2_close` raggiunge `missione_esito`; il
  futuro stato run è 1:1 e subordinato.
- Combat/Spatial/AoE/Danni e Ninja Book restano owner dei propri stati. Missione
  potrà conservare soltanto evidence refs opache, exact e validate.
- `OPEN-AOE-02` resta esterna e non è assunta dalla decisione.
- La decisione autorizza il candidato contrattuale offline R2 e la sua review,
  non schema SQL, apply, Edge, provider, contenuti o dati reali.

## 27/08/2026 — Sostituzione ratificata; Sigilli rinviati ad analisi mirata

- Antonello ratifica per Sostituzione un contratto discreto, cumulativo e
  server-authoritative: `<25 → 0/2 m`, `25–49 → 0/2/5 m`, `50–74 →
  0/2/5/10 m`, `≥75 → 0/2/5/10/15 m`. Il client mostrerà soltanto le ancore
  offerte dal server; costo 5 e riuso ogni tre turni difensivi restano
  invariati. La ratifica non equivale ad apply o rilascio.
- La proposta di rendere i Sigilli un requisito meccanico bloccante non è
  ratificata. Prima serve una verifica separata del comportamento vivo del
  motore e delle possibili condizioni strutturate di interruzione; fino ad
  allora non si introduce alcuna nuova meccanica né parsing del testo libero.

## 27/08/2026 — Intento tattico vincolante e fallimento fedele

- Antonello ratifica una decisione di prodotto trasversale: quando il giocatore
  dichiara una scelta tattica materiale — bersaglio, relay, percorso, copertura,
  ordine o modalità — il motore risolve esattamente quel piano tramite handle
  semantici server-authoritative. Non può sostituirlo con un'alternativa valida
  o più efficiente.
- Il server conserva l'autorità su geometria, punti di bordo, collisioni,
  distanze, tie-break e permessi. La canonizzazione automatica è ammessa solo
  per dettagli geometrici equivalenti dello stesso intento, mai per cambiare
  la scelta tattica.
- Un errore tattico umano resta un possibile fallimento. Prima del commit segue
  la regola di costo precommit della source; dopo il commit conserva i costi
  storici. Sono vietati retarget, reroute, auto-switch, auto-restore e correzione
  narrativa retroattiva, salvo futura permission esplicita e versionata della
  specifica source.
- Motore e Fato separano causa interna ed esito visibile. Il reason code esatto
  resta server/audit; il giocatore riceve soltanto la minima causa osservabile.
  Fato umano assistito e IA non possono dire che esisteva un collegamento,
  bersaglio o percorso alternativo né suggerirlo nell'esito.
- La decisione è TARGET-only. Runtime, parser, UI, prompt IA e regolamenti vivi
  restano invariati finché un successivo gate applicativo non li aggiornerà e
  testerà insieme.
- Antonello approva espressamente anche questa registrazione nella cronologia e
  il corrispondente debito in `04_LAVORI_APERTI.md`; la sanatoria documentale
  non autorizza alcuna modifica Runtime/LIVE.

## 27/08/2026 — Le dimensioni si scelgono per area, non tutte insieme

Antonello ha deciso che il pannellino «Aa» offra **quattro regolazioni
indipendenti** (testo della chat; pannello laterale e Scontro; tasti sotto la
chat; barra in alto e menu — in scheda: testo proprio e tasti condivisi),
ciascuna su Normale/Grande/Molto grande, al posto della scelta unica della
build precedente. La vecchia chiave `tus_pannelli` migra da sola alle tre aree.

## 27/08/2026 — La card Scontro apre in due passi, l'allenamento solo dal pannello verde

Ratificato: nella card Scontro resta un solo pulsante **«Apri scontro»**; al
clic si sceglie la distanza per **fasce pronte** (A contatto·0 / Corta·5 /
Media·20 / Lunga·45) oppure «Lascia al fato» — scartato il campo metri libero.
«Apri un allenamento» è rimosso dalla card: l'allenamento si dichiara solo dal
pannello verde, anch'esso a due passi (Apri allenamento → Tipologia + Conferma).
Le barrette PV/CK sotto la chat sono rimosse e **non vanno rimesse**: i valori
stanno in scheda e, in scontro, accanto alle barre della card (novità cs-num).

## 27/08/2026 — I pulsanti staff stanno nella riga del Fato

Il pulsante **Regia** (overlay PNG rapidi) e il nuovo **«Regia scontri»**
(Regia multi-attore) vivono nella riga staff accanto a «Entra come Fato», non
più fra i tasti dei giocatori. Dall'audit: i due sistemi di regia coesistono —
l'overlay vecchio (`png_*`) è completo ma NON parla col motore nuovo; le
implementazioni PNG recenti vivono nella Regia multi-attore
(`master_v2_*` + `combat_v2_*` + Ninja Book). Entrambi a zero usi in produzione.

## 27/08/2026 — Regia multi-attore: finestra separata e tre aperture

Deciso il pacchetto completo: la Regia multi-attore si usa in una **finestra
stile Editor** (la card a destra resta una striscia di stato che la apre, anche
per i giocatori), e l'apertura offre **tre strade** — *quest* con titolo e
tipologia (**one-shot o di trama, senza missione collegata**: vincolo
`missione_chk` allentato con la colonna `quest_kind`), *missione* dall'elenco
(titolo = missione, flusso di prima), *duello* con i partecipanti e la
**posizione iniziale in metri di ciascuno** (0–60 a passi di 5, validata dal
server; scartata l'alternativa a distanza unica fra squadre). Migrazione
`master_v2_aperture_e_distanze` applicata: firme nuove di
`master_v2_session_open` ed `encounter_open` — **land e DB si rilasciano
insieme**.

## 28/08/2026 — STOP coordinato Ninja Book 032 sulla baseline 377

- La recovery binding R13 applicata come `20260827144814` resta live e inerte;
  non viene rollbackata.
- La migrazione Master `20260827145228 · master_v2_aperture_e_distanze`,
  applicata subito dopo, rende stale l'adapter 127C-R7 costruito sulla history
  376.
- Decisione operativa: nessun apply, consumer, enable, binding dati, sessione
  o canary finché DB PM non coordina un nuovo rebase 127C sulla history 377.
- Il futuro candidato vive in un deposito distinto, attesta nominativamente la
  migrazione Master, ripete suite/concorrenza e richiede review e autorizzazione
  DB separate. Nessun adattamento in-place del candidato stale.

## 28/08/2026 — Adapter 127C e dispatcher 127E installati inerti

- 127C-R10 viene applicato come `20260827154907`, portando la history a 378;
  owner, RLS/FORCE, ACL e rollback risultano verdi, senza runtime o dati.
- 127E-R4 si arresta atomicamente prima del DDL perché confronta erroneamente
  il sigillo storico R13 con il fingerprint estensibile post-127C. Nessun
  residuo viene creato.
- 127E-R5 separa sigillo storico, composito post-127C e fingerprint specifico
  127C; viene applicato come `20260827163249` e porta la history a 379.
- Il recovery 127E viene riallineato alla versione realmente assegnata da
  Supabase e usa lock esclusivi prima di controllo e ritiro. Review finale
  P0/P1/P2=0.
- Decisione operativa: la task Ninja Book 032 riprende sulla baseline 379, ma
  consumer, enable, dati, sessioni e canary restano gate separati.

## 28/08/2026 — Il primo consumer Missione usa Surface 2.3 server-side

- G10-A ratifica soltanto il modello di prodotto del carrier Test Room a
  riposo `annullata`; prepare, closure e recovery restano da progettare e
  provare offline con fault-injection prima di qualsiasi implementazione.
- G10-B respinge il lifecycle 029K/029L corrente: il sostituto deve essere un
  overlay nominativo e session-scoped, senza alterare trigger o flag condivisi,
  e deve chiudere lock order, replay e recovery con review indipendente.
- Per G10-C si sceglie una nuova revisione dispatcher con Surface 2.3 derivata
  e attestata interamente dal server. Il consumer 2.0 non viene usato come
  scorciatoia perché presuppone persona, fatti, atomi, continuità e frame già
  materializzati, mentre il dispatcher R5 vivo conserva solo receipt, hash e
  riferimenti opachi.
- Il browser può inviare soltanto intento e chiavi di correlazione; non può
  fornire contesto narrativo, bearer interno, fatti, atomi o autorizzazioni.
  La revisione mantiene Miyo fuori dalla meccanica, lega Kado e Yori al binding
  server-attested e conserva le garanzie CAS/replay/reconcile di R5 e quelle
  owner-sealed/fact-bound di R14.
- Nessun apply, deploy, provider, enable, dato, binding, sessione o canary è
  autorizzato finché i candidati separati G11-A/B/C e le rispettive review non
  risultano verdi. La fonte 031C-R2 resta `grant_state='active'`.

## 28/08/2026 — Il canary non può essere ridotto al solo Combat

- La verifica PM dei candidati G11 conferma verdi i banchi locali A, B e C,
  con C ancora fail-closed sull'ambiente owner-sealed deposito/approdo.
- Il DB vivo contiene le superfici Mission Run per transition, evidence e
  publication, ma zero piani, versioni, binding o run. G11-C gestisce soltanto
  `combat_round_complete` e `combat_terminal`.
- Decisione: il DoD resta la missione completa. Prima del one-shot servono
  ambienti owner-sealed phase-bound (G11-C1), il piano delle otto fasi con
  prove alternative abilità/azione e reveal progressivo (G11-D), e un
  dispatcher/consumer server-side per le scene con Miyo e l'indagine (G11-E).
- Descrizioni ambiente, client e modello non possono introdurre indizi o
  dichiarare il successo di una prova. Reveal e avanzamento restano legati a
  evidence e grant server-authoritative; il Combat continua a usare 127C.
- Restano vietati apply, deploy, provider, enable, dati, sessioni e canary fino
  alle review indipendenti verdi dell'intera catena.

## 28/08/2026 — Miyo resta al deposito e ogni sua informazione è fact-bound

- Miyo è la richiedente e informatrice civile della prima parte della
  missione; non accompagna i PG al riparo dei banditi e non apre lo scontro.
- Un frame dialogico può essere libero soltanto quando esprime voce,
  gestualità o saluto senza fatti di trama. Inventario mancante, scambio fuori
  orario e limite di conoscenza sui banditi richiedono gli atomi approvati e
  grant, destinatario e scope server-side.
- `miyo.ultimo_controllo` non appartiene al contenuto 029G approvato e non può
  entrare nel consumer. La chiusura può affermare il recupero soltanto dopo un
  fatto terminale attestato dal server; altrimenti resta neutra.
- Il candidato dialoghi G11-C2 R1 è quindi respinto e va risigillato in R2
  prima di fissare G11-E. Nessuna variante può ampliare le proposizioni
  approvate o introdurre dettagli narrativi nuovi.
- Apply, deploy, provider, enable, dati, binding, sessioni, canary e one-shot
  restano fermi fino alle review indipendenti verdi di tutta la catena G11.

## 28/08/2026 — Ogni fase del canary richiede una prova server-side

- La prima review G11-A respinge una chiusura che poteva dichiararsi terminale
  lasciando binding o Combat residui e un lock order incompatibile con Master.
  Il carrier sarà ratificabile soltanto dopo migration standalone, race reale
  e postcondizione full-state a zero.
- Due receipt diverse dello stesso indizio non costituiscono due indizi: il
  conteggio usa clue/fact distinti e l'unicità vale anche in concorrenza.
- Il fatto `missione.recupero_confermato` nasce dal server soltanto dopo receipt
  Combat terminale e continuità della refurtiva; Miyo può usarlo ma non
  produrlo.
- Il piano non può avanzare per semplici chiamate service attraverso le scene.
  Briefing Miyo, prima lettura dell'ambiente, transizione, incontro con la
  refurtiva e chiusura Miyo richiedono receipt di pubblicazione scoped e
  immutabili; raccolta tracce, Combat e recupero mantengono i gate specifici.
- I limiti di conoscenza della persona viaggiano separati dai fatti rivelabili:
  un constraint privato di Miyo può autorizzare un diniego, ma non diventa un
  grant al team né entra nella surface pubblica.

## 28/08/2026 — Il cleanup Test Room chiude il runtime, non cancella lo storico

- La verifica read-only sulla baseline viva 379 conferma che prima del canary
  binding, roster, PNG, run, eventi e pubblicazioni sono a zero e il profilo
  R13 è disabilitato. Questa è la condizione iniziale, non la forma obbligatoria
  dello stato dopo una prova completata.
- R13 conserva il binding in stato immutabile `frozen`; Mission Run conserva
  eventi e pubblicazioni `committed`, mentre `mission_run_state.run_phase`
  prevede gli stati terminali `conclusa`, `fallita` e `annullata`. Le ricevute
  e gli audit G11 sono append-only e non possono essere cancellati per far
  risultare verde un postflight.
- Decisione PM: il criterio finale è **zero runtime attivo per la sessione**,
  non zero righe storiche. Devono risultare terminali la sessione e il run,
  pubblicato o disarmato ogni outbox, revocate/scadute capability e overlay,
  chiusi Combat e offerte e assenti lease o autorizzazioni provider pendenti;
  binding, roster, receipt, eventi, pubblicazioni e audit restano preservati.
- Recovery pre-bind e closure post-bind usano predicati distinti. La prima può
  attestare davvero zero binding; la seconda deve accettare lo storico frozen
  esatto e provarne l'inerzia. Nessun banco valido può simulare la chiusura con
  `DELETE` di binding, run o audit.
- Il disarmo di una singola Test Room è session-scoped: non può disabilitare né
  dipendere dal flag globale del narratore. A-R4 e D-R5 restano STOP fino alla
  correzione, al risigillo e a nuove review indipendenti.

## 28/08/2026 — G11-D R5 verde offline

- Il piano Mission Run R5 supera il banco autore 58/58 e la nuova review
  indipendente 16/16 più 23/23 verifiche statiche; verdetto P0/P1/P2=0.
- Sono chiusi preflight baseline/fingerprint, sorgenti package-binding-roster,
  capability e scadenza, ledger unico run/request-key, otto gate narrativi,
  indizi distinti, receipt Combat/refurtiva e fatto terminale append-only.
- Il verde è solo offline. E-R3 può pinzare D-R5 e produrre le receipt di fase;
  segue una review integrata D/E. Apply, provider, dati e canary restano fermi.

## 28/08/2026 — Projection R9 ritirata prima dell’apply

- Il gate nominativo per `MISSION-NARRATOR-SURFACE-PROJECTION-DB-127E-R9`
  è stato ritirato prima dell’autorizzazione e di qualsiasi scrittura live.
- La R9 era sicura e inerte, ma non semanticamente equivalente alla Surface
  interna richiesta dal consumer: mancavano fact reference tipizzate, atomi
  autoritativi con digest di contenuto e segmento, scope persona, frame di
  dialogo e permission per fatto.
- Il consumer non può inventare tali classi o permessi. R9 è quindi
  `SUPERSEDED / NON APPLICABILE`; la baseline viva resta 379.
- Il prossimo gate è una Projection R10 completa server-side, prodotta
  offline, provata e sottoposta a nuova review e nuova autorizzazione
  nominativa. Fino ad allora restano vietati apply, consumer/Edge/provider,
  enable, binding, sessioni e canary.

## 28/08/2026 — La Surface richiede una phase authority unica

- La fotografia viva 379 conferma receipt autoritative per il Combat ed eventi
  Mission Run immutabili, ma non receipt semantiche pre/post Combat né un
  binding autoritativo fase→PNG/media.
- `nb_media_resolve` e i media approvati di Miyo, Kado e Yori esistono; manca
  ancora l’autorità server che decide quando e quale identità/media possa
  entrare nella Surface.
- Una nuova Projection è ratificabile soltanto insieme a una phase authority
  session-scoped per `pre_combat`, `combat_round`, `combat_terminal` e
  `post_combat`, con permission per fatto, persona scope, dialogue frame e
  binding Ninja Book/media derivati dal server.
- Miyo è ammessa solo nelle fasi al deposito pre/post; Kado e Yori soltanto
  dall’incontro alla conclusione del Combat. L’Edge non può ricostruire né
  completare queste decisioni.

## 28/08/2026 — G11-D R6 fermata dal requisito event trigger

- R6 supera core, packaging e review indipendente, ma non è stata autorizzata
  né applicata.
- Il preflight vivo read-only dimostra che il canale SQL usa `postgres`, che
  non è superuser né membro di `supabase_admin`; gli event trigger della
  piattaforma appartengono invece a `supabase_admin` e non esistono precedenti
  applicativi in migration history.
- La guardia R6 richiede `CREATE EVENT TRIGGER`: il requisito di applicabilità
  hosted è quindi falso. Live resta history 379 e runtime inerte.
- Decisione: R7 deve conservare il core R5 ma sostituire la guardia persistente
  con il sigillo ACL transaction-local per ogni migrazione, con revoche/grant
  nominativi, assert finali e divieto di funzioni tardive. Nessun gate
  successivo riparte prima di nuova review e autorizzazione nominativa.

## 28/08/2026 — R7 annullata: G11-B deve precedere G11-D

- R7 hosted-safe è stata autorizzata dopo suite e review verdi, ma il suo
  preflight interno ha ricevuto `42883`: due helper G11-B richiesti non sono
  presenti live.
- La causa è una dipendenza di sequenza mascherata dalla fixture locale: G11-B
  era verde offline, non applicato. Non si rimuove il requisito da D.
- L'apply è stato annullato atomicamente: history 379, target D e runtime sono
  invariati. L'autorizzazione R7 è consumata e il pacchetto non va ritentato.
- Nuovo ordine vincolante: G11-B API-ready e reviewed, apply B separato, rebase
  D sulla history successiva, poi Surface. Tutti gli altri gate restano fermi.

## 28/08/2026 — Incidente R10: adozione dello schema orfano

- L'apply G11-D R10 ha restituito un errore di preflight ma ha lasciato lo
  schema completo e vuoto senza registrare la migration history: 9 tabelle,
  10 helper, 5 porte, 18 trigger e 28 indici; history ancora 380.
- Nessun dato o runtime è stato creato. Non sono stati eseguiti retry, capture
  o rollback.
- Decisione PM: non eliminare uno schema completo e inerte. Preparare una
  migration di adozione assert-only che attesti byte/fingerprint e zero dati,
  senza DDL sugli oggetti, quindi registri una nuova riga history.
- Il recovery richiede prove di doppio invio, review e autorizzazione nuove.
  Surface, consumer, enable, dati, sessioni e canary restano fermi.

## 28/08/2026 — La cura richiede la tecnica Palmo Curativo appresa

Ratificato (changelog 73): il pulsante ✚ Cura è rimosso dalla chat; la soglia
«Mente ≥ 25» non è mai esistita nel motore (viveva solo nei testi) e viene
cancellata da ogni documentazione. `post_heal` ora esige, oltre alla
corporazione Medico, la tecnica **Palmo Curativo appresa** (abilità di grado C,
100 XP): l'appartenenza al corpo medico da sola non basta. Numeri invariati.
Dalla chat non esiste più alcun comando di cura: un eventuale innesco nuovo
(es. dalla lista Tecniche) è un task futuro.

## 29/08/2026 — Punti caratteristica: un acquisto per gradino

Corretto il bug che rendeva morto il pulsante (la scheda non passava il
gradino a `premio_acquista`) e ratificato il comportamento: il premio
`punti_caratteristica` si compra **una volta per gradino** (Genin, Chunin, …,
al rango giusto), il gradino resta registrato nel perk, e i +15 punti li
concede solo il trigger. CHECK di `grado_tecnica` allargato ai gradini di
carriera. Primo acquisto reale eseguito d'ufficio su Ryutama (−200 XP, +15
punti) dopo il suo tentativo a vuoto del 28/08, che non gli aveva addebitato nulla.

## 02/09/2026 — Esame: deroga di collaudo completa nella Test Room
Antonello autorizza `20260902152803 esame_avvia_deroga_test_room_002`: nella
Test Room lo staff avvia l'esame con qualunque PG (niente controllo di
villaggio, grado, lezioni). Vincolo allentato dichiarato; la chiusura in
`is_test` resta isolata (xp 0, grado invariato). Per la prova sono stati
accesi temporaneamente `is_exam_room` e `is_academy` sulla Test Room: la land
disegna l'Esame solo in `is_exam_room` e ritrova la sessione solo da
`academy_class_state`.

## 02/09/2026 — Il Narratore dell'Esame si unifica al modello delle Missioni IA
Dopo la prova reale di Riuji su Edge v106 (11 cicli, 10 su Luna, 1 ripiego;
meccanica corretta in tutti i casi provati), Antonello decide: la prosa
dell'Esame si porta sul modello del «terzo livello» usato nella Ronda
(ricevuta → piano narrativo → Luna → validatore → approvazione), con le note di
redazione R1–R4 di `management/redazione/NOTE_ESAME_R1-R7.md`. Gli sfidanti
d'esame (`esame_png_profili`, oggi 6) ricevono una **scheda formale con
personalità** e **parlano dentro la narrazione**: racconta il Narratore in
terza persona (voce «Fato», come nella Ronda) e fa dire al PNG le sue battute;
le personas in prima persona di oggi sono superate. Il dialogo fra personaggi
è parte del gioco di ruolo e le regole attuali lo soffocano; **nessuna quota
di battute**: l'interazione è libera e naturale, secondo la personalità del
PNG e il modo di esprimersi del PG (chi parla molto, chi poco). Decise nella stessa sera anche le due
scelte di costruzione: **la mossa del PNG la sceglie il modello fra le opzioni
del server (come oggi)** — perché la scelta nasca da una tattica e la tattica
dallo stato (danni, alleati persi, scopo mancato), così la prosa porta
intenzioni, errori e reazioni coerenti (nota R6); **ferite e sangue sono consentiti nella prosa d'esame
quando il referto li stabilisce** (conseguenza proporzionata a lieve/serio/grave):
cade il filtro «ferite, sangue o KO in una prova che non toglie nulla», e il
regolamento dirà che la prova non toglie nulla davvero ma la scena può
mostrarlo. Sostituisce l'ordine del tabellone: il cantiere «Narratore
unificato» entra come terzo in lavoro.

## 02/09/2026 — L'aula d'esame è un tatami di 10 × 10: perimetro imposto dal server
La prova prevede solo corpo a corpo e Moltiplicazione, quindi il tatami di
10 metri non limita nulla: è il perimetro della prova. Decisione: **nessuno
può uscire dai 10 metri**, lato server (oggi `_esame_muove` ammette una
separazione fino a 60 m e posizioni negative: la ritirata di 15 m esce
dall'aula). La tavola dell'aula di Konoha con le 8 ancore per la
Sostituzione è in `management/arene/`; attesa la gemella di Suna.

## 02/09/2026 — Shion: tre lezioni dell'Accademia registrate d'ufficio
Su richiesta di Antonello (lezioni svolte fuori dal flusso automatico), a
Shion (Deshi, Konoha, user `6212062f…`) sono state accreditate L1, L2, L3 con
`_academy_grant`, la stessa porta che il gioco usa a fine lezione: 45 XP
(tre righe in `xp_log`, causali «accademia: Storia e mondo / Il chakra /
Controllo del chakra»), jutsu di base «Uso dei sigilli» e «Controllo del
chakra». `completed_at` retrodatati a 30/08, 31/08 e 01/09 per rispettare
la regola di una lezione per giornata: L4 disponibile dal 02/09. Prova a
vuoto in rollback prima dell'esecuzione; nessuna funzione modificata.

## 02/09/2026 — Sfidanti d'esame: le sei schede sono approvate per intero
Antonello approva le proposte di tutti e sei gli sfidanti (`management/SCHEDE_SFIDANTI_ESAME.md`: tattica per stato R6, firma fisica R3/R4, voce R5) — Kotoha e Sota già nel pomeriggio, Tatsuma, Hazuki, Isamu e Kazane in serata — con la riserva già decisa: niente frasi fatte, gli esempi sono timbro e ripiego, il dialogo nasce dalla scena. Nella stessa giornata sono arrivate tutte le tavole di riferimento per l'IA: sei sfidanti (`management/sfidanti_esame/riferimenti/`) e le due aule d'esame di Konoha e Suna (`management/arene/`, 8 ancore per la Sostituzione nelle stesse posizioni), trascritte nelle schede perché la Edge non legge immagini. Il passo 1 del cantiere «Narratore unificato» è chiuso; §7 delle schede è il contratto della migrazione delle personas (passo 3). Nessuna modifica a database.

## 03/09/2026 — Il Narratore dell'Esame rilasciato in blocco (NARRATORE-UNIFICATO-001)
Su decisione di Antonello (02/09 sera: «si può fare in blocco», niente strati di compatibilità con la v106), i passi 2–4 del cantiere escono insieme, con zero prove aperte, fra le 05:32 e le 06:40 UTC. Database: `20260903053252 esame_narratore_unificato_001` — bordo del tatami [0,10] applicato in posto ai sette chiamanti del movimento (vincolo aggiunto, dichiarato), ingaggio 2/7 (dichiarato), aula per villaggio con otto ancore dalle tavole, referto v2 con bersaglio/conseguenza/gravità/ancora/movimento/iniziativa/segni decisi dal server con il dado della prova, scena in terza persona, payload v5, sei personas come dossier (scopo, tattica per stato, firma fisica, voce, guardrail nuovi, niente coprifronte), fatti ricalcolati sugli scambi vecchi, payload di replay; il gate V5 resta come funzione-tomba. Poi `…_002_grant` (il GRANT a service_role dimenticato: la prima chiamata l'ha scoperto) e `…_003_replay_scambio`. Edge `exam_genin_ai` riscritta da zero: v117 (`4.0.3-NU001`), sei file, ricevuta → piano narrativo in otto punti → una chiamata a Luna high → validatore per riferimenti → `esame_narrazione_apply`; cadono la «reazione udibile obbligatoria» e il filtro ferite; entrano R2, R3, R5, R7, l'ancora nominata. Banco dei replay: 18 cicli, 17 accettati; i rifiuti iniziali erano falsi positivi del validatore (attribuzione delle battute, fiato in memoria, minimi), corretti in tre versioni. Nota di metodo: il «Narratore delle Missioni IA» che piaceva era Codex in chat con le note di redazione, non la Edge `mission_narratore_ai` v9 (mai chiamata in produzione): si è copiato il metodo, non il codice. Foto della v106 per il rollback in `rilascio_001/edge_v106_foto.tar.gz`. Restano: prova in Test Room con Riuji, regolamento (passo 6), osservazione della latenza di Luna high sui cicli d'attacco.

## 03/09/2026 — Confine del QA narrativo condiviso
Antonello chiude il disegno futuro: i controlli deterministici possono essere condivisi, mentre ricevute e referti sono soltanto comunicazione fra componenti. I Narratori restano su Luna/high; il giudice qualitativo opera asincrono e offline su Terra/high e non può pubblicare, cambiare stato, rigenerare o decidere meccaniche. Nessuna memoria condivisa gratuita e nessun consumer chiama un altro consumer. La decisione non autorizza implementazioni fuori dal cantiere né modifiche LIVE.

## 03/09/2026 — Caricamento GitHub autonomo dopo il gate
Antonello sostituisce la regola del deploy sempre manuale: quando un lavoro già approvato è pronto e verificato, Codex o Claude possono caricare autonomamente su `antonello9311-design/theuntoldstory`, branch `main`, esclusivamente i file appartenenti al task. Restano obbligatori owner unico, riconciliazione con la testa remota, esclusione di segreti e file estranei, registrazione di commit/SHA e verifica del dominio; restano vietati cancellazioni, force-push e riscritture della storia. Gli scope `offline-only` o `no deploy` prevalgono. Se non esiste un canale GitHub autenticato, si blocca soltanto il caricamento e si consegna la lista esatta. Il caricamento di SQL o sorgenti Edge su GitHub non autorizza apply o deploy Supabase.

## 04/09/2026 — Il Tester avanzato della Test Room è rinviato
Antonello rinvia il progetto per il tempo richiesto e continua personalmente i collaudi. Restano parcheggiati, senza nuovo cantiere né autorizzazione a codice o database: capability Tester separata dallo staff, scheda ombra modificabile, Esame ripetibile e chiamate Luna con quota. La Test Room pubblica esistente e le deroghe staff non cambiano; il lavoro si riapre solo con un nuovo mandato di Antonello.
