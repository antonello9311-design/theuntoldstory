# W10 TTL5 — review indipendente integrata finale

Ref: W10-TTL5-INDEPENDENT-20261108 · QA/DB-CORE · 08/11/2026.
**P0/P1/P2 = 0/0/0.** AGG5 qualificata per la conversione esatta e l’installazione autorizzata, soltanto dopo preflight vivo interamente verde, nella medesima baseline/finestra. Enable resta distinto e subordinato a Rootactual/Admin/Pages verificati. Nessun apply o test del reviewer; runtime della candidata NOT_RUN. Ultima aggregata5/5 della stessa candidata: nessun reset di storia, costi o precedenti finding.

## Corpus e identità

Source freeze66885fb00d31ac2cbb79525552aa50ed1c0e9b3d855ba5c260412b0ef3c39b68,11/11pin esatti; componente07b34d6c30edf169f317d7570dec00e716deb51c57f2b208c5e2cc2b9085e772. Root freeze69eb2f4d59d848969a18dcee8c400991d55c07ce26ca4b426adb8f448d345e7c,10/10pin esatti ai percorsi fisici dichiarati. Source identityd9ef3af20584654a3df1eacc11fd79c47af93989e732186157292919259150ed ricalcolata da componente+admission+Edge64b6. Installer inertde389077d5b78832494db0458dda578fa787bc9905d19c6737edb5068a5bf15b/385825B; enable146de885db5603a20669689e0198e8fd3f5b138685834985bee576242b912ff1/101093B; manifest48a6defb50b53f40b26efb9b2746d3a96bf290d9d6f01c0de19309a54f75770e. BuilderW10_TTL5_BUILD_ROOT.py4480dcab72318d7717bf75ca503a5a8b5c849f0b2be71417a53091318d6a3209.

Baseline actualRoot98f88ba491554fbdf5c0e9ec1bb038f95c3d0332206ef80ef2f201c10980451b/524235B, Source71c/proof5b145, captureW10_DB_CAPTURE.json. Edge37/18file reali/SourceSet64b6b4706545e8a7395582dc8fdb39793341d2c3d58b994bf7d0c51576fb9bc0/EZBRdd1d2c569f0aa72f36146c683eb1080c7f13b1ab5149ed6e6cc2f78bf86b9b5c invariati e già controverificati dal raw nella review3940ee93. AdminTemplatef90f3e7a31ba7a76a5b243cdd8355c192dec039085c561e8b13922a7349859c4/484602B con unica mfRevision98. Nessun nuovo deployEdge necessario da questa aggregata.

## Chiusura finding e contratto della queue

**TTL-R1/P2 chiuso:** il freeze elenca i corretti W10_TTL_ROOT_* e tutti10percorsi risolvono ai byte qualificati. Non punta più ai vecchi file AGG3. La storia0/0/1 e il supplemento0/1/1AGG4 restano conservati; nessuna AGG4 è stata applicata.

