Stato: **proposto**
# CANTIERE · REC automatica all'apertura dell'Esame
TASK `EXAM-REC-OPEN-001` · owner `DB-CORE` · reviewer `PM`

## Scope
Aprire una REC ordinaria della stanza nella stessa transazione che apre la prova Genin, prima dei messaggi iniziali di Sistema e Fato. Nessuna modifica alla land, al Narratore, al cron o alle regole.

## Causa accertata
- La REC generale nasce oggi dal trigger `trg_role_autojoin` soltanto dopo un turno pubblico valido del personaggio.
- L'Esame viene invece aperto da `esame_prova_apri`: crea la prova e poi scrive l'incipit tramite Sistema/Fato, senza passare dal turno che consegna al trigger il gettone di apertura.
- Esiste già la porta server `role_start(location, attore)`, riservata a server/service role, che crea la sessione e iscrive il personaggio senza riaprire una RPC al client.

## Contratto proposto
1. In `esame_prova_apri`, dopo la creazione idempotente di `esame_prove` e prima del primo `INSERT` in `messages`, aprire la REC con la porta server esistente e con il candidato come attore.
2. Nei luoghi `is_test=true` non aprire alcuna REC: la Test Room resta zona franca e l'Esame di collaudo continua a funzionare.
3. Se nella stanza esiste già una REC aperta, riusare quella sessione e iscrivere il candidato come oggi fa `role_start`; l'indice unico per luogo impedisce duplicati.
4. Il primo turno del candidato continuerà ad aggiornare il partecipante tramite `trg_role_autojoin`; Sistema, Fato e PNG resteranno nella finestra della REC ma non conteranno come turni del personaggio.
5. Nessun salvataggio retroattivo degli Esami passati e nessuna ricostruzione da `messages_archive`.

## Impatto previsto
- Runtime: una riga in `role_sessions` e una in `role_session_participants` per ogni nuovo Esame aperto in un'aula reale, salvo REC già aperta.
- Codice: una migrazione che adatta in posto `esame_prova_apri(uuid)` con guardia sull'impronta viva e rollback simmetrico.
- Permessi: nessuna funzione nuova, nessun nuovo `GRANT`; firma e ACL di `esame_prova_apri` e `role_start` restano invariati.
- Client e pannello: nessuna modifica a `land.html` o `admin.html`.
- Vincoli: nessun CHECK aggiunto o allentato.

## Gate
1. Preflight in sola lettura su produzione: definizione, firma, proprietario, volatilità, ACL e impronta delle funzioni; stato del branch QA e assenza di prove aperte.
2. Candidato SQL + rollback + banco locale, senza apply.
3. Review indipendente `0/0/0`.
4. Branch QA healthy e allineato: apertura Esame reale crea una sola REC prima dell'incipit; doppio invio non duplica; primo turno aggiorna il conteggio; Test Room non apre REC; rollback/recovery verdi.
5. Solo dopo autorizzazione nominativa: singolo apply in produzione e smoke minimo con account di prova, mai Riuji.

## Prossimo passo
PM: approvare questo contratto. Dopo l'ok DB-CORE prepara il candidato; nessun database o file di pagina viene modificato prima dell'approvazione.
