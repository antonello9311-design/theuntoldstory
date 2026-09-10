# LAND-COMMAND-FEEDBACK-REVIEW-001

**Review indipendente singola: PASS · P0/P1/P2 = 0/0/0.** Candidata001 del difetto empirico010; nessuna riapertura di PNG5/5 o della UI privata003. Owner QA-INDEPENDENT. Nessun finding da correggere in questa consegna; nessuna patch o esecuzione aggiuntiva.

## Oggetto e integrità

Spec `/private/tmp/command-feedback-review001/spec.json`, budget12min, zero SQL/query/Docker/provider/browser/campagne. Letti14 artefatti candidati inclusi MANIFEST, sorgenti originali e riferimenti privati nominati. MANIFEST SHA256 `c42643594bfca1dcbba7024205734e2e5566a59b3503d1cb9d2578a3d63eee26`, LAND SHA256 `8b55c64134948ea4668433abeb4226894b7283704570ffa1d7c6dfa85f7d2c7e`: corrispondono al mandato. Tutti13 artefatti nel manifest,15 source_inputs e12 pin prima del run corrispondono; QA_RESULT riferisce esattamente quei12 input.

La review riguarda il feedback UI. L’assenza della risposta RPC del tentativo Assalto010 resta tale: non si attribuisce al server, alla tecnica, alla rete o al giocatore una causa non acquisita.

## Rifiuto e aggiornamento dello stato

`ui/controller.mjs:23–29,63–75,97–105` separa lastCommand/error/rejection. Un combat-panel-error/1 riconosciuto e nuovamente validato produce lastCommand rejected con la request_key del comando, azzera pending e le scelte e impone refreshRequired. Le letture non cancellano lastCommand né rejection; il successo di readState rimuove soltanto la necessità di aggiornamento. Il messaggio quindi sopravvive a readState, readOptions e nuova versione, mentre selectedOfferId/opzioni/input vengono invalidati dal normale confronto di contesto. canPrepare resta subordinato a permessi, readiness, nuova selezione e assenza di pending: nessuna riabilitazione di un comando stale.

`invalidate` distingue invalidazione nello stesso contesto da clear per principal/PG/luogo cambiati. Conserva esito e pending nel primo caso, invalida envelope e scelte; nel secondo conserva il confine preesistente di identità e cancella la presentazione. Non introduce persistenza interutente o recupero dopo reload dell’ordinary.

`ui/view.mjs:32–53` mostra il feedback prima delle uscite blocked/non disponibile. Le letture fallite hanno messaggio distinto e non cancellano l’esito dell’invio. Nessuna offerta sintetica viene aggiunta quando il contesto non è disponibile.

## Incertezza, ricevuta e preinvio

`controller:92–110` conserva il payload preparato in pending quando trasporto, proiezione o receipt non sono confermati. `retry` passa allo stesso send e invia una copia dello stesso comando; non chiama prepare, non genera una nuova key, non cambia opzioni/versione per adattarle allo stato successivo. Blocked non cancella più pending. Il controllo di identità resta prima dell’invio e gli esiti di risposte appartenenti a epoch/context superati vengono ignorati.

La presenza di un pulsante di verifica in blocked/non disponibile non autorizza una nuova azione: ripropone manualmente soltanto la richiesta pendente. Non ci sono timer, retry automatici o fallback legacy aggiunti. Resta al server verificare replay, contesto e autorizzazione; la fixture che restituisce success a un retry non attesta il comportamento dell’API reale.

Una ricevuta è accettata soltanto dopo validatePanelEnvelope e request_key corrispondente. Conferma sostituisce il precedente rejected/uncertain, cancella rejection e conserva la ricevuta nel lastCommand anche dopo le letture. Il renderer legge solo campi di presentazione e display_events validati; non stampa la request_key o gli identificatori della ricevuta.

`controller:37–47,109` e `ui/mount.mjs:15` rendono visibili le eccezioni anteriori all’invio tramite messaggi italiani finiti e fallback generico. Dettagli raw delle eccezioni non vengono esposti. I messaggi del rifiuto pubblico sono quelli della shape server già validata, resi con textContent senza interpretazione HTML. Nessuna classificazione nuova per Assalto o elenco di errori backend inventato. La conversione preesistente response.error→transport_unconfirmed resta conservativa: non viene impropriamente trasformata in rifiuto definitivo.

