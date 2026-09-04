# Manifesto di certificazione qualitativa · replay reali

TASK-ID: `ESAME-GENIN-NARRATORE-FINALE-001`  
Fonte: banco del 03/09, 18 cicli distinti su 7 prove concluse, 17 accettati dalla baseline oggi LIVE v122 (byte-identica alla foto v119). Gli identificativi completi e il testo dei giocatori non vengono ricopiati qui.

## Campione minimo vincolante

| Campione | Fonte sanitizzata | Cicli | Perché entra |
|---|---|---:|---|
| A | prova reale `5c8dda6b…` | 12 | catena completa: difesa, attacco, esito, Sostituzione, Assalto/copie e finale |
| B | prova reale `2399b1fa…` | 1 | personaggio dialogico, colpo al fianco e continuità del fiato |
| C | prova reale `8ec98d42…` | 1 | battuta ellittica da rendere comprensibile col gesto |
| D | prova reale `23d4ccf1…` | 1 | fisicità ravvicinata, postura e cambio di ritmo |
| E | prova reale `7ed1901d…` | 1 | unico respinto storico: `originale_individuato`, prova negativa obbligatoria |
| F | prova reale `c0479cf6…` | 1 | caso pulito senza avvisi, controllo di non regressione |
| G | prova reale `f3f65edb…` | 1 | copia colpita e coerenza fra fatto e racconto |

Il confronto usa gli stessi payload autoritativi della baseline e della candidata. I nomi dei personaggi sono dati di gioco, ma nei referti di review si usano `candidato`, `sfidante`, `Sensei` e gli ID abbreviati per ridurre l'esposizione.

## Matrice deterministica per ogni testo pubblicabile

La Edge, non Luna, associa a ogni blocco le fonti chiuse realmente presenti nella ricevuta e le espande nella forma frase-per-fonte richiesta dai controlli interni:

- `server.scena` — luogo, luce, suolo, attori presenti;
- `server.esito` — esito, zona, gravità, postura e fatto già risolto;
- `server.intenzione` — mossa offerta e bersaglio previsto;
- `server.posizione.esito.candidato` / `.sfidante` — direzione, ampiezza e bordo del rispettivo movimento già risolto;
- il testo legacy `server.posizione.esito` non è una fonte ammessa: non separa gli attori e non autorizza alcun movimento nella candidata;
- `server.posizione.intenzione` — direzione e ampiezza della manovra offerta;
- `server.conseguenza` — segni e memoria fisica;
- `persona.sfidante` — aspetto, voce, reazione e tattica;
- `memoria.stile` — soltanto esclusione di formule, mai fonte di fatti.

L'output di Luna non contiene fonti né claim e non può autocertificarsi. Esito di ogni frase nel referto di certificazione: `coperta`, `invenzione`, `contraddizione`, `fonte assente`. Il validatore respinge automaticamente le violazioni chiuse che sa dimostrare (voce/pensiero del candidato, esito, zona, movimento, persona estranea ed elementi dichiarati assenti). Le invenzioni linguistiche a vocabolario aperto restano rilievi del replay e della lettura indipendente.

## Checklist qualitativa

Per ciclo si segnano anche:

- ampiezza rispettata, inclusi passo breve e bordo;
- nessun dettaglio del testo del giocatore ricostruito: il brief non contiene raw né claim;
- nessuna voce, pensiero o emozione inventata al candidato;
- sfidante riconoscibile da corpo, tattica e voce, senza recitare il dossier;
- nessuna formula, immagine, battuta o chiusura già usata nella stessa prova;
- scena evoluta: almeno uno fra spazio, pressione, controllo, comprensione e relazione cambia;
- nessun tono da referto, metalinguaggio, oggetto o persona inventati;
- un solo paragrafo e lunghezze rispettate.

## Rigenerazione controllata

Ogni ciclo passa dal validatore meccanico. Se ha errori, è respinto e non viene corretto da un secondo modello. La campagna 4.6 percorre comunque tutto A–G per raccogliere le classi di errore della medesima revisione: una sola chiamata per ciclo, nessun retry e nessuna rigenerazione. Il LIVE resta a una chiamata e una sola risposta pubblicabile.

Il confronto di effort si esegue sullo stesso sottoinsieme congelato: `high` è la baseline; `xhigh` si promuove solo con miglioramento misurabile di validità e qualità a costo/latency/timeout accettabili; `max` si prova soltanto se `xhigh` migliora ma non basta. Nessun confronto modifica produzione.

## Soglia di certificazione

- copertura meccanica frase-per-fonte: 100% sui vincoli chiusi; matrice umana/giudice completa anche per le invenzioni a vocabolario aperto;
- campioni A–G eseguiti, incluso il caso negativo E;
- zero P0/P1/P2 nell'unica review indipendente finale;
- nessun ciclo pubblicabile con `errori`;
- nessuna violazione meccanica e tutti i casi previsti verdi senza rigenerazione;
- costo e latenza riportati separando primo tentativo e rigenerazione.

