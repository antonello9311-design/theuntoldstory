# Integrazioni Combat · piano operativo corrente

Stato: in lavoro · 07/11/2026. Mandato iniziale: organizzare le mosse non integrate nel pannello. Mandato successivo esplicito di Antonello: «Procedi per portare a termine e collaudare copertura/diversivo e punto cieco». Prima tranche esecutiva limitata a queste tre funzioni. Inventario delle altre famiglie conservato, senza avviarne lo sviluppo.

**Decisione del 13/11/2026.** Copertura e Diversivo sono ritirati dal perimetro Land. I relativi collaudi e l’apertura pubblica escono dai lavori attivi. I risultati S24 e le ricevute restano nello storico. Il punto cieco Byakugan resta una voce distinta, con le prove già concluse acquisite.

Il lavoro attivo di questa tranche riguarda il punto cieco. Piano e campagna del 07/11 sono conservati di seguito come riferimento storico.

## Checkpoint storico del 07/11/2026

Il pannello Common riceve offerte server dinamiche: non serve un pulsante scritto a mano per ogni tecnica. L'inventario distingue codice mancante, disponibilità chiusa, requisiti del PG e prova non attestata. Fonte: COMBAT_MOSSE_INVENTARIO.md, ricognizione DB 07/11 di 12 SELECT, zero mutazioni/provider.

I due helper Copertura/Diversivo sono già installati ai posthash 86d93a7e6f27d8e7adf6f852f8ef3de3 e da598c61bb0359fe2fa0b5ce151e768f. Gate tattiche versione2: Staff=true, ordinary/master/generic=false. Facing possiede già orientations/defense_receipts e gate revisione2 Staff=true/public=false. Provenienza da riconciliare con Stage C58/Consumer D del 02/11; i vecchi handoff sorgente non sono installer da rieseguire. Nessun PASS runtime deriva da questi riscontri.

GitHub main13daea7169c67791a20924b07490ebfbb6bc95ed, LAND pubblicata blobcae4e0da5760bf062e79c6595e5d4ce608d615ca. La LAND locale blob502292709cf4fb15dcbe5129990d67df0b08c7b6 ha drift: conservare entrambi, usare gli estratti remoti per il contratto e riconciliare con il file vivo prima di qualsiasi patch. Nessuna sovrascrittura della copia locale in questa tranche documentale.

Le nove Innate mantenute e il raccordo descrizione→Scontro sono conclusi/pubblici: non si riapre quel collaudo e non si ripetono costi già applicati. Quest IA generale, Scorta ordinaria, PG reali, Party, storico e ricevute rimangono fuori dalle mutazioni di prova.

## Priorità e assegnazioni del piano storico

| Ordine | Consegna | Owner e dipendenze | Esito richiesto |
|---|---|---|---|
| 1 | Continuità Tactics e Facing | DB-CORE + COMBAT-CORE; letture pertinenti, revisione delle prove Stage C58/Consumer D | Identità di corpi/gate/consumer/permessi e isolamento Staff; distinguere casi già attestati e mancanti. Nessun reinstallatore obsoleto. |
| 2 | Copertura e Diversivo nel percorso reale | COMBAT-CORE e LAND-UI dopo1; QA indipendente | Offerte, costo unico, movimento, figure e scelta privata prima delle difese; cessione iniziativa, risoluzione e Fato coerenti. Ordinary/Master, PG/PNG nei percorsi previsti; nessuna scelta PG inventata. |
| 3 | Punto cieco Byakugan | COMBAT-CORE dopo1; stessa autorità Innata già qualificata, QA geometrico indipendente | Retro180° con dot<0, laterale escluso; orientamento dall'ultima propria azione conclusa/primario certificato. Deduzione3/2/1/0 una volta, niente deduzione su origine ambigua/coincidente. Non cambia riconoscimento copie o formule base. |
| 4 | Correzione dei soli difetti osservati | Owner della causa e integratore unico | Candidato DB/UI/Edge/config/recovery coerente, delta minimo, review pertinente0/0/0 prima di apply. Riverificare soltanto il caso e le regressioni pertinenti. |
| 5 | Consegna qualificata e disponibilità | PM/Rilascio dopo PASS Staff del relativo perimetro | Audit e custodia esatti, proprie prove chiuse. Apertura delle tecniche collaudate secondo mandato10/09, stessa versione; nessuna apertura Quest IA generale o modo non provato. |

