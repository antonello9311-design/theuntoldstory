# E67 — recupero conservativo

Non rieseguire installer storici. Confrontare sempre Root, Edge effettiva e selezioni future prima di un intervento successivo. L'installazione E67 conserva tutti i Fati, i sei percorsi precedenti, le campagne editoriali E65/E66 chiuse e ogni costo/ricevuta.

L'installer integrato usa CAS e controlli di baseline solo per installare la versione richiesta: nessun nuovo controllo blocca i futuri testi. I nuovi contenuti sono append versionati, non sostituzioni di snapshot passati. Le precedenti versioni conservano il contenuto; eventuali metadati di lifecycle si distinguono dai dati narrativi.

Prima del commit SQL, qualunque eccezione annulla la transazione. Se Edge è già distribuita e la transazione non è confermata, non avviare provider o gameplay e non trattare il nuovo bundle come installazione integrata. Accertare readonly se il commit sia avvenuto; comporre il solo delta ancora necessario dalla baseline effettiva. Non ripetere l'append con ID diversi, non azzerare contatori e non mutare le vecchie prove.

L'eventuale ritorno alla selezione precedente richiede un delta nominato dalla baseline corrente, conservando le versioni nuove e la loro provenienza. Non fare DELETE, non disabilitare trigger, non impostare identità SQL fittizie. Non ricorrere a generazioni editoriali per verificare il recupero.

La qualità narrativa della nuova versione resta NOT_RUN finché Antonello autorizza una nuova prova pertinente. Questa consegna non abilita nuove campagne né riapre E65/E66.
