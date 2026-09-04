# Fonti mirate

- `management/candidati/COMBAT-COMPOSITE_2026-09-01/PIANO_P1_ESAME.md`:
  identità unica, tre verticali, branch QA obbligatorio e stop conditions.
- `management/coordination/HANDOFFS/TASK-PM-COMBAT-SPATIAL-AOE-001.md`,
  blocchi Sostituzione: `generic_sostituzione_spatial_v1`, portata3/5/10/15,
  lifecycle anchor, collisione fail-closed e payload before/impact/anchor/after.
- `management/coordination/HANDOFFS/TASK-EXAM-SOSTITUZIONE-SPAZIALE-DB-CORE-148A-OFFLINE.md`:
  transazione e audit server.
- `management/coordination/HANDOFFS/TASK-EXAM-SOSTITUZIONE-SPAZIALE-COMBAT-CORE-148B-OFFLINE.md`:
  payload Narratore, parità e anti-leakage.
- `management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/CONTRATTO_DB.md`:
  direzione/ampiezza derivate da posizioni autoritative e nessun dato inventato.

Coordinamento del 04/09/2026: la fotografia LIVE read-only del task principale
conferma fatti Sostituzione e request receipt già esistenti; la ricevuta candidata
li estende/normalizza. Il branch Supabase QA risulta stale/unhealthy: nessuna
prova integrata, apply o mutazione è stata tentata.
