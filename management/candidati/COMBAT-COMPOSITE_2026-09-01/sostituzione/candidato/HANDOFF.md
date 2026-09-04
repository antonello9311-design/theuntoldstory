TASK-ID: `P1-A-COMBAT-EXAM-SUBSTITUTION-REBASE-001`

Scope toccato: solo `sostituzione/candidato/` nel cantiere COMBAT-COMPOSITE. La prima bozza ricostruttiva, resa obsoleta dalla conferma LIVE, e preservata in `sostituzione/_precedenti/rebuild_non_authoritative_draft/`. Nessun file condiviso, dossier, database, Esame, UI o LIVE modificato.

Contratti usati/modificati: autorita `generic_sostituzione_spatial_v1`; R9 live inerte e offer-only attestati; anchor exact `portable_single_use`, range Ninjutsu3/5/10/15, cooldown R1→R4, reaction1+chakra5, collisione full-footprint/bounds/occupancy fail-closed, commit e receipt operation-scoped. Congelata la shared identity `combat_exam_exchange_identity_v1` nell'ordine `exchange_id, exchange_version, root_application_id, attack_application_id, defense_application_id, substitution_event_id, resolution_revision`.

Decisioni prese / OPEN: nessun secondo resolver e nessun SQL mutativo. Il futuro adapter Esame sostituisce integralmente il ramo legacy di costo/cooldown/anchor e collega l'exact evento comune alla shared identity. OPEN prodotto0 nel sottoperimetro. Branch QA non allineato resta blocker esterno.

Prove eseguite e risultato: validator statico 36/36 GREEN; controllo antimutazione GREEN; checksum locali verdi. Evidenza storica R9 PG17 x2/race/replay/rollback citata come precedente, non come nuova integrazione. P0=0, P1=0, P2=0 sul contratto statico; provider0, mutazioni0. Gate integrato/apply STOP per branch QA head stale e `MIGRATIONS_FAILED`.

Rischi o regressioni da verificare: doppio addebito se il ramo legacy Esame resta attivo; event id rigenerato invece di quello common; divergenza della shared identity; leakage di coordinate/UUID; prova Esame aperta; drift ACL/body delle sette porte; replay non operation-scoped.

Passaggio richiesto al PM: integrare P1-B/P1-C sulla stessa revisione, poi riallineare il branch QA e svolgere una sola campagna completa. Nessun apply/enable/smoke e autorizzato.