Backend e UI possono procedere in parallelo soltanto con contratto stabile. Un solo integratore modifica le pagine condivise; gli altri consegnano delta isolati. Il JSON COMBAT_MOSSE_PIANO.json rinvia alla sola task esecutiva già acquisita COMBAT-TACTICS-FACING-QA-20261107: le righe della tabella sono fasi della medesima consegna, non prenotazioni duplicate. Eventuali delta correttivi saranno registrati solo contro input pronti.

## Campagna Staff prevista dal piano storico

Owner QA-COMBAT-TACTICS-FACING; sole modalità protette con Riuji/Tamako e testperfunzioni se serve un Master separato e già autenticato. Tetto90min dal primo comando funzionale dopo preflight, 16casi, 8scene e120comandi; 0provider, 0token e0USD. Il residuo economico Innata non viene riutilizzato. Prima dello scambio verificare che il percorso non invii automaticamente una chiamata IA. Un caso che la richiede resta sospeso finché esiste un budget dedicato; nessun retry esplorativo o ampliamento automatico della finestra.

Il runbook definitivo seleziona i soli casi non attestati: entrambe le tattiche in ordinary/Master, attaccante/difensore/PNG ove previsti; iniziativa privata e difese prima della risoluzione; Facing fronte/retro/laterale/assenza-origine, livelli pertinenti e primario/marionetta quando rappresentabili dalla geometria già autorizzata. Le letture non sostituiscono il percorso giocato. Nessuna geometria manuale SQL né fixture o motore locale.

Prima: fotografare risorse reali e Scorta, sessioni aperte, stato/profilo/risorse simulate e ricevute pregresse. Durante: aggiornare contatori e conservare ricevute. Dopo: chiudere solo proprie prove, verificare custodia e assenza residui. Uno stato già attivo non si riattiva; un cambio profilo passa dai normali comandi protetti e non azzera journal o contatori.

## Famiglie successive, non avviate

1. Contratto delle rapide aggiuntive: lancio arma, estrazione/riporre, mira e relazione con principale/reazione; l'etichetta rapida del catalogo non crea un secondo slot.
2. Cure e oggetti: Palmo Curativo, bersaglio alleato/KO, contatto e turno intero; inventario, cariche, limiti e ricevuta comune. L'uso Oggetto esiste già fuori dal Common.
3. Armi equipaggiate: fonte autorizzata, offerta, portata, munizioni/consumo e conseguenze; non dedurre assenza dal renderer dinamico.
4. Richiamo ed evocazioni: rituale/interruzione, ingresso e lifecycle, upkeep/congedo, poi combo/passive con un'unica azione. I comandi Staff per PNG non certificano il Richiamo del PG.
5. Effetti specifici degli altri clan e multibersaglio: usare il producer dinamico per gli attacchi già rappresentabili; integrare solo conseguenze realmente mancanti. Esclusioni intenzionali di scena, Contromossa/opportunità e Flussi multibersaglio restano nel proprio scope.

## Continuità storica

La ricognizione del02/11 e i suoi hash sono conservati in COMBAT_INTEGRAZIONI_STATO.json §historical. Le affermazioni allora «due helper mancanti», «Facing non trovato» e «Innata senza emittente» sono superate dai riscontri e rilasci successivi. Restano fonti di provenienza, non indicazioni per reinstallare corpi o riaprire costi. Review e contatori precedenti non si azzerano.
