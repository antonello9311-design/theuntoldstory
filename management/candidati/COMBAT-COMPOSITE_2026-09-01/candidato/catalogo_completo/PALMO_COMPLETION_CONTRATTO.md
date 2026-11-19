# Palmo Curativo · completamento mirato Source

TASK-ID: COMBAT-CATALOGO-PALMO-COMPLETION-SOURCE-20261119 · owner DB-CORE-PALMO-COMPLETION.
Stato: SOURCE_STATIC_ONLY, non installato, non collaudato in gameplay, non aperto.

## Mandato e continuità

La richiesta di Antonello autorizza la correzione del blocco «Passa» del PNG, il completamento dei soli casi mancanti di Palmo e poi la tecnica successiva. Questa componente consegna esclusivamente la candidata integrata da sottoporre a review indipendente pertinente. Installazione Staff, prove dal sito e apertura restano operazioni successive del PM entro i mandati permanenti 06/09 e 10/09. Non si aggiungono PNG, nuove regole, nuove superfici, banchi o sistemi di protezione.

Baseline viva verificata dal PM il 19/11/2026 alle 14:38:49 UTC: Root `21c3e8e6f9aae4b2dbe9e5169a9f6e2c3bced79e32d251c1ff6eaecf2b2a3c66`, 521923 byte; riga Root `265efaa5944f652eb1ffa2a7a57472158ff1ec8d97271fa33ef5787c5c16ba01`; DB `bdac83c40ac174e23ba95ba7aa8d28151ca142848fd5e842ce5c9719c9a13e1b8`. Il valore DB effettivo fa fede nella custody/Audit e nei parametri N. UI build `presence-entry-staff-20261119-2`, blob `38f37e85d07bd0b12c10b0c2819dcfbd202c08b0097a0a61897be9ee1b82c570`; Combat Edge45 e Generic168 sono immutati. Cure e Paralisi StaffON/publicOFF, peer seal vero, zero scene aperte. Nessuna acquisizione del browser da questa task.

Le fonti originali `CURE_ENTRY_*` Bc92 e `CURE_ENTRY_SAFE_RECOVERY*` Bbb08 restano immutabili: non sono installate nuovamente, né ripinnate. La nuova Source è un delta minimo sulla baseline corrente.

## Difetto osservato e modifica esatta

Nella scena propria già chiusa `564d2dd4-f7a6-46c8-a757-61f19e7e64b1` / Combat `abb1b790-323b-4752-a28b-27b49bf0acb8`, l'ultimo Passa vuoto di Rina causa auto-risoluzione nativa del round senza attacchi. Subito dopo `publish_master_declaration` rifiuta la dichiarazione già risolta con SQLSTATE42501 `panel_role_declaration_scope_invalid`. Il rollback conserva la preparazione Palmo R3 inviata e non produce ledger/report R3. Nessun retry o risoluzione forzata è stato eseguito. Non si attribuisce un esito positivo a questo caso.

Si modificano quattro corpi esistenti, senza cambiare firme, owner, security definer, search_path o ACL:

1. `cure_contact_v1(uuid,uuid)`: il destinatario deve essere `actor_kind='pg'`. Il controllo vale sia alla scelta sia alla risoluzione. Restano contatto effettivo, distanza massima2m, linea libera, squadra, corpi attivi e autorità server.
2. `cure_offers_v1(uuid,bigint,jsonb)`: vengono proposti soltanto destinatari PG della stessa squadra. Non si cambia l'idoneità della sorgente o dei PG a zero PV.
3. `publish_master_declaration(uuid,text)`: nuovo ramo booleano dedicato al solo PNG con Passa vuoto già risolto, in duello Human Master senza missione, legato a identità corrente, controller/versione correnti e Master autenticato. Sono necessari l'esatto evento nativo `combat_v2_action_declare` completato, request/declaration/round/report corrispondenti, auto_resolution del medesimo report, round risolto, Fato ancora in attesa e hash meccanico valido. La policy e i valori scritti devono corrispondere al server. Un PG della scena deve passare gli scope Cure già esistenti; missioni Unified ed Esame restano esclusi dal nuovo ramo. Il Passa vuoto raggiunge il RETURN NULL già esistente: nessuna role/Fato vuota viene pubblicata. Le precedenti validazioni continuano ad applicarsi, compreso testo esatto e snapshot del controller.
4. `catalogo_eligibility_release_v1()`: aggiorna i due pin target nel manifesto privato66 e il tipo/identità dell'emendamento; il sigillo corrente dei cinque peer comprende adesso il publisher come sesto peer. Nessun manifesto completo nuovo viene duplicato nella Root. I7 owning ports,34 funzioni condivise,3 porte native,12 relazioni,10 trigger e la loro autorità rimangono invariati.

`human_duel_round` resta immutato: descrive un duello di soli2PG e non viene allargato per includere PNG. Non si allenta genericamente lo stato della dichiarazione e non si riutilizza il permesso privato service/missione.

## Riserva, compatibilità e disponibilità

