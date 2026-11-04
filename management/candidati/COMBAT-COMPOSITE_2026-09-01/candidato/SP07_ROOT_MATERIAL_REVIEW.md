# SP07 · Controreview integrata materiale aggregata2

**PASS_MATERIAL_ONLY · P0/P1/P2 = 0/0/0**. Task INNATA-SP07-ROOT-MATERIAL-COUNTERREVIEW2-20261104.

SP07M-02 corretto:22 variabili PL esplicite hanno prefisso sp07_pl_; le due ricette pre/post usano alias sp07_byakugan_catalog e sp07_byakugan_quote disgiunti. Scansione AST indipendente di tutte113 espressioni del DO (18 statement,70 scalari,25 RHS): nessuna intersezione con Alias/RangeVar/CTE. Unico riferimento composto PL: sp07_pl_root_before.canonical_preimage, campo presente nella Root catturata. Il compiler applica e verifica lo stesso namespace anche per --suspend. Fonte17 e recovery10 espressioni restano integre nei propri scope.

Compiler8899b2440875cebbbcdeca59cf6f6cf725c2fd2f5a4b654795ed296603962cc7. INSTALL322299c4c68ec906d8f207dd392e6db3a1cbb1cf160417340305fd2d88e223be (669381B); PF8de09967de5a86277abf7b66e4500034e7aa71687f6dd7eec4d0d5b66655bc6a (111guard). Rigenerazione indipendente4output byteexact. Con lexer PostgreSQL distinto dal compiler, invertendo solo22nomiPL+2alias nel codice si recupera l’intero INSTALLc69d byteexact; PF si recupera invertendo solo2alias. Tutte31 capsule, unicaDDL53de e baseline Rootfullrow/90header sono intatte e confrontate alle catture. Restano coerenti91header,17group,2schema,2fingerprint,ABI/ACL,UI,pin,gates e custodia.

SP07M-01 rimane risolto: confronto booleano custodia e semanticSQL1099 byteidentici, receipt readonly boolean/true precedente preservato. Recovery d66a/c4e1 invariata: sospensione positiva Staff55000, OFF/legacy conservati; nessun installer futuro inventato.

Envelope ammessa: due sole SELECT pg_catalog.set_config con true immediatamente dopo BEGIN, prima del DO, stessa richiesta atomica. Chiavi app.sp07_root_material_review_ref e app.sp07_root_material_review_sha256; valori percorso canonico di questo JSON e SHA finale dopo freeze. Rimuovendo le due SELECT deve ritornare INSTALL322299 byteexact; nessun prefisso false o altro delta. Owner registra separatamente payloadSHA e ripete preflight111 vivo prima dell’apply autorizzato.

La review non attesta apply, compilazione completa PostgreSQL, runtime né apertura: parsing e scansione namespace hanno limiti espliciti. StoricoAPP1abort42703,green3f81 e red27eae327 conservato. Zero queryDB/browser/provider/gameplay del reviewer; deadline08:43:30,46comandi/5scene,L2ON65 e audit preservati.
