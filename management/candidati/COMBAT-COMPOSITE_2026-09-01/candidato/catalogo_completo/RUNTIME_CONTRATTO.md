# Runtime catalogo · prima versione integrata candidata

SOURCE ONLY · COMBAT-CATALOGO-COMPLETO-20261118. Versione senza qualifica Staff; lo stato qui descritto è quello della consegna sorgente, prima dell’apply DB governato dal task principale. La completezza del catalogo resta un obiettivo aperto; questa candidata implementa Palmo Curativo e Paralisi illusoria. Le 38 abilità catalogo e i 2 jutsu esplicitamente fuori_scontro mantengono il dominio narrativo, come confermato da Antonello.

## Confini e autorità

Il server produce offerte, controllore/versione, requisiti, geometria, costi modificati, confronto, effetti, clock personali e ricevute. Il client sceglie opzioni server; l’IA racconta i fatti congelati. Nessuna acquisizione o statistica reale viene concessa per la prova: le preparazioni Staff scrivono soltanto snapshot e ricevute della simulazione autorizzata sui due PG. Il pubblico delle due nuove tecniche resta OFF. Missioni, Quest, Esame e altre scene non sono banchi di questa candidata.

Palmo usa la formula pubblicata floor((Mente+Ninjutsu)/3), costo base20, contatto, sé o alleato PG. Occupa il turno intero: nessuna altra azione volontaria, tecnica o movimento prima/dopo; restano le reazioni fisiche. Il resolver segue il ledger nativo, applica capPV, verifica corpo/controllore/contatto e distingue simulazione da risorse reali. Un alleato KO a0 può tornare operativo, senza turno retroattivo né riattivazione di effetti terminati. Le altre cure non ereditano automaticamente questo profilo.

Paralisi costa10, P20, gittata10m, Genjutsu>=25 e sigilli. Un confronto mentale riuscito blocca soltanto il movimento del prossimo turno personale del bersaglio; azione principale e reazioni restano consentite. Nessun dannoPV e nessuna presa fisica. Nessuna sovrapposizione o proroga; scadenza personale, KO della fonte/bersaglio e fine scontro chiudono l’effetto. La liberazione deliberata consuma una principale, basechakra0, contesa mentale con parità favorevole alla liberazione oppure Kai posseduto con Mente>=20. Il Kai in ingresso resta una distinta reazione.

Il perimetro corrente Paralisi Staff ammette esattamente i due PG autorizzati: il Kai su alleato richiede un terzo attore e rimane NOT_REPRESENTABLE, senza PASS presunto. Il raccordo NinjaBook solo Staff è stato autorizzato esplicitamente da Antonello ed è in preparazione come delta separato; non è incluso nell’installer corrente. Palmo può usare il normale composer Master con i due PG alleati e un PNG legacy nemico, restando i soli PG destinatari della cura.

## Producer e consumer composti

| Producer | Contratto / contenuto | Consumer |
|---|---|---|
| Offerte e preparazioni private | profilo Staff, scelta/bersaglio, request, controllore e fingerprint | pannello comune, porte native action/defense, freeze transazionale |
| Resolver Palmo | ledger chakra nativo e ledger cura, outcome immutabile | report nativo e projection result.healing palmo-curativo-narrative/1 |
| Resolver Paralisi | sorgente e confronto mentali, effetti e state_version | lifecycle dei turni/KO/chiusura, dichiarazioni e movement_block_reason |
| Lifecycle Paralisi | eventi legati a round/declaration/clock nativi | genjutsu_facts paralisi-report/1 prima dell’hash report, projection genjutsu_events paralisi-events/1 |
| Report congelato e roster proiettato | risultati e cronologia finale, senza nuova chiave top-level | round_details_from_source e due formatter privati, nomi soltanto dal medesimo roster |
| Claim/context SQL e Scene snapshot | combat-facts/2 solo per nuovi fatti, combat-facts/1 legacy | combat_narratore_ai: facts.ts, ordinary.ts, editorial.mjs attivo |

L’Edge mantiene Scene1. catalogSceneGuidance valida i soli campi tipizzati nuovi nel percorso editoriale effettivamente chiamato; nessun numero di gioco deriva dal testo. Per un effetto, l’ultimo evento causale prevale su applied/still_blocked storici: una scadenza nello stesso report non lascia il Fato a raccontare un blocco ancora attivo. La fine di questo effetto non libera da altre immobilizzazioni. Le ricevute claim/snapshot/permit/save/complete e la barriera pubblicazione/ripresa restano quelle native.

## Baseline e composizione

RUNTIME_BASELINE.json custodisce Root esatta73712255…505228byte e34 descrittori ABI vivi. RUNTIME_SHARED.json conserva corpi prima/dopo, sette risoluzioni esplicite dei conflitti e55 hunk reversibili. Ogni baseline condivisa è verificata prima di sostituire corpi; dopo la sostituzione si confrontano SHA della definizione e MD5 del sorgente. Firme, default, owner, ACL e search_path condivisi restano preservati. Le funzioni nuove ricevono REVOKE/GRANT espliciti e le tabelle private RLS. Non si allentano vincoli comuni del motore.

Root: sette alias per cinque funzioni toccate, quattro hash di codice già arretrati e nessun drift ABI; si compongono i corpi vivi e si aggiornano gli alias, senza reinstallare quelli storici. La riconciliazione esplicita corregge anche l’hash db_core preesistente incoerente. Il nuovo manifesto separa candidatura Staff da qualifiche missione pregresse, conservando client, GenericAI168, ammissioni e dati missioni. Nessun PASS nuovo viene ereditato. Il serializer lineare elimina solo whitespace JSON esterno alle stringhe, richiede roundtrip JSONB e cap524288prima dell’UPDATE. Una proiezione dimensionale non è un PASS.

## Rilascio e recupero

Prima di ogni installazione: review indipendente pertinente della composizione0/0/0, custodia, pin vivi, assenza drift/scene altrui, hash sorgenti e recovery. Il primo deploy Edge resta inattivo per le nuove famiglie finché i producer/gate non sono installati. La ricevuta Edge reale viene letta e confrontata con tutti i18file, soli3delta; nessuna versione o lettura viene inventata prima del deploy. La capsule finale con receipt reale e la sola sostituzione del pin nel template ricevono controverifica prima dell’apply DB atomico.

I due gate pubblici restano OFF. Dopo installazione riservata occorre una campagna finita di normali percorsi Staff con/senza Master, isolamento delle risorse e chiusura nativa delle sole prove proprie. Casi non rappresentabili e percorsi non provati restano limiti del rilascio. La campagna non è avviata e ha consumato0chiamate/provider/scene.

Recovery conservativa: spegnere nuove offerte, chiudere nativamente le sole prove proprie, attendere quiescenza, inverse esatte dei34corpi condivisi e disabilitazione dei soli10trigger Cure nominati. Funzioni/tabelle/profili/audit/snapshot/ledger rimangono custoditi; nessun DELETE, reset o ripristino di schede. La Root di recupero è una nuova identità forward inerte con review propria, senza riscrivere la737o qualifiche storiche. L’inverso dei corpi da solo non è una recovery globale installabile.

## Stato della verifica

Parsing SQL/DO integrale della composizione passato; i limiti del parser senza catalogo su campi rowtype sono registrati e confrontati alla baseline. Nessun DB/gameplay locale. Review private0/0/0 circoscritte conservate; review aggregata in corso. L’errore readonly53100della precedente stima Root e i controlli minimi successivi sono registrati in QA.md. Nessun risultato statico è presentato come prova giocata.
