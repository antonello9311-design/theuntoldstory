# Budget QA vincolante

La campagna parte soltanto su branch Supabase healthy e allineato.

- Revisione: 1 passaggio indipendente, 1 correzione aggregata, 1 controverifica finale.
- Casi: massimo 72 totali sulla stessa revisione — 24 resolver, 20 adapter, 16 receipt, 12 end-to-end.
- Race: 6 scenari multisessione inclusi nei 72.
- Fault injection locale: massimo 12 scenari, separati e non sostitutivi del branch.
- Chiamate modello: 0 fino al verde meccanico; massimo 8 nella sola prova narrativa conclusiva sul branch.
- Tempo: 90 minuti automatici + 30 minuti review per ciclo completo.
- Token modello: massimo 12.000 complessivi nella prova narrativa.

Stop: P0, rischio dati/sicurezza, mutazione inattesa, drift di head/sigilli, un caso rosso al termine della matrice, o superamento di un limite. Un caso rosso non interrompe la raccolta degli altri casi salvo gli stop precedenti.
