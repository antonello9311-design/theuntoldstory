# Una nuova alba · fonte e collaudo Staff

## Consegna

TASK-ID `MISSION-UNA-NUOVA-ALBA-STAFF-SOURCE-QA-20261117`, 17/11/2026. Mandato Antonello per fonte IA riservata alla Staff Test Room e due percorsi giocati con Riuji e testperfunzioni, senza PNG. Esito funzionale positivo per indizi alternativi e rientro con prove parziali. Campagna con scostamento dal limite output di 868 token.

## Scope e contratti

- Bozza `a050c701-796a-4f6b-b129-42b2262e3303`, versione 3, stato `draft`, MD5 documento `cf825ecd8fe85c8f32d10e1a717623a3`. Documento IA canonico SHA-256 `a96ec585eb572a592cdf973e68a26e959011ad916da28555de2993fda9d337ab`.
- Fonte `7e06ff5b-5fc6-446d-ba10-1b2ca2322cf6`, piano selezionato `4bf290b6-41c6-4573-88c3-47c7c4c10c3c`. Due PG, zero PNG, zero mappe, quattro fasi narrative e quattro transizioni. Fonte `annullata`, XP 0 e Ryo 0.
- Nuova RPC `public.mission_alba_staff_source_v1(uuid)` nominativa sul solo autore autenticato, richiesta fissa e contenuto canonico preciso. Verifica Staff, stanza, permessi, versione e impronte. Usa `missione_crea` e `mission_creation_owner.save_complete`, sigilla il piano e verifica il replay della ricevuta. GRANT esplicito `authenticated`, PUBLIC e anon privi di EXECUTE. Nessun vincolo CHECK o policy di tabella modificato.
- Producer editor Staff, consumer RPC di creazione, contratto nativo `mission-creation-result/1`. Avvio e pubblicazione dei Fati attraverso i consumer Mission Generic esistenti. Edge `mission_generic_ai` v167, Root `f9ad89a82dfc1912f042907a6ad7a6b7196370abbf288f1fdd3e52f31de664f1`. La fonte è preparata per il percorso protetto, con premi zero e disponibilità annullata nell’archivio Staff.

## Versione installata e pubblicata

