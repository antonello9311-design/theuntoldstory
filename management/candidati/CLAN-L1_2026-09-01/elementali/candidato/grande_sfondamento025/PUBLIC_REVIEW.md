# PUBLIC_REVIEW — Grande sfondamento 025

**Esito finale indipendente:** VERDE · P0/P1/P2 = **0/0/0**  
**Revisore:** /root/review_grande_public025 · 18/09/2026  
**Modalità:** sola lettura; nessun apply o modifica eseguiti dal revisore.

## Revisioni esaminate

- PUBLIC_INSTALL.sql SHA-256 29073a1de36b14e9ba4218bb64c40365c470a351b83218791ba36dca0b1f3111
- PUBLIC_RECOVERY.sql SHA-256 c920e2f37765f9fb93a1f7c41b2fcc5843fb467ebf8f7d951a8cde0e7ee7a649
- QA_LIVE.md SHA-256 eb91df5d11a4ca26ea8a3521a7a5fad09131073c4f463ae15f58b205cff2cc5b
- REGOLE.md SHA-256 e21f8de101cf71d1c80ecfb052f18b4dbc4a14f21252de5f24d8c9a020e2c603
- regole.html SHA-256 0b1deb2da8027bcfffe2a300932f0881b5a8728442c08b1b0e038c9c1888000e

## Controlli e risultato

1. Transazione unica con pin prima delle mutazioni e assert prima del commit: PASS.
2. Pin coerenti con la baseline viva successiva a Suiton 024: PASS.
3. Composizione di Scudo, Suiton e nuovo ramo other, incluse le fonti già sigillate: PASS.
4. Apertura circoscritta a Grande sfondamento tramite enabled + public_enabled; eligibility, possesso, snapshot e percorsi PG/PNG preservati: PASS.
5. Normalizzazione del solo marker runtime_public_admitted nel confronto del profilo: PASS.
6. Aggiornamento dei soli due pin other in eligibility_release_assert e riesecuzione dell’assert: PASS.
7. Owner postgres, SECURITY DEFINER, search_path vuoto e ACL postgres-only conservati; nessun endpoint o GRANT client nuovo: PASS.
8. Vincolo nuovo esplicito public_enabled implica enabled; nessun vincolo allentato: PASS.
9. Catalogo: pin di costo 10, danno base 20, grado C, Genin, Vento, gittata media e attività; modifica limitata a descrizione, effetto, durata e requisiti Ninjutsu 40: PASS.
10. Recovery transazionale e conservativa, limitata allo spegnimento del gate pubblico della tecnica: PASS.
11. QA ordinary 1vs1: scelta preventiva, colpo pieno, costo 10, danno osservato 31, spinta 3 m, collisione 0, ricevuta immutabile, sessione chiusa e risorse reali invariate: PASS.
12. Sincronizzazione editoriale SQL/Markdown/HTML e bilanciamento tag HTML: PASS.

## Controverifica dopo preflight

Il primo apply è stato annullato integralmente dal preflight con errore 42703: il pin usava il nome logico inesistente element. È stata corretta una sola riga con il confronto vivo req_elements=ARRAY['Vento']::text[]. Il revisore ha ricostruito il diff byte per byte e confermato il nuovo SHA; controverifica VERDE 0/0/0. Nessuna migrazione è stata registrata dal tentativo fallito.

## Limite e postflight richiesto

La review è statica. Dopo l’apply vanno riletti migrazione, hash, colonna e CHECK, gate, catalogo, owner/ACL/search_path e va rieseguito eligibility_release_assert. Il QA allegato certifica il caso ordinary 1vs1; non ricertifica il percorso Master, il cui adapter e la cui meccanica non sono modificati da questo rilascio.
