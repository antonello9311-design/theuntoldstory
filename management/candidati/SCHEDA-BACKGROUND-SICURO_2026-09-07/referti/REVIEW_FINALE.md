# Controverifica finale — SCHEDA-BACKGROUND-SICURO-001

07/09/2026 · unica controverifica dopo l’unica correzione aggregata · esito **0 P0 / 0 P1 / 0 P2 nel perimetro revisionato**. Ciclo di review terminato; nessun nuovo esempio o richiesta di patch.

## Revisione verificata

- `candidato/scheda.html`: 277.695 byte, SHA-256 `9d2cc64ef2a05093d8ad5c6ea60e498802eaa0a1a3fd1237c2955f7fb23adb90`.
- `candidato/background.js`: 9.968 byte, SHA-256 `be17d939cec08203db1b0a38465b06d7643b9acc5a016ec001252f3156664fb1`.
- `build.py`: 4.337 byte, SHA-256 `8b39c9bdbf1621da7b9f34731e54715df8e185ee84fc12e883e0ef3bf23bb745`.

Confronto diretto con `referti/MANIFEST.json`: SHA e byte 3/3 MATCH. La pagina composta è stata verificata per identità, senza estendere la lettura al codice applicativo estraneo al delta.

## Chiusura del finding

Il P2 di `REVIEW.md`, `candidato/background.js:71–84`, è risolto: il contenitore viene creato con `fragment.ownerDocument.createElement('div')`. L’append conserva il documento proprietario inerte del frammento DOMPurify; non adotta più le immagini con src nel documento principale. Il ramo testo semplice usa il documento principale ma contiene esclusivamente un nodo testuale. Consenso, validazione URL, attributi di privacy e CSP restano presenti.

Nel builder è inoltre inclusa la licenza DOMPurify in un commento del blocco incorporato; resta il controllo contro una chiusura script nella dipendenza. Nessuna ulteriore modifica applicativa richiesta dalla review.

## Evidenze e limiti

Letto `referti/QA.json`: revisione r2, 16/16 casi PASS, 18 ms, 0 scritture DB, 0 chiamate provider, 0 token IA. Il risultato riporta i casi del contratto, inclusi struttura Shion sanitizzata, immagini/consenso, CSP, sorgente e sandbox. L’owner precisa che si tratta di assert del compilatore eseguiti nel browser IAB con frame reale montato: i 18 ms non attestano una campagna temporizzata di navigazione, un pentest, richieste remote effettive o runtime Auth/DB. Il reviewer non ha eseguito il browser né ripetuto la matrice.

L’owner attesta anche sintassi di tutti gli script PASS e nessuna richiesta locale UNEXPECTED_NETWORK; queste attestazioni non sono trasformate in una verifica di rete indipendente. Il caso Shion conserva CSS e script originali con narrazione sostituita secondo quanto comunicato dall’owner; nessuna scrittura alla scheda reale.

Al momento della controverifica l’owner indica ancora in corso le osservazioni UI desktop/mobile. Il presente 0/0/0 chiude la review statica del candidato e il finding aggregato; non certifica prove visive non ancora consegnate, pubblicazione sul dominio, persistenza reale o funzionamento con account autenticati. Il completamento delle evidenze UI e dei controlli di pubblicazione previsti resta a carico dell’owner, senza riaprire questa review con nuovi casi.

Nessuna modifica al codice del reviewer. Nessun DB, provider, browser, nuovo corpus o test aggiuntivo. Il giudizio non estende il mandato a Clan, dati Shion o altri cantieri.
