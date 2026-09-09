# Candidata cataloghi narrativi · piano e handoff

Proposto, candidato locale qualificato · NARRATIVE-CATALOG-ALIGN-CANDIDATE-001 · NARRATIVE-AI · 09/09/2026. Solo due testi editoriali della proposta consegnata. Nessun apply produzione, nessuna nuova tattica o modifica della candidata IA verde2/5.

## Scope e autorità

INSTALL modifica solo clan_techniques.description del Clone617484d6-af7b-41c3-a37f-615b22818421 e jutsu.effect della Moltiplicazionec6e31b7b-38fe-4b4f-b3c7-05f3e922d193. Sono testi canonici, non esiti server. Costi, requisiti, formule, limiti e tutte le altre colonne restano identici. Nessuna funzione/tabella/colonna permanente, ACL o gate nuovo.

La proposta004 completa resta un requisito distinto: danno_effettoClone non viene riformulato né spostato per terminare con la frase richiesta sulla copia; le tre tattiche nuove non sono implementate da questo aggiornamento. Non dichiarare soddisfatti quei punti. Non si introduce description in jutsu né un catalogo parallelo.

## Piano del singolo rilascio futuro

Dopo review indipendente pertinente e autorizzazione nominativa DB: riconciliare SHAfile e before correnti, verificare assenza di trigger applicativi concorrenti, riservare DBproduzione. Eseguire INSTALL una volta con ruolo autorizzato alle due tabelle. Transazione unica, lock timeout3s e statement timeout20s, timezoneUTC. Blocca le due righe nell’ordine Clan→jutsu, confronta i due interi preimage prima di ogni UPDATE; ogni UPDATE deve toccare esattamente1riga. Il postflight confronta l’intera riga col target e quindi anche tutte le colonne non modificate. Qualsiasi drift/errore annulla l’intera transazione; nessun force o retry automatico. Il secondo apply è intenzionalmente rifiutato.

Recovery selettivo nella stessa struttura: esige entrambe le righe complete uguali agli after, aggiorna solo i due campi ai before, verifica l’intera riga e committa. Se nel frattempo cambia anche una colonna diversa, si ferma per riconciliazione senza sovrascriverla. Non riscrive snapshot già congelati, narrazioni, history, altre righe o datiPG. Il recupero resta un gate DB nominato.

Il catalogo è condiviso: controllare successivamente le superfici interessate e il nuovo snapshot dal percorso protetto consentito. Riuji escluso. Il percorso ordinary attuale richiede2PG e non supporta ancora testperfunzioni+avversario sintetico: nessun smoke aperto da questa tranche. Mock locale non equivale a prova live. Applycatalogo e deploy/raccordoIA mantengono gate distinti.

## Baseline e campagna congelata

Fonte live09/09 18:42:17UTC: PostgreSQL17.6,78colonne totali,14vincoli (inclusaFKautoreferente),0triggerapplicativi; due sole righe catalogo pubblico. Una lettura produzione, massimo2autorizzate. Il runner contiene questa fixturepubblica e tutti i metadata pertinenti; nientePG/segreti.

DBnuovo narrative_catalog_alignment_001 nel container tus_ordinary_compose_qa_db, PostgreSQL17.6.1.136. Riproduce tutti i tipi/default/notnull e14vincoli dei due cataloghi. Una riga aggiuntiva sintetica soddisfa laFKdel requisito del Clone: non rappresenta il motore né l’abilitàPrerequisito reale. Nessun reset/copiaDBaltriowner. RLS/API/auth/UI/provider e ruoli applicativi non riprodotti: il banco verificaSQLcatalogo come postgres, non accessibilitàclient o comportamento live.

Budget massimo15min,6submissionSQL totali:1createDB+1bootstrap+4gruppi,0provider. Stessa revisione INSTALL/RECOVERY/RUNNER congelata prima dell’esecuzione, hash nelmanifest. Quattrogruppifissi: G1updateesatto/altrecolonneimmutate; G2stalesullasecondariga rifiutato senzaprimaparziale; G3secondoapplyrifiutato; G4COMMITupdate→COMMITrecovery esatti. Ogni gruppo controlla entrambe le righe complete; G1–G3rollback delle fixture, G4committato. Nessuna patch fra gruppi o dopo risultato prima della review. Errori nonSTOP raccolti; bootstrapfallito ferma perché il banco non esiste.

## Consegna e gate

Sei file consegnati, proposta prima/dopo immutata. Campagna unica conclusa: createDB e bootstrap PASS, quattro gruppi su quattro PASS, sei submission SQL su sei, durata 0,511 secondi. INSTALL, RECOVERY e RUNNER conservano le impronte congelate prima delle prove; nessuna patch successiva. COMMIT dell’aggiornamento e COMMIT del ripristino riusciti, righe finali uguali alla baseline. Unica lettura produzione, zero provider, browser, dati PG o mutazioni di produzione. Esiti e limiti in NARRATIVE_CATALOG_QA.json.

Review indipendente ancora da svolgere; nessun verdetto 0/0/0 attribuito dall’owner. Apply DB ancora da autorizzare. Il risultato locale non qualifica le nuove tattiche, la prosa del narratore, i consumer live o la Test Room con avversario sintetico. PM mantiene dossier e riepiloghi comuni.
