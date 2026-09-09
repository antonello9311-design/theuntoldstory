# Espansione multiattore, mappe e PNG — integrazione dalle fonti esistenti

Stato: proposta tecnica fondata su ricognizione; nessuna implementazione o abilitazione attestata da questo documento. TASK-ID IA-ESPANSIONE-MAPPING-001, PM, 09/09/2026. Il contratto narrativo approvato resta immutato. I cicli movimento PG e NARRATIVE_TECH restano terminali rossi, con richiesta di seguito pendente.

## Risultato da ottenere

La stessa base narrativa deve raccontare uno scontro a più attori, la sua relazione con il luogo e lo sviluppo di una missione; i PNG devono conservare identità e conoscenze autorizzate anche nelle scene libere. Il motore risolve azioni, posizioni, danni, costi e conseguenze. L’IA interpreta persona, dialoghi e scena entro tali fatti, lasciando ai giocatori decisioni e dettagli compatibili delle proprie role. Non è sufficiente rendere più lunga una lista di partecipanti o comporre più duelli indipendenti.

## Base già riutilizzabile e limiti osservati

La copia integrale del bundle `combat_narratore_ai` v23, verificata 15/15 file alle 17:07 UTC, contiene:

| Fonte | Evidenza statica | Conseguenza implementativa |
|---|---|---|
| `scene.mjs`, checkHeader / buildScene / verifyScene | `actors` ammette più identità uniche PG/PNG; ogni azione riferisce attore e fonte univoci. `may_speak` richiede PNG e persona. | Conservare formato e validatori: la base editoriale può rappresentare più attori. Questo non certifica alcun consumer multiattore. |
| `scene.mjs`, selezione fonti | Role correnti complete e attribuite; fonti setting/perception richieste; passato scelto in unità complete. La percezione mantiene l’autore. | Non troncare role o togliere attori per rispettare il budget; un contesto obbligatorio troppo grande produce errore esplicito. Non cambiare i limiti senza misura e contratto. |
| `editorial.mjs`, scenePrompts | Inoltra luogo, attori, azioni, fatti definitivi e fonti con autorità distinte. | Riutilizzare il compositore; catalogo e fatti dinamici devono restare distinguibili anche con tecniche di più attori. |
| `runtime.ts`, sceneOrdinary | Ingresso legato a ordinary_round_id/report/hash; acquire/status/permit/save/complete sono RPC del consumer ordinary. | Il trasporto e la pubblicazione del duello non sono un controller universale di missione o scena libera. Servono binding nativi del dominio, non round Combat fittizi. |
| `common.mjs`, regole e profili | PG senza nuove battute/decisioni; PNG parlante solo con persona, ruolo e permesso; percezioni narrabili distinte dalle permission di gioco. | Conservare i vincoli nel raccordo; pubblicare una percezione non trasferisce agli altri PG conoscenza o bersagli legali. |

Impronte della copia distribuita verificata: scene.mjs 6700 B, SHA256 `be436f9ad4bfca637f7bbc9a35e51bcbcc5e66128d5069b3f4300fcb6c90c5e7`; editorial.mjs 2597 B, `ca21013457b3e86bc9e669a22d5da8a5aa14ccaaaf1667f943c157c60fe8dac1`; runtime.ts 5175 B, `9966c7551d603abe7015054b38001bae7568a9f107c4f99307709f20e989c909`; common.mjs 3174 B, `43fdf09ba041dc5d24869a991600367df899f03aba86592845bac44c50408d19`. I candidati locali omonimi possono differire: il prossimo owner riconcilia il bundle distribuito, non sovrascrive da una versione storica. Nessuna chiamata provider in questa analisi.

## Raccordi verificati del server

Ricognizione Combat/missioni: due letture di sole definizioni/metadati del 09/09, prima alle 17:34:44 UTC. Nessuna funzione applicativa invocata. Fonti locali indicate separatamente: non sono nuove verifiche live.

