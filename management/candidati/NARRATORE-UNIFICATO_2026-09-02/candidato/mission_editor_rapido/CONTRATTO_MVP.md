# Editor rapido missioni · contratto MVP

Stato: **proposto per implementazione** · 19/09/2026. Questo documento estende Mission Creation senza sostituirne il contratto `mission-creation-document/1`.

## Risultato osservabile

Da un unico modulo Staff l'editore inserisce trama e indicazioni sulle fasi, poi associa le immagini dei PNG e, se presente, della mappa. Il sistema propone grado, numero partecipanti, fasi, PNG, profili meccanici e condizioni terminali. L'editore corregge tutto, approva i PNG, vede un'anteprima completa e infine usa un solo comando per pubblicare e aprire la missione con il Narratore entro un budget esplicito.

## Fondazioni da riusare

- Mission Creation live: documento completo, salvataggio/revisione atomici, fasi, transizioni, PNG Book, mappe per fase e modalità IA/umana.
- `mission_creation_preflight_v2`: controllo server di capienza e compatibilità prima del salvataggio.
- Mappe generali e default ordinary 10×10: immagine, dimensioni, oggetti, zone e binding di fase.
- Ninja Book / PNG Builder: identità, persona, profilo meccanico, tecniche, conoscenze, media e binding di fase versionati.
- `png_media_attest_v1`: upload e attestazione media; nessun nuovo percorso client diretto verso Storage.
- Runtime Full IA e Narratore missioni: consumano soltanto piano sigillato e fatti server. Il nuovo compilatore non modifica il runtime in corso nella task “Adatta missione per test Full IA”.

## Flusso MVP

1. **Input:** trama obbligatoria; elenco/fasi facoltative ma modificabili; immagini PNG facoltative in ingresso; immagine mappa facoltativa.
2. **Compila bozza:** una sola chiamata IA strutturata propone grado, partecipanti, schieramento, briefing pubblico, retroscena, fasi, obiettivi, transizioni, condizioni, istruzioni Narratore e ruoli PNG.
3. **Risolvi meccanica:** il catalogo server espone soltanto bundle con binding e versione meccanica approvati; l'editor propone per ogni ruolo il precedente con corrispondenza univoca migliore. Statistiche, PV/chakra e tecniche arrivano dalla versione approvata, mai dall'IA; un pareggio resta da scegliere manualmente.
4. **Associa media:** dopo che gli `actor_key` sono stabili, ogni upload viene collegato al relativo riquadro PNG. Un match da nome file può essere proposto, ma un'associazione ambigua resta bloccante finché l'editore la conferma. Niente riconoscimento visivo automatico nell'MVP.
5. **Configura mappa:** con immagine si crea una bozza di mappa generale; senza immagine si usa la default 10×10. Il server verifica capienza e genera posizioni iniziali valide; l'editore indica dimensioni e oggetti importanti e può correggere le posizioni.
6. **Correggi e approva:** ogni campo proposto è modificabile. Ogni PNG richiede approvazione esplicita della propria versione prima dell'uso.
7. **Anteprima obbligatoria:** incipit, sequenza fasi, schede PNG, immagini, mappa con attori, condizioni terminali, budget e lista degli errori. L'anteprima non apre la missione.
8. **Pubblica:** il comando finale ripete la validazione server sulla stessa impronta, sigilla piano e versioni, collega media/mappa/condizioni, prepara recovery, apre la missione e abilita il Narratore con il solo budget mostrato nell'anteprima.

## Documento di bozza

Schema esterno: `mission-rapid-draft/1`.

Campi principali:

- `source`: trama, indicazioni fasi e riferimenti agli upload temporanei;
- `mission`: titolo, grado proposto, team min/max, briefing pubblico, villaggio e modalità;
- `editorial`: retroscena, istruzioni Narratore, incipit e note per fase;
- `phases[]`: chiave, tipo, obiettivo pubblico/privato, transizioni e attori;
- `actors[]`: `actor_key`, tipo, schieramento, identità/persona proposta, archetipo approvato, profilo meccanico risolto, tecniche risolte, conoscenze e limiti, stato di approvazione, media associato;
- `map`: default oppure bozza specifica, dimensioni, oggetti, zona e posizioni;
- `terminal_rules[]`: condizioni configurabili;
- `budget`: chiamate, token e costo massimo del Narratore;
- `control_version`, `source_sha256`, `compiled_sha256` e `preview_seal`.

