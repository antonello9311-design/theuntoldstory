# Manifesto baseline branch QA

TASK-ID: `SUPABASE-BRANCH-GATE-001` · 03/09/2026

## Sorgente autoritativa

- Produzione interrogata in sola lettura: ref `tyhyxkslteigibktluml`.
- Registro sorgente: 461 migrazioni; head `20260903111028 esame_narratore_unificato_005_bersaglio_dichiarato`.
- Snapshot solo schema, senza dati e senza contenuti di `auth`, `storage`, Vault, secret, token o URL credenziali.
- Impronta SHA-256 dello snapshot normalizzato: `f331d3f4bad32125307c99137d2a2f18230c4b25b0bfba26e927b9e1d4505248`.

## Perimetro

24 schemi applicativi: `public`, `clan_innata_private`, `combat_gate_private`, `combat_spatial`, `combat_v2_composite_internal`, `combat_v2_elemental_internal`, `combat_v2_multitarget_internal`, `combat_v2_private`, `mission_ai_board_owner`, `mission_ai_service_owner`, `mission_declaration_owner`, `mission_exchange_combat_owner`, `mission_exchange_owner`, `mission_exchange_v3`, `mission_internal`, `mission_narrative_internal`, `mission_private_approval`, `mission_surface_internal`, `mission_test_room_g11a_r10`, `ninja_book_internal`, `png_builder_activation_internal`, `png_builder_internal`, `png_builder_v17`, `png_media_internal`.

## Normalizzazione riproducibile

1. Estrarre con PostgreSQL 17 uno schema-only della produzione, limitato ai 24 schemi elencati.
2. Rimuovere soltanto i metacomandi client `restrict`/`unrestrict`; rendere idempotente la creazione di `public`.
3. Omettere le 12 istruzioni di default privilege intestate a `supabase_admin`, non applicabili dal ruolo effimero; conservare ACL degli oggetti e default privilege di `postgres`.
4. Applicare lo snapshot come unica migrazione del workdir isolato, con versione `20260903111028`; registrare il nome esatto della head di produzione.
5. Ripristinare `pg_cron`; confrontare conteggi, impronte delle funzioni bersaglio, owner, `proconfig`, ACL, lint e advisor prima di usare il branch come gate.

## Esito attestato

- Branch `qa-exchange-monthly-2026-08-31`, ref `yvqeiorqrdlhuzxkssjg`, `with_data=false`, servizio `ACTIVE_HEALTHY`.
- 230 tabelle `public`, 732 funzioni `public`, 1719 vincoli `public`, 110 policy `public`: uguali alla produzione.
- Registro branch intenzionalmente compattato a una riga; versione e nome della head uguali alla produzione.
- Impronte pre-006 delle quattro funzioni bersaglio uguali alla produzione.
- 006 → rollback → 006 verde; rollback con ripristino esatto delle quattro impronte; owner, `search_path` e ACL invariati; probe runtime 4/4; advisor ERROR 0.
- Lint: gli stessi sei errori storici presenti in produzione, nessuna regressione attribuibile alla 006.

## Residui espliciti

- Il tentativo finale supportato, eseguito con ID branch esatto e stato `MIGRATIONS_PASSED`, è stato accettato ma il readback è rimasto `MIGRATIONS_FAILED`: metadato control-plane stale rispetto al data-plane attestato.
- `pg_net` è 0.20.4 nello schema `extensions` sul branch e 0.20.3 nello schema `public` in produzione. Le quattro funzioni 006 hanno zero riferimenti testuali e zero dipendenze di catalogo verso `pg_net`; nessuno spostamento o downgrade è stato tentato.
- Eccezione PM del 03/09/2026: i due residui precedenti sono non bloccanti per questo solo rilascio e non costituiscono precedente alla regola generale del gate branch.
- Il baseline è schema-only: non sostituisce replay con dati, canary LIVE o valutazione qualitativa della prosa.
