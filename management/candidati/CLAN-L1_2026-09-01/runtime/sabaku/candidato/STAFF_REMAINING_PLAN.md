# Seguito Staff Sabaku e architettura IA

Mandato Antonello09/09: continuare il collaudo mentre avanza il contratto IA. Stessa Staff e4f36e1a-afaf-4d30-a06d-f2f17e6ac391, Riuji/testperfunzioni, nessun reset, account o risorse reali modificati. Conservare aperta la scena.

Tre casi al massimo, 35 minuti complessivi dal claim, fino a3 invii principali e3 provider/18000 token osservati, nessun retry per ottenere un tiro positivo. Costo monetario solo se disponibile. Letture/preflight e postflight esclusi dal numero dei casi ma compresi nel tempo. Al primo errore di sicurezza o isolamento fermare i comandi, conservare evidenze.

1. Verificare turno, stato Clone e accesso dei due PG: se nessuna presa attiva, liberazione non eseguibile; non costruire una presa con SQL né ritirare finché positiva.
2. Verificare le offerte reali del turno corrente, passando una sola volta se necessario per arrivare al turno Sabaku. Se movimento PG autonomo resta assente, registrare limite senza sostituirlo con un attacco.
3. Solo se prerequisiti e offerte reali lo consentono, eseguire il caso mancante di movimento Trasporto o liberazione, mantenendo esito nativo. Altrimenti consegnare il blocco concreto e la diagnosi per il successivo lavoro applicativo; niente nuove mosse o estensione ai Flussi in questa campagna.

Snapshot protetto sulle12 superfici dei duePG prima/dopo, audit e ricevute limitati al caso. Un PASS del raccordo precedente non qualifica presa/liberazione. Nessuna modifica codice o DB dipende da questo solo piano. Contratto IA lavora su file disgiunti nel cantiere Narratore, senza toccare il runtime di collaudo.
