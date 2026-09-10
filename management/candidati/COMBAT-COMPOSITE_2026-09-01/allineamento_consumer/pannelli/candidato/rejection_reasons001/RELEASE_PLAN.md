# Rilascio nominativo proposto · messaggi Common aggregata002

COMBAT-PANEL-REJECTION-REASONS-RELEASE-PREFLIGHT-001 · DB-CORE. **Preflight BEFORE esatto; nessuna applicazione eseguita.** Modulo rejection_reasons001, aggregata002 della stessa candidata, prima correzione RR-01 conclusa. Questo piano non apre una nuova review o campagna.

## Evidenze pronte

Lettura unica metadata del 2026-09-10T05:06:54.324367+00:00: public.combat_panel_commit_v1(jsonb) BEFORE MD584860632d828931cea773b83c583548e, ownerpostgres, ACLpostgres+authenticated; public.combat_v2_fail(text,text,integer,uuid,jsonb) MD5607dec1f81b9b0c310c91585315803f6, ownerpostgres, ACLpostgres+service_role. Firma,security_definer,volatilità e search_path coincidono con BASELINE. Nessuna receipt trovata fra i nomi migrazione pertinenti; la ricerca nominativa non attesta assenza globale sotto nomi diversi. Nessun dato PG, offerta, role, sessione o payload acquisito.

Controverifica aggregata0020/0/0, QA_COMPONENT_PASS4gruppi9sottocasi,9submission in1.649s,0provider. Sono stati eseguiti gateway/handler reali PostgreSQL e INSTALL/RECOVERY integrali COMMIT; corpi/ACL originali ripristinati e sentinella/receipt conservate. Solo dispatcher di frontiera sintetico: niente certificazione gameplay/Auth/RLS. PLAN e QA_EXECUTION_PLAN restano congelati al loro momento; lo stato effettivo è in QA_RESULT/QA_MANIFEST e qui.

## Singolo cambiamento da nominare

Proposta al PM: autorizzare nominativamente **un solo apply della INSTALL.sql aggregata002**, SHA256 30ec1184eeadb0c708de330357c606f234108d6ca45ba9d284367b8b0f81963d,13710byte, sul progetto tyhyxkslteigibktluml; nome migrazione proposto combat_panel_rejection_reasons002, versione assegnata dal canale effettivo. L’owner di rilascio acquisisce la risorsa produzione e mantiene l’esclusiva. Il presente incarico termina prima dell’apply.

La funzione esistente è sostituita da una sola transazione con guardie BEFORE/AFTER, lock e timeout già collaudati. AFTER atteso0ec7f7f1228b3f1afef03ad6323bf960. L’analisi inversa conferma che cambiano soltanto i messaggi di cause riconosciute in selection_rejected: autorità, codice, autenticazione, request_key, recovery, dispatch e confini del rollback sono byteidentici. Nessun nuovo campo API, privilegio, policy RLS, tabella, consumer, Edge, flag o enable; combat_v2_fail è solo dipendenza pinzata e resta immutata. L’effetto sulle spiegazioni è immediato per le chiamate successive alla funzione condivisa; non è un apply inerte.

L’INSTALL ricontrolla i due pin e proprietà anche se il preflight invecchia. Il lock advisory coordina i rilasci cooperanti ma non ferma editor esterni: owner esclusivo e assenza di interventi concorrenti restano necessari. In caso di drift/timeout fermare l’apply, senza adattare pin o riprovare automaticamente. Dopo apply il PM registra receipt effettiva e una lettura metadata AFTER/ACL; non si riusano risultati precedenti come postflight.

## Recovery nominativa pronta

RECOVERY.sql SHA256 3f025c45c511c5af2725d8de139beecd63c116dc05d60efcb2bbd4c27cf218b2,7943byte: singola transazione, accetta soltanto AFTER esatto e combat_v2_fail invariata, ripristina BEFORE84860632d828931cea773b83c583548e e controlla proprietà/ACL. È stata collaudata COMMIT su connessione separata. Non modifica dati, receipt, storico o azioni; non richiede cancellazioni, quiete fabbricata o riscritture della history. Va invocata solo su mandato nominativo PM per una regressione osservata; nessuna recovery automatica o retry incluso nel presente gate.

## Rischio residuo e smoke pertinente

La qualifica locale copre compilazione, classificazione, fallback senza divulgazione, precedenza conflitto, rollback e replay del gateway; il codice Auth/autorità non cambia e i relativi pin/ACL sono conservati. Rimane da verificare l’integrazione reale con accesso Supabase e renderer, non ricostruita dal solo utente nominale locale. Per questo delta limitato il rischio è copribile con un singolo smoke sul percorso normale della Staff Test Room protetta già autorizzata: lettura delle offerte e un invio pertinente nativo soltanto se previsto dal successivo scope PM, mantenendo eventuale rifiuto genuino e relativo messaggio; nessuna scelta contraffatta, SQL di gioco, fault injection o replay011. Un esito accettato è valido per il percorso normale ma non dimostra il testo di una causa non incontrata: il limite va dichiarato, non forzato con nuovi tentativi.

Lo smoke dovrà verificare stato/messaggio/lettura successiva e isolamento delle superfici protette, conservando la scena esistente se così assegnato; budget gioco/provider definito dal PM prima del caso. Nessun privilegio Staff passa agli utenti. La Test Room utenti ancora sul raccordo legacy non è qualificata da questa modifica né resa Common dalla sola sostituzione della RPC: parità resta prerequisito del suo ramo dedicato. Auth/RLS/API o disponibilità utenti non si dichiarano verdi dal banco componente.

## Consegna e confini

Due output: RELEASE_PLAN.md e RELEASE_PREFLIGHT.json. Budget effettivo1query readonly,0mutazioni/casi/provider/browser. PM valida questa fotografia, nomina il singolo apply e assegna separatamente postflight/smoke. Nessuna applicazione, apertura generale, deploy o nuova campagna è stata eseguita da questo incarico.
