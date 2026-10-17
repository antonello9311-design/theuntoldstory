TASK-ID · C1266-ASYNC-RECOVERY-AGG3-20261014 · CONSEGNA SORGENTI VERIFICATI, RUNTIME NOT_RUN

Scope toccato · C1266 recovery async: journal UI pre-send e recupero ownership dopo reload/ACK perso; retry delle sole letture transitorie; timeout anche della lettura stanza; no_work autorevole; classificazione SQL strutturale del falso positivo H0.
Contratti usati/modificati · Estensione recovery chiusa nella stessa RPC status; marker ownership in audit esistente; risposta readonly errore esatta4campi, no_work distinto da none. Nessuna nuova RPC/firma/ACL/tabella/vincolo DDL. Native envelope conservato. Nuovi vincoli applicativi: invio Staff richiede journal persistibile/Web Locks; recupero richiede ownership e hash server; continuazione si ferma su Auth/schema/ignoti; solo transitori espliciti ripetibili entro50letture/380s senza reset. Nessun retry provider.
Decisioni prese · Aggregata3 e controverifica3 stessa famiglia, nessun reset. Agg2 RED0/0/3 e sorgenti precedenti conservati in _precedenti/2026-10-14_timeout_recovery_aggregate3; originale precedente conservato in _precedenti/2026-10-14_timeout_recovery_aggregate2. Stop al verde pertinente, nessuna quarta aggregata.
Prove eseguite · Reviewer indipendente /root/independent_review: SOURCE_ONLY0/0/0, F1/F2/F3 risolti, nessun ulteriore finding nella matrice concordata. Manifest iniziale/finale bd1e9881992ff53c7b9ae7db44f383dcc2e33ebcd8e2ebe07d2ec773e00344ef:32/32 riferimenti SHA/byte;80 riferimenti annidati coerenti. Node --check UI+14moduli PASS; SQL AST12/12/8stmt e PL grammar7/7/4unità con sole dichiarazioni rowtype sostituite record: grammatica, NON risoluzione catalogo/installabilità. File congelati non modificati dopo review; referto finale separato per evitare ricircolo hash.
Rischi / NON provato · Baseline viva/pubblicata non verificata in questo incarico. Installer actual, Auth/RLS/Storage/Realtime, browser/reload reale, provider, Staff2PG2PNG e qualità Fato restano NOT_VERIFIED/NOT_RUN. Gli output Root storici non sono una certificazione della nuova composizione. Non basta aggiornare i pin: occorre continuità con baseline corrente e nuova composizione pertinente.
Passaggio al PM · Correzione source-only consegnata. Human ha mantenuto Staff/browser/DB/GitHub e file centrali; nessun deploy/apply/enable/collaudo/pubblicazione. Riprendere operazioni solo dopo risorse libere e verifica del mandato pertinente. Integrare negli slot centrali già esistenti: SCHEDA = sorgenti agg3review0/0/0, runtimeNOT_RUN; HANDOFF = questa consegna; STORICO = 14/10/2026 · agg3 · recovery async e no_work corretti · source review0/0/0; area = nessun cambiamento operativo. Nessuno stato in uso dichiarato.

File rimasti locali, non pubblicati perché github:main e consumer LAND sono in uso alla task Human; elenco dello scope corrente (archivi storici nel manifest):

- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_UI_SOURCE.mjs
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_UI_CONTRACT.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_UI_DIFF.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_UI_STATIC.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_UI_HANDOFF.md
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_UI_MANIFEST.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_UI_FREEZE.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_DB_DELTA.sql
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_ASYNC_SOURCE.sql
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_EDGE_BUNDLE_FILES.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_EDGE_DIFF.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_CONTRACT.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_SDK_DELTA.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_STATIC.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_HANDOFF.md
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_MANIFEST.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_FREEZE.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_RECOVERY.sql
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_RECOVERY_PROTOCOL.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_RECOVERY_PLAN.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_RECOVERY_AGGREGATE_HANDOFF.md
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_RECOVERY_AGGREGATE_MANIFEST.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_SQL_REVIEW_STRUCTURE.py
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_SQL_REVIEW_STRUCTURE_RESULT.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_RECOVERY_COUNTER3.json
- management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_GENERATION_TIMEOUT_ASYNC_RECOVERY_COUNTER3_HANDOFF.md
