# MISSION-GENERIC — review indipendente Sources R1

Esito: ROSSO · P0=0 / P1=1 / P2=0. Passaggio indipendente iniziale REV1, raccolta unica; nessuna patch applicata. Reviewer NARRATIVE-REVIEW-SOURCES. Budget massimo30min, provider0, test funzionali0. Data11/09/2026.

## Perimetro congelato

| Modulo root | SHA256 verificato |
|---|---|
| MISSION_GENERIC_PANEL.sql | 03ee8476754f4c231a0b5142f57bfb8d86c7b46f7432dc57bf966ff87242d2f9 |
| MISSION_GENERIC_SOURCES.sql | b00cb739df02342f218575ef7f2b5359a439495ccb2fbfb65500165b50876152 |
| MISSION_GENERIC_CHOICE_SOURCES.sql | f9f7135332725e49a29946b58c1bfa0b96ed20e6b724823346a4744a67f71102 |

Lette come dipendenze: contratto generico, DB/Combat/Progress e contratti Dispatch/ProviderGate/runtime/Common. I moduli scritti dal reviewer non ricevono in questo referto una review formale né una qualificazione autonoma. Le conclusioni riguardano esclusivamente i tre moduli root e i loro raccordi effettivi.

## Finding aggregato

**MG-SRC-R1-01 — P1: il primo catalogo scelte PNG chiama ancora helper Common che richiedono Auth umano.**

Evidenza candidata: PANEL righe96–106 impone il contesto service senza auth.uid e PNG con controller_user NULL; righe112–113 invoca master_projection/master_options. La versione definitiva di choice_options in CHOICE_SOURCES ripete queste condizioni a righe52–69. Il nuovo principal virtuale rende valido il controllo proprietario Common, ma non modifica i due helper ulteriori invocati da master_options.

Evidenza viva, sola lettura: `combat_panel_private.master_options` (bodyMD5 `322a25a9a39b61088f874e5359e3beb4`) quando genera le offerte di un contesto nuovo chiama incondizionatamente `clan_hyuga_private.master_control_offers` (bodyMD5 `7f9bdd705b4bd629401c7315f2ec2bc7`) e `clan_innata_private.sharingan_master_control_offers` (bodyMD5 `110e2293ac42e3817ae977ccc92e9fe5`). Entrambi contengono prima dei propri eventuali RETURN/handler:

```sql
SELECT * INTO STRICT a FROM public.combat_v2_actors
WHERE id=c.command_actor_id AND session_id=c.activity_id
  AND controller_user=auth.uid();
```

Nel percorso generico controller_user e auth.uid sono entrambi NULL: la comparazione SQL non è true e SELECT INTO STRICT solleva NO_DATA_FOUND. Il blocco EXCEPTION WHEN insufficient_privilege presente più avanti non copre questa istruzione né questo SQLSTATE. Nessun delta dei moduli generici congelati modifica tali helper. Il fallimento si verifica sul primo contesto del nuovo principal PNG, quindi prima della creazione del work e della chiamata IA; non dipende dal fatto che quel PNG sia Hyūga o Uchiha.

Impatto: opening e pannello possono apparire disponibili, ma il primo tick che richiede una decisione PNG fallisce nel catalogo delle offerte; la missione non raggiunge resolver/esito. Non occorre una prova mutante per dedurre l'esito della comparazione NULL e del SELECT STRICT.

Correzione richiesta per l'aggregata: rendere compatibile l'ingresso dei due helper condivisi con l'autorità per-attore del servizio, oppure raccordare in modo equivalente la generazione Common, conservando verifiche di ambito/identità e senza impersonazione Auth o apertura globale dei controlli. Pin delle dipendenze modificate e verifica del ramo umano/Esame pertinenti. Non nascondere il problema togliendo indiscriminatamente tutte le tecniche/offerte dai PNG.

## Copertura e risultati non problematici osservati

