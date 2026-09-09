# 00 · LEGGIMI — porta d'ingresso al progetto

> Allineamento documentale del 09/09/2026. Questa pagina si riscrive in posto. I documenti recepiscono decisioni e avanzamenti delle task aperte e archiviate; la costruzione del nuovo processo di lavoro è il passo successivo, non è già attivata.

## Il progetto
«The Untold Story» è un GDR play-by-chat in italiano, nell'universo alternativo di Naruto dopo la Notte della Volpe: nessun personaggio canonico esiste nel presente. Beta aperta dal 01/08/2026. Sito `https://theuntoldstory.it`, GitHub Pages, repository `antonello9311-design/theuntoldstory`; backend Supabase `tyhyxkslteigibktluml`. **«L'IA racconta, il server comanda»**: i giocatori scelgono, il motore determina conseguenze e valori, il narratore mette in scena i fatti autorizzati.

## Avvio di ogni task
1. Leggere `AGENTS.md` nella radice e questa pagina: mandato, limiti, owner e procedure vigenti.
2. Leggere `dossier/CONTESTO.md`, `dossier/01_STATO_ATTUALE.md` e `dossier/04_LAVORI_APERTI.md`: riferimenti del gioco, fotografia datata, cantieri e dipendenze correnti.
3. Individuare l'area in `dossier/aree/00_COME_SI_USA.md`; leggere la sua scheda e soltanto i blocchi pertinenti delle fonti elencate.
4. Nel cantiere assegnato leggere `SCHEDA.md` e `HANDOFF.md`: risultato atteso, scope, contratti, prove, blocchi e passaggio richiesto. Non prendere automaticamente il primo lavoro della lista né riaprire un ciclo concluso.
5. Per un dubbio di provenienza usare la sezione pertinente di `dossier/02_INDICE_DOCUMENTI.md`; le decisioni sono in `03_CRONOLOGIA_DECISIONI.md`. Non rileggere tutte le task o i referti pesanti. Prima di modifiche tecniche consultare i blocchi applicabili di `05_CONVENZIONI.md`; architettura e prove sono in `07_ARCHITETTURA.md` e `08_PIANO_PROVE.md`.

## Come distinguere decisioni, stato e prove
Le istruzioni e approvazioni di Antonello stabiliscono cosa si deve fare. Il database interrogato stabilisce cosa è installato e configurato; GitHub e il dominio stabiliscono cosa è pubblicato. La coppia `sito_live/REGOLE.md` / `regole.html`, riconciliata con la pubblicazione, contiene il regolamento. Schede d'area e consegne registrano lo stato con data e fonte; specifiche e vecchie task spiegano l'intenzione, anche quando non ancora implementata.

Una decisione approvata non prova l'implementazione. Una migrazione applicata, una Edge distribuita o un test verde non provano da soli il funzionamento completo. Prima di dichiarare il backend attuale si interroga il DB; prima di dichiarare il sito aggiornato si verifica la pubblicazione. Le prove valgono per versione, percorso e casi effettivamente eseguiti.

## Dove sono le cose
- `sito_live/`: copie locali da riconciliare; i file pubblicabili vanno nella root GitHub. Registro: `dossier/aree/PUBBLICAZIONE.md`.
- `dossier/`: ingresso, fotografia, tabellone e schede d'area; `storico/` conserva i diari precedenti.
- `management/candidati/<CANTIERE>/`: lavori assegnati. In transizione corrisponde a `lavori/<CANTIERE>/` nelle istruzioni. I tre cantieri attivi sono elencati nel tabellone, senza crearne altri da questa pagina.
- `management/repertorio/` e `management/redazione/`: fonti narrative da riconciliare con i profili e i prompt effettivamente distribuiti; `management/coordination/HANDOFFS/`: consegne di provenienza.
- `supabase/`: sorgenti; `claude/`: specifiche e copie ferme, spesso pesanti; `archivio/`: lavori chiusi e fonti storiche. Il caricamento di sorgenti SQL/Edge non le applica al backend.

## Regole operative essenziali
Un file ha un solo owner alla volta; se cambia dopo la lettura, ci si ferma su quel file e si coordina il passaggio. Il parallelismo riguarda lavori indipendenti con scope assegnati; al massimo tre cantieri sono «in lavoro». Ogni task aggiorna la propria consegna e la propria scheda d'area; i riepiloghi centrali sono coordinati dal PM.

Nessuna cancellazione, modifica applicativa o DB fuori autorizzazione. Il lavoro approvato, pronto e verificato viene caricato autonomamente su GitHub limitatamente ai suoi file; apply DB, deploy Edge, enable e apertura generale mantengono i rispettivi gate. «In uso» lo dichiara Antonello.

Per sviluppo e rischi riproducibili si usa PostgreSQL reale in Docker; branch Supabase temporanei solo se motivati e autorizzati anche nel costo. Le funzioni già live si collaudano direttamente nei percorsi protetti delle Test Room. La Staff è autorizzata con testperfunzioni e Riuji; `is_test` da solo non prova l'isolamento. Nella tranche Clan corrente la stessa scena resta aperta per mandato e la Test Room utenti è rinviata: verificare la consegna corrente prima di agire. Dettagli e limiti in `AGENTS.md`.

## Vocabolario minimo
**Deshi** allievo · **Cercoteri**, mai «bijū» nei testi di gioco · **Innata** nona caratteristica · **Ryo** unica valuta · **Scontro** oggetto del motore · **Regia** sessione del Master umano o IA · **Coprifronte**, mai «fascia frontale». L'uso protetto di Riuji nei test non autorizza modifiche al suo account.
