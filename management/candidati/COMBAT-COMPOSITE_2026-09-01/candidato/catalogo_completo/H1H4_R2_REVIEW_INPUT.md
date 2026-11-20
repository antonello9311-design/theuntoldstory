# R2 · aggregata H1 e H4 in Staff

Candidata TEMP, senza apply. Baseline riletta `8e6c57cb13656d9dd4959c8ceb50f177183a283dddbb0bfebea84e553a0f9802`, riga `36424dc3a58278e355ff607a13226ca21b056cf5a27fe050125f0fcc3465b8a6`, zero Master, scontri e inviti Staff. Nessun riavvio o rigioco di R2.

## Corpi e perimetro

- H1 sostituisce `combat_v2_staff_nb_internal.commit_roster(jsonb)`, OID 685884, col DDL esatto del componente. Il guard richiedeva `p.operation`, chiave esclusa dal formato autorizzato del comando. La rimozione interessa la sola verifica della chiave assente. Restano le guardie `o.kind` e `o.operation` dell’offerta server e gli altri controlli di scena e accesso.
- E52 OID 684829 conserva i 75 elementi chiusi. Una sola impronta `source_md5` cambia, quella di `commit_roster`. L’oggetto JSON, la firma, sicurezza e tutti gli altri corpi restano identici. DDL SHA dopo `6815c950932fbdfcc07df6fdd71fb562e6b5c054cc978e23e74683bffc4a4ef4`.
- H4 OID 44941 usa il publisher congelato nel componente separato B `a7bd63832727aa902777af727f5905c555f9aa8c46f0fa9a464f3544298ce503`, con review indipendente del componente `6196d3647ec8cca1bbbaa51723300fc94056ba6529d3bcdc40aedae6d39c59c6`. La review disponibile riguarda H4 separata. L’aggregata richiede un proprio referto.

Le tre sostituzioni verificano fingerprint, OID, firma, owner postgres, ACL, SECURITY DEFINER, volatilità e search path prima e dopo. I pin del validator e del wrapper H1 sono verificati separatamente. Nessun nuovo grant o API.

## Root e recovery

Il descriptor server proiettato cambia private75 e owning57, con schema/RLS identici. Peer6 sostituisce solo E52 e publisher. Compat2 sostituisce solo E52 e il guard compatibile resta identico. L’unico alias runtime `db_core.all_function_headers[235]` riceve entrambi i MD5 del publisher, conservando OID44941 e ABI. Le due occorrenze storiche del MD5 iniziale nella normalized identity R2 restano parte del binding originale. I riferimenti attivi E52 sono specchiati nei rami DB/config con la nuova coppia di MD5 e compat2.

Il confronto del resto della Root passa con digest `dd5f25907c4dff423c34aef80f82e388ef5c6f4d5eae824eb396d34abe48474d`. Dopo il cambio, DB `6433cbb63edbafa39edd7a084b6da193a30d5b8e5df8afab525b2f6d2384ac78`, config `359eced657b75a875bdd6189584b828e816f43666f0eb79627e94bdb34e44c4c` e dimensione **523748 byte**, 540 di margine. La prova server di sola lettura riproduce il preimage R2 e verifica compat2 prima e dopo. L’identità completa della nuova Root dipende dal referto reale.

L’installer chiude la composizione in una sola transazione. Acquisisce lock, attesta Root e corpi, usa unicamente i tre DDL documentati e ricalcola le impronte dalle definizioni effettive prima del CAS. I casi esistenti di Passa PNG, Cura, Paralisi e altri publisher conservano il codice originario nel nuovo publisher. UI, Edge e gate sono confrontati insieme al resto dell’albero. Le missioni sono tutelate secondo `H1H4_R2_COMPATIBILITY.md`.

La recovery attesta le tre definizioni effettivamente installate, quiescenza, Root, configurazione e ammissioni. Ripristina i DDL byte-esatti di R2, i binding e alias originali e crea una Root successiva con nuova identità. Nessuna riscrittura di storico o rimozione di gate. In caso di drift serve una ricomposizione, con i pin della variante osservata.

## Consegna

`H1H4_R2_IDENTITY.json` lega l’aggregata. B è la SHA dei suoi byte. Forward, recovery, DO e sei DDL incorporati hanno superato SQL/PLpgSQL con pglast. Il parser usa `record` per le annotazioni `%ROWTYPE` senza mutare gli artefatti. `H1H4_R2_PREFLIGHT_READONLY.sql` ha restituito gli stessi tre corpi, Root e ammissioni attese. La verifica semantica e il collaudo runtime restano da eseguire. La review deve coprire questa esatta composizione.

Dopo review, `finalize_h1h4_r2.py` richiede referto 0/0/0 vincolato a B, preflight fresco e verifica PostgreSQL della SHA di P. La recovery esige anche la ricevuta del forward realmente installato. Il finalizzatore prepara l’Entry con inversa esatta per review, senza eseguirlo.

Nessun SQL mutante, Git, browser o provider. La candidata H4 separata è intatta.
