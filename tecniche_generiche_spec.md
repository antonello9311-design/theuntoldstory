# Tecniche generiche — il fondo comune di ogni ninja

> **STATO: PROPOSTA, DA APPROVARE RIGA PER RIGA.** Scritta la notte del 31/07/2026, **rivista la mattina del 31/07** sul compendio della Narutopedia. Nessuna riga è stata inserita a database.
>
> **Perché serve.** Il collaudo del 31/07 ha misurato che cosa può imparare un Genin senza clan e senza corporazione: **due abilità in tutto**, e **zero** tecniche con `macro='generica'`. Ogni ninjutsu, genjutsu e taijutsu del gioco appartiene a un clan. Un nuovo iscritto, uscito dall'Accademia, ha davanti otto tecniche che non fanno danno e poi il vuoto.
>
> **Che cosa contiene.** **Quarantuno** tecniche di fondo comune, dal grado D al grado B: il repertorio che nel mondo di gioco conosce chiunque abbia frequentato un'accademia ninja, indipendentemente dal sangue e dai gradi.
>
> **Che cosa è cambiato nella revisione.** Sette nomi, un grado spostato, una tecnica nuova e un capitolo intero di verifica sul canone: tutto elencato in §7, niente cambiato in silenzio.
>
> **Copyright.** Nessun testo è stato preso da altri giochi né dalla Narutopedia. I nomi sono resi in italiano secondo la convenzione del progetto, le descrizioni sono scritte qui, i numeri vengono dal nostro motore (§4 e §5.2 di `REGOLE.md`). Del compendio si usano soltanto i dati — rango, natura, funzione — che servono a tarare, non a copiare.

---

## 1. Le regole che ho seguito nel comporle

| Grado | Rango minimo | Soglia di disciplina | XP | Chakra | Danno base | Addestramenti |
|---|---|---:|---:|---:|---:|---:|
| **D** | Genin | 10 | 50 | 5 | 15 | 1 |
| **C** | Genin | 25 | 100 | 10 | 20 | 2 |
| **B** | Chunin | 40 | 150 | 20 | 25 | 2 |

Ogni valore è multiplo di 5. Il tetto di 65 danni per azione non viene mai sfiorato: sono tecniche di fondo, non finisher.

**Le elementali chiedono l'elemento** (`req_elements` con modo «uno»): chi non ha scelto l'elemento del chakra — è facoltativo alla creazione — resta con le ventisei non elementali, che bastano a giocare. È un incentivo a scegliere, non una punizione.

**Il primo sigillo dichiara la natura** (§5.1, changelog 33): ogni elementale di questo elenco si apre con il segno della sua natura, e la descrizione lo dice. Serve a rendere viva in scena la regola scritta ieri.

**Le difensive e le mantenute** usano `consumption_type='per_turno'`; tutte le altre `ad_utilizzo`. I taijutsu hanno `attivazione='istantanea'`, ninjutsu e genjutsu `'sigilli'` — che è anche la ragione per cui in mischia un taijutser è avvantaggiato.

---

## 2. Ninjutsu generici — 8 righe, nessun elemento richiesto

| Nome | Grado | Serve | Gittata | Chakra | Danno | Che cosa fa |
|---|:--:|---|---|---:|---:|---|
| **Colpo di chakra** | D | Ninjutsu 10 | corta | 5 | 15 | Concentri il chakra nel palmo e lo scarichi addosso all'avversario. Grezzo, rumoroso, efficace: è la prima cosa che insegna chiunque. |
| **Corda di chakra** | D | Ninjutsu 10 | corta | 5 | — | Un filo teso fra le dita che si irrigidisce e lega. Non ferisce: immobilizza un arto o un'arma per un turno, e si spezza con la Forza. |
| **Passo istantaneo** | D | Ninjutsu 10 | contatto | 5 | — | Sparisci da dove sei e ricompari qualche metro più in là, lasciando una nuvola di polvere al tuo posto. Non attacchi e non difendi: cambi fascia di distanza senza dare le spalle, o esci dalla scena. |
| **Occultamento del chakra** | C | Ninjutsu 25 | contatto | 10 (per turno) | — | Comprimi la tua firma finché diventa quella di un civile. Chi cerca di percepirti confronta contro la tua Mente. |
| **Proiettile di chakra** | C | Ninjutsu 25 | media | 10 | 20 | Una sfera compressa scagliata a distanza. È il jutsu che permette a un ninjutser di colpire prima che il taijutser lo raggiunga. |
| **Barriera minore** | C | Ninjutsu 25 | contatto | 10 (per turno) | — | Una parete di chakra larga quanto il tuo corpo. Regge un colpo per turno; oltre, si incrina e cade. |
| **Trappola di chakra** | B | Ninjutsu 40 | media | 20 | 25 | Prepari un innesco su un punto del terreno: chi ci passa lo fa scattare. Va dichiarata in anticipo, e chi ti ha visto prepararla può evitarla. |
| **Barriera a cupola** | B | Ninjutsu 40 | corta | 20 (per turno) | — | La barriera si chiude su di te e su chi ti sta accanto. Protegge il gruppo, ma finché la tieni non attacchi. |

