# Apri scontro · recupero presenza Staff · candidata sorgente

TASK `COMBAT-ENTRY-PRESENCE-SOURCE-20261119` · owner `LAND-UI-PRESENCE` · SOURCE ONLY, review indipendente e integrazione Root ancora richieste. Nessuna pubblicazione, DB/Edge/flag, browser, provider o gameplay in questa preparazione. Le scene del PM non sono state toccate.

## Baseline e difetto

Baseline esatta GitHub main `609c2777ba5953e3fc2310ae91104d05d037dffa`, Land blob `4525dd02527cc01e8708dc01670259a006311ff8`, SHA256 `47ecad08c9a2912d0e223792c171b7df897d3875635647e82497e7cf8e9ffe47`, 2463061 byte. Copia pubblicata ottenuta tramite GET GitHub del blob e ricontrollata con l'identita Git blob locale. Il WIP `sito_live/land.html` blob `e68165dc…` e differente e non e stato usato o modificato.

L'audit sorgenti preliminare c8db95a3 distingue TTL Combat2min da roster sociale8min e timerlegacy disabilitato intenzionalmente in modalita eventi. Nessuna soglia cambia. Il problema UI e duplice: il listener Apri scontro del child Common chiama open senza il beforeOpen del router; Ordinary richiede eligible prima del callback e nasconde l'ingresso quando il grant e falso. Un PG2 passivo non viene rinnovato dal gesto PG1.

## Stessa azione, autorita invariata

La candidata usa esclusivamente il pulsante esistente «Apri scontro». Nei soli accessi Staff gia confermati, il click attraversa il router: beforeOpen→landUserPresence→verifica binding→STATE server→apertura del consumer autorizzato. Il click nella route unknown resta raggiungibile senza fingere che lo scontro sia gia disponibile. Il click Ordinary a entryAllowed=false raggiunge il router prima dell'early return del child; il router aggiorna la proiezione prima di invocare il child. Il child conserva integralmente eligible per apertura effettiva, invio, preparazione e ricevute.

Non viene creato un pulsante di conferma, una richiesta di rinnovo manuale, un'offerta o un grant locale. Le scelte restano quelle restituite da STATE/options e i comandi sono validati dal server. Nessuna nuova RPC, campo command, request_key, permesso, costo, regola o chiamata provider.

## Riserva e binding esistenti

Il solo callback interno `entryPresenceScope` restituisce un binding se tutti gli accessi gia presenti sono validi: iAmStaff e LAND_PROFILE_KNOWN; landEventReadMode; roomEntryStaffScope (UUID Staff esatto e is_test); roomEntryConfirmed con ACK della stessa identita/stanza/UI epoch; principal autenticato coerente e personaggio corrente. Il binding contiene landReadKey (principal/auth epoch), personaggio, stanza e UI_POSTREVIEW_STAFF_EPOCH. Fuori da questi accessi il callback restituisce null e i percorsi pubblici restano quelli della baseline.

Si riusano conferma server di ingresso nella stanza Staff, autorizzazioni gia esistenti di touch_presence e porte Combat. Non e una nuova policy o un sistema protettivo parallelo. touch_presence puo aggiornare solo auth.uid e non cambia location; la candidata non puo rinnovare un altro PG. Anche una revoca server non ancora proiettata dal client resta verificata nelle RPC esistenti e non produce offerte autorizzate localmente.

Aggregata1 dell unico P2 della review indipendente47636dc4: refresh congela il binding Staff prima di ogni attesa; newChild/current refresh lo rivalidano prima della riapertura e dopo il ritorno. Il binding originale viene passato ai child con explicit:false, senza ricalcolarlo per scegliere un ramo pubblico. Common/Ordinary verificano quel binding prima e dopo le proprie attese. Nessun fallback pubblico per un ingresso iniziato Staff. La review precedente e conservata, non azzerata.

Dopo ogni attesa il router rivalida routing/revocation e lo stesso binding Staff; un cambio Auth, personaggio, stanza, ACK/epoch o ruolo osservato ferma il percorso. Gli errori restano nel feedback di apertura esistente, senza invio o retry automatico. Draft, role, pending request e journal non sono modificati.

