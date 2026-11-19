# Cure+UI — review indipendente R1

Esito **0/1/0**: un solo P1 concreto di installazione. Review completa pertinente della composizione congelata B `9c34c8940513bab1fd5e44352b86eb1c6a20f5263ecadf2845af4448cd9efbe5`; nessuna patch eseguita.

**CURE-ENTRY-P1-001 — schema capsule forward incompatibile.** `CURE_ENTRY_SOURCE.sql:7` richiede `cure-neutral-parameters/1`, mentre N, finalizer e footer richiedono `cure-entry-parameters/1` sullo stesso `app.cure_entry_parameters`. Con P=N+review e i due pin sostituiti il primo DO solleva `cure_reaction_parameters_required` prima delle patch. Cambiare solo N non risolve: il footer richiederebbe ancora l’altro valore. Occorre allineare il preflight nella derivazione owning, rigenerare l’aggregata e i digest dipendenti, preservando tutte le guardie. Non è stato tentato un apply.

Tre casi statici completati:

1. Custodia Root79/raw522857, cinque before/after con replay e inversa esatti, MD5 prosrc/SHA DDL, AST ABI invariati, parse dei cinque corpi; UIR2 verde preservata nel suo perimetro.
2. Autorità delle offerte/replay/selector e proiezione UI esatta, derivazione SOURCE/RECOVERY, SQL/DO PLpgSQL, DAG N/R1/P/F/E. Il caso rileva il P1 sopra; gli altri controlli pertinenti non aggiungono finding. N pgSHA `90860a136465d514defe990f946766da84a2512a4b645701568c44de3e50b0cf`.
3. Carryforward delle qualifiche esistenti, due admission e party true/true; peer5/native3 e recovery conservativa. Capacità ricomputata: forward522207 B, recovery522329 B; margini2081/1959. Cap e roundtrip restano bloccanti, nessuna Root futura inventata.

La recovery conserva cinque fix e UI attuale, spegne Cure e genera Root forward dopo chiusura/assestamento nativi. Nessun DELETE, riscrittura storico o vecchio body ripristinato. Auth/RLS/Realtime e gameplay restano limiti empirici da provare nella sola Staff protetta; nessun PASS gameplay o client pubblicato attestato.

Cinque canonici ricontrollati immutati. DB/SELECT metadata/browser/Git/provider/gameplay e scritture canoniche: tutti zero. Nessun P/F/E verde prodotto con questo R1 rosso. La ricevuta rawfile esterna lega i digest di questo referto senza autoriferimenti.
