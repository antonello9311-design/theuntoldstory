# Rilascio Esame2D · confezionamento autorizzato PM

Owner Spatial, executor DB-CORE. Migration codice `20260904233136 esame_spatial_integrated_release_001`; seed separato `20260904233137 esame_spatial_arena_konoha_seed_001`. Versioni assegnate da DB-CORE su orologio UTC e verificate assenti per nome/versione su LIVE e QA prima del freeze; nessuna entry creata. Mandato PM: completamento funzionale Esame, non nuove regole o Missioni; nessun apply implicito.

## File e scope

- `MIGRATION.sql`: composizione delle sorgenti sigillateab83d353, senza runner/fixture/account/sessioni, più delta producerV5 minimo nominato e verificato. Non ripristinare corpi baseline su modifiche LIVE concorrenti.
- `PREFLIGHT.sql`, `POSTFLIGHT.sql`, `ROLLBACK.sql`: pin di 18 corpi baseline e metadati/ACL, assenza dei 15 helper nuovi, verifica dei 33 corpi installati e ripristino controllato. Recovery conserva i 15 helper, revocandoli a service_role/client: restano solo postgres, non richiamati dai consumer ripristinati. Nessuna cancellazione dati o CASCADE. Nessuna firma client cambia.
- `SEED_ARENA.sql`: migration separata `esame_spatial_arena_konoha_seed_001`, SOLO Konoha attiva `df83cd65-b13d-49d6-ad77-a44f35d5ea00`: 1 template, 8 oggetti, 2 slot, 1 binding e 1 route abilitata. Suna, Sala 2 inattive e Staff esclusi. Non modifica flags, sessioni o account. `SEED_DISABLE.sql` disabilita soltanto route/binding del rilascio, prima del recovery codice e soltanto senza esami/istanze aperti.
- Il binding e' metadata del contratto Esame dinamico a due slot; il suo identificatore profilo deterministico NON rappresenta una riga di roster Missioni. Hash reali del documento JSON del contratto, nessun segnaposto QA. La versione del registro si legge dal nome della migration codice effettivamente applicata. Il gate deve verificare anche questa dipendenza, non saltarla.
- `SHA256SUMS`: impronte della consegna finale.

## Delta producer V5

Ownership esclusiva Spatial su SQL in questa cartella, Narratore su Edge e LAND-UI sul consumer HTML. `_esame_ciclo_payload` e replay consegnano card di sette stringhe da `public.jutsu`: effect alimenta descrizione/effetto; action_type e' solo tipologia, non preparazione o sigilli; limits escluso. E' un adattamento canonico dichiarato, NON una revisione editoriale. Proiezione spaziale di sei campi da ricevuta esatta; ramo legacy dichiarato lineare, senza attestazione 2D. Nessun gesto/lato/arto imposto dal server: libertà narrativa contestuale senza ripetizione automatica, meccanica immutabile. Licenza narrativa sui sigilli generici separata nel brief di competenza Narratore.

## Gate finiti

Controlli statici owner prima del freeze: manifest precedente 30/30 intatto; confronto prosrc fra candidato ab83 e release = 32 corpi preesistenti, modificati soltanto ciclo/replay per chiamare il nuovo helper, nessuno mancante, un solo helper nuovo. I 18 corpi di recovery corrispondono 18/18 alle impronte del catalogo baseline. Preflight e postflight sono incorporati byte-exact nella migration. Non sono prove di compilazione o compatibilità dinamica.

Confronto LIVE fresco DB-CORE; review limitata packaging/delta producer; gate branch richiesto e controllo finale payload EFFETTIVAMENTE prodotto→Edge, non handoff arricchito manualmente. Il precedente verdeab83 prova il proprio banco, non certifica questo confezionamento o la compatibilità producer nuova. UI option_id da verificare sul dominio, correzione minima solo se necessaria. Nessuna chiusura Staff concorrente.

Budget definitivo ratificato PM: due scenari, Konoha bound e Suna legacy, ciascuno su ciclo e replay = quattro payload reali. SQL massimo 48 chiamate e 60 secondi, comprese prove concordate e verifica recovery; unico gate Edge massimo 10 secondi, zero provider/token. Una campagna e controverifica finale prevista dal ciclo, nessun ampliamento o rerun per cercare un verde. Runner in questa cartella sotto ownership esclusiva DB-CORE. Preflight branch fresco e nuova eccezione PM nominativa al solo stato Migrations stale, nessuna deroga a catalogo/dati/servizi.

Ordine atomico QA: snapshot registro → PREFLIGHT → MIGRATION → POSTFLIGHT → registrazione transitoria della sola release riuscita → SEED_ARENA → registrazione transitoria del seed → fixture test separata e casi → recovery → ROLLBACK totale. Nessun repair/UPDATE del registro preesistente. Il ROLLBACK della transazione QA deve rendere catalogo e registro identici al preflight; il file di recovery di produzione invece conserva quindici helper postgres-only, quindi NON e' un rollback byte-identico. Produzione richiede GO separato nominativo di entrambe le migration; nessun apply incluso nella consegna offline.
