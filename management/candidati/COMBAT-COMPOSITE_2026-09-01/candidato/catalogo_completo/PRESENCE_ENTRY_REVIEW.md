# Presence Entry — controverifica indipendente R2

Esito pertinente **0/0/0** (P0/P1/P2) sull’aggregata AGG1, build `presence-entry-staff-20261119-2`. Chiuso il singolo finding iniziale `PRESENCE-ENTRY-P2-001`; conteggio storico conservato: review iniziale 0/0/1, una correzione aggregata, una controverifica.

Il router cattura il binding Staff prima delle attese, lo ricontrolla dopo refresh e child.open, e trasmette al child il binding originario con `explicit:false`. La perdita del binding non ricade nel percorso Ordinary.beforeOpen. Common e Ordinary applicano i controlli pertinenti prima e dopo le attese. I percorsi espliciti riusano la presenza nativa; i gate pubblici/server restano distinti.

Tre casi statici completati:

1. Pin dei cinque componenti e blob Git calcolato localmente; replay in memoria degli 11 hunk e replay inverso esatti. Nessun comando Git.
2. Compilazione sintattica dei sei script non vuoti con `node:vm.Script`, senza eseguirli; cinque blocchi CSS byte identici; timer e 264 pulsanti invariati.
3. Tracciamento del binding asincrono e dei percorsi espliciti/passivi Staff, listener pubblici e guard dei consumer. Nessuna nuova infrastruttura o caso giocato.

Nota documentale non bloccante: il manifest conserva le vecchie misure di due script (block4 239321 anziché 240086 B; block5 47444 anziché 47698 B). I pin esterni sono corretti e la sintassi è stata verificata sulla candidata attuale. Il referto JSON custodisce le misure effettive; non richiede di riaprire il freeze.

Candidata: `38f37e85d07bd0b12c10b0c2819dcfbd202c08b0097a0a61897be9ee1b82c570`, 2466041 B. Manifest: `6c449f425c57c1a8b2765bd7689948685f183f32da80582836f3af9d709e3a9a`, 4229 B. Tutti e cinque i canonici ricontrollati invariati a consegna.

Limiti: sola review UI/source pertinente. Root integrata/installabilità globale, preflight vivo e collaudo Staff restano aperti. Nessun PASS gameplay. Operazioni DB/browser/Git/provider/gameplay e scritture canoniche: tutte zero.
