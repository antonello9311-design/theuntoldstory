---
name: gdr-pagine
description: Usa questa skill quando si modifica una pagina HTML monolitica del GDR «The Untold Story» (land.html, scheda.html, admin.html, regole.html, index.html, ambientazione.html, storia.html, guida.html, clan.html, entra.html, privacy.html). Sono file da 40-350 KB con style e script in linea, dove lo strumento Edit fallisce sulle righe lunghe concatenate. Contiene il metodo Python con verifica di unicità, il controllo di sintassi del blocco script, le 14 classi CSS da non rinominare, e SOSTITUISCE per questo repo il divieto di usare comandi shell imposto da antigravity-protocol.
---

# gdr-pagine — modificare una pagina monolitica

**Metodo vigente di progetto:** dalla cartella The Untold Story seguire `AGENTS.md` e `management/coordination/AVVIO_LAVORO.md` per mandato, owner, prenotazioni, budget e consegna. Questa skill conserva i dettagli tecnici del proprio dominio; non assegna file né riapre task o autorizzazioni. Preparare gli output in copia e integrarli con il guard del progetto; i gate di produzione restano distinti.


## ⚠️ Deroga esplicita ad `antigravity-protocol`

La skill `antigravity-protocol` vieta al punto 1 l'uso di comandi shell (`cat`, `grep`, `sed`, script bash) per operare sui file, imponendo gli strumenti nativi di modifica.

**Per questo repository quella direttiva non si applica.** Le pagine di «The Untold Story» sono monoliti con righe HTML lunghissime e concatenate, sui quali lo strumento `Edit` fallisce in modo sistematico. Qui si usa **Python con verifica di unicità** e si ispezionano i file da shell. È una deroga limitata a questo progetto e motivata da un limite pratico dello strumento, non una preferenza di stile.

Resta valido tutto il resto di `antigravity-protocol`.

---

## Le pagine e il loro peso

| Pagina | Peso indicativo |
|---|---:|
| `land.html` | ~353 KB |
| `admin.html` | ~192 KB |
| `scheda.html` | ~176 KB |
| `regole.html` | ~137 KB |
| `ambientazione.html` | ~63 KB |
| `guida.html` | ~49 KB |
| `index.html` | ~46 KB |
| `storia.html` | ~43 KB |
| `entra.html` | ~42 KB |
| `clan.html` | ~33 KB |
| `privacy.html` | ~11 KB |

**La regola di lettura, che vale su tutte:** non si legge mai un file intero se non è strettamente necessario — **si legge solo il blocco rilevante**. Su una pagina da 350 KB aprire tutto per cambiare tre parole significa bruciare l'intera conversazione in una lettura sola.

Le copie `claude/pagina_*.html` conservate nel progetto **non sono vietate**, ma sono istantanee vecchie: la verità è il file locale allineato a quello su GitHub, oppure il sito live. Si guarda la copia solo se serve davvero sapere com'era una pagina a quella data — sapendo che `project_read` non sa restituire un pezzo di documento: o tutto o niente. Quando capita, meglio dirlo prima ad Antonello.

---

## La procedura

### 1 · Backup in `/tmp/`

```bash
cp land.html /tmp/land.html.bak && ls -l /tmp/land.html.bak
```

Alla fine si confrontano le dimensioni: una differenza inattesa di molti KB è un segnale d'allarme.

### 2 · Localizzare il punto

```bash
grep -n "acad-overlay" land.html
```

Serve il numero di riga, non il contenuto della pagina. Poi si legge **solo l'intervallo che interessa**, mai il file intero:

```bash
sed -n '1375,1400p' land.html      # oppure: Read con offset=1375, limit=26
```

Se il blocco è più lungo del previsto si allarga l'intervallo un po' alla volta. Non stampare mai blocchi lunghi: se rispondere a una domanda sembra richiedere migliaia di righe, quasi sempre la domanda giusta era un'altra — un `grep -c`, un conteggio, una ricerca mirata.

### 3 · Sostituire con Python, con l'unicità garantita

```python
p = 'land.html'
s = open(p, encoding='utf-8').read()

old = "onerror=\"this.parentNode.innerHTML=MK_SYM.village\""
new = "onerror=\"this.parentNode.innerHTML=window.MK_SYM.village\""

assert s.count(old) == 1, f"trovate {s.count(old)} occorrenze — fermarsi"
s = s.replace(old, new)
open(p, 'w', encoding='utf-8').write(s)
print("ok")
```

L'`assert` è il punto centrale: **fallisce rumorosamente** se il testo è cambiato o se compare più volte, invece di sostituire nel posto sbagliato. Se le occorrenze sono più d'una e vanno cambiate tutte, si conta prima e si verifica il numero atteso.

⚠️ **Ispezionare un file da shell non soddisfa la precondizione di lettura di `Edit`**: se poi si vuole usare `Edit`, il file va letto con `Read`.

### 4 · Verificare la sintassi del blocco `<script>`

`node --check <(sed …)` **non funziona**: non sa leggere una FIFO da process substitution. Si estrae il blocco in un file vero:

```python
import re
s = open('land.html', encoding='utf-8').read()
blocchi = re.findall(r'<script[^>]*>(.*?)</script>', s, re.S)
open('/tmp/check.js','w',encoding='utf-8').write(
    "(async function(){\n" + blocchi[-1] + "\n})();")
```

```bash
node --check /tmp/check.js
```

L'involucro `(async function(){…})();` serve perché i blocchi usano `await` a livello superiore.

Per i blocchi di soli dati, `node -e "var CERC=…"` fallisce: usare `eval('(' + src + ')')`.

### 5 · Controlli di coerenza

- **Tag bilanciati**, se si è toccato il markup:
  ```bash
  for t in div section table ul li p; do
    echo "$t: $(grep -o "<$t[ >]" land.html | wc -l) / $(grep -o "</$t>" land.html | wc -l)"
  done
  ```
- **Entità UTF-8 letterali** (`—`, `·`, `è`, `§`), non entità nominate.
- **Dimensione del file** confrontata col backup.

---

## Da non toccare, mai

- **Le 14 classi CSS elencate nel report del 25/07**: sono costruite per **concatenazione in JavaScript** (`'btn-' + tipo`), quindi un rinomina apparentemente innocuo rompe la pagina **in silenzio**, senza errori in console. Prima di rinominare una classe, cercarla come frammento di stringa nel JS.
- Le costanti `SB_URL` e `SB_KEY`.
- La struttura di `EMB_EXTRA`, `BIJUU`, `CORP_SPEC_OPTS` in `admin.html`: si aggiungono voci, non si riorganizza.

---

## Attenzioni ricorrenti

- **Firme RPC.** Se il SQL cambia la firma di una funzione chiamata dalla pagina (`companion_create`, `premio_richiedi`, `training_start`…), **HTML e SQL vanno rilasciati insieme**. Dirlo esplicitamente.
- **Duplicazione nota da ripulire** (post-apertura): ~35 KB di blocco bijuu duplicato in tre file, `escI()` duplicata, `esc()` disallineata fra le pagine.
- **Mobile:** `admin.html` ha una sola media query; l'header di `index.html` soffre sugli schermi stretti; la mappa è troppo grande sui 14".

---

## Chiusura e pubblicazione

Seguire gdr-chiusura e AGENTS: caricamento autonomo dei soli file approvati e verificati, riconciliazione remota prima, commit e verifica del dominio dopo. Il registro PUBBLICAZIONE distingue file caricati e file rimasti locali con motivo. Nessun caricamento cumulativo o richiesta all'utente di ricopiare file già depositati. Immagini mancanti solo se pertinenti al lavoro.