---

## 3. Ninjutsu elementali — 15 righe, tre per natura

Ogni natura ha lo stesso scheletro: un colpo ravvicinato di grado D, un attacco a distanza di grado C, una tecnica d'area o di controllo di grado B. Il primo sigillo è quello della natura (§5.1). Sul perché lo scheletro sia identico nel numero ma non nella funzione, §8.2.

### Fuoco 火 — apre con la **Tigre**

| Nome | Grado | Serve | Gittata | Chakra | Danno | Che cosa fa |
|---|:--:|---|---|---:|---:|---|
| **Soffio di brace** | D | Ninjutsu 10 · Fuoco | corta | 5 | 15 | Un getto breve di scintille. Poco più di un avvertimento, ma incendia stoffa, corde e carta. |
| **Grande sfera di fuoco** | C | Ninjutsu 25 · Fuoco | media | 10 | 20 | La tecnica con cui si misura ogni allievo del Fuoco: una sfera che attraversa il campo e costringe a spostarsi. |
| **Annientamento di fiamma** | B | Ninjutsu 40 · Fuoco | media | 20 | 25 | Il fuoco si allarga a ventaglio e prende più bersagli sulla stessa linea. Chi si copre dietro il legno scopre che non era una buona idea. |

### Vento 風 — apre con l'**Uccello**

| Nome | Grado | Serve | Gittata | Chakra | Danno | Che cosa fa |
|---|:--:|---|---|---:|---:|---|
| **Lama di vento** | D | Ninjutsu 10 · Vento | corta | 5 | 15 | Un taglio d'aria compressa sul filo della mano. Non lascia lividi: lascia tagli netti. |
| **Grande sfondamento** | C | Ninjutsu 25 · Vento | media | 10 | 20 | Una folata che parte dal palmo e spinge via tutto quello che trova. Disperde fumo, nebbia e polvere, e chi ci si nascondeva. |
| **Sfera di vuoto** | B | Ninjutsu 40 · Vento | media | 20 | 25 | Aria compressa fino a diventare una lama sferica. Il Vento è l'unico elemento che ferisce senza toccare. |

### Fulmine 雷 — apre con la **Lepre**

| Nome | Grado | Serve | Gittata | Chakra | Danno | Che cosa fa |
|---|:--:|---|---|---:|---:|---|
| **Scarica** | D | Ninjutsu 10 · Fulmine | contatto | 5 | 15 | Una scossa secca a mano aperta. Fa più male di quanto sembri e intorpidisce il braccio colpito. |
| **Lancia di fulmine** | C | Ninjutsu 25 · Fulmine | media | 10 | 20 | Un dardo che parte dritto e arriva prima che l'occhio lo segua: chi ha Velocità bassa fatica a schivarlo. |
| **Rete folgorante** | B | Ninjutsu 40 · Fulmine | media | 20 | 25 | Il fulmine si apre in una maglia che copre un tratto di campo. Chi la attraversa perde il turno successivo. |

### Terra 土 — apre con il **Serpente**

