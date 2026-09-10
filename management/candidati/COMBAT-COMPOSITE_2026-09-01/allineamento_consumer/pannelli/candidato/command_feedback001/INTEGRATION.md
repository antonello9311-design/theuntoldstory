# Integrazione locale feedback Common001 · completata, da caricare

TASK-ID LAND-COMMAND-FEEDBACK-INTEGRATION-001 · LAND-UI. Mandato PM dopo review indipendente0/0/0 SHA7a052768d950ca2ef4355bad01b3db3ad267e8ebb2e9a1638b27ea9edeb047d6. Sono integrati esattamente i tre sorgenti UI e la LAND della candidata001 congelata: nessuna modifica al marcatore, ai contenuti, al builder o al manifest candidato.

La riconciliazione remota è stata fornita dal PM: main1028625475769d9486b3df178b3f965fe19a286a, LAND99 blob b788c09b947f7d7f24bd6d330c86f972c061bee0,841954B/SHA01daea519b8b4adb9fe8411799a46432c009c02f6a6d68b8dbfe772f248a648d. Questo incarico non ha usato GitHub/browser/DB/provider.

Prima delle sostituzioni sono stati conservati byteidentici quattro BEFORE in `_precedenti/command-feedback-before-integration001/`: LAND.html e ui/controller.mjs, mount.mjs, view.mjs. Gli AFTER sono le copie esatte dei corrispondenti file candidati. La ricostruzione inversa dei tre blocchi e del solo marcatore restituisce l'intera LAND99 originale byte per byte; non è una nuova campagna. Tutti gli altri sorgenti e i file della UI privata003 sono invariati.

BUILD.py e BASELINE.json congelati continuano intenzionalmente a riferire gli input precedenti: dopo l'integrazione i quattro percorsi canonici contengono gli AFTER. Per riprodurre quella costruzione usare una root isolata con gli stessi percorsi relativi, riportando i quattro BEFORE dall'archivio secondo `reproducibility_input_aliases` in INTEGRATION_MANIFEST.json; gli altri input vanno copiati solo se ancora corrispondenti ai loro hash originali. Non cambiare pin o usare la nuova LAND come BEFORE, non eseguire assemble097 e non sovrascrivere il sito per ricostruire il banco. Nessuna ripetizione dei sei casi già verdi è stata effettuata.

È stata modificata solo la riga land.html di dossier/aree/PUBBLICAZIONE.md: build LAND-COMMAND-FEEDBACK-CANDIDATE-001,844787B,SHA8b55c64134948ea4668433abeb4226894b7283704570ffa1d7c6dfa85f7d2c7e, stato «Da caricare». Non sono stati riscritti altri documenti centrali.

File applicativi integrati: `sito_live/land.html` e `management/candidati/COMBAT-COMPOSITE_2026-09-01/allineamento_consumer/pannelli/ui/{controller,mount,view}.mjs`. Il manifest elenca gli undici percorsi di consegna, impronte prima/dopo e copie preservate. La candidata e i suoi referti originari restano immutati. Nessun commit/push/deploy, invio di gioco, API o prova browser: caricamento selettivo e smoke restano a cura PM nei gate autorizzati. Non è attestata disponibilità live della build né una causa del tentativoAssalto010.
