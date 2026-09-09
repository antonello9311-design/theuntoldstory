# TASK-PM-AVVIO-001 · Blocco1: avvio uniforme e skill

Stato incarico: consegna locale verificata; deposito GitHub bloccato dal Mac · 09/09/2026 · owner PM, tooling delegato avvio_guard, reviewer indipendente avvio_review. Mandato: «Ok puoi procedere con il blocco 1», integrato dalla richiesta di allineamento delle skill. Solo processo, documenti e strumenti locali; nessun nuovo mandato applicativo.

## Scope toccato

AGENTS e ingressi del dossier; procedura e modello di avvio; coda PM; registro cooperativo, suite di verifica e sincronizzatore; otto sorgenti skill e le rispettive copie installate sul Mac. Inventario esatto con impronte in dossier/aree/PUBBLICAZIONE.md. CLAUDE.md già importa AGENTS e rimane invariato. Nessun quarto cantiere: incarico di solo coordinamento negli spazi esistenti.

## Contratti usati / modificati

AGENTS v3 è l'ingresso; AVVIO_LAVORO è la procedura; JSON di incarico con owner, scope, dipendenze, priorità, criteri, mandato e budget. Registro SQLite locale alla root canonica, non condivisibile copiandolo fra dispositivi. File esatti e contratti in lettura; un integratore per i riepiloghi comuni. Bootstrap dei soli strumenti del guard assegnato all'owner tooling esclusivo; integrazione documentale tramite guard dopo verifica.

## Decisioni prese / OPEN

Le vecchie task restano archiviate; i cinque monitor restano sospesi e l'anti-stop Mac è distinto. Nessuna ripresa automatica del backlog o del ciclo Clan terminale rosso. Massimo tre cantieri documentali invariato. Modifiche applicative, DB, Edge, enable, provider e apertura pubblica mantengono i gate nominativi esistenti. Il deposito GitHub del metodo è coperto dal mandato; nessun deposito cumulativo di sorgenti Clan.

Sorgenti delle otto skill in management/coordination/skills; copie locali del plugin allineate dopo review: 8/8 confronto byte per byte positivo, versioni precedenti conservate nel runtime. Esterni claude.ai/Cowork e altre macchine non verificati; istruzioni da sincronizzare in dossier/06_ISTRUZIONI_PROGETTO.md. Nessuna modifica a modello, permessi o impostazioni globali. Un aggiornamento del plugin può ripristinare la cache; sync_skills rileva differenze.

## Prove eseguite e risultato

Review iniziale unica: 0 P0 / 2 P1 / 2 P2. Finding: sospensione impossibile dopo drift, CRLF rifiutato dal sincronizzatore, YAML gdr-verifica non valido, preferenza browser persa nella deduplicazione. Unica correzione aggregata completata; controverifica finale indipendente 0 P0 / 0 P1 / 0 P2. I quattro scenari a tavolino (UI semplice, frontend/backend, documenti, ripresa archiviata) sono coerenti; non sono un collaudo del gioco.

Guard: 24 casi iniziali PASS, anche nell'esecuzione indipendente (0,281s); tre regressioni mirate al recupero del drift: 27/27 PASS, anche nella controverifica indipendente (0,311s). Sincronizzatore: sette verifiche PASS sulle copie delle otto skill reali, inclusi CRLF, rifiuto del drift senza mutazioni, confronto byte per byte, backup e idempotenza. Frontmatter delle otto skill PASS con Ruby/Psych YAML dopo correzione; il validatore Python di Skill Creator non è eseguibile perché PyYAML manca anche nel runtime disponibile. Non equivale a una prova di caricamento dentro Claude esterno.

Budget del controllo: suite iniziale24 + massimo3 regressioni del finding; sette verifiche sync; quattro scenari a tavolino; un passaggio review e una sola controverifica; zero prove DB e zero chiamate provider di gioco. Consumo token degli agenti non misurato come telemetria provider del prodotto. Test solo su cartelle temporanee e copie autorizzate.

## Rischi o regressioni da verificare

Il guard coordina chi lo usa: non blocca editor o app esterne, non autentica l'owner, non certifica review/consenso, non misura né interrompe budget. Un contratto cambiato dopo la registrazione richiede riconciliazione e nuovo ID. Una consegna del registro non promuove il prodotto a «in uso». I backup e lo storico restano locali nel runtime escluso dalla pubblicazione.

GitHub main riconciliato a23263a942da3760234da1f562a2c33aa7f1675bc: variazioni locali AGENTS corrispondono alle decisioni approvate 06–09/09; indice/tabellone/registro includono chiusure finali già consegnate. Nessun avanzamento remoto trovato. Caricamento al momento bloccato: connettore write già403 nella sessione; il canale alternativo Chrome ha restituito «Mac locked, automatic unlock could not unlock it». Nessun tentativo di aggiramento. Asset del sito invariati, verifica dominio non pertinente a questo deposito documentale.

## Passaggio richiesto al PM

Controverifica0/0/0 acquisita; 26 output integrati tramite guard, due strumenti del guard consegnati dall’owner del bootstrap. Registro reale: status iniziale senza runtime, register e claim riusciti, apply e check puliti. Otto skill installate e controllo finale8/8; confronto dei backup con le copie iniziali positivo. L’evento release del registro attesta la liberazione finale delle prenotazioni: consultare status, senza riaprire la task archiviata per ricostruirlo.

Restano da caricare esclusivamente i28file elencati in PUBBLICAZIONE, una volta sbloccato il Mac e riconciliata nuovamente main. Nessun nuovo consenso al deposito richiesto: è già autorizzato. Stato esterno Claude non verificato; dossier/06 contiene il testo pronto. Alla prossima idea di Antonello usare l’ingresso unico. Nessun riavvio delle task archiviate richiesto.

Storico: 09/09/2026 · v1 · metodo e otto skill allineati, 27prove guard e7verifiche sync positive, review finale0/0/0 · installazione locale verificata; GitHub in attesa dello sblocco del Mac.