| Nome | Grado | Serve | Gittata | Chakra | Danno | Che cosa fa |
|---|:--:|---|---|---:|---:|---|
| **Scudo di terra** | D | Ninjutsu 10 · Terra | contatto | 5 (per turno) | — | Il terreno si alza davanti a te per la larghezza di un uomo. Regge un colpo e poi si sbriciola, ma un turno guadagnato è un turno guadagnato. |
| **Proiettile di roccia** | C | Ninjutsu 25 · Terra | media | 10 | 20 | Strappi una scheggia di terreno e la scagli. Rozzo, pesante, difficile da deviare. |
| **Prigione di pietra** | B | Ninjutsu 40 · Terra | corta | 20 | 25 | La terra si chiude sulle gambe del bersaglio e lo tiene. Chi resta immobile in mezzo al campo diventa il bersaglio di tutti. |

### Acqua 水 — apre con il **Cane**

| Nome | Grado | Serve | Gittata | Chakra | Danno | Che cosa fa |
|---|:--:|---|---|---:|---:|---|
| **Frusta d'acqua** | D | Ninjutsu 10 · Acqua | corta | 5 | 15 | Un filo d'acqua che schiocca come una frusta. Serve poca acqua: bastano una borraccia e buon controllo. |
| **Proiettile d'acqua** | C | Ninjutsu 25 · Acqua | media | 10 | 20 | Un getto compresso che colpisce come un pugno e spegne il fuoco che incontra. |
| **Onda montante** | B | Ninjutsu 40 · Acqua | media | 20 | 25 | Un'ondata che travolge e sposta: il bersaglio finisce dove decidi tu, e in una scena di combattimento la posizione vale più del danno. |

---

## 4. Genjutsu generici — 7 righe

I genjutsu di questo elenco confrontano la tua **Mente** con quella del bersaglio, e si rompono con la **Dispersione** insegnata in Accademia (§4.3).

| Nome | Grado | Serve | Gittata | Chakra | Potenza | Che cosa fa |
|---|:--:|---|---|---:|---:|---|
| **Eco ingannevole** | D | Genjutsu 10 | corta | 5 | 15 | Un rumore che non c'è, alle spalle del bersaglio. Non fa danno: gli fa girare la testa dalla parte sbagliata per un istante. |
| **Suggestione** | D | Genjutsu 10 | corta | 5 | 15 | Una frase piantata nella testa che sembra un pensiero proprio. Funziona su chi è stanco o distratto, non su chi è in guardia. |
| **Immagine speculare** | C | Genjutsu 25 | corta | 10 | 20 | Il bersaglio ti vede dove non sei. Il primo colpo che ti tira va a vuoto. |
| **Paralisi illusoria** | C | Genjutsu 25 | corta | 10 | 20 | Le gambe non rispondono, e non c'è niente che le tenga. Un turno fermo, se il confronto riesce. |
| **Prigione dei sensi** | B | Genjutsu 40 | corta | 20 | 25 | Buio, silenzio, nessun odore. Il bersaglio perde il campo di vista finché non si libera. |
| **Sogno a occhi aperti** | B | Genjutsu 40 | corta | 20 | 25 | Una scena falsa e coerente, costruita su un ricordo del bersaglio. Il più crudele di questa lista, e va giocato con misura. |
| **Rottura condivisa** | B | Genjutsu 40 | contatto | 20 | — | Non attacchi: liberi un compagno da un'illusione toccandolo. È la Dispersione applicata a un altro, ed è ciò che rende utile un genjutser in squadra. |

---

## 5. Taijutsu generici — 11 righe

Nessuno di questi chiede sigilli: sono tutti a **attivazione istantanea**, quindi non si disturbano in mischia e non si leggono dalle mani (§5.1).

