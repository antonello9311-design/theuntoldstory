Stato: **applicato inerte** · baseline QA senza dati; supporto PROD-V5-01 LIVE concluso, codice/route Konoha attivi (non inerti)

# Cantiere · QA-BRANCH-BASELINE-REPAIR

## Scopo

Rendere il data-plane del branch QA esistente equivalente al catalogo applicativo di produzione e vuoto, senza dati, segreti, PII, modifica della produzione o falsificazione della history.

## Stato operativo

- **PROD-V5-01 LIVE, 05/09:** applicati in due transazioni separate autorizzate PM `20260904233136 esame_spatial_integrated_release_001` (statement SHA `95472cf8636c6b6352db4d1ab3857d063069091ceeeaa8f35c9ea2ec143214e3`) e `20260904233137 esame_spatial_arena_konoha_seed_001` (SHA `2fcab661a799a506a714a421097052a4ab81d79214cbc48634775b3972a76b12`), versioni lette dal registro dopo commit. Postflight 33 corpi/metadati/ACL verde; Konoha reale: 1 template10×10/radius0,5, 8 oggetti esatti, 2 slot PG(2,5)/PNG(7,5), 1 binding e 1 route **abilitati**; geometria hash `fa8e1d8d2097d9c2a7b75dd8abe42ae5` verificato. Non è inerte: producer collegato anche al legacy, route2D attiva solo Konoha. Prima/dopo: 61 esami totali/0aperti,160sessioni,77personaggi; cron e flag Staff/Suna/Konoha invariati. Advisor sicurezza aggiornato0errori/311warning/324info, non riclassificati. Nessun nuovo esame/provider/Edge/UI dal DB executor. Evidenza `management/candidati/QA-BRANCH-BASELINE-REPAIR_2026-09-04/referti/PRODV5_LIVE_APPLY_RESULT.json`, SHA `0c0edb962e8760b4aad13cdca551c60a433bc556dad56be7b7950f75e7caae6f`. Gate preliminare SQL16/16,Edge4/4,review finale0/0/0; nessun retry o recovery. Passaggio a Narratore/PM per Edge/UI secondo loro GO.

- 05/09, nuovo GO Antonello «prova» via PM: unica campagna integrata `ab83d353f409d4dfa136e56769566b041b76dcea452af495a0714cef0bf1445e`, 30/30 file e review finale 0/0/0 statica. Esito GREEN, 12 gruppi/24 assert, 30 chiamate, 4,876059 secondi, 0 provider; caso COHERENT, sostituzione EXERCISED. Receipt e attestazione in `referti/COLLISIONI_CAMPAIGN_RESULT.json`.
- Preflight fresco: parent corretto, `ACTIVE_HEALTHY`; Database/PostgREST/Auth/Realtime/Storage/Edge Healthy, solo Migrations Unhealthy sotto nuova eccezione specifica PM. Manifest semantico puro QA=LIVE=postflight `ee122c0d167f399d908146e5a48d4134ec7e6d2c216887f2af38b8835b031992`; 398 tabelle vuote dopo rollback totale. Nessun nuovo branch, rebase, cancellazione o produzione; history non allineata dichiarata.
- I tentativi di replay migration sono terminati: l'ultimo Rebase delle 21:08:51 è abortito atomicamente su `applica_recupero(uuid)` nella migrazione `20260717103955`. Per mandato PM non sono consentiti altri Rebase/Resume né riparazioni simbolo-per-simbolo.
- Autorizzazione nominativa: `AUTORIZZO FAST PATH QA CON ECCEZIONE CONTROL-PLANE`, valida esclusivamente per `kkzvwqsmuqunkjzhlkon` e per questo rilascio.
- Eseguita una sola materializzazione transazionale schema-only sul branch QA dei 24 schemi applicativi LIVE; esclusi dati, sequence values e schemi gestiti. Produzione, Edge/provider, cron, runtime, prove e account invariati.
- Export LIVE: 4.424.862 byte, 398 tabelle, 295 trigger, 110 policy; scansioni `COPY`/`INSERT`/`setval`/segreti/PII tutte a zero.
- Confronto runtime semantico LIVE↔QA: 10.281 righe per lato e SHA-256 identico `e5cc3e57f36585a5565eb89ecaeaaa8440827b42db2dd566c460a892eee52bca`. La normalizzazione esclude solo la posizione fisica di una colonna storicamente rimossa, i privilegi impliciti del proprietario e l'alias `PUBLIC` su `public`; i ruoli applicativi espliciti coincidono.
- Postflight: tutte le 398 tabelle applicative vuote; `characters=0`, prove Esame aperte `0`, cicli narrativi non terminali `0`, sessioni Combat aperte/non terminali `0`, runtime Accademia `0`.
- Registry head QA `20260717085531`; head produzione `20260903203601`: la history QA non è stata modificata o camuffata. Il control-plane resta dichiaratamente `MIGRATIONS_FAILED`; il data-plane è raggiungibile e schema-equivalente sotto l'eccezione one-shot.
- Attestazione verde inviata alla task Spatial `01a06db8-9909-79b2-8f0c-072ec5c60aad`.
- GitHub: nessun artefatto fast-path temporaneo da caricare; la copia locale byte-esatta di `20260717103955` resta non caricata e non serve al percorso autorizzato.

## Vincoli

Nessun apply produzione; nessun Edge/provider; nessun branch nuovo o cancellato; nessun Rebase/Resume o retry adattivo. L'eccezione non bonifica il control-plane e non costituisce precedente.

## Prossimo passo

DB LIVE concluso e consegnato a PM/Narratore. Nessun altro apply o prova qui. QA ora precedente alla head LIVE336/337: nuovo confronto necessario prima di riutilizzo. Pubblicazione sorgenti agli owner.
