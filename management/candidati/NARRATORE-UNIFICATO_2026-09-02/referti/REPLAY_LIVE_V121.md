# Referto replay LIVE · Edge v121

TASK-ID: `ESAME-GENIN-NARRATORE-FINALE-001`  
Esito: **P1 riproducibile; candidata ritirata e recovery completato**.

## Perimetro e ricevute

- Forward DB sigillato: SHA-256 `7a1864d2f7855844e0b5696728103e553233774269e825c587a24baf2aab9949`.
- Rollback DB sigillato: SHA-256 `a2e2cdd362b05b5c36d5acfe09f99413d85c2af13efe763951d9d18190090e31`.
- Edge candidata distribuita una volta come v121: `4.2.0-NU001-CANDIDATO`, contratto 5, prompt 22, `gpt-5.6-luna`, reasoning high; bundle Supabase `7a94b590e91782b888e947e163b3d1ac77601bd161587b5707ca09375ce135f9`.
- Corpus congelato A–G: 18 cicli, richieste `net` 1046–1063; nessuna pubblicazione e nessuna modifica a prove o sessioni.
- Esito trasporto: 17 HTTP 200, un 504. Esito applicativo: **0/17 cicli accettati**; nessuna rigenerazione qualitativa, perché tutti i primi tentativi disponibili erano meccanicamente invalidi.

## Matrice aggregata dei fallimenti

| Contratto | Rilievi | Cicli coinvolti |
|---|---:|---:|
| Copertura frase-per-fonte o claim non corrispondente | 34 | 10 |
| Persona/elemento non autorizzato | 24 | 10 |
| Movimento senza la fonte di posizione corretta | 20 | 11 |
| Esito, contatto o iniziativa non conformi | 18 | 11 |
| Bersaglio/zona autoritativa non rispettati | 15 | 12 |
| Battuta senza attribuzione esplicita | 10 | 4 |
| Tetto token raggiunto | 3 | 3 |

Totale: 124 rilievi bloccanti su 17 risposte applicative. Il difetto attraversa `png_difende`, `png_attacca`, `png_esito` e `png_finale`; non è riconducibile a un singolo campione.

### Cause aggregate congelate per la revisione successiva

| Causa sistemica | Rilievi ricondotti | Evidenza |
|---|---:|---|
| Sovraccarico del contratto emesso dal modello | 44 | 34 allineamenti frase/fonte + 10 attribuzioni di battuta: Luna doveva scrivere e autocertificare la prosa nello stesso passaggio. |
| Fatti autoritativi lasciati da riallineare dentro la prosa | 53 | 20 movimenti + 18 esiti/contatti/iniziativa + 15 bersagli: tre manifestazioni dello stesso disallineamento fra ricevuta e testo libero. |
| Euristiche lessicali troppo ampie | 24 | Persone o elementi non autorizzati: categoria mista di violazioni reali e falsi positivi possibili, da non espandere con nuovi sinonimi. |
| Budget/tempo incompatibile con la forma richiesta | 3 | Tetto di 6.144 token raggiunto; il costo nasceva da prompt, piano, fonti e prose lunghe concorrenti. |

Queste quattro categorie sono il corpus causale congelato. La revisione successiva non aggiunge esempi, sinonimi o casi marginali: riduce l'output del modello a scelta legale + prosa, aggancia deterministicamente ricevuta e provenienze nella Edge e conserva i controlli meccanici su fatti e autorità.

## Diagnosi minima

- **Prompt:** chiede testi lunghi, piano in otto punti e una riga di fonti per ogni frase. Per `png_attacca` dice che la frase che apre il nuovo attacco deve dichiararne il bersaglio, mentre il validatore cerca il bersaglio nell'ultima frase: il contratto operativo non è univoco. La densità delle istruzioni non impedisce al modello di associare una fonte alla frase sbagliata.
- **Schema:** garantisce forma JSON, ID e vocabolari, ma consente da una a quaranta righe di fonti indipendentemente dal numero reale di frasi. Non può imporre né l'allineamento uno-a-uno né la correttezza semantica di bersaglio, movimento ed esito dentro la prosa.
- **Validatore:** intercetta violazioni reali e diffuse, ma alcune euristiche lessicali sono troppo ampie: nomi comuni possono sembrare persone estranee, una negazione a inizio frase può sembrare un nome proprio e la distinzione fra esito precedente e nuovo attacco dipende dal corretto allineamento delle fonti. I falsi positivi possibili non spiegano comunque lo zero su diciassette, perché bersaglio, movimento, esito e tetti token falliscono su più ruoli e campioni.
- **Provider:** il reasoning high consuma il tetto di uscita; tre cicli hanno esaurito 6.144 token senza produrre una risposta utilizzabile. Una richiesta è terminata al gateway. Il problema è quindi anche di budget/tempo, non soltanto editoriale.

Conclusione: mismatch sistemico fra prompt, schema e validatore. La suite offline 144/144 prova i casi deterministici preparati, ma non predice l'aderenza della generazione Luna al contratto su payload reali.

## Recovery e decisione

- Nessun replay ritentato, nessuna rigenerazione, nessun canary e nessuna pubblicazione.
- Edge ripristinata byte-exact dalla foto v119, distribuita come v122: impronta runtime `4.1.0-NU001`, prompt21, Luna/high.
- DB 006 ripristinato col rollback sigillato; le quattro impronte sono tornate alle preimage. Registro: `20260903203601 esame_narratore_finale_ampiezza_006_recovery`, con forward e rollback conservati.
- Postflight: zero prove aperte; `esame-tick` attivo; nessuna sessione o dato personaggio creato o modificato.
- La certificazione finale non è ottenuta. Il programma QA condiviso Esame + Missioni resta non avviato perché il suo prerequisito era la certificazione dell'Esame.
