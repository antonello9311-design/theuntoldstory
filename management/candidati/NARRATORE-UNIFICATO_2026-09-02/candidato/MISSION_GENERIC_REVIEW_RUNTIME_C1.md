# MISSION-GENERIC — controverifica indipendente runtime C1

Esito **VERDE 0P0/0P1/0P2** per COMBAT/PROGRESS/DISPATCH/PROVIDER_GATE e pacchetto Edge. Reviewer PM-GENERIC-REVIEW, 11/09/2026. C1 su A1, prima correzione aggregata e prima controverifica del budget cumulativo. Nessuna patch durante la verifica.

## Freeze

Manifest integrato SHA9064ed3428975a78135228b57e527b3b957fdbe90111d0c6c750b8d59599bf3b; package Edge build mission-generic-ai/2026-09-11.2, 11file. Hash di tutti i sorgenti SQL, UI e Edge ricontrollati contro il manifest.

| Modulo | SHA256 |
|---|---|
| MISSION_GENERIC_COMBAT.sql | cb80d82231f59473d4aa13584d3e9e7a3360ff0b90e2cf0d09e5b53310431b5a |
| MISSION_GENERIC_DISPATCH.sql | 03d6d4c5158e7a72fe11e0721ccb97023e4de3c4ae2073070eb2efea4d0a7aa0 |
| MISSION_GENERIC_PROVIDER_GATE.sql | d19deced1ca6fdb0938009f2f38b99b7278634bc625ff13a1581378b54dde227 |
| MISSION_GENERIC_PROGRESS.sql | 74d09ee600af60e3e331b8514d492eeb264fb5c99899c11d77dd08faab596c57 |

## Finding chiusi

- RT-R1-01: PROGRESS richiede phase e state raccolta_difese prima della query PNG difensori; main PNG richiede raccolta_azioni dopo la barriera PG e assenza di main già inviato. Il target generato dal primo PG non anticipa ora il PNG durante l'attesa del secondo. Il resolver continua a essere quello nativo. Scelta/azioni non fabbricate.
- RT-R1-02: rejectClaim deposita via adapter una ricevuta service autenticata da user/request/lease. La nuova RPC dimostra work claimed, nessuna authorization/dispatch/attempt e receipt claimed prima di registrare failed/costo0. Replay stesso codice restituisce la ricevuta, collisione respinta. L'incertezza della claim o della conferma non viene spacciata per mancato consumo. Lo stato failed consente la chiusura dell'incipit attraverso abort_opening già autorizzato. La finalizzazione applicativa è in sottotransazione: errori del dominio annullano soltanto commit/publication, poi costi e receipt vengono scritti nella transazione esterna. Il messaggio/command_receipt viene azzerato nel referto del fallimento; SQLSTATE dell'errore salvato, senza testo sensibile. Il risultato provider originale resta hash-immobile. Provider non osservato/timeout produce uncertain contabilizzato, escluso da nuovi tentativi e dalla falsa chiusura dell'incipit. GRANT service-only della nuova RPC esplicito.

## Matrice pertinente

Controllati Auth getUser→adapterUser→dispatch_user, lease e prova pre-provider, reiezione in sottotransazione, accounting exact/upper_bound, report/barrier→pubblicazione, fasi native, chiusura distinta incontro/missione e separazione per sessione. Le modifiche A1 non introducono stato condiviso fra le invocazioni HTTP né una seconda chiamata provider sullo stesso work. Lo stato uncertain resta pendente ed esplicito: non è una recovery automatica o una garanzia che la rete non perda una risposta.

ProviderGate mantiene invariati i tre prosrc pin di claim/authorize/consume A1, perché la correzione ha aggiunto reject e modificato finalize. I tre helper nativi di accounting sono stati riletti, con flag legacy invariato e permit Generic di transazione; nessuna apertura alle chiamate legacy. Policy iniziale Generic OFF. Upper bound/call limit server-side, nessuna transazione DB mantenuta durante l'HTTP provider. Limiti di input espliciti: contesto intero e richiesta completa, mai troncamenti silenziosi.

Baseline nativa di21funzioni riletta in sola lettura: MD5body/definition eSHAdefinition, owner/security/search_path/ACL nel file MISSION_GENERIC_NATIVE_PREFLIGHT.json. Pin delle funzioni modificate corrispondenti; enroll_master post-Combat è un pin di composizione PROGRESS, distinto dalla baseline viva. Constraint vivi di dispatch_receipts ammettono failed e finalized_at; update a costo0 della reject non viola la forma. Work uncertain è nuova alternativa esplicitamente dichiarata nello schema candidato, non un valore scritto nella vecchia tabella nativa.

Statica composizione: 272statement SQL top-level PASS, hash di SQL+UI+11fileEdge PASS; sintassi JS e import graph già verificati e non alterati dopo il freeze. Questa verifica non compila i corpi SQL contro un clone PostgreSQL e non attesta Deno, Auth reale, UI visiva, qualità IA o throughput. Nessun test locale ricreato, provider, gameplay, apply/deploy o enable.

## Consegna

I due finding runtime risultano chiusi nella revisione A1. Verde limitato a questo ambito e matrice, da aggregare con UI/DB/Sources C1. L'occupazione dei PG e la seconda chat non disponibile sono limiti del collaudo live, non risultati superati. Non dichiarare in uso o funzionalità concorrente provata finché manca osservazione sul sito.
