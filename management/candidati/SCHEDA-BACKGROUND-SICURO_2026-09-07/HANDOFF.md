TASK-ID: SCHEDA-BACKGROUND-SICURO-001
Scope toccato: scheda.html, renderer locale con DOMPurify3.4.15 incorporato, dossier PAGINE/PUBBLICAZIONE; nessun DB
Contratti usati/modificati: testo background originale invariato; allowlist HTML/CSS, iframe sandbox/CSP, immagini su consenso Postimages/Imgur senza referrer e CORS anonimo; limiti50k/1000/30/8, ripiego testuale
Decisioni prese / OPEN: intervento separato autorizzato; owner confermato LAND. Nessuna eccezione script autore, nessun datoShion riscritto. In uso da dichiarare soltanto Antonello
Prove eseguite e risultato:16/16r2, sintassiPASS, review0/0/1→aggregata→0/0/0; desktop/mobile390px e details nativi; immagine1280x720 dopo click; GitHub+LF MATCH e smokeShion reale online
Rischi o regressioni da verificare: non pentest completo né certificazioneAuth/DB; JS e layoutCSS originali intenzionalmente esclusi. Futuro candidatoMarionetta deve ribasarsi sulla nuova pagina
Passaggio richiesto al PM: preservare release commit9e5fb5ef359f0c0a11ab2f1ccb10d492b674a0ac buildSCHEDA-BACKGROUND-SICURO-001,277695B,SHA9d2cc64ef2a05093d8ad5c6ea60e498802eaa0a1a3fd1237c2955f7fb23adb90 nel rebaseMarionetta. NessunapplyDB/Clan implicito.
