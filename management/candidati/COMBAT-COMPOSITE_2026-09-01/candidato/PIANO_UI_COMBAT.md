# Semplificazione del pannello Combat

## Superficie

Intervenire sul pannello condiviso in `sito_live/land.html`, riconciliato con la versione pubblicata. Coprire duello, Master, Regia IA e Staff. I dati di movimento, attacco, difesa e risoluzione continuano a provenire dalle offerte e dalle ricevute del server.

- Mostrare in alto turno e azione richiesta. Mettere in primo piano mappa e un solo comando di conferma. Raggruppare strumenti di gestione, legenda e ricevute nei dettagli.
- Movimento: scegliere direttamente una destinazione legale sulla mappa. Evidenziare le caselle offerte, distanza e posizione d’arrivo. Fornire la stessa scelta in un elenco accessibile da tastiera.
- Attacco: scegliere tecnica e bersaglio o punto d’impatto direttamente sulla mappa. Ricavare la direzione dal punto scelto. Preselezionare un’unica opzione legale, mantenendo la conferma esplicita del giocatore e mostrando le alternative solo quando hanno un effetto diverso.
- Difesa: mostrare subito l’attacco a cui si risponde e le difese legali. Se arriva un solo attacco, associarlo automaticamente alla scelta. Con più attacchi, scegliere quello da difendere nello stesso passaggio. Usare una sola reazione.
- Master e IA: mostrare modalità, bersaglio o punto, costo, danno e spostamenti dal server. Riunire le valutazioni nello stesso pannello e tenere il Fato vicino all’esito. Verificare che il testo visibile appartenga alla dichiarazione corretta, anche dopo recupero della vista. L’IA usa il risultato del server.
- Sincronizzazione: recuperare la vista dopo un evento di round e conservare il testo in bozza. Una conferma già accettata deve restare riconoscibile dopo aggiornamento o riconnessione.

## Pulizia Staff

`test_room_svuota` usa cancellazioni fisiche su tutte le location di prova, comprese le righe del Combat precedente. La pulizia va resa circoscritta alla Staff Test Room: nascondere o disattivare soltanto contenuti di collaudi chiusi, preservando prove e ricevute tecniche e lasciando visibili attività in corso. Inventariare prima i record e i vincoli. Riutilizzare i meccanismi di visibilità esistenti dove disponibili. Se manca un percorso di disattivazione adatto, aggiungere una funzione mirata con autorizzazione Staff e verifica sulla stanza singola.

## Verifica

Review di client e contratti prima della pubblicazione riservata Staff. Verificare in Staff la selezione mappa via puntatore e tastiera, un attacco singolo e un attacco a punto, una difesa su più attacchi con una sola reazione e il passaggio al Fato con Master e Regia. Verificare la leggibilità su schermo stretto e il recupero dopo ricarica. Riutilizzare B10 e B3 come evidenza meccanica, usando solo casi necessari per la nuova UI.
