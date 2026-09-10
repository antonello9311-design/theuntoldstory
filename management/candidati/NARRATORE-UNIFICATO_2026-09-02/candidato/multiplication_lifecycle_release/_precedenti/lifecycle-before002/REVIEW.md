# NARRATIVE-MULTIPLICATION-LIFECYCLE-REVIEW-001

**Review statica candidata001: PASS — P0/P1/P2 = 0/0/0.** Unico passaggio aggregato indipendente; nessuna patch, esecuzione SQL, nuovo caso o review ricorsiva. Il verde non certifica compilazione PostgreSQL, isolamento del banco, applicazione live o risultato del narratore.

Owner QA-PLAYTEST; mandato PM, budget12min. Candidata congelata manifest SHA256 `fb173196bec2a9cbfa090bc709987b356a160dbd10d13c7b3b5b92436101bc9e`. Una sola helper privata BEFORE MD5 `955228bdc23c89cdb287198db57231b8` → AFTER `6d7cbbfbd1ecbae7f8efad6e7eeaca36`. Tutti i pin dei sette artefatti del manifest e delle nove fonti elencate corrispondono.

## Ricevuta, round e fine certificata

Il blocco nuovo `BUILD.py:12–25` / `INSTALL.sql:259–272` parte dalla ricevuta multiplication_resolutions, unisce formazione/target/dichiarazione e filtra sessione del claim e round sia sul target sia sulla dichiarazione. La helper originaria già lega il round alla sessione del claim. Non cerca per nome, role, danno o fotografia di una formazione estranea al round.

`BUILD.py:27–47` richiede round con resolved_at, report_id uguale al claim e fase risolto/narrato; attacco e target risolti. Verifica schema dei facts, ID formazione e target, modo, tipo di scelta, esito nativo, hash `public.combat_v2_sha256(facts)` e inclusione dei medesimi facts nell'outcome del target. Soltanto la proprietà aggiuntiva role viene ignorata nel confronto; l'array è reso shape-safe prima di jsonb_array_elements. Nessuna costruzione o sostituzione della ricevuta.

`BUILD.py:49–63` / `INSTALL.sql:296–310` richiede consumed, ended_at non nullo, successivo o uguale alla creazione della ricevuta e precedente o uguale a resolved_at. Il creatore deve essere il bersaglio oppure l'attaccante dell'Assalto corrente; membro della sessione obbligatorio. Causa first_attack/assault_resolved coerente con lo stesso criterio del writer. Le colonne receipt.created_at/state/phase sono NOT NULL nella metadata raccolta; resolved_at/ended_at, nullable, hanno guardia esplicita. Incoerenza produce errore22023, senza un evento ipotizzato.

La provenienza nativa è documentata in BASELINE.functions mediante pin ed estratti numerati: multiplication_resolve_choice righe49–55 crea facts e hash; multiplication_attack_finish14–16 sceglie la causa; multiplication_finish11–17 termina solo da active e scrive clock_timestamp; multiplication_state_guard11–15 impedisce un'altra modifica del terminale; resolve_parent73–79 termina la formazione dopo l'outcome target; combat_v2_round_resolve218–220 registra report e resolved_at successivi. Gli estratti sono prove statiche di provenienza, non un'esecuzione del writer in questa review. I relativi pin sono verificati dagli script prima/dopo, ma i writer non sono chiamati dalla helper.

La deduplicazione avviene soltanto dopo avere validato ogni ricevuta (`BUILD.py:65–72`), mediante l'ID della formazione interno: una conclusione per formazione, senza saltare i controlli delle altre ricevute. Le fini senza una ricevuta d'attacco pertinente rimangono esplicitamente escluse, comprese scadenze e combat_end. Nessuna pretesa di coprire tutto il lifecycle.

## Proiezione, privacy e conservazione

L'oggetto nuovo contiene soltanto tecnica, actor_id della scena, stato e causa pubblicabile (`BUILD.py:66–70`). Nessun ID formazione/target/ricevuta, selected_index, original_index, RNG, coordinate, statistiche o danno viene passato al modello. Leggere facts completi per verificare il loro hash non significa esporli: l'output viene costruito con i quattro campi espliciti.