| Percorso | Fonte e limite comprovato | Innesto necessario |
|---|---|---|
| Ordinary live | `scene_snapshot_v2`: esattamente due membri PG, persona nulla, una/due role; `narrative_ordinary_context`: altro membro scelto con STRICT. | Non eliminare solo la cardinalità: autore, corpo, bersaglio e difensore vanno collegati dai riferimenti nativi. |
| Regia | Wrapper vivo `master_v2_ui_state` → mask_native_state/master_state_authoritative. Corpo sottostante consultato da baseline locale: actors PG/PNG/provider, targets con ordinal/target_actor_id, coverage/protected_actor_id, report.id/mechanics_sha256. | Produrre una vista narrativa autorizzata del round risolto. Lo stato UI del Master non è un payload pubblico da inoltrare integralmente. Prima del codice riconfermare gli interni e ACL sul vivo. |
| Esiti multi-bersaglio | `resolve_parent` locale conserva bersaglio, controller/versioni, difensore, children e coperture. `narrative_declaration_facts` locale riduce i target a ordinal/result. | Conservare o ricostruire lato server il binding per bersaglio/difensore prima della prosa; non farlo dedurre al modello dall’ordine o dai nomi. |
| Spazio | Baseline locale map_projection/master_map: arena/template/map_version, actor_states/body_version, oggetti e grant per osservatore; multiplication_mask_map maschera originali. | Congelare la vista pertinente al report/evento, non la mappa successiva al movimento. Nessuna unione delle viste private di più PG. Immagine e geometria autorevole restano distinte. |
| Missione narrativa live | `mission_narrative_surface_project_internal`: capture/phase_policy, phase_actor_bindings, actor_key/template/versione/persona/media; fact_refs e reveal party/phase/server_receipt, permessi che vietano meccaniche/voce PG/segreti. | Riutilizzare la proiezione già persistita e il fingerprint; collegare il Builder alla surface effettiva senza duplicare la persona nel prompt. |
| Exchange missione live | `mission_exchange_receipt_claim_internal`: receipt/cycle/master/run, projection/hash/full_state/phase_claim; fase specifica scontro_2v2. | Quel limite è una policy di dominio distinta da ordinary. Leggere l’interno mission_exchange_surface_owner_project prima di mappare target Combat → actor_key. Nessuna generalizzazione implicita del canary 2v2. |
| Pubblicazione | Ordinary usa cinque RPC scene; il consumer Master locale invia combat_v2_round_narrate_human; mission Edge dichiara reserve/authorize/consume/finalize con mission_narrative_finalize_publish_internal. | Separare adattatori di autorizzazione e pubblicazione, riusando la composizione. Non usare la porta umana per aggirare l’autorità IA né creare una claim ordinary artificiale. Gli interni dei publisher Master/missione restano da riconciliare. |

Pin MD5 delle definizioni vive pertinenti: scene_snapshot_v2 `542eb2b95627522ee8e0f28507fdf29b`; narrative_ordinary_context `ec6a66b6599cdfb3d80aea6c12c9dd43`; narrative_context `4003653d8bbe5aff6a2c186e5eb87a15`; narrative_master `ace331dc06e83f0320dc71f0da276119`; master_v2_ui_state `af2bb18972d4b43b850e6fd75ed56b87`; mission_exchange_receipt_claim_internal `ad0fddaeff0872de2577470a68dd1b1f`; mission_exchange_surface_project_internal `65feb0d04c6f8a09fd4e79e9de76b9ec`; mission_narrative_surface_project_internal `664665d1b3320f0a8548e4452eced13c`. Fonti locali: RECOVERY_CURRENT_FUNCTIONS.json e moduli del cantiere Combat; hash master_map `6b370f3970c743e8ebde629d53ff4591`, master_state_authoritative `75bfb1807f4941a7b89f8816f98002c8`, resolve_parent `ecca3d1eb3f65c5bf5badb76899181a1`, senza attestazione live odierna degli interni. Evidenze della ricognizione conservate temporaneamente in `/private/tmp/ia-expansion-map/`.

### PNG Builder e memoria: due fondazioni da raccordare

