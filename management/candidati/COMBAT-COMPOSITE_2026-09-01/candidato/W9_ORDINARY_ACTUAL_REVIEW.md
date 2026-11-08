# W9 Ordinary S22 — controreview AGG2 BEFORE guard

Ref: W9-REPAIR-AGG2-INDEPENDENT-20261108 · QA/DB-CORE · 2026-11-08 14:01 UTC.
Esito **P0/P1/P2 = 0/0/0** sulla candidata actual-bound corretta. Installazione possibile soltanto dopo nuovo preflight vivo interamente verde e nel mandato/finestra del Main; nessun apply eseguito dal reviewer.

Freeze actual AGG2 `0a88d879b1d63e84eb5ebd57c2c4e3feb85284ada5690e1b8638b464ba04aea2`; builder `c8b0cbfc5d8e76aa1591a15d09874f5886b55455d0d6cf1158bc8a3fedfba4c9`; installer-source `5057c2b7fc54c46f77bb081d11de54291197d11f6d1cc6071cca51ca33804b21`/435910B; manifest `2d7e0e9a113a81aae2c657d11232037629da20e34eb3caef652d7640ca224ab9`. Source56e178e0/49243B, Edge36 e full actual binding invariati.

## Causa e correzione verificata

Il preflight Main13:56:13 ha restituito15/16, soltanto headers_matchfalse, prima di qualunque DDL/apply. Diagnosi readonly SHA6b8d091e68e350f3179ec2c5f584ca4917d96d87724cb00fdde9363150bd6819 conservata nell’archivio `_precedenti/20261108_1358_w9_repair_a1_bad_beforeguard`. Non è drift DB: `beforefn.append(h)` e `afterfn.append(h)` conservavano la stessa istanza; `h.update(...)` sostituiva anche gli hash BEFORE con quelli AFTER. Le review precedenti non avevano rilevato questa condivisione del riferimento Python; il guard vivo ha correttamente impedito l’apply.

Fix funzionale del builder esattamente `beforefn.append(copy.deepcopy(h))`; unica altra differenza builder è metadata di storico AGG2. Verificato offline per tutti7 header esistenti interessati che ogni campo del nuovo BEFORE è identico alla baseline13:10 congelata. Tutti42 valori dei6campi hash/byte mostrati nel forensic readonly coincidono con i7 nuovi BEFORE, non con i precedenti AFTER; nessun pin ricavato arbitrariamente. Gli AFTER non sono stati modificati:22funzioni+27dipendenze=49header e contratti sono identici ad AGG1actual.

21/21 output del freeze verificati per SHA256/byte. Confronto semantico completo dei delta: manifest cambia soltanto functions_before e review_history. Nell’installer cambia solo statement7, il DO di preflight iniziale. Source,12DDL,PROJECTION,READBACK,FINAL_ENABLE,AdminTemplate,POSTBIND,UIgraph eRootformula sono byte identici alla candidata actual qualificata. Il solo fix deepcopy separa gli oggetti, senza rimuovere controlli, modificare ABI/ACL/RLS o alterare hash AFTER. La baseline resta Root8f; proof49,10precedentiTactics/indice677509/trigger/CHECK sono preservati. Root prevista524235/margine53 invariata.

Parser indipendente intero installer34statement/4DO, FINAL_ENABLE9/2DO, PREFLIGHT1SELECT; DO PL passano staticamente.12CREATEFUNCTION identiche alla Source qualificata. Le prove sorgente,17moduliEdge,finanza,recovery,actual18file eEZBR della review actual SHA3476216e2e12b95911d7c918cc4fd0f9634d6f5e46948d1cdf87c8ccf0c5aa41 restano riusabili per identità dei byte: Edgeversion36/verify_jwtfalse/SourceSet6d275299788701dd34339b6117ae702d7923e1457dbb10c3e62fa3766c2ac4cc/EZBR339b67a3793de2d8b71d335ae5ccb04e6b919779e7263fba46a3e9d3ca5629fa,18rawfilematch. PackingProjection43d6 invariato eCTE giàverificato identico alla dipendenzaWINDOW7 congelata.

## Conversione e limiti

Variante privata `W9_REPAIR_INSTALL_AGG2_APPLY.sql`, hash esatto nel JSON di questo referto, derivata con sole tre differenze: DOw9_stop→commento specificato, literalJSON tactics_review→approved_binding (ref/MDsha/Source56/findings000), ultimoROLLBACK→COMMIT.33statement/3DO,12funzioni/7ACL/INSERTapproval immutati. Non usare la variante precedente, il cui preflight attendeva erroneamente gli AFTER. Necessario nuovo preflight completo verde prima dell’apply, senza allentare guardie.

FINAL_ENABLE_SOURCE resta byte identico e separato: dopo readback DB actual ePOSTBIND, pubblicazione e verifica Pages/AdminRoot/Edge, applicare soltanto la formula già qualificata (removeenable_stop/exact9keysactualbinding/ultimoCOMMIT) con8statement/1DO/unicoUPDATEapproval. Nessun Root actual inventato e nessuna nuova review di codice necessaria se la conversione è esattamente quella formula. Fermo in caso di drift/guardrosso/finestrascaduta.

Stessa candidata cumulativa: iniziale0/1/1, AGG1chiusuraSQL/shape, questa AGG2builder; nessun azzeramento dei conteggi. NessunDBapply di AGG1; deployEdge36 conservato, policy nuova ancoraOFF. Scope soloOrdinaryS22, API f43/LAND0ff/moduloDC/Serviceescluso/publicOFF invariati.6Count+6Gen,upper0.0066344,capcumulativo0.10USD e deadline14:12:09UTC invariati. Nessuna proroga, Restore o ripetizione della formazione15.

Reviewer0SQLlive/0UI/0provider/0gameplay/0scritturecanoniche. La diagnosi DB è una cattura readonly del Main/owner, non una nuova query del reviewer. Qualifica statica ≠ apply, enable, Fato pubblicato o contabilità runtime. Conservare tutti i referti e gli esiti storici.
