# Readiness P1 Combat · 04/09/2026

## Produzione — sola lettura

- Head: `20260903203601 esame_narratore_finale_ampiezza_006_recovery`.
- Prove Esame: 61 totali, 1 aperta. La prova aperta resta congelata e non viene identificata né toccata.
- Common Sostituzione già presente: R9 `20260901065823 common_sostituzione_spatial_runtime_bridge_009_media_r4_rebase`.
- Chiusura offer-only successiva: `20260901195205 combat_v2_substitution_spatial_offer_only`.
- Tabelle/capability/receipt spaziali pertinenti presenti ma vuote nello snapshot letto.
- Porte Combat e wrapper Esame presenti; le porte interne Esame non sono eseguibili da `anon`/`authenticated`.

Conclusione: il verticale P1-A è una attestazione/rebase con eventuale delta di innesto, non un secondo resolver.

## Branch QA

- Ref: `yvqeiorqrdlhuzxkssjg`, `qa-exchange-monthly-2026-08-31`.
- Data plane: `ACTIVE_HEALTHY`.
- Control plane: `MIGRATIONS_FAILED`.
- Head DB: `20260903111028 esame_narratore_unificato_005_bersaglio_dichiarato`.
- Non è allineato alla produzione.

## Esito readiness

`STOP_BRANCH_QA_NOT_ALIGNED` per migrazioni, integrazione, rollback/recovery, race e gate. Sono ammesse soltanto costruzione documentale/candidato offline e unit/fault injection locale. Per superare lo STOP serve riallineamento del branch; l'eccezione al solo control-plane non basta finché anche la head è diversa.
