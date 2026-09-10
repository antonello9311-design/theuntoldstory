# Cause di rifiuto Common · candidata001, non applicata

COMBAT-PANEL-REJECTION-REASONS-CANDIDATE-001 · DB-CORE. Il piano autorizzato modifica soltanto la spiegazione pubblica di cause native note del gateway. Non risolve né attribuisce una causa al rifiuto Assalto011. Nessun invio011 viene ripetuto; PNG e UI non sono modificati.

## Fonte e scelta tecnica

Unica query metadata autorizzata: public.combat_panel_commit_v1(jsonb), MD584860632d828931cea773b83c583548e, ownerpostgres/ACLpostgres+authenticated; public.combat_v2_fail(text,text,integer,uuid,jsonb), MD5607dec1f81b9b0c310c91585315803f6, ownerpostgres/ACLpostgres+service_role. Definizioni, firma, configurazione, proprietà e pin sono in BASELINE.json. Nessuna lettura di PG, offerte, role, credenziali o payload privati.

Il gateway associa SQLSTATE22* a selection_rejected. combat_v2_fail usa invece PGRST con un JSON come messaggio: il suo contenuto non viene analizzato o pubblicato dalla candidata e resta nel fallback operation_rejected. Non si confondono codici HTTP con SQLSTATE. Le altre classificazioni authentication_required/request_key_conflict/not_authorized/context_changed/operation_rejected e la loro precedenza restano byteidentiche.

La sola sostituzione è il valore di message nel ramo selection_rejected: CASE SQLERRM con quaranta cause letterali autentiche, raggruppate in ventisette spiegazioni semantiche. Il builder verifica che ogni causa compaia come eccezione nelle fonti congelate010/011; la tabella completa è BASELINE.mapping. Sono distinti formato della richiesta, ID/selezioni, cardinalità/dipendenze/input, testo richiesto, completezza/conflitti della Moltiplicazione, disposizione/capienza, margini arena, movimento, bersaglio/figura, contatto/percorso, disponibilità di catalogo/profilo e azioni incompatibili. Dove la stessa eccezione copre più condizioni, il messaggio conserva l'alternativa: non inventa quale controllo interno sia fallito.

Un nome conosciuto con suffisso, testo arbitrario, UUID, JSON o altro contenuto non coincide con le stringhe esatte e riceve il fallback precedente. Nessuna concatenazione di SQLERRM, SQLSTATE, diagnostiche o identificatori nel testo pubblico. Nessun nuovo campo API, codice d'errore, sinonimo narrativo, messaggio dipendente dal testo della fixture o dal nome del personaggio. La UI già pubblicata mostra il message pubblico con textContent e mantiene la request_key soltanto internamente.

## Invarianti e recovery

INSTALL/RECOVERY sono singole transazioni. Prima e dopo verificano il corpo completo del gateway e combat_v2_fail, owner/ACL/configurazione/volatilità/security_definer; la recovery richiede l'AFTER esatto e ripristina il BEFORE autentico. Una modifica concorrente dei pin blocca la procedura. Il lock advisory del rilascio è cooperativo, non impedisce DDL di editor esterni: il PM deve mantenere l'esclusiva e il preflight fresco nel gate reale.

Si usa CREATE OR REPLACE sulla firma esistente: owner e ACL sono mantenuti e ricontrollati, senza GRANT/REVOKE/ALTER. Il corpo del gateway, incluse letture, lock, dispatch, handler e rollback, è byteidentico al di fuori dell'assegnazione message. Nessuna tabella, funzione aggiuntiva, privilegio, flag, cron o dato di gioco è creato o cambiato. La recovery non invoca alcuna azione/cleanup né modifica receipt, quote, storico o tentativi già conclusi.

Il rischio applicativo residuo è la compilazione del nuovo CASE e la resa dell'handler reale; il QA proposto distingue quella componente dalla simulazione dei rami di gioco. Review indipendente e qualifica PostgreSQL precedono qualsiasi gate nominativo di applicazione; pubblicazione e smoke sono incarichi successivi. Le fonti SQL su GitHub non autorizzano apply.

## Costruzione e consegna

Sette file: PLAN, BASELINE, BUILD, INSTALL, RECOVERY, QA_PLAN, MANIFEST. Il generatore valida impronte e provenienza, produce una sola funzione per transazione, controlla il delta inverso e rifiuta cause non documentate. Due generazioni byteidentiche e AST del builder sono controlli di costruzione, senza eseguire SQL né casi. Il piano QA fissa4gruppi/9sottocasi massimi/9submission SQL/10min/1run/0provider, ancora non avviato. Il manifest conserva stato NOT_RUN e gate mancanti; non presenta la candidata come disponibile live.

Budget costruzione20min,1metadata già consumata,0casi/provider/browser/Docker/apply. Il PM riceve candidata congelata per review indipendente; nessuna modifica a dossier o altri moduli.