| Nome | Grado | Serve | Gittata | Chakra | Danno | Che cosa fa |
|---|:--:|---|---|---:|---:|---|
| **Colpo diretto** | D | Taijutsu 10 | contatto | — | 15 | Il pugno che si insegna il primo giorno. Non costa chakra e non finisce mai. |
| **Spazzata** | D | Taijutsu 10 | contatto | — | 15 | Colpisci le gambe e mandi a terra. Chi è a terra difende peggio nel turno che segue. |
| **Scatto d'assalto** | D | Taijutsu 10 | corta | — | — | Chiudi la distanza in un movimento solo e arrivi a contatto. È così che un taijutser sopravvive a un ninjutser. |
| **Parata** | D | Taijutsu 10 | contatto | — | — | Assorbi il colpo con l'avambraccio invece di schivarlo: prendi metà del danno e resti in piedi dove sei. |
| **Presa e proiezione** | C | Taijutsu 25 | contatto | — | 20 | Afferri, sbilanci, lanci. Il danno non lo fa il tuo braccio: lo fa il terreno. |
| **Calcio ascendente** | C | Taijutsu 25 | contatto | — | 20 | Un calcio che parte dal basso e stacca l'avversario da terra. Chi vola non para. |
| **Passo del fulmine** | C | Taijutsu 25 | corta | — | — | Tre passi che sembrano uno. Non è una tecnica di Fulmine: è pura velocità, e serve a uscire da una morsa. |
| **Combo dei tre colpi** | C | Taijutsu 25 | contatto | — | 20 | Tre colpi incatenati sulla stessa linea. Se il primo passa, gli altri due arrivano quasi da soli. |
| **Colpo caricato** | B | Taijutsu 40 | contatto | 20 | 25 | Fai scorrere il chakra nell'arto un istante prima dell'impatto. È l'unico taijutsu che costa chakra, ed è la ragione per cui un taijutser puro tiene comunque d'occhio la sua riserva. |
| **Guardia di ferro** | B | Taijutsu 40 | contatto | — | — | Chiudi la difesa e non ti muovi più. Finché la tieni non attacchi, ma chi ti colpisce si fa male da solo. |
| **Contrattacco** | B | Taijutsu 40 | contatto | — | 25 | Aspetti il colpo e rispondi nello stesso movimento. È una reazione: si dichiara quando l'avversario attacca, non prima. |

---

## 6. Come si inseriscono, quando dirai di sì

Tutte le righe entrano in `clan_techniques` con `clan = null` e `macro = 'generica'`, quindi compaiono nella sezione **Generiche** del catalogo di ogni personaggio, senza toccare i clan.

Campi da valorizzare, con i vincoli che il database impone:

- `grado` D/C/B · `req_grade` Genin o Chunin · `req_stat` Ninjutsu, Genjutsu o Taijutsu · `req_stat_value` 10/25/40
- `xp_cost` 50/100/150 · `trainings_required` 1/2/2 · `chakra_cost` 5/10/20 · `danno_base` 15/20/25
- `attivazione` **solo** `'istantanea'` o `'sigilli'` · `gittata` **solo** contatto/corta/media/lunga · `consumption_type` **solo** ad_utilizzo/per_turno/passiva
- `req_elements` con `req_elements_mode = 'uno'` sulle quindici elementali
- `is_innata = false`, quindi **occupano slot**: sono tecniche vere, non regali

**Prima dell'inserimento serve una guardia contro i doppioni**: `clan_techniques` non ha unicità sul nome, e un catalogo eseguito due volte si duplica in silenzio (`05_CONVENZIONI` §4).

---

## 7. Che cosa è cambiato con la revisione sul canone

Il compendio della Narutopedia che mi hai passato censisce **3.027 tecniche**, di cui **273 con un rango dichiarato** e **206 prendibili da chiunque** — cioè non Kekkei Genkai, non Hiden, non Dōjutsu. Quelle 206 sono l'unico metro di paragone serio per un elenco di fondo comune. Le ho estratte in un documento a parte, `claude/canone_tecniche_classificate.md`, che resta come bacino da cui pescare in futuro.

**Sette nomi cambiati.**

