Stato: **parcheggiato**
# CANTIERE · QA Esame da REC reali
TASK `QA-ESAME-REC-REAL-001` · owner `QA-PLAYTEST` · reviewer `NARRATIVE-AI`

## Scope
Campagna empirica separata sul Narratore Esame 4.7.1, senza modificare il prodotto né il cantiere tecnico `NARRATORE-UNIFICATO_2026-09-02`. Produzione esclusivamente in lettura; branch QA soltanto dopo disponibilità di due REC genuine e allineamento verificato.

## Budget congelato
- 2 Esami reali conclusi, massimo 6 cicli complessivi.
- Una chiamata `gpt-5.6-luna`, reasoning high, per ciclo; cap 1.024.
- Zero retry o rigenerazioni; massimo 60 minuti; costo massimo **$0,12**.
- Eseguito: **0/6 chiamate**, 0 retry, costo **$0,00**.

## Stato vivo
- Owner verificati: banco/playtest `QA-PLAYTEST`; revisione narrativa `NARRATIVE-AI`. Terzo e ultimo cantiere ammesso mentre Clan L1 e Combat Composite restano «in lavoro».
- Produzione, sola lettura: 6 Esami reali conclusi di candidati oggi Genin; 5 nelle Arena/Aule Esame del perimetro e 1 in un luogo ordinario, escluso. Prove aperte 0; Riuji e account di prova esclusi.
- Collegamento REC byte-exact riuscito per una sola prova: pseudonimo `E6`, prova `333662b8…`, REC `19e59702…`, 9 azioni del candidato, 14.633 caratteri, SHA-256/16 `bad09259118934a3`.
- Il candidato apparente `E3`/`2399b1fa…` sovrappone una REC di «Konoha - Altri Luoghi», ma contiene 0 turni dell'Esame nella finestra: escluso. `E2`/`23d4ccf1…` non ha REC sovrapposta.
- Gli ID dei turni storici dei cinque Esami nel perimetro risolvono in `messages_archive`, ma solo `E6` coincide con `role_messages`; l'archivio tecnico non viene promosso a REC senza mandato esplicito.
- Branch QA interrogabile: 0 prove aperte, 0 cicli non terminali, 18 snapshot sintetici in una prova; nessuna fixture REC scritta e nessuna chiamata modello.

## Lavori aperti
1. Ottenere una seconda REC genuina di Esame concluso, oppure un mandato PM che allarghi esplicitamente la fonte da REC a `messages_archive`.
2. Solo dopo: verificare allineamento corrente del branch, materializzare sei fixture immutabili con review richiesta e svolgere la campagna entro il budget già congelato.

## Prossimo passo
Riprendere soltanto dopo il rilascio e uno smoke verde di `EXAM-REC-OPEN-001`, quando un nuovo Esame reale potrà produrre la seconda REC genuina richiesta. Il budget resta congelato e non è stato consumato.
