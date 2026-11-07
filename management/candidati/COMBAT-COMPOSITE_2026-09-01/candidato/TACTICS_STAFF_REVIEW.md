# Review aggregata indipendente · alias e semantica dell'installer FULL6

**PASS_SOURCE_ONLY · P0/P1/P2 = 0/0/0 sulla candidata corretta.** Reviewer QA/DB-CORE, 07/11/2026. Il precedente referto non aveva rilevato la collisione PL/SQL al guard finale; il tentativoac39… è fallito e rollbackato. La presente revisione corregge quel difetto ed estende l'esame semantico all'intero installer; non trasforma il tentativo annullato in adozione o QA positivo.

Installer congelato `INSTALL_INTEGRATED_SOURCE.sql` **180994byte**, SHA **48b901332dfe73ba2e8cb9f60bdd2899a4d65f9fa0c7b3c163f206273709b44b**. Frozen code **70532b3233ce24e12d18396eacb02e71db5a215df46f6ef88f60160a71384cca**, Rootbuilder **0b8e147faf8853d21c11c67df0718379c0a5149ca0cf14e3a93119d86358a86b** invariati. Verificati **32/32 file/hash/bytecount** del freeze1ae097cf… . InputRoot pendingSHA **4b00c027cfde6a35432f4b1617b72dad1a3a139b608c240463ffa574cb781442**.

## Unico delta del codice

Confronto byte indipendente con `_precedenti/20261107_201214_party-alias/INSTALL_INTEGRATED_SOURCE.sql` SHA5c0c4e9a…: cambia soltanto l'alias della tabella Party nell'ultimo postguard:

`to_jsonb(p)`, `p.release_sha256`, `FROM ... p` diventano rispettivamente `to_jsonb(party_live)`, `party_live.release_sha256`, `FROM ... party_live`.

La condizione conserva identici oggettoatteso, sottrazione release_sha256, confronto con r.revision_sha256, filtro singleton e failclosed. Il builderinstaller riproduce lo stesso fix. Cinque corpi funzionali, formula del sesto membro, pin attesi, SQLproiezioneRoot, Rootbuilder e ABI/ACL restano invariati. La review precedente è conservata storicamente, non riciclata come nuova qualifica.

## Passata semantica dell'intero installer

Analizzati **12 scopePL e 345 espressioniSQL** estratte dai parse tree PL/pgSQL: tutte analizzabili, nessun errore di parsing. Lo scope delle SELECT e gli alias locali sono stati confrontati con i datum PL, considerando anche riferimenti whole-row e record/scalari.

