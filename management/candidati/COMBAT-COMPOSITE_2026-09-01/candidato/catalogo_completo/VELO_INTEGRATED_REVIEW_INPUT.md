# Velo Staff · revisione R2 dei comparatori

La prima installazione ha sollevato `catalogo_eligibility_owning_port_drift` nel comparatore E52 e PostgreSQL ha annullato la transazione. Il referto canonico `VELO_STAFF_INSTALL.json` SHA-256 `974fede3201b8f966da3b1396ef1dba76c585f5134138c34daa3673b8c5b93ac` lega l'errore all'Entry `b1e9f482ee4c4f2cd7a92117eebb8e6367ef765458037a0e51781479388bc070`. Il preflight R2 rivede Root `0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d`, riga invariata, gate Velo assente, E52 e Common validi, due missioni qualificate, zero sessioni e zero inviti pendenti.

L'aggregata R1 aggiornava i manifest MD5, lasciando i due SHA-256 delle DDL precedenti nella tabella di confronto diretto degli otto owning port. La ricognizione readonly di `pg_proc` trova gli stessi pin nel successivo `clan_innata_private.eligibility_release_assert()`. Le funzioni e i loro ACL erano già nella revisione R1. La R2 aggiorna le associazioni esatte di corpo nelle due autorità.

| Firma | SHA-256 prima | SHA-256 candidata |
| --- | --- | --- |
| `public.combat_v2_actor_ability(uuid,text,uuid,boolean)` | `512afb87dcdaaae4c394ea5eff500bcbf12123dea43ee13588e84fb5c19563d8` | `31512f4525275b901ce810f8d23d15a3221091ae6a0f062c40a8d4232c038748` |
| `public.combat_v2_character_snapshot(uuid)` | `20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3` | `9d97f3d6acd6f723f82b51723be91d0a185ee1be1b8060f5bd9d41379d65ea1d` |

E52 conserva tutti gli otto confronti DDL, proprietario, attributi e ACL. L'assert Common usa i due nuovi pin soltanto dopo verifica E52 e per una delle due identità Velo. I rami storici conservano i pin originali. La composizione aggiorna i due membri compat2, l'alias Core dell'assert Common `db_core.combat_innata_functions.41419`, peer6, descrittori Joint, hash DB/config e identità Root. L'AST del forward rispetto a R1 mostra soltanto il corpo E52 sostituito e la nuova dichiarazione sostitutiva dell'assert Common già esistente nello schema. Tutti i corpi di gameplay restano byte per byte uguali a R1.

## Proiezione eseguita in PostgreSQL READ ONLY

- Root Staff `2bcaf1943d787202406fad30d0a628869df77aae792eaa38d089dea41f393e42` e Root inerte `c1f445dc28d216f43f089f9312cf66b57ca68753e66ff849a28e56b6f6552fc3`, entrambe 523.908 byte. I due report di dimensione preservano UI e bundle Edge.
- I due file `VELO_R2_FULL_SEALS_*_READONLY.sql` eseguono la proiezione dei corpi completi di E52 e Common in transazione di sola lettura. La proiezione usa catalogo corrente, SHA e MD5 dei corpi candidati e Root calcolata dal progetto. I confronti reali dei manifest, privilegi delle funzioni già presenti, alias, gate preesistenti e prove delle declinazioni Staff/inerte passano nei due modi. Il test rappresenta separatamente le 10 funzioni e le 4 relazioni Velo ancora assenti mediante AST, ownership, RLS e grant espliciti dei componenti. Nessun DDL o gameplay viene eseguito.
- Cardinalità attestate in entrambe le modalità: 8 owning, 34 shared, 7 alias condivisi, 66 private, 12 relazioni e 10 trigger, 3 native, 6 peer, 75 joint e 2 compat. Le ricevute conservano i digest. La funzione di release applicata dovrà attestare le 10 funzioni e 4 tabelle effettivamente create.
- Grammatica SQL dell'installer 100 istruzioni e della recovery 6. L'analisi offline dei due resolver già esistenti usa una normalizzazione `%ROWTYPE` locale in memoria. Nessun rilascio R2 applicato e nessuna prova Staff eseguita.

## Consegna

`VELO_STAFF_R2_INSTALL_SOURCE.sql` e `VELO_STAFF_R2_RECOVERY_SOURCE.sql` richiedono nuovi referti indipendenti esatti 0/0/0. Il materializzatore R2 esige l'impronta del sorgente corrispondente. Il postflight conserva i controlli effettivi di E52 e Common. La recovery chiude il gate Velo e usa una Root inerte attestata, con storia e contenuti Missioni conservati. `VELO_R2_NATIVE_DDL_INVERSES_REFERENCE.sql` è il confronto byte per byte dei corpi precedenti, incluso l'assert Common, e non è la recovery operativa.
