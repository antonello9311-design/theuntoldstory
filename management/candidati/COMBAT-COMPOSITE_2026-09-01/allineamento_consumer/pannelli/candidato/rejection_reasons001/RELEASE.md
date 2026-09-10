# Rilascio DB rifiuti Common · applicato e verificato

COMBAT-PANEL-REJECTION-REASONS-RELEASE-002 · DB-CORE. Unico apply nominativo autorizzato dal PM nel mandato Antonello alle procedure necessarie per completare i collaudi Clan. Migrazione **20260910051050 combat_panel_rejection_reasons002**, risposta success:true salvata RAW prima del parsing. Nessun replay o recovery.

INSTALL aggregata002:13710byte, SHA25630ec1184eeadb0c708de330357c606f234108d6ca45ba9d284367b8b0f81963d; una sola statement conservata nel registro, MD5b40d8b60058ff3f677e8edd8fef8b4d1 identico al file completo. Postflight 2026-09-10T05:11:11.785026+00:00: due funzioni esatte. Gateway AFTER0ec7f7f1228b3f1afef03ad6323bf960; combat_v2_fail607dec1f81b9b0c310c91585315803f6 invariata. Firme, ownerpostgres, ACL, security_definer, volatilità e search_path coincidono con le attese. Nessun nuovo privilegio o campo API.

La modifica è immediata sulla funzione condivisa: cambia soltanto la spiegazione pubblica delle cause riconosciute. Autorità, autenticazione, code, request_key, recovery, dispatch e rollback sono preservati. Non è un rilascio inerte; non attiva un nuovo motore, un flag, Edge o una stanza.

Review finale0/0/0 e QA componente precedente4/4gruppi9/9sottocasi restano le evidenze di codice/rollback/recovery. Questo incarico ha consumato **1apply e1query readonly postflight**,0gioco/provider/browser/recovery/retry. Nessun dato PG, offerta o role letto o modificato dal rilascio. CorpoSQL non duplicato nel resoconto; sorgenti e risposta RAW sono referenziate in RELEASE_RESULT.json.

La recovery già verificata rimane disponibile soltanto con mandato nominativo, se necessaria, e rifiuta drift; non è stata invocata. Nessun DELETE, ripristino dati o riscrittura storico. La risorsa produzione viene rilasciata dopo check delle consegne.

**Limiti:** disponibilità e accesso effettivi sul sito da controllare nello smoke012 separato; Auth/RLS/API non certificati dal banco sintetico. La parità Test Room utenti ancora legacy resta aperta. Il rilascio non dimostra la causa del rifiuto011 né qualifica Assalto; nessun reinvio automatico. Riepiloghi dei cantieri e deposito GitHub restano al PM.
