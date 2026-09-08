# MISSION-EXAM-ASSALTO-PROJECTION-001 — candidata non applicata

Mandato notturno Antonello: correggere le cause osservate che impediscono un esito completo e coerente. Questa candidata riguarda soltanto la proiezione narrativa del referto, non il combattimento.

Difetto riprodotto in sola lettura sulla prova f50acf03, scambio fe765ac1: Tamako usa Assalto, Kotoha para; server registra24danni sul difensore ed esito dell’inganno copia_colpita. Il referto usa indistintamente la stessa etichetta prevista per la difesa tramite copie e dichiara bersaglio_su «una copia di Kotoha». Le figure dell’Assalto appartengono invece a Tamako. Il modello riceve così bersaglio/identità incoerenti pur avendo la role completa.

Correzione minima nel solo helper `_esame_referto_modello(jsonb)`: per Assalto e i suoi due esiti, quando attaccante e difensore sono presenti, bersaglio_su indica il destinatario del colpo reale; copie_di identifica l’attaccante; difesa_diretta_a distingue copia e originale. Non modifica esito, colpito, danno, zona, gravità, movimenti, contatori, persistenza o RNG. La normale difesa tramite copie resta identica, così come i referti senza identità sufficienti. La rimozione ricorsiva di appendici/numeri preesistente resta invariata.

Nessun nuovo vincolo o funzione: firma, volatilitàIMMUTABLE, proprietà e ACL restano identiche; solo postgres/service_role possono eseguire. Nessuna riscrittura degli scambi o delle role storiche. Le letture future attraverso la proiezione mostreranno l’identità corretta; il record originale resta immutato.

Budget QA prima dell’esecuzione: quattro gruppi su PostgreSQL reale locale,0provider,20min. Assalto con copia e con originale; difesa normale tramite copie invariata; ricorsione e campi meccanici preservati; identità mancanti e ACL. Un solo passaggio indipendente e una sola controverifica finale. La prova live della proiezione è compresa nei venti campioni, senza chiamate aggiuntive. Applicazione dopo gate e prima del gruppo di conferma, non durante i cinque campioni baseline.

Limite separato: il parser della zona della role originale restituisce gamba anziché la zona associata al pugno dell’originale dichiarato. Questa candidata non pretende di risolverlo né modifica il bersaglio per adattarlo alla prosa. Il finding resta esplicito nella raccolta.
