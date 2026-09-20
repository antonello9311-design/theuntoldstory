# MISSION-RAPID-REVIEW-002 · piano di review e collaudo

## Confini

- Revisione indipendente prima di qualsiasi apply/deploy: SQL, Edge, Admin, autorità server, idempotenza, recovery e compatibilità con la baseline post «Adatta missioni».
- Nessun Docker e nessuna prova funzionale locale.
- Dopo review verde, collaudo esclusivamente nella Staff Test Room protetta con `testperfunzioni` e `Riuji`.
- Budget live massimo: 12 casi, 4 chiamate provider, nessun retry esplorativo.

## Gate A · review indipendente

1. Verificare tutti gli hash di `MANIFEST.json` e i pin live di Mission Generic, Mission Creation, board open, PNG Builder e Admin pubblicato.
2. Controllare sintassi e installabilità di `db/INSTALL.sql`, grant/revoke, RLS, idempotenza, lock, transazioni, preview seal, recovery conservativa e assenza di cancellazioni.
3. Controllare le due Edge: autenticazione, separazione service-role, limiti file, SHA/magic/dimensioni, singola chiamata IA, nessun retry e output schema-strict.
4. Controllare Admin: visibilità solo staff, nessuna scrittura Storage diretta, request UUID persistite, correzioni editoriali, anteprima obbligatoria e publish dipendente dal seal.
5. Eseguire le cinque suite pure: attesi compilatore 35/35, media 18/18, UI 51/51, integrazione Admin 28/28, contratti integrati 21/21.
6. Verificare che il consumer terminale sia privato, l'endpoint JSON sia chiuso, l'hook sia composto soltanto sulla definizione viva pinndata e la recovery rifiuti qualunque drift successivo.
6. Registrare finding aggregati P0/P1/P2. Esito necessario per il rilascio: 0/0/0.

## Gate B · checkpoint prima del rilascio

1. Rileggere baseline e owner; nessuna risorsa/file di «Adatta missioni» deve essere attivo o cambiato senza composizione verificata.
2. Applicare DB con policy authoring disabilitata; verificare postflight, funzioni e permessi.
3. Distribuire `mission_authoring_ai` e il ramo compatibile di `png_media_attest_v1`; verificare build marker e conservazione byte-identica del ramo Scorta.
4. Pubblicare asset e Admin riconciliati col remoto; poi configurare e abilitare la sola policy authoring. Ogni gate conserva una recovery separata.

## Gate C · Staff Test Room

1. Preflight: fotografare PV/chakra di prova, progressione, inventario, missioni/sessioni attive e budget provider; accertare modalità protetta.
2. Accessi: Admin vede l’editor; `testperfunzioni` e ruoli non amministrativi non possono usare le RPC editoriali riservate.
3. Compilazione: trama con tre fasi e due PNG, una sola chiamata provider, polling della stessa request, schieramenti proposti e output senza statistiche/tecniche inventate.
4. Correzione: modificare grado, partecipanti, fase, transizione, identità/comportamento/conoscenze/limiti PNG e condizioni terminali; salvare con CAS.
5. Media: caricare due immagini, verificare associazione automatica/non ambigua, approvazione staff e blocco dell’anteprima per media non approvato.
6. Mappa: verificare default 10×10 e una mappa specifica già caricata, capienza e posizionamento PG/PNG senza scritture su schede reali.
7. Anteprima: controllare incipit, fasi, schede PNG con statistiche/PV/chakra/tecniche da versione approvata, immagini, mappa/partecipanti, condizioni, budget ed errori bloccanti; verificare proposta automatica univoca e pareggio lasciato alla scelta editoriale.
8. Pubblicazione: un solo comando; verificare piano sigillato/selezionato, versione, recovery, condizioni, board aperta e Narratore entro budget.
9. Idempotenza: ripetere la stessa request di publish e ottenere lo stesso risultato senza seconda missione.
10. Condizioni: verificare almeno vittoria/sconfitta e una tra fuga, protezione, posizione, resa o sopravvivenza tramite ricevuta server.
11. Compatibilità: aprire e usare un percorso «Adatta missioni» già esistente senza differenze di runtime o regressioni.
12. Postflight: chiudere soltanto la prova creata; confermare PV/chakra, inventario, progressione, sessioni esterne e storico invariati.

## Stop

Fermare il caso interessato senza bypass o retry se compare una scrittura su risorse reali, un accesso non autorizzato, una sessione esterna, drift di versione, errore di sicurezza o superamento del budget. Conservare audit ed esito; nessuna cancellazione dello storico.
