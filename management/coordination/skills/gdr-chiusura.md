---
name: gdr-chiusura
description: Conclude o sospende un incarico del GDR The Untold Story preservando consegna, prove, stato delle aree e prenotazioni. Usa a fine sessione o per handoff e archiviazione; non dichiara finito il prodotto per la sola chiusura della task.
---

# gdr-chiusura — consegna e passaggio di responsabilità

Dalla cartella del progetto applica `AGENTS.md` e `management/coordination/AVVIO_LAVORO.md` §5. Non duplicare la procedura in file datati o appendici di rettifica.

1. Salva risultato e limiti nell'HANDOFF esistente, aggiorna SCHEDA e una riga STORICO del cantiere. Per puro coordinamento PM usa il deposito di consegne già previsto, senza un nuovo cantiere.
2. Riscrivi le sezioni pertinenti della scheda d'area, sotto prenotazione: stato con fonte/data, lavori aperti e prossimo passo. Cron, flag, gate e versioni cambiate devono comparire qui; migrazioni anche in PIATTAFORMA. Non eseguire verifiche backend non pertinenti per un semplice aggiornamento documentale.
3. I documenti centrali sono assegnati dal PM, non riscritti da ogni specialista. Un file condiviso richiede l'owner nel registro di avvio; se varia, fermare la scrittura interessata.
4. Il caricamento GitHub dei file autorizzati, pronti e verificati è autonomo secondo AGENTS. Riconcilia il remoto, deposita solo lo scope, verifica e registra commit/SHA in PUBBLICAZIONE. SQL ed Edge depositati restano sorgenti; apply/deploy/enable conservano gate separati. Indica esattamente i file rimasti locali e il motivo.
5. Salva l'handoff prima di rilasciare la prenotazione. Una consegna sospesa non sblocca dipendenze. Un rosso terminale resta rosso e non riparte automaticamente.
6. Archivia la task soltanto su richiesta e dopo arresto sicuro; sospendi il suo monitor separatamente. Non cancellare il cantiere, lo storico o scene altrui. L'anti-stop del Mac è distinto dai monitor delle task.

Risposta finale in italiano: risultato effettivo, verifica, limite materiale e prossimo passo. Elenca modifiche ai vincoli se presenti; immagini solo se pertinenti e realmente necessarie al mandato. Non imporre all'utente una lista manuale di caricamenti già eseguiti né ripetere l'intero arretrato a ogni chiusura. Le impostazioni esterne Claude non sono aggiornate dal solo salvataggio di un file.
