# MISSION-RAPID-INTEGRATE-007 · composizione candidata

Stato: **candidata review10 aggiornata e congelata per sesta controreview autorizzata**, nessun apply/deploy/pubblicazione riuscito.

## Baseline verificata

- `sito_live/admin.html`: 417747 byte, SHA-256 `795d6cfd91b82ecfa148917ee5c61d108f2d838a0c0aea0c97c5a838cbb6821c`, uguale alla riga pubblicata del 17/09 e al file remoto `main` osservato prima della composizione.
- “Adatta missioni”: `mission_generic_ai` v27, build `mission-generic-ai/2026-09-19.role-window.1`; runtime source SHA-256 `0ec463c380faa507afd6d0719e31b476be210dbb14507fa610e01896415d8e35`; dispatch claim MD5 `bfe01f0affcd68bb34f3301318b304a1`.
- Porte Mission Creation e board pin: preflight MD5 `2bfa56c88e45c52eb4495ee1f7c5d870`, create MD5 `8a512021ec0335f6eddb8b859607b056`, board open MD5 `7efaab206f6b8f1fab92b72c848d5d72`.
- Punto d'innesto Mission Generic verificato sulla definizione viva di `progress_step`: MD5 `0bc40e0ff963c26a63e218f2aa95dd94`.

## Composizione

- Nuovo pannello Admin “Nuova missione rapida”, nascosto a Master e giocatori.
- Asset ESM isolato con input trama/fasi, compilazione riprendibile, correzioni, bundle PNG adottati, immagini attestate, mappa, condizioni, anteprima e publish unico.
- La creazione della coda invoca `mission_authoring_ai` una sola volta; un esito di rete incerto viene riconciliato sulla stessa request senza seconda chiamata provider.
- Upload PNG: stessa Edge `png_media_attest_v1`, ramo nuovo separato; file legato a ticket server per bozza, attore e bundle, poi approvato con `nb_admin_media_approve`.
- Mappa: riuso di `MAPPE_UI_PICKER.asset.v3.mjs` e `mission-map-upload`; nessun secondo uploader.
- Ogni mappa viene riletta dalla porta server sulla key/versione esatta; la preview richiede stato `ready`, selezionabilità, spec identica, geometria valida e capienza sufficiente prima di sigillare.
- Budget: letto dal catalogo runtime server; nessun numero fissato nel client.
- PNG: il compilatore propone lo schieramento; il catalogo ammette solo bundle adottati con binding e versione meccanica approvati. L'editor propone un precedente solo con miglior punteggio univoco e mostra grado, PV, chakra e tecniche; l'editore può correggere e deve approvare.
- Le condizioni terminali non accettano fatti dal client: il consumer privato legge round narrati, attori, oggetti e movimenti nativi, emette un evento Combat completato, chiude l'incontro dalla porta Generic e applica una sola transizione autorevole. Nell'MVP è ammessa al massimo una condizione nativa non standard per fase; vittoria e sconfitta restano gestite dal terminale Generic.
- La sola composizione con “Adatta missioni” è un hook minimo in `progress_step`, ammesso esclusivamente sulla definizione viva pinndata. L'anchor include integralmente la guardia `unified_batches` corrente, così i batch in preparazione continuano a non essere trattati come narrazione pendente. La prima guardia rapida restituisce `null` per ogni missione priva di regole rapide attive, quindi il percorso esistente resta invariato. La recovery conserva e ripristina la definizione precedente solo senza drift.
- Il blocco JS Media Scorta è byte-identico alla baseline.

## Verifiche

- UI pura: 51/51 PASS.
- Compilatore: 35/35 PASS, inclusi schieramento, CORS e unicità della condizione nativa per fase.
- Media: 18/18 PASS.
- Integrazione Admin: 28/28 PASS.
- Contratti statici integrati: 22/22 PASS, compresi consumer nativo, pin mappa/capienza, unicità terminale, soglia intera, identità JSON attori scena/incontro, forma SQL dei confronti `IS DISTINCT FROM (CASE ...)`, uguaglianza sorgente/asset UI, hash dell'evento, pin dell'hook, anchor `unified_batches` identico in install/recovery e recovery anti-drift.
- Script inline: tutti i blocchi passano `node --check`.
- Markup: `div 409/409`, `section 38/38`, `ul 2/2`, `li 2/2`, `p 143/143`.
- SQL statico: JSON valido, transazione unica, dollar tag bilanciati, grant espliciti, nessun `DELETE`, `DROP` o `TRUNCATE`.
- Totale: 154/154 PASS. Zero chiamate provider, zero mutazioni live della review10, zero Docker. Il primo apply live review8 è fallito atomicamente in parsing; il secondo apply review9 è fallito atomicamente sull'anchor obsoleto. Dopo entrambi, schema rapido e hook sono rimasti assenti.

## Gate successivo

Sesta controreview indipendente eccezionalmente autorizzata dall'utente. Solo con P0/P1/P2 = 0/0/0: nuovo checkpoint readonly della versione viva, apply DB riservato, deploy delle due Edge, pubblicazione asset/Admin e collaudo esclusivo nella Staff Test Room protetta con massimo quattro chiamate provider e postflight su risorse/sessioni.
