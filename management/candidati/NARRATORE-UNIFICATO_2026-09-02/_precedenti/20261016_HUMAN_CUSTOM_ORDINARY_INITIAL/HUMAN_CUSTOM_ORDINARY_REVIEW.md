# Review iniziale completa — RED 0/2/0

Fonte `64e2636e9e635c23a8c4839b7ada36497a4ee757feebd691b09cd65166e3b078`; freeze `e58d431abcf0f6521f7e984c38b1092cc167df7eefaccdd38e9ab0b05d5bef5d`.

## F1 · P1 · NativeSave conserva l’admission manuale scaduta

Il percorso normale Editor chiama `mission_factory_save_v1`. Per ogni nuova richiesta questa funzione chiama `manual_authoring_assert_v1('save',NULL)` prima di aggiornare la bozza. Il ramo pubblico generico è spento; entrambe le admission manuali R37 sono scadute il 15/10 alle 19:02:41 UTC. La candidata rinnova solo C416/C444 e non cambia Save né quel guard. Il catalogo permanente e la nuova capacità custom non sono consultati da Save.

Di conseguenza l’edit titolo Iori Native CV6→CV7, esplicitamente richiesto nel caso fisso, resta bloccato prima della Verifica PNG Combat salvata/import. Dal codice si determina `MF_MANUAL_AUTHORING_STAFF_SCOPE`; nessuna chiamata gameplay è stata eseguita per provocarlo. Anche i futuri Native conservano la stessa dipendenza.

Correggere il ramo server di salvataggio nel perimetro Human e comporlo nell’ABI/seal effettivi mantenendo ownership, validazione, CAS, fingerprint e journal. Non basta qualificare il picker; non è proposta l’accensione generica IA.

## F2 · P1 · UUID publish non preparabile prima della riserva

Il consumer invariato SHA `d1e20064…` genera `p_request:crypto.randomUUID()` soltanto dentro il click «Pubblica la quest», poi invia direttamente il comando. Il template fase2 richiede invece `publish_request_key` prima dell’invio e lo usa soltanto per escludere una riga con quella chiave; non lo inserisce nella qualificazione o nel gate. Non esiste quindi una chiave genuina anticipata prodotta dal consumer normale. Inventarne una non collega la riserva alla vera pubblicazione; un click preventivo fallito non è un passaggio ammesso.

Allineare la fase2 a draft/version/source e assenza della relativa pubblicazione, rimuovendo il falso requisito, oppure prevedere e recensire una reale preparazione client. Nessuna fault injection, lettura di storage o chiamata publish è stata eseguita.

## Copertura intera e limiti

Verificate le dieci sezioni della matrice: Auth, identità S5/C, PNG canonici, authoring, proiezioni, riserva, runtime, consumer/recovery, installer e apertura. Parse indipendente di 60 unità PL, espressioni SQL senza collisioni dichiarazione/alias; 76 relazioni qualificate presenti. ABI viva85 esatta: 81 header/OID/ACL esistenti e quattro porte nuove assenti. Le 27 definizioni dell’installer coincidono AST con la fonte e con i body del post85; metadata esistenti conservati. Ricostruite indipendentemente 18 inverse shared/seal; esaminate le cinque inverse identity e i loro rami tipizzati. Riserva delle letture, FORCE RLS e reward simulation controllati anche sulle definizioni vive.

La compatibilità conserva S5 come provenienza e osserva C reale; la fonte per pubblicazione copre arc e intero draft/versione. L’apertura resta separata e richiede nuovo caso custom, terminale, Combat/report/Fato, premio simulato0, 48 invarianti e provider0. Recovery gate-only conserva codice e storico. Nessuna installazione, mutation DB, browser, gameplay o provider da questa review.

Verdetto **RED 0/2/0**, unico referto iniziale; nuova QA **NOT_RUN**. Conteggi preservati ordinary5/Owner3/precedenteNPC1; nuovo scope initial1/correzioni0. Termine caso 16/10 08:10 UTC. Nessuna autorizzazione apply o apertura da questo referto. La prima deposizione prima dell’ultimo input UI del Root è conservata in `_precedenti/20261016_initial_report_before_final_UI_input/`; stesso initial1, nessuna nuova controverifica.

JSON completo: `REVIEW.json`; prove readonly/statiche e hash nella sezione `evidence`.
