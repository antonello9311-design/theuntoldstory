# COMBAT-CATALOGO-DAY-INTEGRATOR-20261120 · in lavoro

## Scope toccato

Ripresa dell’intero catalogo il 20 novembre fino alle 23:59 di Roma. **Catalogo Combat · ripresa del 20/11/2026.** La prima migrazione Staff ha verificato Super Espansione e Parziale con variazioni simulate da 75 a 60 e da 60 a 50 calorie. Il Velo del Cercoterio ha ora tipo azione rapida nel catalogo. Il potenziamento resta da integrare. Tre portate allineate e effetto di Scudo di terra riscritto nel catalogo, migrazione 20261120085205. La portata di Zanna distingue il contatto finale dalla carica, migrazione 20261120090114. La correzione del pannello NinjaBook è sul dominio alle 09:43, commit 6e5f283f. La candidata H1/H2 R1 ha review indipendente positiva. La prima installazione DB R1 è stata annullata dalla verifica dei manifest, con Root 4987 e cinque digest invariati. R2 installata in Staff, migrazione 20261120085624 e Root 8e6c57cb. Restano Difesa Cellulare e Kai su alleato. Il selettore NinjaBook mostra Iori e Nao. La prova con il solo testperfunzioni ha verificato anche il rifiuto della conferma in assenza del secondo PG. Il commit richiede due presenze Staff da non più di due minuti. Su Nara L1 acquisito. Nel primo caso il Passa ha chiuso la finestra preparatoria. Nel secondo il roster ha incluso entrambi i PG, ma il server ha respinto la distanza iniziale di 2 m perché richiede passi di 5. Cinque scene proprie chiuse. Profilo simulato ripristinato e risorse di gioco protette invariate. Nessuna nuova apertura pubblica.

## Contratti usati e modificati

Migrazione 20261120080832, Entry c44f31ec e review indipendente 0/0/0. Root 4987b6ec7f9de174a3e9e785e15cba1cf7d1238b9814ce2db2b38aea6634768a, 523608 byte. Client 6583d5fe, commit 7a286a20 e dominio verificato. Due ammissioni del motore missioni e gate precedenti confermati nel postflight. NinjaBook, Verme, forme Akimichi e Nara avanzata sono riservati alla Staff. Fonti canoniche in JOINT_FIX_INSTALL.json e JOINT_FIX_STAFF_QA.json.

CATALOGO_3_PORTATE_INSTALL conferma Palla 20 m, Scudo e Armatura su sé e nuovo testo Scudo dal §5.3 e dal contratto vivo. Soli metadati, nessun nuovo collaudo meccanico.

H1H2_R2_INSTALL attesta Root 8e6c57cb, client build2, due ammissioni Missioni e gate precedenti riletti. H1H2_R1_INSTALL conserva il rollback precedente. H1H2_R2_ROSTER_IAB attesta operazione e PNG offerti, con conferma respinta prima dello scontro. Chrome era scollegato alla nuova prova.

## Decisioni prese e punti aperti

Abilità fuori scontro narrative, Attivazione Sigilli ritirata, Capolavoro con azione condivisa. NinjaBook ammesso solo dalla Staff umana. Richiamo attende dati sulle creature. Per Insetto elefante serve una visibilità privata per osservatore e bersaglio. Non usare la visibilità generale della mappa come sostituto. Velo del Cercoterio allineato alla azione rapida nel catalogo. Potenziamento da implementare.

## Prove eseguite e risultato

Super Espansione attivata con addebito di 15 calorie simulate. Espansione Parziale ha prodotto un report con 47 PV di danno e un Fato pubblicato. Cellulare offerta a 10 calorie, invio respinto prima di dichiarazione o addebito. NinjaBook bloccato prima del roster. Nara L1 acquisito nel Combat. Il Passa del primo attore ha preceduto la preparazione L2, che era disponibile solo prima della prima dichiarazione. Profilo simulato precedente ripristinato. Tutte le scene proprie chiuse, 0 inviti e 5 impronte protette uguali, 0 provider. Sei prove storiche collegate a voci già disponibili in DAY_EXISTING_COVERAGE. I risultati circoscritti di Palmo, Paralisi, Contesa negativa e Verme restano nei loro referti originali. Copertura 371 voci in NIGHT_CATALOG_STATUS, da aggiornare con gli esiti diurni.

Referto della seconda scena Nara in DAY_NARA_H4_MASTER. L’avvio è stato rifiutato prima di creare Combat.

## Rischi o regressioni da verificare

NinjaBook rimuove solo il veto is_exam_room nel selettore della stanza Staff già vincolato all’UUID. Le guardie sull’Esame attivo e sul server vanno conservate. Cellulare deve omettere target_actor dal solo comando di difesa perché il bersaglio è già vincolato dalla dichiarazione nativa. Verificare la composizione dei sigilli prima di pubblicare. Nara richiede il profilo Nara L1 prima di creare lo scontro, poi la preparazione server a L2.

## Passaggio richiesto al PM

Il commit NinjaBook richiede due PG vivi presenti da non più di due minuti. La prova con un solo PG ha fatto scattare la guardia prevista. Riprendere dal roster con entrambi i PG presenti, poi verificare Kai alleato e Difesa Cellulare sul sito. Nara usa il PG proprietario, 0 e 5 m e la preparazione prima della prima dichiarazione. Strangolamento con Master ha un ulteriore difetto statico del publisher da comporre prima del collaudo. Conservare i casi riusciti e continuare con Palmo ordinario, Verme ordinario e i rami indipendenti. Consultare DAY_RUN per la fine della finestra e i limiti cumulativi.
