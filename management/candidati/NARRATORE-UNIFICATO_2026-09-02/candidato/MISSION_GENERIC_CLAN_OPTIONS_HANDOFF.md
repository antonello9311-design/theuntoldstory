# MISSION_GENERIC_CLAN_OPTIONS · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

Nessun delta al SQL: byte e SHA A1 invariati.

SQL SHA256 `1af3ee0aaf385591b0af05bcb9d112878982f06483b38fcf68d3b355fcd225c4` · 2454 byte. SHA A1 `1af3ee0aaf385591b0af05bcb9d112878982f06483b38fcf68d3b355fcd225c4`. Controlli statici: 4 statement SQL top-level, 0 funzioni PL/pgSQL dirette e 2 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

# MISSION-GENERIC-ROOT-A1 · Common clan offers

Finding MG-SRC-R1-01 corretto con due sostituzioni esatte del solo SELECT di proprietà in clan_hyuga_private.master_control_offers(uuid,bigint) e clan_innata_private.sharingan_master_control_offers(uuid,bigint). Installare dopo PANEL; nessuna dipendenza da ChoiceSources/Dispatch e nessuna modifica ai loro pin.

Auth umano mantiene esattamente controller_user=auth.uid(). Nel ramo service senza Auth è ammesso soltanto il PNG il cui principal per-attore coincide con il permesso vivo della transazione, verificato da current_principal e actor_principal. Nessuna controller identity inventata, nessun allentamento globale o nuova offerta staff. Le altre istruzioni dei due helper restano byte-identiche. Un profilo PNG non supportato dalle specifiche tecniche clan resta escluso dalla rispettiva guardia nativa; vengono mantenute tutte le altre offerte Common, non tagliate le tecniche del PNG.

Fonti vive readonly: bodyMD5 Hyuga7f9bdd705b4bd629401c7315f2ec2bc7 / Sharingan110e2293ac42e3817ae977ccc92e9fe5; funzioni SECURITY DEFINER postgres, search_path vuoto, ACL privata. I sei staff_bind_ready/scopes sono stati letti: AuthNULL restituisce false dai bind; combat_scope dopo contesto registrato respinge actor_kind nonPG con42501, già catturato dagli helper. Non si estende qui il prodotto Clan ai PNG. Gate/risorse/prezzi invariati.

Statica pglast:4statement PASS. Nessun apply, provider o test ricreato. Recovery: ritornare ai due corpi vivi pinned se nessun drift successivo; nessuna tabella nuova né cancellazione di dati.

SHA256 1af3ee0aaf385591b0af05bcb9d112878982f06483b38fcf68d3b355fcd225c4
