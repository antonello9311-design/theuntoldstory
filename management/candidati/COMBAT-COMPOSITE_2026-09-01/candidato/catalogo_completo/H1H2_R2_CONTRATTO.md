# H1/H2 R2 · cattura dei manifest dopo i due DDL

B `a9487d1b3df0dc85ad619d797e2fe17a8a6b28ddcec7f9b88a412e1799d24203`. La migrazione R1 è terminata con P0001 `cure_reaction_post_manifest_drift`. Il rollback ha conservato la Root 4987, il descriptor e le cinque impronte osservate. Il client build2 è già pubblicato con commit `6e5f283f13950bf89584fa2b50ca1a7cf1a83e14`, Pages 44704697096 e ricevute canoniche effettive.

Il compositore aveva attribuito il SELECT delle due firme a shared_manifest e rimosso i capture di private, native, peer e changed_headers. La condizione del footer richiedeva tre header e la condizione successiva due. R2 ripristina le sei proiezioni dallo stesso originale installato e restringe la sola proiezione changed_headers alle firme Aki ed E52. I sei controlli usano IS DISTINCT FROM su cardinalità e digest, prima della traversata degli alias e della composizione del descriptor.

Il SELECT in transazione READ ONLY, con search_path vuoto, acquisisce gli array ordinati completi e proietta soltanto i due hash del corpo e del DDL. Shared34, private66 e native3 sono invariati. Peer6 e relation2 cambiano solo E52. Il nuovo controllo di changed_headers2 verifica le due firme e i loro header completi. Il DDL delle due funzioni è identico a R1. Restano identici i gate, le protezioni, i pin già derivati, la lettura e il passaggio delle ammissioni di missione e la recovery conservativa.

Le ricevute build2 restano quelle effettive R1. I nuovi template richiedono review indipendente vincolata a B, Entry esatta con P ricalcolato in PostgreSQL e preflight vivo prima di ogni installazione.
