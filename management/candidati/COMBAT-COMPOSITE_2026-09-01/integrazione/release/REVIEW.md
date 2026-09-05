# PROD-V5-01 · review indipendente limitata

Verdetto: **P0 0 / P1 0 / P2 0 — VERDE STATICO**. 05/09/2026. Primo e unico passaggio indipendente sul pacchetto congelato; nessun finding da correggere.

## Identità e perimetro

Manifest `SHA256SUMS`: `aff24e0281cb8647aea817c89b587b51f0db946b0061000e0032937456711f8b`, verificati **11/11 file**. Runner DB-CORE `QA_GATE_RUNNER.sql`: `cde490890218d47af16751b4b4b9f4a00ed2a0d829b5ba3b483eb1f71d0950a8`.

Esaminati packaging MIGRATION/PREFLIGHT/POSTFLIGHT/ROLLBACK, SEED_ARENA/SEED_DISABLE, delta producer 020 e wrapper 030/031, sequenza e recupero del runner. Nessuna seconda review LAND o Edge e nessuna riapertura del candidato integrato precedente. Il contratto Edge è stato consultato soltanto per confrontare forma delle card e ricevuta V5. Nessuna esecuzione SQL, chiamata provider, fixture dinamica o modifica applicativa effettuata.

## Evidenze statiche

- Il manifest integrato `ab83d353f409d4dfa136e56769566b041b76dcea452af495a0714cef0bf1445e` conserva **30/30** impronte. Estrazione e confronto meccanico dei corpi: **32 → 33 funzioni**, nessuna rimossa; fra le 32 originarie cambiano soltanto `_esame_ciclo_payload` e `_esame_replay_payload`. Unica funzione aggiunta `_esame_payload_v5_complete_v1`.
- PREFLIGHT e POSTFLIGHT sono incorporati integralmente nella migration. Tutti i **33 digest** attesi dal postflight corrispondono ai corpi confezionati. I **18 corpi** del recovery coincidono con i file baseline; i 18 pin del preflight coincidono con i cataloghi baseline per corpo, owner, SECURITY DEFINER, volatilità, configurazione e ACL confrontate come insieme.
- La migration richiede una transazione effettiva prima delle DDL. Le guardie rifiutano esami aperti, helper già presenti e drift sui corpi/metadati attesi. Il recovery richiede quiete e route disabilitate, verifica il candidato installato, ripristina le 18 baseline e conserva 15 helper con accesso soltanto postgres. Non cancella dati né riscrive la history; non promette equivalenza byte-identica del recovery di produzione.
- Il producer costruisce le sette stringhe canoniche da `jutsu`, dichiara il mapping effect/action_type e tiene `limits` fuori dalle card. L'identità Sostituzione è associata alla card. Per gli esiti risolti la timeline a sei campi deriva dall'evento spaziale referenziato e dalle sue versioni, oppure da scambio/posizioni/ancora esatti del ramo legacy. Il ramo legacy dichiara `legacy_server_1d`, senza attestazione 2D; distanza finale non negativa, senza minimo artificiale di tre metri. Nessun nuovo campo anatomico o nuovo requisito di gioco introdotto dal delta.
- Seed separato limitato alla Konoha nominata: 10×10, raggio attori 0,5, spawn PG (2,5) e PNG (7,5), otto ancore ratificate, due slot, un binding e una route. Versione codice verificata dal registro prima del seed; identificazione del binding come contratto Esame dinamico, senza dipendenza da roster Missioni. I blocchi schema-only pertinenti confermano compatibilità delle colonne e dei vincoli usati. La disabilitazione conserva gli oggetti.
- Il runner verifica autorizzazione/target, timeout, zero-state, collisioni nel registro e SHA esatti delle due sorgenti prima dell'installazione. Registra transitoriamente il SQL dopo successo, esegue il seed reale, usa selector/ripiego PNG e difesa realmente offerta, raccoglie ciclo/replay dello stesso `png_esito` per Konoha bound e Suna legacy. I quattro payload vengono esportati senza arricchimenti. Dopo rollback delle fixture al savepoint prova disabilitazione/recovery, quindi rollback totale e confronto catalogo/registro; mantiene il limite concordato alle chiamate sotto test e al tempo. Un errore SQL arresta il run, senza retry automatico.

## Passaggio al PM / DB-CORE

La review statica è verde e consente il passaggio al **gate dinamico già concordato**, dopo preflight fresco e autorizzazioni nominative richieste. Questo referto non certifica compilazione, esecuzione dei due scenari o accettazione dei quattro payload reali da parte della Edge: tali prove spettano al singolo gate DB-CORE, con 48 chiamate/60 secondi DB inclusa recovery, un gate Edge di 10 secondi e zero provider/token. Il precedente verde ab83 non è trasferito al delta PROD-V5-01.

Nessuna produzione, enable, deploy o pubblicazione autorizzata dal referto. Nessuna nuova campagna proposta. L'eventuale controverifica finale prevista dal budget resta unica; in assenza di finding non è richiesta una correzione aggregata.