- **Autorità PNG e transazione:** PANEL48–88 deriva un principal distinto per attore; current_principal richiede service, permesso del backend/tx correnti e gate corretto. Options/commit emettono permessi privati e li consumano nella stessa transazione. Ambiguità fra principal generico/Esame respinta; auth.uid umano mantiene precedenza. Replay commit restituisce il risultato solo per hash comando identico.
- **Opzioni e comando:** PANEL114–125 e154–169 vincola encounter/actor/context/controller/offerta/principal; rifiuta administration e delega al validatore e commit Common. La modifica della decisione non produce direttamente danni o coordinate. Il finding sopra resta il difetto concreto del raccordo alle opzioni native.
- **Fonti pubbliche della scelta:** CHOICE_SOURCES8–28 rilegge attore/incontro/round, link nativo e hash del messaggio, autore/controller e destinatario pubblico; tratta i testi come tentativi dichiarati. Righe30–38 conserva soltanto l'ultima narrazione pubblicata e ne confronta il corpo reale. Nessuna chat arbitraria inviata dal client.
- **Scena risolta:** SOURCES18–29 lega report al round e incontro/visita correnti, verifica meccaniche e protezione risorse; righe61–92 confronta ogni dichiarazione con il report e richiede stati risolta/superflua. Nessuna difesa mancante trasformata in una role inventata. I PNG richiedono ricevuta Common e link messaggio. Non basta un report UUID isolato a pubblicare.
- **Forma shared-scene:** esaminati nomi dei campi, source/action binding, selezione di fonti complete e ordine delle narrazioni precedenti rispetto a verifyScene/buildScene. Identità PG non ha may_speak; il renderer riceve azioni realmente dichiarate e fatti definitivi server. Il limite12000B è esplicito e i contesti eccessivi falliscono, senza tagliare role.
- **Pubblicazione:** SOURCES132–144 richiede work provider_started, lease/request/payload e nuova lettura della source identica, quindi usa lo store Combat nativo. Lo store vivo conferma stato risolto, publication attesa e inserimento Fato/aggiornamento round; nessun secondo messaggio inserito dal wrapper. Il campo continuità corretto result.text è presente a SOURCES51.
- **Tentativo PNG:** SOURCES171–179 pubblica solo la dichiarazione inviata del PNG con principal per-attore attestato nella transazione Common; il link nativo è registrato. Non anticipa il risultato meccanico. I rami Esame/umano successivi sono mantenuti.
- **ACL e pin:** nuove tabelle RLS senza grant diretti, helper revocati a public/anon/authenticated/service_role. Quattro helper condivisi rimpiazzati risultano sul vivo proprietario postgres, SECURITY DEFINER, search_path vuoto e ACL solo postgres; CREATE OR REPLACE conserva queste ACL. I tre pin PANEL e il pin publish_master_declaration corrispondono alla baseline viva. Il pin della nuova choice_options in CHOICE_SOURCES corrisponde al prosrc del PANEL congelato.
- **Profilo Ninja Book:** le letture dei profili sono server-side. Il trigger vivo guard_approved_version impedisce modifiche al contenuto già approvato, consentendo soltanto inattivazione con incremento della versione; quindi non è stato segnalato come difetto un ipotetico edit libero dello scheletro approvato. L'eventuale politica sulla revoca di un profilo già usato resta quella del controller/binding, non una nuova decisione di questo referto.

## Controlli eseguiti e limiti

Parsing SQL esterno pglast: PANEL17statement, SOURCES7, CHOICE_SOURCES6, tutti PASS. Non compilati i corpi PL/pgSQL in PostgreSQL. Confrontati staticamente i delta dei tre helper PANEL con le baseline vive: aggiunta della partecipazione generica e dei principal, senza cambi ai filtri di risorse/visibilità preesistenti. Lette definizioni native Common e store necessarie al raccordo; nessuna role o segreto estratto.

Nessun browser, provider, apply, enable, fixture, ambiente locale ricreato o test funzionale. Non certificati throughput, concorrenza empirica, disponibilità del sito o qualità narrativa. Il verde degli aspetti ispezionati non supera il P1 e non autorizza il rilascio: il finding entra nell'unica correzione aggregata REV1 del PM, poi nella controverifica prevista insieme agli altri referti.

Passaggio al PM: correggere il raccordo delle offerte prima dell'apply dipendente. Nessun microfinding inviato e nessuna autopatch ai moduli recensiti.
