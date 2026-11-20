# NinjaBook Staff R2 · Conferma del roster

La conferma del 20 novembre alle 08:59:12 UTC ha trovato un prerequisito mancante. Il roster fisso richiede testperfunzioni e Riuji vivi e con presenza in Staff più recente di due minuti. Per Riuji l’ultimo heartbeat registrato era alle 08:43:54.191 UTC, 918,592 secondi prima della risposta. La guardia rifiuta la richiesta con `staff_nb_scene_unavailable` e SQLSTATE `42501` prima di creare Combat, offerta nativa e ammissione.

La scena `4d1c7ff7-5d6d-464a-b996-59140a636c0d` aveva owner umano testperfunzioni con ruolo `master`. Il server ammette i ruoli `master` e `admin`. Lo stesso principal possedeva le due fonti offerte e l’offerta amministrativa con role non richiesto. Il claim Master era valido tra 08:58:47 e l’annullamento alle 08:59:37. Il gate NinjaBook era acceso in Staff e spento in pubblico. Il controllo di autorizzazione della coppia è positivo in sola lettura sullo stato successivo alla prova.

L’offerta verifica i requisiti di preparazione, che non comprendono la presenza contemporanea dei due PG. La conferma aggiunge quella condizione. Il wrapper intercetta il 42501 e lo restituisce dentro una risposta HTTP 200 con il messaggio generico visto nel pannello. I rifiuti di formato usano SQLSTATE della classe 22 e messaggi distinti. Il frame specifico del 42501 non è persistito. L’audit corrente di rifiuto richiede un encounter e questa operazione lo deve ancora aprire.

Postflight della sola scena. Due fonti offerte, zero ricevute di conferma, zero ammissioni, zero offerte native, zero Combat e zero nuovi partecipanti. La scena è annullata. La prossima prova pertinente richiede la presenza ordinaria simultanea dei due PG. Il solo rifiuto con un PG assente non giustifica un cambio di permessi, roster o shape.