La riserva iniziale usa `cure_staff_scope_v1` e il gate Staff esistenti. Il relativo execution scope controlla Stafflocation nominata, soli PG autorizzati, policy della simulazione, pool di prova, assenza di scritture reali e assenza di missioni/autorità IA/Esame. `is_test` non è l'unica condizione. Il forward richiede e conserva CureStaffON/publicOFF e ParalisiStaffON/publicOFF. Il nuovo ramo pubblico può essere raggiunto soltanto tramite `cure_persistent_scope_v1`, già subordinato a Cure public gate, medico autorizzato/tecnica appresa/policy e contesto persistente pertinente. La candidata non apre quel gate e non autorizza globalmente duelli pubblici3attori. L'apertura successiva va limitata al perimetro qualificato in Staff; una prova parziale non qualifica il percorso pubblico non rappresentato.

Producer: normali consumer Combat/azione nativa esistenti. Consumer: publisher, contatto/offerte, helper chiuso e Root/config. Stessa versione integrata DB/helper/Root/config/recovery, stessa UI ed Edge. Nessun nuovo RPC, GRANT, vincolo, tabella, trigger, payload client, messaggio di gioco o modifica di regola. I costi20chakra, formula e valori del server non cambiano. La proiezione pubblica e le barriere Fato esistenti rimangono invariate.

La Root aggiorna soltanto l'alias OID già presente del publisher, emendamento corrente, due descrittori helper compatibili, digest DB/config/code/recovery e riferimenti del rilascio. Carryforward delle sole capability missione già qualificate e delle due ammissioni precedenti; stessi booleani party. Non si attribuisce un nuovo PASS alle missioni o alle tecniche.

## Recovery e provenienza

Recovery conservativa forward: chiude la disponibilità Cure con entrambi i gate falsi, mantiene tutti e quattro i corpi nuovi, aggiorna la Root coerente e preserva storico, preparazioni, dichiarazioni e audit. Non reinstalla corpi vecchi e non forza alcuna risoluzione. Richiede Root/riga/byte/DB correnti reali, funzione/helper/peer esatti, quiescenza nativa e settlement delle sole sorgenti Cure.

Si conserva byte per byte l'esenzione causale di SafeRecoveryBbb08 per la preparazione storica inviata sotto genitori annullati nativamente, senza report/ledger e con contratti/request/controller/target/source completi validi. Non è una sanatoria delle preparazioni vive e non ne cambia lo stato. Recovery non eseguita. La precedente SafeRecovery resta storica e deve fermarsi sui nuovi pin: la nuova recovery è parte di questo bundle.

Il serializer UTF8 lineare, roundtrip JSON, limite524288, CAS della riga Root, controlli sui flag e controlli di carryforward restano obbligatori. Upper bound esatti della forma: forward521367byte/recovery521489byte, con ref review fino256byte codificati; margine minimo2799byte. Non sono identità future né attestazioni runtime.

## Source B, N e review

`PALMO_COMPLETION_MANIFEST.json` elenca solo Source, Recovery, Contratto e Audit con SHA/byte. B è lo SHA256 esterno dei byte completi del Manifest. Non contiene il proprio hash, N, R1, P, F o E.

Audit conserva custody viva, quattro corpi completi, hunk reversibili, diff, metadata, tre casi statici, capacity e recipe pura. Ripristinare in TEMP `scripts.finalize.py.raw_utf8` e `scripts.pg_codec.py.raw_utf8` dall'Audit, senza modificare i cinque file congelati.

`python3 finalize.py --artifacts-dir <dir5file> --out-dir <TEMP>` produce solo N e envelopeSource. N contiene B, custody, expected_current effettivo, riferimento Contratto immutabile e digest delle due ammissioni. Prima della review confrontare `public.combat_v2_sha256(N::jsonb)` via SELECT puro con il codec; non eseguire la candidata SQL.

R1 deve essere un referto indipendente pertinente reale sui cinque file e N, esito0/0/0; nessun file vuoto o conteggio inventato. Solo allora usare `--review-metadata <R1meta> --review-report <R1file>`: il finalizer verifica byte/SHA del referto, costruisce P, sostituisce esattamente due pin e genera F/entrypoint/E. L'unica istruzione aggiunta all'entrypoint è `set_config(P,true)` dopo BEGIN. R2 controlla equivalenza e composizione, poi preflight vivo prima dell'eventuale apply autorizzato.

Per Recovery usare `--recovery --input <NrecActual>` con Root/riga/DB/byte e digest ammissioni reali postapply, e custody corrispondente. Il finalizer rifiuta una recovery senza input: non si indovina una Root o riga futura. Nessuna review o apply è dichiarata qui.

## Evidenze e casi rimasti

Tre soli casi statici verdi: baseline/composizione completa; autorità/riserva/ricevuta; targetPG/costi/spazio/recovery/capacity. SQL e PLPGSQL interi sono stati analizzati senza esecuzione. Zero DB mutate, provider, gameplay, UI o Git da questa task.

PASS storico conservato: Palmo su alleato cura30,23→53PV, costo20chakra simulati, nessun effetto reale e nessuna azione aggiuntiva. Non si ripete per ricertificare la formula.

Restano NOT_RUN dal sito: chiusura R3 tramite PassaPNG e perdita del contatto dopo preparazione (C04: contatto tardivo O casterKO, senza ulteriore prerequisito casterKO dopo contattoPASS); reazione/Sostituzione pertinente; targetKO; percorso ordinario senza Master. Il PM riduce i casi ai percorsi nativi rappresentabili senza inventare PNG, risorse o comandi. Il collaudo usa solo i normali comandi Staff e conserva ricevute/costi, chiude la prova propria e verifica risorse reali/postflight. Nessun PASS simulato, retry casuale o apertura da questa consegna.
