# MISSION-GENERIC-REVIEW-DB-C1 · controverifica indipendente A1

Esito del perimetro DB/PLAN_WRITER/BOARD/OUTCOME: **VERDE · P0/P1/P2 = 0/0/0**. I quattro finding DB-R1-01..04 sono risolti nella candidata congelata. È la prima controverifica dopo l'aggregata A1; non certifica da sola gli altri moduli, il rilascio o il funzionamento live.

Manifest integrato verificato: `MISSION_GENERIC_INTEGRATED_MANIFEST.json`, SHA-256 `9064ed3428975a78135228b57e527b3b957fdbe90111d0c6c750b8d59599bf3b`.

## File controverificati

| File | SHA-256 | Byte | Statement |
|---|---|---:|---:|
| MISSION_GENERIC_DB.sql | b7e42ea5a6b78d50d5289a356d7be96b550d30cdb305e99b02145cf53fc732ff | 38596 | 42 |
| MISSION_GENERIC_PLAN_WRITER.sql | 2e7a81af83224fb7a6f98d83a3836f4b53ddbee1c61574ab41c3f344795e53ae | 20832 | 28 |
| MISSION_GENERIC_BOARD.sql | c8f24b6021243f5491f01fb7c6bb8242b705626c611a3bd16b81417139fb7cd5 | 38905 | 47 |
| MISSION_GENERIC_OUTCOME.sql | da8c285402f54f37c49261e79069069669f907de5f4177790c6d0e5fb562e2c7 | 16843 | 11 |

Tutti i percorsi sono in `management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/`. Byte e hash coincidono con il manifest A1. Nessun file del prodotto modificato durante questa controverifica.

## Chiusura dei finding R1

**DB-R1-01 — risolto.** `BOARD.sql:172-188` introduce staff_roster_assert: autentica lo staff, verifica il luogo di simulazione, forma/duplicati del roster, acquisisce i PG in ordine UUID e ricava gli user_id dalle schede effettive. Il numero di identità deve coincidere con il roster e `staff_test_allowed(location,principals,true)` deve restituire true. Il flag provider=true mantiene anche il gate nativo delle chiamate IA Staff. La prima chiamata è a `BOARD.sql:410`, prima della creazione del carrier, della sua configurazione, della sessione o di un lavoro provider. La chiamata ripetuta in prepare_start a `:277` conserva il controllo anche per quell'ingresso privato. Un PG fuori policy viene respinto senza avviare o prenotare una prova. La policy nativa è pinned sul corpo vivo; il solo is_test non concede più l'ammissione.

**DB-R1-02 — risolto.** `BOARD.sql:105-125` definisce booking_terminal_assert con service_only, activation Generic started, master in chiusura, run già conclusa/fallita con esito coerente, capability attiva, Boardstart non simulato e PG presente nel roster started con ordinal. Il contratto `finish_scope(session,cap,outcome)` deve restituire esattamente false: la sola appartenenza al luogo o un aggiornamento staff generico non bastano. Il BEFORE (`:132-135`) riconosce esclusivamente iscritto→completata/fallita prima della guardia enrollment_open; gli altri cambi durante la missione restano bloccati. Il nuovo ramo AFTER (`:162-169`) ripete la stessa verifica e ritorna senza trasformare gli applicant started in withdrawn: ordinal e roster storico sono preservati e il CHECK nativo resta soddisfatto.

La composizione con finish_scope è stata letta soltanto come contratto della dipendenza: il controllo dei booking include insieme iscritto/completata/fallita, quindi accetta coerentemente il roster sia prima sia dopo ogni UPDATE terminale, anche mentre gli altri booking attendono ancora la loro modifica. Non sono state allargate la porta pubblica dei premi, l'autorità umana o la simulazione. Questa lettura non costituisce review indipendente del modulo PROGRESS scritto dallo stesso autore.

