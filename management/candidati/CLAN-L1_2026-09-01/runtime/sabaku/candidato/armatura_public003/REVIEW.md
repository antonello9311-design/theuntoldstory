# Review indipendente — Armatura di Sabbia · apertura pubblica

## Esito finale

**P0=0 · P1=0 · P2=0 — VERDE**

## Passaggi

La prima revisione ha rilevato due P1: mancavano il pin delle versioni e degli hash delle funzioni collaudate; il controllo ACL copriva soltanto SELECT. La candidata è stata corretta prima dell'apply.

La controverifica finale ha confermato:

- presenza delle migrazioni `20260920121925` e `20260920125041`;
- corrispondenza dei sette hash live di `armor_eligible`, `armor_view`, `armor_activate`, `armor_upkeep`, `armor_absorb`, `consumer_options` e `narrative_context`;
- assenza per anon, authenticated e service_role di SELECT, INSERT, UPDATE e DELETE sul gate, con RLS e FORCE RLS attivi, zero policy e zero trigger applicativi;
- transazione atomica e unica mutazione limitata a `armor_release_gate.public_enabled=true` mantenendo `staff_enabled=true`;
- recovery conservativa che riporta soltanto `public_enabled=false`.

Reviewer indipendente: `sabaku_passive_review`.