| Prima | Adesso | Perché |
|---|---|---|
| Fumo e sparizione | **Passo istantaneo** | Nel canone esiste esattamente questa tecnica, di rango D e marcata «abilità generale»: è la prima cosa che ogni ninja impara per spostarsi. Il vecchio nome descriveva l'effetto scenico invece della tecnica. |
| Palla di fuoco | **Grande sfera di fuoco** | Il nome canonico di quella tecnica, alla lettera, è «grande sfera di fuoco», ed è di rango C come la nostra. Aggiungere «grande» lascia libero il nome per un fuoco minore in futuro. |
| Onda di fiamme | **Annientamento di fiamma** | Il grado B del Fuoco, nel canone, si chiama «annientamento»: è la parola che segna il salto da colpo singolo a tecnica d'area. |
| Raffica tagliente | **Grande sfondamento** | È il nome canonico della tecnica base del Vento di rango C. «Raffica tagliente» diceva la stessa cosa in modo più vago. |
| Vortice affilato | **Sfera di vuoto** | Il grado B del Vento nel canone è una famiglia intera di tecniche «di vuoto». Ci allineiamo alla famiglia, non alla singola. |
| **Muro di terra** (D) | **Scudo di terra** (D) | Questo è il cambio che mi premeva di più. Nel canone il «muro di terra» è di rango **B** ed è *il* muro: chiamare così una tecnica D bruciava il nome giusto per la tecnica giusta. La nostra regge un colpo e si sbriciola — è uno scudo. Il nome «Muro di terra» resta libero per un grado B futuro. |
| Combo dei tre colpi (B) | **Combo dei tre colpi** (C) | Non il nome: il **grado**. Nel canone la combo incatenata è di rango C. A grado B stava stretta e rubava il posto a qualcosa di più grosso. |

**Una tecnica nuova: Colpo caricato (Taijutsu B).** Spostando la combo a C restava un buco al grado B, e il canone dice con chiarezza come si riempie: l'unico modo in cui un taijutsu non di clan arriva al livello alto è **facendogli scorrere dentro il chakra**. È una meccanica che nel nostro motore non esiste ancora — un taijutsu che costa chakra — e vale la pena averla: dà una ragione a un taijutser puro per non svuotare la riserva, e crea una scelta vera nel turno.

**Tre cose che ho verificato e lasciato come stavano.**

1. **Barriera minore (C) e Barriera a cupola (B).** Nel canone le barriere sono a cinque sigilli di rango C e diventano formazioni di rango B. La nostra scala era già giusta.
2. **Sogno a occhi aperti a grado B.** Nel canone l'illusione che mostra al bersaglio la propria morte è di rango **D**, non B. Ma la nostra costruisce una scena coerente su un ricordo, che è un'altra cosa: B regge.
3. **Spazzata, Scatto d'assalto e Calcio ascendente.** Tutte e tre hanno un corrispettivo canonico allo stesso identico grado — D, D e C. Non ho toccato niente.

---

## 8. Che cosa dice il compendio sul bilanciamento

### 8.1 · Le nature sono pari nei numeri

Acqua 263, Fulmine 244, Fuoco 229, Terra 192, Vento 187. Una distribuzione piatta: nessuna natura è la Cenerentola del canone. **Questo conferma la scelta di dare a tutte e cinque lo stesso numero di righe** — tre a testa — e toglie di mezzo la tentazione di premiare il Fuoco perché «fa più scena».

### 8.2 · Ma non sono pari nella funzione, e questa è la cosa importante

Contando solo le tecniche a natura singola e guardando a che cosa servono:

| Natura | Offensive | Difensive | Supplementari |
|---|---:|---:|---:|
| Fulmine | **93%** | 7% | 12% |
| Fuoco | **92%** | 8% | 9% |
| Vento | 87% | 13% | 16% |
| Acqua | 78% | 11% | 29% |
| Terra | 71% | 14% | **38%** |

*(Le percentuali sommano a più di 100 perché una tecnica può avere due funzioni.)*

Il canone dice una cosa netta: **Fuoco e Fulmine attaccano e basta; la Terra è l'elemento del controllo e della difesa; l'Acqua sta nel mezzo.** Non sono cinque colori dello stesso jutsu.

Il nostro elenco lo rispetta già a metà — la Terra è l'unica ad avere la difensiva di grado D, e le altre quattro sono tutte offensive. **Ma resta una scelta aperta sull'Acqua**, che nel canone ha una difensiva famosa quanto quella della Terra: se vuoi, il grado B dell'Acqua diventa un muro d'acqua difensivo invece dell'onda che sposta. Le due letture sono entrambe difendibili:

- **Come sta adesso** — Onda montante, spostamento: l'Acqua è l'elemento che muove il campo. Più originale, e la difensiva resta un tratto esclusivo della Terra.
- **In alternativa** — muro d'acqua difensivo: più fedele al canone, e dà due elementi «solidi» contro tre «taglienti». Ma toglie alla Terra la sua unicità.

