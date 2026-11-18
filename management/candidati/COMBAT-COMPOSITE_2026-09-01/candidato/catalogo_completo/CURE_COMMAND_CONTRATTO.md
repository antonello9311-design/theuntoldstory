# Cure command · applicata in Staff, collaudo da svolgere

Stato operativo: migrazione20261118153417 applicata dopo R1/R2 indipendenti0/0/0. Root07f5b2ea5fd3b16175d8f119c4fa7e66fbfb03b6cac07b93846b67e8b05ba5f1,521454byte, row340b3c89be9a6f70f4133b119c2b121f6666b71d73022c7e4d04cd02d45fd64c. Sourcef56077fd3e08b055def4c9d4e069cdc521a158afad436db40bf2a4017185f7f7, Be14b2a7fd1bbe0d0dad34c12d2176bc1347e6860e205f142d9098f4ae3d559dc. CuregatedStaffON/pubblicoOFF, Paragates invariati. Branchclosed=true,100peer coerenti,2body nuovi6153/cee,34shared/guard250e/Edge45 invariati. Qualifica missioni true,2admissioni epartyflags conservati,0scene/provider, nessun PASS meccanico. Sigilli resta ritirata. Recovery055e limitata e non eseguita. Ricevuta e fonti esatte in CURE_COMMAND_REVIEW.json.

## Contratto sorgente congelato prima dell’applicazione

La successiva etichetta SOURCE ONLY descrive la consegna dello specialista recensita da R1. Lo stato operativo corrente è quello registrato sopra.

# Cure command · correzione server dell'operazione

SOURCE ONLY. Baseline fresca Root7de36fc81053902e6fbfa99c332ee75544f7a8acdb26ebfd9c6ab108045bcf7f,514748byte, row86056394b0a33c29c75f828d6fccd348ac4d6d9009cb95906d0a3b1b7c5a0e42. Edge45, guard250e,825a/654f e tutte34shared restano invariati. Nessuna UI/gameplay/provider/apply/repo in questa task. La sola ulteriore variazione di catalogo decisa dall'utente è gestita separatamente dal PM; questo pacchetto non scrive né ripristina dati di tecniche.

## Difetto e delta minimo

L'unico invio Staff ha restituito rejected/not_authorized con audit42501 in cure_commit_v1. Il comando canonico combat-panel-command/1 non contiene operation e il validator la vieta. L'offerta server cf48… porta kind=control, operation=control e dispatch=cure_staff_profile. Quindi `p->>'operation' IS DISTINCT FROM o.operation` è sempre vero per ogni comando legittimo, prima dei rami profile/action.

La patch elimina soltanto quel termine. Restano le verifiche strette dispatch/profilo server e kind/operation control-control oppure action-declare; receipt.operation continua a provenire da o.operation. Nessuna operation viene aggiunta al client, al DTO, al validator o al fingerprint. Tutti gli altri controlli di autenticazione, idempotenza, ownership, CAS, ruolo, selezioni, turno, scope protetto, costo e ledger restano byte-identici. L'audit separato cure_command_contract_audit.json SHA08d8dd8d… ha esaminato13accessi/9keys e non ha trovato altri campi fuori whitelist; non equivale a review globale della candidata.

## Emendamento esplicito del closed peer

Vengono modificati soltanto due corpi: combat_panel_private.cure_commit_v1(jsonb) e clan_innata_private.catalogo_eligibility_release_v1(). Nessuna reinstallazione34 e nessun cambiamento alla guardia250e. Il committer passa da sourceMD55690d47226fc9ae7bd5aca96ced8d079 a61532836e90ed32ae807b92ee6632b71.

Il helper resta STABLE/private/senza actor lane/DML. Il suo set chiuso mantiene34ABI/shared e65private invariati, sostituendo il solo sourceMD5 del committer. Un nuovo normalized_source_identity, privo di hash proprio, descrive firma, delta e provenienze825a/654f. L'entry cure_command_amendment è l'autorità del manifest66 attivo: non pretende che il vecchio3eb9… sia rimasto invariato. Quest'ultimo resta nella base825a e nell'identità17fd come provenienza. La repair654f conserva il proprio bundle/identità di base, registra active_amendment_source_bundle e aggiorna private66/helper/functions ai corpi realmente presenti. Non attesta che il vecchio helper sia ancora installato.

