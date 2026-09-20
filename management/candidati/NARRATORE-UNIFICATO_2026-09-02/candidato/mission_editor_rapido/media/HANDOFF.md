# MISSION-RAPID-MEDIA-006 · handoff

TASK-ID · `MISSION-RAPID-MEDIA-006`

Scope toccato · Estensione candidata della stessa Edge `png_media_attest_v1` con un ramo binario `mission-rapid-media/1`, più ticket e registrazione privati nell’installer DB dell’editor. Nessun apply o deploy live.

Contratti usati/modificati · `mission_rapid_media_ticket_v1` lega richiesta, bozza posseduta, `actor_key`, bundle `adopted`, template/versione e impronta file. `mission_rapid_media_register_v1` è service-only e registra una versione Ninja Book in review; l’approvazione continua a usare `nb_admin_media_approve`.

Decisioni prese / OPEN · Il ramo Scorta conserva release, asset, ticket e registratore correnti. I media rapidi usano una tabella separata, quindi non allentano il vincolo delle attestazioni storiche. L’Edge riceve i byte, verifica SHA/MIME/dimensioni, carica senza sovrascrittura e registra. Replay con gli stessi byte riusa ticket/oggetto; un conflitto si ferma. Recovery spegne la policy e revoca le nuove porte senza cancellare oggetti o storico. OPEN: review indipendente e prova reale riservata.

Prove eseguite e risultato · Suite pura prevista 18 casi, zero rete e zero provider. Controlli SQL statici da eseguire sul candidato composto.

Rischi o regressioni da verificare · Compatibilità Deno del parser raster, risposta Storage su oggetto assente/esistente, supersessione tramite `nb_admin_media_approve`, CORS dei nuovi header e replay dopo risposta di rete incerta. Questi casi vanno verificati esclusivamente nella Staff Test Room dopo review e rilascio riservato.

Passaggio richiesto al PM · Integrare adapter Admin, congelare Edge/SQL insieme e controverificare che la branca JSON Scorta sia invariata sul corpus esistente.
