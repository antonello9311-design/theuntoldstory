# MISSION-RAPID-TRANSITION-PRIORITY-REVIEW-061

## Esito

**P0/P1/P2: 0/0/0 — VERDE.** Il delta rimuove l'unico valore incompatibile con `mission_plan_transitions_priority_check (priority >= 0)` senza cambiare identità, destinazione o autorità della transizione. Nessuna operazione live, DB, browser o provider è stata eseguita.

## Evidenze

- `db/INSTALL.sql:583-586`: la transizione terminale conserva `transition_key`, `from_step_key`, `to_step_key` ed `event_kind` derivati da `mission_rapid_owner.rule_transition(rule)`; cambia soltanto `priority` a `0`. La forma target compare una volta, la forma `priority,-10` è assente e non risultano altre priorità negative nel `prosrc`.
- La semantica rimane deterministica: l'evento della regola continua a identificare la stessa transizione; il delta non introduce una seconda regola, non modifica l'esito e non affida una scelta all'ordine dei record. Il contratto già vieta più condizioni native non standard per fase (`qa/CONTRACT.test.mjs`, test 16).
- `db/TRANSITION_PRIORITY_FIX.sql:8-25`: il frammento `-10→0` è vincolato a una sola occorrenza, richiede baseline `30a9523e58702a14aca5f7d8d4a05eae` e verifica il risultato `66b271669c92a89db12f497fcb4ac098`. L'estrazione statica esatta del `prosrc` candidato produce l'MD5 target.
- `db/TRANSITION_PRIORITY_RECOVERY.sql:8-25`: recovery esattamente inversa, con unicità del frammento target, pin iniziale `66b271669c92a89db12f497fcb4ac098` e risultato `30a9523e58702a14aca5f7d8d4a05eae`. L'inversione statica della sola sostituzione ricostruisce la baseline. Apply e recovery sono transazionali e non contengono `DELETE`, `DROP` o `TRUNCATE`.
- `db/TRANSITION_PRIORITY_FIX.sql:17-20` e `db/TRANSITION_PRIORITY_RECOVERY.sql:17-20`: restano obbligatori i pin `preview_for=c988923b347cc600b85bb215ea025663`, `mission_creation_preflight_v2=2bfa56c88e45c52eb4495ee1f7c5d870` e `mission_create_complete_v1=8a512021ec0335f6eddb8b859607b056`.
- `db/INSTALL.sql:993-1022`: il contratto Adatta missioni resta invariato. Il pin progressione `0bc40e0ff963c26a63e218f2aa95dd94`, la guardia `mission_generic_owner.unified_batches ub` e l'hook `mission_rapid_owner.try_native_terminal(p_session)` conservano le due occorrenze attese.
- `qa/CONTRACT.test.mjs:149-152`: il test 29 richiede la priorità terminale `0` e rifiuta ogni `priority` negativa. Suite eseguita con Node workspace: **29/29 PASS**, 0 fail.
- `MANIFEST.json:20,30-31,40-42`: pin di `INSTALL.sql`, fix, recovery e suite coerenti. Verifica SHA-256 indipendente: **26/26 artifact corrispondenti**; JSON valido; conteggio contract dichiarato `29/29` coerente con l'esecuzione.

## Verdetto

Il delta può superare il gate di review indipendente. Apply e collaudo live restano distinti e non sono stati eseguiti.