- Migrazione iniziale `20261117191023`, `una_nuova_alba_staff_source`. Due invocazioni UI iniziali della medesima richiesta hanno restituito `42702` per ambiguità della variabile `document`. Entrambe transazioni interamente annullate, nessuna fonte e nessuna chiamata provider.
- Correzione `20261117191732`, `una_nuova_alba_staff_source_document_binding`. Variabile qualificata come `native_document`. MD5 corpo vivo `39eac9b43254f859c9e8cb5cf30b8990`, ACL `{postgres=X/postgres,authenticated=X/postgres}`. Sorgente correttivo `UNA_NUOVA_ALBA_STAFF_SOURCE.sql`, SHA-256 `38d52ad310f66354b75e547cd3b922df0a32ce73a69a58c2537be1c54e26a8c5`. Il file è il delta correttivo della prima migrazione, con preflight sulla sua baseline.
- Editor `mission-ai-editor-ui.mjs`, 25988 byte, SHA-256 `8432ea3cba7d38aae8228b7522e7fc24830854a38efb703c58c9fec7dce7411b`, commit [23522153](https://github.com/antonello9311-design/theuntoldstory/commit/23522153bd32316b8c416449c850d2765a0eccbb). Pulsante «Prepara fonte Staff» usato nel browser e replay idempotente riuscito sulla stessa fonte e sullo stesso piano.
- `admin.html`, 502750 byte, SHA-256 `070e80aa3cae3c3af3193865bb2758e90fb53668506cd31cf4145fac54b35957`, commit [dab0b926](https://github.com/antonello9311-design/theuntoldstory/commit/dab0b9262c550b4298cb4112667dd15eedbc2ee8). Build `ADMIN-ALBA-STAFF-20261117` verificata sul dominio e riferimento al modulo aggiornato. Due righe cambiate dalla baseline remota.
- Controlli sintattici SQL/PLpgSQL e modulo superati. Quattro script inline Admin validi. Review indipendente dei sorgenti e della correzione finale 0/0/0. Finding iniziale sul replay corretto nella prima aggregata. Ambiguità osservata corretta e controverificata nella seconda aggregata. Nessun consumer condiviso del salvataggio modificato.

## Budget ed esecuzione

Budget fissato prima dello Start, due scene, sei Gen più sei Count, dodici HTTP, USD 0.15, input 64000 e output 12000 aggregati, 45 minuti dal primo avvio. Primo Start 19:18:48 UTC, ultima chiusura 19:29:34 UTC.

Consuntivo letto nel DB, sei work completati e sei Fati pubblicati con ricevuta. Dodici chiamate HTTP, sei Count e sei Gen. Gen con 21937 token input e 12868 output, inclusi i token di ragionamento contabilizzati nell’output. Superamento di 868 token rispetto al tetto output, rilevato al completamento dell’ultima generazione. Dopo quel risultato sono state eseguite soltanto chiusura e verifiche. I token Count sono assenti nell’audit.

Gen settled USD 0.0086277. Sei Count ancora `unknown_billable`, riserva cumulativa USD 0.0744. Importo prudenziale comprensivo dell’intera riserva Count USD 0.0830277, entro il tetto monetario. Il totale economico definitivo rimane da consolidare nel normale audit. Nessun reset o aumento di policy e contatori.

## Caso A · indizi alternativi

Sessione `045aeea0-41f3-48aa-b477-a0b128c75761`, carrier `ed7c1598-5f22-4806-93e2-591e127bb45a`.

1. Il Fato iniziale propone più elementi osservabili nel bosco, fra solchi freschi, segni nel fango, odore d’olio e corrente d’aria.
2. Le azioni dei due PG seguono aria, olio e perimetro. Il Fato restituisce graffi, lastra e accesso al rifugio. Avanzamento server a `conclusione`, «Le prove dell’avamposto», control version 2.
3. Il confronto fra registro dei pagamenti, date e lotti dei convogli produce il collegamento agli anticipi intestati a Kurose. Il Fato distingue quel riscontro dal prossimo convoglio all’alba. Avanzamento server a `fase_1`, «Rapporto a Konoha», control version 3. Il percorso ha usato registri e manifesti, lasciando disponibile la diversa pista del sigillo.

Ricevute e messaggi pubblicati, nello stesso ordine.

| Work | Ricevuta | Messaggio |
|---|---|---|
| `27866314-abb7-cdf2-55cb-313b09939c61` | `cb3ade80-e01c-4e3a-96ce-20323dc7550e` | `f8b24d5d-1a64-4018-9367-d8a178ab9fc1` |
| `285795bd-113e-8032-8325-e9ae9456d241` | `e0d2718a-9d33-41f9-99b9-381b97e240cf` | `4603278c-8b9d-4465-8a8d-862a50d9a94f` |
| `8e051d78-00d0-b1da-58ed-9971c04fef2c` | `394089c4-735a-40fa-9a1d-66984830648f` | `dc776d3a-5c06-49f7-af11-8c18024a775f` |

Esito funzionale richiesto PASS. Chiusura ordinaria protetta tramite «Annulla prova» alle 19:24:21 UTC, stato `annullata`, motivo `staff_simulation_abort`. Alla fine del caso il terminale era `waiting_final_publication`, quindi la conclusione nativa di missione con esito positivo rimane fuori dalla copertura eseguita.

## Caso B · rientro con prove parziali

Sessione `2f424d28-06b8-47cd-bf6f-5e457df3b8ae`, carrier `c38ac0f3-207f-49d7-a170-e883ffbf975e`.

1. Nuovo incipit nella medesima configurazione narrativa.
2. I PG seguono segni del terreno, margini e solchi. Il Fato accompagna verso gradini e rifugio. Avanzamento server a `conclusione`, control version 2.
3. I PG raccolgono riscontri del deposito e del convoglio all’alba, limitano l’indagine e scelgono il ritorno con prove parziali. Il Fato conserva l’informazione operativa sul convoglio, riconosce l’attribuzione ancora incompleta e racconta il rientro a Konoha. Avanzamento server a `fase_2`, «Rapporto incompleto», control version 3. Kurose resta privo di attribuzione in quel rapporto.

Ricevute e messaggi pubblicati, nello stesso ordine.

| Work | Ricevuta | Messaggio |
|---|---|---|
| `4b5c0937-4038-45e1-44eb-30804284ef7b` | `4fdbb804-0074-40b3-9816-3c6d972fca72` | `f42fc38b-1d12-4ac3-915d-94247b040d28` |
| `f6a1f0cb-0080-7c2f-5a2f-edfec479566d` | `08fbce3a-d50a-42cb-86a6-e1bc5258fab9` | `65189e63-a80d-4a6f-a04a-89e7cbc60091` |
| `b537da7f-0808-a738-473f-37dac68030e9` | `e99e75bf-66ca-48b6-92f6-c3668aa4e7d2` | `15ccdbbf-1c77-4efb-bdcd-f4ba24942184` |

Esito funzionale richiesto PASS. Chiusura ordinaria protetta tramite «Annulla prova» alle 19:29:34 UTC, stato `annullata`, motivo `staff_simulation_abort`. La copertura comprende il rientro narrato e la selezione autorevole della fase incompleta. Il successivo terminale nativo e l’attribuzione di esiti esterni rimangono fuori dalla campagna.

## Postflight e limiti

- Sei work completati, zero sessioni Master Staff aperte. Entrambe le prove proprie chiuse e storico conservato.
- Fonte annullata e con premi zero. Bozza v3 e impronte iniziali confermate. Zero pubblicazioni della bozza.
- testperfunzioni con vita 105/105, chakra 155/155, XP 9950, grado Genin e pool 120. Riuji con vita 80/80, chakra 105/105, XP 100, grado Genin e pool 90. Questi campi coincidono con il preflight. I metadati di accesso e presenza possono variare durante l’uso del sito. Inventario e portafoglio privi di confronto integrale delle righe nella campagna.
- Il percorso pubblico della bozza conserva `MF_AI_CAPABILITY_ENVELOPE`. La tappa B di ammissione pubblica con zero PNG è ancora candidata. Il presente mandato copre fonte e due percorsi Staff.
- Le prove attestano avanzamento su indizi alternativi e rientro parziale sulla configurazione esatta. La chiusura nativa finale e la pubblicazione della missione richiedono il proprio perimetro successivo.

## Passaggio al PM

Fonte Staff disponibile nell’archivio, entrambe le scene proprie chiuse. Conservare queste ricevute e lo scostamento output nella qualifica. Il prossimo lavoro dipendente è l’ammissione pubblica zero PNG e la relativa finalizzazione protetta nello scope autorizzato. Il costo Count si consolida tramite l’audit esistente.

Le copie di lavoro storiche `sito_live/admin.html` e `sito_live/mission-ai-editor-ui.mjs` sono precedenti alla baseline remota. I delta pubblicati sono custoditi nei due candidati nominativi. Le aree, SCHEDA, HANDOFF e STORICO sono aggiornati nel workspace. Il sorgente correttivo è depositato nel commit [a443448c](https://github.com/antonello9311-design/theuntoldstory/commit/a443448c1e7d78db9ec11883ca69d3c40b847a07) e riletto esatto. Aree, SCHEDA, STORICO e HANDOFF sono depositati con il solo delta di questo mandato, preservando i contenuti remoti estranei. Le copie locali comprendono anche aggiornamenti di altri mandati, conservati nel workspace. Riferimenti dei depositi in PUBBLICAZIONE.
