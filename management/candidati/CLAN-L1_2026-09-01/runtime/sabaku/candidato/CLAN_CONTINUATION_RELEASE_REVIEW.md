# CLAN-RACCORDO-RELEASE-REVIEW-001 · consegnato

**VERDETTO EFFETTIVO: 0 P0 / 0 P1 / 0 P2 — VERDE per il pacchetto recovery e piano di rilascio esaminato.**

Unico passaggio indipendente iniziale, 09/09/2026, owner QA-REVIEW. Nessuna correzione richiesta. Questo referto non riapre la qualifica del raccordo e non autorizza autonomamente apply, recovery, chiamate provider o apertura agli utenti.

## Scope e integrità

Esaminati esclusivamente RELEASE_PLAN, RECOVERY, RELEASE_PREFLIGHT, RECOVERY_QA e RELEASE_MANIFEST, con confronto alle baseline e alle evidenze congelate pertinenti. Il manifesto owner ha SHA-256 `e7fe59f8580b4abfb995fe1f7463fd3cd2e3da89b6d66798950852543843098d`; verificati byte e SHA di tutti i suoi 13 riferimenti, 13/13 corrispondenti. INSTALL resta `9dc6fa7fd2f0520e9e3779a600d90587d2151d389ae00a839f85bec0b6619089`; RECOVERY resta `a0c601c604b17e78964595a99041bfa5a6205132c2814775052f205e4504b85b`.

Review statica e controllo locale delle impronte: **0 SQL eseguiti, 0 provider, 0 browser, nessun nuovo caso o modifica al candidato**. I precedenti cicli terminali, compreso quello rosso, restano immutati; il raccordo già qualificato mantiene la propria copertura e i propri limiti.

## Risultati verificati

1. **Preflight coerente:** i nove hash delle funzioni esistenti coincidono con le baseline congelate; coincidono anche gli ACL dove presenti nelle baseline. La decima voce attesta l'assenza della nuova helper. Owner postgres, SECURITY DEFINER, search_path vuoto e ACL privati sono espliciti. La fotografia non sostituisce il confronto immediatamente prima dell'apply.
2. **Recovery circoscritta e verificabile:** richiede le tre definizioni della candidata, i relativi ACL privati e owner attesi prima della sostituzione; ripristina i due corpi precedenti, riscontrati anche come testo esatto nelle baseline. Controlla gli hash ripristinati prima del COMMIT. Timeout e transazione rendono un errore un arresto del ripristino, senza autorizzare bypass delle guardie.
3. **Helper residua dichiarata:** resta privata e restituisce sempre false, anche per NULL. Non viene eliminata e non vengono cancellati dati, audit o storico. La sua permanenza impedisce intenzionalmente il riuso dell'INSTALL originaria, che richiede assenza: un eventuale rilascio successivo necessita un intervento distinto approvato, senza DROP o aggiramenti.
4. **Prova di persistenza pertinente:** RECOVERY_QA documenta quattro invii Docker e tre invii readonly di produzione, entro il budget, senza provider. La copia sintetica riceve install COMMIT e recovery COMMIT; una nuova connessione conferma i due corpi/ACL/owner precedenti, la helper inerte e il confronto delle funzioni esistenti. Il database sorgente è invariato. Le impronte di personaggi e storico e le nove sessioni chiuse sono uguali; il referto non pretende una fotografia di ogni tabella né una prova di gameplay.
5. **Effetti non reversibili descritti correttamente:** il ripristino del codice non annulla richieste HTTP già partite, elaborazioni in corso o messaggi già prodotti. Audit e richieste eventualmente in volo richiedono verifica separata del PM e restano conservati. Il piano non presenta il recovery come annullamento della storia.

## Rischi di integrazione e gate operativi

Il delta mantiene le porte Auth, le policy RLS e il servizio Edge esistenti, senza cambiare ruoli, grant pubblici, flag o schema delle cinque tabelle osservate. RLS abilitata non dimostra la correttezza di tutte le policy: questo limite è esplicito. La prova Docker qualifica i corpi PostgreSQL e il recovery; non certifica identità Supabase reali, chiamata Edge/provider, resa narrativa o interfaccia. È coerente riservare questi aspetti al singolo smoke reale isolato già previsto, senza imporre un branch temporaneo per un rischio aggiuntivo non dimostrato nel delta. Un difetto concreto di accesso o isolamento deve fermare la prova, senza ripristinare a posteriori risorse reali come sostituto della protezione.

La fotografia mostra tutti e quattro i gate runtime accesi: **l'apply non è inerte** e può rendere eleggibili utility già in attesa. Il piano richiede opportunamente il nuovo confronto delle nove dipendenze, helper assente, runtime e inventario dei report prima del singolo apply. Questi sono gate di esecuzione, non finding mancanti di questo pacchetto. Il PM ha inoltre comunicato preflight immediato alle 15:36:51 UTC con dipendenze/ACL identiche, helper assente e zero report ordinary in attesa, e baseline delle dodici superfici protette alle 15:37:49 UTC: tale comunicazione resta evidenza del PM da registrare nel suo passaggio operativo, non SQL rieseguito dal reviewer.

Il PM deve mantenere nominati il singolo apply, il possibile recovery e il collaudo Clone/Fato protetto nel mandato di Antonello, con budget provider esplicito, nessuna vittoria della presa richiesta e nessun retry esplorativo. Dopo l'apply servono le impronte effettive delle tre funzioni e il controllo di ACL; dopo il collaudo, audit, chiusura della sola prova creata salvo mandato contrario e confronto delle risorse protette. Nessun cambiamento implicito di flag o apertura generale. La disponibilità nelle due Test Room va descritta entro i rispettivi permessi: la copertura utility Staff non certifica una funzione equivalente per gli utenti.

## Passaggio al PM

Il pacchetto recovery/piano può superare il proprio gate di review con **0/0/0**. Restano i passaggi operativi sopra previsti dal piano e le loro evidenze effettive; questo verde non è uno smoke live né una dichiarazione di prodotto in uso. Nessuna modifica necessaria ai cinque file congelati; nessuna nuova campagna richiesta da questa review.
