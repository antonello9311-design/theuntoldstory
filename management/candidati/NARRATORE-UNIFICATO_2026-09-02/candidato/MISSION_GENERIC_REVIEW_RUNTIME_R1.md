# MISSION-GENERIC — review indipendente runtime R1

Esito ROSSO · P0/P1/P2 **0/2/0**. Reviewer PM-GENERIC-REVIEW; moduli scritti dagli owner Combat/Narrative, nessuna autocertificazione dei moduli root. Passaggio iniziale unico, 11/09/2026. Zero provider e zero gameplay.

## Baseline congelata

| File | SHA256 |
|---|---|
| MISSION_GENERIC_COMBAT.sql | cb80d82231f59473d4aa13584d3e9e7a3360ff0b90e2cf0d09e5b53310431b5a |
| MISSION_GENERIC_PROGRESS.sql | 2adebee444e769ceb09f184cfba2e32120909e756625f15e9cfa59e0da5cff93 |
| MISSION_GENERIC_DISPATCH.sql | 0e343b9a6c75f5b1ff758ea265656d3fa7b7aecd693520df18d5ab0c09b0ed86 |
| MISSION_GENERIC_PROVIDER_GATE.sql | d19deced1ca6fdb0938009f2f38b99b7278634bc625ff13a1581378b54dde227 |
| mission-generic-runtime.mjs | 74a1c9fe1108b5879c74a539c8ef62ab98099383772aae6a864febe99f6b989e |
| mission-generic-choice.mjs | 0533db6a340a0ab51cecf85942fc7a716a95f09d704a1b3f29995121c5317d6e |
| mission-generic-http.mjs | 92abeecd87e96f1406577a5cb68828422d29adf50d8e44e44ddbe5fe48a8332c |
| mission-generic-index.ts | da9f1fb97579ceff44062ef0a679d2fb21bc3b60806489274a9ddc5c51af0245 |

## Finding

**RT-R1-01 · P1 — Le difese PNG vengono cercate anche durante la raccolta delle offensive.** PROGRESS330–341 seleziona un PNG con attack_target senza coverage prima della verifica delle offensive PG a342. Non vincola roundrow.state alla fase difese. Con due PG che consegnano in tempi diversi, il primo attacco produce già un target: viene accodata una scelta PNG prima che il secondo PG abbia dichiarato. Al tick seguente lo stesso PNG conserva un target scoperto, ma ha già l'offensiva: Common non offre ancora una difesa nella fase azioni. L'adapter richiede offerte pronte e può arrestarsi su MG_CHOICE_NOT_READY invece di attendere il PG. La scelta della difesa va richiesta nella fase nativa effettiva; le azioni PNG devono seguire la barriera delle azioni PG. Nessuna modifica alla cadenza nativa né auto-difesa inventata. Verifica statica delle fasi reali e caso live pertinente 2PG, quando liberi.

**RT-R1-02 · P1 — Fallimenti certi del lavoro restano pendenti senza una chiusura registrata.** Runtime runMissionEvent reclama il work, poi nei due catch di validateWork/costruzione prompt restituisce409 senza depositare un fallimento. Dispatch status/next osservano soltanto e claim rifiuta qualsiasi stato diverso da ready; nessuna scadenza terminalizza un claimed. Un payload entro il limite DB può superare il limite della richiesta completa dopo l'aggiunta delle istruzioni/schema; questo è un rifiuto certo prima del provider, ma lascia incipit/outbox/reservation in sospeso e non soddisfa abort_opening (richiede failed). Analogamente finalize esegue choice_commit/combat_publish prima di registrare usage: un rifiuto applicativo noto restituisce un'eccezione e annulla la registrazione, benché il provider sia già stato chiamato. Correggere il ciclo con una ricevuta autenticata del fallimento pre-provider e finalizzazione dei costi anche quando l'applicazione del risultato fallisce in sottotransazione. Non equiparare timeout/consumo incerto a nessuna chiamata, non rigenerare né azzerare costi e non sbloccare scene altrui. Conservare un solo tentativo provider e audit verificabile.

## Copertura pertinente

Lettura integrata di Combat (autorità, arena, risorse, principal, receipt), Progress (fasi, resolver, chiusura, simulazione), Dispatch (claim/autorizzazione/consumo/finalize), ProviderGate e ingressi HTTP/runtime. ACL, pin delle mutazioni condivise, forma delle interfacce e lock per sessione esaminati. Nessuna nuova funzione accessibile anonimamente: HTTP verifica Auth.getUser e passa l'identità ottenuta alle RPC service che rileggono membership. I principal PNG restano permessi interni per transazione, non Auth impersonata. CORS ristretto e nessun token finale in risposta al browser. Incertezza di rete non innesca una seconda chiamata provider.

ProviderGate confrontato con i tre corpi nativi vivi: il solo booleano della variabile PL/pgSQL viene autorizzato per la ricevuta Generic validata, sotto lock della policy nativa; il flag legacy sul database resta invariato. Quote globali/per-run e upper bound restano server-side. Nessun prezzo o secret letto oltre ai nomi dei campi del codice. Policy Generic iniziale OFF. Il lock globale riguarda la breve prenotazione contabile, non il tempo di risposta provider di una missione; non prova throughput.

Chiusura nativa e missione_esito lette sul database: schema pubblico qualificato, avanzamento a passi e premi ordinari riusati; simulazione salta premio e role finale. I finding booking del referto DB restano applicabili. Protezione Staff e source carrier non autorizzano roster arbitrari. Roster numerico, slot, arena e eventi restano server-side; zero PNG narrativi è distinto da una configurazione Combat senza avversario.

## Limiti

Controlli statici già registrati dagli owner (SQL esterno e sintassi JS), non una compilazione dei corpi SQL né collaudo runtime. Nessun ambiente locale ricreato, apply, deploy, enable o test sito. Deno non disponibile: import graph Node non è certificazione del deploy. R1 va aggregata con UI/DB/Sources; nessuna patch durante questa review.
