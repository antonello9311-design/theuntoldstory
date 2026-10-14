TASK-ID HUMAN-REGIA-READ-CLICK-HUMAN29-20261015

Scope: solo candidato LAND isolato da baseline pubblicata fc1fd74d, blob 5a811739. Root mantiene ownership LAND finale.
Contratto: click esplicito attende lettura già in corso; mutex locale, verifica identità/generazione/binding e scelte/testo identici prima UUID e journal. Nessun retry automatico. Stato mancante o cambiato genera avviso conservando testo.
Prove: tutti gli script inline parsati Node; inversa esatta sulle sole tre sostituzioni; metadata Human29 dedicato, H22 preservato. RPC, journal e recupero preesistenti invariati. Runtime/deploy NOT_RUN.
Rischi: collaudare race lettura, doppio click, cambio Auth/scena e WIP durante await nella Staff, dopo review indipendente.
Passaggio PM: review Human29 aggregata; integrazione Root sulla baseline corrente, nuova riconciliazione prima pubblicazione. Human1–28 preservati.
