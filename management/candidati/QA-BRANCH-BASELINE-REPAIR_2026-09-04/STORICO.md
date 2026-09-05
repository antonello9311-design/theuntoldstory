# STORICO

04/09/2026 · r1 · aperto il cantiere autorizzato e acquisita la baseline QA/LIVE in sola lettura · in lavoro
04/09/2026 · r2 · candidata e review 0/0/0, GitHub pubblicato; replay fermo su `calc_vita_max` e inventario aggregato con terzo prerequisito `role_set_title` assente · bloccato
04/09/2026 · r3 · repair aggregato exact-LIVE preparato; controverifica finale 0/1/1 per newline nella migrazione storica e controllo rollback non fail-closed · gate rosso, nessun Rebase/Resume
04/09/2026 · r4 · nuova revisione autorizzata, due finding chiusi, PG17 verde e review 0/0/0; repair tre prerequisiti applicato QA, Rebase 21:08:51 abortito su quarto prerequisito ordinato `applica_recupero(uuid)` · STOP PM
04/09/2026 · r5 · PM autorizza fast path schema-only con eccezione control-plane; preflight trova `esame_prove` assente, export esteso interrotto su richiesta Spatial prima dell'apply · blocker unico, nessuna attestazione verde
04/09/2026 · r6 · ripresa autorizzata: unica materializzazione schema-only dei 24 schemi applicativi, manifest runtime LIVE=QA e postflight vuoto verdi; control-plane ancora rosso sotto eccezione, Spatial attestata · applicato inerte
05/09/2026 · r7 · GO nominativo per singola campagna COLLISIONI integrata ab83d353: 12 gruppi verdi, sostituzione esercitata, receipt consegnata e rollback/zero-state/catalogo verificati · GREEN QA, nessuna produzione
05/09/2026 · r8 · PROD-V5-01 SQL16/16verde,16calls/19,700966s e rollback verificato; Narratore4/4verde in93ms,0provider/SQL e review finale0/0/0 · combined GREEN, produzione invariata
05/09/2026 · r9 · GO PM nominativo e psql atomico: release336+seed337 LIVE exact,33corpi/ACL e Konoha1/8/2/1/1verificati,runtime invariato · DB applicato,route Konoha attiva,passaggio Edge/UI agli owner