- **Namespace:** nessuna collisione bare whole-row residua. La collisione concreta era il parametrojsonbPL p e l'aliasrelazionale p dentro to_jsonb(p), ora eliminata. Rimane soltanto p.capture nel subquerycustodia: è una colonna qualificata dell'aliasSQL p, mentre PLp è scalarJSONB senza attributocapture; non è il riferimento whole-row ambiguo. La custodia con quel riferimento era già stata attraversata prima dell'errore finale nella TXannullata. Nessun outputaliasAS coincide con un datumPL nelle345espressioni.
- **Tipi del guard corretto:** party_live è la riga composite della tabella Party; to_jsonb(composite) restituisce JSONB e la sottrazione della chiavetext restituisceJSONB, confrontata con l'oggettoJSONB atteso. party_live.release_sha256 e r.revision_sha256 sono i riferimenti release testuali giàusati dal contratto. r è la composite readiness deliberata; p resta il documentoJSONB proiettato. Non è stata introdotta una variabile chiamata party_live.
- **Altri tipi/operatori:** verificate proiezioni JSONB vsestrazioni text (->>/#>>), canonical_preimage text→JSONB, octet_length(text), hashtext e UUIDdeterministici; metadataABI OIDbigint→JSONnumber neiCAS e OID::text→JSONstring nel fullmanifest. Nessun confronto incrocia ora i due formati per il medesimo contratto. Gli aggregati/arraycomposite e le colonne esplicite del batch conservano l'ordine fisico catturato; le opzioni sono inserite dopo i gruppi e la FKdepends_on resta differita.
- **Null e cardinalità:** coalesce(...,false), SELECTINTOSTRICT, CASISDISTINCT e rowcount/FOUND rimangono attivi. Le proiezioni richiedono sei header, source/ABI/owner/ACL esatti e witness nonvuoto; la Root non viene adottata quando manca un membro. Le authoritygenitore sono confrontate integralmente e la continuazione del profilo richiede esattamente una riga. La sostituzione del sigillo autentica sorgentevecchia e actorqualificato prima della derivazione e controlla dopo DDL/prosrc/header esatti.
- **Postcondizioni complete:** RootSHA/observed/preimage/dbSHA/dimensione524117, manifest6 e compactRoot sono ricontrollati; custodia reale, Staffquiet, finestra e quattro authoritystoriche sono preservate. Il guardParty finale confronta tutti i campi diversi da release_sha256 con la baseline e la release con la Root nuova. Nessuna condizione è stata rimossa per evitare il rosso.
- **Ordine e transazione:** lock/CAS prima delleDDL; cinqueDDL+sigilloderivato prima della proiezione; adozione2UPDATE4append-only; runtime_release_assert ancora attivo; proof/custodia/postguard prima del commit. La varianteSource conserva STOP, metadataPENDING e ROLLBACK. Nessuna chiamata di gameplay o provider è introdotta.

La cattura `INTEGRATED_FULL6_APPLY_FAILED.json` riporta42702 a inlinepostblockL39 sull'ultimo guardParty. Per l'ordine del sorgente congelato, il tentativo ha attraversato cinqueDDL, derivazionesigillo, Root, adozione, runtimeassert e postproof/custodia prima dell'errore. È evidenza circoscritta di risoluzione/esecuzione nella **TXannullata**, non certificazione di installazione o dei percorsi gameplay non invocati. Il readback Main ha confermato Rootgenitore/helperassente/corpivecchi; nessuna adozione persistita è dedotta.

Sintassi indipendente:25statement/8DO/cinque corpi statici PASS. Preflight/postflight/postcommitcapture sonoSELECTuniche valide. Il presente audit semantico è una verifica statica ragionata con la diagnostica consegnata; non pretende la compilazione completa o il successo futuro di ogni ramo del cluster.

## Ricetta di conversione minima coperta da questa review

Il Main può produrre autonomamente la variante finale **senza ulteriore microreview**, soltanto mediante questa ricetta deterministica già verificata nelle conversioni precedenti:

1. Verificare SHA48b90133… del sorgente e il binding all'esatto referto corrente.
2. Sostituire una volta il DO STOP iniziale con il commento `-- Independent FULL6 aggregate review qualified; source and seal recipe unchanged.`.
3. Sostituire unicamente il JSON di pg_temp.tactics_review con ref/SHA di **questo** referto, statequalified, findings000 e sourceSHA70532b32… .
4. Cambiare esclusivamente l'ultimo ROLLBACK in COMMIT.
5. Nell'inputRoot default modificare soltanto aggregate_review: ref/SHA/finding/source7053…/builder0b8e…/sei firme esatti del JSON di questa review, conservando l'inputpending e il diff.
6. Ricostruire la variante dai tre cambiamenti e richiederne **uguaglianza byte completa**; verificare cinqueCREATEFUNCTIONAST identiche e ricettasealverbatim, parser24statement/7DO. Registrare SHA/bytecount effettivi della variante e hash/diffinput. Nessun altro cambio è coperto.

La ricetta non autorizza una patch supplementare né un pin arbitrario. Il Main ripete il preflightreadonly corrente e i guardtask/custodia subito prima dell'operazione giàautorizzata; l'installer li ricontrolla atomicamente. Un nuovo difetto concreto conserva il proprio stop; nessun apply sperimentale è richiesto dalla review.

## Limiti finali

ZeroSELECTlive, mutazioniDB/UI/canoniche, provider o gameplay da questo reviewer. La scadenza20:30:58.461822Z e i budget non cambiano. **Installazione persistita, Root nuova effettiva/Admin pubblicato e QAStaff sono NOT_RUN da questa review.** Nessun PASS pubblico deriva dall'esito. Il chiarimento del templateAdmin e la recoveryforward restano validi; nessun reset/refund/storia cancellata.

