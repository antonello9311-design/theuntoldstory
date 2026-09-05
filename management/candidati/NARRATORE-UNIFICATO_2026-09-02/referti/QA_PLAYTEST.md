# Referto indipendente · rilascio Esame 4.8

Data: 05/09/2026. Revisione:4.8.0/prompt31. Reviewer unico: subagente review_release_esame, sola lettura.
**Primo passaggio: ROSSO, P0/P1/P2 = 0/3/2. Unica controverifica finale: VERDE 0/0/0 sui cinque finding congelati.**

## Finding congelati dell'unico passaggio
1. P1 — producer integrato non soddisfa V5: _esame_ciclo_payload non emette card/legami completi; scena non emette ricevuta6campi. index valida direttamente, senza adattatore. Rischio fallback prima del provider.
2. P1 — validatore impone «iniziativa», due nomi e relazione spaziale nell'ultima frase di ogni campo, in conflitto con il prompt di prosa naturale e con il finale terminale.
3. P1 — materializzazione diretta assegna solo claim dialogici, perdendo le riprese gestuali autorizzate dal ponte; validatore poi le rifiuta.
4. P2 — attivazioni della tecnica precedente e scelta controllate globalmente sul paragrafo: sigilli richiesti per una e vietati per l'altra.
5. P2 — telemetria registra due chiamate anche nei ritorni dopo la sola Luna (errore provider, max_tokens, JSON non leggibile).

## Correzione aggregata controverificata
- Producer: owner Spatial; gate DB PROD-V5-01 verde,16/16 assert,16/48 chiamate,19,700966/60 secondi compresi recovery e rollback. Postflight:398 tabelle QA vuote, catalogo uguale a LIVE/baseline, registro invariato. Nessuna fixture arricchita a mano.
- Edge: assetto contestuale verificato da Terra contro ricevuta, senza parola obbligatoria; invarianti meccaniche conservate. Riconoscitore claim condiviso fra attribuzione/validazione, senza autorizzare auto-esiti.
- Attivazioni multiple associate al loro stadio dal giudice con entrambe le schede. Il solo action_type non autorizza inferenze sui sigilli; licenza generica Sostituzione distinta dal catalogo e nominata Antonello/PM.
- Conteggio effettivo delle chiamate1/2. Prova dell'orchestrazione effettiva index con porte simulate sui quattro rami già rilevati; nessuna chiamata al provider.
- Card: provenienza dell'adattamento canonico e spazio inoltrati identici a Luna/Terra; niente falsa revisione editoriale né limits numerici obsoleti.
- Freeze Edge: manifesto SHA256SUMS `71535d50ce8ee07cf41c193e45ff3f6343dda635df062f6012d4a6b97cce58f4`.
- Verifiche locali finali owner:201/201 narratore +1/1 orchestrazione (quattro scenari simulati) +8/8 LAND =210/210; Edgechecksum10/10. Questi risultati non sono QA generativa né smoke LIVE.

## LAND, review separata sul delta di trasporto
Owner land_ui_option_id; reviewer parent. Diff integrale confrontato con GitHub scaricata fresca il05/09:0/0/0. Otto prove locali includono sintassi, ancore distinte, radio/draft/riapertura, normalizzazioneRPC, scelta scaduta, legacy e Scontro.
Pin:LAND-ESAME-ANCHOR-OPTION-007,706117B,SHA `c241f571d543214d6ca6c5ea4dbbe7e00fafbf0e431bcb0a5b65bfdd2ce144e5`. Caricata dopo i gate, come attestato nel postflight seguente.

## Postflight del rilascio autorizzato
DB336/337 applicati da DB-CORE,33corpi/ACL verdi dopo ciascunapply, runtime prima/dopo invariato0esamiaperti; referto owner `PRODV5_LIVE_APPLY_RESULT.json`, SHA0c0edb962e8760b4aad13cdca551c60a433bc556dad56be7b7950f75e7caae6f.
Singolo deploy Edgev128,4.8/prompt31,ACTIVE/JWTfalse; download10/10 byte-exact al manifesto71535d50. Bundle remotoSHA d7b7466fa9903a3232b38d8806849989249ded3b7e15f2d4427e2fb2ffa138ee. Unico smoke `{impronta:true}` HTTP200,0provider/SQL, impronta prompt c4009b3394b62b35ba724d6068c8323f23e3358892734eac9395d23958564075. Non è uno smoke narrativo completo.
LAND caricata commit445bdd7304af95456f32bcf9e47aaed31b25884d;11fileEdge caricati commit25940d17e3a68f119523f85df0abdf160931f7d7. Entrambi confrontati byte-exact tramite lettura Git remota isolata. Build007 verificata nel file GitHub. Marcatore LAND-ESAME-ANCHOR-OPTION-007 attestato manualmente da Antonello sul dominio pubblico: ricarica senza cache, ricerca nel sorgente, risposta «presente». Verifica strumentale non eseguita; non è una prova funzionale Tamako né verifica byte-exact del dominio.

## Limiti e prossimo gate
Controverifica finale conclusa0/0/0, senza nuove patch o campagne. Input reale `QA-BRANCH-BASELINE-REPAIR_2026-09-04/referti/PRODV5_NATIVE_PAYLOADS.json`, SHA256 `ff717ac0cac7f647c5e27f291b5c35c520d69a05270cd9520e18916230e8ddd1`; risultato nativo DB `PRODV5_GATE_RESULT.json`, SHA256 `0c0eed6ea92f06301156ab247db4499824e7b011faf5b9cbe0e1ea91d7c31f87`.
Unico `payload-owner-gate.mjs FILE 4`:4/4 verdi, exit0,93ms su budget10s,0provider/SQL. Schema, piano e raccordo Luna/Terra di schede, provenienza, spazio e regia coerenti. Reviewer ha verificato gli SHA e chiuso finding1; finding2–5 già chiusi sul freeze71535d50.
I quattro payload sono tutti `png_esito`: ciclo/replay di Konoha bound e Suna legacy. Non sono quattro ruoli, certificazione provider o smoke LIVE senza fallback. Nessun nuovo caso stilistico, generazione, esame o Tamako. Apply DB e deploy Edge richiedono gate e nominativi; sorgenti GitHub non equivalgono a deploy.

## Riferimento storico, non gate corrente
Il precedente referto qui contenuto riguardava4.4.0/prompt24,158/158 e0/0/0 sui tre finding del replay4.3 (rami png_attacca, fonti della frase singola, termine autoritativo usato come persona). Non certificava canary o produzione. Le prove4.7.1 successive e lo smoke10/10 sono registrati nella SCHEDA; nessun risultato storico è trasferito alla4.8.
