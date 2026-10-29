# Quarta prova · conclusione e review

La quarta missione è conclusa normalmente. Il blocco SQL42702 è corretto e il percorso pacifico successivo ha attraversato apertura, tre coppie di azioni, tre risposte e chiusura senza altre correzioni o retry. Il precedente avvio fallito resta documentato; non viene trasformato in un successo al primo tentativo.

## Correzione installata

Un solo alias SQL nell’inizializzatore: `step` diventa `phase_identity(value)` e la query usa `phase_identity.value`. Variabile di ciclo, regole, controlli di identità, ABI, permessi e vincoli restano invariati. Installer atomico: confronto Root e226header, funzione corretta, Root aggiornata, rilettura226header e confronto9impronte protette; errore annulla l’intera transazione. Review indipendente12 e materiale0/0/0; conteggi precedenti conservati. Migrazione `c1266_sql59_scene_init_alias_staff`; Root `93faf010af6aa64e6693fb411796f71acbed30d2baf39b6ca9a7d811dad1abc8`, semantica `eb9a3c7339ac0aeb769d51851be902d381cd168a6f89c3253f553f2a8227fbb0`. Edge119, UI1, schedeV5 e revisione5 invariati.

Il primo avvio congelato aveva fallito alle21:54:17.755UTC con `column reference "step" is ambiguous`, funzione scene_initialize linea37. Nessuna sessione o provider era stata creata. La richiesta38c0b037 era stata risolta dal normale comando come rejected_no_commit. Questa evidenza e il relativo audit sono conservati.

## Percorso effettivamente eseguito

Sessione `93053f1e-7a4e-4ed9-b73c-df8bae2c361e`, avvio22:06:45.646080UTC, chiusura22:12:33.862817UTC, motivo `completata`, run `conclusa`, fase `fase_4`. Sei azioni normali Riuji/Tamako valide e accettate una sola volta; quattro work completati con messaggi e ricevute, nessun recupero o rigenerazione.

| Fato | Pubblicato UTC | Parole | Avanzamento |
|---|---|---:|---|
| D0 | 2026-10-29T22:07:30.437674+00:00 | 181 | stay |
| D1 | 2026-10-29T22:09:29.334463+00:00 | 276 | scene:conclusione |
| D2 | 2026-10-29T22:10:51.920757+00:00 | 242 | scene:fase_4 |
| D3 | 2026-10-29T22:12:18.059887+00:00 | 130 | complete |

Il Fato finale `2727ded3-dfe5-4312-84c5-9d69d8705c74`, SHA `d67ff6f9c7e0d8294af04b5215b0e336c0d8cebf0059ab86693c968358edfe8e`, è visibile su IABRiuji e ChromeTamako. Rilettura dopo uscita/rientro Tamako positiva, senza rigenerazione. La chiusura è stata eseguita con Concludi la prova, non annullando. Postflight:0Staffaperte,0workpropri pendenti,0Combat. Cache D conservata con modeclosed/turn_ownerclosed, is_activetrue: è storico leggibile, non una sessione aperta. La rotta pacifica ha saltato legittimamente la fase meccanica; ingresso/turni/uscita Combat su questa versione restano NOT_RUN.

## Qualità osservata

Le tre risposte iniziano da parole e scelte dei PNG, senza ricopiare battute dei PG o raccontare nuovamente il loro avvicinamento. Confronto normalizzato a cinque parole:0sequenze comuni fra ogni Fato e tutte le azioni PG accettate precedenti; l’assenza di coincidenze non è da sola una prova contro la parafrasi. La lettura distingue risposte pertinenti ai fatti acquisiti da ripubblicazione della prosa PG. Daichi e Keita espongono motivazioni diverse; pagamento, rettifica e indicazione del luogo producono avanzamenti reali.

L’ambiente mantiene occupazioni e spazio di passaggio; non reagisce tutto insieme né ricrea la folla ad ogni turno. Resta però quasi sempre ridotto a banco, cliente, venditore e varco. D3 si accorcia a130parole e il contesto fisico rimane poco sviluppato. Non serve un minimo di parole: servono dettagli pertinenti che cambino possibilità, ritmo o conseguenze.

Restano tre limiti editoriali. D0 apre in mediasres con frasi che presuppongono una discussione precedente; il payload nuovo aveva roles[],last_fati[],memorynull, quindi questo non prova contaminazione delle prove ABC. D1,D2,D3 riprendono parte di ammissioni e limiti già esposti dai PNG; gli ultimi periodi tornano alle questioni aperte. Alla domanda sul possesso attuale di foglio e monete il PNG non sa indicarli: manca una continuità positiva degli oggetti, mentre l’ignoranza sul mandante viene applicata troppo ampiamente.

## Correzioni proposte dopo la review

1. Distinguere semanticamente apertura, continuazione e chiusura nel contesto del generatore. Nell’apertura costruire il primo quadro dalla fase selezionata, senza presupporre battute o mutamenti non avvenuti.
2. Conservare nelle schede e nella memoria lo stato concreto degli oggetti pertinenti: possesso, ultimo luogo noto, passaggio di mano o decisione. Separare ciò che il PNG sa delle proprie azioni da ciò che ignora sugli altri.
3. Usare spazio, attività e reazioni locali per conseguenze utili alla scena; selezionare ciò che è mutato invece di riproporre una coda ambientale equivalente.
4. Passare dagli accordi acquisiti ai gesti successivi; evitare nuove dichiarazioni equivalenti e bilanci delle incognite come chiusura automatica.

5. Rendere leggibili modi e toni attraverso parole e comportamenti osservabili; evitare che il narratore spieghi intenzioni o il modo corretto di interpretare una reazione.

Sono criteri generali e dati di continuità, non nuovi elenchi di parole vietate, quote obbligatorie o filtri che fermano il turno. Nessuna modifica ai testi D e nessun nuovo collaudo avviato per migliorare la prosa.

## Contabilità e preservazione

| Prova | Fati | HTTP | USD prudenziali |
|---|---:|---:|---:|
| A |12|62|0,47600170|
| B |9|37|0,33861150|
| C |6|20|0,17132990|
| D |4|8|0,05902220|
| Totale |31|127|1,04496530/4|

D usa4Count+4Generation. Le4Count hanno costo non liquidato: la loro riserva è conservata. Token noti delle Generation:26.202input/13.604output; uso Count UNKNOWN, non zero. Le9impronte ABC (Fati, work, quote/costi, role, scene, binding, gameplay, sessioni e conteggio) coincidono esattamente prima/dopo installazione e missione. Tutti31FatiABCD conservati, nessuna role reinviata o premio reale; nessun cambio infrastrutturale. Report sanitizzato: niente role complete o schede private PNG nel deposito pubblico.

Review editoriale indipendente conservata nell’evidenza SQL59; i relativi rilievi non sono gate di rigenerazione.
