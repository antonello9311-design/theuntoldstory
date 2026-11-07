# T3 RANGE10 · controreview unica aggregata1

**P0/P1/P2 = 0/0/0 · QUALIFIED_SOURCE_ONLY_INSTALL_BLOCKED_EXPIRED_WINDOW.** Ref `T3-RANGE10-ROOT-AGGREGATE1-INDEPENDENT-20261107`. Solo sorgente/parser/review. Fonte, installer e metadata rimangono STOP/PENDING/ROLLBACK; nessuna varianteAPPLY o bindinginstallazione prodotto. Finestra22:17:48UTC scaduta: questa qualifica non la rinnova.

Freeze `02aae57466f9a70c919918ee23fa4a91eb47b7582e04d9e427a2778982b0cf6c`,13/13hash/bytecount verificati. Componente `e163bd59baa530df14764ed361af658f312f171b88a4f1bdd6508c83d7b3de49`; fonte integrata `8054ddb373d95fd4c8e20a82eb163744e660813f20e02765a565f57c0b0bb777`; installer `4fd1312a936264f2463b12e01db421b93955612ce692e7154e70122a237c8d05`,182104B. Manifest `bca8ac4a1a3cdaf9e29d31b2b3b4d51da43300a7eb83e4878a5413a0934aa8a0`; builder `3d04078837c6dab9b6864c6b37b896ecb52e3223f1cddf88379a593c49d82882`.

## Errore precedente e correzione pertinente

Il precedente referto0/0/0 e l'unica apply382d8492 fallita atomicamente restano storici in `_precedenti/20261107_2216_t3_root_explicit_cast/`. La precedente previsione statica del conbin era errata: i castespliciti del DDL generavano funcformat1, mentre la proof pretendeva i castimpliciti2. Il vecchio preflight12/12 provava la baseline, non quella trasformazione postDDL. Il fallimento non è un PASSruntime e il rollback riferito dal Main mantiene Root36f. Nessuna nuovaquery è stata eseguita per questa controreview.

Aggregata1 modifica esattamente un ADDCHECK: da ARRAY con tre castnumeric espliciti a `CHECK(range_m IN(2,3,10))`. Confronto byte completo della fonteintegrata vecchia/nuova: soltanto questa sostituzione. L'intero installer, proiezione, preflight e readback, normalizzati esclusivamente i nuovi digestSHA256, non hanno altre differenze di codice. Tutti functions_before/after, dipendenze, conbinatteso/CHECKmetadata, indice677509, trigger, zeroaliasRoot e cap sono identici. WriterStaffguard e suo AST non cambiano.

Verificato indipendentemente sul sorgente ufficiale PostgreSQL17: transformAExprIn sceglie il tipo comune includendo la colonna numeric, converte i tre literal tramite coerce_to_common_type e costruisce ArrayExpr/ScalarArrayOpExpr. Quest'ultima coercizione richiede COERCE_IMPLICIT_CAST. Per la colonna numeric e i literalint4 catturati ciò è coerente con i tre FUNCEXPR impliciti della proof conservata. Fonti primarie: [parse_expr.c](https://github.com/postgres/postgres/blob/REL_17_STABLE/src/backend/parser/parse_expr.c#L1111), [parse_coerce.c](https://github.com/postgres/postgres/blob/REL_17_STABLE/src/backend/parser/parse_coerce.c#L1486). È una conclusione statica basata sul parser e sul catalogo precedente, non una lettura del nuovoCHECK nel DB o una garanzia di runtime. Il guardconbin esatto resta attivo proprio per verificare l'oggetto reale prima di qualsiasiCOMMIT futuro.

## Composizione e invarianti preservate

Enum precisamente2/3/10; nessunrangeaperto o5, nessunDDL sugli altri vincoli/dati. Unico writer con portata canonica10 richiede il gateTactics esistente prima di RNG/INSERT; ownedcontext/controller/offerte/versioni/round/geometria/occlusioni, ABI/ACL/RLS/FORCERLS, costi e anonimato restano quelli già esaminati. Nessuna nuova apertura pubblica o actorID futuro.

Proof3 resta completa:10header+11deps, CHECKcatalog/conbin/definition/tableACL/RLS/località/validated e nuovoOID derivato dal catalogo, indicepair e trigger invariati. Nove corpi precedenti non reinstallati. Root si ricompone da36f cambiando solo compacttactics_staff e dbSHA, zeroalias; cap524117/524288/margine171. Installer conserva operator/CAS/Staffquiet/custodia/authority/finestra, lock, adozioniCAS+append-only e runtimeassert/postguard. Nessuna guardia rimossa o pin atteso adattato al vecchioDDLerrato.

Admintemplate e POSTBIND byteinvariati: ricostruzioneRoot/cap/manifest/constraintactual e una sola mfRevision. Recovery conservativa invariata: dopo una riga10legittima soltanto forward, mai ridurre CHECK2/3 eliminando/modificando righe, seed, ricevute o storico, né writer senza guard. S18 resta chiusa e costi storici conservati.

## Evidenze e limiti

Installer19statement/6scopePL/1CREATEFUNCTION; preflight/proiezione/readback singoleSELECT; parsingSQL/PL e ASTPython validi. Nessun nuovoDBread/apply/UI/provider/Git/QA o banco locale; non letti seed o identitàoriginali. T3 NONPASS e runtime NOT_RUN. Una diagnosi statica sufficiente del fallimento, il rollback comunicato e questa controreview non attestano nuova installazione.

Nessuna ricettaeseguibile/varianteAPPLY generata oggi. Una futura ripresa richiede mandato e finestra espliciti, baseline/contratti/composizione riconciliati, review pertinente e preflightfresco; non basta cambiare data/pin o riusare il binding precedente. Conservare i conteggi e l'unico tentativo fallito, senza reset. L'apertura pubblica resta esclusa.
