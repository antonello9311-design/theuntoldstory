# Campagna nativa visibilità Moltiplicazione001

Stato: sospeso · COMBAT-MULTIPLICATION-VISIBILITY-QA-001 · QA-PLAYTEST.
Piano congelato prima della prima SQL: 2026-09-10T06:25:24.934615+00:00.

## Mandato e matrice approvata

Il PM ha approvato espressamente il10/09/2026, nel mandato Antonello sui collaudiClan, la matrice aggiornata di4gruppi/4casi G1/G2b/G3/G4. G2a è NON_APPLICABILE al prodotto attuale perché invisibilità è futura, non PASS; il requisito futuro resta conservato. Questa approvazione sostituisce soltanto lo stato proposta della preparazione congelata: i suoi file e QA_PLAN originale non vengono alterati. Review prodotto0010/0/0 chiusa; esecuzione distinta, nessuna nuova review del prodotto.

- G1: apertura ordinary nativa da2identità sintetiche, iniziativa nativa senza forzature; preparazione Assalto1copia con geometria nativa (10,9)/(9,10), originalefermo, costo15 e invarianti.
- G2b: grantdiretto presente ma proiezioneblocked; profilo resta disponibile, deve raggiungere precisamente errore22023 panel_multiplication_assault_contact_invalid. Un rifiuto prima non è PASS.
- G3: bersaglio visibile oltre contatto, errorecontatto nativo con rollback del solo assetto sintetico negativo.
- G4: RECOVERY integrale COMMIT dopo snapshot14relazioni; duecorpi/ownerACL/config e dati identici. DB conservato.

## Budget e ricetta congelati

Unico run, massimo8submission SQL totali inclusi creazione/setup,600secondi,0provider/token/browser/produzione/retry. Nessun probe preliminare o campagna aggiuntiva. Ordine8fasi: preflight+CREATE; bootstrapfixture; INSTALLCOMMIT; G1; G2b; G3; snapshot+RECOVERYCOMMIT; postflight. Errori prerequisito fermano dipendenti NOTRUN; rossi sicuri dei casi sono raccolti come runner. Nessuna riparazione/reset/nuovo ruolo/configglobale o modifica runner/prodotto.

PostgreSQL17.6, fullcontainer8681f0364c9f27bd5c856d2cc0f20690c8bc2f8d4aaf36de3394241b1596c019; DBnuovo combat_multiplication_visibility_001. Il runner verifica configurazione pinzata e fonti nella stessa unica esecuzione, senza Env/mountcontents/segreti o righePGreali. Entrambi aliascluster eDBprenotati.

Comando autorizzato: QA_RUNNER.py --authorized-once --approved-four-case-matrix --output /private/tmp/multiplication-visibility-qa001/raw-result.json. Nessun output precedente riusato.

Runner SHA256 d6ee0e6e4c14eb203b9813046c4a7f6b85c9df5488adfead483de1b2e605285d.
Manifest preparazione SHA256 6c06f5dbd59c9ceb09cbfefdea92b263e50b54ca1fcf9ab90f1808d09891a1a2.

| Fase | SHA256 SQL congelato |
|---|---|
| 01 | `4a1dc70185ea1cbdc0e001cb461ca1be0a5fce3b80bc0a20ab5d7e70ef03fa1e` |
| 02 | `48c20b4830ebfd81631e4c5debd182f0c6f8d7a5f98f72178a3ccb0ab0b8988c` |
| 03 | `da493c29f699fb3aa70dfaab1e52c533a130ff7f6047bb7ffaa6d31392d9d805` |
| 04 | `a5f5a8c5279f3b713b47d5fc37895af566c58e21637bf071e95b19f155ec39fc` |
| 05 | `dd2965208795ed9b80790a7b11cf35eabdae0e8f49cc72c66df87dfaa80290a6` |
| 06 | `cecf439a4794cae3aca9198cc9312f5763bd0a06a0edb130de5578ad1ccdea6d` |
| 07 | `79aba9653872299e1fa0278f586066eebda2abe830b141a06b0697d77eeb8c9c` |
| 08 | `3e885a66164a628d536a6d0469f5a56be6b38aa78fac29fd01d3f76985aaf9e2` |

## Consegna iniziale / limiti

Scope: soli QA_EXECUTION_PLAN.md, QA_RESULT.json, QA_MANIFEST.json, QA_REVIEW_NOTES.md. Contratti e19input invariati. Riepiloghi comuni al PM.
Native PostgreSQL locale e identità nominali non certificano Auth reale/RLS/API, UI, attacco risolto, PNG, Master o TestRoomutenti, né futura invisibilità. Nessun gate di produzione concesso. Qualunque risultato rosso viene consegnato con consumo e fase esatti, senza retry.

## Consegna finale

Unica campagna realmente eseguita: NOT_QUALIFIED;2/8SQL,1,860secondi,0provider/token/retry. Ambiente EXACT_MATCH, fase01PASS; fase02FAIL exit3 con neutral_geometry_pin_drift, inline_code_block r25. Tutti G1/G2b/G3/G4NOTRUN; G2a restaNON_APPLICABILE, nonPASS. INSTALL eRECOVERY candidata non eseguiti. Le impronte di entrambe le SQL coincidono con il freeze.

Fonte specifica QA_SETUP.sql46667–46670: controllo composto scene_fingerprint/geometry_hash; nessuna lettura ha acquisito il valore effettivo divergente, quindi non si attribuisce quale hash o causa tecnica. Bootstrap contiene COMMIT46617 prima della transazione fixture46620; seed fallisce prima di fixtureDO46686/COMMIT46709. Banco conservato, nessuna queryposterrore/reset/riparazione.

Passaggio richiesto al PM: valutare il prerequisito di geometria emerso, con referto completo congelato; nessuna ripetizione autorizzata da questa consegna. Reviewprodotto001 resta storica0/0/0, il gateQA è rosso e produzione non autorizzata. Il registro viene rilasciato sospeso per non promuovere il risultato a dipendenza qualificata.
