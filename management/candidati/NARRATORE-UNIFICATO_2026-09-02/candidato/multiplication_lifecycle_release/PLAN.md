# NARRATIVE-MULTIPLICATION-LIFECYCLE-AGGREGATA-002 · candidata congelata, non applicata

## TASK-ID · Scope e contatore
Candidata002, prima correzione aggregata della lifecycle; non azzera il conteggio e non riapre altri cicli. Owner NARRATIVE-AI, mandato PM/Antonello per correzioni necessarie. Otto file di prodotto del modulo; 27 file correnti001 conservati byteidentici in `_precedenti/lifecycle-before002/`. Le precedenti sottocartelle interne restano intatte. Nessuna modifica a PNG, Flussi, Master, Edge, prompt, sito, DB o documenti centrali.

## Problema iniziale e stato della001
Lo smoke006 ha certificato il consumo della Copertura ma il payload non conteneva la conclusione. La helper001 aggiunge quell’evento server senza cambiare esito, catalogo, Clone o stringa JSON dello snapshot. Review001 0/0/0, componente4/4 e wrapper8/8 sono esiti conclusi della001 e restano immutati. Il preflight live001 ha trovato18/18pin esatti, ma una riga ordinary ancora `claimed` oltre la scadenza ha impedito l’apply: nessun rilascio eseguito.

La002 corregge esclusivamente quella classificazione nella guardia `QUIET`. Il corpo AFTER della helper rimane **byteidentico001**, SHA256 `59d25d1a527958bd63e4cb3ebf8ad68665fdc301c13f76edc175d2e4625af9a7`, MD5 `6d7cbbfbd1ecbae7f8efad6e7eeaca36`. Non richiede di ripetere i quattro gruppi della proiezione; la nuova guardia e i wrapper002 richiedono invece qualificazione propria.

## Fonti live verificate prima di costruire
Due sole query readonly autorizzate: 02:18:48.097559UTC del10/09/2026, sei definizioni/owner/ACL/config e relative impronte; 02:19:02.192959UTC, sole condizioni tecniche del claim segnalato. Nessuna role, testo provider, figura, coordinata, segreto o dato di scheda.

Claim `01fadb09-6e62-45ee-9456-2e9b9bc3647d`, round `b8788944-3079-4506-b073-5489a75ef701`: stateclaimed; scadenza08/09/2026 22:32:11.60653UTC, strettamente precedente alla lettura. Cinque booleani NULL tutti veri (`completion_sha256`, `completion_result`, `provider_response_id`, `provider_request_sha256`, `raw_output_sha256`); zero attempt perclaim e zero perround. Il claim storico non è stato terminalizzato, aggiornato o rinnovato.

Le sei semantiche risultano compatibili col corpus esaminato e vengono ora pinzate nei pre/post di INSTALL e RECOVERY. `claim_v1` e `complete_v1` usano `clock_timestamp()` **dopo i lock**. Un claim esistente non riceve un nuovo permesso; un risultato legacy tardivo viene negato. La transazione lunga o iniziata prima della scadenza non congela il tempo come accadrebbe con `now()`. La v2 rifiuta un legacy claim senza attempt; permit/save richiedono attempt e lease adeguata. **Complete v2 può consegnare un risultato già generated dopo la lease**: per questo non si escludono genericamente tutte le righe scadute.

Questi sei corpi sono soltanto dipendenze lette e confrontate, non modificati. Il BASELINE conserva definizioni, impronte complete, impronte corpo e attributi; il preflight blocca eventuali mutamenti futuri di quelle semantiche.

## Correzione tecnica circoscritta
Si acquisiscono gli stessi lock `SHARE ROW EXCLUSIVE` su narrative_claims e scene_attempts_v2. All’inizio del successivo DO, quindi **dopo entrambi i lock**, si campiona una sola volta `checked_at:=clock_timestamp()`.

Per ogni claim ordinary non terminale, l’operazione resta bloccata salvo che siano vere tutte le condizioni: stato claimed, scadenza nonNULL strettamente anteriore a checked_at, cinque campi di risultato/provenienza NULL, nessun attempt correlato né perclaim né perround. Un attempt di qualunque stato, inclusi generated/provider_reserved oltre la lease, continua a impedire l’esclusione. I casi non dimostrati o incoerenti restano bloccanti.

Questo è un criterio readonly di disponibilità durante il rilascio. Non aggiorna state/scadenza, non riemette permessi, non cancella dati, non esegue il recovery di un claim e non afferma che nessuna vecchia HTTP sia mai partita. L’autorità delle porte native e la loro gestione delle scadenze restano identiche.

Sono ora confrontati17corpi e7relazioni, contro gli11corpi+7relazioni della001. Nessuna nuova funzione/tabella/colonna/grant client, nessun vincolo cambiato. L’unica funzione sostituita dal futuro apply resta la helper già qualificata come componente.

## Recovery e composizione
Stessa guardia QUIET in INSTALL/RECOVERY. Il blocco UNUSED e il gate nominativo primauso della001 restano byteidentici: dopo una conclusione persistita, recovery vietata senza rewind della storia. Il nome storico del gate identifica la medesima capability di prodotto, non una nuova autorizzazione implicita. Nessun apply/deploy abilitato dalla costruzione002.

Restano i limiti di composizione001: Flow006 sostituisce la stessa helper e necessita di integrazione esplicita; nessuna concatenazione di script per sovrascriverlo. Master/utenti/PNG non vengono collegati da questa candidata. Il caso006 e le sue role non vengono rigenerati.

## Prove eseguite, limiti e passaggio al PM
Due query readonly, AST Python e generazione offline; confronto byteidentico del corpo AFTER e dei blocchi narrativo/UNUSED; SQL rigenerabili senza differenze. Zero SQL mutanti, Docker, provider, browser o campagna002. I referti001 restano sorgenti immutabili della sola001; nessun esito verde viene trasferito alla guardia002.

QA_PLAN fissa una futura matrice limitata alla guardia empirica e al wrapper002: massimo8submission SQL/10min/0provider, nuovo banco distinto e nessun rerun della proiezione4/4. Il PM assegna review finale002, costruzione/qualifica proporzionata e gate nominativo prima di qualsiasi apply. La compatibilità live della semantica è provata alla lettura, non promette immutabilità futura: i nuovi pin servono a fermare il rilascio in caso di drift.
