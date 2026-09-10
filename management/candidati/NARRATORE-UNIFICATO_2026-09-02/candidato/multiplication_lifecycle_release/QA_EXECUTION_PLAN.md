# NARRATIVE-MULTIPLICATION-LIFECYCLE-QA-ENVIRONMENT-002 · banco congelato, non eseguito

TASK-ID corrente: NARRATIVE-MULTIPLICATION-LIFECYCLE-QA-ENVIRONMENT-002. Owner QA-PLAYTEST. Prima correzione della preparazione, prima di qualsiasi campagna. Scope: QA_ENVIRONMENT.json, QA_RUNNER.py, questo piano e due predecessori byteidentici in _precedenti/qa-before-environment002/. SETUP/CASES e prodotto restano immutati. Candidata di prodotto e review indipendente immutabili. Consegna di sola costruzione con una inspect Docker readonly di soli metadati autorizzati; 0 query SQL, esecuzioni runner, browser, provider e azioni PG. Nessuna qualifica runtime dichiarata.

## Contratto e decisione di copertura
La matrice resta G1–G4 di QA_PLAN.md. Si esegue il corpo BEFORE/AFTER esatto e l’hook corrente su PostgreSQL17.6, con check_function_bodies ON e le dipendenze SQL effettivamente percorse. Il corpo dell’hook non viene modificato. La definizione BEFORE 955228bdc23c89cdb287198db57231b8, AFTER 6d7cbbfbd1ecbae7f8efad6e7eeaca36 e hook a417e6a98201a2177cb8c244a736bb3c vengono confrontati con pg_get_functiondef; owner postgres e ACL {postgres=X/postgres} controllati prima/dopo.

**INSTALL.sql e RECOVERY.sql completi: NOT_RUN.** Lo schema minimo non equivale alle sette relazioni native vincolate: i pin comprendono owner, ACL, colonne/not-null, CHECK/FK, RLS e trigger. Otto funzioni native hanno nel BASELINE soltanto identità/impronte/estratti; mancano i corpi necessari a riprodurre i pin. Restano inoltre incomplete nel baseline corrente varie dipendenze legacy Staff/Clone. Non si inventano trigger o autorizzazioni per far passare le guardie. Nessun risultato COMPONENT_PASS sblocca quel gate di rilascio: ROOT deve assegnare il controllo completo pertinente, recuperando solo sorgenti autentiche corrispondenti alle impronte. Non è necessario chiamare il motore di gioco per confrontare i metadati, ma il banco minimo non può fingere di possederli.

Le guardie Staff `staff_test_allowed`/`combat_v2_values_written`, lo schema di lettura e l’hash dei messaggi derivano dal precedente NARRATIVE_TECH_QA.py; sono fonte del banco storico minimo, non attestazione fresh delle versioni live. Il banco usa ruoli nominali già presenti, non muta ruoli globali né emula Auth. Il catalogo sintetico deriva dalla fixture storica ed è confrontato BEFORE/AFTER: non certifica il testo pubblico aggiornato. Il ramo 006 è rappresentato semanticamente (`original_found`, copertura consumata per primo attacco, reazione schivata) con identificatori nuovi/sintetici e digest calcolati dai fatti della fixture. Nessun originale, selezione privata, seed, coordinate o role reale copiati. Nessuna chiamata al resolver/RNG o affermazione che la ricevuta sintetica sia nata da gameplay nativo.

## Fixture e normalizzazione
Due PG nominali Attore A/B e due role sintetiche, sui valori già usati dal banco precedente. Nessun dato di schede reali. Una formazione del round precedente viene consumata dalla ricevuta dello scambio corrente; il Clone legacy del banco è già terminato e deve restare identico nella proiezione. `original_index` e RNG restano null; un marcatore sintetico privato nelle figures verifica che esse non raggiungano lo snapshot. Tabelle minime dichiarate, nessun CHECK/FK/policy/trigger nativo artificiosamente ricreato.

G2 verifica i quattro campi esatti della conclusione Moltiplicazione, fonti e conclusione Clone invariati, determinismo, roster e fonti role invariati, snapshot `resolved_facts` ancora JSON-string. G3 usa solo tre variazioni delle invarianti note: target di round estraneo escluso, hash ricevuta alterato respinto, terminale incoerente respinto. Ogni variazione avviene in subtransazione con rollback e confronto dei dati; nessun tiro nuovo.

G4 include il blocco UNUSED estratto byteidentico da BUILD.py in una funzione **di banco** identificata `qa_exact_recovery_use_guard`, senza attribuirgli equivalenza al wrapper intero. Gate nominativo assente negato; presente primauso ammesso; storia contenente la conclusione in object/JSON-string negata. Null/scalari attraversati in sicurezza. I dati aggiunti nella verifica dopo-uso vivono esclusivamente in subtransazioni che terminano con rollback; il percorso primauso resta vuoto. Nessun DELETE, reset o riscrittura della storia. Poi il BEFORE esatto viene ripristinato con COMMIT; postflight su altra connessione confronta corpi/ACL/hook, snapshot BEFORE e digest di tutte le 22 relazioni fixture. Questo è recovery della componente, non qualifica di RECOVERY.sql completo.

