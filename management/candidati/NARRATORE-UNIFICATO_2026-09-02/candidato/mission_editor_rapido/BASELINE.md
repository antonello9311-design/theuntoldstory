# Editor rapido missioni · baseline di continuità

Stato: **congelata per sviluppo locale** · 19/09/2026. Non autorizza apply o deploy.

## Mandato e perimetro

- Goal: sviluppare l'MVP da trama, fasi e immagini a missione validata e pubblicabile.
- Cantiere riusato: `NARRATORE-UNIFICATO_2026-09-02`.
- Task corrente: `MISSION-RAPID-BASELINE-001`, owner `PM-MISSION-RAPID`.
- Contratto: `mission-rapid-draft/1`, in `CONTRATTO_MVP.md`.
- Nessuna mutazione live autorizzata da questa baseline. Apply DB, deploy Edge, enable e apertura restano gate distinti.

## Separazione da «Adatta missione per test Full IA»

La task concorrente usa al momento due prenotazioni vive:

- `MISSION-ROLE-WINDOW-FINAL-20260919`: `edge:mission_generic_ai`, browser e file runtime/documentali centrali;
- `MISSION-LIFECORE-STAFF-CLOSE-FINAL-20260919`: `db:produzione` e chiusura Staff del ciclo vita PNG.

Entrambe le prenotazioni sono state rilasciate `consegnato` senza drift. L'editor rapido non modifica quei file o risorse. Il compilatore usa la nuova Edge `mission_authoring_ai`; UI, SQL e test restano sotto `candidato/mission_editor_rapido/`. Qualunque futura composizione condivisa ripartirà dai valori congelati qui e ripeterà il controllo se la baseline viva sarà cambiata.

| Superficie concorrente | Versione finale | Hash finale | Evidenza |
|---|---:|---|---|
| `mission_generic_ai` | v27, build `mission-generic-ai/2026-09-19.role-window.1` | bundle EZBR `1884f9aceba8655e86380095ed7d8563531c4f1187f08f113d228e5fa13ef7e9`; runtime sorgente `0ec463c380faa507afd6d0719e31b476be210dbb14507fa610e01896415d8e35`; index sorgente `f2ff9a6306c691ab7883cc3b755d46989a8e1d40a85e9e0436709193df9a7fba` | handoff finale, file locali e lettura Edge live v27 |
| `mission_generic_dispatch_claim_v1` | corpo DB post-chiusura | MD5 `bfe01f0affcd68bb34f3301318b304a1`; SHA-256 `ae04a57ebb3efed85959a4a25f2082d34ec788d375909cbe842db6614a6f8e78` | lettura live successiva al rilascio DB |
| chiusura Staff Life Core | SQL finale | `00205def6f551d8b6addbdf49728416d8b8ae7640f8713176bc37ffa0384cc83` | review 0/0/0 e postflight PASS |
| documenti centrali Missioni/IA/Piattaforma | consegna `MISSION-ROLE-WINDOW-FINAL-20260919` | file rilasciati senza drift | `HANDOFF.md` centrale e task guard |

## Fondazioni già verificate e riutilizzabili

### Mission Creation

- Documento nativo: `mission-creation-document/1`.
- Catalogo Staff: `mission_creation_catalog_v1()`.
- Preflight readonly Staff: `mission_creation_preflight_v2(jsonb)`.
- Creazione atomica idempotente: `mission_create_complete_v1(uuid,jsonb)`.
- Revisione atomica CAS: `mission_revision_complete_v1(uuid,uuid,text,bigint,jsonb)`.
- Riapertura editor: `mission_creation_editor_v1(uuid,uuid)`.
- Revisione privata e immutabile: `mission_creation_owner.revisions`, con impronta del documento e snapshot delle arene.
- Validazione corrente: grado `D–S`, team `1–4`, fasi/editoriale/attori/transizioni referenziali, esiti di combattimento completi e capienza della mappa.
- Una pubblicazione corrente configura e seleziona il piano ma non deve essere usata dall'MVP come scorciatoia per saltare preview, approvazione PNG o apertura controllata.

Impronte vive congelate dopo la consegna concorrente:

| RPC | MD5 corpo | SHA-256 corpo |
|---|---|---|
| `mission_creation_catalog_v1()` | `606496e963a34449d071909ba5907dcb` | `468a73e915e9ad94a2e822452eed76b338060b9ccbc0b3a7bff59b1eee95b08b` |
| `mission_creation_preflight_v2(jsonb)` | `2bfa56c88e45c52eb4495ee1f7c5d870` | `667b1f48ae4f65530785c06785e4273c368729a7295f4d4b4a1d7266ed789798` |
| `mission_create_complete_v1(uuid,jsonb)` | `8a512021ec0335f6eddb8b859607b056` | `52d6dd0c5c432dd2cfbf4d75f900e08c10598325c170dc747adc5005beb044ed` |
| `mission_revision_complete_v1(uuid,uuid,text,bigint,jsonb)` | `f524f372527a2dee51dccc5c8d579c99` | `eaf8fa2302a8e80c5ab92880c6143a9fbf46e4edeae485948083b70e5fd092b7` |
| `mission_creation_editor_v1(uuid,uuid)` | `962af693ff03fda37ff2bddfddd4d94d` | `12a1651d819f01f752748f7cfb62fd95982f0fb7bb737f9351c694adaad32328` |

