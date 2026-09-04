# HANDOFF · EXAM-REC-OPEN-001

**TASK-ID** · `EXAM-REC-OPEN-001`

**Scope toccato** · aperto il cantiere e definito il contratto; nessuna modifica a database, funzioni vive, pagina, cron o Edge.

**Contratti usati/modificati** · usati: `esame_prova_apri(uuid)`, porta server `role_start(uuid,uuid)`, indice unico della REC aperta per luogo, isolamento `locations.is_test`. Proposta: collegare l'apertura della prova alla REC prima dell'incipit, senza cambiare firme.

**Decisioni prese / OPEN** · REC automatica solo nelle aule reali; Test Room esclusa; niente recupero storico e niente chiusura automatica. OPEN: approvazione PM del piano e fotografia corrente del database.

**Prove eseguite e risultato** · tracciamento statico: la land chiama `esame_prova_apri`, che crea `esame_prove` e poi scrive Sistema/Fato; il trigger REC apre soltanto con il gettone prodotto da `post_message`; la porta server esistente è adatta all'innesto. Nessuna prova mutante eseguita. Documenti e QA parcheggiato caricati e verificati su `main` nei commit `6cc2fb79…`, `629875eb2…`, `2bd0eedab…`, `0ff9d7c9a…`, `144a3db03…`.

**Rischi o regressioni da verificare** · ordine temporale dell'incipit; doppio invio; REC già aperta nella stanza; partecipante iniziale con zero turni; Test Room; ACL e firma invariati; nessuna collisione con il trigger al primo turno.

**Passaggio richiesto al PM** · approvare il contratto; poi DB-CORE prepara candidato, rollback e banco, senza apply.