Verificata mediante confronto delle stringhe la reversibilità delle due sole inserzioni (dichiarazione dell'array e blocco prima del RETURN): rimuovendole, l'intero AFTER coincide col BEFORE. Fonti catalogo, controlli Staff, conclusioni Clone, firma, volatilità e search_path della helper sono preservati. L'AFTER congelato compare esatto in INSTALL e il BEFORE esatto in RECOVERY, una sola definizione in ciascuno script.

Hook scene_snapshot_v2 MD5 `a417e6a98201a2177cb8c244a736bb3c` invariato. Il genere dello smoke006 è azione_risolta: non è necessario ampliare l'ingresso a confronto. Le due chiavi fonti_tecniche/conclusioni_effetti_server e resolved_facts come stringa JSON restano invariate. Edge25 separa il catalogo e conserva gli altri fatti (`editorial_scene_release/editorial.mjs:10–26`), con istruzione già presente sulla cessazione visibile quando certificata: nessun cambio prompt o frase obbligatoria. La presenza del catalogo da sola non è usata come prova di fine.

## INSTALL, RECOVERY e limiti di rilascio

Entrambi gli script sono una transazione, con timeout di lock3s e statement30s, contesto locale public/extensions, ownerpostgres richiesto e lock SHARE ROW EXCLUSIVE su narrative_claims/scene_attempts_v2. Il preflight ferma claim ordinary ancora in corso. Non modifica flag, cron, righe di gioco o history.

`BUILD.py:85–120,158–173` genera pin delle funzioni (definizione, owner, ACL), metadati delle cinque relazioni del raccordo e delle due relazioni claim/snapshot. Le relazioni del raccordo comprendono vincoli/trigger raccolti; i metadati dei registri lifecycle mantengono il loro perimetro dichiarato. Deparser eseguiti nello stesso search_path previsto; nessun OID letterale nelle impronte attese. I corpi delle guardie e le due definizioni SQL sono stati letti: **non eseguiti né compilati in PostgreSQL**.

Dopo la sostituzione vengono ribaditi ownerpostgres, REVOKE dai ruoli client/service_role e GRANT soltanto postgres (INSTALL323–325; RECOVERY275–277), con pin postflight. Nessuna nuova funzione o grant client.

RECOVERY richiede AFTER esatto e impostazione nominativa primauso. `BUILD.py:128–144` / `RECOVERY.sql:155–170` decodifica resolved_facts sia object sia stringa JSON valida, esamina soltanto un array valido e rifiuta una conclusione Moltiplicazione nuova già persistita, anche non pubblicata. Lock sui registri e diniego claim in corso impediscono una normale acquisizione/persistenza concorrente durante questo passaggio. Si ripristina solo il BEFORE, senza cancellare né riscrivere i documenti già congelati. Dopo uso la recovery è vietata: correzione in avanti e lettori conservati, con mandato PM distinto.

Flow006 modifica la stessa helper: i pin diversi impediscono concatenazione cieca. La successiva composizione deve preservare i due contributi e aggiornare le impronte; questa review non approva già tale composizione. Master/utenti/PNG non vengono abilitati o certificati.

## QA e consegna

Letti PLAN/CONTRACT/BASELINE/BUILD/INSTALL/RECOVERY/QA_PLAN/MANIFEST e sole fonti pertinenti. Il piano propone una futura qualifica di proiezione in PostgreSQL: quattro gruppi, massimo8submission/10min/0provider. Il runner/fixture di questa estensione non esiste ancora; il banco NARRATIVE_TECH precedente è minimo e non rappresenta tutti i vincoli/trigger/ACL del wrapper. La verifica del corpo e quella degli script completi devono mantenere esiti distinti; nessun mock equiparato al motore nativo. Tale limite è già dichiarato nella candidata e resta un gate concreto prima del rilascio.

**Attività reviewer: 0 query, SQL, Docker, provider, browser, esecuzioni del prodotto, nuovi casi.** Nessun testo completo delle role, dato PG o segreto letto; nessuna nuova copia del corpus nativo. Nessuna modifica della candidata, dei precedenti o di altri prodotti.

Consegna unica0/0/0 al PM per qualifica PostgreSQL separata e successivi gate nominativi. Non sono autorizzati da questo referto apply, deploy, rigenerazione dello smoke006 o apertura agli utenti. Nessun nuovo esempio o finding da aggiungere dopo la consegna.