## Unica campagna futura autorizzabile
ROOT acquisisce prima file risultato e risorsa esclusiva del container condiviso. Questo incarico non prenota la risorsa di esecuzione né esegue container/SQL: usa soltanto la singola ispezione readonly dei metadati autorizzata dal PM. Il runner deve essere eseguito una sola volta, dopo review del banco e gate ROOT, senza patch/retry durante la campagna. Output effettivo assegnato dal PM separatamente; il runner rifiuta di sovrascriverlo.

Container esistente atteso: `tus_ordinary_compose_qa_db`, fullID `8681f0364c9f27bd5c856d2cc0f20690c8bc2f8d4aaf36de3394241b1596c019`. Database esclusivamente NUOVO `narrative_multiplication_lifecycle_001`, TEMPLATE template0. Nessun riavvio/reset/stop o modifica di altro banco. Ispezione futura limitata a ID/nome/immagine/rete/porte/mount/stato, mai Env. Configurazione osservata e fissata in QA_ENVIRONMENT.json: immagine supabase/postgres:17.6.1.136 e suo digest, rete tus_ordinary_compose_qa_network, solo 5432/tcp→127.0.0.1:54322, sette bind SQL read-only e due volumi QA config/data. Il runner confronta tutti gli otto campi e tutti i metadati dei nove mount, ordinati per destinazione; qualunque drift ferma prima della prima SQL. Nessun contenuto dei mount o Env acquisito. Non si applica il precedente requisito non richiesto network-none/no-mount: era incompatibile con il banco compose espressamente assegnato. La correzione fissa la configurazione autorizzata e non accetta genericamente altre reti o porte. Ruoli postgres/anon/authenticated/service_role richiesti già presenti; se mancano, STOP senza crearli nel container condiviso.

Massimo **8 submission SQL / 10 minuti / 0 provider e token**, preparazione inclusa:

1. Preflight locale: versione17.6, owner, ruoli nominali e assenza del nuovo DB.
2. CREATE del solo database nuovo.
3. SETUP e BEFORE/hook/fixture esatti, baseline di dati e snapshot, COMMIT.
4. Componente AFTER COMMIT e G1 pin/owner/ACL/hook.
5. G2 proiezione e conservazione legacy.
6. G3 dinieghi con rollback.
7. G4 guardia storica e recovery della componente BEFORE, COMMIT esplicito.
8. Postflight in connessione distinta: dati/storia, corpi/ACL e snapshot, esito quattro gruppi.

Ogni submission usa psql separato, Docker assoluto e socket locale esplicito; timeout statement/transaction PG17 e processo limitati al residuo del budget. Il container condiviso non viene mai fermato al timeout. Errori dei gruppi sono raccolti senza estendere i casi; fallimento setup impedisce i gruppi dipendenti e viene consegnato NOT_QUALIFIED. Il postflight è diagnostico anche se l’install della componente fallisce. Nessuna produzione/provider/API/RLS/Edge/giocabilità Master/utenti/PNG è qualificata. Persistono DB e referto per diagnosi, senza cancellazioni.

Comando proposto (solo ROOT con scope e output assegnato):
`python3 -B QA_RUNNER.py --authorized-once --expected-container-id 8681f0364c9f27bd5c856d2cc0f20690c8bc2f8d4aaf36de3394241b1596c019 --output <percorso_risultato_assegnato>`

## Prove di costruzione e consegna
AST Python verificato, nessuna esecuzione del runner. Il runner incorpora SHA-256 di otto input candidati, due SQL QA e QA_ENVIRONMENT.json; drift ferma prima di Docker/SQL. Il blocco di recovery è lo stesso della candidata, nessun prompt o formula modificati. Restano distinti review del prodotto giàverde, costruzione di questo banco e sua campagna ancora NON ESEGUITA.

Impronte congelate (nessuna autoreferenza circolare: ENVIRONMENT non contiene hash del runner corrente):
- QA_ENVIRONMENT.json: `883a7d319a08a975034b5159896e45be8486baf36ff8b83e0ffa1262c64ed16c`
- QA_SETUP.sql: `4321f741b78d0e6d8b2f101e60147d7a58350e95a1b3bac874c470f8a6b88643`
- QA_CASES.sql: `72a7cfbb167e14334b7c526d32c4167e89ab6f0f6850b10b0d286605ffceb393`
- QA_RUNNER.py: `9e37a05561ca11e88bc3ea28e74345cbca624918b2a44fa36b7959f64209bc8e`

Fonti tecniche pregresse:
- NARRATIVE_TECH_QA.py: `9c61b367cfb133a0ebb888bafb90d0bbf4c0c4879e2cf9d0f3656c60b626d0db`
- NARRATIVE_TECH_QA.sql: `93d3a134365ac5444b29a952ba82943e7b8a0ab464f65f305e8f34dc1862f549`
- NARRATIVE_TECH_BASELINE.json: `18ea4f2558e1b1f606b68369f76933ca6ca8cf1f94a448aaea78ee86954695e1`

Passaggio richiesto al PM: verificare la correzione di ambiente congelata (SQL test counter ancora 0; futura matrice invariata 8 SQL/4 gruppi/10 minuti), acquisire scope di esecuzione e risultato, poi eseguire una sola matrice. Il gate dei wrapper completi resta separatamente aperto anche in caso di COMPONENT_PASS. Nessuna apertura o prova live autorizzata da questa consegna.