Due letture di sole definizioni/metadati alle 17:34:59 e 17:36:13 UTC. Le nove porte `public.png_builder_v17_*` esistono: authority_attest, owner_register, identity_create, technique_bind, life_transition, phase_bind, archive, story_ledger_append, canonize. Owner postgres, SECURITY DEFINER e search_path vuoto; ACL espliciti osservati `{postgres=X/postgres}`. La vecchia etichetta documentale “service-only” non prova l’accesso attuale di service_role: identificare wrapper e ruolo effettivo, senza allentare permessi per inferenza.

- `identity_create` distingue effimero/persistente e narrative_only/combat_capable; `technique_bind` è distinto dalla persona. La creazione di un PNG non apre una sessione o gli concede automaticamente tecniche.
- `phase_bind` scrive `png_builder_v17.phase_bindings` con identità/control/life, template/versione e reveal autorizzato. La surface narrativa vive invece su `mission_surface_internal.phase_actor_bindings`: run_binding_id, allowed_phases, actor_key, template_id/template_version_id, public_persona/persona_sha256 e media_projection/media_sha256 sono le colonne lette nel proiettore vivo. Il ponte fra i due binding non è stato individuato nelle funzioni consultate; la ricerca di chiamanti diretti non esclude Edge, SQL dinamico o altri orchestratori. Riconciliare il writer prima di implementare un doppione.
- `story_ledger` registra event/request/story_npc/mission/ledger_kind/from_version/to_version/payload_sha256/lineage_sha256/created_at; non contiene il contenuto del ricordo. Collegare la fonte versionata del payload, verificarne impronta e conoscibilità per quel PNG; non ricavare memoria dal digest o dalla chat intera.
- `binding_mode=live_scene` distingue presenza attuale da flashback, ma richiede mission_id/phase_id: non certifica l’autonomia dei PNG nelle scene libere. Serve un contesto reale di presenza/evento/uscita e un publisher del dominio, senza missione fittizia.
- `mission_narrative_finalize_publish_internal` conserva autorizzazione, metriche/costo, replay e chiusura; questi controlli vanno riusati. La catena scelta PNG → offerta legale → commit → ricevuta deve ancora essere tracciata all’interno del proiettore exchange privato. Esame resta riferimento distinto, senza riaprirne le prove.

Pin MD5 vivi: identity_create `d58fba3f0227937588b6434d3085f18b`; phase_bind `32475c0d17feda7ece9bd74f6e5cd063`; story_ledger_append `234f834d294eb484a949665f42da598b`; technique_bind `6415a0109ea909501185b9bffdcc5a4c`; finalize_publish_internal `7b911b992c31e08b587679e99104c313`. Fonte progettuale: ARCHITETTURA-PNG-NINJA-BOOK-2026-09-02.md, SHA256 `262eab95be972b21a001fa171c44802156d2a3f8f8beffc2d32c8023076650ee`; ricognizione temporanea `/private/tmp/ia-expansion-npc/NOTA.md`, SHA256 `8cdfc67fd8143d876b8e574896bf4d14fd285bc63c7a0c0c0dfbaf6114b5f0b4`. Non letti dati concreti di identità, PG, memorie o gate; nessun conteggio/abilitazione del 02/09 aggiornato da questa analisi.

## Ordine di implementazione e proprietà dei file