Il helper verifica nuova identità normalizzata, Root rawSHA/configSHA/dbSHA, review pertinente, collegamento fra i due entry e MF66 risultante; conserva tutte le verifiche precedenti100peer/7porte/12relazioni/10trigger. Ownhelper hash resta fuori dal proprio preimage ed è registrato nel manifest, senza ciclo. Gate, acquisizione e controllo restano ai producer originari. NuovaQA NOT_RUN, parentQA BLOCKED_COMMAND_CONTRACT, staff_pass/public_enabled=false.

## Installer e Root forward

cure_command.integrated.template.sql è una transazione: preflight da Root7de esatta e guard/helper correnti, quiescenza, vecchio closed peer valido; due patch minime CAS con verifica di entrambi i preimage prima della prima sostituzione e verifica dei due postimage; nuova Root forward. Nessun altro corpo viene eseguito o reinstallato.

Il footer cattura il manifest66 e i due header realmente risultanti, aggiorna i soli binding dell'emendamento/compatibilità e conserva825a, UI, Edge45, Generic168, guardia e configurazione estranea. Ricalcola DB/config/code/recovery/Root, valida serializer compatto/roundtrip/cap524288 e adotta soltanto qualifiche missione già legittime, due admission e party flags. Il digest vivo delle due admission è904e260a2e3b48a6667b0ced2ed380dc45ef3a904f614e06be706897e5ad8b78. Gate Cure e Para vengono fotografati dal server e verificati invariati; entrambi pubblici restano OFF. Non viene ereditato un PASS per Cure dal carryforward missione.

Modello dimensionale offline: massimo522270byte con review.ref codificataJSON≤512byte, margine2018byte. Non è una Root finale né un'attestazione di spazio DB; il cap runtime resta vincolante. Finalizer e footer impongono il limite del riferimento recensito.

## Recovery limitata

cure_command.recovery.template.sql richiede la nuova Root effettiva e i suoi SHA/riga/byte/DB da capsule esterna. Richiede quiescenza e chiusura terminale delle sole sessioni Cure, dichiarazioni assestate, nessun report attesa, claim claimed, tentativo non published/failed, dispatch/publish prepared delle fonti Cure. Non risolve, scade o annulla nulla. Spegne soltanto CureStaff/public, verifica Para invariata ed esegue le sole due inverse CAS.

Il committer torna5690 e il helper torna bde; il manifest66 attivo torna al valore base realmente calcolato. La nuova Root segna l'emendamento inert_recovery, aggiorna header correnti, rimuove il puntatore active amendment dalla compatibilità654f e ne ripristina gli header/manifest autentici. Conserva profili/ledger/eventi/report/audit e tutta la storia. Guard250e,34shared, Para ed Edge45 restano presenti e immutati. Nessun rollback Edge44 o ripristino della vecchia riga Root.

## Pipeline N/R1/P/F/E

cure_command.source_manifest.json è B, con byte esatti di template forward/recovery, patch e contratti, senza capsule finale, refertoR1 o SQLfinale. source_bundle_sha256 è SHA256 dei byte di B; B non incorpora il proprio hash. Le DDL candidate sono normalizzate native: il committer parte dal pg_get_functiondef fresco, il helper dal normalizzato bde il cui ddlMD5 coincide con quello catturato in Root7de. Le patch agiscono solo sul corpo, preservando header e permessi; non usano una ricostruzione storica a corpo intero.

Il PM completa cure_command.params.template.json, rimuove l'intero membro review e prepara N con B, custody, compatibility ref/SHA reale e digest admission. Il comando `python3 cure_command_finalize.py --input <N.json>` produce params.N.json/hash. R1 deve recensire template+B+N senza includere il futuro F. Con --review-metadata e --review-report il finalizer verifica il file reale del referto0/0/0 e produce P/F/E con due sostituzioni del pin pieno (review inclusa). E resta separato, senza autoreferenze. Prima di applicare F occorre un entrypoint con il solo set_config(app.cure_command_parameters,P,true) immediatamente dopo BEGIN, più controllo indipendente dell'equivalenza e hash dell'entrypoint in E, come nel rilascio precedente.

La recovery usa --recovery e un nuovo N con schema cure-command-recovery-parameters/1, expected_current root_sha256/root_row_sha256/root_bytes/db_sha256 e custody reali. Non sono inventati questi valori futuri. Tutti gli script sono locali: non aprono connessioni né eseguono SQL.

Parsing/replay sono controlli statici, non installazione o collaudo. Nessuna capsuleP, SQLF, ricevuta o qualificazione positiva è prodotta senza input esterni reali. Il mandato del successivo caso Staff resta distinto.
