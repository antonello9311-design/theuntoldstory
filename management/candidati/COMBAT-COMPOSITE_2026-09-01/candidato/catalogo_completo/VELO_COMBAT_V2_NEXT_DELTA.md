# Velo del Cercoterio · prossimo delta Combat V2

Il 20 novembre la Root osservata è `0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d`. La riga catalogo è `c9b261da-c9cd-40bb-8189-7b65ab5a1605`, SHA-256 `a79a36d47fe260c0db0d965703cef3b41d98c39530605382d6a8c68109d78229`. Il tipo di uso rapido è già installato. La lettura trova zero Forze Portanti, assegnazioni Velo, dichiarazioni Combat V2 e snapshot vivi con la tecnica.

## Regole determinate

- Tecnica D per Forza Portante Genin, Sintonia almeno 10, 50 XP per acquisirla. Indicazione personale, attivazione istantanea con la rapida. Il catalogo indica 5 chakra per turno.
- Velo attivo a zero code. Aggiunge 5 alla Forza e 5 alla Velocità efficaci del personaggio. La Potenza e i metri seguono le formule già vigenti. A Velocità 20 il budget passa da 10 m a 10 m, a Velocità 25 passa da 10 m a 15 m. Il Velo non introduce un bonus fisso di 5 m o 5 danni.
- Il Velo non produce bonus di Resistenza, guarigione, danni da contatto, contraccolpo, code o possessione. Le meccaniche del Manto e il passaggio Velo–Manto restano nel proprio incarico.
- §5.2 distingue il valore dichiarato nel catalogo dal mantenimento già eseguito dal server. §4.2 e §4.7 indicano l’unica rapida e lo scope della guardia. Il nuovo controllo iniziale è una funzione Staff esplicita.

## Delta proposto per review

1. Produrre un’offerta personale di controllo Velo dai percorsi ordinario e Master del pannello Comune. Validare lato server l’attore, il turno personale, la proprietà dell’offerta, la fase e la policy Staff. Il server determina l’operazione dal record offerta. Il client invia il comando canonico.
2. Riutilizzare lo schema di stato e transizione locale allo scontro delle Innate mantenute, previa integrazione del ramo di ammissione specifico. Quattro Zampe usa la stessa transizione da entrambi i consumer. Il suo bonus piatto di movimento e le sue regole di difesa appartengono alla sua tecnica. Prevedere un solo effetto attivo con ricevute idempotenti per turno e costo simulato. Il ledger generico V2 non contiene una voce rapida. Identificare il vincolo condiviso esistente o introdurre quello necessario limitatamente alla candidata Staff, mantenendo una sola rapida e una principale indipendente.
3. Congelare le modifiche di Forza e Velocità nei valori efficaci server del turno. La quota movimento legge la Velocità efficace prima dell’arrotondamento e sottrae i metri già spesi. Offerta, validatore, risoluzione degli attacchi e proiezione devono leggere la stessa autorità. Dichiarazioni e Fati già congelati conservano i loro valori. UI e narratore ricevono stato, costo ed esiti dal server.
4. Riservare l’ID Velo al suo controllo sul backend. I percorsi generici di dichiarazione offensiva e di Test Room utenti ammettono l’uso rapida dal catalogo. Evitare di partire da una concessione nello snapshot generico. Il profilo di prova può usare soltanto l’ammissione locale di una scena Staff autorizzata, attraverso il pannello esistente, senza rendere un PG reale Forza Portante.
5. Acquisire il checkpoint Root vivo prima di comporre modifiche a hook di turno, offerte, proiezioni e risoluzione condivise. Review aggregata e recovery conservativa per chiudere la disponibilità Staff preservando ricevute e storia. Allineare entrambe le copie del regolamento quando la disponibilità o la descrizione del motore cambia.

## Decisioni e verifiche aperte

- La fonte fissa 5 chakra per turno. Resta da confermare se adottare per Velo la convenzione già usata dalle Innate mantenute, con 5 sull’attivazione e 5 all’avvio dei turni personali successivi. Questo determina il comportamento con riserva insufficiente. Anche costo, finestra e slot dello spegnimento volontario vanno fissati. Chiusura della scena e perdita di controllo devono rimuovere l’effetto locale preservando la storia.
- Esiste già il controllo di acquisto per le bestie nominate tramite `req_cercoterio`. Il Velo è universale fra le bestie e ha il campo nullo, quindi il suo ingresso deve verificare esplicitamente la qualità di Forza Portante e la tecnica appresa. Prima di un’apertura pubblica va verificato l’intero percorso di acquisto del Velo e il contratto degli slot. La riga usa `is_innata=true`, che già esenta la verifica generica degli slot, mentre §5.2 nomina le Innate di clan. Nessuna modifica di metadati numerici è proposta.
- Per il collaudo Staff serve un’ammissione simulata identificabile e legalmente sufficiente, perché nessuna scheda possiede il Velo. Verificare su duello senza Master e scena con Master. Casi pertinenti: ingresso al turno e consumo di una rapida lasciando la principale, risorse e bonus osservabili nell’attacco e nello spostamento, mantenimento senza raddoppi, fine effetto e postflight. Il soggetto, il chakra e le decisioni del giocatore restano protetti.

## Fonti

- `sito_live/REGOLE.md` e `sito_live/regole.html` §8.9, §5.2, §4.2, §4.5, §4.7. `claude/cercoteri_spec.md` §4.2.
- `combat_panel_private.movement_budget(uuid,uuid)` MD5 `57546d18129f1fd09b05aeecfca00403`. `combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)` MD5 `e7ec43224a4640d00c53bad72ac0132d`. Adattatori Quattro Zampe `clan_inuzuka_private.commit_control(jsonb,jsonb)` e `commit_master_control(jsonb)`.
- `public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)` MD5 `77f98c15d1778bd7cc5e6fdfe8d221b8`. `public.training_eligibility(uuid,uuid)` MD5 `fdc29cffebae65a0be398f4641fdca8e`. `public.tecnica_vincoli_extra(uuid,uuid)` MD5 `d54847146e41c63a953ac226322eae22`.

## Prossimo passo di implementazione

Comporre un candidato Staff con il comportamento esistente delle Innate mantenute come riferimento: 5 chakra per il turno di attivazione, 5 all’avvio di ogni successivo turno personale. Il budget di movimento usa la Velocità aggiornata e conserva i metri già spesi. Verificare sul comando della guardia il vincolo della singola rapida condivisa dal regolamento. Esplicitare nel contratto della candidata la finestra dello spegnimento, l’effetto della riserva insufficiente e la precedenza con eventuali Innate. La firma funzionale e l’allineamento di §4.2, §5.2 e §8.9 restano oggetto della review.
