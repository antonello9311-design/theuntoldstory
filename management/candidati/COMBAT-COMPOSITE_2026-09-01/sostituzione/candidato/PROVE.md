# Prove P1-A

- Validator statico: 36 banchi continui/unici; profilo, identity, firme, lifecycle, range, economia, collisione, replay e anti-leakage pinzati.
- Controllo antimutazione: il file SQL candidato contiene soltanto `BEGIN READ ONLY`, assert catalogali e `ROLLBACK`; nessun DDL/DML/GRANT.
- Evidenza storica riusata: R9 aveva gia coperto PG17 x2, stessa selezione/resolve concorrente byte-equal, fingerprint conflict, profili exact e rollback/recovery. Non e stata spacciata per nuova prova integrata sulla head corrente.
- Branch Supabase QA: data plane healthy ma head stale e control plane `MIGRATIONS_FAILED`; suite integrata, race/recovery e gate apply non eseguiti.
- LIVE: sola fotografia gia registrata dal coordinamento; una prova Esame aperta, zero test o mutazioni su di essa.

Esito del sottoperimetro statico: `P0=0, P1=0, P2=0`. Esito del gate integrato/apply: `STOP_BRANCH_QA_NOT_ALIGNED`.
