# HANDOFF · PROD-V5-01

## TASK-ID
PROD-V5-01 / executor DB-CORE nel cantiere QA-BRANCH-BASELINE-REPAIR.

## Scope toccato
QA: unica campagna in rollback. LIVE: due apply distinti byte-exact codice336 e seed337 autorizzati PM; nessun Edge/UI/provider/account/sessione/Staff mutato.

## Contratti usati/modificati
Freeze aff24e0281cb8647aea817c89b587b51f0db946b0061000e0032937456711f8b,11/11 file,review0/0/0. Nessun contratto modificato. Recovery18baseline+15helperpostgres-only/seedinerte distinta da fullrollback totale.

## Decisioni prese / OPEN
GO Antonello via PM su versioni/name/SHA e trasporto psql atomico confermato; due commit riusciti, INSERT di due nuove righe registro, nessun UPDATE/repair. Nessun COMMIT interno nei file congelati. OPEN: passaggio Edge/UI agli owner.

## Prove eseguite e risultato
**PROD-V5-01 LIVE, 05/09:** applicati in due transazioni separate autorizzate PM `20260904233136 esame_spatial_integrated_release_001` (statement SHA `95472cf8636c6b6352db4d1ab3857d063069091ceeeaa8f35c9ea2ec143214e3`) e `20260904233137 esame_spatial_arena_konoha_seed_001` (SHA `2fcab661a799a506a714a421097052a4ab81d79214cbc48634775b3972a76b12`), versioni lette dal registro dopo commit. Postflight 33 corpi/metadati/ACL verde; Konoha reale: 1 template10×10/radius0,5, 8 oggetti esatti, 2 slot PG(2,5)/PNG(7,5), 1 binding e 1 route **abilitati**; geometria hash `fa8e1d8d2097d9c2a7b75dd8abe42ae5` verificato. Non è inerte: producer collegato anche al legacy, route2D attiva solo Konoha. Prima/dopo: 61 esami totali/0aperti,160sessioni,77personaggi; cron e flag Staff/Suna/Konoha invariati. Advisor sicurezza aggiornato0errori/311warning/324info, non riclassificati. Nessun nuovo esame/provider/Edge/UI dal DB executor. Evidenza `management/candidati/QA-BRANCH-BASELINE-REPAIR_2026-09-04/referti/PRODV5_LIVE_APPLY_RESULT.json`, SHA `0c0edb962e8760b4aad13cdca551c60a433bc556dad56be7b7950f75e7caae6f`. Gate preliminare SQL16/16,Edge4/4,review finale0/0/0; nessun retry o recovery. Passaggio a Narratore/PM per Edge/UI secondo loro GO.

## Rischi o regressioni da verificare
Combined QA verde non sostituisce smoke narrativo LIVE. Advisor0errori/311warning/324info non riclassificati. QA resta vuoto ma è ora precedente alla head LIVE336/337: nessuna attestazione futura di allineamento senza nuovo confronto.

## Passaggio richiesto al PM
DB completato, evidenza consegnata a PM/Spatial/Narratore; proseguire Edge/UI solo nei GO dei rispettivi owner. Nessun ulteriore apply/prova/provider qui; pubblicazione sorgenti esclusa dallo scope executor.