Tutte risultano owner `postgres`, `SECURITY DEFINER`, `search_path=""`, revocate ad `anon` e con `EXECUTE authenticated`.

### Mappe

- Le mappe specifiche passano per catalogo generale versionato, con geometria, slot, oggetti e impronta server.
- L'assenza di mappa specifica è già risolta server-side sulla default ordinary 10×10.
- Il preflight v2 controlla catalogo e capienza; l'MVP aggiungerà soltanto bozza/configurazione e binding esplicito, senza generazione automatica.

### PNG e media

- Ninja Book/Builder resta la sola fonte autorizzata per identità, persona, profilo meccanico, tecniche, conoscenze e binding di fase.
- Le porte `png_builder_stage_v1`, `png_builder_validate_v1` e `png_builder_compile_v1` esistono, ma il flusso corrente clona da un template approvato e non accetta direttamente un nuovo upload come identità completa.
- `png_media_attest_v1` resta l'unico percorso di upload/attestazione; l'MVP deve aggiungere un adattatore di associazione `actor_key -> media attestato`, non un secondo uploader.
- Ricognizione live successiva al checkpoint: tabelle v17 generalizzate `owner_objects`, `identities`, `technique_bindings` e `phase_bindings` senza righe; Builder v1 con due bozze/due bundle; sei attestazioni media; cinque mappe generali; tredici revisioni e cinque richieste Mission Creation.
- Impronte vive Builder: stage MD5 `655f4bd573d1271f7d072f8b5b1719c4`, validate MD5 `987102c1c984ffbfbb4adc4531173b66`, compile MD5 `13909ce28a3a4b32fd8b6fbd0a5c944a`; tutte service-role only, owner `postgres`, `SECURITY DEFINER`, `search_path=""`.

### Runtime

- Il runtime Full IA consuma piani sigillati e fatti autorevoli server-side.
- L'editor non cambia prompt, role window, life-core o dispatcher di `mission_generic_ai`.
- Le condizioni terminali dell'MVP sono dati versionati nel piano; la loro valutazione dovrà innestarsi sulle porte autorevoli esistenti solo dopo il checkpoint di composizione.

## Vincoli di implementazione derivati

1. L'IA propone esclusivamente contenuto editoriale e requisiti semantici; statistiche, PV, chakra e tecniche sono risolti dal server da cataloghi approvati.
2. La bozza resta privata e non raggiungibile dai giocatori.
3. Qualunque correzione invalida il sigillo di anteprima.
4. Il publish usa la stessa impronta di bozza, cataloghi, media, mappa e budget mostrata nell'anteprima.
5. Ambiguità media, PNG non approvato, tecnica non risolta, mappa incapiente o budget assente sono errori bloccanti.
6. Le sei famiglie terminali sono configurazioni dati chiuse e versionate, non SQL per missione.
7. Nessun file o contratto condiviso viene ricopiato da una versione precedente: ogni delta sarà composto sulla baseline finale appena consegnata.

## Ambiente di prova

Per mandato di Antonello del 19/09/2026 non si usa Docker. Il percorso è: controlli statici e review della candidata congelata; rilascio iniziale riservato; collaudo funzionale esclusivamente nella Staff Test Room protetta con `testperfunzioni` e `Riuji`; postflight su risorse, progressione e sessioni. La prova si arresta su scritture a risorse reali, bypass/autorizzazioni inattese, sessioni estranee o superamento del budget provider. La Staff Test Room è la superficie funzionale reale, non un sostituto della review e del checkpoint di continuità.

## Condizioni per il congelamento

- task guard concorrenti rilasciati: **PASS**;
- handoff finale letto: **PASS**;
- versione/hash Edge riletti dal backend vivo: **PASS**, v27;
- definizioni/hash RPC rilette dopo il rilascio DB: **PASS**;
- ultima migrazione riletta: `20260919113356 mission_npc_lifecore_smoke_cleanup_20260919`;
- conteggi v17/media/creation ricontrollati: **PASS**;
- assenza di sovrapposizioni di file e risorse: **PASS**;
- task concorrente segnala come unico OPEN l'osservazione futura della qualità multi-domanda; non è una dipendenza dell'authoring editoriale.

Conclusione: baseline coerente e componibile. I consumer locali dell'editor rapido possono essere registrati. Prima di toccare una superficie condivisa si ripete il checkpoint; nessun pin verrà aggiornato senza ricomporre il delta reale.
