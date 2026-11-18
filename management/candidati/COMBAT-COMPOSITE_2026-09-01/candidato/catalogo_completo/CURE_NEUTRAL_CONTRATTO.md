# Cure Neutral · revisione della variabile locale

Contratto sorgente immutabile, non attestazione di stato operativo. SOURCE ONLY: apply/deploy e qualifica Staff sono distinti. Il riferimento wholefile di questo contratto non deve essere alterato dopo la review; stato operativo e ricevute vanno nel referto e nella documentazione PM.

## Difetto e superficie

QA3, Root07f5b2ea5fd3b16175d8f119c4fa7e66fbfb03b6cac07b93846b67e8b05ba5f1: request409a8363… respinta prima del gameplay con42702, cure_neutral_preset_v1→cure_voluntary_receipt_guard_v1→cure_commit_v1. La scena propria è stata chiusa nativamente dal PM con quattro digest invariati e zero profili/dichiarazioni/provider/residui.

Il helper dichiara operation text e usa operation='control' senza qualifica in due SELECT, dalla panel.offers e dalla consumer.offers originale ordinary. PostgreSQL deve distinguere colonna e variabile omonime e genera l'ambiguità. Esiste inoltre una terza colonna r.operation già qualificata, che non collide. Le altre variabili della funzione e dodici helper Cure strettamente pertinenti non presentano altre collisioni concrete nella verifica statica.

Il difetto è osservato nella Staff, ma la sua superficie non è limitata dalla sola disponibilità Cure: il trigger common request_receipts invoca il helper per i control prima che questo valuti lo scope Staff. Perciò anche un control non Cure può incontrare l'errore con CurepublicOFF. Questa è la ragione per mantenere la correzione del nome nella recovery operativa.

## Delta e autorità

Solo dieci usi locali sono rinominati operation→preset_operation: dichiarazione, assegnazione e riferimenti procedurali. Il corpo cresce di70byte. Le due colonne SQL non qualificate restano colonne operation; la terza r.operation e le chiavi JSON/receipt operation restano byte-identiche. Nessun variable_conflict globale, alias di autorità, cambio di query/whitelist/dynamicSQL o nuovo campo client.

Cambiano soltanto cure_neutral_preset_v1(uuid,uuid,uuid,jsonb) e catalogo_eligibility_release_v1(). Il committer corretto61532836e90ed32ae807b92ee6632b71 rimane immutato, insieme a guard250e,34shared, altri65private, Edge45, validator/client/formule e catalogo dati. Il helper di compatibilità verifica il nuovo sourceMD5 Neutral, la stessa chiusura100peer/7porte/12relazioni/10trigger e una revisione esplicita dell'identità attiva.

Per un control non Cure la prima SELECT non è più ambigua. Fuori dallo scope Staff ammesso il helper restituisce false; il trigger prosegue in cure_note_voluntary, che conserva le proprie verifiche di fonte congelata e scope/gate prima di un nuovo audit. Non si restringono globalmente i controlli né si disabilitano trigger per evitare l'errore. Si conserva la neutralità soltanto per preparazioni provate da offerte consumate e ricevute server esatte.

## Metadata compatti e Root

La custody Root07raw verificata occupa521454byte, rowSHA340b3c89be9a6f70f4133b119c2b121f6666b71d73022c7e4d04cd02d45fd64c. Il nuovo footer revisiona in posto cure_command_amendment, senza aggiungere un'altra coppia di grandi entry: parentRoot07, precedente bundle commandE14, precedente identità e nuova firma Neutral/before/after. Commit615 resta esplicitamente preservato. Le provenienze825a/654f/E14 e la custody storica non vengono riscritte come se fossero nuove versioni.

Il manifest66 attivo è ricalcolato e collegato alla nuova revisione. Solo i due header modificati Neutral/helper sono registrati; non si duplica il manifest66 completo nella Root. Il precedente handler615 è contenuto nei65peer invariati e nel suo sourceMD5 preservato. L'identità normalizzata non contiene un hash del proprio helper o una Root futura costante, evitando cicli.

La transazione forward contiene preflight07 esatto, due patch minime CAS (tutti i preimage prima della prima modifica), postimage e footer forward. UI/Generic168/Edge45,825a base e configurazione estranea restano invariati; vengono ricalcolati DB/config/code/recovery/Root. Si conserva soltanto la qualifica missione già valida, due content admission e party flags. Digest delle due righe07:9dcf6e68a18d58def5caf5e4373648b7058e801deaf7c25861830638d6381fe6. NuovaQA NOT_RUN, parentQA BLOCKED_NEUTRAL_NAME_COLLISION, staff_pass/publicfalse.

## Recovery operativa senza ripristinare l'ambiguità

La recovery mantiene entrambi i corpi corretti. NON esegue inverse verso i vecchi DDL diagnosticati, perché CureOFF non impedirebbe il42702 nei control generici. I vecchi DDL restano soltanto in custodia diagnostica. La recovery richiede Root attuale futura pin-nata, esatte impronte dei due corpi corretti, quiescenza e chiusura/assestamento delle sole fonti Cure: nessun report attesa, claim claimed, tentativo non published/failed, dispatch/publish prepared. Non forza risoluzioni, chiusure, scadenze o snapshot.

Spegne soltanto CureStaff/public, verifica Para invariata e crea una nuova Root con revisione Cure inert_recovery e disponibilità CureOFF. Il helper accetta questa modalità solo se entrambi i gate Cure sono OFF; continua a verificare esattamente gli stessi100peer e a servire le altre offerte/control. Non dichiara Cure qualificata e non ripristina una vecchia Root. Profili, ricevute, ledger, eventi, report e storia restano conservati. Commit615, guard250e,34shared, Para ed Edge45 rimangono immutati.

## Cap e pipeline

Modello byte offline sulle due forme esatte: forward massimo523655byte, margine633; recovery massimo523777byte, margine511, cap524288 invariato. Assunzione vincolante: review.ref codificata JSON≤512byte, imposta da footer e finalizer. Nessun valore di SHA Root futura o spazio DB è inventato. Serializer lineare UTF8, roundtrip e cap sul testo effettivo bloccano la sostituzione se diverge.

source_manifest è B, con hash dei template forward/recovery, sorgenti/patch e di questo contratto, senza proprio hash, capsule finale/referto/SQL finale. Il PM completa params.template e rimuove review per ottenere N; compatibility.ref deve indicare questo wholefile byte-immutabile o una copia completa immutabile nel review.raw_utf8. Il finalizer produce N/hash, poi con file R1 effettivo0/0/0 produce P/F/E sostituendo soltanto i due pin pieni, review inclusa. E rimane esterno. L'entrypoint inserisce solo set_config(app.cure_neutral_parameters,P,true) subito dopo BEGIN, con hash ed equivalenza esplicita in R2, come la pipeline precedente.

La recovery ha schema cure-neutral-recovery-parameters/1 e expected_current root/riga/byte/DB reali post-apply, mai valori futuri inventati. Nessuna capsule finale, R1/R2 o prova Staff è simulata da questi script. Parsing e replay sono controlli statici; il caso reale Staff resta successivo e con budget distinto.
