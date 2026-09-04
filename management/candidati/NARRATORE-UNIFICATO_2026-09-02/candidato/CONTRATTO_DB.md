# Contratto DB candidato · ampiezza narrativa delle manovre

TASK-ID: `ESAME-GENIN-NARRATORE-FINALE-001`  
Baseline autoritativa dopo il recovery: head LIVE `20260903203601 esame_narratore_finale_ampiezza_006_recovery`; le quattro funzioni toccate dal forward 006 sono tornate alle impronte pre-006. Il forward candidato resta `20260903203600_esame_narratore_finale_ampiezza_006.sql` e va provato solo sul branch QA riallineato.

## Scopo chiuso

Il server aggiunge al payload v5 soltanto parole che descrivono l'ampiezza del movimento già consentito o già risolto. L'Edge e il modello non calcolano coordinate, non scelgono distanze e non cambiano la posizione.

- `intenzioni[*].ampiezza`: ampiezza prevista della manovra offerta, se ricavabile in modo univoco dall'intenzione autoritativa; altrimenti `null`.
- `esito_precedente.movimenti_autoritativi`: una lista con al massimo una voce per `actor.candidate` e una per `actor.opponent`; ogni voce porta `direzione` e `ampiezza` effettive, ricavate dalle posizioni prima/dopo e dal bordo applicato. La separazione per attore è necessaria perché nello stesso scambio possono muoversi entrambi.

La descrizione usa un vocabolario chiuso in parole:

- `nessuno`;
- `un passo`;
- `due passi`;
- `tre o più passi`;
- suffisso `fino al bordo del tatami` quando la posizione finale è sul bordo;
- suffisso `fermato dal bordo del tatami` quando il movimento richiesto è stato accorciato dal limite, ma soltanto se il corpo LIVE conserva quel fatto.

Il campo testuale `movimento` resta per compatibilità. La forma nuova è `{attore_ref, direzione, ampiezza}` e non introduce numeri JSON.

## Derivazione autoritativa

Per un referto risolto, il database confronta separatamente candidato e sfidante prima e dopo la risoluzione, dopo l'applicazione di `_esame_bordo`. Il valore assoluto della differenza seleziona il vocabolo; la posizione finale aggiunge l'eventuale bordo. Non si deriva mai l'ampiezza dalla prosa del giocatore o del Narratore.

Per un'intenzione ancora da risolvere, `ampiezza` è ammessa soltanto se il corpo LIVE dell'intenzione conserva già la posizione proiettata o il delta autorizzato. Se il LIVE espone solo `avanti`/`indietro`, il campo resta `null`: è vietato inventare un passo standard.

## Corpi già fotografati e guardati dal forward 006

Il forward 006 verifica firma e impronta prima di sostituire i quattro corpi che cambiano:

1. `_esame_ciclo_payload(p_prova uuid)`;
2. `_esame_replay_payload(p_prova uuid, p_ciclo uuid)`;
3. `_esame_risolvi(p_prova uuid, p_azione jsonb, p_chi text)`;
4. `_esame_png_gioca(...)`, che conserva l'intenzione scelta.

La revisione Edge 4.3 non cambia il payload v5 né richiede altro SQL: identificatori e provenienze dell'output vengono materializzati nella Edge.

## Forma della migrazione futura

- nome nuovo successivo alla head LIVE verificata al momento del gate;
- guardia su zero prove aperte e impronta di ogni corpo sostituito;
- sostituzioni esatte con conteggio unitario oppure corpi completi presi dalla fotografia LIVE;
- firme RPC, owner, `SECURITY DEFINER`, `search_path`, volatilità e ACL invariati;
- `GRANT EXECUTE` esplicito per ogni funzione nuova; nessun nuovo helper è previsto se il vocabolario può restare interno ai corpi esistenti;
- nessun `DELETE`, nessun dato storico riscritto, nessun cambio di vincolo o di meccanica;
- prova obbligatoria in `BEGIN/ROLLBACK`, poi review DB-CORE `P0/P1/P2 = 0` prima dell'apply.

## Verifiche di accettazione

- payload LIVE e replay hanno la stessa struttura `movimenti_autoritativi`, oltre all'eventuale `intenzioni[*].ampiezza`;
- zero numeri fuori da `scena.spazio` e zero cifre nei referti narrativi;
- `nessuno`, passo breve, movimento più ampio e arrivo al bordo risultano distinti;
- direzione e ampiezza corrispondono alle posizioni autoritative;
- payload senza ampiezza resta accettato dalla candidata Edge;
- bersaglio dichiarato della 461 continua a prevalere senza variazioni.

## Gate reale

Produzione resta fuori dal banco. Il gate richiesto è: branch Supabase QA healthy e allineato alla head di recovery → forward 006 → prove d'integrazione → rollback → nuovo forward → impronte/ACL/`search_path` verdi → unica review indipendente 0/0/0. Soltanto dopo si possono richiedere i gate nominativi di produzione già delegati.
