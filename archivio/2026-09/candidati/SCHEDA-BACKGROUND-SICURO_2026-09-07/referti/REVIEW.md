# Review indipendente — SCHEDA-BACKGROUND-SICURO-001

07/09/2026 · unico passaggio iniziale · esito **0 P0 / 0 P1 / 1 P2**. Il rilascio resta bloccato fino all’unica correzione aggregata, alla controverifica e alla matrice prevista.

## Perimetro e identificazione

Lettura statica di `candidato/background.js`, `build.py`, `referti/MANIFEST.json` e contratto SCHEDA-BACKGROUND in `dossier/aree/PAGINE.md`. SHA modulo `9bda69b3d5b94257a4d37c37948e5fb968794c18d6ecab610cc577b345882199`; SHA builder `993fe7cade43fbbdc4b1c17cbc8bd02099ec1065dbc6996fc5ca9c698030c02e`, entrambi confrontati con il manifest. Output scheda dichiarato dal manifest `1c1a6aa4abaa5b400f1376389fe2b5c458772f51a4e5bf77bba14763c67f38bd`. La riconciliazione remota MATCH+LF è evidenza fornita dall’owner, non ripetuta dal reviewer.

Nessun browser, DB, provider o test dinamico eseguito dal reviewer. Nessuna scrittura al codice, alla scheda o al dossier. Il codice della dipendenza e la pagina composta non rientravano nel perimetro assegnato; la versione DOMPurify 3.4.15 è quella fissata e attestata dall’owner, non una nuova verifica indipendente di supply chain.

## Finding aggregato

**[P2] Mantenere le immagini nel documento inerte durante la serializzazione** — `candidato/background.js:71–84`.

Dopo il consenso, il renderer assegna `src` alle immagini filtrate (righe 71–75), poi appende il frammento a un contenitore creato con `document.createElement` (riga 84). L’append adotta quei nodi nel documento principale attivo. Le immagini diventano quindi risorse del documento principale prima della serializzazione in `srcdoc`; la CSP e l’origine isolata dell’iframe non governano questo passaggio. `loading=lazy` non costituisce una barriera di sicurezza che sostituisca l’isolamento richiesto. Il difetto è il trasferimento osservabile nel codice fuori dal documento inerte: non dichiaro osservata una richiesta anticipata né un redirect verso altri host, e non riguarda il ramo senza consenso, che sostituisce le immagini con testo.

Correzione minima: creare il contenitore di serializzazione nel documento inerte proprietario del frammento filtrato (`fragment.ownerDocument`), conservando lì le immagini, oppure serializzare gli URL validati senza costruire nodi con `src` nel documento principale. Conservare consenso, allowlist, assenza di referrer, attributo crossorigin e CSP invariati. Il caso rete/CSP già previsto dalla matrice deve documentare il comportamento effettivo, senza aggiungere casi o retry esplorativi.

## Controlli statici senza ulteriori finding

- XSS e CSS: allowlist chiusa di tag/attributi, namespace HTML soltanto, niente eventi, URL attivi, id/name/classi o CSS autore libero. Valori CSS enumerati; rimossi script/style/SVG/MathML e contenuti incorporati. La serializzazione usa solo il frammento già filtrato.
- Isolamento della resa: iframe con sandbox vuoto, nessun permesso script/same-origin, CSP prima del contenuto e fonti esterne vietate salvo le due origini immagini dopo consenso. Non risultano tag autore capaci di introdurre una navigazione o un modulo attivo.
- Prima del consenso: hook elimina ogni src; gli img diventano segnaposto testuale, altri attributi di rete sono fuori allowlist e CSP img-src è none. Zero rete resta da osservare nel browser, inclusa la fase interna del parser.
- URL immagini: solo HTTPS assoluto, due host enumerati, estensioni raster ammesse, niente query/frammenti/credenziali/porte/srcset. Il consenso viene revocato al cambio sorgente, modifica, cambio modalità e passaggio a testo.
- Limiti e conservazione: soglia caratteri prima del parsing; elementi, profondità e immagini prima della resa. Errori con ripiego in textarea readonly; il renderer non riscrive source.value né introduce chiamate di salvataggio. Per Shion gli stili di occultamento vengono eliminati; la resa reale e la completezza del testo spettano al caso Shion della matrice.
- Integrazione: il builder conserva il controllo disabled esistente e collega setEditable allo stesso oEdit in applyMode. Mount una sola volta, anteprima/lettura usano compile comune. La sequenza completa di caricamento e salvataggio della pagina non è certificata dalla sola lettura del builder.
- Build: baseline vincolata con SHA e sostituzioni univoche; salvataggio del candidato separato. Nessuna modifica a DB/contratti o alle funzioni di salvataggio introdotta dal builder.

## Passaggio successivo

Owner: unica correzione aggregata del finding e completamento dei 16 casi già fissati (0 DB / 0 provider / 20 minuti). Reviewer: una sola controverifica finale sulla revisione risultante e sulle evidenze disponibili; nessun nuovo esempio dopo questo referto. Nessuna autorizzazione a pubblicazione, DB, Clan o modifica dei dati di Shion è implicita nel giudizio.
