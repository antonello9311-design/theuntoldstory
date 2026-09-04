# Piano di implementazione · EXAM-REC-OPEN-001

## Obiettivo verificabile
Quando una prova Genin viene aperta in un'aula reale, `role_open_here(location)` deve vedere immediatamente una sola REC aperta e la sua finestra deve includere il messaggio di Sistema e l'incipit del Fato.

## File previsti
- `[NEW] candidato/<timestamp>_exam_rec_open_001.sql` — guardie sulla head, adattamento puntuale di `esame_prova_apri(uuid)`, verifiche finali.
- `[NEW] candidato/<timestamp>_exam_rec_open_001_ROLLBACK.sql` — ripristino del corpo precedente solo se l'impronta applicata coincide.
- `[NEW] candidato/BANCO.sql` — prove locali e integrate.
- `[NEW] referti/REFERTO.md` — review indipendente e verdetto P0/P1/P2.
- `[MODIFY] SCHEDA.md`, `HANDOFF.md`, `STORICO.md` — stato e prove.
- `[MODIFY] dossier/aree/ESAME.md` e `dossier/aree/PIATTAFORMA.md` soltanto quando cambia lo stato operativo o la migrazione entra a registro.

## Sequenza tecnica
1. Fotografare dal database vivo `esame_prova_apri(uuid)` e `role_start(uuid,uuid)`, senza fidarsi delle sole copie locali.
2. Inserire nel corpo di `esame_prova_apri` un controllo del luogo di prova e, per le sole aule reali, la chiamata a `role_start(v_loc,v_uid)` subito prima dei messaggi d'apertura.
3. Conservare firma, `SECURITY DEFINER`, `search_path`, proprietario, volatilità e ACL. Nessun nuovo endpoint client.
4. Dimostrare ordine, idempotenza, concorrenza e isolamento Test Room.
5. Fermarsi al gate: review e branch verdi precedono qualunque autorizzazione di produzione.

## Fuori scope
Chiusura automatica della REC a fine Esame; recupero delle REC storiche mancanti; modifica dei testi del Fato; modifica della UI; correzioni al monitor o all'interruzione dell'Esame.