Dimmi quale preferisci: è l'unica riga delle quindici su cui non mi sono deciso da solo.

### 8.3 · Il grado D elementale, nel canone, non esiste

È la divergenza più grossa di tutto il documento e voglio che sia scritta nero su bianco: **il canone non ha nessuna tecnica elementale offensiva di rango D.** Zero per Fuoco, Vento e Fulmine; per Terra e Acqua ce n'è una a testa, e sono entrambe di supporto, non attacchi. Il repertorio elementale, nel canone, comincia direttamente al rango C.

Noi cinque tecniche elementali di grado D le mettiamo lo stesso, e per un motivo di gioco preciso: **un Genin che ha appena scelto l'elemento deve poter usare qualcosa subito**, non aspettare la soglia 25. Se le togliessimo, chi sceglie l'elemento non guadagnerebbe niente per settimane, e la scelta facoltativa alla creazione diventerebbe una scelta vuota. È una divergenza voluta, e le cinque righe D sono scritte apposta come tecniche piccole: una brace, un taglio d'aria, una scossa, uno scudo che si sbriciola, un filo d'acqua.

### 8.4 · Due conferme che il motore era già tarato bene

**I genjutsu non fanno danno.** Su 45 genjutsu puri del canone, 31 sono di pura utilità e solo 5 puramente offensivi. Che nella nostra scheda i genjutsu abbiano una **Potenza** invece di un danno non è una stranezza nostra: è come funziona la materia.

**Le tecniche accademiche sono di rango E.** Trasformazione, Clone, Sostituzione, Fuga dalla corda e Mantello dell'invisibilità sono tutte marcate «abilità generale» al rango più basso. La nostra regola per cui **il grado E non fa danno** e le accademiche non consumano slot sta esattamente dove il canone la mette.

**E una cosa che invece ci siamo inventati.** Su 191 taijutsu puri del canone, 186 sono offensivi e solo 15 difensivi — e nessuno di quei 15 ha un rango dichiarato. **Parata** e **Guardia di ferro** non hanno un corrispettivo: sono nostre. Vanno benissimo per il motore — servono a dare al taijutser qualcosa da fare quando non attacca — ma è giusto sapere che lì stiamo scrivendo noi, non traducendo.

---

## 9. Da dove pescare la prossima volta

`claude/canone_tecniche_classificate.md` è organizzato per natura e per classificazione, con rango e funzione di ogni riga. Quando servirà altro materiale, questi sono i filoni già individuati:

- **Grado A e S per i clan** — 67 tecniche di rango A e 24 di rango S nel canone, molte delle quali di sangue: è il bacino giusto per i traguardi di clan, non per il fondo comune.
- **Tecniche di sigillo (fūinjutsu)** — nel canone sono una famiglia a sé, con barriere e sigilli di contenimento fra C e B. Da noi non esistono ancora: sarebbero il fondo comune naturale di una futura specializzazione ANBU.
- **Ninjutsu medico** — il canone ne classifica una manciata a rango B. Il Corpo Medico ha lo statuto ma poche tecniche: è il primo posto dove pescare.
- **Tecniche con armi (shurikenjutsu, kenjutsu)** — 186 kenjutsu e una ventina di shurikenjutsu classificati. Da noi le armi non hanno tecniche proprie: è un buco intero, e si riempie con un pacchetto come questo.
- **Cloni** — il canone ne ha una famiglia lunghissima, dal rango E al B. Noi abbiamo solo il Clone accademico. Un clone d'acqua o di terra a grado C sarebbe una ricompensa naturale per chi ha scelto l'elemento.

---

## 10. Che cosa resta da decidere

