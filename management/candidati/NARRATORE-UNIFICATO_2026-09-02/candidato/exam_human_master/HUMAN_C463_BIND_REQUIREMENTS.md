# C463: preparazione config-only · template non applicabile

Budget10min/provider0. Nessun apply/sessione/browser/QA. IDsession non disponibile; nessun consumer registrato. HUMAN_C463_BIND_TEMPLATE.sql contiene sentinel failclosed prima di ogni UPDATE e richiede un freeze nuovo, senza riuso C616.

Input dopo prepare normale UI: receipt prepare esatta (request_key, native_session_id, source_sha256, control_version=1), Master assegnato Riuji, q/m/run/prepared/binding coerenti, Staff/stato preparazione/no encounter/no Native optin. Roster solo Riuji/Tamako e protezione Native. Nuova cattura readonly di queste sole proiezioni e PGprotected; nessuna impersonazione Auth.

Controlli necessari: C384enabled, C395prepare/start, C407admission, C412runtime, C444lease, C416kind/catalog e authscope. Template confronta C463/C444/C416 exact; al freeze aggiungere CAS delle altre quattro righe vive e funzione pin loop reale. C463 baseline false con arraysvuoti e timestampnull; acquisire nuova row viva. C463 dopo bind contiene UN Master e UNA sessione.

Pin prima freeze: public.master_v2_lock_scope, combat_consumer_private.staff_test_allowed, public.mission_factory_quest_human_regia_optin_v1 e receipt_v1, c463_optin_identity/journal guard, c395_source_assert, c407_identity/active, c444_enabled, c416_kind_live e guard source pertinentes. Acquisire intero ABI/OID/body/DDL/owner/ACL/config delle firme effettive, schemaCHECK C463. Non limitarsi a hash forniti nel payload. Vincoli/grant restano invariati.

Expiry: C463CHECK impone expires=bound+120min. Usare lease_end=LEAST(C444expires,C416expires), bound=lease_end-120min; questo eredita la finestra Human e NON estende né rinnova C444/C416. La data originaria della finestra non attesta un bind precedente: actualapplytimestamp resta nell'evidenza Root. Nel postflight verificare bound<=now<expiry e expiry<=entrambi controlli. Non impostare now+120 che supererebbe la leaseHuman già iniziata.

Root autentico: mandato corrente/refreview0/0/0/hashauthority/baseline/receipt/assets-version, permit15min e requestdistinta da prepare/optin. Review composizione effettiva dopo ID; nessun apply prima review/preflight. Config-only non crea Nativeoptin: UI esegue poi normale RPC optin con propriaUUIDpersistita e start distinto.

Recovery: exactCAS postimageC463 e ownMaster/session; UPDATE enabled=false soltanto. Conservare arrays/timestamp/review, Nativeoptin, journal, receipt e tutta storia. Nessun bodyrestore o cancellazione. Non modificare C384/395/407/412/444/416, C464/provider/readiness. Reader/replay restano disponibili per ricevute originali. Chiudere solo prova propria normalmente e verificare PG/sessioni nel postflight.

Storia: CFG initialRED→AGG1counter1GREEN→apply1FAIL42883→AGG2counter2GREEN→apply2success16:37:44UTC preservata. Nessuna review/certificazioneC463 nuova dichiarata.
