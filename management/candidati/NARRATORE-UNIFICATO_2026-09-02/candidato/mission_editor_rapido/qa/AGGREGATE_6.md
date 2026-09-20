# MISSION-RAPID-AGG6-031 · sesta aggregata autorizzata

Stato: **candidata review10 congelata per controreview indipendente**. Nessuna mutazione live.

## Causa corretta

Il secondo apply review9 è terminato atomicamente con `MR_PROGRESS_HOOK_DRIFT`: il pin MD5 della funzione viva era corretto, ma l'anchor testuale precedeva l'introduzione della guardia `mission_generic_owner.unified_batches`. Il tentativo non ha installato né schema rapido né hook.

## Delta

- `db/INSTALL.sql` e `db/RECOVERY.sql` usano lo stesso frammento vivo completo, compresi alias `uo`, esclusione del batch `preparing` e legame tramite `route.event_id`.
- Il pin `0bc40e0ff963c26a63e218f2aa95dd94` non cambia.
- Il test di contratto 22 prova due occorrenze dell'anchor in ciascun artefatto (old/new), posizione dell'hook dopo `narration_pending` e presenza unica del pin.
- Manifest aggiornato a `mission-rapid-editor/2026-09-19.review10`.

## Evidenza readonly

La simulazione sulla definizione viva ha misurato: `old_count=1`, `new_count_before=0`, `new_count_after=1`, `adds_single_hook=1`, `preserves_unified_batch_guard=true`; MD5 ipotetico della funzione composta `17b27d084e906b573086f36f6063aab6`. Nessun SQL mutante eseguito.
