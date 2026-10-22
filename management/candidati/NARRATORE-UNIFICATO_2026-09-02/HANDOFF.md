# C1266 · Avviso annullamento Staff

**TASK-ID** · C1266-ABORT-NOTICE-20261022.

**Scope toccato** · Pannello abort Generic e pin LAND; sola presentazione.

**Contratti usati/modificati** · staff-simulation-abort-state/1, recovery/1 e journal/1 invariati; opzione client hideUnauthorizedAvailability solo Generic. Nessuna modifica DB/Edge o autorizzazioni.

**Decisioni prese / OPEN** · Conservare prova e incipit, zero annullamenti/provider.

**Prove eseguite e risultato** · C1266 · Avviso annullamento · 22/10/2026: lettura della disponibilità distinta dal recupero di un annullamento pendente. La prova è avviata da Riuji; Tamako non è lo start_actor autorizzato dalla porta abort. Nessuna operazione abort presente. Il consumer Generic nasconde soltanto il diniego esatto 42501/STAFF_ABORT_NOT_AUTHORIZED dopo recupero riuscito e journal senza pending, committed o rejected. Altri errori restano visibili; guardie, permessi, journal, invio e ricevute invariati. Nessun vincolo aggiunto o allentato. Sintassi PASS e review indipendente 0/0/0; client f0c75e5c170abfedd7bc186cfddcef3d47fa2f10, Pages39737422685 riuscito, Chrome Staff senza falso avviso dopo ricarica. Confronto readonly prima/dopo identico: scena in corso, incipit originale conservato nel DB, work, audit, quote e zero annullamenti; zero nuove chiamate provider. La chat era già vuota prima dell’intervento per la finestra di lettura di dodici ore; nessuna rigenerazione o intervento su quel filtro. Nuove role/Director non collaudati.

**Rischi o regressioni da verificare** · Pending/errori qualificati staticamente; nessuna fault injection live. Chat fuori finestra12h osservata prima della correzione; filtro non modificato.

**Passaggio richiesto al PM** · Correzione UI consegnata, prova lasciata aperta. Prove e handoff precedente in candidato/exam_human_master/C1266_ABORT_NOTICE.json.
