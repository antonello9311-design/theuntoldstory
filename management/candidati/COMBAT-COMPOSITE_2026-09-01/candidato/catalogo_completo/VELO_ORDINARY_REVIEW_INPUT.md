# Velo del Cercoterio · compatibilità ordinary Staff R3

La Root attiva R2 è `2bcaf1943d787202406fad30d0a628869df77aae792eaa38d089dea41f393e42`. Il suo writer ordinary imposta `lesiva=true` fuori dall'arena dedicata Shuriken. La policy della Staff è separata da quel flag. L'analisi READ ONLY trova 73 duelli ordinary con i due PG, policy simulata e `values_written=false`, tutti `lesiva=true`. Con la R2, il controllo di ammissione Velo richiede `lesiva IS FALSE` prima di verificare la sorgente. Il referto tecnico della prova ordinaria è conservato nel percorso TEMP accanto alla guida di collaudo.

## Modifica

Il solo cambiamento di comportamento nel sorgente R3 sposta `s.lesiva IS FALSE` nel ramo Master di `clan_innata_combat_private.velo_staff_scope_v1(uuid)`, dove si applicava già. L'ordinary richiede la stessa stanza Staff, il gate privato, la coppia di attori esatta, i controllori noti e la presenza, il contesto nativo e la policy `staff_test_no_persistent_resources_v1`. Restano obbligatori `public.combat_v2_values_written(s.id) IS FALSE` e `combat_panel_private.uses_simulated_pools(s.id) IS TRUE`. Nessun ingresso della Test Room utenti, Master ulteriore o disponibilità pubblica.

Il simulatore ordinary indipendente esige una stanza test attiva, activity registrata e aperta con policy Staff, zero persistenza, due soli attori e due membership native coerenti con le schede e i principal autorizzati. Il writer della transizione Velo usa `is_test=true`, aggiorna lo snapshot e registra zero applicato alla scheda reale. La modifica R3 riguarda l'ammissione entro questa autorità. Il writer ordinary, fonti di risorsa e ledger sono invariati.

## Sigilli e proiezioni

- Tre sostituzioni DDL byte-esatte: scope, E52 e Common. Le ultime due aggiornano i soli riferimenti di integrità al corpo previsto e alle nuove identità. Firma, ownership, ACL, volatilità e configurazione di ogni funzione sono pinzati prima e dopo.
- Root R3 attiva `4aec6254673c4c076d313660659a11a0f0b502d434def8bd7a6e4a5c8776f479` e identità inerte proiettata `02fd262c096ec3c6a611fb0da7a627d0b3006a37fc5006aaa6e781f1e9449016`. Entrambe 523.908 byte. La proiezione READ ONLY verifica anche che tutte le chiavi Root esterne ai venti percorsi nominati conservino gli stessi valori.
- E52 e Common eseguiti in sola lettura sui corpi e Root proiettati in entrambe le modalità. Passano owning 8, shared 34, alias 7, private 66, relazioni 12, trigger 10, native 3, peer 6, joint 75 e compat2. Le 10 funzioni e 4 tabelle Velo sono già presenti e i comparatori leggono l'ABI e gli ACL del catalogo effettivo. In modalità inerte la proiezione rappresenta il gate OFF.
- Recovery operativa riporta l'ordinary al comportamento R2, mantenendo il Velo Master e il gate precedente. La SELECT inversa ripristina i 20 percorsi dichiarati e ottiene gli esatti byte canonici di Root 2bcaf194. Il rollback conserva schema, profili, ricevute, esiti e ammissioni. Le due missioni già qualificate seguono il ramo attivo della Root.
- La sintassi SQL e PL/pgSQL passa per le tre DDL, 11 istruzioni forward e 10 recovery. Il preflight finale vede la prova Master in corso e uno stato Velo attivo. Forward e recovery esigono separatamente zero Combat, zero Master, zero inviti Staff pendenti e zero effetti Velo attivi. Nessun apply R3 e nessun gioco eseguito da questo incarico.

I sorgenti operativi richiedono nuovi referti esatti 0/0/0 prima della materializzazione. Il coordinamento con il ramo Sfera precede una candidata canonica. Se cambia la Root viva, serve una nuova composizione del delta dalla baseline corrente.
