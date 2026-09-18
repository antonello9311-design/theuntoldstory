# Grande sfondamento — collaudo live 1vs1

**Esito:** VERDE funzionale; revisione editoriale e apertura pubblica ancora da approvare/eseguire.

## Perimetro e budget

- Data: 18/09/2026.
- Staff Test Room live, percorso ordinario senza Master.
- Partecipanti autorizzati: testperfunzioni contro Riuji.
- Un caso, una risoluzione IA, nessun retry; tetto fissato a 60 minuti e 2 chiamate provider.
- Sessione: `b120a5b0-8c49-448a-8b9b-6d15442679ec`; motore `combat-v2/2.0.0`, resolver `v11-parity/1`.

## Caso eseguito

testperfunzioni, a 2 m da Riuji, prepara e usa Grande sfondamento selezionando prima dell’invio «spinge se colpisce». Riuji rinuncia alla difesa. Il server risolve un colpo pieno.

## Evidenze

- Selezione server-side: tecnica `d5605069-b381-41ad-8e6a-9c24a314c58f`, bersaglio singolo Riuji, `push_requested=true`.
- Costo simulato: testperfunzioni da 155 a 145 chakra.
- Danno simulato: Riuji da 80 a 49 PV.
- Movimento forzato: applicato, motivo `moved`, distanza 3 m, da `(4,4)` a `(1,4)`; distanza reciproca da 2 a 5 m.
- Nessun costo di movimento volontario e nessun danno da collisione.
- Narrazione pubblicata coerente: la folata raggiunge Riuji al busto e lo allontana di tre metri, senza coinvolgere altro.
- Ricevuta immutabile `other-force/1`: dichiarazione `c07b348b-4416-4a7f-8053-b565e4e6b7af`, evento spaziale `62418340-5ed2-98b1-29b6-4f784985ba8f`.
- Duello chiuso alle 21:04:44 UTC; storico della stanza conservato.
- Schede reali intatte dopo la prova: testperfunzioni 105/105 PV e 155/155 chakra; Riuji 80/80 PV e 105/105 chakra.

## Revisione editoriale proposta

**Descrizione:** Dopo aver composto i sigilli, iniziando dall’Uccello, il ninja libera una forte folata di vento dal palmo, dirigendola verso un solo avversario.

**Effetto:** Su un colpo pieno, la folata può respingere il bersaglio lungo la direzione dell’attacco; ostacoli, dislivelli e terreno possono arrestare lo spostamento.

I valori di portata, danno e costo restano nei rispettivi campi. La regola dettagliata mantiene scelta prima dell’invio, limite di 3 m, nessun effetto su colpo non pieno, nessun danno da collisione e nessuna dispersione automatica degli occultamenti prodotti da tecniche.
