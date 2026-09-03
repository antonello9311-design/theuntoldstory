# Memoria compatta dell'architettura

- Frontend: HTML statico monolitico, stile e script inline, GitHub Pages; caricamento autonomo dei soli file verificati dopo riconciliazione remota, senza force-push.
- Backend: Supabase con RLS, RPC, Edge Function e cron; il database è la fonte di verità.
- Principio: l'IA produce narrazione, il server decide e valida ogni valore di gioco.
- Un owner alla volta per ciascun HTML; i contratti RPC appartengono a DB-CORE e sono congelati dal PM prima della UI.
- Avvio contesto: dossier `00 → 01 → 04`; indice e cronologia solo su domanda; file pesanti solo con necessità mirata.
- Verifica: query mirate per backend, sonde del codice reale e playtest per flussi visibili, manifest per il rilascio.
- Persistenza: decisioni in cronologia, stato in `01`, lavoro attivo in `04`, regole in coppia `REGOLE.md`/`regole.html`.