## Confronto pagina e recupero

Controllata staticamente la trasformazione import/export usata da BUILD.py senza eseguirlo. Ognuno dei tre blocchi originali controller/mount/view compare una sola volta nella LAND99; ognuno dei tre AFTER compare una sola volta nella candidata. Invertendo soltanto queste sostituzioni e il marcatore si ottiene l’intera LAND99 byteidentica, SHA256 `01daea519b8b4adb9fe8411799a46432c009c02f6a6d68b8dbfe772f248a648d`. Nessun lost update o modifica fuori dai tre blocchi e dal marcatore. Validatore, mappa, Moltiplicazione e domain-views restano byteidentici.

BUILD richiede tutte le impronte d’ingresso e rifiuta blocchi mancanti/duplicati; non usa il vecchio assembler pinzato097 per rigenerare99. Il delta inverso è dimostrato sul contenuto, non su una produzione modificata. Un eventuale ripristino dopo rilascio richiede prima il confronto della testa corrente per non sovrascrivere interventi successivi.

## UI privata003 e bozza

I cinque input privati nominati nel manifest sono immutati. Questa pagina parte dalla LAND99 e **non incorpora** la UI privata003: il pacchetto non deve essere usato per sostituirla. Il nuovo renderer accetta l’assenza di lastCommand/interactionError e mantiene il fallback rejection/error e renderers. Non modifica i predicati privati di chiusura, import/export, validazione actor/policy/versione o lo storage della bozza privata.

La futura composizione deve innestare il delta renderer sulla base privata effettiva preservando isPrivateUserClose e il suo collegamento module3→module5, recupero del pending e draft legato a principal/PG/test/actor. Non è attestata compatibilità dinamica integrata. Il controller ordinary resta in memoria; mantiene narrativeText durante rifiuto e cambio versione, lo mantiene in blocked se pending, conserva gli altri confini di cancellazione dichiarati. Nessuna promessa di recupero della bozza ordinary dopo reload viene introdotta da questa review.

## Copertura dei sei gruppi già eseguiti

Letto VERIFY.mjs integralmente senza eseguirlo. Il banco estrae il bundle Common dalla LAND candidata, espone nel solo contesto VM controller/mount/view e compila i quattro script inline. Le fixture usano RPC in memoria e DOM minimo, non client/server reali.

- G1 verifica rifiuto dopo letture, messaggio renderizzato, key non renderizzata e un solo commit.
- G2 verifica nuova versione, invalidazione delle scelte senza perdita dell’esito, invalidazione nello stesso contesto e successivo cambio principal.
- G3 verifica conferma successiva, sostituzione del rifiuto e persistenza dopo readState.
- G4 verifica pending dopo blocked/invalidazione/nuova versione e confronto esatto dei due payload, con un solo retry manuale.
- G5 attraversa mount per preinvio incompleto ed errore locale e verifica che il dettaglio raw non diventi testo.
- G6 verifica feedback in blocked e assenza di select/input/textarea o nuovi comandi di gioco.

QA_RESULT dichiara6/6 PASS, unico run03:41:44.722UTC, quattro script,0retry della campagna. Impronte postrun invariate. Questa review conferma corrispondenza dei casi al contratto e integrità del referto, non riesegue né estende la matrice. Non copre browser/layout/accessibilità reale, PostgREST/Auth/RLS, rete vera, privata003 integrata o causaAssalto010. Il caso di retry nel G4 è il requisito del gruppo, non un tentativo esplorativo per cercare verde.

## Consegna

Verdetto finale **0/0/0**; nessun nuovo esempio/campagna o patch dopo questa consegna. Due soli output reviewer. Zero modifiche a prodotti, sito_live, sorgenti canoniche, DB, Edge o documenti centrali. Il PM può procedere ai successivi passaggi di integrazione/pubblicazione e collaudo autorizzati; il verde di componente e questa review non equivalgono a disponibilità live.