| Consegna | Intervento concreto | Dipendenza e criterio di uscita |
|---|---|---|
| 1. Raccordo IA scontri in corso | Completare le fonti canoniche di Clone e Moltiplicazione e la fine Clone certificata; recepire i testi ratificati e riconciliare le tre opzioni tattiche. | I terminali rossi rimangono tali fino al seguito autorizzato. Il primo rilascio non certifica tutte le tecniche o tutto il sistema. |
| 2. Producer Combat multiattore | Comporre roster effettivo, controller e ricevute di azione/difesa/bersaglio; ordinare gli eventi del round e collegare le role native. Mantenere un unico stato dello scontro. | Stessa scena e stessa revisione del motore; nessuna perdita o duplicazione di attori, esiti, bersagli o costi. Il producer ordinary non si allarga eliminando una guardia. |
| 3. Spazio narrabile | Derivare dai dati spaziali effettivi posizioni, ostacoli, coperture e percezioni autorizzate pertinenti; mantenere versioni e attribuzioni. | Distinguere mappa tecnica del combattimento da luoghi, collegamenti e descrizioni del mondo. L’IA non inventa una scorciatoia o una copertura con effetto meccanico. |
| 4. Identità e presenza PNG | Collegare Builder/Book approvati al binding di scena/fase e al profilo legale; distinguere civile, combattente effimero e persistente. | Persona e permesso di parola non concedono azioni Combat, tecniche, memoria o conoscenze non autorizzate. Civili senza profilo Combat restano narrabili. |
| 5. Controller missione e quest | Usare fasi, obiettivi, alternative legali e ricevute del dominio per avanzamento, conseguenze e passaggio allo scontro o al ramo pacifico. | La narrazione non chiude obiettivi né assegna premi. Le alternative non risolte rimangono possibilità. Chiusura e ripresa non pubblicano o accreditano due volte. |
| 6. Continuità e scene libere | Alimentare presenza, memoria acquisita, relazioni ratificate e diritto di iniziativa del PNG dal controller della scena. | Non creare un combattimento fittizio per produrre un dialogo. Frequenza, iniziativa autonoma e persistenza delle nuove relazioni richiedono policy già ratificate oppure una decisione di prodotto esplicita. |

DB-CORE / COMBAT-CORE possiedono producer e controller; NARRATIVE-AI compone le fonti e il testo; LAND-UI cura la presentazione nello stesso percorso del prodotto; owner Builder/missione cura binding e continuità; PM integra contratti e riepiloghi. Prima della scrittura assegnare file esatti e risorse: le nuove migrazioni e gli adapter vivono nel candidato del cantiere esistente, con INSTALL/RECOVERY/QA e revisione propria. Nessuna modifica ai moduli congelati delle campagne terminali. Un nuovo campo si introduce soltanto se le fonti esistenti non possono rappresentare un requisito comprovato.

## Prove che devono qualificare l’espansione

La futura campagna avrà casi, chiamate, token e tempo fissati prima dell’esecuzione; questo documento non la avvia e non inventa budget provider. La matrice dovrà coprire almeno i requisiti seguenti nella stessa candidata:

- Più PG e PNG con attacco, difesa propria/delegata e bersagli distinti: ordine e attribuzione dei risultati verificati contro le ricevute native; nessuna duplicazione del costo di una tecnica multi-bersaglio.
- Spostamento, ostacolo e percezione: narrazione coerente con posizione effettiva e punto di arresto, nessuna rivelazione di originali o coordinate riservate.
- Tecniche attaccanti, difensive e persistenti: origine e identità separate, creazione/stato/fine non dedotti dalla sola prosa o dall’assenza di un campo.
- PNG civile e combattente: persona e dialogo permessi, assenza di azioni PG inventate; conoscenze disponibili al singolo PNG rispettate.
- Missione con esito pacifico e con scontro: stato di fase, conseguenze, terminale e recovery verificati; nessuna equivalenza fra prova narrativa manuale e ciclo automatico completo.
- Concorrenza e continuità: versioni stale rifiutate, pubblicazione singola, cambio controller e uscita di un attore gestiti, memoria del PNG persistente coerente nelle apparizioni successive.
- Entrambe le Test Room nei rispettivi perimetri, isolamento reale e UI del prodotto; la prova Staff corrente resta conservata. Nessun test mutante fuori dalle porte protette autorizzate.

Lo standard PNG già esistente definisce la qualità umana di voce, condotta e relazione; non si aggiungono liste di sinonimi o copioni. Le prove editoriali valuteranno prima la fedeltà della singola mossa, poi la coesione di scene con role complete. Un testo piacevole non sana fatti errati.

## Consegna e limiti

TASK-ID IA-ESPANSIONE-MAPPING-001 · Scope: ricognizione e piano nei documenti assegnati · Contratti: combat-scene/1, narrative-editorial/1 e fonti Builder/Book, invariati · Decisione: riusare composizione e autorità esistenti, costruire adapter per dominio · Prove: sole letture documentali/corpi, nessun gameplay/provider · Rischi: presenza di funzioni non equivale a integrazione o qualità · Passaggio PM: assegnare un candidato end-to-end dopo i prerequisiti nominati, mantenendo i gate distinti.
