# MISSION_GENERIC_PROVIDER_GATE · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

- Riga 54: `<>case p_stage when 'authorize' then 'claimed' else 'authorized' end` → `<>(case p_stage when 'authorize' then 'claimed' else 'authorized' end)`.
- Riga 77: `<>case p_stage when 'consume' then 'consume' else 'authorize' end` → `<>(case p_stage when 'consume' then 'consume' else 'authorize' end)`.
- Riga 79: `<>case p_stage when 'consume' then 'authorized' else 'claimed' end` → `<>(case p_stage when 'consume' then 'authorized' else 'claimed' end)`.
- Riga 80: `<>case p_stage when 'reserve' then 'claimed' when 'authorize' then 'reserved' else 'authorized' end` → `<>(case p_stage when 'reserve' then 'claimed' when 'authorize' then 'reserved' else 'authorized' end)`.

SQL SHA256 `08a6bc63f598c5c8768d9640a4a8e0782dced24fc82db8a96d9fbb4ff2feb44d` · 16370 byte. SHA A1 `d19deced1ca6fdb0938009f2f38b99b7278634bc625ff13a1581378b54dde227`. Controlli statici: 20 statement SQL top-level, 3 funzioni PL/pgSQL dirette e 6 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

# MISSION-GENERIC-PROVIDER-GATE-001

Stato: delta candidato, non applicato. Owner NARRATIVE-PROVIDER-GATE. Nessun enable, prezzo modificato o chiamata provider.

## Difetto verificato e correzione

La lettura viva di reserve/authorize nativi conferma che `mission_narrative_internal.runtime_policy.enabled` è il gate comune di tutti i receipt ammessi. Accenderlo per la sola missione generica cambierebbe anche l'ammissione dei rami legacy; non è un interruttore specifico della nuova funzione. La policy osservata resta enabled=false, con budget run/day/global NULL.

Il delta mantiene questa riga invariata. Crea un gate privato generico, inizialmente spento, e permessi per work validi esclusivamente nella transazione del dispatcher. Nei due helper nativi, solo per event_kind mission_generic_event, dopo la verifica del permesso viene impostato `pol.enabled=true` nella variabile locale della funzione; nessun UPDATE alla policy persistente. Gli altri eventkind seguono byte per byte il ramo originale. Il consume nativo riceve inoltre la verifica del permesso generico prima del consumo; token/lease nativi restano necessari.

Il permesso è legato a work, receipt, lease, payloadSHA, backend PID e txid corrente. È creato dai soli helper privati richiamati dal dispatcher authorize/consume: nessun GRANT al client/service_role per coniarlo direttamente. Un UUID receipt, token worker o flag client da soli non permettono di ereditare il gate. Il controllo rilegge work/admission, visita/snapshot, envelope attestato e l'effettiva fase claimed/reserved/authorized. Dopo il commit un permesso non è riusabile in un'altra transazione.

## Quote esplicite

Nuova provider_policy: enabled=false, tre tetti chiamate (run/day/global), tre budget USD (run/day/global), inizialmente NULL. CHECK impedisce enabled=true senza tutti e sei i valori positivi e finiti per i costi. dispatch_admissions della sessione deve essere attiva e non può superare il limite run del gate. Nessun prezzo è codificato nel delta: upper_bound usa esattamente max_input_tokens/input_usd_million e max_output_tokens/output_usd_million della policy nativa. Modello Luna/high e store=false restano invarianti.

La somma generica usa receipt generici: spesa exact/upper_bound, inclusi eventi falliti o incerti contabilizzati; una riserva esistente non viene sommata due volte in authorize/consume. Le chiamate conteggiano receipt con tentativo nativo già presente. La prenotazione si svolge sotto il lock nativo runtime_policy FOR UPDATE, quindi due sessioni non possono prenotare contemporaneamente oltre il totale globale. Non viene tenuto alcun lock durante HTTP al provider.

I limiti globali sono cumulativi sui receipt generici conservati, non si azzerano rinominando una prova. Il limite giornaliero segue date_trunc(day) nativa. Prima del QA il PM registra i sei valori e le admission delle singole sessioni coerenti con il tetto proposto di 12 chiamate/USD2 complessivi, tenendo conto di qualsiasi consumo generico preesistente. Configurazione del gate e aperture non sono incluse in questo SQL; NULL resta fail-closed.

Le quote native non NULL, se successivamente configurate, continuano a limitare anche il generico; non vengono ignorate. Le quote generiche esplicite rendono invece sicuro il caso attuale in cui le quote native sono NULL. Il delta non modifica finalize: le chiamate già partite continuano a registrare i costi anche se l'ammissione viene poi chiusa.

## Dipendenze e pin

Applicare dopo MISSION_GENERIC_DISPATCH.sql. Sei patch dinamiche esatte: tre funzioni native e claim/authorize/consume generici. Per le native il pin è SHA256 di pg_get_functiondef letto sul vivo; per le generiche è SHA256 prosrc estratto dal candidato canonico. Ogni anchor deve apparire una sola volta, altrimenti l'intera transazione fallisce. Pin e firme complete nel manifest; nessun CREATE OR REPLACE viene eseguito su una baseline diversa.

Le patch native aggiungono soltanto il ramo controllato; ACL e firme originali restano quelle di CREATE OR REPLACE. I GRANT service-only delle tre RPC generiche sono espliciti e i tre nuovi helper privati sono revocati a public/anon/authenticated/service_role. Nessun GRANT di schema nuovo al client. Il PM deve integrare il delta prima della freeze/review: modifiche ulteriori a questi corpi richiedono ricomposizione esplicita dei pin.

Nuovi vincoli: provider_policy singleton, budget positivi/finiti, sei valori necessari quando enabled; provider_permits PK work, unique receipt, FK native/work, stage authorize|consume e payloadSHA64. Entrambe le tabelle hanno RLS e nessun accesso diretto. Nessun vincolo legacy è allentato.

## Verifica e limiti

Sola lettura dei tre helper nativi: completata. Generazione controllata: sei anchor unici e sei pin, parser SQL esterno PASS20statement. Non compilati i corpi PL/pgSQL e non eseguita concorrenza sul database; nessun banco ricreato. Review indipendente della composizione e preflight dei pin restano necessari. Provider/apply/enable eseguiti: zero.

Recovery conservativa: spegnere il solo provider_policy generico/admission per fermare nuovi consume, preservare permessi, receipt, tentativi e costi. Non azzerare policy o storico, non accendere il gate legacy. Le patch native fuori eventkind generico restano inerti; un eventuale rollback di codice deve usare baseline e pin conservati, senza cancellazioni.

## Correzione aggregata A1 · RT-R1-02

Contratto aggiornato in MISSION_GENERIC_NARRATIVE_A1_HANDOFF.md: fallimento certo pre-provider autenticato e registrato senza tentativi/costi; applicazione finale in sottotransazione, con costi e audit conservati se respinta; timeout/consumo incerto non diventano fallimenti a costo zero. Stato uncertain osservabile senza retry o abort automatico; campo outcome_uncertain nella consegna. Nuova RPC service-only mission_generic_dispatch_reject_v1. Build Edge .2 e manifest riallineati. Nessun apply/deploy/provider; controverifica A1 pendente.
