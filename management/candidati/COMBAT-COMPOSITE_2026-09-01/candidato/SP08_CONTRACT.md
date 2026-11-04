# SP08 — probe facoltativo Rotazione su profilo Staff incompatibile

TASK-ID INNATA-SP08-SOURCE-20261104 · COMBAT-INNATA-SP08-SOURCE. MandatoPM04/11 e tecniche10/09, ripresautente corrente; nessun ampliamento a tutte le Innate in questa correzione.

Difetto reale: ordinary81c3506e, attaccoTamako request1d18aeed del10:55:31.255, SQLSTATE42501 BYAKUGAN_NOT_OWNED. rotation_attack_power_freeze(d.target_actor_id) interroga il TARGETRiuji, profiloByakuL2, mediante rotation_profile che legge hardcoded lo statoL1. Lo scope esplicito rifiuta correttamente L1 non scelto; è il probe facoltativo a dover restituire nessun profilo. Non è un errore di presenza o il40001 di pollingHuman preesistente.

Delta: solo clan_hyuga_private.rotation_profile(p_actor uuid) RETURNS jsonb, STABLE SECURITY DEFINER search_path='', ownerpostgres/ACLpostgres invariati. Producer: rotation_profile; consumerimmutati rotation_attack_power_freeze e gli altri caller esistenti. byakugan_scope_v1(uuid,uuid), combat_scope/state_read, attivazioni esplicite, prezzi, gate, UI e autorità rimangono invariati.

Condizione del nuovo ramo: scopeis_test già ottenuto dal guard nativo, rotationGateStaff abilitato; sessione dell'attore presente e aperta nella solaStaff0b85f354-9cdb-47e1-baf9-3d266bb7e06b, nessunvalore reale scritto; staff_profile_actor_v1 restituisce il profilo realmente associato all'attore/controller/materializzazione e autorizzato dal server. Se la tecnica scelta è diversa dalByakuganL1 richiesto da questo consumerlegacy, ritorna SQLNULL. Nessuna inferenza da nome/clan/categoria e nessun catch generico di42501. Un profilo selezionatoL2/3/4 non autorizza di riflesso Rotazione o altri bonus. Se manca il profilo protetto o siamo World/nonStaff, il vecchio codice continua byte-identico. Le richieste esplicite Innata invalide continuano a rifiutare nello scope originale.

Nessuna modifica di regola/costo, tabella/CHECK/trigger/GRANT/gate. OID51293 attualmente non tracciato nei91header; va aggiunto un header completo (totale92). Nessun trigger usa direttamente questo helper JSONB; nessun fingerprint relazionale cambia. Questi impatti vengono verificati nella composizioneRoot, senza supposizione di reinstallare91funzioni.

Recoveryconservativa: stesso helper, solo inStaffproof esistente, sospende tutti i probeRotazione dei profili simulati restituendoNULL. Worldlegacy e richiesteInnateesplicite restano invariati; OFF/cleanup e saldi restano disponibili. Il SQL sorgente ha sentinella e richiede un nuovo cutoverforward dalla Rootviva corrente, mai vecchiRoot/corpi/dati o refills.

Evidenze preservate: carryL2ON65 attivazione0; primoownturnTamako, nessun upkeepRiuji dovuto. Attaccofallito/nessunadifesa; OFF98ef0c37 costo0 e chiusura10:56:49.080148;65/55,PG3Scorta intatti.52comandi/6scene/0provider; primaDifesaL2 e regressioneSP07upkeep NONPROVATE. FatiSharingan precedenti HumanMaster manuali, NarratoreCombat NOT_RUN.

Gate: SourceReview0/0/0, poi candidata integrataRoot569a91→nuova92 con source/UIconfig/recovery coerenti, reviewmateriale0/0/0, preflightvivo e applyStaff autorizzata. Nessunapply da questo SourceTask. DeadlineQA12:18:45Z non cambia; preparazione può proseguire dopo, gameplay no.