**TTL-R2/P1 chiuso:** il ramo p_claim8461c789 sostituisce il guard globale con un predicato nominativo fondato sull’approvazione privata, attiva e non scaduta. Non considera la queue un’autorizzazione. Il problema originario era il commit del worker dopo l’HTTP: la propria riga resta visibile al callback per MVCC. La correzione non assume che fosse già sparita. [Sorgente ufficiale pg_net0.20.3](https://github.com/supabase/pg_net/blob/v0.20.3/src/worker.c#L260-L355).

La matrice è stata verificata staticamente nelle branche, nella3VL e nelle cardinalità, senza costruire fixture o invocare funzioni:

| Stato privato | Vincolo di coda | Esito statico |
|---|---|---|
| TTL_READY | Nessuna riga pertinente a sessione/round/request; proprio ID assente | Ammissibile solo con tutte le altre prove vere |
| QUEUED:n, n>14 | Zero o una sola riga propria; se presente POST/55000 e JSON esattamente4campi più identitàbyte | Callback ammissibile solo con tutte le altre prove vere |
| Vecchi ID11–14, proprio ID duplicato, stesso ID con body/metodo/timeout diverso | Rifiuto | Nessun rinnovo |
| Riga con round/request/sessioneS22 ma ID diverso | Rifiuto | Nessun rinnovo |
| Body nonNULL malformato/oltre65536B o UTF8 invalido | Rifiuto conservativo, anche SQL nel casoUTF8 | Nessun invio/costo |
| Richieste non pertinenti | Nessun diritto conferito | Autorità sempre privata |

Il PM ha accettato esplicitamente zero oppure una riga propria nel callback; esattamenteuna era una sua specifica preparatoria, non un requisito utente. Con zero righe continuano ad essere necessari marker privatoQUEUED:n, stessa claim/request/report/contesto e prova durevole. Con una riga, JSONB e byte devono entrambi coincidere col produttore nativo; chiavi extra, duplicate o normalizzazioni permissive non diventano prova. Nessun URL/header/token letto dal nuovo predicato.

Una SELECT di solo catalogo del reviewer conferma net.http_post(text,jsonb,jsonb,jsonb,integer), OID19733/DDLMD505103078b4b36c776bc0925f4fecf8e2, contiene la conversione body::text→UTF8; pg_catalog.pg_input_is_valid(text,text), OID6210/DDLMD5e17bf484ce1fa462abf20ca367f5b4ff, esiste e restituisceboolean. La busta generata da cron e net.http_post è quindi coerente con l’uguaglianza bytea del helper. Il CASE validaJSON prima del cast e limita65536B; UTF8 invalido fallisce chiuso. La queue resta senzaPK e conDMLPUBLIC preesistente: può interferire o negare servizio, non viene promossa a fonte d’autorità o risolta con nuoviGRANT/RLS. Il permesso positivo deriva soltanto dalla catena privata e dalla porta service-only già qualificata.

## Prova durevole e un solo rinnovo

La catena AGG4 rimane byte-identica: enable realmente committato20261108204525/nome exact, testo97979B/SHA329699cc0125503eef2cf511d83d327a33986cd9a2b9c981c0db5d3f2d587f2a e arraystatementsSHA6b447a53acf330192dd94f21d75af4b657d5304d8870600d6ae80b5a0e0f82c1, entrambi ricalcolati indipendentemente dal file eseguito. Quel SQL vincolaRoot98/49header e non può concludersi se NEVER_SENT non è true; il helper allora era boolean nonNULL. La prova stabilisce il controllo storico, senza dipendere da HTTP13 temporaneo.

Prepared489/rowSHA57b627/usagef294/HTTP13f441, HTTP14terminal200failed/retryfalse/SHA8c0b, approvazioneQUEUED14SHA1ccd, claim7d5/attempt271/context0418 e assenze di quota/Count/lease_resumed/narrativa/queue sono vincolate nella preparazione. La riga append-only durableusage9ac25 e il migrationstatement exact vengono nuovamente richiesti dal helper. Registro migrazioni ownerpostgres/OID17599/ACL/schema/colonne/PK e privilegi effettivi di scrittura negati adanon/auth/service entrano nei guard prima/dopo/projection/readback/enable. Il vecchioRoot98 è fatto storico archiviato, non un requisito erroneo del currentRoot dopo l’update.

Prepare registra l’approvazioneQUEUED14 e tutta la prova sanitizzata, poi soloTTL_PREPAREDinactive. FinalenableTTL_READY e cronTTL_QUEUE_RESERVED→QUEUED:n consumano un solo diritto sotto lock prima di pg_net. Cron, admission, enable e durableusage sono byte identici adAGG4. L’acquire già qualificata resta invariata: stessa claim/request, rinnovoexpires_at una volta con auditlease_resumed, massimo300s/deadline; nessuna nuova claim, role, azione o costo. SHA changed/audit/Count impediscono ulteriori rinnovi. Non si ricrea HTTP13 né si cancella storia. Nessun nuovo invio negli ultimi60s.

## Composizione DB/Root/consumer

Due corpi esistenti, stesse ABI/opzioniDDL/ACL/owner/search_path/OID; BEFORE confermati contro il captureactual, nessun aliasing con AFTER. Zero nuove funzioni/tabelle/colonne/vincoli/GRANT. Le due2CREATE AST sono identiche tra componente e installer. Restanti47header e27dipendenze, dieciTactics precedenti e gli altri corpiW10 restano invariati; il fix42725 e il validatorNULL/finanza non sono arretrati.

Root conserva49header(22+27), oggetti actualindice677509/trigger/CHECK/tabelleACL/RLS, migration_guard e aggiunge il contratto pgnet0.20.3/builtin nei guard prima/dopo/projection/readback/enable. FullHeader.tables documenta migration_journal e pgnet_contract; nessun nuovo campo nella capsulaRoot. Ricostruzione indipendente dal Root98 e fullHeaderafter coincide con Rootprevisto **cb9967c439703863f4e57d586ecfeff02208ce67139732964046cf4e50311142**,524235B/margine53. Cambiano solo compactproof/sourceSHA e dbSHA; capsule2, Edge37, primoMissionbundle, config e UI restano identici. Il forecast non è un’installazione attestata.

Adoption conserva CAS parent98 e quattro append-only, vecchie capabilityMission/Party senza attestare nuovi runtime. CustodiaPG/Scorta/Party/gate, attori/dichiarazioni/sessione/attività vengono confrontati prima/dopo. Source inizialmente soloStaff; Tactics/FacingpublicOFF, gli altri rami conservano la parità della baseline. LAND0ff/moduloDC/APIf43 invariati; templateAdmin actual98 offre una sola mfRevision da derivare dal capture successivo.

Finanza invariata: stessi6Count/6Gen cumulativi, input16384/output9992/Countupper0/Genupper0.0066344/somma0.0398064, campagna0.10USD e quota globale5USD/1000/30giorni; nessun reset o riprezzo. ON5/formazione15 già pagati restano unici. Contatori e costo storico0.0175484 conservati; Service/authoring esclusi da questo installer.

Parser pglast6.17 su tutto: installer16stmt/5DO/2CREATE, FINAL_ENABLE12stmt/4DO, recovery3stmt/1DO, projection/preflight/readback1SELECT. SQLbody e PLbody (sola proiezione dei tipi compositi a record per il parser) passano.103queryPL/89uniche analizzate staticamente dopo estrazione delle assegnazioni:0fallimenti/0sottrazioni fra literal sconosciuti. Controllo degli scope/alias dei nuovi guard completato. Nessuna esecuzione di gameplay, espressioniDB o worker.

## Binding e conversione rigorosa

Approved_binding nel JSON di questo referto, ref/MDsha/Source d9ef/findings000. Variante privata W10_TTL5_INSTALL_APPLY.sql con soli3cambi: DOw10_stop→commento specificato; solo literalJSON tactics_review5keys→approved_binding; ultimoROLLBACK→COMMIT. Attesi15stmt/4DO/2CREATE invariati, tutti guard e dati immutati; hash esatto nel JSON. Necessario nuovo preflight Main interamente verde e baseline ancora98 prima di eseguirla. Il preflight21:14 depositato dal Main è12/12, ma non è una nuova SELECT del reviewer né sostituisce il controllo immediato dell’owner.

Dopoapply: readbackactualRoot/full49/oggetti/contratti, confronto col forecast, AdminTemplate con una sola mfRevision98→Rootactual e byte restanti identici, pubblicazione/verifica Pages eDOM. Solo poi conversione FINAL_ENABLE: rimuovere soltanto enable_stop, sostituire soltanto w10_enable_bindingexact9keys con stateVERIFIED/rootactual/Source d9ef/LAND0ff/moduloDC/SourceSet64b6 e3booleani realmente verificati, ultimoROLLBACK→COMMIT.11stmt/3DO/unicoUPDATEapproval, tutti gli altri byte intatti. Non inventareRoot o prove di pubblicazione; drift/guardrosso ferma il passo dipendente. La recovery già qualificata disattiva solo l’ammissioneW10, preservando tutto lo storico.

Deadline21:50:39UTC, enable/queue non negli ultimi60s, nessuna proroga o sesta correzione implicita. Runtime è NOT_RUN; dopo installazione solo casiStaff autorizzati entro budget, public soltantoALLPASS del perimetroMain. Un Fato non raggiunto resta non provato.

Operazioni reviewer inAGG5:1SELECT di catalogo sui due contratti nativi,0RPCwriter/0worker/0provider/0UI/0gameplay/0scritturecanoniche; soli referti e variante privati. Le altre prove readonly sono catture attribuite al Main/owner e i precedenti supplementi. Nessun header/APIsecret/fullrole letto. Tutti i refertiAGG1–4 e i relativi rossi restano conservati.