L'esecuzione Luna high richiede la candidata Edge disponibile in replay e il payload DB con ampiezza: è quindi successiva ai gate nominati DB ed Edge, non autocertificabile offline.

## Stato del gate sul branch

Il corpus sul branch QA contiene 18 snapshot sanitizzati e inerti: 11 attacchi, 3 difese, 3 esiti e 1 finale. La campagna congelata sulla Edge v107/4.3 ha dato **18/18 HTTP 200, 0 timeout, 4 validi, 14 rifiutati**. Soltanto A07, A10 e A12 erano verdi anche senza rilievi qualitativi; B era strutturalmente valido con un rilievo.

I **50 blocker** si riducono a quattro categorie: 30 binding autoritativo/temporale/bersaglio; 15 forma o budget, inclusi due tetti token; 4 falsi positivi del riconoscitore di persone; 1 rifiuto provider `invalid_prompt`. I rilievi non bloccanti sono 13: nuovo assetto poco leggibile 9, tono da referto 2, branca condivisa 1, formula ripetuta 1; più 2 avvisi.

Telemetria congelata 4.3: latenza media 26,8 s, p50 25,1 s, p95 e massimo 57,3 s; tempo modello cumulato 482,2 s. Token registrati: 60.981 input, 49.425 output, dei quali 32.797 reasoning; costo stimato $0,0715. La funzione DB006 è stata ripristinata esatta e i token runtime del banco ruotati.

La candidata conclusiva è `4.7.1-NU001-CANDIDATO`/prompt30. Conserva slot semantici chiusi, atomi server-side e alias nominativo esatto; sostituisce lo strict JSON annidato con un vettore minimo ricomposto dal server per azione e rami. Tetto uniforme 1.024, Luna/high con verbosity medium e una chiamata. Gate locale 189/189, checksum 9/9 e review finale `0/0/0`. Unico A08 sul branch: HTTP 200, stop, una chiamata, 0 motivi/qualità/avvisi e nessun fallback. La stessa revisione è stata distribuita in produzione e riscaricata 9/9 byte-exact.

Smoke LIVE completo con `testperfunzioni`: 10 cicli (`png_difende` 4, `png_attacca` 3, `png_esito` 2, `png_finale` 1), tutti risolti da `gpt-5.6-luna` con prompt30 e stop normale; 0 ripieghi e 0 cicli non conformi. Prova e sessione chiuse dalle porte ordinarie, progressione isolata (XP 0, grado invariato), Test Room ripristinata e postflight globale pulito.

Prima campagna completa Luna/`high` sulla Edge QA v118: **18/18 casi A–G lanciati una volta, nessun retry**. Diciassette risposte HTTP 200 sono incomplete per `tetto_token_raggiunto`/`max_tokens` prima della composizione; il finale A12 è fermato prima del provider perché la fixture sanitizzata non conserva il Sensei. I due finding sono stati aggregati prima della revisione a slot chiusi. Poiché la review conclusiva della revisione aggregata è rossa, A–G non viene ripetuta e il gate produzione resta chiuso.

Ricertificazione conclusiva Luna/`high` sulla Edge QA v119: **18/18 casi A–G lanciati una volta, nessun retry; 16 verdi e 2 rossi**. A11 e D (`png_attacca`) hanno raggiunto esattamente 8.192 output token e sono stati fermati con `stop_reason=max_tokens`; gli altri casi si sono chiusi normalmente. Totali: 15.082 input, 20.918 output, 3.221 reasoning; latenza media 11.755 ms, massima 85.024 ms. Il limite token del provider è separato dai tetti di caratteri della prosa. Postflight: zero prove aperte, zero azioni senza esito, zero cicli non terminali; token runtime ruotato. Gate produzione chiuso.

Certificazione conclusiva Luna/`high` sulla Edge QA v120: **18/18 casi A–G verdi**, una chiamata per ciclo, nessun retry e zero motivi, rilievi qualitativi o avvisi. Output per caso 183–521 token; totali 15.048 input, 4.932 output, 3.379 reasoning; latenza media 3.688 ms, massima 5.798 ms. Postflight: zero prove aperte, zero azioni senza esito, zero cicli non terminali; token runtime ruotato. Candidata pronta al gate nominativo di produzione.

Ultimo gate autorizzato Luna/`high`, verbosity medium, Edge QA v125/4.6.6: **15/18 pulite** alla singola chiamata; A08 `png_difende`, A09 e A17 `png_attacca` saturano esattamente 11.798 output token con `max_tokens` (65.818–68.626 ms). I 15 verdi hanno azione 438–1.159 caratteri e zero qualità/avvisi. Totali: 15.082 input, 39.193 output, 2.768 reasoning; latenza media 14.374 ms. Postflight: token ruotato, zero prove aperte e zero cicli non terminali. Gate produzione negato; vietato cercare un verde con nuovi retry.

