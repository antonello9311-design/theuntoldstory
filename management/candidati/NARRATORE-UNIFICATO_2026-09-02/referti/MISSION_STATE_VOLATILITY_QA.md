# STATE-VOLATILITY001 — QA

Budget3gruppi/0provider/15min. PostgreSQL17.6 locale reale tus_night_projection_001; fixture sintetica, zero dati di Tamakoimportati. Prima esecuzione3/3PASS.

1. Medesima chiamata STABLE in transazioneREADONLY riproduceSQLSTATE25006.
2. RPC dichiarataVOLATILE e transazione scrivibile: stato restituito con prova corretta, impronta scheda invariata.
3. Authassente rifiutata, corpoMD5a2f88dc113ee44b9078e09a580153bce eACLpostgres/service_role/authenticated invariati.

La fixture locale è chiusa tramite esame_session_close a fine run, protectedtrue/closedtrue. Nessun provider o nuova chiamata sul sito. Non certifica PostgREST reale: il riscontro necessario segue il singoloapply dalla pagina di Tamako già autenticata in Firefox. Candidata ridotta ad ALTERFUNCTIONVOLATILE e NOTIFYreloadschema;nessun nuovoGRANT o corpo SQL.