1. **L'Acqua di grado B: onda che sposta o muro che difende?** (§8.2). È l'unica riga su cui non mi sono deciso da solo.
2. **I sette nomi cambiati ti convincono?** Se preferisci quelli di prima si torna indietro in un minuto: nessuna riga è ancora a database.
3. **Le difensive che costano chakra a ogni turno** (Barriera minore, Barriera a cupola, Scudo di terra, Guardia di ferro) sono una meccanica nuova: il costo si paga finché la tieni. Il motore lo prevede con `per_turno`, ma nessuna tecnica lo usava ancora.
4. **Colpo caricato è il primo taijutsu che costa chakra.** Va bene come principio, o i taijutsu devono restare tutti gratuiti?
5. **Parata, Contrattacco e Scatto d'assalto sono reazioni o azioni rapide?** L'economia del turno (§4.6) prevede una reazione per turno: se restano reazioni, un taijutser ne può usare una sola per turno e la scelta diventa interessante.
6. **Quarantuno bastano per aprire?** Il grado B chiede il Chunin, quindi un Genin appena uscito dall'Accademia ne vede **venti**: diciotto non elementali più le due del suo elemento. Le altre ventuno si aprono con la promozione. Sono mesi di gioco, e i gradi A e S restano ai clan, ai premi e alle tecniche personali, che è giusto.

---

## 11. Che cosa ho guardato nell'altro riferimento, e che cosa ne porto a casa

*Consultato il 31/07/2026 con il browser, sulla scheda pubblica di «Naruto x Boruto GDR — New Rebirth» e sulle recensioni dei suoi giocatori. Il vecchio «Naruto Rebirth» risulta **chiuso**; il sito di gioco del successore non si è caricato, quindi il loro catalogo di tecniche non l'ho visto. **Nessun testo è stato copiato**: qui ci sono solo osservazioni di meccanica e di prodotto.*

**Il numero che ridimensiona tutto: loro dichiarano oltre 50 clan e 1.200 tecniche, costruiti dal 2018.** Otto anni. Noi apriamo con **309 tecniche attive** — di cui 169 di clan, 67 abilità, 41 di evocazione e 32 di cercoterio — e, se approvi questo elenco, 41 generiche. Non è poco per un primo giorno: è il seme giusto, e va detto per non farsi prendere dall'ansia del confronto.

**Quattro cose che copierei come meccanica, non come testo:**

1. **La chat di prova.** Hanno un luogo dedicato dove un giocatore verifica che una tecnica funzioni davvero, prima di usarla in una scena vera. Da noi costerebbe pochissimo — un luogo con un flag, escluso dal calcolo dell'XP e dalla cronologia — e toglierebbe di mezzo la paura di sbagliare in mezzo a una role. È la cosa che aggiungerei per prima dopo l'apertura.
2. **Il tutor assegnato al nuovo iscritto.** Ogni nuovo arrivato viene seguito da un giocatore esperto per il primo mese. Nelle recensioni è la cosa che i giocatori nominano più spesso, prima della grafica e prima delle meccaniche. Da noi non serve codice: serve una decisione e due righe in una bacheca.
3. **Un tetto settimanale alla crescita.** Limitano quanto un personaggio può crescere in una settimana, e i giocatori lo citano come un pregio, non come una costrizione: evita che i primi arrivati diventino irraggiungibili. Da valutare contro il nostro degressivo giornaliero (20/14/10/7), che fa un lavoro simile ma più morbido.
4. **Le descrizioni non ambigue.** Un recensore scrive che alcune loro tecniche lasciano spazio a interpretazioni, e lo staff conferma di aver avviato una **revisione totale delle descrizioni**. Con 1.200 righe è un lavoro enorme. Noi arriveremmo a 350: conviene scrivere bene adesso. Le quarantuno di questo documento sono state rilette con un criterio secco — *che cosa succede esattamente quando la uso?* — e dove la risposta non era ovvia, la riga è stata riscritta.

**E una che mi ha colpito più delle altre.** Il difetto che il loro staff riconosce apertamente non è tecnico: è che **la gente arriva e se ne va dopo poco**. Un recensore lo scrive senza giri di parole, e la risposta dello staff non lo smentisce. È esattamente il rischio che il collaudo di stanotte ha misurato da noi in modo diverso: un nuovo iscritto senza clan che non ha niente da imparare. Loro hanno 1.200 tecniche e perdono lo stesso gente, il che dice che il problema non si risolve solo col catalogo — si risolve con qualcuno che ti accoglie. Il tutor del punto 2 è la loro risposta, ed è gratis.
