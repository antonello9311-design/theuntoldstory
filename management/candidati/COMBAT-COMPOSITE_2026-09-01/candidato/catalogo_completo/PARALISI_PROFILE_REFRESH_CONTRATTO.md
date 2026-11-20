# Paralisi: fingerprint della preparazione Staff

Source componente, non installer autonomo. TASK-ID COMBAT-CATALOGO-PARALISI-PROFILE-REFRESH-SOURCE-20261120. B `9c9c84ddb2fcc037b0b2164877d296c72a99529b86f3dfcaf59e5c62d4cb65c3`.

La preparazione osservata nel Combatc0425452 è riuscita ma ha lasciato le offerte della versione2. La diagnosi indipendente `0f26d36a5a49ef633fba055d65d242b6aa1bc416248f1ce8dc8f3faa151e375c` individua la ricevuta Genjutsu assente dal fingerprint Master. Il producer staff_bind modifica abilities/ricevuta senza principale o costi; master_options riusa le offerte correnti.

Un solo hunk nel corpo vivo master_projection(uuid,uuid) aggiunge al fingerprint interno la sola SHA di una ricevuta Staff valida per attore/sessione/controller/versione. Riusa binding esistente, scope simulato/Staff e medesimo refresh_context: nessun nuovo campo esposto al viewer, nessun cambiamento a Auth, offerte, regole, statistiche o azioni. In assenza di ricevuta il contributo è l'oggetto vuoto, identità per concatenazione; i contesti estranei conservano il fingerprint.

Header, firma, owner/ACL/SECDEF/search_path restano esatti. Nessuna funzione, tabella, colonna, constraint o GRANT nuovo. Tre casi statici verdi e grammatica SQL/PLPGSQL integrale; nessuna fixture/DB locale/gameplay/provider.

OPEN prima dell'apply: review indipendente e una Root corrente composta con il ContactSource, alias storici riconciliati, helper/pin pertinenti e recovery conservativa. Il corpo baseline owning78a5798b è più recente degli alias storici136d5f7f nel Root: non ripristinare corpi vecchi né limitarsi a cambiare pin. Il PM aggiorna i soli alias e la prova della versione integrata dopo composizione. Il componente bare fallisce al postflight senza PM seal.

Recovery forward lascia corpo/ricevute/report e spegne solo gateParalisi Staff/public; richiede Root/config OFF sigillati nello stesso installer. Non è stata eseguita né qualificata. Runtime attacco/resistenza/effetto/Kai ancoraNOT_RUN; pubblicoOFF. Nessun nuovo PASS ricavato dalla preparazione o dalla sola sintassi.

## Normalizzazione e identita riproducibile

Il marker originario dei due template è il literal `SOURCE_B_FROM_NORMALIZATION`, non64zeri. Sostituire l’unica occorrenza del B finale in SOURCE.sql e RECOVERY.sql con quel literal, senza altre modifiche: sha256 dei byteUTF8/LF riproduce i due normalized_*_template_sha256 nell’identity. Nessuna normalizzazioneUnicode. Poi B=sha256(UTF8(json.dumps(identity,ensure_ascii=False,sort_keys=True,separators=(",",":")))). Gli hash dei template sono calcolati prima dell’inserimento di B; l’identity resta immutata. R1ac727bcf e correzione PPR-P2-001 sono conservati integralmente nell’Audit. SQL/recovery/corpi/B sono byteidentici.

La recovery componente spegne il gate condiviso combat_v2_genjutsu_internal.gate, non un flag isolato per tecnica: il PM deve elencarne tutti i consumer pertinenti e integrare quiescenza, lockRoot e sealconfigOFF. Questo non è un installer o una recovery globale già qualificata.
