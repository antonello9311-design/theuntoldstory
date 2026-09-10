# QA runtime rifiuti Common · congelato prima delle SQL

COMBAT-PANEL-REJECTION-REASONS-QA-001 · QA-PLAYTEST. Candidata aggregata002 controverificata0/0/0; un solo run autorizzato dal PM. Stato iniziale: NOT_RUN. Output effettivo in QA_RESULT.json, senza modifiche al codice durante la campagna.

## Confini e risorsa

Container esistente tus_ordinary_compose_qa_db, fullID8681f0364c9f27bd5c856d2cc0f20690c8bc2f8d4aaf36de3394241b1596c019, PostgreSQL17.6.1.136. Configurazione precisa del banco compose già osservata: rete QA e porta loopback, nove mount di configurazione/dati QA. QA_ENVIRONMENT.json conserva solo metadata selezionati; ispezione senza Env né contenuti mount. Runner rifiuta qualsiasi drift. Prenotati entrambi alias docker:ordinary-compose-qa-db e docker:tus_ordinary_compose_qa_db, più db:combat_panel_rejection_reasons_001.

Nuovo DB combat_panel_rejection_reasons_001, assenza verificata prima CREATE nella stessa prima submission psql tramite gexec. Nessun reset o riuso, nessun altro DB modificato. Ruoli nominali già esistenti verificati, non creati o alterati. Nessun account reale, segreto o dato PG.

## Sorgenti e componente

QA_SETUP riusa il bootstrap nativo completo già compilato006, cambiando solo il nome del DB nella guardia preparatoria; nessun corpo/vincolo/trigger nativo rimosso o indebolito. Il riuso del corpus completo evita supporti finti per access_reason/location_adapter; non è una nuova campagna del motore. Rimane la riga descrittiva preparatoria con gameplay_ready=false, nessuna history o chiave RNG fabbricata.

Il gateway BEFORE e combat_v2_fail sono riconciliati ai corpi/ACL congelati della candidata; auth.uid, validate_command, hash, error_codes, access_reason e location_adapter sono autentici. Firme/hash/provenienza in QA_SOURCE_MANIFEST. La fixture inserisce un solo utente nominale sintetico auth.users, un profilo mediante trigger nativo, una presenza e un luogo locale non Test Room, un contesto e un’offerta amministrativa ordinary coerente con FK/check/trigger. Non viene creato alcun personaggio, attore, scena o sessione di combattimento. Solo nel DB dedicato il gate ordinary è acceso per raggiungere il dispatch; ciò non attesta protezione Test Room o parità utenti.

Unica frontiera sostituita: combat_panel_private.commit_ordinary(jsonb), esplicitamente sintetica. Scrive sentinella locale, solleva gli errori congelati o restituisce un risultato minimo con receipt. I casi attraversano il gateway completo e il suo handler PostgreSQL; non il motore di gioco. Identità via auth.uid autentica su impostazione locale nominale: nessuna prova Auth/API/RLS, nessun bypass di assert di prodotto. Helper QA di registrazione e confronto sono dichiarati e non fanno parte del prodotto.

## Matrice invariata e misura

4gruppi,9sottocasi massimi,9submission totali,10min dalla singola invocazione,0provider/token/browser. La prima submission include preflight e CREATE; la seconda include bootstrap completo e fixture, non chiamate nascoste. Le altre sette: INSTALL COMMIT e G1; G2duecasi; G3quattrocasi; G4successo/replay; snapshot; RECOVERY COMMIT; postflight G4. Ogni fase usa una connessione psql distinta. SQL e hash congelati prima della prima invocazione; le nove submission contengono più statement dichiarati, non sono nove statement individuali.

G2 usa validatore nativo e vera scrittura sentinella annullata dopo eccezione; G3 distingue cause sconosciute/suffisso,40001,PGRST nativo e precedenza conflittochiave; G4 conserva successo/replay con un solo effetto e receipt, quindi recovery completa e snapshot identico. Nessuna matrice di40uguaglianze o nuovo esempio per RR-01. G1/guardie confrontano corpi completi e ACL autentici; ogni caso salva booleani e risposta sintetica, senza materiali privati reali.

Deadline600s, timeout statement<=120s e transaction<=122s adeguati al residuo, timeout client+5s circa. Timeout/errore isolamento ferma senza retry né stop del container condiviso. Errori di un gruppo si conservano e si prosegue nei gruppi sicuri; bootstrap/install falliti rendono i dipendenti NOT_RUN. Nessuna patch durante la campagna. Conservare DB/container e tutte le righe dopo recovery.

## Consegna

Freeze materiali e manifest prima SQL, un unico risultato anche rosso, poi aggiornamento del solo stato/evidenze manifest. Prodotti e review immutabili. Qualifica di componente, non causa011, geometria, risorse, permessi Supabase reali, provider o smoke del sito. Il successivo gate live resta al PM.