**DB-R1-03 — risolto.** `PLAN_WRITER.sql:162` congela anche source_mission_content_sha256, escludendo soltanto status dal contenuto editoriale. Il nuovo helper storico (`:229-247`) verifica quell'hash, settings, stato approvato e fingerprint del piano, associazione della definizione e hash del suo contenuto. La porta Staff usa historical_plan (`BOARD.sql:411`); il normale start continua a usare selected_plan con il controllo completo che include status. La variazione aperta→programmata→completata/fallita non invalida più il riuso storico, mentre modifiche editoriali vengono ancora rilevate. Revisioni e missione sorgente non vengono riscritte. L'A1 congela ora anche briefing/village/tag_trama/location_hint nel fingerprint editoriale.

**DB-R1-04 — risolto.** I validator DB e OUTCOME sono allineati: una fase meccanica deve avere esattamente un incontro; una fase narrativa non apre incontri. Ogni incontro richiede 1..12 PNG secondo il core nativo e almeno un team diverso da pg_team (`OUTCOME.sql:72-76`), oltre ai controlli precedenti su identità, approvazioni e duplicati. Le fasi narrative continuano ad ammettere zero PNG. Più incontri sono rappresentati da fasi/visite distinte. L'editor non può più sigillare i quattro casi fuori dal contratto segnalati in R1. La distinzione any/pg_win/pg_loss/draw conserva il rifiuto delle sovrapposizioni e non introduce un ordine arbitrario dei trigger.

## Pin, schema, permessi e verifiche pertinenti

- I tre pin prosrc OUTCOME corrispondono ai corpi A1 effettivi: validate_definition `96b6a55c701498d9df5388654e4dff67`, editor_v1 `653feaf7dea6845ee6f80e067ba289fe`, plan_catalog_v1 `97f75f6547ffc3880891f7864c37a153`.
- Database vivo letto in sola lettura: booking_guard MD5 `bc2c23eaa64e0a69bc4cc5c568368364`, booking_sync `451704552b059dd8bfbcb8585a0e59a5`, staff_test_allowed `80434afefcecbc48e190999830389cee`. Owner postgres, SECURITY DEFINER, search_path vuoto e ACL postgres-only corrispondono alle funzioni native coinvolte. I delta dei trigger aggiungono rami Generic, conservano i corpi legacy e verificano pin/ancora univoca prima della sostituzione.
- Nessuna modifica al CHECK degli applicants o alla policy nativa Staff. Nessun accesso diretto alle nuove tabelle private. I nuovi helper historical_plan, staff_roster_assert e booking_terminal_assert hanno REVOKE esplicito per public/anon/authenticated/service_role; le porte pubbliche conservano autenticazione e GRANT precedenti.
- Nessun valore di gioco viene ammesso dal client per correggere i finding. Il roster viene risolto nelle schede reali sotto lock; la chiusura deriva dalla capability e dalla fase terminale; le risorse/prestazioni simulate restano nel percorso già previsto. Quote e reservation della simulazione non diventano quote reali.
- I contratti di installazione richiedono l'intero pacchetto prima dell'uso. BOARD contiene riferimenti PL/pgSQL a finish_scope definita in PROGRESS, che viene installato per ultimo; il manifest mantiene i gate off e vieta enable intermedi. Nessuna funzione nuova SQL-language viene invocata in anticipo da questo delta.
- Statica: parser PostgreSQL pglast, **128 statement top-level PASS**. Hash, numero di byte, firme delle nuove dipendenze e permessi verificati. Non è una compilazione integrata delle query PL/pgSQL contro gli schemi installati e non è una prova funzionale.

## Limiti e consegna

Controverifica limitata ai quattro finding e alle regressioni pertinenti dell'A1 congelata. Nessuna nuova campagna esplorativa, nessuna patch, autoreview del proprio Combat/Progress, provider, browser, test locale ricreato o apply DB. Le garanzie dinamiche, Auth reale e la concorrenza empirica restano da verificare nel collaudo autorizzato sul sito; non sono dedotte dal parser.

Guard `MISSION-GENERIC-REVIEW-DB-C1`, owner `QA-GENERIC-DB`. Il PM può aggregare questo **0/0/0** con gli altri referti C1. Solo l'esito complessivo e i gate di rilascio determinano il successivo apply; il verde di questo perimetro non significa prodotto in uso.