## Aperture passive

Listener del child Common/Ordinary delegano al router solo nella riserva Staff; il router gestisce anche lo stesso ingresso quando non esiste ancora un child. Dopo l'unico rinnovo esplicito passa explicit:false al child Staff. Le aperture passive da install/refresh passano explicit:false nella stessa riserva, cosi il child Ordinary non esegue touch_presence. Eventi, semplice refresh, rendering, errori di rete e ricomparsa del pannello non diventano heartbeat. Nessun setInterval/setTimeout aggiunto.

I listener aggiunti vengono rimossi al dispose. Il pulsante temporaneamente esposto in route unknown viene nuovamente nascosto quando il binding Staff cessa; le viste dei child restano responsabili dei loro ingressi normali. Il testo aggiunto alla card bloccata descrive soltanto l'apertura per verificare le scelte, senza una checklist utente.

## Producer e consumer

- Producer di binding: host Land ordinaryRefresh, accessi Staff e room ACK gia presenti.
- Producer di presenza: callback esistente landUserPresence e RPC public.touch_presence(), invariata.
- Router/consumer: attachPanelLand, listener attachCombatPanel e attachOrdinaryLand, STATE/options e grant/eligible esistenti.
- Consumer meccanici: prepare/commit/submit, server guards di presenza e controllo, DTO e validator byte-identici.
- Riserva pubblica: nuovo recupero disponibile solo con binding Staff; nessun enable pubblico e nessun dato di catalogo modificato.

## Controlli statici, tre casi

1. Custodia main/blob, unicita delle29sostituzioni, replay della patch HTML forward e inverse: immagini byte-esatte. La sola meta build nuova e `presence-entry-staff-20261119-2`.
2. Sintassi di tutti6script inline non vuoti tramite node --check: PASS. CSS identico, numero pulsanti identico, nessuna rinomina delle classi o modifica alle costanti di configurazione.
3. Tracciamento sorgente dei percorsi Staff unknown/Ordinary/Common, revoche/binding dopo await e separazione passivo/esplicito. Pubblico e porte/eligible/comandi preservati. Questa e verifica statica, senza fixture o esecuzione di gameplay/UI/DB.

Nessun PASS funzionale o review indipendente0/0/0 dichiarati dall'autore. Restano necessari il collaudo Staff pertinente della candidata integrata e le sole regressioni di apertura/passivo/cambio contesto richieste dal reviewer/PM. Il browser e le scene rimangono del PM.

## Integrazione e recovery HTML

I cinque artefatti sono baseline HTML, candidata HTML, patch, contratto e manifest. Il manifest pinza i quattro artefatti esterni; la SHA del manifest stesso e consegnata esternamente, evitando un ciclo di auto-hash. La baseline HTML e anche l'immagine di recovery conservativa; patch inverse provata staticamente.

Prima di qualsiasi rilascio, il PM deve ricomporre la UI binding nella Root corrente (checkpoint readonly precedente79f17709/Edge45; nessuna nuova verifica DB di questo task). La nuova SHA/build client non e gia ammessa. Conservare gli altri asset/UI, DB/RPC/ACL, Edge45, gate, qualifiche missioni/due admission e party flags: non aggiornare semplicemente un pin e non reinstallare vecchi corpi. L'eventuale Root forward/guard/custodia/cap e fuori dai cinque file di questo owner; installabilita globale OPEN fino alla composizione e review indipendente.

Recovery: soltanto se la Land effettivamente pubblicata coincide con la SHA candidata recensita, usare l'immagine baseline esatta o l'inversa della patch, preservando tutti gli altri file. In caso di drift STOP del solo ripristino. Il PM deve ricomporre una Root forward coerente con il client ripristinato, mantenendo server e storico correnti; mai sostituire la vecchia riga Root o cancellare audit/sessioni. Non chiudere scene altrui per applicare la recovery. Nessun eseguibile DB o operazione Git e autorizzato da questa consegna.