La verifica mirata precedente sulla 4.4.1 aveva A03 `png_esito` verde (1.869 input, 2.977 output, 280 reasoning, 24.688 ms) e A02 `png_attacca` respinta con `invalid_prompt`. Dopo il primo tentativo operativo che aveva selezionato A01 per errore, A02 è stata ripetuta correttamente una sola volta con `ciclo_id=…0002`, `massimo=1`, trasporto 210.000 ms e nessuna rigenerazione. Risposta HTTP 200, funzione `4.4.1-NU001-CANDIDATO`, 7.867 ms, 1.770 input, 579 output di cui 372 reasoning, stop `stop`, costo stimato $0,0010488. Esito rosso: `azione_png` contiene una battuta senza attribuzione esplicita e un nuovo esito senza fonte server; 2 rilievi qualitativi, 0 avvisi. Nessun testo completo o PII è conservato nel referto. Nessun retry; A03 non rilanciata e condizione «A02 e A03 verdi sulla stessa revisione» non soddisfatta. Campagna A–G non avviata.

Gate 4.4.3 mirato: A02 `…0002` verde, HTTP 200, 10.408 ms, 2.113 input, 719 output/516 reasoning, stop normale, 0 blocker, 1 qualità, 0 avvisi. A03 `…0003` rossa, HTTP 200, 10.655 ms, 2.135 input, 1.514 output/1.272 reasoning, stop normale: `azione_png` contiene una cifra e nomina la persona estranea `(Need)`; 1 qualità, 0 avvisi. Una chiamata ciascuna, nessuna rigenerazione o retry; A–G non avviata. Postflight: Edge v114 9/9 esatta; 18 cicli `scartata`, quattro referti fixture, zero prove aperte, zero agent attivi; token runtime ruotato server-side, mai letto. Produzione non toccata: Edge v123/recovery `ACTIVE`, `verify_jwt=false`, SHA-256 `cbd35e02ec51ff2c99d263ffbffe41ac01dfbf700788030f0f62203d417372b3`.

Gate 4.4.4 mirato: A02 `…0002` pienamente verde, HTTP 200, 38.954 ms, 2.363 input, 3.433 output/3.106 reasoning, stop normale, 0 blocker/qualità/avvisi. A03 `…0003` rossa, HTTP 200, 13.398 ms, 2.385 input, 1.512 output/490 reasoning, stop normale: `azione_png` contiene un a capo e non è un paragrafo unico; 0 qualità/avvisi. Una chiamata ciascuna, nessuna rigenerazione o retry; A–G non avviata. Postflight: Edge v115 9/9 esatta; 18 cicli `scartata`, quattro referti fixture, zero prove aperte, zero agent attivi; token runtime ruotato server-side, mai letto. Produzione non toccata: Edge v123/recovery `ACTIVE`, `verify_jwt=false`, SHA-256 `cbd35e02ec51ff2c99d263ffbffe41ac01dfbf700788030f0f62203d417372b3`.

Gate 4.4.5 mirato: review indipendente `0/0/0`; Edge QA v116 `ACTIVE`, 9/9 byte-esatta, bundle SHA-256 `eb8176cab5c55ddcb5b65913cc5d31ffd3ef9913794e4675fe8448ccdfad729f`. A02 `…0002` verde, HTTP 200, 20.668 ms, 2.363 input, 1.916 output/1.552 reasoning, stop normale, 0 blocker/qualità/avvisi. A03 `…0003` rossa, HTTP 200, 9.814 ms, 2.385 input, 868 output/645 reasoning, stop normale: non racconta un contatto compiuto per l'esito `colpito` e la chiusura non rende leggibile il nuovo assetto; 0 qualità/avvisi. Una chiamata ciascuna, nessuna rigenerazione o retry; A–G non avviata. Postflight: 18 cicli `scartata`, quattro referti fixture, zero prove aperte o azioni pendenti; token runtime ruotato server-side, mai letto. Produzione non toccata: Edge v123/recovery invariata.

Gate strutturale 4.5.0 mirato: unica review indipendente chiusa `0/0/0`; Edge QA v117 `ACTIVE`, 9/9 byte-esatta, bundle SHA-256 `01662356988b2bc944057e5bb5e8ff940f3880e13c8af469ee53d254840ae143`. A02 `…0002` verde, HTTP 200, 36.782 ms, 2.554 input, 3.270 output/2.983 reasoning, stop normale, 0 blocker/qualità/avvisi. A03 `…0003` rossa, HTTP 200, 18.840 ms, 2.585 input, 1.724 output/1.388 reasoning, stop normale: il segmento dell'esito attribuisce il risultato all'attore sbagliato e l'assetto finale non è leggibile; tre segnalazioni meccaniche complessive, di cui due sul medesimo difetto di assetto, 0 qualità/avvisi. Una chiamata ciascuna, nessuna rigenerazione o retry; condizione per A–G non soddisfatta e campagna non avviata. Postflight: 18 cicli `scartata`, zero fixture non scartate, quattro referti fixture, zero prove aperte o azioni pendenti; token runtime ruotato server-side, mai letto. Produzione non toccata: Edge v123/recovery `ACTIVE`, `verify_jwt=false`, SHA-256 `cbd35e02ec51ff2c99d263ffbffe41ac01dfbf700788030f0f62203d417372b3`.