La bozza non è una missione aperta e non è raggiungibile dai giocatori.

## Condizioni terminali generiche

L'MVP supporta un insieme chiuso e versionato, configurabile per missione senza nuovo SQL:

- `victory` / `defeat` su esito autorevole di uno scontro;
- `surrender_after_exchanges` con soglia intera positiva;
- `escape` per attore o squadra;
- `protect_subject` per PNG oppure oggetto;
- `reach_position` su cella/zona server-side;
- `survive_rounds` con soglia intera positiva.

Ogni regola dichiara fase, soggetto, soglia, esito e transizione. Il server valuta gli eventi; client e IA mostrano soltanto configurazione e risultato.

## API proposte

- `mission_rapid_compile_request_v1(p_request, p_source)` crea/idempotentemente recupera il lavoro di compilazione, senza pubblicare.
- `mission_rapid_compile_state_v1(p_request)` restituisce stato e bozza disponibile allo Staff proprietario.
- `mission_rapid_draft_save_v1(p_draft, p_expected_version, p_document)` salva correzioni e invalida l'anteprima precedente.
- `mission_rapid_preview_v1(p_draft, p_expected_version)` valida e restituisce `mission-rapid-preview/1`, errori strutturati e `preview_seal` solo se verde.
- `mission_rapid_publish_v1(p_draft, p_expected_version, p_preview_seal, p_request)` ricontrolla l'impronta e applica atomicamente la pubblicazione idempotente.

Le funzioni client hanno `GRANT authenticated` e controllo Staff/proprietario; helper, claim worker e resolver restano privati. Le firme definitive dipendono dalla ricognizione della baseline DB viva e non possono duplicare porte equivalenti già presenti.

## Compilatore e PNG

Il compilatore produce solo contenuto editoriale e richieste semantiche. Il server:

- limita grado e team ai valori ammessi;
- propone precedenti approvati per funzione, parole chiave e grado, senza scegliere automaticamente in caso di pari merito;
- legge statistiche e pool dalla versione meccanica approvata del bundle;
- espone soltanto le tecniche presenti nella versione approvata;
- rifiuta riferimenti non risolti anziché inventarli;
- separa identità pubblica, conoscenze private, limiti di rivelazione e comportamento;
- congela le versioni approvate usate dalla missione.

## Anteprima e pubblicazione

L'anteprima è obbligatoria e firmata sulla stessa versione di bozza, cataloghi, media, mappa e budget. Ogni modifica successiva invalida il sigillo. Il pulsante finale esegue un solo comando UI ma il server mantiene distinte le responsabilità: ricontrollo, sigillo, creazione/revisione, binding, recovery, apertura e admission del Narratore. Un errore lascia la bozza correggibile e non apre parzialmente la missione.

## Non obiettivi MVP

- generazione automatica di immagini o mappe;
- scontorno e doppio asset ritratto/sagoma;
- apprendimento automatico dalle nuove approvazioni;
- riconoscimento visivo per indovinare il PNG;
- modifica del comportamento runtime Full IA attualmente in lavorazione nell'altra task.

## Gate di composizione con “Adatta missione”

Prima di integrare DB condiviso, Edge runtime, `land.html`, asset Mission Creation o documenti centrali si devono rileggere task guard e consegna della task `MISSION-ROLE-WINDOW-PROMPT-20260919`, annotare versione/hash finali e ricomporre il delta sulla nuova baseline. È vietato copiare una versione precedente o aggiornare soltanto i pin. Il compilatore usa una Edge separata (`mission_authoring_ai`) e un modulo UI isolato finché il contratto condiviso non è verificato.

## Criteri di accettazione MVP

- Una trama con tre PNG e quattro/cinque fasi produce una bozza modificabile con riferimenti risolti, senza valori meccanici inventati dall'IA.
- Con immagini PNG e mappa, tutti i binding sono espliciti e visibili; senza mappa viene usata la default 10×10.
- Le sei famiglie di condizioni terminali sono configurabili da UI e validate dal server.
- Una mappa incapiente, una tecnica non supportata, un'immagine ambigua, un PNG non approvato o un budget assente impediscono il sigillo.
- L'anteprima verde corrisponde byte-logicamente a ciò che viene pubblicato; il replay dello stesso comando è idempotente.
- Il percorso protetto mostra missione, PNG, immagini, mappa e Narratore; recovery e postflight lasciano risorse PG e sessioni estranee invariate.
